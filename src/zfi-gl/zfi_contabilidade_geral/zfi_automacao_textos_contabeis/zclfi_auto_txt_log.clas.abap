"!<p><h2>Automação textos contábeis - Log</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 17 de jan de 2022</p>
CLASS zclfi_auto_txt_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
      "! Objeto SLG0
      BEGIN OF gc_log_objeto,
        "! Objeto de log
        obj    TYPE bal_s_log-object VALUE 'ZFI_AUTOTXTCONT',
        "! Subobjeto de log
        subobj TYPE bal_s_log-subobject VALUE 'FILL_SGTXT',
      END OF gc_log_objeto.

    CONSTANTS:
      "! Classe de mensagem
      gc_msgid TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB'.

    METHODS:
      "! Inicializa o objeto
      constructor,

      "! Armazena novo log
      "! @parameter is_message          | Mensagem
      "! @parameter is_log_context      | Contexto do log
      insert_log
        IMPORTING
          is_message     TYPE bapiret2
          is_log_context TYPE zsfi_log_autotxtcont OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      "! Controlador do log
      gv_log_handle TYPE balloghndl.

    METHODS:
      "! Inicializa o objeto de log SLG1 ZFI_VAN_FINNET
      init_log.

ENDCLASS.



CLASS ZCLFI_AUTO_TXT_LOG IMPLEMENTATION.


  METHOD constructor.
    me->init_log( ).
  ENDMETHOD.


  METHOD init_log.

    DATA: ls_log        TYPE bal_s_log.

    ls_log-aluser    = sy-uname.
    ls_log-alprog    = sy-repid.
    ls_log-object    = gc_log_objeto-obj.
    ls_log-subobject = gc_log_objeto-subobj.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ls_log
      IMPORTING
        e_log_handle = gv_log_handle
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    IF sy-batch EQ abap_True.

      CALL FUNCTION 'BP_ADD_APPL_LOG_HANDLE'
        EXPORTING
          loghandle = gv_log_handle
        EXCEPTIONS
          OTHERS    = 4.

      IF sy-subrc NE 0.
        RETURN.
      ENDIF.

    ENDIF.


  ENDMETHOD.


  METHOD insert_log.

    CONSTANTS:
      lc_estrutura_context TYPE bal_s_msg-context-tabname VALUE 'ZSFI_LOG_AUTOTXTCONT',
      lc_probclass         TYPE bal_s_msg-probclass VALUE '1'.

    DATA: ls_msg        TYPE bal_s_msg,
          lt_log_handle TYPE bal_t_logh.

    DATA: ls_context TYPE zsfi_log_autotxtcont.

    ls_msg-msgty     = is_message-type.
    ls_msg-msgid     = COND #( WHEN is_message-id IS INITIAL THEN gc_msgid
                               ELSE is_message-id ).
    ls_msg-msgno     = is_message-number.
    ls_msg-msgv1     = is_message-message_v1.
    ls_msg-msgv2     = is_message-message_v2.
    ls_msg-msgv3     = is_message-message_v3.
    ls_msg-msgv4     = is_message-message_v4.
    ls_msg-probclass = lc_probclass.

    MESSAGE id ls_msg-msgid TYPE 'S' NUMBER ls_msg-msgno
      WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4 DISPLAY LIKE ls_msg-msgty.
    .

*    ls_context = is_log_context.
*
*    ls_msg-context-tabname = lc_estrutura_context.
*    ls_msg-context-value   = ls_context.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = gv_log_handle
        i_s_msg          = ls_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    FREE lt_log_handle.
    APPEND gv_log_handle TO lt_log_handle.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle = lt_log_handle
      EXCEPTIONS
        OTHERS         = 4.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
