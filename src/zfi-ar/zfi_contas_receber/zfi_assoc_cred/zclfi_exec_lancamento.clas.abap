"!<p>Classe Executa Lançamento Desconto</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 15 de Março de 2022</p>
CLASS zclfi_exec_lancamento DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! Realizar Lançamento de Desconto
    "! @parameter iv_commit             | Executa Commit
    "! @parameter is_docheader          | Linha Cabeçalho
    "! @parameter it_accountgl          | Item CtaRazão
    "! @parameter it_accountreceivable  | Item do cliente
    "! @parameter it_accountpayable     | Item do fornecedor
    "! @parameter it_currencyamount     | Itens da moeda
    "! @parameter it_extension2         | ExtensionIn / ExtensionOut
    "! @parameter ev_type               | Operação de referência
    "! @parameter ev_key                | Chave referência
    "! @parameter ev_sys                | Sistema
    "! @parameter rt_return             | Parâmetro de retorno
    METHODS executar
      IMPORTING
        !iv_commit            TYPE flag
        !is_docheader         TYPE bapiache09
        !it_accountgl         TYPE bapiacgl09_tab OPTIONAL
        !it_accountreceivable TYPE bapiacar09_tab OPTIONAL
        !it_accountpayable    TYPE bapiacap09_tab OPTIONAL
        !it_currencyamount    TYPE bapiaccr09_tab OPTIONAL
        !it_extension2        TYPE bapiapoparex_tab OPTIONAL
      EXPORTING
        !ev_type              TYPE bapiache09-obj_type
        !ev_key               TYPE bapiache09-obj_key
        !ev_sys               TYPE bapiache09-obj_sys
      RETURNING
        VALUE(rt_return)      TYPE bapiret2_t .

    "! Realizar Lançamento FM NEW TASK
    "! @parameter is_docheader          | Linha Cabeçalho
    "! @parameter it_accountgl          | Item CtaRazão
    "! @parameter it_accountreceivable  | Item do cliente
    "! @parameter it_accountpayable     | Item do fornecedor
    "! @parameter it_currencyamount     | Itens da moeda
    "! @parameter it_extension2         | ExtensionIn / ExtensionOut
    "! @parameter ev_type               | Operação de referência
    "! @parameter ev_key                | Chave referência
    "! @parameter ev_sys                | Sistema
    "! @parameter rt_return             | Parâmetro de retorno
    METHODS executar_new_task
      IMPORTING
        !is_docheader         TYPE bapiache09
        !it_accountgl         TYPE bapiacgl09_tab OPTIONAL
        !it_accountreceivable TYPE bapiacar09_tab OPTIONAL
        !it_accountpayable    TYPE bapiacap09_tab OPTIONAL
        !it_currencyamount    TYPE bapiaccr09_tab OPTIONAL
        !it_extension2        TYPE bapiapoparex_tab OPTIONAL
      EXPORTING
        !ev_type              TYPE bapiache09-obj_type
        !ev_key               TYPE bapiache09-obj_key
        !ev_sys               TYPE bapiache09-obj_sys
      RETURNING
        VALUE(rt_return)      TYPE bapiret2_t .

    "! Verificar lançamento já efetuado
    "! @parameter iv_xblnr              | Nº documento de referência
    "! @parameter iv_bukrs              | Empresa
    "! @parameter iv_GJAHR              | Exercício
    "! @parameter iv_BLART              | Tipo de documento
    "! @parameter rv_return             | Retorno da verificação
    METHODS verificar_lancamento
      IMPORTING
        !iv_xblnr        TYPE xblnr1
        !iv_bukrs        TYPE bukrs
        !iv_gjahr        TYPE gjahr
        !iv_blart        TYPE blart
      RETURNING
        VALUE(rv_return) TYPE flag .

    "! Setup Messages
    "! @parameter p_task              | Task
   CLASS-METHODS setup_messages
      IMPORTING P_TASK   Type    CLIKE.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA:
      "!Armazenamento das mensagens de processamento
      gt_return               TYPE STANDARD TABLE OF bapiret2,

      "!Flag para sincronizar o processamento da função de criação de ordens de produção
      gv_wait_async           TYPE abap_bool,

      "!Tipo Documento Criado
      gv_type              TYPE bapiache09-obj_type,
      "!Chave Documento Criado
      gv_key               TYPE bapiache09-obj_key,
      "!Sistema Documento Criado
      gv_sys               TYPE bapiache09-obj_sys.
ENDCLASS.



CLASS zclfi_exec_lancamento IMPLEMENTATION.


  METHOD executar.

    DATA(lt_accountgl)          = it_accountgl[].
    DATA(lt_accountreceivable)  = it_accountreceivable[].
    DATA(lt_accountpayable)     = it_accountpayable[].
    DATA(lt_currencyamount)     = it_currencyamount[].
    DATA(lt_extension2)         = it_extension2[].

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader    = is_docheader
      IMPORTING
        obj_type          = ev_type
        obj_key           = ev_key
        obj_sys           = ev_sys
      TABLES
        accountgl         = lt_accountgl
        accountreceivable = lt_accountreceivable
        accountpayable    = lt_accountpayable
        currencyamount    = lt_currencyamount
        extension2        = lt_extension2
        return            = rt_return.

    IF iv_commit IS NOT INITIAL.
      IF line_exists( rt_return[ type = 'E' ] )."#EC CI_STDSEQ
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD executar_new_task.
    DATA(lt_accountgl)          = it_accountgl[].
    DATA(lt_accountreceivable)  = it_accountreceivable[].
    DATA(lt_accountpayable)     = it_accountpayable[].
    DATA(lt_currencyamount)     = it_currencyamount[].
    DATA(lt_extension2)         = it_extension2[].

* ---------------------------------------------------------------------------
* Chama evento para criação de documentos
* ---------------------------------------------------------------------------
    gv_wait_async = abap_false.

    CALL FUNCTION 'ZFMFI_EXEC_ACC_DOC_POST'
      STARTING NEW TASK 'EXEC_ACC_DOC_POST'
      CALLING setup_messages ON END OF TASK
      EXPORTING
        is_docheader           = is_docheader
        it_accountgl           = lt_accountgl[]
        it_accountreceivable   = lt_accountreceivable[]
        it_accountpayable      = lt_accountpayable[]
        it_currencyamount      = lt_currencyamount[]
        it_extension2          = lt_extension2[].

    WAIT UNTIL gv_wait_async = abap_true.

    ev_type     = gv_type.
    ev_key      = gv_key.
    ev_sys      = gv_sys.
    rt_return   = gt_return.


*    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*      EXPORTING
*        documentheader    = is_docheader
*      IMPORTING
*        obj_type          = ev_type
*        obj_key           = ev_key
*        obj_sys           = ev_sys
*      TABLES
*        accountgl         = lt_accountgl
*        accountreceivable = lt_accountreceivable
*        accountpayable    = lt_accountpayable
*        currencyamount    = lt_currencyamount
*        extension2        = lt_extension2
*        return            = rt_return.

  ENDMETHOD.

  METHOD setup_messages.

    CASE p_task.
      WHEN 'EXEC_ACC_DOC_POST'.
        RECEIVE RESULTS FROM FUNCTION 'ZFMFI_EXEC_ACC_DOC_POST'
            IMPORTING
                ev_type     = gv_type
                ev_key      = gv_key
                ev_sys      = gv_sys
                et_return   = gt_return.

      WHEN OTHERS.
    ENDCASE.

    gv_wait_async = abap_true.

  ENDMETHOD.
  METHOD verificar_lancamento.
    SELECT SINGLE belnr
      FROM bkpf
      INTO @DATA(lv_belnr)
    WHERE xblnr = @iv_xblnr
      AND bukrs = @iv_bukrs
      AND gjahr = @iv_gjahr
      AND blart = @iv_blart
      AND stblg = @space.
    IF sy-subrc EQ 0.
      rv_return = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
