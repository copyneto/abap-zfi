CLASS lcl_contrato DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK contrato.

    METHODS read FOR READ
      IMPORTING keys FOR READ contrato RESULT result.

    METHODS rba_log FOR READ
      IMPORTING keys_rba FOR READ contrato\_log FULL result_requested RESULT result LINK association_links.

    METHODS calccresc FOR MODIFY
      IMPORTING keys FOR ACTION contrato~calccresc.

    METHODS contabili FOR MODIFY
      IMPORTING keys FOR ACTION contrato~contabili.


    CONSTANTS: gc_msgid     TYPE sy-msgid VALUE 'ZFI_BASE_CALCULO',
               gc_msg_exer  TYPE sy-msgno VALUE '003',
               gc_msg_dtlnc TYPE sy-msgno VALUE '004',
               gc_msg_032   TYPE sy-msgno VALUE '032',
               gc_msg_033   TYPE sy-msgno VALUE '033',
               gc_error     TYPE sy-msgty VALUE 'E'.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.

ENDCLASS.

CLASS lcl_contrato IMPLEMENTATION.

  METHOD lock.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD read.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD rba_log.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD calccresc.

    DATA: lt_return TYPE bapiret2_t.

    DATA(ls_keys) = keys[ 1 ].

    DATA(lo_cresc_m) = NEW zclfi_contrato_calc_cresciment( ).

    SELECT doc_uuid_h
      FROM ztfi_contrato
     WHERE contrato = @ls_keys-contrato
       AND aditivo  = @ls_keys-aditivo
      INTO @DATA(lv_doc_uuid_h)
        UP TO 1 ROWS.
    ENDSELECT.

    DATA(ls_import) = VALUE zsfi_key_crescimnt( doc_uuid_h = lv_doc_uuid_h
                                                contrato = ls_keys-contrato
                                                aditivo  = ls_keys-aditivo
                                                ).

    lo_cresc_m->execute( EXPORTING is_import = ls_import
                         IMPORTING et_return = lt_return ).

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_return>).

      APPEND VALUE #( contrato = ls_keys-contrato
                      aditivo  = ls_keys-aditivo
                      %msg     = new_message( id       = <fs_return>-id
                                              number   = <fs_return>-number
                                              severity =  CONV #( <fs_return>-type )
                                              v1       = <fs_return>-message_v1
                                              v2       = <fs_return>-message_v2
                                              v3       = <fs_return>-message_v3
                                              v4       = <fs_return>-message_v4 ) ) TO reported-contrato.

    ENDLOOP.

  ENDMETHOD.

  METHOD contabili.

    DATA: lt_return TYPE bapiret2_t.

    DATA: ls_chv TYPE zsfi_contab_key.

    DATA(ls_keys) = keys[ 1 ].


    SELECT *
      FROM zi_fi_contrato_cliente
     WHERE contrato = @ls_keys-contrato
       AND aditivo  = @ls_keys-aditivo
      INTO @DATA(ls_contrato)
        UP TO 1 ROWS.
    ENDSELECT.

*    SELECT *
*      FROM zi_fi_log_calc_crescimento
*     WHERE contrato = @ls_keys-contrato
*       AND aditivo  = @ls_keys-aditivo
*      INTO @DATA(ls_calc)
*        UP TO 1 ROWS.
*    ENDSELECT.

    IF ls_keys-%param-budat IS INITIAL.
      APPEND VALUE #( contrato = ls_keys-contrato
                      aditivo  = ls_keys-aditivo
                      %msg     = new_message( id       = gc_msgid
                                              number   = gc_msg_dtlnc
                                              severity =  CONV #( gc_error ) ) ) TO reported-contrato.

*    ELSEIF ls_calc IS INITIAL.
*      "Crescimento ainda não foi calculado
*      "Documento já contabilizado: &1 &2 &3
*      APPEND VALUE #( contrato = ls_keys-contrato
*                    aditivo  = ls_keys-aditivo
*                    %msg     = new_message( id       = gc_msgid
*                                            number   = gc_msg_033
*                                            severity =  CONV #( gc_error ) ) ) TO reported-contrato.
*
*    ELSEIF ls_calc-belnr IS NOT INITIAL.
*      "Crescimento do Contrato já contabilizado
*      APPEND VALUE #( contrato = ls_keys-contrato
*                    aditivo  = ls_keys-aditivo
*                    %msg     = new_message( id       = gc_msgid
*                                            number   = 038
*                                            severity =  CONV #( gc_error ) ) ) TO reported-contrato.
    ELSE.


      ls_chv-contrato     = ls_keys-contrato.
      ls_chv-aditivo      = ls_keys-aditivo.
      ls_chv-budat_screen = ls_keys-%param-budat.
*      ls_chv-mont_crescimento = ls_calc-montcrescimento.


      CALL FUNCTION 'ZFMFI_CONTAB_CRESCIMENTO'
        STARTING NEW TASK 'CONTABCRESC'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          is_key = ls_chv.

      WAIT UNTIL gv_wait_async = abap_true.

      LOOP AT gt_messages ASSIGNING FIELD-SYMBOL(<fs_return>).

        APPEND VALUE #( contrato = ls_keys-contrato
                        aditivo  = ls_keys-aditivo
                        %msg     = new_message( id       = <fs_return>-id
                                                number   = <fs_return>-number
                                                severity =  CONV #( <fs_return>-type )
                                                v1       = <fs_return>-message_v1
                                                v2       = <fs_return>-message_v2
                                                v3       = <fs_return>-message_v3
                                                v4       = <fs_return>-message_v4 ) ) TO reported-contrato.

      ENDLOOP.

    ENDIF.
  ENDMETHOD.

  METHOD setup_messages.

*    receive results from function 'ZFMFI_CONTROLE_RAIZ_CNPJ'
    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_CONTAB_CRESCIMENTO'
         IMPORTING
           et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.

ENDCLASS.

CLASS lcl_logcontr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ logcontr RESULT result.

    METHODS rba_contrato FOR READ
      IMPORTING keys_rba FOR READ logcontr\_contrato FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lcl_logcontr IMPLEMENTATION.

  METHOD read.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD rba_contrato.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_zi_fi_contrato_cliente DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_zi_fi_contrato_cliente IMPLEMENTATION.

  METHOD check_before_save.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD finalize.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

  METHOD save.
    IF sy-subrc IS INITIAL.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
