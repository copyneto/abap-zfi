"!<p><h2>Agrupamento de faturas ticket</h2></p> <br/>
"! Esta classe é responsável pelo agrupamento de faturas <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 22 de dez de 2021</p>
CLASS zclfi_agrupa_faturas DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      "! Moeda
      gc_currency_reais        TYPE waers VALUE 'BRL',
      "! Chave de lançamento para fatura agrupada
      gc_chave_lancto          TYPE newbs VALUE '31',
      "! Item da fatura agrupada
      gc_buzei                 TYPE buzei VALUE '001',
      "! Item usado para desconto
      gc_buzei_desconto        TYPE buzei VALUE '002',
      "! Texto do item - desconto
      gc_txt_desconto          TYPE sgtxt VALUE 'VALOR DESCONTO',
      "! Chave de lançamento para desconto
      gc_chave_lancto_desconto TYPE newbs VALUE '50',

      "! Classe de mensagem
      gc_msgid                 TYPE sy-msgid VALUE 'ZFI_AGRUPA_FATURAS'.

    TYPES:
      "! Dados do fornecedor agrupador
      BEGIN OF ty_forn_Agrupador,
        FornAgrupador TYPE  zi_fi_forn_agrupador-FornAgrupador,
        CompanyCode   TYPE  zi_fi_forn_agrupador-CompanyCode,
        AccountNumber TYPE  zi_fi_forn_agrupador-AccountNumber,
        DocumentType  TYPE  zi_fi_forn_agrupador-DocumentType,
      END OF  ty_forn_agrupador.

    TYPES:
      "! Arquivo de faturas
      ty_import_arq_t       TYPE STANDARD TABLE OF zi_fi_agrupafaturas WITH DEFAULT KEY,
      "! Dados do arquivo de faturas
      ty_import_arqlinhas_t TYPE STANDARD TABLE OF zi_fi_agrupalinhas WITH DEFAULT KEY.

    METHODS:
      "! Construtor
      "! @parameter it_import_arq | Dados do arquivo de faturas
      constructor
        IMPORTING
          it_import_arq TYPE ty_import_arq_t,

      "! Executa agrupamento de faturas
      "! @parameter is_campos_popup | Campos preenchidos pelo usuário
      "! @parameter rt_msg          | Mensagens de retorno
      execute
        IMPORTING
                  !is_campos_popup TYPE zi_fi_agrupa_faturas_popup
        RETURNING VALUE(rt_msg)    TYPE bapiret2_t,

      "! Método executado após chamada da função background
      "! @parameter p_task | Parametro obrigatório do método
      task_finish
        IMPORTING
          !p_task TYPE clike.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      "! Arquivo de faturas
      lt_import_arq       TYPE ty_import_arq_t,
      "! Dados do arquivo de faturas
      lt_import_arqlinhas TYPE ty_import_arqlinhas_t,
      "! Dados para criação da fatura agrupada na bapi FB05
      lt_ftpost           TYPE TABLE OF ftpost,
      "! Dados para compensação na chamada na bapi FB05
      lt_ftclear          TYPE TABLE OF ftclear,
      "! Mensagens de retorno
      lt_msgbapi          TYPE bapiret2_tab.

    DATA:
      "! Dados do fornecedor agrupador
      ls_forn_agrupador TYPE ty_forn_agrupador.

    METHODS:

      "! Seleciona linhas do arquivo
      "! @parameter rt_result | Linhas do arquivo
      seleciona_linhas_arquivo
        RETURNING VALUE(rt_result) TYPE ty_import_arqlinhas_t,

      "! Preenche cabeçalho da fatura agrupada
      "! @parameter is_campos_popup | Campos preenchidos pelo usuário
      preenche_cabecalho
        IMPORTING !is_campos_popup TYPE zi_fi_agrupa_faturas_popup,

      "! Preenche item da fatura agrupada
      "! @parameter is_campos_popup | Campos preenchidos pelo usuário
      preenche_itens
        IMPORTING !is_campos_popup TYPE zi_fi_agrupa_faturas_popup,

      "! Preenche documentos que serão compensados
      preenche_doc_compensar,

      "! Calcula diferença de valores dentro do limite do desconto cadastrado no Fornecedor agrupador
      "! @parameter rv_result | Desconto em R$
      calcula_desconto
        RETURNING VALUE(rv_result) TYPE wrbtr,

      "! Valida preenchimento dos campos da BAPI
      "! @parameter rv_error | (x) Erro
      valida_preenchimento
        RETURNING VALUE(rv_error) TYPE abap_bool,

      "! Exibe erros e para o processo
      "! @parameter rv_error | (x) Há Erros
      busca_erros
        RETURNING VALUE(rv_error) TYPE abap_bool,

      "! Seleciona dados do fornecedor agrupador
      "! @parameter iv_forn_agrupador | ID Fornecedor agrupador
      "! @parameter iv_companycode    | ID empresa
      "! @parameter rs_result         | Dados do fornecedor agrupador
      seleciona_forn_agrupador
        IMPORTING
                  !iv_forn_agrupador TYPE lifnr
                  !iv_companycode    TYPE bukrs
        RETURNING VALUE(rs_result)   TYPE ty_forn_agrupador,

      "! Converte data para formato DD/MM/AAAA
      "! @parameter iv_date   | Data formato AAAAMMDD
      "! @parameter rv_Result | Data em formato DD/MM/AAAA
      conv_date
        IMPORTING
                  iv_Date          TYPE bldat
        RETURNING VALUE(rv_Result) TYPE char10,

      "! Converte valor para formato XXX.XXX,XX
      "! @parameter iv_Value  | Valor no formato XXX,XXX.XX
      "! @parameter rv_Result | Valor no formato XXX.XXX,XX
      conv_value
        IMPORTING
                  iv_Value         TYPE wrbtr
        RETURNING VALUE(rv_Result) TYPE char20.

ENDCLASS.



CLASS zclfi_agrupa_faturas IMPLEMENTATION.

  METHOD execute.

    CONSTANTS:
      lc_background_mode          TYPE rfpdo-allgazmd VALUE 'N',
      lc_SGFUNCT                  TYPE rfipi-sgfunct  VALUE 'C',
      lc_auglv_transf_compensacao TYPE t041a-auglv    VALUE 'UMBUCHNG',
      lc_tcode                    TYPE sy-tcode       VALUE 'FB05'.

    DATA:
      lv_msgid TYPE sy-msgid,
      lv_msgno TYPE sy-msgno,
      lv_msgty TYPE sy-msgty,
      lv_msgv1 TYPE sy-msgv1,
      lv_msgv2 TYPE sy-msgv2,
      lv_msgv3 TYPE sy-msgv3,
      lv_msgv4 TYPE sy-msgv4.

    me->seleciona_linhas_arquivo( ).

    me->seleciona_forn_agrupador(
      EXPORTING
        iv_forn_agrupador = is_campos_popup-selfornagrupa
        iv_companycode    = is_campos_popup-selcompanycode
    ).

    me->preenche_cabecalho( is_campos_popup ).

    me->preenche_itens( is_campos_popup ).

    me->preenche_doc_compensar( ).

    me->valida_preenchimento( ).

    IF me->busca_erros( ) EQ abap_true.

      rt_msg = me->lt_msgbapi.
      RETURN.

    ENDIF.

    DATA(ls_arquivo) = me->lt_import_arq[ 1 ].

    "Executa processo de agrupamento e compensação
    CALL FUNCTION 'ZFMFI_AGRUPA_FATURAS'
      STARTING NEW TASK 'BACKGROUND' CALLING task_finish ON END OF TASK
      EXPORTING
        iv_user         = sy-uname
        iv_idarquivo    = ls_arquivo-IdArquivo
        is_campos_popup = is_campos_popup
        it_ftpost       = me->lt_ftpost
        it_ftclear      = me->lt_ftclear
      TABLES
        et_mensagens    = me->lt_msgbapi.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL me->lt_msgbapi IS NOT INITIAL.

  ENDMETHOD.

  METHOD conv_date.

    IF iv_date IS INITIAL.

      rv_result = space.

    ELSE.

      WRITE iv_date TO rv_result DD/MM/YYYY.
      SHIFT rv_result LEFT DELETING LEADING space.

    ENDIF.

  ENDMETHOD.

  METHOD conv_value.

    WRITE iv_value TO rv_result CURRENCY gc_currency_reais.
    SHIFT rv_result LEFT DELETING LEADING space.

  ENDMETHOD.

  METHOD preenche_cabecalho.

    CONSTANTS:
      lc_HEADER                   TYPE stype_pi VALUE 'K'.

    CONSTANTS:
      BEGIN OF lc_bapi_fields,
        company       TYPE ftpost-fnam VALUE 'BKPF-BUKRS',
        posting_date  TYPE ftpost-fnam VALUE 'BKPF-BUDAT',
        document_date TYPE ftpost-fnam VALUE 'BKPF-BLDAT',
        doctype       TYPE ftpost-fnam VALUE 'BKPF-BLART',
        currency      TYPE ftpost-fnam VALUE 'BKPF-WAERS',
        doctext       TYPE ftpost-fnam VALUE 'BKPF-BKTXT',
        notafiscal    TYPE ftpost-fnam VALUE 'BKPF-XBLNR',
      END OF lc_bapi_fields.

    IF me->busca_erros( ) EQ abap_true.
      RETURN.
    ENDIF.

    me->lt_ftpost = VALUE #(
                            (   stype = lc_header
                                count = 1
                                fnam  = lc_bapi_fields-company
                                fval  = CONV bdc_fval( is_campos_popup-selcompanycode )
                             )

                            (   stype = lc_header
                                count = 1
                                fnam  = lc_bapi_fields-document_date
                                fval  = CONV bdc_fval( conv_date( is_campos_popup-seldocumentdate ) )
                             )

                            (   stype = lc_header
                                count = 1
                                fnam  = lc_bapi_fields-posting_date
                                fval  = CONV bdc_fval( conv_date( is_campos_popup-selpostingdate ) )
                             )

                            (   stype = lc_header
                                count = 1
                                fnam  = lc_bapi_fields-doctype
                                fval  = CONV bdc_fval( me->ls_forn_agrupador-documenttype )
                             )

                            (   stype = lc_header
                                count = 1
                                fnam  = lc_bapi_fields-currency
                                fval  = CONV bdc_fval( gc_currency_reais )
                             )


                            (   stype = lc_header
                                count = 1
                                fnam  = lc_bapi_fields-notafiscal
                                fval  = CONV bdc_fval( is_campos_popup-selreference )
                             )

    ).

  ENDMETHOD.

  METHOD preenche_doc_compensar.

    CONSTANTS:
      lc_conta_forn(1) TYPE c     VALUE 'K',
      lc_selfd(5)      TYPE c     VALUE 'BELNR'.

    IF me->busca_erros( ) EQ abap_true.
      RETURN.
    ENDIF.

    LOOP AT me->lt_import_arqlinhas ASSIGNING FIELD-SYMBOL(<fs_faturas_a_agrupar>).

      APPEND INITIAL LINE TO me->lt_ftclear ASSIGNING FIELD-SYMBOL(<fs_ftclear>).

      <fs_ftclear> = VALUE #(
                          agbuk  = <fs_faturas_a_agrupar>-companycode
                          agkoa  = lc_conta_forn
                          agkon  = <fs_faturas_a_agrupar>-supplier
                          agums  = space
                          selfd  = lc_selfd
                          xnops  = abap_true
                          selvon = <fs_faturas_a_agrupar>-AccountingDocument &&
                                   <fs_faturas_a_agrupar>-fiscalyear &&
                                   <fs_faturas_a_agrupar>-accountingitem
      ).

    ENDLOOP.

  ENDMETHOD.

  METHOD preenche_itens.

    CONSTANTS:
       lc_item TYPE stype_pi VALUE 'P'.

    CONSTANTS:
      BEGIN OF lc_bapi_fields,
        newbs TYPE  ftpost-fnam VALUE 'RF05A-NEWBS',
        hkont TYPE  ftpost-fnam VALUE 'BSEG-HKONT',
        bupla TYPE  ftpost-fnam VALUE 'BSEG-BUPLA',
        wrbtr TYPE  ftpost-fnam VALUE 'BSEG-WRBTR',
        zuonr TYPE  ftpost-fnam VALUE 'BSEG-ZUONR',
        sgtxt TYPE  ftpost-fnam VALUE 'BSEG-SGTXT',
        zfbdt TYPE  ftpost-fnam VALUE 'BSEG-ZFBDT',
        zterm TYPE  ftpost-fnam VALUE 'BSEG-ZTERM',
        zbd1t TYPE  ftpost-fnam VALUE 'BSEG-ZBD1T',
        zbd2t TYPE  ftpost-fnam VALUE 'BSEG-ZBD2T',
        zbd3t TYPE  ftpost-fnam VALUE 'BSEG-ZBD3T',
        kostl TYPE  ftpost-fnam VALUE 'COBL-KOSTL',
        newko TYPE  ftpost-fnam VALUE 'RF05A-NEWKO',
      END OF lc_bapi_fields.

    DATA:
      lv_valor_desconto TYPE wrbtr,
      lv_valor_agrupado TYPE wrbtr.

    IF me->busca_erros( ) EQ abap_true.
      RETURN.
    ENDIF.

    lv_valor_desconto = is_campos_popup-seldesconto.

    READ TABLE me->lt_import_arqlinhas ASSIGNING FIELD-SYMBOL(<fs_item>) INDEX 1.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    lv_valor_agrupado = REDUCE bseg-wrbtr(
                            INIT lv_x = CONV bseg-wrbtr( 0 )
                            FOR ls_itens IN me->lt_import_arqlinhas
                            NEXT lv_x = lv_x + ls_itens-ValorNFFatura
                        ).

    lv_valor_agrupado = ( lv_valor_agrupado - lv_valor_desconto ).

    me->lt_ftpost = VALUE #( BASE lt_ftpost
                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_fields-newbs
                                fval = CONV bdc_fval( gc_chave_lancto )
                            )


                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_fields-hkont
                                fval = CONV bdc_fval( is_campos_popup-selfornagrupa )
                            )

                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_fields-bupla
                                fval = CONV bdc_fval( <fs_item>-BusinessPlace )
                            )


                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_fields-wrbtr
                                fval = CONV bdc_fval( conv_value( lv_valor_agrupado ) )
                            )

                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_fields-zuonr
                                fval = CONV bdc_fval( <fs_item>-assignment )
                            )

                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_fields-sgtxt
                                fval = CONV bdc_fval( <fs_item>-itemtext )
                            )

                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_fields-zfbdt
                                fval = CONV bdc_fval( conv_date( is_campos_popup-selduedate ) )
                            )

                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_Fields-zterm
                                fval = CONV bdc_fval( abap_false )
                            )

                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_Fields-zbd1t
                                fval = CONV bdc_fval( abap_false )
                            )


                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_Fields-zbd2t
                                fval = CONV bdc_fval( abap_false )
                            )


                            (   stype = lc_item
                                count = CONV count_pi( gc_buzei )
                                fnam = lc_bapi_Fields-zbd3t
                                fval = CONV bdc_fval( abap_false )
                            )

                ).

    " Adiciona desconto
    IF lv_valor_desconto IS NOT INITIAL.

      me->lt_ftpost = VALUE #( BASE lt_ftpost

                               (  stype = lc_item
                                  count = CONV count_pi( gc_buzei_desconto )
                                  fnam = lc_bapi_fields-bupla
                                  fval = CONV bdc_fval( <fs_item>-BusinessPlace )
                               )

                               ( stype = lc_item
                                 count = CONV count_pi( gc_buzei_desconto )
                                 fnam = lc_bapi_fields-sgtxt
                                 fval = CONV bdc_fval( gc_txt_desconto )
                               )

                              (   stype = lc_item
                                  count = CONV count_pi( gc_buzei_desconto )
                                  fnam = lc_bapi_fields-wrbtr
                                  fval = CONV bdc_fval( conv_value( lv_valor_desconto ) )
                              )

                              (   stype = lc_item
                                  count = CONV count_pi( gc_buzei_desconto )
                                  fnam = lc_bapi_fields-newko
                                  fval = CONV bdc_fval( me->ls_forn_agrupador-accountnumber )
                              )

                              (   stype = lc_item
                                  count = CONV count_pi( gc_buzei_desconto )
                                  fnam = lc_bapi_fields-kostl
                                  fval = CONV bdc_fval( is_campos_popup-selcostcenter )
                              )

                             (   stype = lc_item
                                 count = CONV count_pi( gc_buzei_desconto )
                                 fnam = lc_bapi_fields-newbs
                                 fval = CONV bdc_fval( gc_chave_lancto_desconto )
                             )
                      ).

    ENDIF.

  ENDMETHOD.

  METHOD valida_preenchimento.

    IF me->lt_ftclear IS INITIAL
        OR me->lt_ftpost IS INITIAL.

      APPEND VALUE #(  id = gc_msgid
                 type       = if_xo_const_message=>error
                 number     = 005 ) TO me->lt_msgbapi.

    ENDIF.

  ENDMETHOD.

  METHOD task_finish.

    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_AGRUPA_FATURAS'
      TABLES
        et_mensagens = me->lt_msgbapi.

  ENDMETHOD.

  METHOD constructor.
    me->lt_import_arq = it_import_arq.
  ENDMETHOD.

  METHOD seleciona_forn_agrupador.

    IF me->busca_erros( ) EQ abap_true.
      RETURN.
    ENDIF.

    IF me->ls_forn_agrupador IS NOT INITIAL.

      rs_result = me->ls_forn_agrupador.
      RETURN.

    ENDIF.

    SELECT
        Agrupador~FornAgrupador,
        Agrupador~CompanyCode,
        Agrupador~AccountNumber,
        Agrupador~DocumentType
    FROM zi_fi_forn_agrupador AS Agrupador
    WHERE FornAgrupador EQ @iv_forn_agrupador
      AND CompanyCode EQ @iv_companycode
      INTO TABLE @DATA(lt_forn_agrupador).

    IF sy-subrc NE 0.

      APPEND VALUE #(  id = gc_msgid
                       type       = if_xo_const_message=>error
                       number     = 009
                       message_v1 = iv_forn_agrupador
                     ) TO me->lt_msgbapi.

      RETURN.

    ENDIF.

    TRY.

        rs_result = me->ls_forn_agrupador = CORRESPONDING #( lt_forn_agrupador[ 1 ] ).

      CATCH cx_sy_itab_line_not_found.
        CLEAR rs_result.
    ENDTRY.

  ENDMETHOD.

  METHOD seleciona_linhas_arquivo.

    IF me->busca_erros( ) EQ abap_true.
      RETURN.
    ENDIF.

    DATA(ls_arquivo) = me->lt_import_arq[ 1 ].

    SELECT
        IdArquivo,
        Id,
        CompanyCode,
        Supplier,
        NotaFiscal,
        DataArquivo,
        TipoNF,
        ChaveAcesso,
        Cnpj,
        DueDate,
        ItemStatus,
        ValorNFArquivo,
        ValorNFFatura,
        CurrencyCode,
        AccountingDocument,
        FiscalYear,
        AccountingItem,
        DtEmissaoArquivo,
        DtEmissaoFatura,
        BusinessPlace,
        Assignment,
        ItemText,
        ProfitCenter,
        Msg,
        FornAgrupador,
        FaturaAgrupada,
        RefAgrupada,
        CreatedBy,
        CreatedAt,
        LastChangedBy,
        LastChangedAt,
        LocalLastChangedAt
    FROM zi_fi_agrupalinhas
    WHERE IdArquivo EQ @ls_arquivo-IdArquivo
    INTO CORRESPONDING FIELDS OF TABLE @me->lt_import_arqlinhas.

    IF sy-subrc EQ 0.

      rt_result = me->lt_import_arqlinhas.

    ELSE.

      APPEND VALUE #(  id = gc_msgid
                       type       = if_xo_const_message=>error
                       number     = 008 ) TO me->lt_msgbapi.
    ENDIF.

  ENDMETHOD.

  METHOD busca_erros.

    SORT me->lt_msgbapi BY type.

    READ TABLE me->lt_msgbapi TRANSPORTING NO FIELDS
        WITH KEY type = if_xo_const_message=>error
        BINARY SEARCH.

    IF sy-subrc EQ 0.
      rv_error = abap_True.
    ENDIF.

  ENDMETHOD.

  METHOD calcula_desconto.

    DATA:
      lv_total_sap      TYPE wrbtr,
      lv_total_arquivo  TYPE wrbtr,
      lv_diferenca      TYPE wrbtr,
      lv_valor_desconto TYPE wrbtr.

    IF me->busca_erros( ) EQ abap_true.
      RETURN.
    ENDIF.

    lv_total_sap = REDUCE bseg-wrbtr(
                        INIT lv_x = CONV bseg-wrbtr( 0 )
                        FOR ls_itens IN me->lt_import_arqlinhas
                        NEXT lv_x = lv_x + ls_itens-ValorNFFatura
               ).

    lv_total_arquivo = REDUCE bseg-wrbtr(
                            INIT lv_x = CONV bseg-wrbtr( 0 )
                            FOR ls_itens IN me->lt_import_arqlinhas
                            NEXT lv_x = lv_x + ls_itens-ValorNFArquivo
               ).

    IF lv_total_sap EQ lv_total_arquivo.
      RETURN.
    ENDIF.

    lv_diferenca = ( lv_total_sap - lv_total_arquivo ).

    rv_result = lv_diferenca.

  ENDMETHOD.

ENDCLASS.
