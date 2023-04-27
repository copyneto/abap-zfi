CLASS lcl_compcrescimento DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS: gc_msgid    TYPE sy-msgid VALUE 'ZFI_CONTRATO_CLIENTE',
               gc_error    TYPE sy-msgty VALUE 'E',
               gc_e_perid  TYPE sy-msgno VALUE '033',
               gc_e_duplic TYPE sy-msgno VALUE '034',
               gc_e_mont   TYPE sy-msgno VALUE '035'.

    METHODS calcdocno FOR DETERMINE ON SAVE
      IMPORTING keys FOR _compcrescimento~calcdocno.
    METHODS updatecurrency FOR DETERMINE ON MODIFY
      IMPORTING keys FOR _compcrescimento~updatecurrency.
    METHODS authoritycreate FOR VALIDATE ON SAVE
      IMPORTING keys FOR _compcrescimento~authoritycreate.
    METHODS validaciclo FOR VALIDATE ON SAVE
      IMPORTING keys FOR _compcrescimento~validaciclo.

ENDCLASS.

CLASS lcl_compcrescimento IMPLEMENTATION.

  METHOD calcdocno.

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
  ENTITY _crescimento
  FIELDS ( contrato )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_header).

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _crescimento BY \_compcresci
    FIELDS ( contrato )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_linha).

    READ TABLE lt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
    IF sy-subrc = 0.

      SELECT SINGLE contrato, aditivo
      FROM ztfi_contrato
      INTO @DATA(ls_contrato)
      WHERE doc_uuid_h = @<fs_header>-docuuidh.

      MODIFY ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
      ENTITY _compcrescimento
      UPDATE FIELDS ( contrato aditivo )
      WITH VALUE #( FOR ls_linha IN lt_linha (           "#EC CI_STDSEQ
                         %key      =  ls_linha-%key
                          contrato = ls_contrato-contrato
                          aditivo = ls_contrato-aditivo
                         ) )
      REPORTED DATA(lt_reported).

    ENDIF.
  ENDMETHOD.

  METHOD updatecurrency.

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _compcrescimento
    FIELDS ( contrato )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_linha).

    MODIFY ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _compcrescimento
    UPDATE SET FIELDS WITH VALUE #( FOR ls_linha IN lt_linha (
                                        %key = ls_linha-%key
                                        waers = 'BRL'
                                        %control = VALUE #( waers = if_abap_behv=>mk-on )
                                    ) ) REPORTED DATA(lt_reported).

    reported = CORRESPONDING #( DEEP lt_reported ).

  ENDMETHOD.

  METHOD authoritycreate.
    CONSTANTS lc_area TYPE string VALUE 'VALIDATE_CREATE'.

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
        ENTITY _crescimento
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_data).

    TRY.
        DATA(ls_root_data) = lt_data[ 1 ].

        LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
          IF zclfi_auth_zfibukrs=>bukrs_create( ls_root_data-bukrs ) EQ abap_false.

            APPEND VALUE #( %tky        = <fs_key>-%tky
                            %state_area = lc_area )
            TO reported-_compcrescimento.

            APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-_compcrescimento.

            APPEND VALUE #( %tky        = <fs_key>-%tky
                            %state_area = lc_area
                            %msg        = NEW zcxca_authority_check(
                                              severity = if_abap_behv_message=>severity-error
                                              textid   = zcxca_authority_check=>gc_create )
                            %element-ciclos = if_abap_behv=>mk-on )
              TO reported-_compcrescimento.
          ENDIF.
        ENDLOOP.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.

  METHOD validaciclo.

    DATA: lt_ciclos_cres TYPE STANDARD TABLE OF zsfi_ciclos_cresc_ctrt.

    DATA: lv_ciclo TYPE ze_ciclobasecomp,
          lv_error TYPE char1.

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _crescimento BY \_cadcresci
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_crescimento).

    READ ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
    ENTITY _crescimento BY \_compcresci
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_ciclos).

    IF lt_crescimento IS NOT INITIAL.

      DATA(ls_keys)        = keys[ 1 ].
      DATA(ls_crescimento) = lt_crescimento[ 1 ].

      SORT lt_ciclos BY ciclos.

      CLEAR: lv_error.
      LOOP AT lt_ciclos ASSIGNING FIELD-SYMBOL(<fs_ciclos>).

        IF lv_ciclo NE <fs_ciclos>-ciclos.

          IF <fs_ciclos>-montcomp IS INITIAL.
            APPEND VALUE #( %tky        = ls_keys-%tky
                            %msg        = new_message( id       = gc_msgid
                                                       number   = gc_e_mont
                                                       severity =  CONV #( gc_error ) )
                            %element-montcomp = if_abap_behv=>mk-on )
                         TO reported-_compcrescimento.
          ELSE.
            lv_ciclo       = <fs_ciclos>-ciclos.
            lt_ciclos_cres = VALUE #( BASE lt_ciclos_cres ( ciclo = <fs_ciclos>-ciclos ) ).
          ENDIF.

        ELSE.

          APPEND VALUE #( %tky        = ls_keys-%tky
                          %msg        = new_message( id       = gc_msgid
                                                     number   = gc_e_duplic
                                                     severity =  CONV #( gc_error ) )
                          %element-ciclos = if_abap_behv=>mk-on )
                       TO reported-_compcrescimento.

          lv_error = abap_true.
          EXIT.

        ENDIF.

      ENDLOOP.

      IF  1 = 2.
        MODIFY ENTITIES OF zi_fi_contrato_cresc IN LOCAL MODE
        ENTITY _compcrescimento
        DELETE FROM CORRESPONDING #( lt_ciclos )
        REPORTED DATA(lt_reported).
      ENDIF.

      IF lv_error IS INITIAL.

        DATA(lo_object) = NEW zclfi_ciclos_cescim_contrat( ).

        lo_object->check_ciclo(
          EXPORTING
            iv_periodicidade = ls_crescimento-periodicidade
            it_ciclos        = lt_ciclos_cres[]
          IMPORTING
            es_return        = DATA(ls_return) ).

        IF ls_return IS NOT INITIAL.

          APPEND VALUE #( %tky        = ls_keys-%tky
                          %msg        = new_message( id       = ls_return-id
                                                     number   = ls_return-number
                                                     severity =  CONV #( ls_return-type ) )
                          %element-ciclos = if_abap_behv=>mk-on )
                       TO reported-_compcrescimento.
        ENDIF.
      ENDIF.

    ELSE.

      APPEND VALUE #( %tky        = ls_keys-%tky
                      %msg        = new_message( id       = gc_msgid
                                                 number   = gc_e_perid
                                                 severity =  CONV #( gc_error ) ) )
                   TO reported-_compcrescimento.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
