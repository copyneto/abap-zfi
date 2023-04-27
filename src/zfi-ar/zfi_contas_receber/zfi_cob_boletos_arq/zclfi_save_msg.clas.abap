CLASS zclfi_save_msg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:  gc_object TYPE bal_s_log-object VALUE 'ZFI_CAN_JOB'.

    METHODS save_ballog
      IMPORTING
        iv_subobject TYPE balsubobj
        it_msg       TYPE bapiret2_tab.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gv_log_handle TYPE balloghndl .

    METHODS create_log
      IMPORTING
        !iv_subobject TYPE balsubobj .
    METHODS add_msgs
      IMPORTING
        !it_msg TYPE bapiret2_tab .
    METHODS save_ball .
ENDCLASS.



CLASS zclfi_save_msg IMPLEMENTATION.


  METHOD save_ballog.

    IF lines( it_msg ) LE 120.

      create_log( iv_subobject ).

      add_msgs( it_msg ).

      save_ball( ).

    ENDIF.

  ENDMETHOD.


  METHOD create_log.

    DATA: ls_log        TYPE bal_s_log.

    ls_log-aluser    = sy-uname.
    ls_log-alprog    = sy-repid.
    ls_log-object    = gc_object.
    ls_log-subobject = iv_subobject.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ls_log
      IMPORTING
        e_log_handle = gv_log_handle
      EXCEPTIONS
        OTHERS       = 1 ##FM_SUBRC_OK.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD add_msgs.

    DATA: ls_msg        TYPE bal_s_msg,
          lt_log_handle TYPE bal_t_logh.

    APPEND gv_log_handle TO lt_log_handle.

*    DATA: ls_context TYPE ypoc_job.

    LOOP AT it_msg ASSIGNING FIELD-SYMBOL(<fs_msg>).
      ls_msg = VALUE #(
        msgty = <fs_msg>-type
        msgid = <fs_msg>-id
        msgno = <fs_msg>-number
        msgv1 = <fs_msg>-message_v1
        msgv2 = <fs_msg>-message_v2
        msgv3 = <fs_msg>-message_v3
        msgv4 = <fs_msg>-message_v4
      ).

      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle     = gv_log_handle
          i_s_msg          = ls_msg
        EXCEPTIONS
          log_not_found    = 1
          msg_inconsistent = 2
          log_is_full      = 3
          OTHERS           = 4 ##FM_SUBRC_OK.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
    ENDLOOP.



  ENDMETHOD.


  METHOD save_ball.

    DATA: lt_log_handle TYPE bal_t_logh.

    APPEND gv_log_handle TO lt_log_handle.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle = lt_log_handle
      EXCEPTIONS
        OTHERS         = 4 ##FM_SUBRC_OK.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
