"!<p><h2>Exceções da Automat. Bancária - Importação arquivos Van FINNET</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 18 de out de 2021</p>
CLASS zcxfi_autobanc_import DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    DATA:
      "! Variável de mensagem 1
      gv_msgv1   TYPE msgv1,
      "! Variável de mensagem 2
      gv_msgv2   TYPE msgv2,
      "! Variável de mensagem 3
      gv_msgv3   TYPE msgv3,
      "! Variável de mensagem 4
      gv_msgv4   TYPE msgv4,
      "! Tipo de mensagem
      gv_msgtype TYPE bapi_mtype.


    CONSTANTS:
      "! Msg: Erro genérico
      BEGIN OF gc_generic_error,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE 'GV_MSGV2',
        attr3 TYPE scx_attrname VALUE 'GV_MSGV3',
        attr4 TYPE scx_attrname VALUE 'GV_MSGV4',
      END OF gc_generic_error,

      "! Msg: Diretório de importação não encontrado
      BEGIN OF gc_import_directory_not_found,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_import_directory_not_found,

      "! Msg: Erro ao gravar o log
      BEGIN OF gc_log_save_erro,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_log_save_erro,

      "! Msg: Diretório vazio
      BEGIN OF gc_directory_empty,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE 'GV_MSGV2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_directory_empty,

      "! Msg: Erro durante a leitura do diretório
      BEGIN OF gc_read_directory_failed,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE 'GV_MSGV2',
        attr3 TYPE scx_attrname VALUE 'GV_MSGV3',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_read_directory_failed,

      "! Msg: Layout do arquivo não encontrado
      BEGIN OF gc_layout_bank_file_not_found,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_layout_bank_file_not_found,

      "! Msg: Erro ao iniciar o job
      BEGIN OF gc_job_start_erro,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_job_start_erro,

      "! Msg: Erro durante a importação na FF.5
      BEGIN OF gc_ff5_import_erro,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_ff5_import_erro,

      "! Msg: Arquivo já existe
      BEGIN OF gc_file_exist,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE 'GV_MSGV2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_file_exist,

      "! Msg: Nome de arquivo incorreto
      BEGIN OF gc_erro_name_file,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_erro_name_file,

      "! Msg: Erro de autorização
      BEGIN OF gc_auth_check_empresa,
        msgid TYPE symsgid VALUE 'ZFI_VAN_FINNET',
        msgno TYPE symsgno VALUE '013',
        attr1 TYPE scx_attrname VALUE 'GV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_auth_check_empresa.

    "! Inicializa objeto
    "! @parameter iv_textid   | Classe de mensagem
    "! @parameter iv_previous | Mensagem anterior
    "! @parameter iv_msgv1    | Variável de mensagem 1
    "! @parameter iv_msgv2    | Variável de mensagem 2
    "! @parameter iv_msgv3    | Variável de mensagem 3
    "! @parameter iv_msgv4    | Variável de mensagem 4
    "! @parameter iv_type     | Tipo da mensagem
    METHODS constructor
      IMPORTING
        !iv_textid   LIKE if_t100_message=>t100key OPTIONAL
        !iv_previous LIKE previous OPTIONAL
        !iv_msgv1    TYPE msgv1 OPTIONAL
        !iv_msgv2    TYPE msgv2 OPTIONAL
        !iv_msgv3    TYPE msgv3 OPTIONAL
        !iv_msgv4    TYPE msgv4 OPTIONAL
        !iv_type     TYPE bapi_mtype DEFAULT 'E'.

    "! Recupera mensagens de processamento
    "! @parameter rt_return | Mensagens de retorno
    METHODS get_bapin_return
      RETURNING
        VALUE(rt_return) TYPE bapiret2_t.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCXFI_AUTOBANC_IMPORT IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    CALL METHOD super->constructor
      EXPORTING
        previous = previous.

    me->gv_msgv1 = iv_msgv1.
    me->gv_msgv2 = iv_msgv2.
    me->gv_msgv3 = iv_msgv3.
    me->gv_msgv4 = iv_msgv4.
    me->gv_msgtype  = iv_type.

    CLEAR me->textid.
    IF iv_textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = iv_textid.
    ENDIF.

  ENDMETHOD.


  METHOD get_bapin_return.

    CONSTANTS:
      lc_msg(3) TYPE c VALUE 'MSG'.

    APPEND INITIAL LINE TO rt_return ASSIGNING FIELD-SYMBOL(<fs_message>).

    <fs_message>-type        = if_xo_const_message=>error.
    <fs_message>-id          = if_t100_message~t100key-msgid.
    <fs_message>-number      = if_t100_message~t100key-msgno.

    IF me->gv_msgv1 IS NOT INITIAL.
      <fs_message>-message_v1 = me->gv_msgv1.
    ELSE.

      <fs_message>-message_v1 = if_t100_message~t100key-attr1.

      IF <fs_message>-message_v1 CA lc_msg.
        CLEAR <fs_message>-message_v1.
      ENDIF.

    ENDIF.

    IF me->gv_msgv2 IS NOT INITIAL.
      <fs_message>-message_v2 = me->gv_msgv2.
    ELSE.

      <fs_message>-message_v2 = if_t100_message~t100key-attr2.

      IF <fs_message>-message_v2 CA lc_msg.
        CLEAR <fs_message>-message_v2.
      ENDIF.

    ENDIF.

    IF me->gv_msgv3 IS NOT INITIAL.
      <fs_message>-message_v3 = me->gv_msgv3.
    ELSE.

      <fs_message>-message_v3 = if_t100_message~t100key-attr3.

      IF <fs_message>-message_v3 CA lc_msg.
        CLEAR <fs_message>-message_v3.
      ENDIF.

    ENDIF.

    IF me->gv_msgv4 IS NOT INITIAL.
      <fs_message>-message_v4 = me->gv_msgv4.
    ELSE.

      <fs_message>-message_v4 = if_t100_message~t100key-attr4.

      IF <fs_message>-message_v4 CA lc_msg.
        CLEAR <fs_message>-message_v4.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
