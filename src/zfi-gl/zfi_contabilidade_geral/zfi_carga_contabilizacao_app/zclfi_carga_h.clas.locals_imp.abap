CLASS lhc__h DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS cancelar FOR MODIFY
      IMPORTING keys FOR ACTION _h~cancelar RESULT result.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR _h RESULT result.
    METHODS message FOR MODIFY
      IMPORTING keys FOR ACTION _h~message RESULT result.
    METHODS lancar FOR MODIFY
      IMPORTING keys FOR ACTION _h~lancar RESULT result.

ENDCLASS.

CLASS lhc__h IMPLEMENTATION.

  METHOD cancelar.

    READ ENTITIES OF zi_fi_carga_h IN LOCAL MODE
    ENTITY _h
      FIELDS ( status ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header)
    FAILED failed.

    MODIFY ENTITIES OF zi_fi_carga_h IN LOCAL MODE
    ENTITY _h
    UPDATE FIELDS ( status )
    WITH VALUE #( FOR ls_header IN lt_header (           "#EC CI_STDSEQ
                       %key      =  ls_header-%key
                        status = '3'
                       ) )
    REPORTED DATA(lt_reported2).

    READ ENTITIES OF zi_fi_carga_h IN LOCAL MODE
    ENTITY _h
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_all)
    FAILED failed.


    result = VALUE #( FOR ls_all IN lt_all
                       ( %tky   = ls_all-%tky
                         %param = ls_all ) ).

  ENDMETHOD.

  METHOD get_features.

    READ ENTITIES OF zi_fi_carga_h IN LOCAL MODE
      ENTITY _h
        FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header)
      FAILED failed.


    result =
        VALUE #(
        FOR ls_header IN lt_header
          LET lv_pendente =   COND #( WHEN ls_header-status = '0' "PENDENTE
                                      THEN if_abap_behv=>fc-o-enabled
                                      ELSE if_abap_behv=>fc-o-disabled )

          IN
            ( %tky              = ls_header-%tky
              %action-message  = if_abap_behv=>fc-o-enabled
              %action-cancelar  = lv_pendente
              %action-lancar  = lv_pendente
             ) ).


  ENDMETHOD.

  METHOD message.

    IF lines( keys ) GT 0.
      SELECT documentid,
             seqnr,
             msgty,
             msgid,
             msgno,
             msgv1,
             msgv2,
             msgv3,
             msgv4,
             message
        FROM zi_fi_carga_log
        FOR ALL ENTRIES IN @keys
        WHERE documentid = @keys-docuuidh
        INTO TABLE @DATA(lt_mensagens).

      IF sy-subrc = 0.

        LOOP AT lt_mensagens INTO DATA(ls_mensagens). "#EC CI_LOOP_INTO_WA

          APPEND VALUE #( %tky-docuuidh = ls_mensagens-documentid ) TO failed-_item.

          APPEND VALUE #( %tky = VALUE #( docuuidh = ls_mensagens-documentid )
                          %msg =  new_message( id       = ls_mensagens-msgid
                                               number   = CONV #( ls_mensagens-msgno )
                                               severity = CONV #( ls_mensagens-msgty )
                                               v1       = ls_mensagens-msgv1
                                               v2       = ls_mensagens-msgv2
                                               v3       = ls_mensagens-msgv3
                                               v4       = ls_mensagens-msgv4 ) ) TO reported-_item.
        ENDLOOP.

      ELSE.
        "Não existem mensagens de processamento
        APPEND VALUE #( %tky = VALUE #( docuuidh = ls_mensagens-documentid )
                        %msg =  new_message( id       = 'ZFI_CARGA_CONTAB'
                                             number   = CONV #( '18' )
                                             severity = CONV #( 'W' ) ) ) TO reported-_item.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD lancar.

    READ ENTITIES OF zi_fi_carga_h IN LOCAL MODE
    ENTITY _h
      FIELDS ( docuuidh ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header)
    FAILED failed.

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF sy-subrc = 0.

      CALL FUNCTION 'ZFMFI_CARGA_CONTAB_LANCAR'
        STARTING NEW TASK 'CARGACONT'
        EXPORTING
          iv_doc_uuid_h = <fs_header>-docuuidh.

    ENDIF.

    "Lançamento sendo executado em background
    APPEND VALUE #( %tky = <fs_header>-%tky
                    %msg =  new_message( id       = 'ZFI_CARGA_CONTAB'
                                     number   = CONV #( '017' )
                                     severity = CONV #( 'S' ) ) ) TO reported-_item.

    "Atualiza as informações
    READ ENTITIES OF zi_fi_carga_h IN LOCAL MODE
      ENTITY _h
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_all)
      FAILED failed.

    result = VALUE #( FOR ls_all IN lt_all ( %key = ls_all-%key
                                              %param    = ls_all ) ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
