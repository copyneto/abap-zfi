"!<p>Classe para gerar a impressão da etiqueta</p>
"!<p><strong>Autor:</strong>Igor Malfara</p>
"!<p><strong>Data:</strong> 16 de agosto de 2021</p>
class ZCLFI_GERAR_BOLETO definition
  public
  final
  create public .

public section.

  data GS_PROCESS type ZSFI_BOLETO_PROCESS .
  data GT_OTF type TSFOTF .

  methods CONSTRUCTOR
    importing
      !IS_PROCESS type ZSFI_BOLETO_PROCESS optional
      !IS_PARAM type SSFCTRLOP optional .
    "! Executa toda a rotina da classe
    "! @parameter iv_app    | execução via app
    "! @parameter iv_email  | execução via email
    "! @parameter it_key    | Chave de processamento
    "! @parameter ev_pdf_file | Arquivo pdf
    "! @parameter et_return | Mensagens de retorno
  methods PROCESS
    importing
      !IV_APP type FLAG optional
      !IV_EMAIL type ADR6-SMTP_ADDR optional
      !IT_EMAIL_CCO type BCSY_SMTPA optional
      !IT_KEY type ZCTGFI_POST_KEY optional
      !IV_BUKRS type BUKRS optional
      !IV_BELNR type BELNR_D optional
      !IV_GJAHR type GJAHR optional
      !IV_BUZEI type BUZEI optional
      !IT_KEYS type ZCTGFI_BOLETO_DOCUMENTO optional
    exporting
      !EV_PDF_FILE type XSTRING
      !ET_RETURN type BAPIRET2_T .
  PROTECTED SECTION.


PRIVATE SECTION.

  TYPES:
    BEGIN OF ys_abatimentos,
      bukrs TYPE bsid_view-bukrs,
      belnr TYPE bsid_view-belnr,
      gjahr TYPE bsid_view-gjahr,
      buzei TYPE bsid_view-buzei,
      rebzg TYPE bsid_view-rebzg,
      rebzj TYPE bsid_view-rebzj,
      rebzz TYPE bsid_view-rebzz,
      dmbtr TYPE bsid_view-dmbtr,
    END OF ys_abatimentos .
  TYPES:
    tt_abatimentos       TYPE SORTED TABLE OF ys_abatimentos WITH NON-UNIQUE KEY bukrs belnr gjahr buzei.

  TYPES:
    tt_abat_valor TYPE TABLE OF ys_abatimentos.

  CONSTANTS:
    "! Valores utilizados na chamada da etiqueta
    BEGIN OF gc_bol,
      "! Impressora padrão quando não existir configuração
      printer      TYPE char4 VALUE 'LOCL',
      "! EQ
      s_eq         TYPE char2 VALUE 'EQ',
      "! I
      s_i          TYPE char1 VALUE 'I',
      "! Módulo
      modulo       TYPE zi_ca_param_mod-modulo VALUE 'FI',
      "! Chave
      chave1       TYPE zi_ca_param_par-chave1 VALUE 'BANCOEMPRESA',
      "! Chave
      chave2       TYPE zi_ca_param_par-chave2 VALUE 'BRADESCO',
      "! Banco 237
      banco_237    TYPE char3 VALUE '237',
      "! Banco 237 e dígito
      banco_2372   TYPE char4 VALUE '2372',
      "! Código da moeda
      digito_moeda TYPE char1 VALUE '9',
      "! Chave 09
      chave_09     TYPE char2 VALUE '09',
      "! Espécie de documento
      especiedoc   TYPE char2 VALUE 'DM',
      "! Aceite
      aceite       TYPE char1 VALUE 'N',
      "! Tipo de moeda
      especie      TYPE char2 VALUE 'R$',
      "! Moeda
      currency     TYPE waers VALUE 'BRL',
      "! Interno(para verificação de email)
      interno      TYPE sx_address-type VALUE 'INT',
      "! Impressora local
      device       TYPE rspoptype VALUE 'LOCL',
      "! Formulário bradesco
      formname     TYPE tdsfname VALUE 'ZSFFI_BOLETO_237',
      "! Subject
      subject      TYPE bcs_subject VALUE '3C - Boleto' ##NO_TEXT,
      "! Address
      address      TYPE bcs_visname VALUE 'do@not.reply' ##NO_TEXT,
      "! No replay
      visname      TYPE bcs_visname VALUE 'Do not reply' ##NO_TEXT,
      "! PDF
      doctype      TYPE bcss_attachment-doctype     VALUE 'PDF',
      "! Descrição do boleto
      description  TYPE bcss_attachment-description VALUE 'Boleto' ##NO_TEXT,
    END OF gc_bol .
  "! Arquivo pdf binário
  DATA gv_pdf_file TYPE xstring .
  "! Variável para controle de mensagens
  DATA gv_dummy TYPE string .
  "! Parametros de impressão
  DATA gs_param TYPE ssfctrlop .
  "! Tabela de mensagens
  DATA gt_msg_ex TYPE bapiret2_t .
  "! Tabela com dados da busca de info do boleto
  DATA gt_boletos_all TYPE zctgfi_boleto_all .
  "! Tabela com dados preenchidos para o boleto
  DATA gt_boleto_smart TYPE zctgfi_boleto_237 .
  DATA:
      "! Tabela com texto cliente
    gt_texto_instruc TYPE SORTED TABLE OF ztfi_blt_txtinst WITH UNIQUE KEY bukrs hbkid .
  DATA:
      "! Range por empresa
    gr_bukrs TYPE RANGE OF bukrs .
  DATA:
      "! Range por documento
    gr_belnr TYPE RANGE OF belnr_d .
  DATA:
      "! Range por ano
    gr_gjahr TYPE RANGE OF gjahr .
  DATA:
      "! Range por item
    gr_buzei TYPE RANGE OF buzei .
  DATA gt_abatimentos TYPE tt_abatimentos .
*  DATA gt_abatimentos_valor TYPE tt_abatimentos .
  DATA gt_abatimentos_valor TYPE tt_abat_valor .
  DATA gt_email_cco TYPE bcsy_smtpa .
  DATA gc_cco TYPE bcs_copy VALUE 'B' ##NO_TEXT.

  "! Método para buscar dados
  METHODS get_data .
  "! Método para popular campos do boleto
  METHODS build_boleto .
  "! Método para verificar se há dados para processar
  "! @parameter iv_email |  Email
  "! @parameter rv_result | Verdadeiro ou falso
  METHODS check_data
    IMPORTING
      !iv_email        TYPE adr6-smtp_addr
    RETURNING
      VALUE(rv_result) TYPE abap_bool .
  "! Método para processar boleto
  METHODS execute_boleto .
  "! Método para processar boleto e email
  "! @parameter iv_email |  Email
  METHODS execute_boleto_email
    IMPORTING
      !iv_email TYPE adr6-smtp_addr .
  "! Método para alterar texto
  "! @parameter IS_BOLETO |  Boleto
  METHODS replace_text
    IMPORTING
      !is_boleto       TYPE zsfi_boleto_all
    CHANGING
      !cs_gerar_boleto TYPE zsfi_boleto_237 .
  "! Método para inserir mensagem de retorno
  METHODS append_msg .
  "! Método para atribuir erro no formulário
  METHODS set_erro_form .
  "! Método para fazer refresh
  METHODS refresh .
  "! Método para retornar ok na geração do boleto
  METHODS set_ok_form .
  "! Método para atribuir dados de processamento
  "! @parameter it_key  | Chave de execuçaõ
  METHODS set_data
    IMPORTING
      !it_key TYPE zctgfi_post_key .
  "! Método para atribuir dados de processamento
  "! @parameter iv_bukrs  | Empresa
  METHODS set_data_range
    IMPORTING
      !iv_bukrs TYPE bukrs
      !iv_belnr TYPE belnr_d
      !iv_gjahr TYPE gjahr
      !iv_buzei TYPE buzei .
  "! Método para verificar dados ao processar email
  "! @parameter rv_cliente | Check de mesmo cliente em execução
  METHODS valida_email
    RETURNING
      VALUE(rv_cliente) TYPE abap_bool .
  "! Método para construir o email
  "! @parameter iv_email | Email
  METHODS build_email
    IMPORTING
      !iv_email    TYPE adr6-smtp_addr
      !iv_filename TYPE bcs_filename .
  "! Método para converter otf
  "! @parameter it_otf | Boleto em OTF
  METHODS convert_otf
    IMPORTING
      !it_otf TYPE tt_itcoo .
  "! Método para verificar parametros de impressão
  "! @parameter rv_dialog | Parametros de impressão
  METHODS set_no_dialog
    RETURNING
      VALUE(rv_dialog) TYPE ssfctrlop-no_dialog .
  "! Método para verificar parametros de impressão
  "! @parameter rv_otf | Parametros de impressão
  METHODS set_otf
    RETURNING
      VALUE(rv_otf) TYPE ssfctrlop-getotf .
  "! Método para verificar parametros de impressão
  "! @parameter rv_preview | Parametros de impressão
  METHODS set_preview
    RETURNING
      VALUE(rv_preview) TYPE ssfctrlop-preview .
  "! Método para calcular o vencimento
  "! @parameter is_boleto | Dados do boleto
  "! @parameter rv_vencimento | Vencimento
  METHODS set_vencimento
    IMPORTING
      !is_boleto           TYPE zsfi_boleto_all
    RETURNING
      VALUE(rv_vencimento) TYPE sy-datum .
  "! Método para formatar a data
  "! @parameter iv_date | Data
  "! @parameter rv_date | Data formatada
  METHODS set_date
    IMPORTING
      !iv_date       TYPE zsfi_boleto_campos-data_proc
    RETURNING
      VALUE(rv_date) TYPE zsfi_boleto_237-dataproc .
  "! Método para formatar o valor
  "! @parameter iv_valor | Valor
  "! @parameter rv_valor | Valor formatada
  METHODS set_valor
    IMPORTING
      !iv_valor       TYPE zsfi_boleto_campos-total
    RETURNING
      VALUE(rv_valor) TYPE zsfi_boleto_237-valordoc .
  "! Método para formatar o CPF
  "! @parameter iv_cpf | CPF
  "! @parameter rv_cpf | CPF formatada
  METHODS set_cpf
    IMPORTING
      !iv_cpf       TYPE stcd2
    RETURNING
      VALUE(rv_cpf) TYPE zsfi_boleto_237-cpf .
  "! Método para formatar o CNPJ
  "! @parameter iv_cnpj | CNPJ
  "! @parameter rv_cnpj | CNPJ formatada
  METHODS set_cnpj
    IMPORTING
      !iv_cnpj       TYPE stcd1
    RETURNING
      VALUE(rv_cnpj) TYPE char18 .
  "! Método para verificar se não houve erros
  METHODS check_ok .
  "! Método para validar endereço de email
  "! @parameter iv_email | Email
  "! @parameter rv_email | Válido ou inválido
  METHODS valida_end_email
    IMPORTING
      !iv_email       TYPE adr6-smtp_addr
    RETURNING
      VALUE(rv_email) TYPE abap_bool .
  METHODS set_boleto_email
    RETURNING
      VALUE(rt_boleto_email) TYPE zctgfi_boleto_ref .
  METHODS execute_boleto_normal .
  METHODS atualiza_documento .
  METHODS download_file
    IMPORTING
      !is_otf_data TYPE ssfcrescl
      !iv_kunnr    TYPE kunnr
      !iv_xblnr    TYPE xblnr
      !iv_buzei    TYPE buzei OPTIONAL .
ENDCLASS.



CLASS ZCLFI_GERAR_BOLETO IMPLEMENTATION.


  METHOD constructor.

    gs_process = is_process.

    gs_param = is_param.

  ENDMETHOD.


  METHOD append_msg.

    DATA(ls_message) = VALUE bapiret2( type         = sy-msgty
                                       id           = sy-msgid
                                       number       = sy-msgno
                                       message_v1   = sy-msgv1
                                       message_v2   = sy-msgv2
                                       message_v3   = sy-msgv3
                                       message_v4   = sy-msgv4 ).

    ls_message-message = gv_dummy.

    APPEND ls_message TO gt_msg_ex.

  ENDMETHOD.


  METHOD check_data.

    rv_result = abap_true.

    IF lines( gt_boletos_all ) = 0.

      rv_result = abap_false.

      MESSAGE e008 INTO gv_dummy.

      append_msg( ).

      EXIT.

    ENDIF.

    CASE gs_process-email.

      WHEN abap_true.

        IF valida_end_email( iv_email ) = abap_false.

          rv_result = abap_false.

        ELSE.

          IF valida_email( ) = abap_false.

            rv_result = abap_false.

          ENDIF.

        ENDIF.

    ENDCASE.


  ENDMETHOD.


  METHOD get_data.

    SELECT zi_fi_boleto_all~bukrs,
           belnr,
           gjahr,
           buzei,
           xblnr,
           kunnr,
           gsber,
           zi_fi_boleto_all~hbkid,
           xref3,
           zuonr,
           bldat,
           zi_fi_boleto_all~waers,
           zbd1t,
           zbd2t,
           zbd3t,
           vbeln,
           bupla,
           zbd1p,
           zbd2p,
           zterm,
           zlsch,
           rebzg,
           rebzj,
           rebzz,
           zfbdt,
           madat,
           wrbtr,
           dmbtr,
           br_notafiscal,
           bankl,
           _t012k_1~dtaai AS dtaai,
           _t012k_1~bankn AS bankn,
           _t012k_1~bkont AS bkont,
           dtaid,
           vorga,
           name1,
           pstlz,
           stras,
           ort01,
           ort02,
           regio,
           stcd1,
           stcd2,
           stcd3
      FROM zi_fi_boleto_all
      LEFT OUTER JOIN t012k AS _t012k_1
        ON  _t012k_1~bukrs = zi_fi_boleto_all~bukrs
        AND _t012k_1~hbkid = zi_fi_boleto_all~hbkid
      WHERE zi_fi_boleto_all~bukrs IN @gr_bukrs
        AND belnr IN @gr_belnr
        AND gjahr IN @gr_gjahr
        AND buzei IN @gr_buzei
   INTO TABLE @DATA(lt_cds).

    LOOP AT lt_cds ASSIGNING FIELD-SYMBOL(<fs_cds>).

      APPEND INITIAL LINE TO gt_boletos_all ASSIGNING FIELD-SYMBOL(<fs_boleto>).

      <fs_boleto>-bukrs = <fs_cds>-bukrs.
      <fs_boleto>-belnr = <fs_cds>-belnr.
      <fs_boleto>-gjahr = <fs_cds>-gjahr.
      <fs_boleto>-buzei = <fs_cds>-buzei.
      <fs_boleto>-xblnr = <fs_cds>-xblnr.
      <fs_boleto>-kunnr = <fs_cds>-kunnr.
      <fs_boleto>-gsber = <fs_cds>-gsber.
      <fs_boleto>-hbkid = <fs_cds>-hbkid.
      <fs_boleto>-xref3 = <fs_cds>-xref3.
      <fs_boleto>-zuonr = <fs_cds>-zuonr.
      <fs_boleto>-bldat = <fs_cds>-bldat.
      <fs_boleto>-waers = <fs_cds>-waers.
      <fs_boleto>-zbd1t  = <fs_cds>-zbd1t.
      <fs_boleto>-zbd2t = <fs_cds>-zbd2t.
      <fs_boleto>-zbd3t = <fs_cds>-zbd3t.
      <fs_boleto>-vbeln  = <fs_cds>-vbeln.
      <fs_boleto>-bupla = <fs_cds>-bupla.
      <fs_boleto>-zbd1p  = <fs_cds>-zbd1p.
      <fs_boleto>-zbd2p = <fs_cds>-zbd2p.
      <fs_boleto>-zterm = <fs_cds>-zterm.
      <fs_boleto>-zlsch = <fs_cds>-zlsch.
      <fs_boleto>-rebzg = <fs_cds>-rebzg.
      <fs_boleto>-rebzj = <fs_cds>-rebzj.
      <fs_boleto>-rebzz = <fs_cds>-rebzz.
      <fs_boleto>-zfbdt = <fs_cds>-zfbdt.
      <fs_boleto>-madat  = <fs_cds>-madat.
      <fs_boleto>-wrbtr = <fs_cds>-wrbtr.
      <fs_boleto>-dmbtr = <fs_cds>-dmbtr.
      <fs_boleto>-br_notafiscal = <fs_cds>-br_notafiscal.
      <fs_boleto>-bankl   = <fs_cds>-bankl.
      <fs_boleto>-dtaai   = <fs_cds>-dtaai.
      <fs_boleto>-bankn   = <fs_cds>-bankn.
      <fs_boleto>-bkont   = <fs_cds>-bkont.
      <fs_boleto>-dtaid   = <fs_cds>-dtaid.
      <fs_boleto>-vorga   = <fs_cds>-vorga.
      <fs_boleto>-name1   = <fs_cds>-name1.
      <fs_boleto>-pstlz   = <fs_cds>-pstlz.
      <fs_boleto>-stras   = <fs_cds>-stras.
      <fs_boleto>-ort01   = <fs_cds>-ort01.
      <fs_boleto>-ort02   = <fs_cds>-ort02.
      <fs_boleto>-regio   = <fs_cds>-regio.
      <fs_boleto>-stcd1   = <fs_cds>-stcd1.
      <fs_boleto>-stcd2   = <fs_cds>-stcd2.
      <fs_boleto>-stcd3   = <fs_cds>-stcd3.

    ENDLOOP.


    CHECK lines( gt_boletos_all ) > 0.
    IF gt_boletos_all IS NOT INITIAL.

      gt_abatimentos = CORRESPONDING #( gt_boletos_all ).
      DELETE ADJACENT DUPLICATES FROM gt_abatimentos COMPARING bukrs belnr gjahr buzei.

      SELECT bsid~bukrs, bsid~belnr, bsid~gjahr, bsid~buzei, bsid~rebzg, bsid~rebzj, bsid~rebzz,
      SUM( bsid~dmbtr ) AS valor
      FROM bsid_view AS bsid
      INNER JOIN @gt_abatimentos AS abatimentos
*        ON bsid~bukrs = abatimentos~bukrs
*       AND bsid~belnr = abatimentos~rebzg
*       AND bsid~gjahr = abatimentos~rebzj
*       AND bsid~buzei = abatimentos~rebzz
        ON bsid~bukrs = abatimentos~bukrs
       AND bsid~rebzg = abatimentos~belnr
       AND bsid~rebzj = abatimentos~gjahr
       AND bsid~rebzz = abatimentos~buzei
      GROUP BY bsid~bukrs, bsid~belnr, bsid~gjahr, bsid~buzei, bsid~rebzg, bsid~rebzj, bsid~rebzz
      INTO TABLE @gt_abatimentos_valor.

    ENDIF.
    SORT gt_boletos_all BY bukrs belnr gjahr buzei.

    DATA(lt_aux) = gt_boletos_all.
    SORT lt_aux BY bukrs kunnr hbkid.
    DELETE ADJACENT DUPLICATES FROM lt_aux COMPARING bukrs kunnr hbkid.

    CHECK lines( lt_aux ) > 0.

    SELECT mandt
           bukrs
           hbkid
           text
       FROM ztfi_blt_txtinst
       INTO TABLE gt_texto_instruc
        FOR ALL ENTRIES IN lt_aux
      WHERE bukrs EQ lt_aux-bukrs
        AND hbkid EQ lt_aux-hbkid.

  ENDMETHOD.


  METHOD process.


    IF it_key IS NOT INITIAL.
      set_data( it_key ).
    ENDIF.
    IF iv_belnr IS NOT INITIAL.
      set_data_range(
        iv_bukrs = iv_bukrs
        iv_belnr = iv_belnr
        iv_gjahr = iv_gjahr
        iv_buzei = iv_buzei
      ).
    ENDIF.

    LOOP AT it_keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      set_data_range(
        iv_bukrs = <fs_key>-bukrs
        iv_belnr = <fs_key>-belnr
        iv_gjahr = <fs_key>-gjahr
        iv_buzei = <fs_key>-buzei
      ).
    ENDLOOP.

    get_data( ).

    IF check_data( iv_email ) = abap_true.

      build_boleto( ).

      CASE abap_true.

        WHEN gs_process-email.

          gt_email_cco = it_email_cco.
          execute_boleto_email( iv_email ).

        WHEN gs_process-app.
          atualiza_documento(  ).
          execute_boleto(  ).

          ev_pdf_file = gv_pdf_file.

        WHEN OTHERS. "outros ou report

          execute_boleto_normal( ).
          atualiza_documento( ).

      ENDCASE.

    ENDIF.

    check_ok( ).

    et_return = gt_msg_ex.

    refresh( ).

  ENDMETHOD.


  METHOD refresh.

    FREE: gt_boletos_all, gt_msg_ex, gv_pdf_file.

  ENDMETHOD.


  METHOD set_erro_form.

    MESSAGE e009 INTO gv_dummy.

    append_msg( ).


  ENDMETHOD.


  METHOD build_boleto.

    DATA: ls_campo      TYPE zsfi_boleto_campos,
          ls_sacado     TYPE zsfi_boleto_sacado,
          lv_vencimento TYPE sy-datum,
          lv_dmbtr      TYPE dmbtr,
          lv_valorcob   TYPE dmbtr,
          lt_instrucao  TYPE zsfi_boleto_instr,
          lv_hbkid      TYPE t045t-hbkid.

    DATA lr_banco TYPE RANGE OF hbkid.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    DATA lv_operacao.
    DATA: lv_digv(2), lv_agencia(5).
    DATA: lv_data TYPE bldat.

    TRY.

        lo_param->m_get_range(
          EXPORTING
            iv_modulo = gc_bol-modulo
            iv_chave1 = gc_bol-chave1
            iv_chave2 = gc_bol-chave2
          IMPORTING
            et_range  = lr_banco
        ).
      CATCH zcxca_tabela_parametros.

    ENDTRY.

    SORT gt_abatimentos_valor BY bukrs rebzg rebzj rebzz.

    LOOP AT gt_boletos_all ASSIGNING FIELD-SYMBOL(<fs_boleto>).

      CLEAR lv_dmbtr.

      APPEND INITIAL LINE TO gt_boleto_smart ASSIGNING FIELD-SYMBOL(<fs_smart>).
      <fs_smart>-bukrs = <fs_boleto>-bukrs.
      <fs_smart>-belnr = <fs_boleto>-belnr.
      <fs_smart>-gjahr = <fs_boleto>-gjahr.
      <fs_smart>-buzei = <fs_boleto>-buzei.
      <fs_smart>-xblnr = <fs_boleto>-xblnr.

      IF <fs_boleto>-hbkid IN lr_banco.
        <fs_boleto>-banco    = gc_bol-banco_237.
        <fs_boleto>-ubnkl    = gc_bol-banco_237.
        <fs_boleto>-bankl(4) = gc_bol-banco_2372.
      ELSE.
        <fs_boleto>-banco    = space.
      ENDIF.

      <fs_boleto>-ubnkl+3(1) = gc_bol-digito_moeda.

      CLEAR: ls_campo, lv_operacao.

      ls_campo-ch_banco_emp = <fs_boleto>-hbkid.
      ls_campo-ch_banco     = <fs_boleto>-bankl.
      ls_campo-conta        = <fs_boleto>-bankn.


      ls_campo-convenio     = <fs_boleto>-dtaid+2(7).

      "@@ banco
      IF ls_campo-ch_banco_emp IN lr_banco.

        CLEAR : lv_digv(2),
                lv_agencia(5),
                ls_campo-agencia,
                ls_campo-conta,
                ls_campo-dvage,
                ls_campo-dvcon.

        lv_agencia     = <fs_boleto>-hbkid.
        ls_campo-conta = <fs_boleto>-bankn.
        lv_digv        = <fs_boleto>-bkont.

        ls_campo-agencia = lv_agencia+1.
        ls_campo-dvage   = lv_digv(1).
        ls_campo-dvcon   = lv_digv+1(1).

        ls_campo-carteira  = gc_bol-chave_09.

        <fs_smart>-local_pagto = TEXT-b01.

      ENDIF.

      "@@ Sacado

      ls_campo-fatura    = <fs_boleto>-belnr.
      ls_campo-ano       = <fs_boleto>-gjahr.
      ls_campo-linha     = <fs_boleto>-buzei.
      ls_campo-data_doc  = <fs_boleto>-zfbdt.
      ls_campo-total     = <fs_boleto>-wrbtr.
      ls_campo-data_proc = sy-datum.
      ls_campo-empresa   = <fs_boleto>-bukrs.
      ls_campo-num_docu  = <fs_boleto>-xblnr.
      ls_campo-filial    = <fs_boleto>-bupla.

      lv_operacao = <fs_boleto>-vorga(1).

      "@@ data vencimento.
      lv_vencimento = set_vencimento( <fs_boleto> ).
      <fs_smart>-vencimento = lv_vencimento.

      CLEAR lv_data.

      ls_campo-data_doc = <fs_boleto>-bldat.

      IF <fs_boleto>-zfbdt = lv_vencimento.

        IF sy-datum <= <fs_boleto>-zfbdt.

          ls_campo-data_proc = sy-datum.

        ELSE.

          lv_data = <fs_boleto>-zfbdt - 2.
          ls_campo-data_proc = lv_data.

        ENDIF.

      ELSE.

        ls_campo-data_proc = ls_campo-data_doc .

      ENDIF.

      "@@ Banco, moeda e convenio
      <fs_smart>-banco       = ls_campo-ch_banco.
      <fs_smart>-moeda       = 9.
      <fs_smart>-convenio    = ls_campo-convenio.
      <fs_smart>-agencia     = <fs_boleto>-bankl+4(4).
      <fs_smart>-conta       = ls_campo-conta.
      <fs_smart>-filial      = ls_campo-filial.
      <fs_smart>-chave_banco = ls_campo-ch_banco_emp.

      <fs_smart>-cedente    = ls_campo-nmcedente.
      <fs_smart>-agenciacod = ls_campo-agencia && '-' &&
                              ls_campo-dvage   && '/' &&
                              ls_campo-conta   && '-' &&
                              ls_campo-dvcon.
      <fs_smart>-agenciacod = <fs_boleto>-bankl+4(4) && '-' && <fs_boleto>-bkont(1) && '/' &&  <fs_boleto>-bankn && '-' && <fs_boleto>-bkont+1(1).

      <fs_smart>-datadoc    = ls_campo-data_doc.

      <fs_smart>-especiedoc = gc_bol-especiedoc.
      <fs_smart>-aceite     = gc_bol-aceite.

      <fs_smart>-dataproc = set_date( ls_campo-data_proc ).

      IF ls_campo-ch_banco_emp IN lr_banco.

*        <fs_smart>-nossonum = ls_campo-fatura+2(8) &&
*                            ls_campo-linha+2(1) &&
*                            ls_campo-ano+2(2).
        <fs_smart>-nossonum = <fs_boleto>-belnr+2(8) && <fs_boleto>-buzei+2(1) && <fs_boleto>-gjahr+2(2).
      ENDIF.

      <fs_smart>-cod_mensagem = ls_campo-fatura   &&
                                ls_campo-ano      &&
                                ls_campo-linha.

      <fs_smart>-carteira   = ls_campo-carteira.
      <fs_smart>-especie    = gc_bol-especie.
      <fs_smart>-numdoc     = ls_campo-num_docu(9).
      <fs_smart>-valordoc   = set_valor( ls_campo-total ).
      <fs_smart>-valor_cd   = <fs_smart>-valordoc.
      <fs_smart>-valordoc   = set_valor( ls_campo-total ).
*      lv_dmbtr              = lv_dmbtr + <fs_boleto>-dmbtr.

      READ TABLE gt_abatimentos_valor WITH KEY bukrs = <fs_boleto>-bukrs
                                               rebzg = <fs_boleto>-belnr
                                               rebzj = <fs_boleto>-gjahr
                                               rebzz = <fs_boleto>-buzei
                                      BINARY SEARCH
                                      TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.

        LOOP AT gt_abatimentos_valor ASSIGNING FIELD-SYMBOL(<fs_abat>) FROM sy-tabix.

          IF <fs_abat>-bukrs NE <fs_boleto>-bukrs
          OR <fs_abat>-rebzg NE <fs_boleto>-belnr
          OR <fs_abat>-rebzj NE <fs_boleto>-gjahr
          OR <fs_abat>-rebzz NE <fs_boleto>-buzei.

            EXIT.

          ENDIF.

          ADD <fs_abat>-dmbtr TO lv_dmbtr.

        ENDLOOP.

      ENDIF.

*      lv_dmbtr = VALUE #( gt_abatimentos_valor[ bukrs = <fs_boleto>-bukrs rebzg = <fs_boleto>-belnr rebzj = <fs_boleto>-gjahr rebzz = <fs_boleto>-buzei ]-dmbtr OPTIONAL ).

      IF lv_dmbtr > 0.
        <fs_smart>-valorabat  = set_valor( lv_dmbtr ).
      ENDIF.
      lv_valorcob           = ls_campo-total - lv_dmbtr.
      <fs_smart>-valorcob   = set_valor( lv_valorcob ).
      IF <fs_smart>-valorcob = <fs_smart>-valordoc.
        CLEAR <fs_smart>-valorcob.
      ENDIF.
      <fs_smart>-cpf        = set_cpf( <fs_boleto>-stcd2 ).
      <fs_smart>-cgc        = set_cnpj( <fs_boleto>-stcd1 ).
      <fs_smart>-inscricao  = ls_campo-inscricao.

*      "@@ Cedente
*      lt_instrucao-banco    = <fs_boleto>-hbkid.
*      APPEND lt_instrucao TO <fs_smart>-instrucao.

      "Sacado
      <fs_smart>-sacado_nome      = <fs_boleto>-name1.
      <fs_smart>-sacado_endereco  = <fs_boleto>-stras.
      <fs_smart>-inscricao        = <fs_boleto>-stcd3.
      <fs_smart>-fatura           = ls_campo-fatura.

      replace_text(
        EXPORTING
          is_boleto       = <fs_boleto>
        CHANGING
          cs_gerar_boleto = <fs_smart>
      ).
      IF <fs_boleto>-zbd1p IS NOT INITIAL.
        DATA(lv_desconto) = CONV dmbtr( ( <fs_boleto>-zbd1p * <fs_boleto>-dmbtr ) / 100 ).
        DATA(lv_desconto_output) = set_valor( lv_desconto ).
        APPEND VALUE #(
          texto  = |{ TEXT-002 } { lv_desconto_output }|
        ) TO <fs_smart>-instrucao.
      ENDIF.

      <fs_smart>-sacado-nome   = <fs_boleto>-name1.
      <fs_smart>-sacado-cep    = <fs_boleto>-pstlz.
      <fs_smart>-sacado-rua    = <fs_boleto>-stras.
      <fs_smart>-sacado-cidade = <fs_boleto>-ort01.
      <fs_smart>-sacado-bairro = <fs_boleto>-ort02.
      <fs_smart>-sacado-uf     = <fs_boleto>-regio.
      <fs_smart>-sacado-codigo = <fs_boleto>-kunnr.

    ENDLOOP.

  ENDMETHOD.


  METHOD execute_boleto.

    DATA:
      lo_cached_response    TYPE REF TO if_http_response,
      lt_otf                TYPE STANDARD TABLE OF itcoo,
      lt_pdf                TYPE tlinet,
      lt_host               TYPE STANDARD TABLE OF /sdf/icm_data_struc,

      ls_control_parameters TYPE ssfctrlop,
      ls_output_options     TYPE ssfcompop,
      ls_job_output_info    TYPE ssfcrescl,
      ls_job_output_options TYPE ssfcresop,
      lv_smartform          TYPE rs38l_fnam,
      lv_pdf_filesize       TYPE i,
      lv_guid               TYPE guid_32.



    TRY.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname = gc_bol-formname
          IMPORTING
            fm_name  = lv_smartform.

      CATCH cx_fp_api_repository.

        set_erro_form( ).

      CATCH cx_fp_api_usage.

        set_erro_form( ).

      CATCH cx_fp_api_internal.

        set_erro_form( ).

    ENDTRY.

    LOOP AT gt_boletos_all INTO DATA(ls_boleto) .  "#EC CI_LOOP_INTO_WA

      READ TABLE gt_boleto_smart INTO DATA(ls_smart)
                                 WITH KEY bukrs = ls_boleto-bukrs
                                          belnr = ls_boleto-belnr
                                          gjahr = ls_boleto-gjahr
                                          buzei = ls_boleto-buzei
                                          BINARY SEARCH.

      CHECK sy-subrc = 0.

      AT FIRST.
        ls_control_parameters-no_open  = abap_false.
        ls_control_parameters-no_close = abap_true.
      ENDAT.
      AT LAST.
        ls_control_parameters-no_close = abap_false.
      ENDAT.

      ls_control_parameters-no_dialog = abap_true.
      ls_control_parameters-preview   = space.
      IF gs_param-device IS INITIAL.
        ls_control_parameters-getotf    = abap_true.                " Return OTF. Later we will convert to PDF.
        ls_output_options-tddest        = gc_bol-device.
      ELSE.
        ls_output_options-tddest        = gs_param-device.
        ls_output_options-tdimmed       = abap_true.
        ls_output_options-tdnewid       = abap_true.
      ENDIF.

      CALL FUNCTION lv_smartform
        EXPORTING
          control_parameters = ls_control_parameters
          output_options     = ls_output_options
          user_settings      = space
          gt_dados_boleto    = ls_smart
        IMPORTING
          job_output_info    = ls_job_output_info
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

      IF sy-subrc <> 0.

        set_erro_form( ).

        RETURN.

      ENDIF.

      INSERT LINES OF ls_job_output_info-otfdata[] INTO TABLE lt_otf[].

      IF ls_job_output_info-userexit   IS NOT INITIAL AND
         ls_job_output_info-outputdone IS INITIAL.
        RETURN.
      ENDIF.

      ls_control_parameters-no_dialog = abap_true.
      ls_control_parameters-preview   = space.
      ls_control_parameters-no_open   = abap_true.

    ENDLOOP.

    IF NOT lt_otf IS INITIAL.
      convert_otf(
        EXPORTING
          it_otf = lt_otf ).
    ENDIF.

  ENDMETHOD.


  METHOD set_data.

    DATA lt_key TYPE zctgfi_post_key.

    DATA lv_str    TYPE string.

    LOOP AT it_key INTO lv_str.                    "#EC CI_LOOP_INTO_WA

      SPLIT lv_str AT ';' INTO TABLE lt_key.

    ENDLOOP.

    IF lines( lt_key ) > 0.

      LOOP AT lt_key ASSIGNING FIELD-SYMBOL(<fs_key>).
        IF strlen( <fs_key> ) = 19.
          DATA(lv_key) =  <fs_key>(18) && '00' && <fs_key>+18(1).
          <fs_key> = lv_key.
        ELSEIF strlen( <fs_key> ) = 18.
          lv_key =  <fs_key>(4) && '0' && <fs_key>+4(13) && '00' && <fs_key>+17(1).
          <fs_key> = lv_key.
        ELSEIF strlen( <fs_key> ) = 17.
          lv_key =  <fs_key>(4) && '00' && <fs_key>+4(12) && '00' && <fs_key>+16(1).
          <fs_key> = lv_key.
        ELSEIF strlen( <fs_key> ) = 16.
          lv_key =  <fs_key>(4) && '000' && <fs_key>+4(11) && '00' && <fs_key>+15(1).
          <fs_key> = lv_key.
        ENDIF.
        APPEND INITIAL LINE TO gr_bukrs ASSIGNING FIELD-SYMBOL(<fs_bukrs>).
        <fs_bukrs>-sign = gc_bol-s_i.
        <fs_bukrs>-option = gc_bol-s_eq.
        <fs_bukrs>-low = <fs_key>(4).


        APPEND INITIAL LINE TO gr_belnr ASSIGNING FIELD-SYMBOL(<fs_belnr>).
        <fs_belnr>-sign = gc_bol-s_i.
        <fs_belnr>-option = gc_bol-s_eq.
        <fs_belnr>-low = <fs_key>+4(10).

        APPEND INITIAL LINE TO gr_gjahr ASSIGNING FIELD-SYMBOL(<fs_gjahr>).
        <fs_gjahr>-sign = gc_bol-s_i.
        <fs_gjahr>-option = gc_bol-s_eq.
        <fs_gjahr>-low = <fs_key>+14(4).

        APPEND INITIAL LINE TO gr_buzei ASSIGNING FIELD-SYMBOL(<fs_buzei>).
        <fs_buzei>-sign = gc_bol-s_i.
        <fs_buzei>-option = gc_bol-s_eq.
        <fs_buzei>-low = <fs_key>+18(3).
        <fs_buzei>-low = |{ <fs_buzei>-low  ALPHA = OUT }|.
      ENDLOOP.

      DELETE ADJACENT DUPLICATES FROM gr_bukrs.
      DELETE ADJACENT DUPLICATES FROM gr_buzei.

    ENDIF.
  ENDMETHOD.


  METHOD set_data_range.
    APPEND INITIAL LINE TO gr_bukrs ASSIGNING FIELD-SYMBOL(<fs_bukrs>).
    <fs_bukrs>-sign = gc_bol-s_i.
    <fs_bukrs>-option = gc_bol-s_eq.
    <fs_bukrs>-low = iv_bukrs.

    APPEND INITIAL LINE TO gr_belnr ASSIGNING FIELD-SYMBOL(<fs_belnr>).
    <fs_belnr>-sign = gc_bol-s_i.
    <fs_belnr>-option = gc_bol-s_eq.
*    <fs_belnr>-low = iv_belnr.
    <fs_belnr>-low = |{ iv_belnr  ALPHA = IN }|.

    APPEND INITIAL LINE TO gr_gjahr ASSIGNING FIELD-SYMBOL(<fs_gjahr>).
    <fs_gjahr>-sign = gc_bol-s_i.
    <fs_gjahr>-option = gc_bol-s_eq.
*    <fs_gjahr>-low = iv_gjahr.
    <fs_gjahr>-low = iv_gjahr.

    APPEND INITIAL LINE TO gr_buzei ASSIGNING FIELD-SYMBOL(<fs_buzei>).
    <fs_buzei>-sign = gc_bol-s_i.
    <fs_buzei>-option = gc_bol-s_eq.
    <fs_buzei>-low = iv_buzei.
    <fs_buzei>-low = |{ <fs_buzei>-low  ALPHA = IN }|.
  ENDMETHOD.


  METHOD valida_email.

    CHECK gs_process-email = abap_true.

    rv_cliente = abap_true.

    DATA(lt_aux) = gt_boletos_all.
    SORT lt_aux BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_aux COMPARING kunnr.

    DATA lr_kunnr TYPE RANGE OF kunnr.

    LOOP AT lt_aux ASSIGNING FIELD-SYMBOL(<fs_aux>).


      APPEND INITIAL LINE TO lr_kunnr ASSIGNING FIELD-SYMBOL(<fs_kunnr>).

      <fs_kunnr>-sign   = gc_bol-s_i.
      <fs_kunnr>-option = gc_bol-s_eq.
      <fs_kunnr>-low    = <fs_aux>-kunnr.

    ENDLOOP.

    CHECK lines( lr_kunnr ) > 0.

    SELECT bukrs,
           belnr,
           gjahr,
           buzei,
           kunnr,
           stcd1
       FROM zv_fi_boleto_email
      WHERE kunnr IN @lr_kunnr
      INTO TABLE @DATA(lt_cliente).


    LOOP AT lt_cliente ASSIGNING FIELD-SYMBOL(<fs_cliente>).

      AT FIRST.

        DATA(lv_first) = <fs_cliente>-stcd1(8).

      ENDAT.

      DATA(lv_check) = <fs_cliente>-stcd1(8).

      IF lv_first <> lv_check.

        MESSAGE e015 INTO gv_dummy.

        append_msg( ).

        rv_cliente = abap_false.

        EXIT.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.


  METHOD build_email.

    CHECK gv_pdf_file IS NOT INITIAL.

    TRY.
        DATA(lo_msg) = NEW cl_bcs_message( ).


        lo_msg->set_subject( gc_bol-subject ).

        lo_msg->add_recipient(
          EXPORTING
            iv_address      = CONV bcs_address( iv_email )
            iv_visible_name = CONV bcs_visname( iv_email )
        ).

        LOOP AT gt_email_cco ASSIGNING FIELD-SYMBOL(<fs_email_cco>).
          lo_msg->add_recipient(
            EXPORTING
              iv_address      = CONV bcs_address( <fs_email_cco> )
              iv_visible_name = CONV bcs_visname( <fs_email_cco> )
              iv_copy         = gc_cco
          ).
        ENDLOOP.

        lo_msg->set_sender(
          EXPORTING
            iv_address      = gc_bol-address
            iv_visible_name = gc_bol-visname
        ).

        lo_msg->set_main_doc(
          EXPORTING
            iv_contents_txt = |<p><strong><em>| &&
                              TEXT-m01 &&
                              |</em></strong></p>| &&
                              |<p><em>| &&
                              TEXT-m02 &&
                              |</em></p>| &&
                              |<p><em>| &&
                              TEXT-m03 &&
                              |</em></p>| &&
                              |<p><em>| &&
                              TEXT-m04 && space &&
                              TEXT-m05 &&
                              |</em></p>| &&
                              |<p><em>| &&
                              TEXT-m06 &&
                              |</em></p>| &&
                              |<p><em>| &&
                              TEXT-m07 &&
                              |</em></p>| &&
                              |<p><strong><em>| &&
                              TEXT-m08 &&
                              |</em></strong></p>| &&
                              |<p><strong><em>| &&
                              TEXT-m09 &&
                              |</em></strong></p>| &&
                              |<p><strong><em>| &&
                              TEXT-m10 &&
                              |</em></strong></p>|
            iv_doctype      = 'htm'    " Document Category
        ).

        lo_msg->add_attachment(
          EXPORTING
            iv_doctype      = gc_bol-doctype        "'PDF'
            iv_description  = iv_filename "gc_bol-description    "'teste'
            iv_filename     = iv_filename
            iv_contents_bin = gv_pdf_file
        ).

        lo_msg->set_send_immediately( abap_true ).

        lo_msg->send( ).


      CATCH cx_bcs_send.

        MESSAGE e014 INTO gv_dummy.

        append_msg( ).


    ENDTRY.


  ENDMETHOD.


  METHOD execute_boleto_email.

    DATA:
      lo_cached_response    TYPE REF TO if_http_response,

*      lt_interface          TYPE ytpoc_002,
      lt_otf                TYPE STANDARD TABLE OF itcoo,
      lt_pdf                TYPE tlinet,
      lt_host               TYPE STANDARD TABLE OF /sdf/icm_data_struc,

      ls_control_parameters TYPE ssfctrlop,
      ls_output_options     TYPE ssfcompop,
      ls_job_output_info    TYPE ssfcrescl,
      ls_job_output_options TYPE ssfcresop,
      lv_smartform          TYPE rs38l_fnam,
      lv_pdf_filesize       TYPE i,
      lv_guid               TYPE guid_32.


    TRY.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname = gc_bol-formname
          IMPORTING
            fm_name  = lv_smartform.

      CATCH cx_fp_api_repository.

        set_erro_form( ).

      CATCH cx_fp_api_usage.

        set_erro_form( ).

      CATCH cx_fp_api_internal.

        set_erro_form( ).

    ENDTRY.

    DATA(lt_boleto_email) = set_boleto_email( ).
*    data(lt_smart_email)  = set_smart_boleto( ).

    LOOP AT lt_boleto_email INTO DATA(ls_boleto).  "#EC CI_LOOP_INTO_WA

      DATA(ls_line) = ls_boleto.

      READ TABLE gt_boleto_smart INTO DATA(ls_smart)
                             WITH KEY xblnr = ls_line-xblnr
                                      bukrs = ls_line-bukrs
                                      belnr = ls_line-belnr
                                      gjahr = ls_line-gjahr
                                      buzei = ls_line-buzei
                                      BINARY SEARCH.

      CHECK sy-subrc = 0.

      AT NEW xblnr.
        ls_control_parameters-no_open  = abap_false.
        ls_control_parameters-no_close = abap_true.
      ENDAT.
      AT END OF xblnr.
        ls_control_parameters-no_close = abap_false.
      ENDAT.

      ls_control_parameters-no_dialog = abap_true.
      ls_control_parameters-preview   = space.
      ls_control_parameters-getotf    = abap_true.
      ls_output_options-tddest        = gc_bol-device.


      CALL FUNCTION lv_smartform
        EXPORTING
          control_parameters = ls_control_parameters
          output_options     = ls_output_options
          user_settings      = space
          gt_dados_boleto    = ls_smart
        IMPORTING
          job_output_info    = ls_job_output_info
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

      IF sy-subrc <> 0.
        " Houveram erros durante geração do relatório.
        set_erro_form( ).

        RETURN.

      ENDIF.

      CLEAR: lt_otf.
      INSERT LINES OF ls_job_output_info-otfdata[] INTO TABLE lt_otf[].

* ----------------------------------------------------------------------
* Manage user input
* ----------------------------------------------------------------------
      IF ls_job_output_info-userexit   IS NOT INITIAL AND
         ls_job_output_info-outputdone IS INITIAL.
        RETURN.
      ENDIF.

* ----------------------------------------------------------------------
* Prepare parameters for next document
* ----------------------------------------------------------------------
      ls_control_parameters-no_dialog = abap_true.
      ls_control_parameters-preview   = space.
      ls_control_parameters-no_open   = abap_true.

      AT END OF xblnr.
        ls_control_parameters-no_close = abap_false.

        CLEAR gv_pdf_file.

        convert_otf(
          EXPORTING
            it_otf = lt_otf ).

        build_email(
          iv_email = iv_email
          iv_filename = |{ TEXT-001 }_{ ls_line-kunnr }_{ ls_line-xblnr(16) }.pdf|
        ).

      ENDAT.


    ENDLOOP.


  ENDMETHOD.


  METHOD convert_otf.

    DATA lt_pdf                TYPE tlinet.
    DATA lv_pdf_filesize       TYPE i.

    gt_otf = it_otf[].

    CLEAR: gv_pdf_file.

    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
      IMPORTING
        bin_filesize          = lv_pdf_filesize
        bin_file              = gv_pdf_file
      TABLES
        otf                   = it_otf[]
        lines                 = lt_pdf[]
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        err_bad_otf           = 4
        OTHERS                = 5.

    IF sy-subrc <> 0.

      set_erro_form( ).

    ENDIF.

  ENDMETHOD.


  METHOD set_no_dialog.
    rv_dialog = COND #(
      WHEN gs_param IS NOT INITIAL
      THEN gs_param-no_dialog
      ELSE abap_true
    ).
  ENDMETHOD.


  METHOD set_preview.
    rv_preview = COND #(
      WHEN gs_param IS NOT INITIAL
      THEN gs_param-preview
      ELSE abap_true
    ).
  ENDMETHOD.


  METHOD set_otf.
    rv_otf = COND #(
      WHEN gs_param IS NOT INITIAL
      THEN gs_param-getotf
      ELSE abap_false
    ).
  ENDMETHOD.


  METHOD set_vencimento.

    IF is_boleto-madat IS INITIAL.

      CALL FUNCTION 'J_1B_FI_NETDUE'
        EXPORTING
          zfbdt   = is_boleto-zfbdt
          zbd1t   = is_boleto-zbd1t
          zbd2t   = is_boleto-zbd2t
          zbd3t   = is_boleto-zbd3t
        IMPORTING
          duedate = rv_vencimento
        EXCEPTIONS
          OTHERS  = 1.

      IF sy-subrc <> 0 .
        RETURN.
      ENDIF.

    ELSE.

      rv_vencimento = is_boleto-madat.

    ENDIF.


  ENDMETHOD.


  METHOD set_date.

    rv_date = iv_date+6(2) && '/' &&
              iv_date+4(2) && '/' &&
              iv_date(4).

  ENDMETHOD.


  METHOD set_valor.

    WRITE iv_valor TO rv_valor CURRENCY gc_bol-currency.

    CONDENSE  rv_valor  NO-GAPS.

  ENDMETHOD.


  METHOD set_cpf.

    CHECK iv_cpf IS NOT INITIAL.

    rv_cpf = iv_cpf(3)      && '.' &&
             iv_cpf+3(3)    && '.' &&
             iv_cpf+6(3)    && '-' &&
             iv_cpf+9(2).


  ENDMETHOD.


  METHOD set_cnpj.

    CHECK iv_cnpj IS NOT INITIAL.

    rv_cnpj = iv_cnpj(2)    && '.' &&
              iv_cnpj+2(3)  && '.' &&
              iv_cnpj+5(3)  && '/' &&
              iv_cnpj+8(4)  && '-' &&
              iv_cnpj+12(2).


  ENDMETHOD.


  METHOD check_ok.

    ASSIGN gt_msg_ex[ type = 'E' ] TO FIELD-SYMBOL(<fs_check>) . "#EC CI_STDSEQ

    IF sy-subrc <> 0.

      set_ok_form( ).

    ENDIF.

  ENDMETHOD.


  METHOD valida_end_email.

    DATA ls_add TYPE sx_address.

    rv_email = abap_true.

    ls_add-type = gc_bol-interno.
    ls_add-address = iv_email.

    CALL FUNCTION 'SX_INTERNET_ADDRESS_TO_NORMAL'
      EXPORTING
        address_unstruct    = ls_add
      EXCEPTIONS
        error_address_type  = 1
        error_address       = 2
        error_group_address = 3
        OTHERS              = 4.

    IF sy-subrc <> 0.

      rv_email = abap_false.

      MESSAGE e013 INTO gv_dummy.

      append_msg( ).
    ENDIF.

  ENDMETHOD.


  METHOD set_ok_form.

    MESSAGE s010 INTO gv_dummy.

    append_msg( ).


  ENDMETHOD.


  METHOD replace_text.

    DATA: lv_lf     TYPE c,
          lv_string TYPE string.

    lv_lf = cl_abap_char_utilities=>cr_lf+1(1).

    READ TABLE gt_texto_instruc ASSIGNING FIELD-SYMBOL(<fs_line>)
                                WITH KEY bukrs = is_boleto-bukrs
                                         hbkid = is_boleto-hbkid
                                         BINARY SEARCH.

    IF sy-subrc = 0.

      REPLACE ALL OCCURRENCES OF: '<VALOR>' IN <fs_line>-text WITH cs_gerar_boleto-valor,
                                  '<DESC>'  IN <fs_line>-text WITH cs_gerar_boleto-valorabat,
                                  '<TOTAL>' IN <fs_line>-text WITH cs_gerar_boleto-valorcob,
                                  '<MULTA>' IN <fs_line>-text WITH cs_gerar_boleto-valor_cd,
                                  lv_lf     IN <fs_line>-text WITH '#'.

      SPLIT <fs_line>-text AT '#' INTO TABLE DATA(lt_text).

      IF lt_text IS NOT INITIAL.
        LOOP AT lt_text ASSIGNING FIELD-SYMBOL(<fs_text>).

          APPEND VALUE #( texto = <fs_text> ) TO cs_gerar_boleto-instrucao.

        ENDLOOP.
      ENDIF.

    ELSE.
      EXIT.
    ENDIF.

  ENDMETHOD.


  METHOD set_boleto_email.

    LOOP AT gt_boletos_all ASSIGNING FIELD-SYMBOL(<fs_line>).

      APPEND INITIAL LINE TO rt_boleto_email ASSIGNING FIELD-SYMBOL(<fs_return>).

      <fs_return> = CORRESPONDING #( <fs_line> ).

    ENDLOOP.

    SORT gt_boleto_smart BY xblnr bukrs belnr gjahr buzei.

  ENDMETHOD.


  METHOD execute_boleto_normal.

    DATA: ls_control_parameters TYPE ssfctrlop,
          ls_output_options     TYPE ssfcompop,
          ls_otf_data           TYPE ssfcrescl.

    DATA: lv_fm_name TYPE rs38l_fnam.

    ls_control_parameters-no_dialog = set_no_dialog( ).
*    ls_control_parameters-device    = gs_param-device.
    ls_control_parameters-preview   = set_preview( ).
    ls_control_parameters-getotf    = set_otf( ).
    ls_output_options-tdnewid       = abap_true.
    ls_output_options-tdimmed       = abap_true.
*    ls_output_options-tddest        = gc_bol-device.
    ls_output_options-tddest        = gs_param-device.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = gc_bol-formname
      IMPORTING
        fm_name            = lv_fm_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT gt_boletos_all INTO DATA(ls_boleto).   "#EC CI_LOOP_INTO_WA

      READ TABLE gt_boleto_smart INTO DATA(ls_smart)
                                  WITH KEY bukrs = ls_boleto-bukrs
                                           belnr = ls_boleto-belnr
                                           gjahr = ls_boleto-gjahr
                                           buzei = ls_boleto-buzei
                                           BINARY SEARCH.

      FREE: ls_otf_data.

      CALL FUNCTION lv_fm_name
        EXPORTING
          control_parameters = ls_control_parameters
          output_options     = ls_output_options
          user_settings      = space
          gt_dados_boleto    = ls_smart
        IMPORTING
          job_output_info    = ls_otf_data
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

      IF sy-subrc IS INITIAL.
        IF ls_control_parameters-getotf = abap_true.
          download_file( is_otf_data = ls_otf_data
                         iv_kunnr    = ls_boleto-kunnr
                         iv_xblnr    = ls_boleto-xblnr
                         iv_buzei    = ls_boleto-buzei
                        ).
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD atualiza_documento.

    LOOP AT gt_boletos_all ASSIGNING FIELD-SYMBOL(<fs_boleto>).
      IF <fs_boleto>-xref3 IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      DATA lt_acchg TYPE TABLE OF accchg.
      lt_acchg = VALUE #( (
        fdname = 'XREF3'
        newval = <fs_boleto>-belnr+2(8) && <fs_boleto>-buzei+2(1) && <fs_boleto>-gjahr+2(2)
      ) ).
      CALL FUNCTION 'FI_DOCUMENT_CHANGE'
        EXPORTING
          i_buzei              = <fs_boleto>-buzei
          i_bukrs              = <fs_boleto>-bukrs
          i_belnr              = <fs_boleto>-belnr
          i_gjahr              = <fs_boleto>-gjahr
        TABLES
          t_accchg             = lt_acchg
        EXCEPTIONS
          no_reference         = 1
          no_document          = 2
          many_documents       = 3
          wrong_input          = 4
          overwrite_creditcard = 5
          OTHERS               = 6.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD download_file.

    DATA: lt_tab_otf_final TYPE TABLE OF itcoo,
          lt_pdf_tab       TYPE TABLE OF tline.

    DATA: lv_bin_filesize TYPE i,
          lv_item         TYPE i.

    FREE lt_tab_otf_final[].

    lt_tab_otf_final = is_otf_data-otfdata.

    CALL FUNCTION 'CONVERT_OTF'
      EXPORTING
        format                = 'PDF'
        max_linewidth         = 132
      IMPORTING
        bin_filesize          = lv_bin_filesize
      TABLES
        otf                   = lt_tab_otf_final
        lines                 = lt_pdf_tab
      EXCEPTIONS
        err_max_linewidth     = 1
        err_format            = 2
        err_conv_not_possible = 3
        err_bad_otf           = 4
        OTHERS                = 5.

    IF sy-subrc = 0.

      lv_item = iv_buzei.

      DATA(lv_filename) = |{ TEXT-001 }_{ iv_kunnr }-{ lv_item }_{ iv_xblnr(16) }.pdf|.

      WAIT UP TO 1 SECONDS.

      cl_gui_frontend_services=>gui_download( EXPORTING bin_filesize = lv_bin_filesize
                                                        filetype     = 'BIN'
                                                        filename     = lv_filename
                                               CHANGING data_tab     = lt_pdf_tab
                                               EXCEPTIONS
                                               OTHERS       = 24 ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
