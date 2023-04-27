class ZCLFI_CONTRATOS_CONTAB definition
  public
  final
  create public .

public section.

  types:
    ty_accit       TYPE TABLE OF  accit .
  types:
    ty_acccr       TYPE TABLE OF  acccr .
  types:
    ty_accfi       TYPE TABLE OF  accfi .
  types:
    ty_vbrp       TYPE TABLE OF  vbrpvb .
  types:
    ty_contrato    TYPE TABLE OF ztfi_contrato .
  types:
    BEGIN OF ty_client,
        cliente  TYPE zi_fi_raiz_clientes-cliente,
        empresa  TYPE zi_fi_raiz_clientes-empresa,
        contrato TYPE zi_fi_raiz_clientes-contrato,
      END OF   ty_client .
  types:
    ty_cnpj_client TYPE TABLE OF ty_client .
  types:
    BEGIN OF ty_doc_uuid_h,
        doc_uuid_h TYPE sysuuid_x16,
      END OF   ty_doc_uuid_h .
  types:
    tt_doc_uuid_h TYPE TABLE OF ty_doc_uuid_h .
  types:
    ty_cont_cont  TYPE TABLE OF ztfi_cont_cont .

    "! Executa atualização tabela contratos de contabilização
    "! @parameter is_cvbrk  | Documento de faturamento: dados de cabeçalho
    "! @parameter it_xaccit | Interface com contabilidade: informação sobre item
    "! @parameter it_xaccfi | Interface com a contabilidade: contabilidade financeira CtaO
    "! @parameter it_xacccr | Interface com contabilidade: informação sobre moeda
  methods EXECUTAR
    importing
      !IS_CVBRK type VBRK
      !IS_CVBRP type VBRPVB
      !IT_CVBRP type TY_VBRP
      !IT_XACCIT type TY_ACCIT
      !IT_XACCFI type TY_ACCFI
      !IT_XACCCR type TY_ACCCR
      !IT_DOC_UUID_H type TT_DOC_UUID_H
    exporting
      !ET_RETURN type BAPIRET2_T .
protected section.
private section.

  methods BUSCA_CONTRATOS
    importing
      !IS_CVBRK type VBRK
    exporting
      !ET_CNPJ_CLIENT type TY_CNPJ_CLIENT .
  methods CALCULA_MONTANTE
    importing
      !IT_XACCIT type ZCLFI_CONTRATOS_CONTAB=>TY_ACCIT
      !IT_XACCCR type ZCLFI_CONTRATOS_CONTAB=>TY_ACCCR
    exporting
      !EV_WRBTR_40 type WRBTR .
  methods CONTRATOS_ATIVOS
    importing
      !IT_DOC_UUID_H type TT_DOC_UUID_H
      !IT_CNPJ_CLIENT type TY_CNPJ_CLIENT optional
    exporting
      !ET_CONTRATO type TY_CONTRATO .
  methods PREENCHE_DADOS
    importing
      !IT_CONTRATO type TY_CONTRATO
      !IV_WRBTR_40 type WRBTR
      !IS_CVBRK type VBRK
      !IS_CVBRP type VBRPVB
      !IT_CVBRP type TY_VBRP
    exporting
      !ET_DOC type TY_CONT_CONT .
  methods SALVA_DADOS
    importing
      !IT_DOC type TY_CONT_CONT
    exporting
      value(ET_RETURN) type BAPIRET2_T .
ENDCLASS.



CLASS ZCLFI_CONTRATOS_CONTAB IMPLEMENTATION.


  METHOD executar.

* ---------------------------------------------------------------------------
* Calcula Montante
* ---------------------------------------------------------------------------

    me->calcula_montante( EXPORTING
                           it_xaccit = it_xaccit
                           it_xacccr = it_xacccr
                          IMPORTING
                           ev_wrbtr_40 = DATA(lv_wrbtr_40)  ).
* ---------------------------------------------------------------------------
* Busca Contratos
* ---------------------------------------------------------------------------
*    me->busca_contratos( EXPORTING
*                           is_cvbrk = is_cvbrk
*                         IMPORTING
*                           et_cnpj_client = DATA(lt_cnpj_client)  ).


* ---------------------------------------------------------------------------
* Busca Contratos Ativos
* ---------------------------------------------------------------------------
    me->contratos_ativos( EXPORTING
                           it_doc_uuid_h   = it_doc_uuid_h
*                           it_cnpj_client  = lt_cnpj_client
                         IMPORTING
                           et_contrato = DATA(lt_contrato)  ).

* ---------------------------------------------------------------------------
* Preenche dados para tabela
* ---------------------------------------------------------------------------
    CHECK lt_contrato[] IS NOT INITIAL.

    me->preenche_dados( EXPORTING
                   it_contrato   = lt_contrato
                   is_cvbrk      = is_cvbrk
                   is_cvbrp      = is_cvbrp
                   it_cvbrp      = it_cvbrp
                   iv_wrbtr_40   = lv_wrbtr_40
                 IMPORTING
                   et_doc = DATA(lt_doc) ).

    "Tabela exportada para Enhancement ZEIFI_RV_INVOICE_DOCUMENT_ADD
    "include ZFII_GRAVA_DOC_CONTABIL no final da função RV_INVOICE_DOCUMENT_ADD
    "para a gravação do documento contábil gerado (BSID)
    EXPORT lt_doc FROM lt_doc TO MEMORY ID 'ZTFI_CONT_CONT'.
* ---------------------------------------------------------------------------
* Grava dados na tabela
* ---------------------------------------------------------------------------

*    CHECK lt_doc[] IS NOT INITIAL.
*
*    me->salva_dados( EXPORTING
*     it_doc   = lt_doc
*   IMPORTING
*     et_return = DATA(lt_return)  ).


  ENDMETHOD.


  METHOD busca_contratos.

    SELECT empresa, cliente, contrato                   "#EC CI_SEL_DEL
    FROM zi_fi_raiz_clientes
    WHERE empresa = @is_cvbrk-bukrs AND
          cliente = @is_cvbrk-kunag
      INTO TABLE @DATA(lt_cnpj_client).

    SORT lt_cnpj_client BY contrato.
    DELETE ADJACENT DUPLICATES FROM  lt_cnpj_client COMPARING contrato.
    et_cnpj_client[] = lt_cnpj_client[].

  ENDMETHOD.


  METHOD calcula_montante.

    DATA(lt_xaccit) = it_xaccit[].
    DATA(lt_xacccr) = it_xacccr[].
    DATA: lv_wrbtr_40 TYPE acbtr_rw.
*    DATA: lv_wrbtr_40_aux TYPE bschl.
    DATA: lv_cont TYPE n.

    CONSTANTS: lc_40 TYPE char2 VALUE 40.

*    SORT lt_xaccit BY bschl.
*    SORT lt_xacccr BY wrbtr.
    SORT lt_xaccit BY posnr.
    SORT lt_xacccr BY posnr.

    LOOP AT it_xaccit ASSIGNING FIELD-SYMBOL(<fs_xacci>).

      IF <fs_xacci>-bschl = lc_40.


        READ TABLE lt_xacccr ASSIGNING FIELD-SYMBOL(<fs_xacccr>)
                                WITH KEY posnr = <fs_xacci>-posnr
                                BINARY SEARCH.
        IF sy-subrc = 0.

          lv_wrbtr_40 = <fs_xacccr>-wrbtr + lv_wrbtr_40.
          ADD 1 TO lv_cont.

        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lv_wrbtr_40 IS NOT INITIAL AND
       lv_cont IS NOT INITIAL.
      ev_wrbtr_40 = lv_wrbtr_40 / lv_cont.
    ENDIF.

  ENDMETHOD.


  METHOD contratos_ativos.

    CHECK it_doc_uuid_h[] IS NOT INITIAL.

    SELECT *  "bukrs, kunnr, contrato
     FROM ztfi_contrato
     INTO TABLE @DATA(lt_contrato)
*      FOR ALL ENTRIES IN @it_cnpj_client
      FOR ALL ENTRIES IN @it_doc_uuid_h
*     WHERE contrato EQ @it_cnpj_client-contrato AND
     WHERE doc_uuid_h EQ @it_doc_uuid_h-doc_uuid_h AND
           desativado EQ @abap_false.

    SORT lt_contrato BY contrato.
    IF lt_contrato[] IS NOT INITIAL.
      et_contrato[] = lt_contrato[].
    ENDIF.

  ENDMETHOD.


  METHOD preenche_dados.

    DATA(lt_itens) = it_contrato[].
    SORT: lt_itens BY contrato.
    DATA: lv_cont    TYPE n,
          lv_zzkzwi1 TYPE kzwis.

    DATA(lv_ano) = sy-datum+0(4).

    LOOP AT it_cvbrp ASSIGNING FIELD-SYMBOL(<fs_cvbrp>).
      ADD <fs_cvbrp>-zzkzwi1 TO lv_zzkzwi1.
    ENDLOOP.

    LOOP AT lt_itens ASSIGNING FIELD-SYMBOL(<fs_itens>).

      APPEND INITIAL LINE TO et_doc ASSIGNING FIELD-SYMBOL(<fs_doc>).

*      ADD 1 TO lv_cont.

* ----------------------------------------------------------------------
* preenche dados documentos
* ----------------------------------------------------------------------
      <fs_doc>-doc_cont_id            = <fs_itens>-doc_uuid_h.
      <fs_doc>-contrato               =  <fs_itens>-contrato.
      <fs_doc>-aditivo                =  <fs_itens>-aditivo.
*      <fs_doc>-aditivo                =  lv_cont.
      <fs_doc>-bukrs                  =  is_cvbrk-bukrs.
      <fs_doc>-kunnr                  =  is_cvbrk-knkli.
      <fs_doc>-belnr                  =  is_cvbrk-belnr.
      <fs_doc>-gjahr                  =  lv_ano.
      <fs_doc>-numero_item            =  is_cvbrp-dp_buzei.
      <fs_doc>-budat                  =  sy-datum.
      <fs_doc>-wrbtr                  =  iv_wrbtr_40.
      <fs_doc>-waers                  =  'BRL'.
      <fs_doc>-bzirk                  =  is_cvbrk-bzirk.
      <fs_doc>-canal                  =  is_cvbrk-vtweg.
      <fs_doc>-setor                  =  is_cvbrk-spart.
      <fs_doc>-vkorg                  =  is_cvbrk-vkorg.
      <fs_doc>-tipo_desc              =  'F'.
*      <fs_doc>-doc_provisao           =  <fs_itens>-doc_provisao.
*      <fs_doc>-exerc_provisao         =  <fs_itens>-exerc_provisao.
      <fs_doc>-mont_provisao          =  lv_zzkzwi1.
*      <fs_doc>-doc_liquidacao         =  <fs_itens>-doc_liquidacao.
*      <fs_doc>-exerc_liquidacao       =  <fs_itens>-exerc_liquidacao.
*      <fs_doc>-mont_liquidacao        =  <fs_itens>-mont_liquidacao.
*      <fs_doc>-doc_estorno            =  <fs_itens>-doc_estorno.
*      <fs_doc>-exerc_estorno          =  <fs_itens>-exerc_estorno.
*      <fs_doc>-mont_estorno           =  <fs_itens>-mont_estorno.
      <fs_doc>-status_provisao        = 1.
      <fs_doc>-tipo_dado              = 'S'.
      <fs_doc>-created_by             = sy-uname.
      GET TIME STAMP FIELD <fs_doc>-created_at.
      <fs_doc>-local_last_changed_at  = <fs_doc>-created_at.

    ENDLOOP.
  ENDMETHOD.


  METHOD salva_dados.

    FREE: et_return.

    MODIFY ztfi_cont_cont FROM TABLE it_doc.
    IF sy-subrc NE 0.
      " Falha ao salvar dados de carga.
      et_return[] = VALUE #( BASE et_return ( type = 'E' id = 'ZFI_CONTRATO_CONTAB' number = '000' ) ).
      RETURN.
    ENDIF.
  ENDMETHOD. "#EC CI_VALPAR
ENDCLASS.
