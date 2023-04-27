CLASS zclfi_autotxt_selecao_regras DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      ty_empresas_t       TYPE SORTED TABLE OF bukrs WITH UNIQUE KEY table_line,
      ty_tipo_documento_t TYPE SORTED TABLE OF blart WITH UNIQUE KEY table_line,
      ty_chave_lancto_t   TYPE SORTED TABLE OF bschl WITH UNIQUE KEY table_line,
      ty_conta_t          TYPE SORTED TABLE OF hkont WITH NON-UNIQUE KEY table_line,
      ty_tipo_atualiza_t  TYPE SORTED TABLE OF tpm_dis_flowtype WITH UNIQUE KEY table_line,
      ty_tipo_produto_t   TYPE SORTED TABLE OF vvsart WITH UNIQUE KEY table_line.


    METHODS:
      constructor
        IMPORTING
          is_regra TYPE zclfi_auto_txt_contab=>ty_regras
          io_log   TYPE REF TO zclfi_auto_txt_log OPTIONAL,

      recupera_criterios
        EXPORTING
          et_empresas       TYPE ty_empresas_t
          et_tipo_documento TYPE ty_tipo_documento_t
          et_chave_lancto   TYPE ty_chave_lancto_t
          et_conta          TYPE ty_conta_t
          et_tipo_atualiza  TYPE ty_tipo_atualiza_t
          et_tipo_produto   TYPE ty_tipo_produto_t,

      recupera_regra
        RETURNING VALUE(rs_result) TYPE zclfi_auto_txt_contab=>ty_regras,

      executa
        CHANGING ct_documentos TYPE zclfi_auto_txt_contab=>ty_documentos_contab_t.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_campos,
        Id        TYPE zi_fi_cfg_auto_textos_campos-Id,
        Campo     TYPE zi_fi_cfg_auto_textos_campos-Campo,
        Ordenacao TYPE zi_fi_cfg_auto_textos_campos-Ordenacao,
        NomeCampo TYPE zi_fi_cfg_auto_textos_campos-NomeCampo,
      END OF ty_campos.

    TYPES:
      ty_campos_t               TYPE SORTED TABLE OF ty_campos WITH UNIQUE KEY Ordenacao,
      ty_range_empresa_t        TYPE RANGE OF bukrs,
      ty_range_tipo_documento_t TYPE RANGE OF blart,
      ty_range_chave_lancto_t   TYPE RANGE OF bschl,
      ty_range_conta_t          TYPE RANGE OF hkont,
      ty_range_tipo_atualiza_t  TYPE RANGE OF tpm_dis_flowtype,
      ty_range_tipo_produto_t   TYPE RANGE OF vvsart.

    DATA:
      gt_documentos_da_regra TYPE zclfi_auto_txt_contab=>ty_documentos_contab_t,
      gt_campos              TYPE ty_campos_t,

      gt_empresas            TYPE ty_empresas_t,
      gt_tipo_documento      TYPE ty_tipo_documento_t,
      gt_chave_lancto        TYPE ty_chave_lancto_t,
      gt_conta               TYPE ty_conta_t,
      gt_tipo_atualiza       TYPE ty_tipo_atualiza_t,
      gt_tipo_produto        TYPE ty_tipo_produto_t,

      gt_range_bukrs         TYPE ty_range_empresa_t,
      gt_range_blart         TYPE ty_range_tipo_documento_t,
      gt_range_bschl         TYPE ty_range_chave_lancto_t,
      gt_range_hkont         TYPE ty_range_conta_t,
      gt_range_dflowtype     TYPE ty_range_tipo_atualiza_t,
      gt_range_gsart         TYPE ty_range_tipo_produto_t.

    DATA:
      gs_regra TYPE zclfi_auto_txt_contab=>ty_regras.

    DATA:
      "! Log de processamento
      go_log TYPE REF TO zclfi_auto_txt_log.

    METHODS:
      "! Atualiza texto conforme regra localizada para o documento
      "! @parameter iv_texto        | Texto montado conforme regra
      "! @parameter is_documento    | Documento que terá o texto atualizado
      atualiza_texto
        IMPORTING
                  iv_texto                TYPE bseg-sgtxt
                  is_documento            TYPE zclfi_auto_txt_contab=>ty_documentos_contab
        RETURNING VALUE(rv_processado_ok) TYPE abap_bool,

      monta_texto_contabil
        IMPORTING
                  is_documento     TYPE zclfi_auto_txt_contab=>ty_documentos_contab
                  is_campo         TYPE ty_campos
                  iv_texto         TYPE bseg-sgtxt
        RETURNING VALUE(rv_result) TYPE bseg-sgtxt,

      seleciona_campos
        RETURNING VALUE(rt_result) TYPE ty_campos_t,

      seleciona_range_empresas
        RETURNING VALUE(rt_result) TYPE ty_range_empresa_t,

      seleciona_range_tipo_documento
        RETURNING VALUE(rt_result) TYPE ty_range_tipo_documento_t,

      seleciona_range_chave_lancto
        RETURNING VALUE(rt_result) TYPE ty_range_chave_lancto_t,

      seleciona_range_conta
        RETURNING VALUE(rt_result) TYPE ty_range_conta_t,

      seleciona_range_tipo_atualiza
        RETURNING VALUE(rt_result) TYPE ty_range_tipo_atualiza_t,

      seleciona_range_tipo_produto
        RETURNING VALUE(rt_result) TYPE ty_range_tipo_produto_t,

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
        RETURNING VALUE(rt_result) TYPE ty_conta_t,


      busca_documentos_da_regra
        IMPORTING
                  it_documentos    TYPE zclfi_auto_txt_contab=>ty_documentos_contab_t
        RETURNING VALUE(rt_result) TYPE zclfi_auto_txt_contab=>ty_documentos_contab_t,

      processa_documentos_da_regra
        CHANGING ct_documentos TYPE zclfi_auto_txt_contab=>ty_documentos_contab_t.


ENDCLASS.



CLASS zclfi_autotxt_selecao_regras IMPLEMENTATION.

  METHOD constructor.

    me->gs_regra = is_regra.

    me->go_log = io_log.

    me->seleciona_campos( ).

    me->seleciona_range_empresas( ).

    me->seleciona_range_chave_lancto( ).

    me->seleciona_range_conta( ).

    me->seleciona_range_tipo_atualiza( ).

    me->seleciona_range_tipo_documento( ).

    me->seleciona_range_tipo_produto( ).

    me->recupera_criterios(  ).

  ENDMETHOD.

  METHOD seleciona_empresas.

    IF me->gt_empresas IS NOT INITIAL.

      rt_result = me->gt_empresas.
      RETURN.

    ENDIF.

    DATA(lt_range_bukrs) = me->seleciona_range_empresas( ).
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


  METHOD seleciona_range_empresas.

    IF me->gt_range_bukrs IS NOT INITIAL.

      rt_result = me->gt_range_bukrs.
      RETURN.

    ENDIF.

    SELECT
        IdSelCompany,
        CritSelCompany,
        SignCompany,
        OptCompany,
        LowCompany,
        HighCompany
    FROM zi_fi_cfg_autotxt_crit_empresa
    WHERE IdRegra EQ @me->gs_regra-idregra
    INTO TABLE @DATA(lt_sel_empresas).

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    rt_result = me->gt_range_bukrs = VALUE #( FOR ls_sel_empresas IN lt_sel_empresas
                                                ( sign = ls_sel_empresas-signcompany
                                                  option = ls_sel_empresas-optcompany
                                                  low = ls_sel_empresas-lowcompany
                                                  high = ls_sel_empresas-highcompany )
                                      ).

  ENDMETHOD.

  METHOD executa.

    IF me->gt_range_blart IS INITIAL
        AND me->gt_range_bschl IS INITIAL
        AND me->gt_range_bukrs IS INITIAL
        AND me->gt_range_dflowtype IS INITIAL
        AND me->gt_range_gsart IS INITIAL
        AND me->gt_range_hkont IS INITIAL.

      RETURN.

    ENDIF.

    DATA(lt_documentos_da_regra) = me->busca_documentos_da_regra( it_documentos = ct_documentos ).
    IF lt_documentos_da_regra IS INITIAL.
      RETURN.
    ENDIF.

    me->processa_documentos_da_regra( CHANGING ct_documentos = ct_documentos ).

  ENDMETHOD.


  METHOD busca_documentos_da_regra.

    LOOP AT it_documentos ASSIGNING FIELD-SYMBOL(<fs_documentos>).

      IF me->gt_range_bukrs IS NOT INITIAL
        AND <fs_documentos>-bukrs NOT IN me->gt_range_bukrs.

        CONTINUE.

      ENDIF.

      IF me->gt_range_blart IS NOT INITIAL
        AND <fs_documentos>-blart NOT IN me->gt_range_blart.

        CONTINUE.

      ENDIF.

      IF me->gt_range_bschl IS NOT INITIAL
        AND <fs_documentos>-bschl NOT IN me->gt_range_bschl.

        CONTINUE.

      ENDIF.


      IF me->gt_range_hkont IS NOT INITIAL
        AND <fs_documentos>-hkont NOT IN me->gt_range_hkont.

        CONTINUE.

      ENDIF.

      IF me->gt_range_dflowtype IS NOT INITIAL
        AND <fs_documentos>-dis_flowty NOT IN me->gt_range_dflowtype.

        " Validação adicional: Dependendo do range, o standard não interpreta intervalo De - Até como apresentado no Search help
        " Ex.: Se o critério da regra é De = 'MM110--' Até 'MM1100+', o standard não considera 'MM1100-' como valor válido, mas deveria
        " Para este caso, é necessário comparar diretamente com o valor do search help
        IF me->gt_tipo_atualiza IS NOT INITIAL
            AND NOT line_exists( me->gt_tipo_atualiza[ table_line = <fs_documentos>-dis_flowty ] ).

          CONTINUE.

        ENDIF.

      ENDIF.

      IF me->gt_range_gsart IS NOT INITIAL
        AND <fs_documentos>-gsart NOT IN me->gt_range_gsart.

        CONTINUE.

      ENDIF.

      APPEND <fs_documentos> TO me->gt_documentos_da_regra.

    ENDLOOP.

    rt_result = me->gt_documentos_da_regra.

  ENDMETHOD.

  METHOD seleciona_campos.

    IF me->gt_campos IS NOT INITIAL.

      rt_result = me->gt_campos.
      RETURN.

    ENDIF.

    SELECT
        Id,
        Campo,
        Ordenacao,
        NomeCampo
    FROM zi_fi_cfg_auto_textos_campos
    WHERE IdRegra EQ @me->gs_regra-idregra
    INTO TABLE @me->gt_campos.

    IF sy-subrc EQ 0.
      rt_result = me->gt_campos.
    ELSE.

      IF me->go_log IS BOUND.

        me->go_log->insert_log(
          EXPORTING
            is_message = VALUE #(
                            type = if_xo_const_message=>warning
                            number = 006
                            message_v1 = CONV #( me->gs_regra-regra ) )
        ).

      ENDIF.
    ENDIF.


  ENDMETHOD.

  METHOD processa_documentos_da_regra.

    DATA:
      lv_texto_contab TYPE bseg-sgtxt.

    IF me->gt_documentos_da_regra IS INITIAL.
      RETURN.
    ENDIF.

    me->gt_documentos_da_regra = VALUE #( LET lt_docs = me->gt_documentos_da_regra IN

                                        FOR ls_documento IN lt_docs

                                        LET lv_novo_texto = REDUCE #(
                                                                INIT lv_txt = VALUE bseg-sgtxt(  )
                                                                FOR ls_campo IN me->gt_campos
                                                                NEXT lv_txt = me->monta_texto_contabil(
                                                                                is_documento = ls_documento
                                                                                is_campo = ls_campo
                                                                                iv_texto = lv_txt )
                                        ) IN
                                          ( bukrs       = ls_documento-bukrs
                                            belnr       = ls_documento-belnr
                                            gjahr       = ls_documento-gjahr
                                            buzei       = ls_documento-buzei
                                            monat       = ls_documento-monat
                                            kostl       = ls_documento-kostl
                                            lifnr       = ls_documento-lifnr
                                            kunnr       = ls_documento-kunnr
                                            awkey       = ls_documento-awkey
                                            sgtxt       = ls_documento-sgtxt
                                            LifnrName   = ls_documento-LifnrName
                                            KunnrName   = ls_documento-KunnrName
                                            hkonttxt    = ls_documento-hkonttxt
                                            xblnr       = ls_documento-xblnr
                                            budat       = ls_documento-budat
                                            PoNumber    = ls_documento-PoNumber
                                            DocNumber   = ls_documento-DocNumber
                                            blart       = ls_documento-blart
                                            hkont       = ls_documento-hkont
                                            bschl       = ls_documento-bschl
                                            Dis_flowty  = ls_documento-Dis_flowty
                                            Gsart       = ls_documento-Gsart
                                            processado  = me->atualiza_texto( is_documento = ls_documento
                                                                              iv_texto     = lv_novo_texto )
                                            bktxt       = ls_documento-bktxt
                                            projk       = ls_documento-projk
                                            aufnr       = ls_documento-aufnr
                                            )
                                 ).

    LOOP AT me->gt_documentos_da_regra ASSIGNING FIELD-SYMBOL(<fs_doc_regra>).

      TRY.

          ASSIGN  ct_documentos[ bukrs = <fs_doc_regra>-bukrs belnr = <fs_doc_regra>-belnr gjahr = <fs_doc_regra>-gjahr buzei = <fs_doc_regra>-buzei ] TO FIELD-SYMBOL(<fs_documento>).
          <fs_documento>-processado = <fs_doc_regra>-processado.

        CATCH cx_sy_itab_line_not_found.
          CONTINUE.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD monta_texto_contabil.

    DATA(lv_texto_contab) = iv_texto.

    IF lv_texto_contab IS INITIAL.

      lv_texto_contab = COND bseg-sgtxt( WHEN me->gs_regra-textofixo IS NOT INITIAL
                                           THEN me->gs_regra-textofixo ).

      DATA(lv_iniciado_por_texto_fixo) = abap_true.

    ENDIF.

    ASSIGN COMPONENT is_campo-campo OF STRUCTURE is_documento TO FIELD-SYMBOL(<fs_field_content>).

    IF sy-subrc EQ 0
      AND <fs_field_content> IS ASSIGNED
      AND <fs_field_content> IS NOT INITIAL.

      lv_texto_contab = COND #( WHEN lv_texto_contab IS INITIAL THEN |{ <fs_field_content> }|
                                WHEN lv_iniciado_por_texto_fixo EQ abap_true THEN |{ lv_texto_contab } { <fs_field_content> }|
                                  ELSE |{ lv_texto_contab }{ zclfi_auto_txt_contab=>gc_separa_texto }{ <fs_field_content> }| ).

    ENDIF.

    rv_result = lv_texto_contab.

  ENDMETHOD.

  METHOD atualiza_texto.

    CONSTANTS:
      lc_text_contab TYPE accchg-fdname VALUE 'SGTXT'.

    IF iv_texto IS INITIAL.

      IF me->go_log IS BOUND.

        me->go_log->insert_log(
          EXPORTING
            is_message = VALUE #(
                            type = if_xo_const_message=>error
                            number = 009
                            message_v1 = CONV #( |{ is_documento-belnr } { is_documento-buzei } | )
                            message_v2 = CONV #( is_documento-bukrs )
                            message_v3 = CONV #( is_documento-gjahr )
                            message_v4 = CONV #( me->gs_regra-regra )
            ) ).

        RETURN.

      ENDIF.

    ENDIF.

    DATA(lt_accchg) = VALUE fdm_t_accchg( ( fdname = lc_text_contab
                                            oldval = is_documento-sgtxt
                                            newval = iv_texto
                                          ) ).

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_buzei              = is_documento-buzei
        i_bukrs              = is_documento-bukrs
        i_belnr              = is_documento-belnr
        i_gjahr              = is_documento-gjahr
      TABLES
        t_accchg             = lt_accchg
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        error_message        = 6
        OTHERS               = 7.

    IF sy-subrc EQ 0.

      IF me->go_log IS BOUND.

        me->go_log->insert_log(
          EXPORTING
            is_message = VALUE #(
                            type = if_xo_const_message=>success
                            number = 008
                            message_v1 = CONV #( |{ is_documento-belnr } { is_documento-buzei }| )
                            message_v2 = CONV #( is_documento-bukrs )
                            message_v3 = CONV #( is_documento-gjahr )
                            message_v4 = CONV #( me->gs_regra-regra )
            ) ).

      ENDIF.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      rv_processado_ok = abap_true.

    ELSE.

      IF me->go_log IS BOUND.

        me->go_log->insert_log(
          EXPORTING
            is_message = VALUE #(
                            type = if_xo_const_message=>error
                            number = 009
                            message_v1 = CONV #( is_documento-belnr )
                            message_v2 = CONV #( is_documento-bukrs )
                            message_v3 = CONV #( is_documento-gjahr )
                            message_v4 = CONV #( me->gs_regra-regra )
            ) ).

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD seleciona_range_chave_lancto.

    IF me->gt_range_bschl IS NOT INITIAL.

      rt_result = me->gt_range_bschl.
      RETURN.

    ENDIF.

    SELECT
        IdSelPostingKey,
        CritSelPostingKey,
        SignPostingKey,
        OptPostingKey,
        LowPostingKey,
        HighPostingKey
    FROM zi_fi_cfg_autotxt_crit_chave
    WHERE IdRegra EQ @me->gs_regra-idregra
    INTO TABLE @DATA(lt_sel_chave).

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    rt_result = me->gt_range_bschl = VALUE #( FOR ls_sel_chave IN lt_sel_chave
                                                ( sign = ls_sel_chave-signPostingKey
                                                  option = ls_sel_chave-optPostingKey
                                                  low = ls_sel_chave-lowPostingKey
                                                  high = ls_sel_chave-highPostingKey )
                                      ).



  ENDMETHOD.

  METHOD seleciona_range_conta.

    IF me->gt_range_hkont IS NOT INITIAL.

      rt_result = me->gt_range_hkont.
      RETURN.

    ENDIF.

    SELECT
        IdSelAccount,
        CritSelAccount,
        SignAccount,
        OptAccount,
        LowAccount,
        HighAccount
    FROM zi_fi_cfg_autotxt_crit_conta
    WHERE IdRegra EQ @me->gs_regra-idregra
    INTO TABLE @DATA(lt_sel_contas).

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    rt_result = me->gt_range_hkont = VALUE #( FOR ls_sel_conta IN lt_sel_contas
                                                ( sign = ls_sel_conta-signAccount
                                                  option = ls_sel_conta-optAccount
                                                  low = ls_sel_conta-lowAccount
                                                  high = ls_sel_conta-highAccount )
                                      ).


  ENDMETHOD.

  METHOD seleciona_range_tipo_atualiza.

    IF me->gt_range_dflowtype IS NOT INITIAL.

      rt_result = me->gt_range_dflowtype.
      RETURN.

    ENDIF.

    SELECT
        IdSelTreasuryUpdateType,
        CritSelTreasuryUpdateType,
        SignTreasuryUpdateType,
        OptTreasuryUpdateType,
        LowTreasuryUpdateType,
        HighTreasuryUpdateType
    FROM zi_fi_cfg_autotxt_crit_flowtp
    WHERE IdRegra EQ @me->gs_regra-idregra
    INTO TABLE @DATA(lt_sel_tipo_atualiza).

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    rt_result = me->gt_range_dflowtype = VALUE #( FOR ls_sel_tipo_atualiza IN lt_sel_tipo_atualiza
                                                ( sign = ls_sel_tipo_atualiza-signTreasuryUpdateType
                                                  option = ls_sel_tipo_atualiza-optTreasuryUpdateType
                                                  low = ls_sel_tipo_atualiza-lowTreasuryUpdateType
                                                  high = ls_sel_tipo_atualiza-highTreasuryUpdateType )
                                      ).


  ENDMETHOD.

  METHOD seleciona_range_tipo_documento.

    IF me->gt_range_blart IS NOT INITIAL.

      rt_result = me->gt_range_blart.
      RETURN.

    ENDIF.

    SELECT
        IdSelDocType,
        CritSelDocType,
        SignDocType,
        OptDocType,
        LowDocType,
        HighDocType
    FROM zi_fi_cfg_autotxt_crit_tipodoc
    WHERE IdRegra EQ @me->gs_regra-idregra
    INTO TABLE @DATA(lt_sel_tipo_doc).

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    rt_result = me->gt_range_blart = VALUE #( FOR ls_sel_tipo_doc IN lt_sel_tipo_doc
                                                ( sign = ls_sel_tipo_doc-signDocType
                                                  option = ls_sel_tipo_doc-optDocType
                                                  low = ls_sel_tipo_doc-lowDocType
                                                  high = ls_sel_tipo_doc-highDocType )
                                      ).


  ENDMETHOD.

  METHOD seleciona_range_tipo_produto.

    IF me->gt_range_gsart IS NOT INITIAL.

      rt_result = me->gt_range_gsart.
      RETURN.

    ENDIF.

    SELECT
        IdSelFIProdType,
        CritSelFIProdType,
        SignFIProdType,
        OptFIProdType,
        LowFIProdType,
        HighFIProdType
    FROM zi_fi_cfg_autotxt_crit_prodtp
    WHERE IdRegra EQ @me->gs_regra-idregra
    INTO TABLE @DATA(lt_sel_tipo_produto).

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    rt_result = me->gt_range_gsart = VALUE #( FOR ls_sel_tipo_produto IN lt_sel_tipo_produto
                                                ( sign = ls_sel_tipo_produto-signFIProdType
                                                  option = ls_sel_tipo_produto-optFIProdType
                                                  low = ls_sel_tipo_produto-lowFIProdType
                                                  high = ls_sel_tipo_produto-highFIProdType )
                                      ).


  ENDMETHOD.

  METHOD seleciona_tipo_atualiza.

    IF me->gt_tipo_atualiza IS NOT INITIAL.

      rt_result = me->gt_tipo_atualiza.
      RETURN.

    ENDIF.

    DATA(lt_range_dflowtype) = me->seleciona_range_tipo_atualiza( ).
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

    DATA(lt_range_bschl) = me->seleciona_range_chave_lancto( ).
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

    DATA(lt_range_hkont) = me->seleciona_range_conta( ).
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

    DATA(lt_range_blart) = me->seleciona_range_tipo_documento( ).
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

    DATA(lt_range_gsart) = me->seleciona_range_tipo_produto( ).
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

  METHOD recupera_criterios.

    et_chave_lancto = me->seleciona_chave_lancto( ).

    et_conta = me->seleciona_conta(  ).

    et_empresas = me->seleciona_empresas( ).

    et_tipo_atualiza = me->seleciona_tipo_atualiza( ).

    et_tipo_documento = me->seleciona_tipo_documento( ).

    et_tipo_produto = me->seleciona_tipo_produto( ).

  ENDMETHOD.

  METHOD recupera_regra.
    rs_result = me->gs_regra.
  ENDMETHOD.

ENDCLASS.


