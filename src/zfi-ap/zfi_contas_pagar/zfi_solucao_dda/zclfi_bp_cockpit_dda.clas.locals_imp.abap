CLASS lhc_cockpit DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.
    DATA gv_wait_async     TYPE abap_bool.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK cockpit.

    METHODS read FOR READ
      IMPORTING keys FOR READ cockpit RESULT result.

    METHODS reprocessar FOR MODIFY
      IMPORTING keys FOR ACTION cockpit~reprocessar.
    METHODS notadivergente FOR MODIFY
      IMPORTING keys FOR ACTION cockpit~notadiv.

ENDCLASS.

CLASS lhc_cockpit IMPLEMENTATION.

  METHOD lock.
    RETURN.
  ENDMETHOD.

  METHOD read.

    DATA(lt_keys) = keys[].

*    LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<fs_key>).
*
*      CONDENSE <fs_key>-supplier NO-GAPS.
*      CONDENSE <fs_key>-docnumber NO-GAPS.
*      CONDENSE <fs_key>-miroinvoice NO-GAPS.
*
*    ENDLOOP.

    SELECT *
    FROM zi_fi_cockpit_dda
    FOR ALL ENTRIES IN @lt_keys
    WHERE  statuscheck = @lt_keys-statuscheck
*      AND supplier = @lt_keys-supplier
      AND referenceno = @lt_keys-referenceno
*      AND docnumber = @lt_keys-docnumber
*      AND miroinvoice = @lt_keys-miroinvoice
      AND companycode = @lt_keys-companycode
      AND fiscalyear = @lt_keys-fiscalyear
      AND cnpj = @lt_keys-cnpj
      AND duedate = @lt_keys-duedate
      AND dataarq = @lt_keys-dataarq
      INTO TABLE @DATA(lt_result).

    result = CORRESPONDING #( lt_result ) .


  ENDMETHOD.

  METHOD reprocessar.


    DATA: lt_process_f TYPE ztt_j1b_error_dda,
          lt_msg       TYPE bapiret2_tab.

    READ ENTITIES OF zi_fi_cockpit_dda IN LOCAL MODE
    ENTITY cockpit
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_process)
    FAILED failed
    REPORTED reported.

    IF lt_process IS NOT INITIAL.

      lt_process_f = VALUE ztt_j1b_error_dda( FOR ls_process IN lt_process (
                 status_check      = ls_process-statuscheck
                 lifnr             = ls_process-supplier
                 cnpj             = ls_process-cnpj
                 reference_no      = ls_process-referenceno
                 doc_num           = ls_process-docnumber
                 miro_invoice      = ls_process-miroinvoice
                 bukrs             = ls_process-companycode
                 gjahr             = ls_process-fiscalyear
                 due_date          = ls_process-duedateconverted
                 barcode           = ls_process-barcode
                 amount           =  ls_process-amountnotconv
                 ) ).

      CLEAR: gv_wait_async.

      CALL FUNCTION 'ZFMFI_DDA_REPROCESSA'
        STARTING NEW TASK 'DDAREPROCESSA'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          it_process = lt_process_f.

      WAIT UNTIL gv_wait_async = abap_true.


      LOOP AT gt_messages INTO DATA(ls_message).         "#EC CI_NESTED

        APPEND VALUE #( %msg        = new_message( id       = ls_message-id
                                                   number   = ls_message-number
                                                   v1       = ls_message-message_v1
                                                   v2       = ls_message-message_v2
                                                   v3       = ls_message-message_v3
                                                   v4       = ls_message-message_v4
                                                   severity = CONV #( ls_message-type ) )
                         )
          TO reported-cockpit.

      ENDLOOP.

    ENDIF.


  ENDMETHOD.

  METHOD setup_messages.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_DDA_REPROCESSA'
        IMPORTING
          et_return = gt_messages.

    gv_wait_async = abap_true.

  ENDMETHOD.

  METHOD notadivergente.

    DATA(lv_belnr) = keys[ 1 ]-%param-nfdiv_belnr.
    DATA(lv_buzei) = keys[ 1 ]-%param-nfdiv_buzei.

    READ ENTITIES OF zi_fi_cockpit_dda IN LOCAL MODE
    ENTITY cockpit
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_process)
    FAILED failed
    REPORTED reported.

    IF lines( lt_process ) = 1.

      DATA(ls_process_dda) = lt_process[ 1 ].

      DATA(ls_process) = VALUE j1b_error_dda(
           status_check = ls_process_dda-statuscheck
           lifnr        = ls_process_dda-supplier
           cnpj         = ls_process_dda-cnpj
           reference_no = ls_process_dda-referenceno
           doc_num      = ls_process_dda-docnumber
           miro_invoice = ls_process_dda-miroinvoice
           bukrs        = ls_process_dda-companycode
           gjahr        = ls_process_dda-fiscalyear
           due_date     = ls_process_dda-duedateconverted
           barcode      = ls_process_dda-barcode
           amount       = ls_process_dda-amount
            ).

      CLEAR: gv_wait_async.

      CALL FUNCTION 'ZFMFI_DDA_ATRIB'
        STARTING NEW TASK 'DDAATRIB'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          is_process_dda = ls_process
          iv_belnr       = lv_belnr
          iv_buzei       = lv_buzei.

      WAIT UNTIL gv_wait_async = abap_true.

      LOOP AT gt_messages INTO DATA(ls_message).         "#EC CI_NESTED

        APPEND VALUE #( %tky = ls_process_dda-%tky
                        %msg = new_message( id       = ls_message-id
                                                   number   = ls_message-number
                                                   v1       = ls_message-message_v1
                                                   v2       = ls_message-message_v2
                                                   v3       = ls_message-message_v3
                                                   v4       = ls_message-message_v4
                                                   severity = CONV #( ls_message-type ) )
                         )
          TO reported-cockpit.

      ENDLOOP.

    ELSEIF lines( lt_process ) > 1.

      " Selecione somente uma linha para nota fiscal divergente
      APPEND VALUE #( %tky = ls_process_dda-%tky
                      %msg  = new_message( id       = 'ZFI_SOLUCAO_DDA'
                                                   number   = '020'
                                                   severity = CONV #( 'E' ) )
                         )
          TO reported-cockpit.

    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_fi_cockpit_dda DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_zi_fi_cockpit_dda IMPLEMENTATION.

  METHOD check_before_save.
    RETURN.
  ENDMETHOD.

  METHOD finalize.
    RETURN.
  ENDMETHOD.

  METHOD save.
    RETURN.
  ENDMETHOD.

ENDCLASS.
