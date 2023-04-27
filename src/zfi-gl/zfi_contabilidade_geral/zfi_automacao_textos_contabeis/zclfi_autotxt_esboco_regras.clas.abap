CLASS zclfi_autotxt_esboco_regras DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_regra,
        Regra TYPE zi_fi_cfg_auto_textos_regras-Regra,
      END OF ty_regra,

      BEGIN OF ty_sel_Empresa,
        CritSelCompany TYPE zi_fi_cfg_autotxt_crit_empresa-CritSelCompany,
        SignCompany    TYPE zi_fi_cfg_autotxt_crit_empresa-SignCompany,
        OptCompany     TYPE zi_fi_cfg_autotxt_crit_empresa-OptCompany,
        LowCompany     TYPE zi_fi_cfg_autotxt_crit_empresa-LowCompany,
        HighCompany    TYPE zi_fi_cfg_autotxt_crit_empresa-HighCompany,
      END OF ty_sel_empresa,

      BEGIN OF ty_sel_TipoDoc,
        CritSelDocType TYPE zi_fi_cfg_autotxt_crit_tipodoc-CritSelDocType,
        SignDocType    TYPE zi_fi_cfg_autotxt_crit_tipodoc-SignDocType,
        OptDocType     TYPE zi_fi_cfg_autotxt_crit_tipodoc-OptDocType,
        LowDocType     TYPE zi_fi_cfg_autotxt_crit_tipodoc-LowDocType,
        HighDocType    TYPE zi_fi_cfg_autotxt_crit_tipodoc-HighDocType,
      END OF ty_sel_tipodoc,

      BEGIN OF ty_sel_conta,
        CritSelAccount TYPE  zi_fi_cfg_autotxt_crit_conta-CritSelAccount,
        SignAccount    TYPE  zi_fi_cfg_autotxt_crit_conta-SignAccount,
        OptAccount     TYPE  zi_fi_cfg_autotxt_crit_conta-OptAccount,
        LowAccount     TYPE  zi_fi_cfg_autotxt_crit_conta-LowAccount,
        HighAccount    TYPE  zi_fi_cfg_autotxt_crit_conta-HighAccount,
      END OF  ty_sel_conta,

      BEGIN OF ty_sel_chave,
        CritSelPostingKey TYPE zi_fi_cfg_autotxt_crit_chave-CritSelPostingKey,
        SignPostingKey    TYPE zi_fi_cfg_autotxt_crit_chave-SignPostingKey,
        OptPostingKey     TYPE zi_fi_cfg_autotxt_crit_chave-OptPostingKey,
        LowPostingKey     TYPE zi_fi_cfg_autotxt_crit_chave-LowPostingKey,
        HighPostingKey    TYPE zi_fi_cfg_autotxt_crit_chave-HighPostingKey,
      END OF ty_Sel_chave,

      BEGIN OF ty_sel_tipo_atualiza,
        CritSelTreasuryUpdateType TYPE zi_fi_cfg_autotxt_crit_flowtp-CritSelTreasuryUpdateType,
        SignTreasuryUpdateType    TYPE zi_fi_cfg_autotxt_crit_flowtp-SignTreasuryUpdateType,
        OptTreasuryUpdateType     TYPE zi_fi_cfg_autotxt_crit_flowtp-OptTreasuryUpdateType,
        LowTreasuryUpdateType     TYPE zi_fi_cfg_autotxt_crit_flowtp-LowTreasuryUpdateType,
        HighTreasuryUpdateType    TYPE zi_fi_cfg_autotxt_crit_flowtp-HighTreasuryUpdateType,
      END OF ty_sel_tipo_atualiza,

      BEGIN OF ty_Sel_tipo_prod,
        CritSelFIProdType TYPE zi_fi_cfg_autotxt_crit_prodtp-CritSelFIProdType,
        SignFIProdType    TYPE zi_fi_cfg_autotxt_crit_prodtp-SignFIProdType,
        OptFIProdType     TYPE zi_fi_cfg_autotxt_crit_prodtp-OptFIProdType,
        LowFIProdType     TYPE zi_fi_cfg_autotxt_crit_prodtp-LowFIProdType,
        HighFIProdType    TYPE zi_fi_cfg_autotxt_crit_prodtp-HighFIProdType,
      END OF ty_sel_tipo_prod.

    TYPES:
      ty_empresas_t             TYPE SORTED TABLE OF bukrs WITH UNIQUE KEY table_line,
      ty_tipo_documento_t       TYPE SORTED TABLE OF blart WITH UNIQUE KEY table_line,
      ty_chave_lancto_t         TYPE SORTED TABLE OF bschl WITH UNIQUE KEY table_line,
      ty_conta_t                TYPE SORTED TABLE OF hkont WITH NON-UNIQUE KEY table_line,
      ty_tipo_atualiza_t        TYPE SORTED TABLE OF tpm_dis_flowtype WITH UNIQUE KEY table_line,
      ty_tipo_produto_t         TYPE SORTED TABLE OF vvsart WITH UNIQUE KEY table_line,

      ty_regra_t                TYPE STANDARD TABLE OF ty_regra,
      ty_range_empresa_t        TYPE RANGE OF bukrs,
      ty_range_tipo_documento_t TYPE RANGE OF blart,
      ty_range_chave_lancto_t   TYPE RANGE OF bschl,
      ty_range_conta_t          TYPE RANGE OF hkont,
      ty_range_tipo_atualiza_t  TYPE RANGE OF tpm_dis_flowtype,
      ty_range_tipo_produto_t   TYPE RANGE OF vvsart.

    METHODS:
      constructor
        IMPORTING
*          it_regra             TYPE ty_regra_t
          it_sel_empresa       TYPE ty_range_empresa_t
          it_sel_tipodoc       TYPE ty_range_tipo_documento_t
          it_sel_conta         TYPE ty_range_conta_t
          it_sel_chave         TYPE ty_range_chave_lancto_t
          it_sel_tipo_atualiza TYPE ty_range_tipo_atualiza_t
          it_sel_tipo_prod     TYPE ty_range_tipo_produto_t,

      verifica_conflito_de_regra
        IMPORTING io_regra_existente TYPE REF TO zclfi_autotxt_selecao_regras
        RETURNING VALUE(rt_result)   TYPE bapiret2_tab.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      gt_empresas          TYPE ty_empresas_t,
      gt_tipo_documento    TYPE ty_tipo_documento_t,
      gt_chave_lancto      TYPE ty_chave_lancto_t,
      gt_conta             TYPE ty_conta_t,
      gt_tipo_atualiza     TYPE ty_tipo_atualiza_t,
      gt_tipo_produto      TYPE ty_tipo_produto_t,
*      gt_regra             TYPE ty_regra_t,
      gt_sel_empresa       TYPE ty_range_empresa_t,
      gt_sel_tipodoc       TYPE ty_range_tipo_documento_t,
      gt_sel_conta         TYPE ty_range_conta_t,
      gt_sel_chave         TYPE ty_range_chave_lancto_t,
      gt_sel_tipo_atualiza TYPE ty_range_tipo_atualiza_t,
      gt_sel_tipo_prod     TYPE ty_range_tipo_produto_t.

    METHODS:
      compara_empresas
        IMPORTING it_reg_existe_empresa TYPE zclfi_autotxt_selecao_regras=>ty_empresas_t
        RETURNING VALUE(rv_result)      TYPE abap_bool,

      compara_tipo_atualiza
        IMPORTING it_reg_existe_tipo_atual TYPE zclfi_autotxt_selecao_regras=>ty_tipo_atualiza_t
        RETURNING VALUE(rv_result)         TYPE abap_bool,

      compara_tipo_produto
        IMPORTING it_reg_existe_tipo_prod TYPE zclfi_autotxt_selecao_regras=>ty_tipo_produto_t
        RETURNING VALUE(rv_result)        TYPE abap_bool,

      compara_tipo_documento
        IMPORTING it_reg_existe_tipo_doc TYPE zclfi_autotxt_selecao_regras=>ty_tipo_documento_t
        RETURNING VALUE(rv_result)       TYPE abap_bool,

      compara_chave_lancto
        IMPORTING it_reg_existe_chave TYPE zclfi_autotxt_selecao_regras=>ty_chave_lancto_t
        RETURNING VALUE(rv_result)    TYPE abap_bool,

      compara_conta
        IMPORTING it_reg_existe_conta TYPE zclfi_autotxt_selecao_regras=>ty_conta_t

        RETURNING VALUE(rv_result)    TYPE abap_bool,

      seleciona_empresas
        RETURNING VALUE(rt_result) TYPE ty_empresas_t,

      seleciona_tipo_atualiza
        RETURNING VALUE(rt_result) TYPE ty_tipo_atualiza_t,

      seleciona_tipo_produto
        RETURNING VALUE(rt_result) TYPE ty_tipo_produto_t,

      seleciona_tipo_documento
        RETURNING VALUE(rt_result) TYPE ty_tipo_documento_t,

      seleciona_chave_lancto
        RETURNING VALUE(rt_result) TYPE ty_chave_lancto_t,

      seleciona_conta
        RETURNING VALUE(rt_result) TYPE ty_conta_t.


ENDCLASS.



CLASS zclfi_autotxt_esboco_regras IMPLEMENTATION.

  METHOD constructor.

*    me->gt_regra             = it_regra.

    me->gt_sel_empresa       = it_sel_empresa.
    me->gt_sel_tipodoc       = it_sel_tipodoc.
    me->gt_sel_conta         = it_sel_conta.
    me->gt_sel_chave         = it_sel_chave.
    me->gt_sel_tipo_atualiza = it_sel_tipo_atualiza.
    me->gt_sel_tipo_prod     = it_sel_tipo_prod.

  ENDMETHOD.

  METHOD seleciona_empresas.

    IF me->gt_empresas IS NOT INITIAL.

      rt_result = me->gt_empresas.
      RETURN.

    ENDIF.

    DATA(lt_range_bukrs) = me->gt_sel_empresa.
    IF lt_range_bukrs IS INITIAL.
      RETURN.
    ENDIF.

    SELECT
        CompanyCode
    FROM zi_ca_vh_company
    WHERE CompanyCode IN @lt_range_bukrs
    INTO TABLE @me->gt_empresas.

    IF sy-subrc EQ 0.
      rt_result = me->gt_empresas.
    ENDIF.

  ENDMETHOD.


  METHOD seleciona_tipo_atualiza.

    IF me->gt_tipo_atualiza IS NOT INITIAL.

      rt_result = me->gt_tipo_atualiza.
      RETURN.

    ENDIF.

    DATA(lt_range_dflowtype) = me->gt_sel_tipo_atualiza.
    IF lt_range_dflowtype IS INITIAL.
      RETURN.
    ENDIF.

    SELECT
        TreasuryUpdateType
    FROM zi_fi_vh_treasuryupdatetype
    WHERE TreasuryUpdateType IN @lt_range_dflowtype
    INTO TABLE @me->gt_tipo_atualiza.

    IF sy-subrc EQ 0.
      rt_result = me->gt_tipo_atualiza.
    ENDIF.


  ENDMETHOD.

  METHOD seleciona_chave_lancto.

    IF me->gt_chave_lancto IS NOT INITIAL.

      rt_result = me->gt_chave_lancto.
      RETURN.

    ENDIF.

    DATA(lt_range_bschl) = me->gt_sel_chave.
    IF lt_range_bschl IS INITIAL.
      RETURN.
    ENDIF.

    SELECT
        PostingKey
    FROM zi_ca_vh_bschl
    WHERE PostingKey IN @lt_range_bschl
    INTO TABLE @me->gt_chave_lancto.

    IF sy-subrc EQ 0.
      rt_result = me->gt_chave_lancto.
    ENDIF.


  ENDMETHOD.

  METHOD seleciona_conta.

    IF me->gt_conta IS NOT INITIAL.

      rt_result = me->gt_conta.
      RETURN.

    ENDIF.

    DATA(lt_range_hkont) = me->gt_sel_conta.
    IF lt_range_hkont IS INITIAL.
      RETURN.
    ENDIF.

    SELECT DISTINCT
        GLAccount
    FROM zi_fi_vh_saknr_pc3c
    WHERE GLAccount IN @lt_range_hkont
    INTO TABLE @me->gt_conta.

    IF sy-subrc EQ 0.
      rt_result = me->gt_conta.
    ENDIF.


  ENDMETHOD.

  METHOD seleciona_tipo_documento.

    IF me->gt_tipo_documento IS NOT INITIAL.

      rt_result = me->gt_tipo_documento.
      RETURN.

    ENDIF.

    DATA(lt_range_blart) = me->gt_sel_tipodoc.
    IF lt_range_blart IS INITIAL.
      RETURN.
    ENDIF.

    SELECT
        DocType
    FROM zi_ca_vh_doctype
    WHERE DocType IN @lt_range_blart
    INTO TABLE @me->gt_tipo_documento.

    IF sy-subrc EQ 0.
      rt_result = me->gt_tipo_documento.
    ENDIF.


  ENDMETHOD.

  METHOD seleciona_tipo_produto.

    IF me->gt_tipo_produto IS NOT INITIAL.

      rt_result = me->gt_tipo_produto.
      RETURN.

    ENDIF.

    DATA(lt_range_gsart) = me->gt_sel_tipo_prod.
    IF lt_range_gsart IS INITIAL.
      RETURN.
    ENDIF.

    SELECT
        FinancialInstrumentProductType
    FROM zi_fi_vh_fiinstrprodttype
    WHERE FinancialInstrumentProductType IN @lt_range_gsart
    INTO TABLE @me->gt_tipo_produto.

    IF sy-subrc EQ 0.
      rt_result = me->gt_tipo_produto.
    ENDIF.


  ENDMETHOD.

  METHOD verifica_conflito_de_regra.

    IF me->gt_sel_empresa IS INITIAL
        AND me->gt_sel_tipodoc IS INITIAL
        AND me->gt_sel_conta IS INITIAL
        AND me->gt_sel_chave IS INITIAL
        AND me->gt_sel_tipo_atualiza IS INITIAL
        AND me->gt_sel_tipo_prod IS INITIAL.

      RETURN.

    ENDIF.

    " Critérios da regra analisada
    io_regra_existente->recupera_criterios(
      IMPORTING
        et_empresas       = DATA(lt_reg_existe_empresa)
        et_tipo_documento = DATA(lt_reg_existe_tipo_doc)
        et_chave_lancto   = DATA(lt_reg_existe_chave_lancto)
        et_conta          = DATA(lt_reg_existe_conta)
        et_tipo_atualiza  = DATA(lt_reg_existe_tipo_atualiza)
        et_tipo_produto   = DATA(lt_reg_existe_tipo_produto)
    ).

    IF me->compara_chave_lancto( lt_reg_existe_chave_lancto ) EQ abap_true
        AND me->compara_conta( lt_reg_existe_conta  ) EQ abap_true
        AND me->compara_empresas( lt_reg_existe_empresa ) EQ abap_true
        AND me->compara_tipo_atualiza( lt_reg_existe_tipo_atualiza ) EQ abap_true
        AND me->compara_tipo_documento( lt_reg_existe_tipo_doc ) EQ abap_true
        AND me->compara_tipo_produto( lt_reg_existe_tipo_produto ) EQ abap_true.

      DATA(ls_regra_existente) = io_regra_existente->recupera_regra( ).

      rt_result = VALUE bapiret2_tab(
                                      ( id = zclfi_auto_txt_log=>gc_msgid
                                        type = if_xo_const_message=>error
                                        number = 001
                                        message_v1 = ls_regra_existente-regra )
      ).

    ENDIF.

  ENDMETHOD.

  METHOD compara_chave_lancto.

    DATA(lt_chave_lancto) = me->seleciona_chave_lancto( ).

    IF lt_chave_lancto IS INITIAL
        AND it_reg_existe_chave IS INITIAL.

      rv_result = abap_true.
      RETURN.

    ENDIF.

*rv_result = reduce abap_bool( init lv_criterio_repetido = abap_false
*                              for ls_chave_lancto in lt_chave_lancto
*                              for ls_regra_existe in it_reg_existe_chave where ( table_line = ls_chave_lancto-table_line )
*                              next lv_criterio_repetido
*).

    DATA(lt_compara) = FILTER ty_chave_lancto_t( lt_chave_lancto IN it_reg_existe_chave
                                                    WHERE table_line = table_line ).

    IF lt_compara IS NOT INITIAL.
      rv_result = abap_true.
    ENDIF.


  ENDMETHOD.

  METHOD compara_conta.

    DATA(lt_conta) = me->seleciona_conta( ).

    IF lt_conta IS INITIAL
        AND it_reg_existe_conta IS INITIAL.

      rv_result = abap_true.
      RETURN.

    ENDIF.

    DATA(lt_compara) = FILTER ty_conta_t( lt_conta IN it_reg_existe_conta
                                             WHERE table_line = table_line ).

    IF lt_compara IS NOT INITIAL.
      rv_result = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD compara_empresas.

    DATA(lt_empresas) = me->seleciona_empresas( ).

    IF lt_empresas IS INITIAL
        AND it_reg_existe_empresa IS INITIAL.

      rv_result = abap_true.
      RETURN.

    ENDIF.

    DATA(lt_compara) = FILTER ty_empresas_t( lt_empresas IN it_reg_existe_empresa
                                                    WHERE table_line = table_line ).

    IF lt_compara IS NOT INITIAL.
      rv_result = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD compara_tipo_atualiza.

    DATA(lt_tipo_atualiza) = me->seleciona_tipo_atualiza(  ).

    IF lt_tipo_atualiza IS INITIAL
        AND it_reg_existe_tipo_atual IS INITIAL.

      rv_result = abap_true.
      RETURN.

    ENDIF.

    DATA(lt_compara) = FILTER ty_tipo_atualiza_t( lt_tipo_atualiza IN it_reg_existe_tipo_atual
                                                    WHERE table_line = table_line ).

    IF lt_compara IS NOT INITIAL.
      rv_result = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD compara_tipo_documento.

    DATA(lt_tipo_documento) = me->seleciona_tipo_documento( ).

    IF lt_tipo_documento IS INITIAL
        AND it_reg_existe_tipo_doc IS INITIAL.

      rv_result = abap_true.
      RETURN.

    ENDIF.

    DATA(lt_compara) = FILTER ty_tipo_documento_t( lt_tipo_documento IN it_reg_existe_tipo_doc
                                                    WHERE table_line = table_line ).

    IF lt_compara IS NOT INITIAL.
      rv_result = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD compara_tipo_produto.

    DATA(lt_tipo_produto) = me->seleciona_tipo_produto( ).

    IF lt_tipo_produto IS INITIAL
        AND it_reg_existe_tipo_prod IS INITIAL.

      rv_result = abap_true.
      RETURN.

    ENDIF.

    DATA(lt_compara) = FILTER ty_tipo_produto_t( lt_tipo_produto IN it_reg_existe_tipo_prod
                                                    WHERE table_line = table_line ).

    IF lt_compara IS NOT INITIAL.
      rv_result = abap_true.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
