class ZCLFI_PROC_ASSOC_CRED definition
  public
  inheriting from CL_ABAP_BEHV
  final
  create public .

public section.

  types:
    BEGIN OF ty_keys,
        empresa   TYPE ztfi_creditoscli-empresa,
        cliente   TYPE ztfi_creditoscli-cliente,
        raizid    TYPE ztfi_creditoscli-raizid,
        raizsn    TYPE ztfi_creditoscli-raizsn,
        documento TYPE ztfi_creditoscli-documento,
        ano       TYPE ztfi_creditoscli-ano,
        linha     TYPE ztfi_creditoscli-linha,
      END OF ty_keys .
  types:
    BEGIN OF ty_dados,
        bukrs TYPE bukrs,
        belnr TYPE belnr_d,
        gjahr TYPE gjahr,
        buzei TYPE buzei,
        bschl TYPE bschl,
        zlsch TYPE schzw_bseg,
        umskz TYPE umskz,
        kunnr TYPE kunnr,
        blart TYPE blart,
      END OF   ty_dados .
  types:
    BEGIN OF ty_fatura,
        bukrs   TYPE bukrs,
        belnr   TYPE belnr_d,
        gjahr   TYPE gjahr,
        buzei   TYPE buzei,
        kunnr   TYPE kunnr,
        zlsch   TYPE schzw_bseg,
        zfbdt   TYPE dzfbdt,
        zbd1t   TYPE dzbd1t,
        zbd2t   TYPE dzbd2t,
        zbd3t   TYPE dzbd3t,
        sgtxt   TYPE sgtxt,
        zuonr   TYPE dzuonr,
        gsber   TYPE gsber,
        bupla   TYPE bupla,
        prctr   TYPE prctr,
        segment TYPE fb_segment,
        hbkid   TYPE hbkid,
        xref1   TYPE xref1,
        xref2   TYPE xref2,
        anfbn   TYPE anfbn,
        wrbtr   TYPE wrbtr,
        bschl   TYPE bschl,
        netdt   TYPE netdt,
        xblnr   TYPE xblnr1,
        blart   TYPE blart,
        budat   TYPE budat,
        bktxt   TYPE bktxt,
        stcd1   TYPE stcd1,
        stcd2   TYPE stcd2,
      END OF   ty_fatura .
  types:
    BEGIN OF ty_bseg,
        bukrs   TYPE bukrs,
        belnr   TYPE belnr_d,
        gjahr   TYPE gjahr,
        buzei   TYPE buzei,
        kunnr   TYPE kunnr,
        zlsch   TYPE schzw_bseg,
        zfbdt   TYPE dzfbdt,
        zbd1t   TYPE dzbd1t,
        zbd2t   TYPE dzbd2t,
        zbd3t   TYPE dzbd3t,
        sgtxt   TYPE sgtxt,
        zuonr   TYPE dzuonr,
        gsber   TYPE gsber,
        kostl   TYPE kostl,
        bupla   TYPE bupla,
        prctr   TYPE prctr,
        segment TYPE fb_segment,
        hbkid   TYPE hbkid,
        xref1   TYPE xref1,
        xref2   TYPE xref2,
        wrbtr   TYPE wrbtr,
        bschl   TYPE bschl,
        netdt   TYPE netdt,
        xblnr   TYPE xblnr1,
        blart   TYPE blart,
        bktxt   TYPE bktxt,
        stcd1   TYPE stcd1,
        stcd2   TYPE stcd2,
        dtven   TYPE dats,
        resid   TYPE ze_residual,
      END OF   ty_bseg .
  types:
    ty_reported TYPE RESPONSE FOR REPORTED EARLY zi_fi_cockpit_associacao_cre .
  types TY_CREDITOS type ZI_FI_COCKPIT_CREDITOS_CLI .
  types:
    tt_creditos TYPE TABLE OF ty_creditos .
  types:
    tt_bseg     TYPE TABLE OF ty_bseg .

    "! Realiza todas as validações
    "! @parameter iv_parameter  | Parâmetro
    "! @parameter iv_processo   | Processo
    "! @parameter iv_BUKRS      | Empresa
    "! @parameter iv_BELNR      | Documento
    "! @parameter iv_GJAHR      | Exercício
    "! @parameter iv_BUZEI      | Linha
    "! @parameter et_return     | Mensagens de retorno
  methods VALIDACAO
    importing
      !IV_PARAMETER type STRING
      !IV_PROCESSO type STRING
      !IV_BUKRS type BUKRS
      !IV_BELNR type BELNR_D
      !IV_GJAHR type GJAHR
      !IV_BUZEI type BUZEI
      !IS_KEYS type TY_KEYS optional
    exporting
      !ET_RETURN type BAPIRET2_T .
    "! Formata as mensages de retorno
    "! @parameter ct_return | Mensagens de retorno
  methods FORMAT_MESSAGE
    importing
      !IV_CHANGE_ERROR_TYPE type FLAG optional
      !IV_CHANGE_WARNING_TYPE type FLAG optional
    changing
      !CT_RETURN type BAPIRET2_T .
    "! Constrói mensagens retorno do aplicativo
    "! @parameter it_return | Mensagens de retorno
    "! @parameter es_reported | Retorno do aplicativo
  methods BUILD_REPORTED
    importing
      !IT_RETURN type BAPIRET2_T
    exporting
      !ES_REPORTED type TY_REPORTED .
    "! Método Constructor
  methods CONSTRUCTOR .
    "! Realiza validação dos dados bancários
    "! @parameter iv_kunnr   | Cliente
    "! @parameter iv_belnr   | Documento
    "! @parameter et_return  | Mensagens de retorno
  methods VALIDA_DADOS_BANCARIOS
    importing
      !IV_BUKRS type BUKRS
      !IV_BELNR type BELNR_D
      !IV_GJAHR type GJAHR
      !IV_BUZEI type BUZEI
      !IV_KUNNR type KUNNR
    exporting
      !ET_RETURN type BAPIRET2_T .
    "! Realiza contabilização pagamento fornecedor
    "! @parameter it_creditos   | Tabela de créditos
    "! @parameter et_return  | Mensagens de retorno
  methods EXECUTA_LANC_PAGAMENTO_FORN
    importing
      !IT_CREDITOS type TT_CREDITOS
    exporting
      !ET_RETURN type BAPIRET2_T .
    "! Realiza contabilização Associacao Créditos
    "! @parameter it_creditos   | Tabela de créditos
    "! @parameter et_return  | Mensagens de retorno
  methods EXECUTA_LANC_ASSOCI_CRED
    importing
      !IT_CREDITOS type TT_CREDITOS
    exporting
      !ET_RETURN type BAPIRET2_T .
  PROTECTED SECTION.
private section.

  constants:
    BEGIN OF gc_param,
        modulo      TYPE ztca_param_par-modulo VALUE 'FI-AR',
        associacao  TYPE ztca_param_par-chave1 VALUE 'ASSOCIACAO',
        associacre  TYPE ztca_param_par-chave1 VALUE 'ASSOCIACREDITO',
        tp_doc_asso TYPE ztca_param_par-chave2 VALUE 'TIPODEDOCUMENTO',
        tp_doc_forn TYPE ztca_param_par-chave2 VALUE 'TIPODOCFORNECEDOR',
        cta_razao40 TYPE ztca_param_par-chave2 VALUE 'CONTARAZAO40',
        cta_razao50 TYPE ztca_param_par-chave2 VALUE 'CONTARAZAO50',
        tipodoc     TYPE ztca_param_par-chave3 VALUE 'TIPODOC',
      END OF gc_param .
  constants:
    BEGIN OF gc_associ,
        pdc       TYPE bschl VALUE '19',
        devolucao TYPE bschl VALUE '11',
      END OF gc_associ .
  data GV_BLART_PAG_FORN type BLART .
  data GV_BSCHL_PAG_FORN type BSCHL .
  data GV_BLART_DEVOL type BLART .
  data GV_BSCHL_DEVOL type BSCHL .
  data GV_BLART_ASSOCI type BLART .
  data GV_TP_DOC_ASSOCI type BLART .
  data GV_BSCHL_ASSOCI type BSCHL .
  data GV_UMSKZ_ASSOCI type UMSKZ .
  data GV_ZLSCH_ASSOCI type SCHZW_BSEG .
  data GV_ZLSCH_PAG_FORN_B type SCHZW_BSEG .
  data GV_ZLSCH_PAG_FORN_T type SCHZW_BSEG .
  data GV_BLART_LANC_31 type BLART .
  data GV_SAKNR40 type SAKNR .
  data GV_SAKNR50 type SAKNR .
  data GS_KEYS type TY_KEYS .

  methods GET_TEXT_HEADER
    importing
      !IS_CREDITOS type TY_CREDITOS
    returning
      value(RV_TEXT) type STRING .
  methods GET_DIA_UTIL
    changing
      !CV_DATE type DATUM .
    "! Realiza validação de Créditos
    "! @parameter iv_processo   | Processo
    "! @parameter is_dados      | Dados
    "! @parameter et_return     | Mensagens de retorno
  methods VALIDACAO_CREDITOS
    importing
      !IV_PROCESSO type STRING
      !IS_DADOS type TY_DADOS
    exporting
      !ET_RETURN type BAPIRET2_T .
    "! Realiza validação de Fatura
    "! @parameter is_dados      | Dados
    "! @parameter et_return     | Mensagens de retorno
  methods VALIDACAO_FATURA
    importing
      !IS_DADOS type TY_DADOS
    exporting
      !ET_RETURN type BAPIRET2_T .
    "! Realiza validação do processo de associacao
    "! @parameter is_dados      | Dados
    "! @parameter et_return     | Mensagens de retorno
  methods VALIDACAO_ASSOCIACAO
    importing
      !IS_DADOS type TY_DADOS
    exporting
      !ET_RETURN type BAPIRET2_T .
    "! Realiza validação do processo de pagamento ao fornecedor
    "! @parameter is_dados      | Dados
    "! @parameter et_return     | Mensagens de retorno
  methods VALIDACAO_PGFORNECEDOR
    importing
      !IS_DADOS type TY_DADOS
    exporting
      !ET_RETURN type BAPIRET2_T .
    "! Seleciona dados
    "! @parameter iv_BUKRS      | Empresa
    "! @parameter iv_BELNR      | Documento
    "! @parameter iv_GJAHR      | Exercício
    "! @parameter iv_BUZEI      | Linha
    "! @parameter es_dados      | Dados de Retorno da seleção
  methods SELECIONA_DADOS
    importing
      !IV_BUKRS type BUKRS
      !IV_BELNR type BELNR_D
      !IV_GJAHR type GJAHR
      !IV_BUZEI type BUZEI
    exporting
      !ES_DADOS type TY_DADOS .
  methods GRAVA_LOG_DADOS_BANCARIOS
    importing
      !IV_BUKRS type BUKRS
      !IV_BELNR type BELNR_D
      !IV_GJAHR type GJAHR
      !IV_BUZEI type BUZEI .
  methods GET_DATA_HEADER
    importing
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
    exporting
      !ES_DOCHEADER type BAPIACHE09 .
  methods SELECT_DADOS_DOCUMENTOS
    importing
      !IT_CREDITOS type TT_CREDITOS
    exporting
      !ET_DOCUMENTOS type TT_BSEG .
  methods SELECT_DADOS_DOC_ASSO_CRED
    importing
      !IT_CREDITOS type TT_CREDITOS
    exporting
      !ES_FATURA type TY_FATURA
      !ET_DOCUMENTOS type TT_BSEG .
  methods ADD_DATA_ACCOUNTGL
    importing
      !IV_ITEM_NO type POSNR_ACC
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
      !IS_DOCUMENTO type TY_BSEG
    exporting
      !ET_ACCOUNTGL type BAPIACGL09_TAB .
  methods ADD_DATA_ACCOUNTRECEIVABLE
    importing
      !IV_ITEM_NO type POSNR_ACC
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
      !IS_DOCUMENTO type TY_BSEG
    exporting
      !ET_ACCOUNTRECEIVABLE type BAPIACAR09_TAB .
  methods ADD_DATA_ACCOUNTPAYABLE
    importing
      !IV_ITEM_NO type POSNR_ACC
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
      !IS_DOCUMENTO type TY_BSEG
    exporting
      !ET_ACCOUNTPAYABLE type BAPIACAP09_TAB .
  methods ADD_DATA_CURRENCYAMOUNT
    importing
      !IV_ITEM_NO type POSNR_ACC
      !IV_SHKZG type SHKZG
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
    changing
      !CT_CURRENCYAMOUNT type BAPIACCR09_TAB .
  methods ADD_DATA_EXTENSION2
    importing
      !IV_ITEM_NO type POSNR_ACC
      !IS_FATURA type TY_FATURA
      !IS_DOCUMENTO type TY_BSEG
    changing
      !CT_EXTENSION2 type BAPIAPOPAREX_TAB .
  methods GRAVA_LOG_PAG_FORNECEDOR
    importing
      !IV_KEY type BAPIACHE09-OBJ_KEY
      !IS_CREDITOS type TY_CREDITOS
      !IS_DOCUMENTO type TY_BSEG .
  methods PREENCHE_DADOS_PAG_FOR
    importing
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
      !IS_DOCUMENTO type TY_BSEG
    exporting
      !ES_DOCHEADER type BAPIACHE09
      !ET_ACCOUNTRECEIVABLE type BAPIACAR09_TAB
      !ET_ACCOUNTPAYABLE type BAPIACAP09_TAB
      !ET_CURRENCYAMOUNT type BAPIACCR09_TAB
      !ET_EXTENSION2 type BAPIAPOPAREX_TAB .
  methods PREENCHE_DADOS_PDC
    importing
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
      !IS_DOCUMENTO type TY_BSEG
    exporting
      !ES_DOCHEADER type BAPIACHE09
      !ET_ACCOUNTRECEIVABLE type BAPIACAR09_TAB
      !ET_ACCOUNTGL type BAPIACGL09_TAB
      !ET_CURRENCYAMOUNT type BAPIACCR09_TAB
      !ET_EXTENSION2 type BAPIAPOPAREX_TAB .
  methods PREENCHE_DADOS_PDC_RESIDUAL
    importing
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
      !IS_DOCUMENTO type TY_BSEG
    exporting
      !ES_DOCHEADER type BAPIACHE09
      !ET_ACCOUNTRECEIVABLE type BAPIACAR09_TAB
      !ET_ACCOUNTGL type BAPIACGL09_TAB
      !ET_CURRENCYAMOUNT type BAPIACCR09_TAB
      !ET_EXTENSION2 type BAPIAPOPAREX_TAB .
  methods PREENCHE_DADOS_DEVO
    importing
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
      !IS_DOCUMENTO type TY_BSEG
    exporting
      !ES_DOCHEADER type BAPIACHE09
      !ET_ACCOUNTRECEIVABLE type BAPIACAR09_TAB
      !ET_ACCOUNTGL type BAPIACGL09_TAB
      !ET_CURRENCYAMOUNT type BAPIACCR09_TAB
      !ET_EXTENSION2 type BAPIAPOPAREX_TAB .
  methods PREENCHE_DADOS_DEVO_RESI
    importing
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA
      !IS_DOCUMENTO type TY_BSEG
    exporting
      !ES_DOCHEADER type BAPIACHE09
      !ET_ACCOUNTRECEIVABLE type BAPIACAR09_TAB
      !ET_ACCOUNTGL type BAPIACGL09_TAB
      !ET_CURRENCYAMOUNT type BAPIACCR09_TAB
      !ET_EXTENSION2 type BAPIAPOPAREX_TAB .
  methods COMMIT .
  methods EXE_FB1D_DOC_CHANGE
    importing
      !IV_TIPO type CHAR1
      !IS_CREDITOS type TY_CREDITOS
      !IS_FATURA type TY_FATURA optional .
  methods EXE_FB1D
    importing
      !IS_FATURA type TY_FATURA
    exporting
      !ET_RETURN type BAPIRET2_T .
  methods GRAVA_LOG_ASSOCI_CREDITO
    importing
      !IV_KEY type BAPIACHE09-OBJ_KEY
      !IS_CREDITOS type TY_CREDITOS
      !IS_DOCUMENTO type TY_BSEG
      !IS_FATURA type TY_FATURA .
  methods ROLLBACK .
ENDCLASS.



CLASS ZCLFI_PROC_ASSOC_CRED IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).

    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.
        lo_param->m_get_single( EXPORTING iv_modulo = gc_param-modulo
                                         iv_chave1 = gc_param-associacao
                                         iv_chave2 = gc_param-tp_doc_asso
                                IMPORTING ev_param = gv_tp_doc_associ ).

      CATCH zcxca_tabela_parametros INTO DATA(lo_cx).
        WRITE lo_cx->get_text( ).
    ENDTRY.

    TRY.
        lo_param->m_get_single( EXPORTING iv_modulo = gc_param-modulo
                                         iv_chave1 = gc_param-associacre
                                         iv_chave2 = gc_param-tp_doc_forn
                                IMPORTING ev_param = gv_blart_lanc_31 ).

      CATCH zcxca_tabela_parametros INTO lo_cx.
        WRITE lo_cx->get_text( ).
    ENDTRY.

    TRY.
        lo_param->m_get_single( EXPORTING iv_modulo = gc_param-modulo
                                          iv_chave1 = gc_param-associacre
                                          iv_chave2 = gc_param-cta_razao40
                                IMPORTING ev_param = gv_saknr40 ).

      CATCH zcxca_tabela_parametros INTO lo_cx.
        WRITE lo_cx->get_text( ).
    ENDTRY.

    TRY.
        lo_param->m_get_single( EXPORTING iv_modulo = gc_param-modulo
                                          iv_chave1 = gc_param-associacre
                                          iv_chave2 = gc_param-cta_razao50
                                IMPORTING ev_param = gv_saknr50 ).

      CATCH zcxca_tabela_parametros INTO lo_cx.
        WRITE lo_cx->get_text( ).
    ENDTRY.

    me->gv_blart_devol    = 'RV'.
    me->gv_bschl_devol    = '11'.
    me->gv_blart_associ   = 'DD'.
    me->gv_bschl_associ   = '19'.
    me->gv_umskz_associ   = 'C'.
    me->gv_zlsch_associ   = '8'.
    me->gv_blart_pag_forn = 'RV'.
    me->gv_bschl_pag_forn = '11'.
    me->gv_zlsch_pag_forn_b = 'B'.
    me->gv_zlsch_pag_forn_t = 'T'.

  ENDMETHOD.


  METHOD validacao.

    FREE: et_return.

    gs_keys = is_keys.

    me->seleciona_dados( EXPORTING iv_bukrs     = iv_bukrs
                                   iv_belnr     = iv_belnr
                                   iv_gjahr     = iv_gjahr
                                   iv_buzei     = iv_buzei
                         IMPORTING es_dados     = DATA(ls_dados) ).

* ---------------------------------------------------------------------------
*  Validação Créditos
* ---------------------------------------------------------------------------
    IF iv_parameter = gc_cds-credito.
      me->validacao_creditos( EXPORTING iv_processo  = iv_processo
                                        is_dados     = ls_dados
                              IMPORTING et_return = et_return ).
    ELSE.
* ---------------------------------------------------------------------------
*  Validação Fatura
* ---------------------------------------------------------------------------
      me->validacao_fatura( EXPORTING is_dados     = ls_dados
                            IMPORTING et_return = et_return ).
    ENDIF.

  ENDMETHOD.


  METHOD validacao_creditos.
* ---------------------------------------------------------------------------
*  Validação Associação de Créditos
* ---------------------------------------------------------------------------
    IF iv_processo = gc_proc-associacao_credito.
      me->validacao_associacao( EXPORTING is_dados  = is_dados
                                IMPORTING et_return = et_return ).
    ELSE.
* ---------------------------------------------------------------------------
*  Validação Pagamento Fornecedor
* ---------------------------------------------------------------------------
      me->validacao_pgfornecedor( EXPORTING is_dados  = is_dados
                                  IMPORTING et_return = et_return ).
    ENDIF.

  ENDMETHOD.


  METHOD seleciona_dados.

    CLEAR: es_dados.

    SELECT SINGLE a~bukrs
                  a~belnr
                  a~gjahr
                  a~buzei
                  a~bschl
                  a~zlsch
                  a~umskz
                  a~kunnr
                  b~blart
    FROM bseg AS a
    INNER JOIN bkpf AS b
    ON b~bukrs = a~bukrs AND
       b~belnr = a~belnr AND
       b~gjahr = a~gjahr
    INTO es_dados
    WHERE a~bukrs = iv_bukrs
      AND a~belnr = iv_belnr
      AND a~gjahr = iv_gjahr
      AND a~buzei = iv_buzei."#EC CI_SEL_NESTED

  ENDMETHOD.


  METHOD validacao_fatura.

    IF gs_keys-raizsn IS NOT INITIAL.

      SELECT empresa,
             documento,
             ano,
             linha,
             cliente,
             montante
        FROM ztfi_faturacli
        INTO TABLE @DATA(lt_fatura_cli)
       WHERE empresa = @gs_keys-empresa
         AND cliente = @gs_keys-cliente
         AND raizid  = @gs_keys-raizid
         AND raizsn  = @gs_keys-raizsn
         AND marcado = @abap_true.                   "#EC CI_SEL_NESTED

    ELSE.

      "Selecionar linhas da fatura selecionada
      SELECT empresa,
             documento,
             ano,
             linha,
             cliente,
             montante
        FROM ztfi_faturacli
        "INTO TABLE @DATA(lt_fatura_cli1)
        INTO TABLE @lt_fatura_cli
       WHERE empresa = @is_dados-bukrs
         AND cliente = @is_dados-kunnr
         AND marcado = @abap_true.                   "#EC CI_SEL_NESTED

    ENDIF.

    IF sy-dbcnt > 1.
      "Selecionar apenas uma fatura!
      et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                              field = 'DOCUMENTO'
                                              type = 'E'
                                              id = 'ZFI_ASSOCI_CRE'
                                              number = '006'
                                              message_v1 = is_dados-belnr
                                              message_v2 = is_dados-blart ) ).
    ELSEIF sy-subrc <> 0.
      "Selecionar uma fatura!
      et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                              field = 'DOCUMENTO'
                                              type = 'E'
                                              id = 'ZFI_ASSOCI_CRE'
                                              number = '007'
                                              message_v1 = is_dados-belnr
                                              message_v2 = is_dados-blart ) ).

    ENDIF.

    IF lt_fatura_cli[] IS NOT INITIAL.

      SELECT SUM( dmbtr )
      FROM bsid_view AS vw_data
      JOIN @lt_fatura_cli AS fat ON (  vw_data~bukrs = fat~empresa AND
                                        vw_data~rebzg = fat~documento AND
                                        vw_data~rebzj = fat~ano AND
                                        vw_data~rebzz = fat~linha )
      INTO @DATA(lv_utilizado).

      IF sy-subrc = 0 AND lv_utilizado <> 0.

        READ TABLE lt_fatura_cli INDEX 1 INTO DATA(ls_fatura).

        SELECT SUM( Montante )
        FROM zi_fi_creditos_cli_cdcli
        WHERE Empresa = @is_dados-bukrs
        AND Documento = @is_dados-belnr
        AND Ano = @is_dados-gjahr
        AND Linha = @is_dados-buzei
        INTO @DATA(lv_credito).

        DATA(lv_restante) = ( ls_fatura-montante - lv_utilizado ).

        IF lv_restante < lv_credito.

          et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                                  field = 'DOCUMENTO'
                                                  type = 'E'
                                                  id = 'ZFI_ASSOCI_CRE'
                                                  number = '021'
                                                  message_v1 = ls_fatura-documento
                                                  message_v2 = ls_fatura-empresa
                                                  message_v3 = ls_fatura-ano ) ).
        ENDIF.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD validacao_associacao.

    me->validacao_fatura( EXPORTING is_dados  = is_dados
                          IMPORTING et_return = et_return ).

* ---------------------------------------------------------------------------
* Validação de campos
* ---------------------------------------------------------------------------
    IF is_dados-bschl = gc_associ-pdc.
      IF is_dados-blart <> gv_blart_associ.
        "Doc: &1 Tipo Doc. Associação deve ser &2.
        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                                field = 'BLART'
                                                type = 'E'
                                                id = 'ZFI_ASSOCI_CRE'
                                                number = '008'
                                                message_v1 = is_dados-belnr
                                                message_v2 = gv_blart_associ ) ).
      ENDIF.

      IF is_dados-bschl <> gv_bschl_associ.
        "Doc: &1 Chav Lan. Associação deve ser &2.
        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                                field = 'BLART'
                                                type = 'E'
                                                id = 'ZFI_ASSOCI_CRE'
                                                number = '009'
                                                message_v1 = is_dados-belnr
                                                message_v2 = gv_bschl_pag_forn ) ).
      ENDIF.

*      IF is_dados-umskz <> gv_umskz_associ.
*        "Doc: &1 Cod. Razão Esp. Associação deve ser &2.
*        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
*                                                field = 'BLART'
*                                                type = 'E'
*                                                id = 'ZFI_ASSOCI_CRE'
*                                                number = '011'
*                                                message_v1 = is_dados-belnr
*                                                message_v2 = gv_umskz_associ ) ).
*      ENDIF.

      IF is_dados-zlsch <> gv_zlsch_associ.
        "Doc: &1 Form Pag.Associação deve ser &2.
        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                                field = 'BLART'
                                                type = 'E'
                                                id = 'ZFI_ASSOCI_CRE'
                                                number = '010'
                                                message_v1 = is_dados-belnr
                                                message_v2 = gv_zlsch_associ ) ).
      ENDIF.
    ELSEIF is_dados-bschl = gc_associ-devolucao.
*      IF is_dados-blart <> gv_blart_devol.
*        "Doc: &1 Tipo Doc. Associação deve ser &2.
*        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
*                                                field = 'BLART'
*                                                type = 'E'
*                                                id = 'ZFI_ASSOCI_CRE'
*                                                number = '008'
*                                                message_v1 = is_dados-belnr
*                                                message_v2 = gv_blart_associ ) ).
*      ENDIF.

      IF is_dados-bschl <> gv_bschl_devol.
        "Doc: &1 Chav Lan. Associação deve ser &2.
        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                                field = 'BLART'
                                                type = 'E'
                                                id = 'ZFI_ASSOCI_CRE'
                                                number = '009'
                                                message_v1 = is_dados-belnr
                                                message_v2 = gv_bschl_pag_forn ) ).
      ENDIF.

*      IF is_dados-zlsch <> gv_umskz_associ.
*        "Doc: &1 Cod. Razão Esp. Associação deve ser &2.
*        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
*                                                field = 'BLART'
*                                                type = 'E'
*                                                id = 'ZFI_ASSOCI_CRE'
*                                                number = '011'
*                                                message_v1 = is_dados-belnr
*                                                message_v2 = gv_umskz_associ ) ).
*      ENDIF.

      IF is_dados-zlsch <> gv_zlsch_associ.
        "Doc: &1 Form Pag.Associação deve ser &2.
        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                                field = 'BLART'
                                                type = 'E'
                                                id = 'ZFI_ASSOCI_CRE'
                                                number = '010'
                                                message_v1 = is_dados-belnr
                                                message_v2 = gv_zlsch_associ ) ).
      ENDIF.
    ENDIF.

    me->format_message( CHANGING ct_return = et_return[] ).

  ENDMETHOD.


  METHOD validacao_pgfornecedor.
* ---------------------------------------------------------------------------
* Validação de campos
* ---------------------------------------------------------------------------
*    IF is_dados-blart <> gv_blart_pag_forn.
*      "Doc: &1 Tipo Doc. pagamento fornecedor deve ser &2.
*      et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
*                                              field = 'BLART'
*                                              type = 'E'
*                                              id = 'ZFI_ASSOCI_CRE'
*                                              number = '001'
*                                              message_v1 = is_dados-belnr
*                                              message_v2 = gv_blart_pag_forn ) ).
*    ENDIF.

    IF is_dados-bschl <> gv_bschl_pag_forn.
      "Doc: &1 Chav Lan. pagamento fornecedor deve ser &2.
      et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                              field = 'BLART'
                                              type = 'E'
                                              id = 'ZFI_ASSOCI_CRE'
                                              number = '002'
                                              message_v1 = is_dados-belnr
                                              message_v2 = gv_bschl_pag_forn ) ).
    ENDIF.

    IF is_dados-zlsch <> gv_zlsch_pag_forn_b AND
       is_dados-zlsch <> gv_zlsch_pag_forn_t.
      "Doc: &1 Form Pag. pagamento for. deve ser &2 ou &3.
      et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                              field = 'BLART'
                                              type = 'E'
                                              id = 'ZFI_ASSOCI_CRE'
                                              number = '003'
                                              message_v1 = is_dados-belnr
                                              message_v2 = gv_zlsch_pag_forn_b
                                              message_v3 = gv_zlsch_pag_forn_t ) ).
    ENDIF.

    me->format_message( CHANGING ct_return = et_return[] ).

  ENDMETHOD.


  METHOD build_reported.

    DATA: lo_dataref            TYPE REF TO data,
          ls_mdf                TYPE zi_tm_mdf,
          ls_carregamento       TYPE zi_tm_mdf_carregamento,
          ls_descarregamento    TYPE zi_tm_mdf_descarregamento,
          ls_complemento        TYPE zi_tm_mdf_complemento,
          ls_emitente           TYPE zi_tm_mdf_emitente,
          ls_historico          TYPE zi_tm_mdf_historico,
          ls_motorista          TYPE zi_tm_mdf_motorista,
          ls_municipio          TYPE zi_tm_mdf_municipio,
          ls_percurso_doc       TYPE zi_tm_mdf_percurso_doc,
          ls_placa              TYPE zi_tm_mdf_placa,
          ls_placa_condutor     TYPE zi_tm_mdf_placa_condutor,
          ls_placa_vale_pedagio TYPE zi_tm_mdf_placa_vale_pedagio.

    FIELD-SYMBOLS: <fs_cds>  TYPE any.

    FREE: es_reported.

    LOOP AT it_return INTO DATA(ls_return).

* ---------------------------------------------------------------------------
* Determina tipo de estrutura CDS
* ---------------------------------------------------------------------------
      CASE ls_return-parameter.
        WHEN gc_cds-credito.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-creditos.
        WHEN gc_cds-fatura.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-fatura.
        WHEN OTHERS.
          CREATE DATA lo_dataref TYPE LINE OF ty_reported-associ.
      ENDCASE.

      ASSIGN lo_dataref->* TO <fs_cds>.

* ---------------------------------------------------------------------------
* Converte mensagem
* ---------------------------------------------------------------------------
      ASSIGN COMPONENT '%msg' OF STRUCTURE <fs_cds> TO FIELD-SYMBOL(<fs_msg>).

      IF sy-subrc EQ 0.
        TRY.
            <fs_msg>  = new_message( id       = ls_return-id
                                     number   = ls_return-number
                                     v1       = ls_return-message_v1
                                     v2       = ls_return-message_v2
                                     v3       = ls_return-message_v3
                                     v4       = ls_return-message_v4
                                     severity = CONV #( ls_return-type ) ).
          CATCH cx_root.
        ENDTRY.
      ENDIF.

* ---------------------------------------------------------------------------
* Marca o campo com erro
* ---------------------------------------------------------------------------
      IF ls_return-field IS NOT INITIAL.
        ASSIGN COMPONENT |%element-{ ls_return-field }| OF STRUCTURE <fs_cds> TO FIELD-SYMBOL(<fs_field>).

        IF sy-subrc EQ 0.
          TRY.
              <fs_field> = if_abap_behv=>mk-on.
            CATCH cx_root.
          ENDTRY.
        ENDIF.
      ENDIF.

* ---------------------------------------------------------------------------
* Adiciona o erro na CDS correspondente
* ---------------------------------------------------------------------------
      CASE ls_return-parameter.
        WHEN gc_cds-credito.
          es_reported-creditos[]        = VALUE #( BASE es_reported-creditos[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN gc_cds-fatura.
          es_reported-fatura[]          = VALUE #( BASE es_reported-fatura[] ( CORRESPONDING #( <fs_cds> ) ) ).
        WHEN OTHERS.
          es_reported-associ[]             = VALUE #( BASE es_reported-associ[] ( CORRESPONDING #( <fs_cds> ) ) ).
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD format_message.

    DATA: ls_return_format TYPE bapiret2.

* ---------------------------------------------------------------------------
* Format mensagens de retorno
* ---------------------------------------------------------------------------
    LOOP AT ct_return REFERENCE INTO DATA(ls_return).

      " ---------------------------------------------------------------------------
      " Ao processar a Action com múltiplas linhas, quando há qualquer mensagem de
      " erro ele acaba ocultando as outras mensagens de Sucesso, Informação e
      " Aviso. Esta alternativa foi encontrada para exibir todas as mensagens
      " ---------------------------------------------------------------------------
      ls_return->type = COND #( WHEN ls_return->type EQ 'E' AND iv_change_error_type IS NOT INITIAL
                                THEN 'I'
                                WHEN ls_return->type EQ 'W' AND iv_change_warning_type IS NOT INITIAL
                                THEN 'I'
                                ELSE ls_return->type ).

      IF  ls_return->message IS INITIAL.

        TRY.
            CALL FUNCTION 'FORMAT_MESSAGE'
              EXPORTING
                id        = ls_return->id
                lang      = sy-langu
                no        = ls_return->number
                v1        = ls_return->message_v1
                v2        = ls_return->message_v2
                v3        = ls_return->message_v3
                v4        = ls_return->message_v4
              IMPORTING
                msg       = ls_return->message
              EXCEPTIONS
                not_found = 1
                OTHERS    = 2.

            IF sy-subrc <> 0.
              CLEAR ls_return->message.
            ENDIF.

          CATCH cx_root INTO DATA(lo_root).
            DATA(lv_message) = lo_root->get_longtext( ).
        ENDTRY.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD valida_dados_bancarios.

    SELECT SINGLE lifnr
      FROM lfbk
      INTO @DATA(ls_lfbk)
    WHERE lifnr = @iv_kunnr."#EC CI_SEL_NESTED

    IF sy-subrc <> 0.
      grava_log_dados_bancarios( iv_bukrs = iv_bukrs
                                 iv_belnr = iv_belnr
                                 iv_gjahr = iv_gjahr
                                 iv_buzei = iv_buzei ).

      "Doc: &1 Fornecedor &2 não possui dados bancários cadastrados.
      et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                              field = 'LIFNR'
                                              type = 'E'
                                              id = 'ZFI_ASSOCI_CRE'
                                              number = '005'
                                              message_v1 = iv_belnr
                                              message_v2 = iv_kunnr ) ).
    ENDIF.

  ENDMETHOD.


  METHOD grava_log_dados_bancarios.
    DATA: ls_logtab    TYPE ztfi_logconcred,
          ls_documento TYPE ty_bseg.

    SELECT SINGLE
            a~bukrs
            a~belnr
            a~gjahr
            a~buzei
            a~kunnr
            a~zlsch
            a~zfbdt
            a~zbd1t
            a~zbd2t
            a~zbd3t
            a~sgtxt
            a~zuonr
            a~gsber
            a~kostl
            a~bupla
            a~prctr
            a~segment
            a~hbkid
            a~xref1
            a~xref2
            a~wrbtr
            a~bschl
            a~netdt
            c~xblnr
            c~blart
            c~bktxt
            b~stcd1
            b~stcd2
      FROM  bseg AS a
      INNER JOIN kna1 AS b
      ON b~kunnr = a~kunnr
      INNER JOIN bkpf AS c
      ON c~bukrs = a~bukrs     AND
         c~belnr = a~belnr     AND
         c~gjahr = a~gjahr
      INTO ls_documento
      WHERE a~bukrs = iv_bukrs
        AND a~belnr = iv_belnr
        AND a~gjahr = iv_gjahr
        AND a~buzei = iv_buzei."#EC CI_SEL_NESTED

    ls_logtab-bukrs = ls_documento-bukrs.
    ls_logtab-kunnr = ls_documento-kunnr.
    ls_logtab-stcd1 = ls_documento-stcd1.
    ls_logtab-stcd2 = ls_documento-stcd2.

    ls_logtab-zcredito          =  ls_documento-belnr   .
    ls_logtab-zitemcredito      =  ls_documento-buzei   .
    ls_logtab-zexerciciocredito =  ls_documento-gjahr   .
    ls_logtab-zwrbtr            =  ls_documento-wrbtr   .
    ls_logtab-zbschl            =  ls_documento-bschl   .
    ls_logtab-znetdt            =  ls_documento-dtven   .
    ls_logtab-zzlsch            =  ls_documento-zlsch   .
    ls_logtab-zzuonr            =  ls_documento-zuonr   .
    ls_logtab-zxblnr            =  ls_documento-xblnr   .
    ls_logtab-zblart            =  ls_documento-blart   .
    ls_logtab-zxref1_hd         =  ls_documento-xref1.
    ls_logtab-zxref2_hd         =  ls_documento-xref2.

    ls_logtab-zdoccon           = ls_documento-belnr.
    ls_logtab-zexerciciodoccon  = ls_documento-gjahr.

    ls_logtab-zdadosfor = 'NÃO'.

    ls_logtab-zdata = sy-datum.
    ls_logtab-zhora = sy-uzeit.
    ls_logtab-bname = sy-uname.

    MODIFY ztfi_logconcred FROM ls_logtab."#EC CI_IMUD_NESTED
    CLEAR ls_logtab.

  ENDMETHOD.


  METHOD executa_lanc_pagamento_forn.
    DATA: ls_docheader TYPE bapiache09,
          ls_fatura    TYPE ty_fatura.

    DATA: lt_accountgl         TYPE bapiacgl09_tab,
          lt_accountreceivable TYPE bapiacar09_tab,
          lt_accountpayable    TYPE bapiacap09_tab,
          lt_currencyamount    TYPE bapiaccr09_tab,
          lt_extension2        TYPE bapiapoparex_tab,
          lt_return            TYPE bapiret2_t.

    me->select_dados_documentos( EXPORTING it_creditos   = it_creditos
                                 IMPORTING et_documentos = DATA(lt_documentos) ).

    LOOP AT it_creditos ASSIGNING FIELD-SYMBOL(<fs_creditos>).
      READ TABLE lt_documentos
        ASSIGNING FIELD-SYMBOL(<fs_documentos>)
        WITH KEY bukrs = <fs_creditos>-empresa
                 belnr = <fs_creditos>-documento
                 gjahr = <fs_creditos>-ano
                 buzei = <fs_creditos>-linha
        BINARY SEARCH.

      me->preenche_dados_pag_for( EXPORTING is_creditos  = <fs_creditos>
                                            is_fatura    = ls_fatura
                                            is_documento = <fs_documentos>
                                  IMPORTING es_docheader = ls_docheader
                                            et_accountreceivable = lt_accountreceivable
                                            et_accountpayable    = lt_accountpayable
                                            et_currencyamount    = lt_currencyamount
                                            et_extension2        = lt_extension2 ) .

      NEW zclfi_exec_lancamento( )->executar_new_task(
           EXPORTING
             is_docheader         = ls_docheader
             it_accountgl         = lt_accountgl
             it_accountreceivable = lt_accountreceivable
             it_accountpayable    = lt_accountpayable
             it_extension2        = lt_extension2
             it_currencyamount    = lt_currencyamount
           IMPORTING
             ev_type           = DATA(lv_type)
             ev_key            = DATA(lv_key)
             ev_sys            = DATA(lv_sys)
           RECEIVING
             rt_return         = lt_return
         ).

      IF NOT line_exists( lt_return[ type = 'E' ] )."#EC CI_STDSEQ
        exe_fb1d_doc_change( iv_tipo     = 'P'
                             is_creditos = <fs_creditos> ).

        "Doc. &1 Empresa &2 Exercício &3 contabilizado com sucesso!
        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                                field = 'BELNR'
                                                type = 'S'
                                                id = 'ZFI_ASSOCI_CRE'
                                                number = '016'
                                                message_v1 = lv_key(10)
                                                message_v2 = lv_key+10(4)
                                                message_v3 = lv_key+14(4) ) ).

        grava_log_pag_fornecedor( EXPORTING iv_key       = lv_key
                                            is_creditos  = <fs_creditos>
                                            is_documento = <fs_documentos> ).
      ELSE.
        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                                        field = 'BELNR'
                                                        type = 'I'
                                                        id = 'ZFI_ASSOCI_CRE'
                                                        number = '018' ) ).

        APPEND LINES OF lt_return TO et_return.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_data_header.

    es_docheader-doc_date     = sy-datum.
    es_docheader-username     = sy-uname.
    es_docheader-fisc_year    = es_docheader-pstng_date(4).
    es_docheader-fis_period   = es_docheader-pstng_date+4(2).
    es_docheader-comp_code    = is_creditos-empresa .
    es_docheader-ref_doc_no   = is_creditos-documento.
    es_docheader-header_txt   = is_creditos-documento.

    IF is_fatura IS INITIAL.
      es_docheader-doc_type     = gv_blart_lanc_31.
    ELSE.
      es_docheader-doc_type     = gv_tp_doc_associ.
    ENDIF.

  ENDMETHOD.


  METHOD select_dados_documentos.
    DATA: lt_documentos TYPE tt_bseg.

    DATA(lt_creditos) = it_creditos[].

    SORT lt_creditos BY empresa documento ano linha.

    IF it_creditos[] IS NOT INITIAL.
      SELECT  a~bukrs
              a~belnr
              a~gjahr
              a~buzei
              a~kunnr
              a~zlsch
              a~zfbdt
              a~zbd1t
              a~zbd2t
              a~zbd3t
              a~sgtxt
              a~zuonr
              a~gsber
              a~kostl
              a~bupla
              a~prctr
              a~segment
              a~hbkid
              a~xref1
              a~xref2
              a~wrbtr
              a~bschl
              a~netdt
              c~xblnr
              c~blart
              c~bktxt
              b~stcd1
              b~stcd2
        FROM  bseg AS a
        INNER JOIN kna1 AS b
        ON b~kunnr = a~kunnr
        INNER JOIN bkpf AS c
        ON c~bukrs = a~bukrs     AND
           c~belnr = a~belnr     AND
           c~gjahr = a~gjahr
        INTO TABLE et_documentos
        FOR ALL ENTRIES IN it_creditos
        WHERE a~bukrs = it_creditos-empresa
          AND a~belnr = it_creditos-documento
          AND a~gjahr = it_creditos-ano
          AND a~buzei = it_creditos-linha."#EC CI_SEL_DEL

      IF sy-subrc = 0.
        SELECT  a~bukrs
                a~belnr
                a~gjahr
                a~buzei
                a~kunnr
                a~zlsch
                a~zfbdt
                a~zbd1t
                a~zbd2t
                a~zbd3t
                a~sgtxt
                a~zuonr
                a~gsber
                a~kostl
                a~bupla
                a~prctr
                a~segment
                a~hbkid
                a~xref1
                a~xref2
                a~wrbtr
                a~bschl
                a~netdt
          FROM  bseg AS a
          INTO TABLE lt_documentos
          FOR ALL ENTRIES IN et_documentos
          WHERE a~bukrs = et_documentos-bukrs
            AND a~belnr = et_documentos-belnr
            AND a~gjahr = et_documentos-gjahr."#EC CI_NO_TRANSFORM

        SORT: et_documentos BY bukrs belnr gjahr buzei,
              lt_documentos BY bukrs belnr gjahr buzei.

        LOOP AT et_documentos ASSIGNING FIELD-SYMBOL(<fs_documentos>).
          DATA(lv_tabix_doc) = sy-tabix.
          READ TABLE lt_creditos
            WITH KEY empresa   = <fs_documentos>-bukrs
                     documento = <fs_documentos>-belnr
                     ano       = <fs_documentos>-gjahr
                     linha     = <fs_documentos>-buzei
            TRANSPORTING NO FIELDS
            BINARY SEARCH.
          IF sy-subrc EQ 0.


             ##FM_SUBRC_OK
            CALL FUNCTION 'J_1B_FI_NETDUE'
              EXPORTING
                zfbdt   = <fs_documentos>-zfbdt
                zbd1t   = <fs_documentos>-zbd1t
                zbd2t   = <fs_documentos>-zbd2t
                zbd3t   = <fs_documentos>-zbd3t
              IMPORTING
                duedate = <fs_documentos>-dtven
              EXCEPTIONS
                OTHERS  = 1."#EC CI_SUBRC


             ##FM_SUBRC_OK
            CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
              EXPORTING
                date                         = <fs_documentos>-dtven
                factory_calendar_id          = 'BR'
              IMPORTING
                date                         = <fs_documentos>-dtven
              EXCEPTIONS
                calendar_buffer_not_loadable = 1
                correct_option_invalid       = 2
                date_after_range             = 3
                date_before_range            = 4
                date_invalid                 = 5
                factory_calendar_not_found   = 6
                OTHERS                       = 7."#EC CI_SUBRC

            READ TABLE lt_documentos
               WITH KEY bukrs = <fs_documentos>-bukrs
                        belnr = <fs_documentos>-belnr
                        gjahr = <fs_documentos>-gjahr
               TRANSPORTING NO FIELDS."#EC CI_STDSEQ
            IF sy-subrc EQ 0.
              DATA(lv_tabix_out) = sy-tabix.
              LOOP AT lt_documentos ASSIGNING FIELD-SYMBOL(<fs_documentos_out>)
              FROM lv_tabix_out
              WHERE bukrs = <fs_documentos>-bukrs
                AND belnr = <fs_documentos>-belnr
                AND gjahr = <fs_documentos>-gjahr
                AND buzei GT <fs_documentos>-buzei."#EC CI_NESTED
                IF <fs_documentos_out>-gsber IS NOT INITIAL.
                  <fs_documentos>-gsber = <fs_documentos_out>-gsber.
                ENDIF.
                IF <fs_documentos_out>-kostl IS NOT INITIAL.
                  <fs_documentos>-kostl = <fs_documentos_out>-kostl.
                ENDIF.
                IF <fs_documentos_out>-prctr IS NOT INITIAL.
                  <fs_documentos>-prctr = <fs_documentos_out>-prctr.
                ENDIF.
                IF <fs_documentos_out>-segment IS NOT INITIAL.
                  <fs_documentos>-segment = <fs_documentos_out>-segment.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ELSE.
            DELETE et_documentos INDEX lv_tabix_doc.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD add_data_accountgl.
    IF is_fatura IS NOT INITIAL.
      CASE iv_item_no.
        WHEN '3'.
          APPEND VALUE #( itemno_acc  = iv_item_no
                           gl_account = gv_saknr40
                           item_text  = is_documento-sgtxt
                           alloc_nmbr = is_documento-zuonr
                           bus_area   = is_documento-gsber
                           profit_ctr = is_documento-prctr
                           segment    = is_documento-segment )
                 TO et_accountgl.
        WHEN '4'.
          APPEND VALUE #( itemno_acc  = iv_item_no
                            gl_account = gv_saknr50
                            item_text  = is_documento-sgtxt
                            alloc_nmbr = is_documento-zuonr
                            bus_area   = is_documento-gsber
                            profit_ctr = is_documento-prctr
                            segment    = is_documento-segment )
                  TO et_accountgl.
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD add_data_currencyamount.
    IF is_fatura IS INITIAL.
      APPEND VALUE #( itemno_acc = iv_item_no
                       currency   = is_creditos-moeda
                       amt_doccur = SWITCH #( iv_shkzg WHEN 'H' THEN ( is_creditos-montante * -1 ) ELSE is_creditos-montante ) )
             TO ct_currencyamount.

    ELSE.

    ENDIF.

  ENDMETHOD.


  METHOD add_data_accountreceivable.
    IF is_fatura IS INITIAL.
      APPEND VALUE #(  itemno_acc = iv_item_no
                       customer   = is_creditos-cliente
                       bus_area   = is_documento-gsber
                       alloc_nmbr = is_documento-zuonr
                       item_text  = is_documento-sgtxt
                       profit_ctr = is_documento-prctr )
             TO et_accountreceivable.
    ELSE.
      CASE iv_item_no.
        WHEN '1'.
          APPEND VALUE #(  itemno_acc = iv_item_no
                           customer   = is_creditos-cliente
                           bus_area   = is_documento-gsber
                           alloc_nmbr = is_documento-zuonr
                           item_text  = is_documento-sgtxt
                           profit_ctr = is_documento-prctr )
                 TO et_accountreceivable.
        WHEN '2'.
          APPEND VALUE #(  itemno_acc = iv_item_no
                           customer   = is_fatura-kunnr
                           bus_area   = is_fatura-gsber
                           alloc_nmbr = is_fatura-zuonr
                           item_text  = is_fatura-sgtxt
                           profit_ctr = is_fatura-prctr
                           partner_bk = is_fatura-hbkid
                           pymt_meth  = is_fatura-zlsch
                            )
                 TO et_accountreceivable.

      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD add_data_extension2.
    IF is_fatura IS INITIAL.
      APPEND VALUE #( structure  = 'BUPLA'
                      valuepart1 = iv_item_no
                      valuepart2 = is_documento-bupla )
             TO ct_extension2.

      APPEND VALUE #( structure  = 'XREF1_HD'
                      valuepart1 = iv_item_no
                      valuepart2 = 'PAGAR_DEVOL' )
             TO ct_extension2.

      APPEND VALUE #( structure  = 'XREF2_HD'
                      valuepart1 = iv_item_no
                      valuepart2 = is_documento-xref2 )
             TO ct_extension2.

    ELSE.
      APPEND VALUE #( structure  = 'BUPLA'
                       valuepart1 = iv_item_no
                       valuepart2 = is_documento-bupla )
              TO ct_extension2.

      APPEND VALUE #( structure  = 'XREF1_HD'
                      valuepart1 = iv_item_no
                      valuepart2 = 'CONC_MANUAL' )
             TO ct_extension2.

      APPEND VALUE #( structure  = 'XREF2_HD'
                      valuepart1 = iv_item_no
                      valuepart2 = is_documento-xref2 )
             TO ct_extension2.

    ENDIF.


  ENDMETHOD.


  METHOD add_data_accountpayable.
    IF is_fatura IS INITIAL.
      APPEND VALUE #(  itemno_acc = iv_item_no
                       vendor_no  = is_creditos-cliente
                       partner_bk = is_documento-hbkid
                       pymt_meth  = is_documento-zlsch
                       bus_area   = is_documento-gsber
                       paymt_ref  = is_documento-dtven
                       alloc_nmbr = is_documento-zuonr
                       item_text  = is_documento-sgtxt
                       profit_ctr = is_documento-prctr )
             TO et_accountpayable.

    ELSE.

    ENDIF.

  ENDMETHOD.


  METHOD  grava_log_pag_fornecedor.
    DATA ls_logtab TYPE ztfi_logconcred.

    IF iv_key IS NOT INITIAL.

      ls_logtab-bukrs = is_documento-bukrs.
      ls_logtab-kunnr = is_documento-kunnr.
      ls_logtab-stcd1 = is_documento-stcd1.
      ls_logtab-stcd2 = is_documento-stcd2.

      ls_logtab-zcredito          =  is_documento-belnr   .
      ls_logtab-zitemcredito      =  is_documento-buzei   .
      ls_logtab-zexerciciocredito =  is_documento-gjahr   .
      ls_logtab-zwrbtr            =  is_documento-wrbtr   .
      ls_logtab-zbschl            =  is_documento-bschl   .
      ls_logtab-znetdt            =  is_documento-dtven   .
      ls_logtab-zzlsch            =  is_documento-zlsch   .
      ls_logtab-zzuonr            =  is_documento-zuonr   .
      ls_logtab-zxblnr            =  is_documento-xblnr   .
      ls_logtab-zblart            =  is_documento-blart   .
      ls_logtab-zxref1_hd         =  is_documento-xref1.
      ls_logtab-zxref2_hd         =  is_documento-xref2.

      ls_logtab-zdoccon           = iv_key(10).
      ls_logtab-zexerciciodoccon  = iv_key+14(4).

      SELECT buzei
        FROM bseg
        INTO ls_logtab-zitemdoccon
        UP TO 1 ROWS
        WHERE bukrs = is_documento-bukrs
          AND belnr = ls_logtab-zdoccon
          AND gjahr = ls_logtab-zexerciciodoccon
          AND bschl = '17'."#EC CI_SEL_NESTED
      ENDSELECT.

      SELECT buzei
        FROM bseg
        INTO ls_logtab-umskz
        UP TO 1 ROWS
        WHERE bukrs = is_documento-bukrs
          AND belnr = ls_logtab-zdoccon
          AND gjahr = ls_logtab-zexerciciodoccon
          AND bschl = '09'."#EC CI_SEL_NESTED
      ENDSELECT.

      SELECT SINGLE bankn
        FROM lfbk
        INTO ls_logtab-zdadosfor
        WHERE lifnr = is_documento-kunnr."#EC CI_SEL_NESTED

      IF sy-subrc <> 0.
        ls_logtab-zdadosfor = 'NÃO'.
      ELSE.
        CLEAR ls_logtab-zdadosfor.
      ENDIF.

      ls_logtab-zdata = sy-datum.
      ls_logtab-zhora = sy-uzeit.
      ls_logtab-bname = sy-uname.

      MODIFY ztfi_logconcred FROM ls_logtab."#EC CI_IMUD_NESTED
      CLEAR ls_logtab.
    ENDIF.

  ENDMETHOD.


  METHOD executa_lanc_associ_cred.
    DATA: ls_docheader      TYPE bapiache09.

    DATA: lt_accountgl         TYPE bapiacgl09_tab,
          lt_accountreceivable TYPE bapiacar09_tab,
          lt_accountpayable    TYPE bapiacap09_tab,
          lt_currencyamount    TYPE bapiaccr09_tab,
          lt_extension2        TYPE bapiapoparex_tab,
          lt_return            TYPE bapiret2_t.

    me->select_dados_doc_asso_cred( EXPORTING it_creditos   = it_creditos
                                    IMPORTING es_fatura     = DATA(ls_fatura)
                                              et_documentos = DATA(lt_documentos) ).

    LOOP AT it_creditos ASSIGNING FIELD-SYMBOL(<fs_creditos>).
      CLEAR:  lt_accountgl[],
              lt_accountreceivable[],
              lt_accountpayable[],
              lt_currencyamount[],
              lt_extension2[],
              lt_return[].
      READ TABLE lt_documentos
        ASSIGNING FIELD-SYMBOL(<fs_documentos>)
        WITH KEY bukrs = <fs_creditos>-empresa
                 belnr = <fs_creditos>-documento
                 gjahr = <fs_creditos>-ano
                 buzei = <fs_creditos>-linha
        BINARY SEARCH.
      IF <fs_creditos>-chavelancamento = gc_associ-pdc .
        IF <fs_documentos>-resid = 0.
          me->preenche_dados_pdc(
            EXPORTING
              is_creditos          = <fs_creditos>
              is_fatura            = ls_fatura
              is_documento         = <fs_documentos>
            IMPORTING
              es_docheader         = ls_docheader
              et_accountreceivable = lt_accountreceivable
              et_accountgl         = lt_accountgl
              et_currencyamount    = lt_currencyamount
              et_extension2        = lt_extension2 ).
        ELSE.
          me->preenche_dados_pdc_residual(
            EXPORTING
              is_creditos          = <fs_creditos>
              is_fatura            = ls_fatura
              is_documento         = <fs_documentos>
            IMPORTING
              es_docheader         = ls_docheader
              et_accountreceivable = lt_accountreceivable
              et_accountgl         = lt_accountgl
              et_currencyamount    = lt_currencyamount
              et_extension2        = lt_extension2 ).

        ENDIF.
      ELSEIF <fs_creditos>-chavelancamento = gc_associ-devolucao .
        IF <fs_documentos>-resid = 0.
          me->preenche_dados_devo(
            EXPORTING
              is_creditos          = <fs_creditos>
              is_fatura            = ls_fatura
              is_documento         = <fs_documentos>
            IMPORTING
              es_docheader         = ls_docheader
              et_accountreceivable = lt_accountreceivable
              et_accountgl         = lt_accountgl
              et_currencyamount    = lt_currencyamount
              et_extension2        = lt_extension2 ).
        ELSE.
          me->preenche_dados_devo_resi(
            EXPORTING
              is_creditos          = <fs_creditos>
              is_fatura            = ls_fatura
              is_documento         = <fs_documentos>
            IMPORTING
              es_docheader         = ls_docheader
              et_accountreceivable = lt_accountreceivable
              et_accountgl         = lt_accountgl
              et_currencyamount    = lt_currencyamount
              et_extension2        = lt_extension2 ).

        ENDIF.
      ENDIF.


      NEW zclfi_exec_lancamento( )->executar_new_task(
           EXPORTING
             is_docheader         = ls_docheader
             it_accountgl         = lt_accountgl
             it_accountreceivable = lt_accountreceivable
             it_accountpayable    = lt_accountpayable
             it_extension2        = lt_extension2
             it_currencyamount    = lt_currencyamount
           IMPORTING
             ev_type           = DATA(lv_type)
             ev_key            = DATA(lv_key)
             ev_sys            = DATA(lv_sys)
           RECEIVING
             rt_return         = lt_return
         ).

      IF NOT line_exists( lt_return[ type = 'E' ] )."#EC CI_STDSEQ
        exe_fb1d_doc_change( iv_tipo     = 'A'
                             is_creditos = <fs_creditos>
                             is_fatura   = ls_fatura ).
        grava_log_associ_credito(  EXPORTING iv_key       = lv_key
                                             is_creditos  = <fs_creditos>
                                             is_documento = <fs_documentos>
                                             is_fatura    = ls_fatura ).
        "Doc. &1 Empresa &2 Exercício &3 contabilizado com sucesso!
        et_return[] = VALUE #( BASE et_return ( parameter = gc_cds-credito
                                                field = 'BELNR'
                                                type = 'S'
                                                id = 'ZFI_ASSOCI_CRE'
                                                number = '015'
                                                message_v1 = lv_key(10)
                                                message_v2 = lv_key+10(4)
                                                message_v3 = lv_key+14(4) ) ).
      ELSE.
        APPEND LINES OF lt_return TO et_return.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD select_dados_doc_asso_cred.
    DATA: lt_documentos TYPE tt_bseg.

    DATA(lt_creditos) = it_creditos[].

    SORT lt_creditos BY empresa documento ano linha.

    IF it_creditos[] IS NOT INITIAL.
      SELECT  a~bukrs
              a~belnr
              a~gjahr
              a~buzei
              a~kunnr
              a~zlsch
              a~zfbdt
              a~zbd1t
              a~zbd2t
              a~zbd3t
              a~sgtxt
              a~zuonr
              a~gsber
              a~kostl
              a~bupla
              a~prctr
              a~segment
              a~hbkid
              a~xref1
              a~xref2
              a~wrbtr
              a~bschl
              a~netdt
              c~xblnr
              c~blart
              c~bktxt
              b~stcd1
              b~stcd2
        FROM  bseg AS a
        INNER JOIN kna1 AS b
        ON b~kunnr = a~kunnr
        INNER JOIN bkpf AS c
        ON c~bukrs = a~bukrs     AND
           c~belnr = a~belnr     AND
           c~gjahr = a~gjahr
        INTO TABLE et_documentos
        FOR ALL ENTRIES IN it_creditos
        WHERE a~bukrs = it_creditos-empresa
          AND a~belnr = it_creditos-documento
          AND a~gjahr = it_creditos-ano."#EC CI_SEL_DEL

      IF sy-subrc = 0.
        SELECT  a~bukrs
                a~belnr
                a~gjahr
                a~buzei
                a~kunnr
                a~zlsch
                a~zfbdt
                a~zbd1t
                a~zbd2t
                a~zbd3t
                a~sgtxt
                a~zuonr
                a~gsber
                a~kostl
                a~bupla
                a~prctr
                a~segment
                a~hbkid
                a~xref1
                a~xref2
                a~wrbtr
                a~bschl
                a~netdt
          FROM  bseg AS a
          INTO TABLE lt_documentos
          FOR ALL ENTRIES IN et_documentos
          WHERE a~bukrs = et_documentos-bukrs
            AND a~belnr = et_documentos-belnr
            AND a~gjahr = et_documentos-gjahr."#EC CI_NO_TRANSFORM

        SORT: et_documentos BY bukrs belnr gjahr buzei,
              lt_documentos BY bukrs belnr gjahr buzei.

        LOOP AT et_documentos ASSIGNING FIELD-SYMBOL(<fs_documentos>).
          DATA(lv_tabix_doc) = sy-tabix.
          READ TABLE lt_creditos
            WITH KEY empresa   = <fs_documentos>-bukrs
                     documento = <fs_documentos>-belnr
                     ano       = <fs_documentos>-gjahr
                     linha     = <fs_documentos>-buzei
            TRANSPORTING NO FIELDS
            BINARY SEARCH.
          IF sy-subrc EQ 0.
            READ TABLE lt_documentos
               WITH KEY bukrs = <fs_documentos>-bukrs
                        belnr = <fs_documentos>-belnr
                        gjahr = <fs_documentos>-gjahr
               TRANSPORTING NO FIELDS."#EC CI_STDSEQ
            IF sy-subrc EQ 0.
              DATA(lv_tabix_out) = sy-tabix.
              LOOP AT lt_documentos ASSIGNING FIELD-SYMBOL(<fs_documentos_out>)
              FROM lv_tabix_out
              WHERE bukrs = <fs_documentos>-bukrs
                AND belnr = <fs_documentos>-belnr
                AND gjahr = <fs_documentos>-gjahr
                AND buzei GT <fs_documentos>-buzei."#EC CI_NESTED
                IF <fs_documentos_out>-gsber IS NOT INITIAL.
                  <fs_documentos>-gsber = <fs_documentos_out>-gsber.
                ENDIF.
                IF <fs_documentos_out>-kostl IS NOT INITIAL.
                  <fs_documentos>-kostl = <fs_documentos_out>-kostl.
                ENDIF.
                IF <fs_documentos_out>-prctr IS NOT INITIAL.
                  <fs_documentos>-prctr = <fs_documentos_out>-prctr.
                ENDIF.
                IF <fs_documentos_out>-segment IS NOT INITIAL.
                  <fs_documentos>-segment = <fs_documentos_out>-segment.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ELSE.
            DELETE et_documentos INDEX lv_tabix_doc.
          ENDIF.
        ENDLOOP.

        SELECT  empresa,
                documento,
                ano,
                linha,
                cliente,
                residual
          FROM ztfi_creditoscli
          INTO TABLE @DATA(lt_creditoscli)
          FOR ALL ENTRIES IN @et_documentos
        WHERE empresa   = @et_documentos-bukrs
          AND documento = @et_documentos-belnr
          AND ano       = @et_documentos-gjahr
          AND linha     = @et_documentos-buzei.
        IF sy-subrc = 0.
          SORT lt_creditoscli BY empresa documento ano linha.
        ENDIF.


        LOOP AT et_documentos ASSIGNING <fs_documentos>.

           ##FM_SUBRC_OK
          CALL FUNCTION 'J_1B_FI_NETDUE'
            EXPORTING
              zfbdt   = <fs_documentos>-zfbdt
              zbd1t   = <fs_documentos>-zbd1t
              zbd2t   = <fs_documentos>-zbd2t
              zbd3t   = <fs_documentos>-zbd3t
            IMPORTING
              duedate = <fs_documentos>-dtven
            EXCEPTIONS
              OTHERS  = 1."#EC CI_SUBRC


           ##FM_SUBRC_OK
          CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
            EXPORTING
              date                         = <fs_documentos>-dtven
              factory_calendar_id          = 'BR'
            IMPORTING
              date                         = <fs_documentos>-dtven
            EXCEPTIONS
              calendar_buffer_not_loadable = 1
              correct_option_invalid       = 2
              date_after_range             = 3
              date_before_range            = 4
              date_invalid                 = 5
              factory_calendar_not_found   = 6
              OTHERS                       = 7."#EC CI_SUBRC
          READ TABLE lt_creditoscli
              ASSIGNING FIELD-SYMBOL(<fs_creditoscli>)
            WITH KEY empresa   = <fs_documentos>-bukrs
                     documento = <fs_documentos>-belnr
                     ano       = <fs_documentos>-gjahr
                     linha     = <fs_documentos>-buzei
            BINARY SEARCH.
          IF sy-subrc = 0.
            <fs_documentos>-resid = <fs_creditoscli>-residual.
          ENDIF.
        ENDLOOP.

        READ TABLE it_creditos ASSIGNING FIELD-SYMBOL(<fs_creditos>) INDEX 1.
        SELECT SINGLE  a~empresa
                       a~documento
                       a~ano
                       a~linha
                       b~kunnr
                       b~zlsch
                       b~zfbdt
                       b~zbd1t
                       b~zbd2t
                       b~zbd3t
                       b~sgtxt
                       b~zuonr
                       b~gsber
                       b~bupla
                       b~prctr
                       b~segment
                       b~hbkid
                       b~xref1
                       b~xref2
                       b~anfbn
                       b~wrbtr
                       b~bschl
                       b~netdt
                       c~xblnr
                       c~blart
                       c~budat
                       c~bktxt
                       d~stcd1
                       d~stcd2
           INTO es_fatura
           FROM ztfi_faturacli AS a
           INNER JOIN bseg AS b
           ON b~bukrs = a~empresa AND
              b~belnr = a~documento AND
              b~gjahr = a~ano       AND
              b~buzei = a~linha
           INNER JOIN bkpf AS c
           ON c~bukrs = b~bukrs     AND
              c~belnr = b~belnr     AND
              c~gjahr = b~gjahr
            INNER JOIN kna1 AS d
            ON d~kunnr = b~kunnr
           WHERE a~empresa   = <fs_creditos>-empresa
             AND a~cliente   = <fs_creditos>-cliente
             AND a~raizid    = <fs_creditos>-raizid
             AND a~raizsn    = <fs_creditos>-raizsn
             AND a~marcado   = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD preenche_dados_pag_for.

    DATA: lv_item_no    TYPE posnr_acc.

    DATA(lv_venc) = is_documento-dtven.

    get_dia_util( CHANGING cv_date = lv_venc ).

    es_docheader-doc_date     = sy-datum.
    es_docheader-username     = sy-uname.
    es_docheader-pstng_date   = sy-datum.
    es_docheader-fisc_year    = es_docheader-pstng_date(4).
    es_docheader-fis_period   = es_docheader-pstng_date+4(2).
    es_docheader-comp_code    = is_creditos-empresa .
    es_docheader-ref_doc_no   = is_documento-xblnr.
    es_docheader-header_txt   = get_text_header( is_creditos )."is_creditos-documento.
    es_docheader-doc_type     = gv_blart_lanc_31.

    lv_item_no = 1.

    APPEND VALUE #(  itemno_acc = lv_item_no
                      vendor_no  = is_creditos-cliente
                      bank_id    = is_documento-hbkid
                      pymt_meth  = is_documento-zlsch
                      bus_area   = is_documento-gsber
                      paymt_ref  = is_documento-dtven
                      alloc_nmbr = is_documento-zuonr
                      item_text  = is_documento-sgtxt
                      bline_date = lv_venc
                      profit_ctr = is_documento-prctr )
            TO et_accountpayable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_creditos-montante * -1 )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BUPLA'
                    valuepart1 = lv_item_no
                    valuepart2 = is_documento-bupla )
           TO et_extension2.

    APPEND VALUE #( structure  = 'XREF1_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = 'PAGAR_DEVOL' )
           TO et_extension2.

    APPEND VALUE #( structure  = 'XREF2_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = |{ is_documento-belnr }-{ is_documento-gjahr }| )
           TO et_extension2.

    APPEND VALUE #( structure  = 'BSCHL'
                    valuepart1 = lv_item_no
                    valuepart2 = '31' )
           TO et_extension2.

    lv_item_no = lv_item_no + 1.

    APPEND VALUE #(  itemno_acc = lv_item_no
                     customer   = is_creditos-cliente
                     bus_area   = is_documento-gsber
                     alloc_nmbr = is_documento-zuonr
                     item_text  = is_documento-sgtxt
                     profit_ctr = is_documento-prctr )
           TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_creditos-montante )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BUPLA'
                    valuepart1 = lv_item_no
                    valuepart2 = is_documento-bupla )
           TO et_extension2.

    APPEND VALUE #( structure  = 'XREF1_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = 'PAGAR_DEVOL' )
           TO et_extension2.

    APPEND VALUE #( structure  = 'XREF2_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = |{ is_documento-belnr }-{ is_documento-gjahr }| )
           TO et_extension2.

    APPEND VALUE #( structure  = 'BSCHL'
                    valuepart1 = lv_item_no
                    valuepart2 = '07' )
           TO et_extension2.

  ENDMETHOD.


  METHOD preenche_dados_pdc.
    DATA: lv_item_no    TYPE posnr_acc.

    DATA: lv_cliente TYPE kna1-kunnr.

    DATA: lv_bus_area_cred TYPE gsber,
          lv_bus_area_fat  TYPE gsber.

    IF is_creditos-cliente IS NOT INITIAL.
      lv_cliente = is_creditos-cliente.
    ELSE.
      lv_cliente = is_creditos-codcliente.
    ENDIF.

    IF is_documento-gsber IS INITIAL.

      SELECT SINGLE
        gsber
        FROM bseg
        INTO @lv_bus_area_cred
        WHERE bukrs = @is_documento-bukrs
          AND belnr = @is_documento-belnr
          AND gjahr = @is_documento-gjahr
          AND koart = 'S'.

    ELSE.
      lv_bus_area_cred = is_documento-gsber.
    ENDIF.

    IF is_fatura-gsber IS INITIAL.

      SELECT SINGLE
        gsber
        FROM bseg
        INTO @lv_bus_area_fat
        WHERE bukrs = @is_fatura-bukrs
          AND belnr = @is_fatura-belnr
          AND gjahr = @is_fatura-gjahr
          AND koart = 'S'.

    ELSE.
      lv_bus_area_fat = is_fatura-gsber.
    ENDIF.

    es_docheader-doc_date     = sy-datum.
    es_docheader-username     = sy-uname.
    es_docheader-pstng_date   = sy-datum.
    es_docheader-fisc_year    = es_docheader-pstng_date(4).
    es_docheader-fis_period   = es_docheader-pstng_date+4(2).
    es_docheader-comp_code    = is_creditos-empresa .
    es_docheader-ref_doc_no   = is_creditos-referencia.
    es_docheader-header_txt   = is_documento-bktxt.
    es_docheader-doc_type     = gv_tp_doc_associ.

    lv_item_no = 1.

*   Lançamento 09

    APPEND VALUE #(  itemno_acc = lv_item_no
                     customer   = lv_cliente
                     sp_gl_ind  = gv_umskz_associ
*                     bus_area   = is_documento-gsber
                     bus_area   = lv_bus_area_cred
                     alloc_nmbr = is_documento-zuonr
                     item_text  = is_documento-sgtxt
                     profit_ctr = is_documento-prctr )
           TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_creditos-montante )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = '09' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

    APPEND VALUE #( structure  = 'XREF1_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = 'CONC_MANUAL' )
           TO et_extension2.

    APPEND VALUE #( structure  = 'XREF2_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = |{ is_fatura-belnr }-{ is_fatura-gjahr }| )
           TO et_extension2.

    lv_item_no = lv_item_no + 1.

*   Lançamento 17

    APPEND VALUE #(  itemno_acc = lv_item_no
                      customer   = is_fatura-kunnr
*                      bus_area   = is_fatura-gsber
                      bus_area   = lv_bus_area_fat
                      alloc_nmbr = is_fatura-zuonr
*                      alloc_nmbr = is_documento-zuonr
                      item_text  = is_documento-sgtxt
                      profit_ctr = is_fatura-prctr
                      bank_id    = is_fatura-hbkid
                      pymt_meth  = is_fatura-zlsch
                       )
            TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_creditos-montante * -1 )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = '17' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-bupla )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZG'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-belnr )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZJ'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-gjahr )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZZ'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-buzei )
            TO et_extension2.

    lv_item_no = lv_item_no + 1.

*   Lançamento 40

    APPEND VALUE #( itemno_acc  = lv_item_no
                     gl_account = gv_saknr40
                     item_text  = is_documento-sgtxt
                     alloc_nmbr = is_documento-zuonr
                     costcenter = is_documento-kostl
*                     bus_area   = is_documento-gsber
                     bus_area   = lv_bus_area_cred
                     profit_ctr = is_documento-prctr
                     segment    = is_documento-segment )
           TO et_accountgl.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_creditos-montante )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

    lv_item_no = lv_item_no + 1.

*   Lançamento 50

    APPEND VALUE #( itemno_acc  = lv_item_no
                      gl_account = gv_saknr50
                      item_text  = is_documento-sgtxt
                      alloc_nmbr = is_documento-zuonr
*                      bus_area   = is_documento-gsber
                      bus_area   = lv_bus_area_cred
                      profit_ctr = is_documento-prctr
                      costcenter = is_documento-kostl
                      segment    = is_documento-segment )
            TO et_accountgl.

    APPEND VALUE #( itemno_acc = lv_item_no
                      currency   = is_creditos-moeda
                      amt_doccur = is_creditos-montante * -1 )
            TO et_currencyamount.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

  ENDMETHOD.


  METHOD preenche_dados_pdc_residual.

    DATA: lv_item_no  TYPE posnr_acc,
          lv_montante TYPE bseg-dmbtr.

    DATA: lv_bus_area_cred TYPE gsber,
          lv_bus_area_fat  TYPE gsber.

    IF is_documento-gsber IS INITIAL.

      SELECT SINGLE
        gsber
        FROM bseg
        INTO @lv_bus_area_cred
        WHERE bukrs = @is_documento-bukrs
          AND belnr = @is_documento-belnr
          AND gjahr = @is_documento-gjahr
          AND koart = 'S'.

    ELSE.
      lv_bus_area_cred = is_documento-gsber.
    ENDIF.

    IF is_fatura-gsber IS INITIAL.

      SELECT SINGLE
        gsber
        FROM bseg
        INTO @lv_bus_area_fat
        WHERE bukrs = @is_fatura-bukrs
          AND belnr = @is_fatura-belnr
          AND gjahr = @is_fatura-gjahr
          AND koart = 'S'.

    ELSE.
      lv_bus_area_fat = is_fatura-gsber.
    ENDIF.

    es_docheader-doc_date     = sy-datum.
    es_docheader-username     = sy-uname.
    es_docheader-pstng_date   = sy-datum.
    es_docheader-fisc_year    = es_docheader-pstng_date(4).
    es_docheader-fis_period   = es_docheader-pstng_date+4(2).
    es_docheader-comp_code    = is_creditos-empresa .
    es_docheader-ref_doc_no   = is_creditos-referencia.
    es_docheader-header_txt   = is_documento-bktxt.
    es_docheader-doc_type     = gv_tp_doc_associ.

    lv_item_no = 1.

*   Lançamento 09

    APPEND VALUE #(  itemno_acc = lv_item_no
                     customer   = is_creditos-cliente
                     sp_gl_ind  = gv_umskz_associ
*                     bus_area   = is_documento-gsber
                     bus_area   = lv_bus_area_cred
                     alloc_nmbr = is_documento-zuonr
                     item_text  = is_documento-sgtxt
                     profit_ctr = is_documento-prctr
                     pymt_meth  = is_documento-zlsch )
           TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_creditos-montante )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = '09' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

    APPEND VALUE #( structure  = 'XREF1_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = 'CONC_MANUAL' )
           TO et_extension2.

    APPEND VALUE #( structure  = 'XREF2_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = |{ is_fatura-belnr }-{ is_fatura-gjahr }| )
           TO et_extension2.

    lv_item_no = lv_item_no + 1.

*   Lançamento 19

*    lv_montante = is_creditos-montante - is_documento-resid.

    APPEND VALUE #(  itemno_acc = lv_item_no
                     customer   = is_creditos-cliente
                     sp_gl_ind  = gv_umskz_associ
*                     bus_area   = is_documento-gsber
                     bus_area   = lv_bus_area_cred
                     alloc_nmbr = is_documento-zuonr
                     item_text  = is_documento-sgtxt
                     profit_ctr = is_documento-prctr
                     pymt_meth  = is_documento-zlsch
                     )
            TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_documento-resid * -1 )
*                     amt_doccur = lv_montante * -1 )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = '19' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-bupla )
            TO et_extension2.

    lv_item_no = lv_item_no + 1.

*   Lançamento 17

    lv_montante = is_creditos-montante - is_documento-resid.

    APPEND VALUE #(  itemno_acc = lv_item_no
                     customer   = is_fatura-kunnr
*                     bus_area   = is_fatura-gsber
                     bus_area   = lv_bus_area_fat
                     alloc_nmbr = is_fatura-zuonr
*                     alloc_nmbr = is_documento-zuonr
                     item_text  = is_documento-sgtxt
                     profit_ctr = is_fatura-prctr
                     bank_id    = is_fatura-hbkid
                     pymt_meth  = is_fatura-zlsch
                      )
           TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = lv_montante * -1 )
*                     amt_doccur = is_documento-resid * -1 )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = '17' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-bupla )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZG'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-belnr )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZJ'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-gjahr )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZZ'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-buzei )
            TO et_extension2.

    lv_item_no = lv_item_no + 1.

*   Lançamento 40

    APPEND VALUE #( itemno_acc  = lv_item_no
                     gl_account = gv_saknr40
                     item_text  = is_documento-sgtxt
                     alloc_nmbr = is_documento-zuonr
*                     bus_area   = is_documento-gsber
                     bus_area   = lv_bus_area_cred
                     profit_ctr = is_documento-prctr
                     costcenter = is_documento-kostl
                     segment    = is_documento-segment )
           TO et_accountgl.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = lv_montante ) "is_documento-resid
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

    lv_item_no = lv_item_no + 1.

*   Lançamento 50

    APPEND VALUE #( itemno_acc  = lv_item_no
                    gl_account = gv_saknr50
                    item_text  = is_documento-sgtxt
                    alloc_nmbr = is_documento-zuonr
*                    bus_area   = is_documento-gsber
                    bus_area   = lv_bus_area_cred
                    profit_ctr = is_documento-prctr
                    costcenter = is_documento-kostl
                    segment    = is_documento-segment )
            TO et_accountgl.

    APPEND VALUE #( itemno_acc = lv_item_no
                      currency   = is_creditos-moeda
                      amt_doccur = lv_montante * -1 ) "is_documento-resid * -1
            TO et_currencyamount.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

  ENDMETHOD.


  METHOD preenche_dados_devo.

    DATA: lv_item_no    TYPE posnr_acc.

    DATA: lv_cliente TYPE kna1-kunnr.

    IF is_creditos-cliente IS NOT INITIAL.
      lv_cliente = is_creditos-cliente.
    ELSE.
      lv_cliente = is_creditos-codcliente.
    ENDIF.

    es_docheader-doc_date     = sy-datum.
    es_docheader-username     = sy-uname.
    es_docheader-pstng_date   = sy-datum.
    es_docheader-fisc_year    = es_docheader-pstng_date(4).
    es_docheader-fis_period   = es_docheader-pstng_date+4(2).
    es_docheader-comp_code    = is_creditos-empresa .
    es_docheader-ref_doc_no   = is_creditos-referencia.
    es_docheader-header_txt   = is_documento-bktxt.
    es_docheader-doc_type     = gv_tp_doc_associ.

    lv_item_no = 1.

    APPEND VALUE #(  itemno_acc = lv_item_no
                     customer   = lv_cliente
                     bus_area   = is_documento-gsber
                     alloc_nmbr = is_documento-zuonr
*                     alloc_nmbr = is_fatura-zuonr
                     item_text  = is_documento-sgtxt
                     profit_ctr = is_documento-prctr
*                     pymt_meth  = is_fatura-zlsch
                     pymt_meth  = is_documento-zlsch
                      )
           TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_creditos-montante )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = '07' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

    APPEND VALUE #( structure  = 'XREF1_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = 'CONC_MANUAL' )
           TO et_extension2.

    APPEND VALUE #( structure  = 'XREF2_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = |{ is_documento-belnr }-{ is_documento-gjahr }| )
           TO et_extension2.

    lv_item_no = lv_item_no + 1.

    APPEND VALUE #(  itemno_acc = lv_item_no
                      customer   = is_fatura-kunnr
                      bus_area   = is_documento-gsber
*                      alloc_nmbr = is_documento-zuonr
                      alloc_nmbr = is_fatura-zuonr
                      item_text  = is_documento-sgtxt
                      profit_ctr = is_documento-prctr
                      bank_id    = is_fatura-hbkid
                      pymt_meth  = is_fatura-zlsch
                       )
            TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_creditos-montante * -1 )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = '17' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZG'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-belnr )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZJ'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-gjahr )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZZ'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-buzei )
            TO et_extension2.

  ENDMETHOD.


  METHOD preenche_dados_devo_resi.
    DATA: lv_item_no  TYPE posnr_acc,
          lv_montante TYPE bseg-dmbtr.

    es_docheader-doc_date     = sy-datum.
    es_docheader-username     = sy-uname.
    es_docheader-pstng_date   = sy-datum.
    es_docheader-fisc_year    = es_docheader-pstng_date(4).
    es_docheader-fis_period   = es_docheader-pstng_date+4(2).
    es_docheader-comp_code    = is_creditos-empresa .
    es_docheader-ref_doc_no   = is_creditos-referencia.
    es_docheader-header_txt   = is_documento-bktxt.
    es_docheader-doc_type     = gv_tp_doc_associ.

    lv_item_no = 1.

    lv_montante = is_creditos-montante - is_documento-resid.

    APPEND VALUE #(  itemno_acc = lv_item_no
                     customer   = is_creditos-codcliente
                     bus_area   = is_documento-gsber
                     alloc_nmbr = is_documento-zuonr
*                     alloc_nmbr = is_fatura-zuonr
                     item_text  = is_documento-sgtxt
                     profit_ctr = is_documento-prctr
*                     pymt_meth  = is_fatura-zlsch
                     pymt_meth  = is_documento-zlsch
                      )
           TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_documento-resid * -1 )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bschl ) "pferraz 27/12
*                     valuepart2 = '11' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

    APPEND VALUE #( structure  = 'XREF1_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = 'CONC_MANUAL' )
           TO et_extension2.

    APPEND VALUE #( structure  = 'XREF2_HD'
                    valuepart1 = lv_item_no
                    valuepart2 = |{ is_documento-belnr }-{ is_documento-gjahr }| )
           TO et_extension2.

    APPEND VALUE #( structure  = 'REBZG'
                     valuepart1 = lv_item_no
                     valuepart2 = '' )
            TO et_extension2.

    lv_item_no = lv_item_no + 1.

    APPEND VALUE #(  itemno_acc = lv_item_no
                     customer   = is_creditos-codcliente
                     bus_area   = is_documento-gsber
                     alloc_nmbr = is_documento-zuonr
*                     alloc_nmbr = is_fatura-zuonr
                     item_text  = is_documento-sgtxt
                     profit_ctr = is_documento-prctr
*                     pymt_meth  = is_fatura-zlsch
                     pymt_meth  = is_documento-zlsch
                      )
            TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = is_creditos-montante )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = '07' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

    lv_item_no = lv_item_no + 1.

    APPEND VALUE #(  itemno_acc = lv_item_no
                     customer   = is_fatura-kunnr
                     bus_area   = is_documento-gsber
*                     alloc_nmbr = is_documento-zuonr
                     alloc_nmbr = is_fatura-zuonr
                     item_text  = is_documento-sgtxt
                     profit_ctr = is_documento-prctr
                     bank_id    = is_fatura-hbkid
                     pymt_meth  = is_fatura-zlsch
                      )
           TO et_accountreceivable.

    APPEND VALUE #( itemno_acc = lv_item_no
                     currency   = is_creditos-moeda
                     amt_doccur = lv_montante * -1 )
           TO et_currencyamount.

    APPEND VALUE #( structure  = 'BSCHL'
                     valuepart1 = lv_item_no
                     valuepart2 = '17' )
            TO et_extension2.

    APPEND VALUE #( structure  = 'BUPLA'
                     valuepart1 = lv_item_no
                     valuepart2 = is_documento-bupla )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZG'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-belnr )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZJ'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-gjahr )
            TO et_extension2.

    APPEND VALUE #( structure  = 'REBZZ'
                     valuepart1 = lv_item_no
                     valuepart2 = is_fatura-buzei )
            TO et_extension2.
  ENDMETHOD.


  METHOD commit.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDMETHOD.


  METHOD exe_fb1d_doc_change.
    DATA: ls_copensa_upd_doc TYPE zsfi_compensa_upd_doc.

    ls_copensa_upd_doc-tipo      = iv_tipo.
    ls_copensa_upd_doc-bukrs_cre = is_creditos-Empresa.
    ls_copensa_upd_doc-belnr_cre = is_creditos-Documento.
    ls_copensa_upd_doc-gjahr_cre = is_creditos-Ano.
    ls_copensa_upd_doc-buzei_cre = is_creditos-Linha.

    if iv_tipo = 'A'.

      ls_copensa_upd_doc-bukrs = is_fatura-bukrs.
      ls_copensa_upd_doc-belnr = is_fatura-belnr.
      ls_copensa_upd_doc-gjahr = is_fatura-gjahr.
      ls_copensa_upd_doc-buzei = is_fatura-buzei.
      ls_copensa_upd_doc-kunnr = is_fatura-kunnr.
      ls_copensa_upd_doc-anfbn = is_fatura-anfbn.

    endif.

    NEW zclfi_exec_compensa_upd_doc(  )->executar_new_task(
      EXPORTING
        is_compensa_upd_doc = ls_copensa_upd_doc
      IMPORTING
        es_compensa_upd_doc = ls_copensa_upd_doc
      RECEIVING
        rt_return           = DATA(lt_return)
    ).

  ENDMETHOD.


  METHOD exe_fb1d.
    DATA lv_doc_est TYPE belnr_d.
    DATA lv_item_est TYPE buzei.
    DATA lv_ano_est TYPE mjahr.

    DATA: lv_error TYPE boolean.

    IF is_fatura-anfbn IS NOT INITIAL.

      CALL FUNCTION 'ZFMFI_BATCH_COMPENSAR'
        EXPORTING
          iv_kunnr    = is_fatura-kunnr
          iv_waers    = 'BRL'
          iv_budat    = sy-datum
          iv_bukrs    = is_fatura-bukrs
          iv_anfbn    = is_fatura-anfbn
        IMPORTING
          ev_erro     = lv_error
          ev_doc_est  = lv_doc_est
          ev_item_est = lv_item_est
          ev_ano_est  = lv_ano_est
        CHANGING
          ct_msg      = et_return.

    ENDIF.

  ENDMETHOD.


  METHOD grava_log_associ_credito.
    DATA ls_logtab TYPE ztfi_logconcred.

    IF iv_key IS NOT INITIAL.

      ls_logtab-bukrs = is_documento-bukrs.
      ls_logtab-kunnr = is_documento-kunnr.
      ls_logtab-stcd1 = is_documento-stcd1.
      ls_logtab-stcd2 = is_documento-stcd2.

      ls_logtab-zfatura          = is_fatura-belnr.
      ls_logtab-zitemfatura      = is_fatura-buzei.
      ls_logtab-zexerciciofatura = is_fatura-gjahr.
      ls_logtab-wrbtr            = is_fatura-wrbtr   .
      ls_logtab-bschl            = is_fatura-bschl   .
      ls_logtab-netdt            = is_fatura-netdt   .
      ls_logtab-zlsch            = is_fatura-zlsch   .
      ls_logtab-zuonr            = is_fatura-zuonr   .
      ls_logtab-xblnr            = is_fatura-xblnr   .
      ls_logtab-blart            = is_fatura-blart   .
      ls_logtab-xref1_hd         = is_fatura-xref1.
      ls_logtab-xref2_hd         = is_fatura-xref2.

      ls_logtab-zcredito          =  is_documento-belnr   .
      ls_logtab-zitemcredito      =  is_documento-buzei   .
      ls_logtab-zexerciciocredito =  is_documento-gjahr   .
      ls_logtab-zwrbtr            =  is_documento-wrbtr   .
      ls_logtab-zbschl            =  is_documento-bschl   .
      ls_logtab-znetdt            =  is_documento-dtven   .
      ls_logtab-zzlsch            =  is_documento-zlsch   .
      ls_logtab-zzuonr            =  is_documento-zuonr   .
      ls_logtab-zxblnr            =  is_documento-xblnr   .
      ls_logtab-zblart            =  is_documento-blart   .
      ls_logtab-zxref1_hd         =  is_documento-xref1.
      ls_logtab-zxref2_hd         =  is_documento-xref2.

      ls_logtab-zdoccon           = iv_key(10).
      ls_logtab-zexerciciodoccon  = iv_key+14(4).

      SELECT buzei
        FROM bseg
        INTO ls_logtab-zitemdoccon
        UP TO 1 ROWS
        WHERE bukrs = is_documento-bukrs
          AND belnr = ls_logtab-zdoccon
          AND gjahr = ls_logtab-zexerciciodoccon
          AND bschl = '17'."#EC CI_SEL_NESTED
      ENDSELECT.

      SELECT buzei
        FROM bseg
        INTO ls_logtab-umskz
        UP TO 1 ROWS
        WHERE bukrs = is_documento-bukrs
          AND belnr = ls_logtab-zdoccon
          AND gjahr = ls_logtab-zexerciciodoccon
          AND bschl = '09'."#EC CI_SEL_NESTED
      ENDSELECT.

      SELECT SINGLE bankn
        FROM lfbk
        INTO ls_logtab-zdadosfor
        WHERE lifnr = is_documento-kunnr."#EC CI_SEL_NESTED

      IF sy-subrc <> 0.
        ls_logtab-zdadosfor = 'NÃO'.
      ELSE.
        CLEAR ls_logtab-zdadosfor.
      ENDIF.


      ls_logtab-zdata = sy-datum.
      ls_logtab-zhora = sy-uzeit.
      ls_logtab-bname = sy-uname.

      MODIFY ztfi_logconcred FROM ls_logtab."#EC CI_IMUD_NESTED
      CLEAR ls_logtab.

    ENDIF.

  ENDMETHOD.


  METHOD rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.


  METHOD get_text_header.

    SELECT SINGLE
      bktxt
      FROM bkpf
      INTO rv_text
      WHERE belnr = is_creditos-documento
        AND bukrs = is_creditos-empresa
        AND gjahr = is_creditos-ano.

  ENDMETHOD.


  METHOD get_dia_util.

    DATA lv_day TYPE cind.

    DO 7 TIMES.

      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
        EXPORTING
          date                         = cv_date
          factory_calendar_id          = 'BR'
        IMPORTING
          date                         = cv_date
        EXCEPTIONS
          calendar_buffer_not_loadable = 1
          correct_option_invalid       = 2
          date_after_range             = 3
          date_before_range            = 4
          date_invalid                 = 5
          factory_calendar_not_found   = 6
          OTHERS                       = 7.

      IF sy-subrc <> 0.
        CLEAR cv_date.
        EXIT.
      ELSE.
        CALL FUNCTION 'DATE_COMPUTE_DAY'
          EXPORTING
            date = cv_date
          IMPORTING
            day  = lv_day.
      ENDIF.

      IF lv_day EQ '6' OR lv_day EQ '7'.
        ADD 1 TO cv_date.
      ELSE.
        EXIT.
      ENDIF.

    ENDDO.

  ENDMETHOD.
ENDCLASS.
