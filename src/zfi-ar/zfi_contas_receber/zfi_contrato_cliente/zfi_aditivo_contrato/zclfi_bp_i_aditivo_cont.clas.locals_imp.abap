CLASS lhc__aditivo DEFINITION INHERITING FROM cl_abap_behavior_handler.


  PUBLIC SECTION.

    METHODS setup_messages IMPORTING p_task TYPE clike.

  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ _aditivo RESULT result.

    METHODS aditivo FOR MODIFY
      IMPORTING keys FOR ACTION _aditivo~aditivo.

    DATA gv_wait_async     TYPE abap_bool.
    DATA gt_messages       TYPE STANDARD TABLE OF bapiret2.

ENDCLASS.

CLASS lhc__aditivo IMPLEMENTATION.

  METHOD read.

    IF keys IS NOT INITIAL.
      SELECT *
            FROM zi_aditivo_cont
            FOR ALL ENTRIES IN @keys
            WHERE docuuidh   = @keys-docuuidh
              AND contrato   = @keys-contrato
              AND aditivo    = @keys-aditivo
              INTO TABLE @DATA(lt_contrato).
    ENDIF.

    result = CORRESPONDING #( lt_contrato ).
  ENDMETHOD.

  METHOD aditivo.

    gv_wait_async = abap_false.

    READ ENTITIES OF zi_aditivo_cont IN LOCAL MODE
       ENTITY _aditivo
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_contrato)
       FAILED failed.

    READ TABLE lt_contrato ASSIGNING FIELD-SYMBOL(<fs_contrato>) INDEX 1.
    IF sy-subrc = 0.

      CALL FUNCTION 'ZFMFI_ADITIVO_CONTRATO'
        STARTING NEW TASK 'ADITIVO'
        CALLING setup_messages ON END OF TASK
        EXPORTING
          iv_doc_uuid_h = <fs_contrato>-docuuidh.

      WAIT UNTIL gv_wait_async = abap_true.

      LOOP AT gt_messages INTO DATA(ls_message).         "#EC CI_NESTED

        APPEND VALUE #( %tky        = <fs_contrato>-%tky
                        %msg        = new_message( id       = ls_message-id
                                                   number   = ls_message-number
                                                   v1       = ls_message-message_v1
                                                   v2       = ls_message-message_v2
                                                   v3       = ls_message-message_v3
                                                   v4       = ls_message-message_v4
                                                   severity = CONV #( ls_message-type ) )
                         )
          TO reported-_aditivo.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD setup_messages.
    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_ADITIVO_CONTRATO'
        IMPORTING
          et_return = gt_messages.

    gv_wait_async = abap_true.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_zi_aditivo_cont DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lcl_zi_aditivo_cont IMPLEMENTATION.

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
