"!<p>Classe Executa Lançamento Desconto</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 15 de Março de 2022</p>
CLASS zclfi_exec_lancamento_desconto DEFINITION
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
        !it_accountgl         TYPE bapiacgl09_tab   OPTIONAL
        !it_accountreceivable TYPE bapiacar09_tab   OPTIONAL
        !it_accountpayable    TYPE bapiacap09_tab   OPTIONAL
        !it_currencyamount    TYPE bapiaccr09_tab   OPTIONAL
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

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLFI_EXEC_LANCAMENTO_DESCONTO IMPLEMENTATION.


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
      IF line_exists( rt_return[ type = 'E' ] ).
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.
      ENDIF.
    ENDIF.

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
