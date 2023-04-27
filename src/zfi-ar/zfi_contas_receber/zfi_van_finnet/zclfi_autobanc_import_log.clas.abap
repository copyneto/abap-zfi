"!<p><h2>Automat. Bancária Van FINNET - Log de Importação arquivos</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 18 de out de 2021</p>
CLASS zclfi_autobanc_import_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      "! Objeto do Log na transação SLG1
      gc_object TYPE bal_s_log-object VALUE 'ZFI_VAN_FINNET',
      "! Classe de mensagens para VAN Finnet
      gc_msgid  TYPE symsgid VALUE 'ZFI_VAN_FINNET'.

    CONSTANTS:
      "! Subobjetos do log na transação SLG1
      BEGIN OF gc_subobject,
        "! Download na F110
        download_f110   TYPE balsubobj VALUE 'F110',
        "! Importação de arquivos
        importa_arquivo TYPE balsubobj VALUE 'IMPORTA_ARQ',
      END OF gc_subobject.

    CLASS-METHODS:
      "! Gera instância desta classe
      "! @parameter iv_subobject | Subobjeto da SLG1
      "! @parameter ro_result | Instância gerada
      create_instance
        IMPORTING
          !iv_subobject    TYPE balsubobj
        RETURNING
          VALUE(ro_result) TYPE REF TO zclfi_autobanc_import_log.

    METHODS:
      "! Inicializa o objeto
      "! @parameter iv_subobject | Subobjeto da SLG1
      constructor
        IMPORTING
          !iv_subobject TYPE balsubobj,

      "! Inicializa o objeto de log SLG1 ZFI_VAN_FINNET
      init_log,

      "! Armazena novo log
      "! @parameter is_message          | Mensagem
      "! @parameter is_log_context      | Contexto do log
      insert_log
        IMPORTING
          is_message     TYPE bapiret2
          is_log_context TYPE zsfi_log_van_finnet OPTIONAL,

      "! Grava os logs no objeto SLG1 ZFI_VAN_FINNET
      save_log.


  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      "! Logs armazenados
      gt_log        TYPE TABLE OF ztfi_autbanc_log,
      "! Controlador do log
      gv_log_handle TYPE balloghndl,
      "! Subobjeto da SLG1
      gv_subobject  TYPE balsubobj.

ENDCLASS.



CLASS zclfi_autobanc_import_log IMPLEMENTATION.

  METHOD create_instance.

    ro_result = NEW zclfi_autobanc_import_log( iv_subobject ).

  ENDMETHOD.

  METHOD insert_log.

    CONSTANTS:
      lc_estrutura_context TYPE bal_s_msg-context-tabname VALUE 'ZSFI_LOG_VAN_FINNET',
      lc_probclass         TYPE bal_s_msg-probclass VALUE '1'.

    DATA: ls_msg        TYPE bal_s_msg,
          lt_log_handle TYPE bal_t_logh.

    DATA: ls_context TYPE zsFI_log_VAN_FINNET.

    ls_msg-msgty     = is_message-type.
    ls_msg-msgid     = is_message-id.
    ls_msg-msgno     = is_message-number.
    ls_msg-msgv1     = is_message-message_v1.
    ls_msg-msgv2     = is_message-message_v2.
    ls_msg-msgv3     = is_message-message_v3.
    ls_msg-msgv4     = is_message-message_v4.
    ls_msg-probclass = lc_probclass.


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

  ENDMETHOD.

  METHOD save_log.

    DATA: lt_log_handle TYPE bal_t_logh.

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

  METHOD constructor.

    me->gv_subobject = iv_subobject.
    me->init_log( ).

  ENDMETHOD.

  METHOD init_log.

    DATA: ls_log        TYPE bal_s_log.

    ls_log-aluser    = sy-uname.
    ls_log-alprog    = sy-repid.
    ls_log-object    = gc_object.
    ls_log-subobject = me->gv_subobject.

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

ENDCLASS.
