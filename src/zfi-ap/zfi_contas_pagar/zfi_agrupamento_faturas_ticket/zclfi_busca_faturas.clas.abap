"!<p><h2>Busca de faturas no SAP</h2></p> <br/>
"! Esta classe busca as faturas no SAP para comparação com as faturas do arquivo de agrupamento <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 22 de dez de 2021</p>
class ZCLFI_BUSCA_FATURAS definition
  public
  final
  create public .

public section.

  types:
      "! Fornecedores encontrados no arquivo
    BEGIN OF ty_sel_forn,
        Supplier     TYPE i_supplier-supplier,
        Suppliername TYPE i_supplier-suppliername,
        TaxNumber1   TYPE i_supplier-TaxNumber1,
      END OF ty_sel_forn .
  types:
      "! Faturas do SAP
    BEGIN OF ty_sel_faturas,
        bukrs      TYPE Bsik_view-bukrs,
        belnr      TYPE Bsik_view-belnr,
        gjahr      TYPE Bsik_view-gjahr,
        buzei      TYPE Bsik_view-buzei,
        sgtxt      TYPE Bsik_view-sgtxt,
        xblnr      TYPE Bsik_view-xblnr,
        dmbtr      TYPE Bsik_view-dmbtr,
        bldat      TYPE Bsik_view-bldat,
        zfbdt      TYPE Bsik_view-zfbdt,
        bupla      TYPE Bsik_view-bupla,
        zuonr      TYPE Bsik_View-zuonr,
        prctr      TYPE Bsik_view-prctr,
        Supplier   TYPE i_Supplier-Supplier,
        TaxNumber1 TYPE i_Supplier-TaxNumber1,
      END OF ty_Sel_Faturas .
  types:
      "! Notas fiscais em diversas formatações
    BEGIN OF ty_sel_notafiscal,
        stcd1 TYPE stcd1,
        lifnr TYPE lifnr,
        xblnr TYPE xblnr,
        nfarq type xblnr,
      END OF ty_Sel_notafiscal .
  types:
      "! Categ. tabela notas fiscais
    ty_sel_notafiscal_t   TYPE STANDARD TABLE OF ty_sel_notafiscal WITH DEFAULT KEY .
  types:
      "! Categ. tabela Faturas selecionadas no SAP
    ty_sel_Faturas_T      TYPE STANDARD TABLE OF ty_sel_faturas WITH DEFAULT KEY .
  types:
      "! Categ. tabela Fornecedores encontrados no arquivo
    ty_sel_forn_t         TYPE STANDARD TABLE OF ty_sel_forn WITH NON-UNIQUE KEY Supplier .
  types:
      "! Categ. tabela Arquivo de faturas
    ty_import_arq_t       TYPE STANDARD TABLE OF zi_fi_agrupafaturas WITH DEFAULT KEY .
  types:
      "! Categ. tabela Linhas do arquivo de faturas
    ty_import_arqlinhas_t TYPE STANDARD TABLE OF zi_fi_agrupalinhas WITH DEFAULT KEY .

      "! Classe de mensagem
  constants GC_MSGID type SY-MSGID value 'ZFI_AGRUPA_FATURAS' ##NO_TEXT.
      "! Chave bloqueio ticket
  constants GC_BLOQUEIO_TICKET type BSIK_VIEW-ZLSPR value 'T' ##NO_TEXT.
      "! Moeda
  constants GC_CURRENCY_REAIS type WAERS value 'BRL' ##NO_TEXT.
  constants:
      "! Status de processamento do Arquivo
    BEGIN OF gc_status_arq,
        pendente        TYPE ztfi_agrupfatura-status_proc VALUE '0',
        nao_processavel TYPE ztfi_agrupfatura-status_proc VALUE '1',
        disponivel      TYPE ztfi_agrupfatura-status_proc VALUE '2',
        agrupado        TYPE ztfi_agrupfatura-status_proc VALUE '3',
        erro_agrupar    TYPE ztfi_agrupfatura-status_proc VALUE '4',
      END OF gc_status_arq .
  constants:
      "! Status de processamento do Item
    BEGIN OF gc_status_proc,
        pendente TYPE ztfi_agruplinhas-status_proc VALUE '0',
        erro     TYPE ztfi_agruplinhas-status_proc VALUE '1',
        aviso    TYPE ztfi_agruplinhas-status_proc VALUE '2',
        ok       TYPE ztfi_agruplinhas-status_proc VALUE '3',
      END OF gc_status_proc .

      "! Construtor
      "! @parameter it_import_arq | Arquivo de faturas
  methods CONSTRUCTOR
    importing
      !IT_IMPORT_ARQ type TY_IMPORT_ARQ_T .
      "! Busca de faturas no SAP
      "! @parameter is_busca  | Campos preenchidos pelo usuário para busca
      "! @parameter rt_result | Mensagens de retorno
  methods EXECUTE
    importing
      !IS_BUSCA type ZI_FI_BUSCA_FATURA_AGRUP_POPUP
    returning
      value(RT_RESULT) type BAPIRET2_TAB .
      "! Método executado após chamada da função background
      "! @parameter p_task | Parametro obrigatório do método
  methods TASK_FINISH
    importing
      !P_TASK type CLIKE .
  methods REGRA_DO_ZERO
    importing
      !IV_NF type J_1BNFNUM9
      !IV_SERIE type J_1BSERIES
      !IV_LIFNR type I_SUPPLIER-SUPPLIER optional
      !IV_STCD1 type J_1BNFNUM9 optional
      !IV_NFARQ type XBLNR optional
    changing
      !CT_RESULT type TY_SEL_NOTAFISCAL_T .
  PROTECTED SECTION.
private section.

      "! Arquivo de faturas
  data LT_IMPORT_ARQ type TY_IMPORT_ARQ_T .
      "! Linhas do arquivo de faturas
  data LT_IMPORT_ARQLINHAS type TY_IMPORT_ARQLINHAS_T .
      "! Fornecedores do arquivo
  data LT_FORN type TY_SEL_FORN_T .
      "! Notas fiscais do arquivo em diversas formatações
  data LT_NOTAFISCAL type TY_SEL_NOTAFISCAL_T .
      "! Mensagem de retorno
  data LT_MSGBAPI type BAPIRET2_TAB .

  methods BUSCA_VARIACOES_FATURA
    importing
      !IT_SELFAT type TY_SEL_FATURAS_T
    changing
      !CS_DADOS type ZI_FI_AGRUPALINHAS
      !CV_ERRO type CHAR1 .
      "! Seleciona linhas do arquivo de faturas
      "! @parameter rt_result | Linhas do arquivo de faturas
  methods SELECIONA_LINHAS_ARQUIVO
    returning
      value(RT_RESULT) type TY_IMPORT_ARQLINHAS_T .
      "! Seleciona fornecedores com base nos CNPJs do arquivo de faturas
      "! @parameter rt_result | Fornecedores encontrados no arquivo
  methods SELECIONA_FORNECEDORES
    returning
      value(RT_RESULT) type TY_SEL_FORN_T .
      "! Seleciona faturas no SAP
      "! @parameter is_busca  | Campos preenchidos pelo usuário para busca de faturas
      "! @parameter rt_result | Faturas do SAP
  methods SELECIONA_FATURAS
    importing
      !IS_BUSCA type ZI_FI_BUSCA_FATURA_AGRUP_POPUP
    returning
      value(RT_RESULT) type TY_SEL_FATURAS_T .
      "! Recupera NFs do arquivo em vários formatos
      "! @parameter rt_result | Notas fiscais do arquivo
  methods RECUPERA_NOTA_FISCAL
    returning
      value(RT_RESULT) type TY_SEL_NOTAFISCAL_T .
ENDCLASS.



CLASS ZCLFI_BUSCA_FATURAS IMPLEMENTATION.


  METHOD execute.

    DATA:
      lt_grava_arqlinhas TYPE STANDARD TABLE OF ztfi_agruplinhas,
      lt_grava_arquivo   TYPE STANDARD TABLE OF ztfi_agrupfatura.

    DATA:
      ls_arquivo TYPE zsfi_agrupa_fatura_arquivo.

    DATA:
      lv_erro TYPE char1.

    DATA(lt_dados_arquivo) = me->seleciona_linhas_arquivo( ).

    DATA(lt_sel_faturas) = me->seleciona_faturas( is_busca ).

    DATA(lt_forn) = me->seleciona_fornecedores( ).

    DATA(lt_notafiscal)  = me->recupera_nota_fiscal( ).

    SORT:
    lt_sel_faturas BY supplier xblnr,
*    lt_notafiscal BY lifnr xblnr,
    lt_forn BY taxnumber1.

    LOOP AT lt_dados_arquivo ASSIGNING FIELD-SYMBOL(<fs_dados_arquivo>).

      CLEAR lv_erro.

      READ TABLE lt_forn ASSIGNING FIELD-SYMBOL(<fs_forn>)
          WITH KEY taxnumber1 = <fs_dados_arquivo>-cnpj
          BINARY SEARCH.

      IF sy-subrc EQ 0.

        <fs_dados_arquivo>-supplier = <fs_forn>-supplier.

      ELSE.

        " Fornecedor não cadastrado
        <fs_dados_arquivo>-itemstatus = gc_status_proc-erro.

        MESSAGE ID gc_msgid TYPE if_xo_const_message=>error NUMBER 011
            INTO <fs_dados_arquivo>-msg.

        CONTINUE.

      ENDIF.


      READ TABLE lt_sel_faturas ASSIGNING FIELD-SYMBOL(<fs_fatura>)
          WITH KEY supplier = <fs_dados_arquivo>-supplier
                   xblnr = <fs_dados_arquivo>-notafiscal
          BINARY SEARCH.

      IF sy-subrc EQ 0.

        <fs_dados_arquivo>-companycode          = <fs_fatura>-bukrs.
        <fs_dados_arquivo>-accountingdocument   = <fs_fatura>-belnr.
        <fs_dados_arquivo>-accountingitem       = <fs_fatura>-buzei.
        <fs_dados_arquivo>-fiscalyear           = <fs_fatura>-gjahr.
        <fs_dados_arquivo>-valornffatura        = <fs_fatura>-dmbtr.
        <fs_dados_arquivo>-dtemissaofatura      = <fs_fatura>-bldat.
        <fs_dados_arquivo>-duedate              = <fs_fatura>-zfbdt.
        <fs_dados_arquivo>-assignment           = <fs_fatura>-zuonr.
        <fs_dados_arquivo>-businessplace        = <fs_fatura>-bupla.
        <fs_dados_arquivo>-profitcenter         = <fs_fatura>-prctr.
        <fs_dados_arquivo>-itemtext             = <fs_fatura>-sgtxt.

      ELSE.

        busca_variacoes_fatura( EXPORTING it_selfat = lt_sel_faturas
                                CHANGING  cs_dados  = <fs_dados_arquivo>
                                          cv_erro   = lv_erro ).

        IF lv_erro IS NOT INITIAL.

          "Fatura não encontrada
          <fs_dados_arquivo>-itemstatus = gc_status_proc-erro.

          MESSAGE ID gc_msgid TYPE if_xo_const_message=>error NUMBER 012
              INTO <fs_dados_arquivo>-msg.

          CONTINUE.

        ENDIF.

      ENDIF.

      IF <fs_dados_arquivo>-valornfarquivo NE <fs_dados_arquivo>-valornffatura.

        " Divergência de valores
        <fs_dados_arquivo>-itemstatus = gc_status_proc-aviso.

        MESSAGE ID gc_msgid TYPE if_xo_const_message=>error NUMBER 013
            INTO <fs_dados_arquivo>-msg.

        CONTINUE.

      ENDIF.

      " Divergência de datas
      IF <fs_dados_arquivo>-dtemissaoarquivo NE <fs_dados_arquivo>-dtemissaoarquivo.

        <fs_dados_arquivo>-itemstatus = gc_status_proc-aviso.

        MESSAGE ID gc_msgid TYPE if_xo_const_message=>error NUMBER 014
            INTO <fs_dados_arquivo>-msg.

        CONTINUE.

      ENDIF.

      <fs_dados_arquivo>-itemstatus = gc_status_proc-ok.

    ENDLOOP.


    lt_grava_arqlinhas = VALUE #( FOR ls_dados_arquivo IN lt_dados_arquivo

            (   id_arquivo            = ls_dados_arquivo-idarquivo
                id                    = ls_dados_arquivo-id
                bukrs                 = ls_dados_arquivo-companycode
                arq_data              = ls_dados_arquivo-dataarquivo
                lifnr                 = ls_dados_arquivo-supplier
                xblnr1                = ls_dados_arquivo-notafiscal
                tipo_nf               = ls_dados_arquivo-tiponf
                chave_acesso          = ls_dados_arquivo-chaveacesso
                cnpj                  = ls_dados_arquivo-cnpj
                zfbdt                 = ls_dados_arquivo-duedate
                status_proc           = ls_dados_arquivo-itemstatus
                arq_dmbtr             = ls_dados_arquivo-valornfarquivo
                doc_dmbtr             = ls_dados_arquivo-valornffatura
                waers                 = gc_currency_reais
                belnr                 = ls_dados_arquivo-accountingdocument
                gjahr                 = ls_dados_arquivo-fiscalyear
                buzei                 = ls_dados_arquivo-accountingitem
                arq_bldat             = ls_dados_arquivo-dtemissaoarquivo
                doc_bldat             = ls_dados_arquivo-dtemissaofatura
                zuonr                 = ls_dados_arquivo-assignment
                bupla                 = ls_dados_arquivo-businessplace
                prctr                 = ls_dados_arquivo-profitcenter
                sgtxt                 = ls_dados_arquivo-itemtext
                msg                   = ls_dados_arquivo-msg
                forn_agrupador        = ls_dados_arquivo-fornagrupador
                fatura_agrupada       = ls_dados_arquivo-faturaagrupada
                ref_agrupada          = ls_dados_arquivo-refagrupada
                created_by            = ls_dados_arquivo-createdby
                created_at            = ls_dados_arquivo-createdat
                last_changed_by       = ls_dados_arquivo-lastchangedby
                last_changed_at       = ls_dados_arquivo-lastchangedat
                local_last_changed_at = ls_dados_arquivo-locallastchangedat
            )
        ).

    " Status do arquivo
    SORT lt_dados_arquivo BY itemstatus.
    READ TABLE lt_dados_arquivo TRANSPORTING NO FIELDS
        WITH KEY itemstatus = gc_status_proc-erro
        BINARY SEARCH.

    IF sy-subrc EQ 0.
      DATA(lv_status_arquivo) = gc_status_arq-nao_processavel.
    ELSE.
      lv_status_arquivo = gc_status_arq-disponivel.
    ENDIF.

    lt_grava_arquivo = VALUE #( FOR ls_import_arq IN me->lt_import_arq
    (
      id_arquivo            = ls_import_arq-idarquivo
      arquivo               = ls_import_arq-arquivo
      data                  = ls_import_arq-dataimportacao
      hora                  = ls_import_arq-horaimportacao
      status_proc           = lv_status_arquivo
      bukrs                 = is_busca-selcompanycode
      created_by            = ls_import_arq-createdby
      created_at            = ls_import_arq-createdat
      last_changed_by       = ls_import_arq-lastchangedby
      last_changed_at       = ls_import_arq-lastchangedat
      local_last_changed_at = ls_import_arq-locallastchangedat
     )
    ).

    rt_result = VALUE #( ( type = if_xo_const_message=>success
                           id = gc_msgid
                           number = 003 )
                ).

    CALL FUNCTION 'ZFMFI_UPD_ARQ_AGRUPA_FATURAS'
      STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
      EXPORTING
        it_agrupa_fatura = lt_grava_arquivo
        it_agrupa_linhas = lt_grava_arqlinhas
      TABLES
        et_mensagens     = me->lt_msgbapi.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL me->lt_msgbapi IS NOT INITIAL.

  ENDMETHOD.


  METHOD constructor.
    me->lt_import_arq = it_import_arq.
  ENDMETHOD.


  METHOD seleciona_fornecedores.

    TYPES:
      BEGIN OF ty_taxnum,
        taxnumber1 TYPE i_supplier-TaxNumber1,
      END OF ty_taxnum.

    DATA:
      lt_taxnum TYPE STANDARD TABLE OF ty_taxnum.

    IF me->lt_forn IS NOT INITIAL.

      rt_result = me->lt_forn.
      RETURN.

    ENDIF.

    DATA(lt_sel_forn) = me->lt_import_arqlinhas.

    SORT lt_sel_forn BY cnpj.
    DELETE ADJACENT DUPLICATES FROM lt_sel_forn COMPARING cnpj.
    LOOP AT lt_sel_forn ASSIGNING FIELD-SYMBOL(<fs_sel_forn>).

      APPEND INITIAL LINE TO lt_taxnum ASSIGNING FIELD-SYMBOL(<fs_taxnum>).
      IF <fs_taxnum> IS ASSIGNED.

        <fs_taxnum>-taxnumber1 = replace( val   = <fs_sel_forn>-cnpj
                                          regex = '[^\d]'
                                          with  = ' '
                                          occ   = 0 ).

      ENDIF.

    ENDLOOP.

    SELECT
        Supplier~Supplier,
        Supplier~SupplierName,
        Supplier~TaxNumber1
    FROM i_supplier AS Supplier
    FOR ALL ENTRIES IN @lt_taxnum
    WHERE Supplier~TaxNumber1 EQ @lt_taxnum-taxnumber1
    INTO TABLE @DATA(lt_forn).

    IF sy-subrc EQ 0.
      rt_result = me->lt_forn = lt_forn.
    ENDIF.


  ENDMETHOD.


  METHOD seleciona_faturas.

    DATA(lt_busca) = me->recupera_nota_fiscal( ).

    IF lt_busca IS INITIAL.
      RETURN.
    ENDIF.

    SELECT
        Bsik~bukrs,
        Bsik~belnr,
        Bsik~gjahr,
        Bsik~buzei,
        Bsik~sgtxt,
        Bsik~xblnr,
        Bsik~dmbtr,
        Bsik~bldat,
        Bsik~zfbdt,
        Bsik~bupla,
        Bsik~zuonr,
        Bsik~prctr,
        Supplier~Supplier,
        Supplier~TaxNumber1
    FROM bsik_view AS Bsik
        INNER JOIN i_supplier AS Supplier
            ON Bsik~lifnr = Supplier~Supplier
    FOR ALL ENTRIES IN @lt_busca
    WHERE Bsik~bukrs          EQ @is_busca-selcompanycode
      AND Supplier~Supplier   EQ @lt_busca-lifnr
      AND Bsik~Xblnr          EQ @lt_busca-xblnr
      AND Bsik~zlspr          EQ @gc_bloqueio_ticket
    INTO TABLE @DATA(lt_faturas).

    IF sy-subrc EQ 0.
      rt_Result = lt_Faturas.
    ENDIF.

  ENDMETHOD.


  METHOD recupera_nota_fiscal.

    CONSTANTS:
      lc_nf_separador TYPE c VALUE `-`.

    DATA:
      lv_nf_c    TYPE j_1bnfnum9,
      lv_serie_c TYPE j_1bseries,
      lv_serie_o TYPE j_1bseries,
      lv_nf_s    TYPE j_1bnfnum9,
      lv_serie_s TYPE j_1bseries.

    IF me->lt_notafiscal IS NOT INITIAL.

      rt_result = me->lt_notafiscal.
      RETURN.

    ENDIF.

    DATA(lt_arquivo) = me->lt_import_arqlinhas.

    DATA(lt_forn) = me->seleciona_fornecedores(  ).

    SORT lt_forn BY taxnumber1.

    LOOP AT lt_arquivo ASSIGNING FIELD-SYMBOL(<fs_arquivo>).

      READ TABLE lt_forn ASSIGNING FIELD-SYMBOL(<fs_forn>)
          WITH KEY taxnumber1 = <fs_arquivo>-cnpj
          BINARY SEARCH.

      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

      SPLIT <fs_arquivo>-notafiscal AT '-' INTO lv_nf_c lv_serie_c.

      lv_serie_o = lv_serie_c.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_nf_c
        IMPORTING
          output = lv_nf_c.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lv_nf_c
        IMPORTING
          output = lv_nf_s.

      APPEND INITIAL LINE TO me->lt_notafiscal ASSIGNING FIELD-SYMBOL(<fs_result>).
      <fs_result>-lifnr = <fs_forn>-supplier.
      <fs_result>-stcd1 = lv_nf_c.
      <fs_result>-xblnr = <fs_arquivo>-notafiscal.
      <fs_result>-nfarq = <fs_arquivo>-notafiscal.

      " Tratativas somente com o campo série preenchido
      IF NOT lv_serie_c IS INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_serie_c
          IMPORTING
            output = lv_serie_c.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lv_serie_c
          IMPORTING
            output = lv_serie_s.

        " NF com zeros a esquerda / Série com zeros
        APPEND INITIAL LINE TO me->lt_notafiscal ASSIGNING <fs_result>.
        <fs_result>-lifnr = <fs_forn>-supplier.
        <fs_result>-stcd1 = lv_nf_c.
        <fs_result>-xblnr = lv_nf_c && lc_nf_separador && lv_serie_c.
        <fs_result>-nfarq = <fs_arquivo>-notafiscal.

        " NF com zeros a esquerda / Série sem zeros
        APPEND INITIAL LINE TO me->lt_notafiscal ASSIGNING <fs_result>.
        <fs_result>-lifnr = <fs_forn>-supplier.
        <fs_result>-stcd1 = lv_nf_c.
        <fs_result>-xblnr = lv_nf_c && lc_nf_separador && lv_serie_s.
        <fs_result>-nfarq = <fs_arquivo>-notafiscal.

        " NF sem zeros a esquerda / Série com zeros
        APPEND INITIAL LINE TO me->lt_notafiscal ASSIGNING <fs_result>.
        <fs_result>-lifnr = <fs_forn>-supplier.
        <fs_result>-stcd1 = lv_nf_c.
        <fs_result>-xblnr = lv_nf_s && lc_nf_separador && lv_serie_c.
        <fs_result>-nfarq = <fs_arquivo>-notafiscal.

        " NF sem zeros a esquerda / Série sem zeros
        APPEND INITIAL LINE TO me->lt_notafiscal ASSIGNING <fs_result>.
        <fs_result>-lifnr = <fs_forn>-supplier.
        <fs_result>-stcd1 = lv_nf_c.
        <fs_result>-xblnr = lv_nf_s && lc_nf_separador && lv_serie_s.
        <fs_result>-nfarq = <fs_arquivo>-notafiscal.

      ENDIF.

      " NF sem série com zeros a esquerda
      APPEND INITIAL LINE TO me->lt_notafiscal ASSIGNING <fs_result>.
      <fs_result>-lifnr = <fs_forn>-supplier.
      <fs_result>-stcd1 = lv_nf_c.
      <fs_result>-xblnr = lv_nf_c.
      <fs_result>-nfarq = <fs_arquivo>-notafiscal.

      " NF sem série sem zeros a esquerda
      APPEND INITIAL LINE TO me->lt_notafiscal ASSIGNING <fs_result>.
      <fs_result>-lifnr = <fs_forn>-supplier.
      <fs_result>-stcd1 = lv_nf_c.
      <fs_result>-xblnr = lv_nf_s.
      <fs_result>-nfarq = <fs_arquivo>-notafiscal.

      regra_do_zero( EXPORTING iv_nf     = lv_nf_s
                               iv_serie  = lv_serie_o
                               iv_lifnr  = <fs_forn>-supplier
                               iv_stcd1  = lv_nf_c
                               iv_nfarq  = <fs_arquivo>-notafiscal
                     CHANGING  ct_result = lt_notafiscal ).

    ENDLOOP.

    SORT me->lt_notafiscal BY lifnr nfarq stcd1 xblnr.
    DELETE ADJACENT DUPLICATES FROM me->lt_notafiscal COMPARING lifnr nfarq stcd1 xblnr.

    rt_result = me->lt_notafiscal.

  ENDMETHOD.


  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_UPD_ARQ_AGRUPA_FATURAS'
      TABLES
        et_mensagens = me->lt_msgbapi.

  ENDMETHOD.


  METHOD seleciona_linhas_arquivo.

    DATA(lt_arquivo) = me->lt_import_arq.
    IF lt_arquivo IS INITIAL.
      RETURN.
    ENDIF.

    SELECT *
    FROM zi_fi_agrupalinhas
    FOR ALL ENTRIES IN @lt_arquivo
    WHERE IdArquivo EQ @lt_arquivo-IdArquivo
    ORDER BY PRIMARY KEY
    INTO TABLE @me->lt_import_arqlinhas.

    IF sy-subrc EQ 0.
      rt_Result = me->lt_import_arqlinhas.
    ENDIF.

  ENDMETHOD.


  METHOD busca_variacoes_fatura.

    cv_erro = abap_true.

    READ TABLE lt_notafiscal WITH KEY lifnr = cs_dados-supplier
                                      nfarq = cs_dados-notafiscal
                             BINARY SEARCH
                             TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

      LOOP AT lt_notafiscal ASSIGNING FIELD-SYMBOL(<fs_nf>) FROM sy-tabix.

        IF <fs_nf>-lifnr NE cs_dados-supplier OR <fs_nf>-nfarq NE cs_dados-notafiscal.
          EXIT.
        ENDIF.

        READ TABLE it_selfat ASSIGNING FIELD-SYMBOL(<fs_fatura>)
            WITH KEY supplier = cs_dados-supplier
                     xblnr    = <fs_nf>-xblnr
            BINARY SEARCH.

        IF sy-subrc EQ 0.

          cs_dados-companycode          = <fs_fatura>-bukrs.
          cs_dados-accountingdocument   = <fs_fatura>-belnr.
          cs_dados-accountingitem       = <fs_fatura>-buzei.
          cs_dados-fiscalyear           = <fs_fatura>-gjahr.
          cs_dados-valornffatura        = <fs_fatura>-dmbtr.
          cs_dados-dtemissaofatura      = <fs_fatura>-bldat.
          cs_dados-duedate              = <fs_fatura>-zfbdt.
          cs_dados-assignment           = <fs_fatura>-zuonr.
          cs_dados-businessplace        = <fs_fatura>-bupla.
          cs_dados-profitcenter         = <fs_fatura>-prctr.
          cs_dados-itemtext             = <fs_fatura>-sgtxt.

          CLEAR cv_erro.
          RETURN.

        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD regra_do_zero.

    CONSTANTS: lc_max TYPE i VALUE '9'.

    DATA: lv_times TYPE i,
          lv_nf    TYPE j_1bnfnum9,
          lv_pos   TYPE i.

    DATA(lv_len) = strlen( iv_nf ).

    lv_times = lc_max - lv_len.
    lv_nf    = iv_nf.
    SHIFT lv_nf RIGHT DELETING TRAILING space.
    lv_pos   = lv_times - 1.

    DO lv_times TIMES.

      lv_nf+lv_pos(1) = 0.

      APPEND INITIAL LINE TO ct_result ASSIGNING FIELD-SYMBOL(<fs_res>).
      <fs_res>-xblnr = lv_nf.
      <fs_res>-stcd1 = iv_stcd1.
      <fs_res>-lifnr = iv_lifnr.
      <fs_res>-nfarq = iv_nfarq.

      SHIFT <fs_res>-xblnr LEFT DELETING LEADING space.

      IF iv_serie IS NOT INITIAL.
        APPEND INITIAL LINE TO ct_result ASSIGNING FIELD-SYMBOL(<fs_res1>).
        <fs_res1>-xblnr = lv_nf && '-' && iv_serie.
        <fs_res1>-stcd1 = iv_stcd1.
        <fs_res1>-lifnr = iv_lifnr.
        <fs_res1>-nfarq = iv_nfarq.

        SHIFT <fs_res1>-xblnr LEFT DELETING LEADING space.

      ENDIF.

      SUBTRACT 1 FROM lv_pos.

    ENDDO.

  ENDMETHOD.
ENDCLASS.
