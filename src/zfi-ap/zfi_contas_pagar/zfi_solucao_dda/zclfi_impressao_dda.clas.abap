"!<p><h2>Impressão de boletos recebidos através do arquivo DDA</h2></p>
"!<p><strong>Autor:</strong>Marcos Roberto de Souza</p>
"!<p><strong>Data:</strong>4 de out de 2021</p>
CLASS zclfi_impressao_dda DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      "! Gerador de instância
      constructor,

      "! Localizar e formatar as informações para impressão do boleto via Adobe form
      "! @parameter is_chave_dda | Campos chave do título
      "! @parameter iv_imprimir  | Será realizada impressão (<em>ABAP_TRUE</em>) ou apenas retornado binário (<em>ABAP_FALSE</em>)
      "! @parameter ev_erro      | Mensagem de erro caso haja problema no processamento
      "! @parameter ev_pdf       | PDF gerado no formato binário
      gerar_boleto IMPORTING is_chave_dda TYPE zsfi_arquivo_dda
                             iv_imprimir  TYPE abap_bool DEFAULT abap_false
                   EXPORTING ev_erro      TYPE string
                             ev_pdf       TYPE xstring.

  PRIVATE SECTION.
    DATA:
       "!Instância do form Adobe de boletos DDA
      go_form TYPE REF TO zclca_adobeform.

    METHODS:
      "! Determinar o nome do objeto gráfico com o logotipo do banco correspondente ao boleto
      "! @parameter io_doc |Estrutura com os dados do boleto (lidos do BD)
      "! @parameter cs_boleto |Estrutura utilizada na impressão (Adobe form)
      determinar_logotipo IMPORTING io_doc    TYPE REF TO data
                          CHANGING  cs_boleto TYPE zsfi_boleto_dda,

      "! formatar o código de barras com o padrão Febraban
      "! @parameter iv_barcode |Código de barras a ser formatado
      "! @parameter cs_boleto |Estrutura utilizada na impressão (Adobe form)
      formatar_barcode IMPORTING iv_barcode TYPE brcde
                       CHANGING  cs_boleto  TYPE zsfi_boleto_dda.
ENDCLASS.



CLASS ZCLFI_IMPRESSAO_DDA IMPLEMENTATION.


  METHOD constructor.

    TRY.
        go_form = NEW zclca_adobeform( iv_formname = 'ZAFFI_BOLETO_DDA' ).
      CATCH zcxca_adobe_error.
    ENDTRY.
  ENDMETHOD.


  METHOD gerar_boleto.

    DATA: ls_dados_form   TYPE zclca_adobeform=>ty_params,
          ls_chave_dda    TYPE zsfi_arquivo_dda,
          ls_dados_boleto TYPE zsfi_boleto_dda,
          lv_cnpj         TYPE j_1bwfield-cgc_number,
          lv_cnpj_form    TYPE c LENGTH 18,
          ls_empresa      TYPE t001,
          ls_endereco     TYPE addr1_val.

    ls_chave_dda = is_chave_dda.

    "ler os dados para impressão do boleto
    SELECT empresa, banco, dataarquivo, nomeempresa, cnpjcedente, fornecedor, documentocontabil, ano,
           datavencimento, agenciacedente, nomecedente, datadocumento, numerodocumento, especietitulo, nossonum,
           carteira, valortitulo, jurosmora, valorabatimento, nomeavalista, valorcobrado, instrucao01, instrucao02,
           codigomoedabr, digitoagencia, fatorvencimento, campolivre, codigoprotesto, prazoprotesto, numeroinscricao
        FROM zi_fi_arquivo_dda
        WHERE fornecedor        = @ls_chave_dda-lifnr AND
              empresa           = @ls_chave_dda-bukrs AND
*              documentocontabil = @ls_chave_dda-belnr AND
              ano               = @ls_chave_dda-gjahr AND
              dataarquivo       = @ls_chave_dda-data_arq
           INTO TABLE @DATA(lt_documentos).

    IF sy-subrc <> 0 .

      "ler os dados para impressão do boleto
      SELECT empresa, banco, dataarquivo, nomeempresa, cnpjcedente, fornecedor, documentocontabil, ano,
             datavencimento, agenciacedente, nomecedente, datadocumento, numerodocumento, especietitulo, nossonum,
             carteira, valortitulo, jurosmora, valorabatimento, nomeavalista, valorcobrado, instrucao01, instrucao02,
             codigomoedabr, digitoagencia, fatorvencimento, campolivre, codigoprotesto, prazoprotesto, numeroinscricao
          FROM zi_fi_arquivo_dda
          WHERE
*               fornecedor        = @ls_chave_dda-lifnr AND
                empresa           = @ls_chave_dda-bukrs AND
                documentocontabil = @ls_chave_dda-num_doc AND
                ano               = @ls_chave_dda-gjahr AND
                dataarquivo       = @ls_chave_dda-data_arq
             INTO TABLE @lt_documentos.

    ENDIF.


    " Busca o registro mais recente
    SORT lt_documentos BY dataarquivo DESCENDING.

    IF ls_chave_dda-num_doc IS INITIAL.

      READ TABLE lt_documentos INTO DATA(ls_documento) INDEX 1.

      IF ls_documento IS INITIAL.
        "Documento não encontrado para impressão de boleto DDA
        ev_erro = TEXT-e01.
        RETURN.
      ENDIF.
    ELSE.
      DATA(lt_documentos_aux) = lt_documentos.
      DELETE lt_documentos_aux WHERE numerodocumento NE ls_chave_dda-num_doc.

      READ TABLE lt_documentos_aux INTO ls_documento INDEX 1.

      IF ls_documento IS INITIAL.
        "Documento não encontrado para impressão de boleto DDA
        ev_erro = TEXT-e01.
        RETURN.
      ENDIF.
    ENDIF.

    "Dados gerais
    ls_dados_boleto-banco       = ls_documento-banco.
    ls_dados_boleto-agcedente   = ls_documento-agenciacedente.
    ls_dados_boleto-cedente     = ls_documento-campolivre+3(9).
    "    ls_dados_boleto-numdoc      = ls_documento-nossonum. "ls_dados_boleto-nossonum = ls_documento-numerodocumento.
    ls_dados_boleto-numdoc      = ls_documento-numerodocumento.
    ls_dados_boleto-especiedoc  = ls_documento-especietitulo.
    ls_dados_boleto-especie  = '09'.
    ls_dados_boleto-carteira    = ls_documento-campolivre(3).
    ls_dados_boleto-instrucao01 = ls_documento-instrucao01.
    ls_dados_boleto-instrucao02 = ls_documento-instrucao02.
    ls_dados_boleto-nossonum    = ls_documento-campolivre+3(9).
    ls_dados_boleto-valor       = ls_documento-valortitulo.

    DATA:
      lv_bar_out   TYPE  char100,
      lv_barcode   TYPE  char100,
      lv_valor_br  TYPE  char20,
      lv_valor_aux TYPE  num10.

    CLEAR: lv_bar_out, lv_barcode.
    lv_valor_br = ls_documento-valortitulo.
    TRANSLATE lv_valor_br USING '. '.
    CONDENSE lv_valor_br NO-GAPS.

    lv_valor_aux = lv_valor_br.

    SELECT SINGLE barcode
      FROM j1b_error_dda
      INTO @DATA(lv_barcode_dda)
      WHERE reference_no = @ls_documento-documentocontabil
         AND bukrs = @ls_documento-empresa
         AND posting_date = @ls_documento-dataarquivo.

    IF sy-subrc = 0.

      lv_barcode  = lv_barcode_dda.
      ls_dados_boleto-banco = lv_barcode_dda(3).

    ELSE.

      CONCATENATE ls_documento-banco ls_documento-codigomoedabr
            ls_documento-digitoagencia ls_documento-fatorvencimento
            lv_valor_aux        ls_documento-campolivre
            INTO lv_barcode.

      CONDENSE lv_barcode NO-GAPS.

    ENDIF.


    "Determinar o logotipo do banco
    determinar_logotipo( EXPORTING io_doc    = REF #( ls_dados_boleto )
                         CHANGING  cs_boleto = ls_dados_boleto ).

    "Formatar o Código de Barras
    formatar_barcode( EXPORTING iv_barcode = CONV brcde( lv_barcode )
                      CHANGING  cs_boleto  = ls_dados_boleto ).

    "Tratar datas
    ls_dados_boleto-vencimento = |{ ls_documento-datavencimento DATE = USER }|.
    ls_dados_boleto-datadoc    = |{ ls_documento-datadocumento  DATE = USER }|.
    ls_dados_boleto-dataproc   = |{ ls_documento-dataarquivo    DATE = USER }|.

    "Valores
    ls_dados_boleto-valordoc     = ls_documento-valortitulo.
    ls_dados_boleto-desconto     = ls_documento-valorabatimento.
*    ls_dados_boleto-multa        = ls_documento-jurosmora.
    ls_dados_boleto-valorcobrado = ls_documento-valortitulo."ls_documento-valorcobrado.

    "Dados do Sacado
    CALL FUNCTION 'J_1B_COMPANY_READ'
      EXPORTING
        company           = ls_documento-empresa
      IMPORTING
        cgc_number        = lv_cnpj
        company_record    = ls_empresa
      EXCEPTIONS
        company_not_found = 1
        branch_not_found  = 2
        OTHERS            = 3.
    IF sy-subrc = 0.
      lv_cnpj = ls_documento-cnpjcedente.

      CALL FUNCTION 'CONVERSION_EXIT_CGCBR_OUTPUT'
        EXPORTING
          input  = lv_cnpj
        IMPORTING
          output = lv_cnpj_form.

      ls_dados_boleto-sacado = |{ ls_empresa-butxt } - CNPJ: { lv_cnpj_form }|.
      CALL FUNCTION 'HRF_READ_COMPANY_ADDRESS'
        EXPORTING
          sprsl         = sy-langu
          company_code  = ls_documento-empresa
        CHANGING
          address       = ls_endereco
        EXCEPTIONS
          display_error = 1
          OTHERS        = 2.
      IF sy-subrc = 0.
        ls_dados_boleto-endereco = |{ ls_endereco-street }, { ls_endereco-house_num1 } - CEP:{ ls_endereco-post_code1 } - { ls_endereco-city1 }-{ ls_endereco-region }|.
      ENDIF.
    ENDIF.

    CLEAR ls_dados_boleto-instrucao01.

    CASE ls_documento-codigoprotesto.

      WHEN 1.

        CONCATENATE 'PROTESTAR APÓS' ls_documento-prazoprotesto 'DIAS CORRIDOS APÓS VENCIMENTO'
        INTO ls_dados_boleto-instrucao01 SEPARATED BY space.

      WHEN 2.

        CONCATENATE 'PROTESTAR APÓS' ls_documento-prazoprotesto 'DIAS ÚTEIS APÓS VENCIMENTO'
        INTO ls_dados_boleto-instrucao01 SEPARATED BY space.
      WHEN OTHERS.
        ls_dados_boleto-instrucao01 = |APÓS O VENCIMENTO COBRAR R$ { ls_documento-jurosmora } DE JUROS, | &&
        |PROPORCIONAL AOS DIAS DE ATRASO.|.
    ENDCASE.


    ls_dados_boleto-instrucao02 = |BOLETO REF. NF { ls_documento-numerodocumento }|.
    DATA: lv_cnpj_cpf3 TYPE char20.

*cedente
    IF ls_documento-nomecedente IS NOT INITIAL AND ls_documento-numeroinscricao IS NOT INITIAL.
      DATA(lv_len) = strlen( ls_documento-numeroinscricao ).

      IF lv_len = 14.
        WRITE ls_documento-numeroinscricao TO lv_cnpj_cpf3 USING EDIT MASK '__.___.___/____-__'.
      ENDIF.

      IF lv_len = 15.
        SHIFT ls_documento-numeroinscricao BY 1 PLACES LEFT.
        WRITE ls_documento-numeroinscricao TO lv_cnpj_cpf3 USING EDIT MASK '__.___.___/____-__'.
      ENDIF.

      IF lv_len = 11.
        WRITE ls_documento-numeroinscricao TO lv_cnpj_cpf3 USING EDIT MASK '___.___.___-__'.
      ENDIF.

      CONCATENATE ls_documento-nomecedente lv_cnpj_cpf3 INTO ls_dados_boleto-cedente SEPARATED BY '-'.

    ELSE.
      CLEAR lv_len.
      lv_len = strlen( ls_documento-numeroinscricao ).

      IF lv_len = 14.
        WRITE ls_documento-numeroinscricao TO lv_cnpj_cpf3 USING EDIT MASK '__.___.___/____-__'.
      ENDIF.

      IF lv_len = 15.
        SHIFT ls_documento-numeroinscricao BY 1 PLACES LEFT.
        WRITE ls_documento-numeroinscricao TO lv_cnpj_cpf3 USING EDIT MASK '__.___.___/____-__'.
      ENDIF.

      IF lv_len = 11.
        WRITE ls_documento-numeroinscricao TO lv_cnpj_cpf3 USING EDIT MASK '___.___.___-__'.
      ENDIF.

      CONCATENATE ls_documento-nomecedente lv_cnpj_cpf3 INTO ls_dados_boleto-cedente SEPARATED BY '-'.
    ENDIF.

*cedente
    CONCATENATE ls_dados_boleto-agcedente ls_documento-campolivre+16(5) INTO ls_dados_boleto-agcedente SEPARATED BY ' / '.

    TRY.
        "Preparar interface com o formulário Adobe
        ls_dados_form-parametro = 'IS_DADOS_BOLETO'.
        ls_dados_form-valor     = REF #( ls_dados_boleto ).
        go_form->setup_data( is_data = ls_dados_form ).

        IF iv_imprimir = abap_true.
          go_form->show_dialog( iv_print_dialog = abap_true ).
          go_form->print( ).

        ELSE.
          go_form->get_pdf( IMPORTING ev_pdf = ev_pdf ).
        ENDIF.

      CATCH zcxca_adobe_error.
    ENDTRY.
  ENDMETHOD.


  METHOD determinar_logotipo.

    ASSIGN io_doc->* TO FIELD-SYMBOL(<fs_doc>).
    ASSIGN COMPONENT 'BANCO' OF STRUCTURE <fs_doc> TO FIELD-SYMBOL(<fs_banco>).
    IF <fs_banco> IS ASSIGNED.
      cs_boleto-logotipo = COND #( WHEN <fs_banco> = '237' THEN 'BRADESCO'
                                   WHEN <fs_banco> = '341' THEN 'ITAU'
                                   WHEN <fs_banco> = '033' THEN 'SANTANDER'
                                   WHEN <fs_banco> = '422' THEN 'SAFRA'
                                   WHEN <fs_banco> = '001' THEN 'BANCOBRASIL'
                                   WHEN <fs_banco> = '745' THEN 'CITIBANK'
                                   ELSE 'BANCO' ).
      cs_boleto-logotipo = |Z_LOGO_{ cs_boleto-logotipo }|.
    ENDIF.
  ENDMETHOD.


  METHOD formatar_barcode.
    cs_boleto-barcode   = iv_barcode.
* Área para receber codigo digitado (tamanho: 44)
    DATA: BEGIN OF ls_entrada,
            c1(3)  TYPE c,
            c2(1)  TYPE c,
            c3(1)  TYPE c,
            c4(4)  TYPE c,
            c5(10) TYPE c,
            c6(1)  TYPE c,
            c7(4)  TYPE c,
            c8(10) TYPE c,
            c9(10) TYPE c,
          END OF ls_entrada.
* Área de calculo do digito verificador para campo com tamanho 9.
    DATA: BEGIN OF ls_digito9,
            d1(1) TYPE n,
            d2(1) TYPE n,
            d3(1) TYPE n,
            d4(1) TYPE n,
            d5(1) TYPE n,
            d6(1) TYPE n,
            d7(1) TYPE n,
            d8(1) TYPE n,
            d9(1) TYPE n,
          END OF ls_digito9.

* Área de calculo do digito verificador para campo com tamanho 10.
    DATA: BEGIN OF ls_digito10,
            d21(1)  TYPE n,
            d22(1)  TYPE n,
            d23(1)  TYPE n,
            d24(1)  TYPE n,
            d25(1)  TYPE n,
            d26(1)  TYPE n,
            d27(1)  TYPE n,
            d28(1)  TYPE n,
            d29(1)  TYPE n,
            d210(1) TYPE n,
          END OF ls_digito10.

* Áreas de trabalho.
    DATA: lv_digver(2) TYPE n.
    DATA: lv_digx(1)   TYPE n.
    DATA: lv_dwrk(2)   TYPE n.
    DATA: lv_dezena(3) TYPE n.
    DATA: lv_valor(1)  TYPE c.

    DATA:
      gc_sgtxt TYPE sgtxt,
      lv_esrre TYPE  bseg-esrre,
      lv_esrnr TYPE bseg-esrnr,
      lv_brcde TYPE rf05l-brcde,
      lv_zlsch TYPE bseg-zlsch.

*-----------------------------------------------------------------------
* Inicio dos procedimentos.
*-----------------------------------------------------------------------
* Se alguma coisa tiver sido digitada
* move codigo digitado para campo de ls_entrada
***  ls_entrada = iv_barcode.
***
**** Só converte se código digitado contiver apenas números,
***  IF ls_entrada-c1 CA 'abcdefghijklmnopqrstuvwxyz.-' OR
***     ls_entrada-c2 CA 'abcdefghijklmnopqrstuvwxyz.-' OR
***     ls_entrada-c3 CA 'abcdefghijklmnopqrstuvwxyz.-' OR
***     ls_entrada-c4 CA 'abcdefghijklmnopqrstuvwxyz.-' OR
***     ls_entrada-c5 CA 'abcdefghijklmnopqrstuvwxyz.-' OR
***     ls_entrada-c6 CA 'abcdefghijklmnopqrstuvwxyz.-' OR
***     ls_entrada-c7 CA 'abcdefghijklmnopqrstuvwxyz.-' OR
***     ls_entrada-c8 CA 'abcdefghijklmnopqrstuvwxyz.-' OR
***     ls_entrada-c9 CA 'abcdefghijklmnopqrstuvwxyz.-'.
***  ELSE.
***
***
**** Monta area para calculo do dígito do primeiro campo.
***    CONCATENATE   ls_entrada-c1
***                  ls_entrada-c2
***                  ls_entrada-c6
***                  ls_entrada-c7
***    INTO lv_esrnr.
***
**** Calcula dígito verificador do primeiro campo.
***    ls_digito9 = lv_esrnr.
***    lv_dwrk = ls_digito9-d1 * 2.
***    IF lv_dwrk > 9.
***      ls_digito9-d1 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito9-d1 = lv_dwrk.
***    ENDIF.
***    lv_dwrk = ls_digito9-d3 * 2.
***    IF lv_dwrk > 9.
***      ls_digito9-d3 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito9-d3 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito9-d5 * 2.
***    IF lv_dwrk > 9.
***      ls_digito9-d5 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito9-d5 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito9-d7 * 2.
***    IF lv_dwrk > 9.
***      ls_digito9-d7 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito9-d7 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito9-d9 * 2.
***    IF lv_dwrk > 9.
***      ls_digito9-d9 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito9-d9 = lv_dwrk.
***    ENDIF.
***
***    lv_digver = ls_digito9-d1 +
***             ls_digito9-d2 +
***             ls_digito9-d3 +
***             ls_digito9-d4 +
***             ls_digito9-d5 +
***             ls_digito9-d6 +
***             ls_digito9-d7 +
***             ls_digito9-d8 +
***             ls_digito9-d9.
***
***    lv_dezena = ( lv_digver / 10 ).
***    lv_dezena = lv_dezena * 10.
***    IF lv_dezena < lv_digver.
***      lv_dezena = lv_dezena + 10.
***    ENDIF.
***    lv_digver = lv_dezena - lv_digver.
***    lv_digx = lv_digver.
***
**** Monta primeiro campo da saida.
***    CONCATENATE   lv_esrnr lv_digx
***    INTO lv_esrnr.
***
***    ls_digito10 = ls_entrada-c8.
***    lv_dwrk = ls_digito10-d22 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d22 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d22 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito10-d24 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d24 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d24 = lv_dwrk.
***    ENDIF.
***    lv_dwrk = ls_digito10-d26 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d26 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d26 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito10-d28 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d28 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d28 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito10-d210 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d210 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d210 = lv_dwrk.
***    ENDIF.
***
***    lv_digver = ls_digito10-d21 +
***             ls_digito10-d22 +
***             ls_digito10-d23 +
***             ls_digito10-d24 +
***             ls_digito10-d25 +
***             ls_digito10-d26 +
***             ls_digito10-d27 +
***             ls_digito10-d28 +
***             ls_digito10-d210 +
***             ls_digito10-d29.
***    lv_dezena = ( lv_digver / 10 ).
***    lv_dezena = lv_dezena * 10.
***    IF lv_dezena < lv_digver.
***      lv_dezena = lv_dezena + 10.
***    ENDIF.
***    lv_digver = lv_dezena - lv_digver.
***    lv_digx = lv_digver.
***
**** Monta segundo campo na saida.
***    CONCATENATE   ls_entrada-c8 lv_digx
***    INTO lv_esrre.
***
**** Calcula dígito verificador do terceiro campo.
***    ls_digito10 = ls_entrada-c9.
***    lv_dwrk = ls_digito10-d22 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d22 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d22 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito10-d24 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d24 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d24 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito10-d26 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d26 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d26 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito10-d28 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d28 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d28 = lv_dwrk.
***    ENDIF.
***
***    lv_dwrk = ls_digito10-d210 * 2.
***    IF lv_dwrk > 9.
***      ls_digito10-d210 = ( lv_dwrk - 10 ) + 1.
***    ELSE.
***      ls_digito10-d210 = lv_dwrk.
***    ENDIF.
***
***    lv_digver = ls_digito10-d21 +
***             ls_digito10-d22 +
***             ls_digito10-d23 +
***             ls_digito10-d24 +
***             ls_digito10-d25 +
***             ls_digito10-d26 +
***             ls_digito10-d27 +
***             ls_digito10-d28 +
***             ls_digito10-d210 +
***             ls_digito10-d29.
***
***    lv_dezena = ( lv_digver / 10 ).
***    lv_dezena = lv_dezena * 10.
***    IF lv_dezena < lv_digver.
***      lv_dezena = lv_dezena + 10.
***    ENDIF.
***    lv_digver = lv_dezena - lv_digver.
***    lv_digx = lv_digver.
***
**** Monta terceiro campo na saida.
***    CONCATENATE   lv_esrre ls_entrada-c9 lv_digx
***    INTO lv_esrre.
***
**** Monta quarto campo na saida.
***    CONCATENATE   lv_esrre ls_entrada-c3
***    INTO lv_esrre.
***
***    IF NOT ( ls_entrada-c4 = space OR
***             ls_entrada-c4 CO '0' ).
***      CONCATENATE   lv_esrre ls_entrada-c4
***      INTO lv_esrre.
***
***    ENDIF.
***
***    IF ls_entrada-c5 <> '0000000000'.
***      CONCATENATE
***      lv_esrnr
***      lv_esrre
***      ls_entrada-c5
***    INTO lv_brcde.
***    ELSE.
***      CONCATENATE
***      lv_esrre
***      '000'
***      INTO lv_esrre.
***      CONCATENATE
***      lv_esrnr
***      lv_esrre
***      INTO lv_brcde.
***    ENDIF.
***  ENDIF.
***
*** WRITE lv_brcde TO cs_boleto-codbarras USING EDIT MASK '_____._____ _____.______ _____.______ _ ______________'.
***
*** cs_boleto-barcode = iv_barcode.

    WRITE iv_barcode TO cs_boleto-codbarras USING EDIT MASK '_____._____ _____.______ _____.______ _ ______________'.

    CLEAR cs_boleto-barcode.
    cs_boleto-barcode(4)     = iv_barcode(4).
    cs_boleto-barcode+4(15)  = iv_barcode+32(15).
    cs_boleto-barcode+19(5)  = iv_barcode+4(5).
    cs_boleto-barcode+24(10) = iv_barcode+10(10).
    cs_boleto-barcode+34(10) = iv_barcode+21(10).

*    cs_boleto-barcode = iv_barcode.

  ENDMETHOD.
ENDCLASS.
