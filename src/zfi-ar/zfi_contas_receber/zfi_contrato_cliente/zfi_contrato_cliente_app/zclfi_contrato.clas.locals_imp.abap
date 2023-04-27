
CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.

    METHODS setup_messages IMPORTING p_task TYPE clike.
    METHODS messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.
    METHODS calculardocumentno FOR DETERMINE ON SAVE
      IMPORTING keys FOR _contrato~calculardocumentno.

    METHODS updatestatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _contrato~updatestatus.

    METHODS desativar FOR MODIFY
      IMPORTING keys FOR ACTION _contrato~desativar RESULT result.

    METHODS renovar FOR MODIFY
      IMPORTING keys FOR ACTION _contrato~renovar.

    METHODS buscaproximoid
      RETURNING
        VALUE(rv_number) TYPE ze_num_contrato.

    METHODS get_features FOR FEATURES
      IMPORTING keys REQUEST requested_features FOR _contrato RESULT result.

    METHODS get_authorizations FOR AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR _contrato RESULT result.

    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _contrato~authoritycreate.

    METHODS validacampos FOR VALIDATE ON SAVE
      IMPORTING keys FOR _contrato~validacampos.
    METHODS updatestatusdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _contrato~updatestatusdata.

    DATA gv_wait_async     TYPE abap_bool.
    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.

ENDCLASS.

CLASS lhc_header IMPLEMENTATION.


  METHOD buscaproximoid.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZFICONTRAT'
      IMPORTING
        number                  = rv_number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD calculardocumentno.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
    ENTITY _contrato
    FIELDS ( contrato )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

    IF NOT line_exists( lt_header[ contrato  = '' ] ).   "#EC CI_STDSEQ
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
    ENTITY _contrato
    UPDATE FIELDS ( contrato status )
    WITH VALUE #( FOR ls_header IN lt_header WHERE ( contrato IS INITIAL ) ( "#EC CI_STDSEQ
                       %key      =  ls_header-%key
                        contrato   = buscaproximoid( )
                        status = '1'
                       ) )
    REPORTED DATA(lt_reported).

  ENDMETHOD.


  METHOD get_features.


    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
      ENTITY _contrato
        FIELDS ( status ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header)
      FAILED failed.


    result =
        VALUE #(
        FOR ls_header IN lt_header
        LET lv_desativar =   COND #( WHEN ls_header-status = '6'
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled  )

        IN
          ( %tky              = ls_header-%tky
            %action-desativar = lv_desativar
           ) ).


  ENDMETHOD.


  METHOD desativar.

    gv_wait_async = abap_false.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
         ENTITY _contrato
         FIELDS ( docuuidh status ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_header)
         FAILED failed.

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.

    IF sy-subrc = 0.

      CALL FUNCTION 'ZFMFI_DESATIVAR_CONTRATO'
        STARTING NEW TASK 'DESACONT'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          iv_doc_uuid_h = <fs_header>-docuuidh.

      WAIT UNTIL gv_wait_async = abap_true.

    ENDIF.


    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
         ENTITY _contrato
         FIELDS ( status ) WITH CORRESPONDING #( keys )
         RESULT DATA(lt_return)
         FAILED failed.

    result = VALUE #( FOR ls_header IN lt_return
                    ( %tky   = ls_header-%tky
                      %param = ls_header ) ).

  ENDMETHOD.


  METHOD setup_messages.
    gv_wait_async = abap_true.
  ENDMETHOD.


  METHOD renovar.
    gv_wait_async = abap_false.

    DATA(lv_observacao) = keys[ 1 ]-%param-observacao.


    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
        ENTITY _contrato
          FIELDS ( docuuidh aditivo contrato ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_dados)
        FAILED failed.

    READ TABLE lt_dados ASSIGNING FIELD-SYMBOL(<fs_dados>) INDEX 1.
    IF sy-subrc = 0.

      CALL FUNCTION 'ZFMFI_RETOMAR_APROVACAO'
        STARTING NEW TASK 'RETAPROV'
        CALLING messages ON END OF TASK
        EXPORTING
          iv_observacao = lv_observacao
          iv_contrato   = <fs_dados>-contrato
          iv_aditivo    = <fs_dados>-aditivo.

      WAIT UNTIL gv_wait_async = abap_true.
      IF line_exists( gt_messages[ type = 'E' ] ).       "#EC CI_STDSEQ

        LOOP AT gt_messages INTO DATA(ls_message).       "#EC CI_NESTED

          APPEND VALUE #( %msg        = new_message( id       = ls_message-id
                                                     number   = ls_message-number
                                                     v1       = ls_message-message_v1
                                                     v2       = ls_message-message_v2
                                                     v3       = ls_message-message_v3
                                                     v4       = ls_message-message_v4
                                                     severity = CONV #( ls_message-type ) )
                           )
            TO reported-_contrato.

        ENDLOOP.

      ELSE.

        APPEND VALUE #( %msg =  new_message( id       = 'ZFI_CONTRATO_CLIENTE'
                         number   = CONV #( '007' )
                         severity = CONV #( 'S' ) ) ) TO reported-_contrato.

        APPEND VALUE #( %msg =  new_message( id       = 'ZFI_CONTRATO_CLIENTE'
                         number   = CONV #( '003' )
                         v1       = <fs_dados>-contrato
                         v2       = <fs_dados>-aditivo
                         severity = CONV #( 'S' ) ) ) TO reported-_contrato.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD messages.
    RECEIVE RESULTS FROM FUNCTION 'ZZFMFI_RETOMAR_APROVACAO'
         IMPORTING
           et_return = gt_messages.

    gv_wait_async = abap_true.
  ENDMETHOD.


  METHOD updatestatus.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
        ENTITY _contrato
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header).

    MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
        ENTITY _contrato
        UPDATE FIELDS ( status )
        WITH VALUE #( FOR ls_header IN lt_header  WHERE (
                      desativado IS NOT INITIAL ) (
                      %key      =  ls_header-%key
                      status = '6'
                      %control-status = if_abap_behv=>mk-on
                      ) )
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).                      "#EC CI_STDSEQ

    reported = CORRESPONDING #( DEEP lt_reported ).

  ENDMETHOD.


  METHOD authoritycreate.

    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
        ENTITY _contrato
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF zclfi_auth_zfibukrs=>bukrs_create( <fs_data>-bukrs ) EQ abap_false.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area )
        TO reported-_contrato.

        APPEND VALUE #( %tky = <fs_data>-%tky ) TO failed-_contrato.

        APPEND VALUE #( %tky        = <fs_data>-%tky
                        %state_area = lc_area
                        %msg        = NEW zcxca_authority_check(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcxca_authority_check=>gc_create )
                        %element-bukrs = if_abap_behv=>mk-on )
          TO reported-_contrato.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validacampos.

    DATA: lt_return_all TYPE bapiret2_t.

* ---------------------------------------------------------------------------
* Recupera linhas selecionadas
* ---------------------------------------------------------------------------
    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
        ENTITY _contrato
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_contrato).

    DATA(lo_contrato) = NEW zclfi_contrato_cliente_util( ).

* ---------------------------------------------------------------------------
* Valida campos
* ---------------------------------------------------------------------------
    LOOP AT lt_contrato REFERENCE INTO DATA(ls_contrato).

      lo_contrato->valida_contrato( EXPORTING is_contrato = CORRESPONDING #( ls_contrato->* )
                                    IMPORTING et_return   = DATA(lt_return) ).

      INSERT LINES OF lt_return[] INTO TABLE lt_return_all[].
    ENDLOOP.

* ---------------------------------------------------------------------------
* Monta mensagens de retorno
* ---------------------------------------------------------------------------
    lo_contrato->reported( EXPORTING it_return   = lt_return_all
                           IMPORTING es_reported = DATA(lt_reported) ).

    reported = CORRESPONDING #( DEEP lt_reported ).

  ENDMETHOD.


  METHOD get_authorizations.

    DATA: lv_update TYPE if_abap_behv=>t_xflag.

    READ ENTITIES OF zi_fi_contrato  IN LOCAL MODE
        ENTITY _contrato
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data)
        FAILED failed.

    CHECK lt_data IS NOT INITIAL.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

        IF zclfi_auth_zfibukrs=>bukrs_update( <fs_data>-bukrs ).
          lv_update = if_abap_behv=>auth-allowed.
        ELSE.
          lv_update = if_abap_behv=>auth-unauthorized.
        ENDIF.

      ENDIF.

      APPEND VALUE #( %tky           = <fs_data>-%tky
                      %update        = lv_update
                      %assoc-_raiz   = lv_update
                      %assoc-_cond   = lv_update
                      %assoc-_prov   = lv_update
                      %assoc-_janela = lv_update )
             TO result.
    ENDLOOP.

  ENDMETHOD.


  METHOD updatestatusdata.

    READ ENTITIES OF zi_fi_contrato IN LOCAL MODE
    ENTITY _contrato
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).



    MODIFY ENTITIES OF zi_fi_contrato IN LOCAL MODE
        ENTITY _contrato
        UPDATE FIELDS ( status )
        WITH VALUE #( FOR ls_header IN lt_header  WHERE (
                      datafimvalid < sy-datum ) (
                      %key      =  ls_header-%key
                      status = '5' "Contrato vencido
                      %control-status = if_abap_behv=>mk-on
                      ) )
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).                      "#EC CI_STDSEQ

    reported = CORRESPONDING #( DEEP lt_reported ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
