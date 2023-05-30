"!<p><h3>Gravação dos dados de Arquivo DDA</h3></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 08 de mar de 2022</p>
CLASS zclfi_dda_info_arquivo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      "! Tipo Arquivo 240 posições
      BEGIN OF ty_file_240,
        campo(240) TYPE c,
      END OF ty_file_240.

    TYPES:
      "! Categ. Tabela Arquivo 240 posições
      tt_file_240 TYPE STANDARD TABLE OF ty_file_240.

    METHODS:
      "! Inicializa dados do objeto referenciado
      "! @parameter it_dados_arquivo | Dados do Retorno de pagamento
      "! @parameter iv_filepath      | Caminho do arquivo
      constructor
        IMPORTING it_dados_arquivo TYPE tt_file_240
                  iv_filepath      TYPE char128,

      "! Processa Arquivo DDA
      process_file,

      "! Grava dados do DDA nas tabelas ZTFI_DDA*
      save_data.


  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA:
      "! Dados do arquivo DDA
      gt_file_240    TYPE tt_file_240,
      "! Cabeçalho DDA
      gt_dda_header  TYPE STANDARD TABLE OF ztfi_dda_header,
      "! Lote DDA
      gt_dda_lote    TYPE STANDARD TABLE OF ztfi_dda_lote,
      "! Segmento G DDA
      gt_dda_segto_g TYPE STANDARD TABLE OF ztfi_dda_segto_g,
      "! Segmento H DDA
      gt_dda_segto_h TYPE STANDARD TABLE OF ztfi_dda_segto_h,
      "! Trailer do arquivo DDA
      gt_dda_tr_file TYPE STANDARD TABLE OF ztfi_dda_tr_file,
      "! Trailer de lote DDA
      gt_dda_trail   TYPE STANDARD TABLE OF ztfi_dda_trail.

    DATA:
      "! Nome do arquivo DDA
      gv_nome_arquivo TYPE ztfi_dda_header-arquivo.

    "! Recupera nome do arquivo no caminho informado
    "! @parameter iv_filepath | Caminho do arquivo
    "! @parameter rv_result   | Nome do arquivo
    METHODS get_filename
      IMPORTING iv_filepath      TYPE char128
      RETURNING VALUE(rv_result) TYPE ztfi_dda_header-arquivo.

    "! Recupera cód. empresa dentro do arquivo DDA
    "! @parameter rv_result | Cód. empresa
    METHODS get_company
      RETURNING
        VALUE(rv_result) TYPE bukrs.

    "! Formata decimais
    "! @parameter iv_value    | Valor
    "! @parameter iv_decimals | Qtd. Casas decimais
    "! @parameter rv_result   | Valor formatado
    METHODS format_decimals
      IMPORTING
        iv_value         TYPE char20
        iv_decimals      TYPE i
      RETURNING
        VALUE(rv_result) TYPE char20.

    "! Busca fornecedor SAP
    METHODS busca_fornec_sap.
    METHODS changedoc.

ENDCLASS.



CLASS ZCLFI_DDA_INFO_ARQUIVO IMPLEMENTATION.


  METHOD constructor.

    me->gt_file_240 = it_dados_arquivo.

    me->get_filename( iv_filepath ).

  ENDMETHOD.


  METHOD process_file.

    CONSTANTS:
      BEGIN OF lc_tipo_registro,
        header  TYPE c VALUE '0',
        lote    TYPE c VALUE '1',
        segto   TYPE c VALUE '3',
        trail   TYPE c VALUE '5',
        tr_file TYPE c VALUE '9',
      END OF lc_tipo_registro,

      BEGIN OF lc_tipo_segmento,
        segto_g TYPE c VALUE 'G',
        segto_h TYPE c VALUE 'H',
      END OF lc_tipo_segmento.

    CONSTANTS:
      lc_numbers TYPE string VALUE '0123456789'.

    DATA:
      lv_data(8)      TYPE c,
      lv_tabix        LIKE sy-tabix,
      lv_tp_reg(01)   TYPE c,
      lv_segmento(01) TYPE c.


    DATA(lv_bukrs) = me->get_company(  ).

    LOOP AT me->gt_file_240 ASSIGNING FIELD-SYMBOL(<fs_file_240>).

      CLEAR:
          lv_tp_reg, lv_segmento.

      lv_tp_reg = <fs_file_240>-campo+7(1).
      lv_segmento = <fs_file_240>-campo+13(1).

      CASE lv_tp_reg.

*     Preenchendo o header de arquivo
        WHEN  lc_tipo_registro-header.

          APPEND INITIAL LINE TO me->gt_dda_header ASSIGNING FIELD-SYMBOL(<fs_dda_header>).

          <fs_dda_header>-bukrs       = lv_bukrs.
          <fs_dda_header>-hbkid       = <fs_file_240>-campo(3).
          <fs_dda_header>-data_arq    = sy-datum.

          <fs_dda_header>-arquivo     = me->gv_nome_arquivo.
          <fs_dda_header>-cod_lote    = <fs_file_240>-campo+3(4).
          <fs_dda_header>-cod_insc    = <fs_file_240>-campo+17(1).
          <fs_dda_header>-num_insc    = <fs_file_240>-campo+18(14).
          <fs_dda_header>-nome_emp    = <fs_file_240>-campo+72(30).
          <fs_dda_header>-nome_ban    = <fs_file_240>-campo+102(30).
          <fs_dda_header>-cod_arquivo = <fs_file_240>-campo+142(1).

          lv_data = <fs_file_240>-campo+143(8).
          <fs_dda_header>-dt_gerac    = lv_data+4(4) && lv_data+2(2) && lv_data(2).
          <fs_dda_header>-hr_gerac    = <fs_file_240>-campo+151(6).
          <fs_dda_header>-num_seq     = <fs_file_240>-campo+157(6).
          <fs_dda_header>-layout      = <fs_file_240>-campo+163(3).

        WHEN  lc_tipo_registro-lote.

          APPEND INITIAL LINE TO me->gt_dda_lote ASSIGNING FIELD-SYMBOL(<fs_dda_lote>).

          <fs_dda_lote>-bukrs      = lv_bukrs.
          <fs_dda_lote>-data_arq    = sy-datum.
          <fs_dda_lote>-cnpj   = <fs_file_240>-campo+19(14).
          <fs_dda_lote>-hbkid   = <fs_file_240>-campo(3).
          <fs_dda_lote>-cod_lote    = <fs_file_240>-campo+3(4).
          <fs_dda_lote>-operacao    = <fs_file_240>-campo+8(1).
          <fs_dda_lote>-cod_serv    = <fs_file_240>-campo+9(2).

          <fs_dda_lote>-layout    = <fs_file_240>-campo+13(3).
          <fs_dda_lote>-cod_insc    = <fs_file_240>-campo+17(1).
          <fs_dda_lote>-num_insc    = <fs_file_240>-campo+19(14).
          <fs_dda_lote>-nome_emp    = <fs_file_240>-campo+73(30).

        WHEN  lc_tipo_registro-segto.

          CASE  lv_segmento.

            WHEN lc_tipo_segmento-segto_g.

              APPEND INITIAL LINE TO me->gt_dda_segto_g ASSIGNING FIELD-SYMBOL(<fs_dda_segto_g>).

              <fs_dda_segto_g>-bukrs        = lv_bukrs.
              <fs_dda_segto_g>-data_arq     = sy-datum.
              <fs_dda_segto_g>-hbkid        = <fs_file_240>-campo(3).
              <fs_dda_segto_g>-cod_lote     = <fs_file_240>-campo+3(4).
              <fs_dda_segto_g>-num_reg      = <fs_file_240>-campo+8(5).
              <fs_dda_segto_g>-cod_banco_br = <fs_file_240>-campo+17(3).
              <fs_dda_segto_g>-cod_moeda_br = <fs_file_240>-campo+20(1).
              <fs_dda_segto_g>-dac_br       = <fs_file_240>-campo+21(1).
              <fs_dda_segto_g>-ft_vencto_br = <fs_file_240>-campo+22(4).

              <fs_dda_segto_g>-valor_br_br = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+26(10) )
                                                                  iv_decimals = 2 ).

              <fs_dda_segto_g>-cpo_livre_br = <fs_file_240>-campo+36(25).
              <fs_dda_segto_g>-cod_insc = <fs_file_240>-campo+61(1).
              <fs_dda_segto_g>-num_insc = <fs_file_240>-campo+63(14).
              <fs_dda_segto_g>-nome_ced = <fs_file_240>-campo+77(30).

              CLEAR lv_data.
              lv_data = <fs_file_240>-campo+107(8).
              <fs_dda_segto_g>-dt_vencto    = lv_data+4(4) && lv_data+2(2) && lv_data(2).

              <fs_dda_segto_g>-valor_tit = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+115(15) )
                                                                iv_decimals = 2 ).

              <fs_dda_segto_g>-qt_moeda = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+130(15) )
                                                               iv_decimals = 5 ).

              <fs_dda_segto_g>-cod_moeda = <fs_file_240>-campo+145(2).
              <fs_dda_segto_g>-num_doc = <fs_file_240>-campo+147(10).
              <fs_dda_segto_g>-belnr = <fs_file_240>+147(10). " COND #(  WHEN <fs_file_240>-campo+147(10) CO lc_numbers THEN <fs_file_240>-campo+147(10) ).
              CONDENSE <fs_dda_segto_g>-belnr NO-GAPS.
              <fs_dda_segto_g>-xblnr = <fs_file_240>+147(15). " COND #(  WHEN <fs_file_240>-campo+147(10) CO lc_numbers THEN <fs_file_240>-campo+147(10) ).
              CONDENSE <fs_dda_segto_g>-xblnr NO-GAPS.
              <fs_dda_segto_g>-gjahr = <fs_file_240>-campo+111(4).

              <fs_dda_segto_g>-ag_cobr = <fs_file_240>-campo+162(5).
              <fs_dda_segto_g>-dac_ag = <fs_file_240>-campo+167(1).
*              <fs_dda_segto_g>-fornec_sap = me->busca_fornec_sap( <fs_file_240>-campo+62(15) ).
              <fs_dda_segto_g>-carteira = <fs_file_240>-campo+178(1).
              <fs_dda_segto_g>-esp_tit = <fs_file_240>-campo+179(2).
              <fs_dda_segto_g>-nosso_num = <fs_file_240>-campo+40(9).

              CLEAR: lv_data.
              lv_data = <fs_file_240>-campo+181(8).
              <fs_dda_segto_g>-dt_emiss = lv_data+4(4) && lv_data+2(2) && lv_data(2).
              <fs_dda_segto_g>-juros_mora = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+189(15) )
                                                                 iv_decimals = 2 ).

              CLEAR: lv_data.
              lv_data = <fs_file_240>-campo+205(8).
              <fs_dda_segto_g>-dt_pri_desc =  lv_data+4(4) && lv_data+2(2) && lv_data(2).

              <fs_dda_segto_g>-vl_pri_desc = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+213(15) )
                                                                  iv_decimals = 2 ).

              <fs_dda_segto_g>-cod_protesto = <fs_file_240>-campo+228(1).
              <fs_dda_segto_g>-prz_protesto = <fs_file_240>-campo+229(2).

              CLEAR: lv_data.
              lv_data = <fs_file_240>-campo+231(8).
              <fs_dda_segto_g>-dt_limite = lv_data+4(4) && lv_data+2(2) && lv_data(2).

            WHEN lc_tipo_segmento-segto_h.

              APPEND INITIAL LINE TO me->gt_dda_segto_h ASSIGNING FIELD-SYMBOL(<fs_dda_segto_h>).

              <fs_dda_segto_h>-bukrs      = lv_bukrs.
              <fs_dda_segto_h>-data_arq    = sy-datum.
              <fs_dda_segto_h>-hbkid       = <fs_file_240>-campo(3).
              <fs_dda_segto_h>-cod_lote    = <fs_file_240>-campo+3(4).
              <fs_dda_segto_h>-num_reg = <fs_file_240>-campo+8(5).
              <fs_dda_segto_h>-cdg_ins_ava = <fs_file_240>-campo+17(1).
              <fs_dda_segto_h>-insc_ava = <fs_file_240>-campo+18(15).
              <fs_dda_segto_h>-nome_ava = <fs_file_240>-campo+33(40).

              CLEAR: lv_data.
              lv_data = <fs_file_240>-campo+74(8).
              <fs_dda_segto_h>-dt_seg_desc = lv_data+4(4) && lv_data+2(2) && lv_data(2).

              <fs_dda_segto_h>-vl_seg_desc = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+82(15) )
                                                                  iv_decimals = 2 ).

              CLEAR: lv_data.
              lv_data = <fs_file_240>-campo+98(8).
              <fs_dda_segto_h>-dt_ter_desc =  lv_data+4(4) && lv_data+2(2) && lv_data(2).

              <fs_dda_segto_h>-vl_ter_desc = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+106(15) )
                                                                  iv_decimals = 2 ).

              CLEAR: lv_data.
              lv_data = <fs_file_240>-campo+122(8).
              <fs_dda_segto_h>-dt_multa = lv_data+4(4) && lv_data+2(2) && lv_data(2).

              <fs_dda_segto_h>-vl_multa = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+130(15) )
                                                               iv_decimals = 2 ).

              <fs_dda_segto_h>-vl_abat = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+145(15) )
                                                              iv_decimals = 2 ).

              <fs_dda_segto_h>-ints_01 = <fs_file_240>-campo+160(40).
              <fs_dda_segto_h>-ints_02 = <fs_file_240>-campo+200(40).


          ENDCASE.

        WHEN  lc_tipo_registro-trail.

          APPEND INITIAL LINE TO me->gt_dda_trail ASSIGNING FIELD-SYMBOL(<fs_dda_trail>).

          <fs_dda_trail>-bukrs       = lv_bukrs.
          <fs_dda_trail>-data_arq    = sy-datum.
          <fs_dda_trail>-hbkid       = <fs_file_240>-campo(3).
          <fs_dda_trail>-cod_lote    = <fs_file_240>-campo+3(4).
          <fs_dda_trail>-qtd_reg     = <fs_file_240>-campo+17(6).
          <fs_dda_trail>-vlr_tit     = me->format_decimals( iv_value    = CONV #( <fs_file_240>-campo+23(16) )
                                                            iv_decimals = 2 ).


        WHEN  lc_tipo_registro-tr_file.

          APPEND INITIAL LINE TO me->gt_dda_tr_file ASSIGNING FIELD-SYMBOL(<fs_dda_tr_file>).

          <fs_dda_tr_file>-bukrs     = lv_bukrs.
          <fs_dda_tr_file>-data_arq  = sy-datum.
          <fs_dda_tr_file>-hbkid     = <fs_file_240>-campo(3).
          <fs_dda_tr_file>-tot_reg   = <fs_file_240>-campo+17(6).
          <fs_dda_tr_file>-tot_lotes = <fs_file_240>-campo+23(16).

        WHEN OTHERS.

      ENDCASE.

    ENDLOOP.

    me->busca_fornec_sap( ).

    me->save_data( ).

  ENDMETHOD.


  METHOD get_company.

    DATA:
      lv_paval  TYPE t001z-paval,
      lv_paval2 TYPE t001z-paval.

    READ TABLE me->gt_file_240 ASSIGNING FIELD-SYMBOL(<fs_file>)  INDEX 1.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.


    lv_paval  = <fs_file>+19(08). "com zero incial
    lv_paval2 = <fs_file>+18(08). "sem zero  incial

    SELECT SINGLE bukrs
           FROM   t001z
           WHERE  paval EQ @lv_paval OR
                  paval EQ @lv_paval2
    INTO @DATA(lv_bukrs).

    IF sy-subrc EQ 0.
      rv_result = lv_bukrs.
    ENDIF.


  ENDMETHOD.


  METHOD format_decimals.

    CONSTANTS:
      lc_ponto TYPE c VALUE '.'.

    DATA: lv_valor(20)    TYPE c,
          lv_tam          TYPE i,
          lv_inteiros(20) TYPE c,
          lv_decimais(20) TYPE c,
          lv_casas(2)     TYPE n.

    lv_tam = strlen( iv_value ).

    lv_casas = lv_tam - iv_decimals.

    lv_inteiros  = iv_value(lv_casas).
    lv_decimais = iv_value+lv_casas(iv_decimals).

    CONDENSE: lv_inteiros, lv_decimais.

    CLEAR: lv_valor.

    CONCATENATE lv_inteiros lv_decimais INTO lv_valor
        SEPARATED BY lc_ponto.

    rv_result = lv_valor.

  ENDMETHOD.


  METHOD save_data.

    IF lines( gt_dda_segto_g ) > 0.

      IF gt_dda_header IS NOT INITIAL.
        MODIFY ztfi_dda_header FROM TABLE gt_dda_header.
      ENDIF.

      IF gt_dda_lote IS NOT INITIAL.
        MODIFY ztfi_dda_lote FROM TABLE gt_dda_lote.
      ENDIF.

      IF gt_dda_segto_g IS NOT INITIAL.
        MODIFY ztfi_dda_segto_g FROM TABLE gt_dda_segto_g.
      ENDIF.

      IF gt_dda_segto_h IS NOT INITIAL.
        MODIFY ztfi_dda_segto_h FROM TABLE gt_dda_segto_h.
      ENDIF.

      IF gt_dda_tr_file IS NOT INITIAL.
        MODIFY ztfi_dda_tr_file FROM TABLE gt_dda_tr_file.
      ENDIF.

      IF gt_dda_trail IS NOT INITIAL.
        MODIFY ztfi_dda_trail FROM TABLE gt_dda_trail.
      ENDIF.

      me->changedoc(  ).

    ENDIF.

  ENDMETHOD.


  METHOD get_filename.

    IF iv_filepath IS INITIAL.
      RETURN.
    ENDIF.

    CALL FUNCTION 'TRINT_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = iv_filepath
      IMPORTING
        stripped_name = me->gv_nome_arquivo
      EXCEPTIONS
        x_error       = 1
        OTHERS        = 2.

    IF sy-subrc EQ 0.
      rv_result = me->gv_nome_arquivo.
    ELSE.
      CLEAR rv_result.
    ENDIF.

  ENDMETHOD.


  METHOD busca_fornec_sap.

    TYPES:
      BEGIN OF ty_search_taxcode,
        taxcode TYPE i_supplier-TaxNumber1,
      END OF ty_search_taxcode.

    CONSTANTS: lc_zero TYPE c VALUE `0`.

    DATA:
      lt_search_taxcode TYPE STANDARD TABLE OF ty_search_taxcode.

    DATA:
      lv_taxcode_no_zero TYPE i_supplier-TaxNumber1.

    DATA(lt_segto_g) = me->gt_dda_segto_g.

    SORT lt_segto_g BY num_insc.
    DELETE ADJACENT DUPLICATES FROM lt_segto_g COMPARING num_insc.

    LOOP AT lt_segto_g ASSIGNING FIELD-SYMBOL(<fs_segto_g>).

      APPEND INITIAL LINE TO lt_search_taxcode ASSIGNING FIELD-SYMBOL(<fs_search_taxcode>).
      <fs_search_taxcode>-taxcode = <fs_segto_g>-num_insc.

      APPEND INITIAL LINE TO lt_search_taxcode ASSIGNING <fs_search_taxcode>.
      <fs_search_taxcode>-taxcode = shift_left( val = <fs_segto_g>-num_insc sub = lc_zero ).

    ENDLOOP.

    IF lt_segto_g IS INITIAL.
      RETURN.
    ENDIF.

    SELECT Supplier,
           taxnumber1
    FROM i_supplier
    FOR ALL ENTRIES IN @lt_search_taxcode
    WHERE TaxNumber1 EQ @lt_search_taxcode-taxcode
    INTO TABLE @DATA(lt_supplier).

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    SORT lt_supplier BY taxnumber1.

    LOOP AT me->gt_dda_segto_g ASSIGNING FIELD-SYMBOL(<fs_update_segto_g>).

      READ TABLE lt_supplier ASSIGNING FIELD-SYMBOL(<fs_supplier>)
          WITH KEY TaxNumber1 = <fs_update_segto_g>-num_insc
          BINARY SEARCH.

      IF sy-subrc EQ 0.

        <fs_update_segto_g>-fornec_sap = <fs_supplier>-Supplier.

      ELSE.

        CLEAR lv_taxcode_no_zero.

        lv_taxcode_no_zero = shift_left( val = <fs_update_segto_g>-num_insc sub = lc_zero ).

        READ TABLE lt_supplier ASSIGNING <fs_supplier>
            WITH KEY TaxNumber1 = lv_taxcode_no_zero
            BINARY SEARCH.

        IF sy-subrc EQ 0.
          <fs_update_segto_g>-fornec_sap = <fs_supplier>-Supplier.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD changedoc.

    IF gt_dda_segto_g IS NOT INITIAL.

      CALL FUNCTION 'ZFMFI_DOC_CONTABIL'
        STARTING NEW TASK 'DOC_CONTABIL'
        DESTINATION 'NONE'
        TABLES
          it_segto  = gt_dda_segto_g
          it_header = gt_dda_header.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
