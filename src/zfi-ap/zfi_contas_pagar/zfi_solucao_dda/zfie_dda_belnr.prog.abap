***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: FI AP - Solução DDA                                    *
*** AUTOR : Paulo Ferraz - META                                       *
*** FUNCIONAL: Raphael Rocha - META                                   *
*** DATA : 03.03.2023                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 03.03.2022 | Paulo Ferraz       | Desenvolvimento inicial         *
***********************************************************************


new zclfi_dda_xblnr(  )->process_file_ff5(
  CHANGING
    ct_dados_arquivo = bdata_ap[]
).


*    TYPES:
*      "! Tipo Arquivo 240 posições
*      BEGIN OF ty_file_240,
*        campo(240) TYPE c,
*      END OF ty_file_240.
*
*    TYPES:
*      BEGIN OF ty_search_taxcode,
*        taxcode TYPE i_supplier-taxnumber1,
*      END OF ty_search_taxcode.
*
*    CONSTANTS: lc_zero  TYPE c VALUE '0',
*               lc_k     TYPE c VALUE 'K',
*               lc_ponto TYPE c VALUE '.'.
*
*    TYPES:
*      "! Categ. Tabela Arquivo 240 posições
*      ty_t_file_240 TYPE STANDARD TABLE OF ty_file_240.
*
*    DATA: lt_file TYPE ty_t_file_240.
*
*    DATA: lv_paval        TYPE t001z-paval,
*          lv_paval2       TYPE t001z-paval,
*          lv_indextb      TYPE sy-tabix,
*          lv_data(8)      TYPE c,
*          lv_tabix        LIKE sy-tabix,
*          lv_tp_reg(01)   TYPE c,
*          lv_segmento(01) TYPE c,
*          lv_documento    TYPE xblnr1,
*          lv_data_venc    TYPE datum,
*          lv_gjahr        TYPE bseg-gjahr,
*          lv_valor_tit    TYPE wrbtr,
*          lv_supplier     TYPE i_supplier-supplier,
*          lv_cnpj         TYPE ztfi_dda_segto_g-num_insc,
*          lv_raiz_cnpj    TYPE char8.
*
*    DATA: lr_xblnr    TYPE RANGE OF bkpf-xblnr,
*          lr_cnpj     TYPE RANGE OF i_supplier-taxnumber1,
*          lr_supplier TYPE RANGE OF i_supplier-supplier.
*
*    lt_file = bdata_ap[].
*
************************************************************************
*    " Buscar empresa
************************************************************************
*    READ TABLE lt_file ASSIGNING FIELD-SYMBOL(<fs_file>) INDEX 1.
*
*    IF sy-subrc NE 0.
*      RETURN.
*    ENDIF.
*
*    lv_paval  = <fs_file>+19(08). "com zero incial
*    lv_paval2 = <fs_file>+18(08). "sem zero  incial
*
*    SELECT SINGLE bukrs
*           FROM   t001z
*           WHERE  paval EQ @lv_paval OR
*                  paval EQ @lv_paval2
*    INTO @DATA(lv_bukrs).
*    IF sy-subrc NE 0.
*      RETURN.
*    ENDIF.
*
************************************************************************
*    " Buscar Documento
************************************************************************
*
*    LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<fs_file_240>).
*      lv_indextb = sy-tabix.
*
*      CLEAR:
*         lv_tp_reg, lv_segmento.
*
*      lv_tp_reg = <fs_file_240>-campo+7(1).
*      lv_segmento = <fs_file_240>-campo+13(1).
*
*      "Segmento G
*      IF lv_tp_reg = '3' AND
*         lv_segmento = 'G'.
*
*
*        CLEAR: lv_data, lv_data_venc, lv_cnpj,
*               lv_gjahr, lv_valor_tit, lr_cnpj,
*               lv_cnpj, lv_supplier, lv_documento.
*        lv_data = <fs_file_240>-campo+107(8).
*        lv_data_venc = lv_data+4(4) && lv_data+2(2) && lv_data(2)..
*
*        lv_cnpj = <fs_file_240>-campo+63(14).
*        lv_gjahr = <fs_file_240>-campo+111(4).
*
*        lv_valor_tit = <fs_file_240>-campo+115(13)  && lc_ponto && <fs_file_240>-campo+128(2) .
*
*        IF strlen( lv_cnpj ) < 14.
*          lv_cnpj = shift_left( val = lv_cnpj sub = lc_zero ).
*        ENDIF.
*
*        lv_raiz_cnpj = lv_cnpj(8).
*
*        APPEND VALUE #( sign = 'I'
*                        option = 'CP'
*                        low = lv_raiz_cnpj && '*' ) TO lr_cnpj.
*
*        IF lr_cnpj IS NOT INITIAL .
*          SELECT supplier
*              FROM i_supplier
*              WHERE taxnumber1 IN @lr_cnpj
*              INTO TABLE @DATA(lt_supplier).
*          IF lt_supplier IS NOT INITIAL.
*            lr_supplier = VALUE #( FOR ls_supplier IN lt_supplier
*                    (  sign = 'I'
*                       option = 'EQ'
*                       low = ls_supplier ) ).
*          ENDIF.
*        ENDIF.
*
*
*        lv_documento = <fs_file_240>-campo+147(15).
*        IF lv_documento CO '0123456789'.
*
*        ELSE.
*
**          SPLIT lv_documento AT '/' INTO DATA(lv_part1) DATA(lv_part2).
**          APPEND VALUE #( sign = 'I'
**                        option = 'CP'
**                        low = '*' && lv_part1 ) TO lr_xblnr.
*
*          REPLACE '/' IN lv_documento WITH '-'.
*        ENDIF.
*
*        APPEND VALUE #( sign = 'I'
*                        option = 'EQ'
*                        low = lv_documento ) TO lr_xblnr.
*
*        SHIFT lv_documento LEFT DELETING LEADING '0'.
*        CONDENSE lv_documento NO-GAPS.
*
*        APPEND VALUE #( sign = 'I'
*                        option = 'CP'
*                        low = '*' && lv_documento ) TO lr_xblnr.
*
*
*
*        SELECT a~belnr, a~xblnr
*          FROM bsik_view AS a
*          INNER JOIN bseg AS b
*            ON a~bukrs = b~bukrs AND
*               a~belnr = b~belnr AND
*               a~gjahr = b~gjahr AND
*               a~buzei = b~buzei
*          WHERE a~bukrs = @lv_bukrs
*             AND a~gjahr = @lv_gjahr
*             AND a~lifnr IN @lr_supplier
*             AND a~xblnr IN @lr_xblnr
*             AND b~netdt = @lv_data_venc
*          INTO TABLE @DATA(lt_ref).
*
*        IF lt_ref IS NOT INITIAL.
*
*          IF lines( lt_ref ) = 1.
*            READ TABLE bdata_ap INDEX lv_indextb ASSIGNING FIELD-SYMBOL(<fs_file2>).
*            IF sy-subrc = 0.
*              CLEAR:<fs_file2>+147(15).
*              <fs_file2>+147(10) = lt_ref[ 1 ]-belnr.
*            ENDIF.
*          ELSE.
*
*
*            DATA(ls_dda_xblnr) = VALUE ztfi_error_xblnr(
*                bukrs = lv_bukrs
*                gjahr = lv_gjahr
*                cnpj = lv_cnpj
*                due_date = <fs_file_240>-campo+107(8)
*                reference_no = <fs_file_240>-campo+147(15) ).
*
*            MODIFY ztfi_error_xblnr FROM ls_dda_xblnr.
*
*          ENDIF.
*
*        ELSE.
*
*          SELECT a~belnr, a~xblnr
*            FROM bsik_view AS a
*            INNER JOIN bseg AS b
*              ON a~bukrs = b~bukrs AND
*                 a~belnr = b~belnr AND
*                 a~gjahr = b~gjahr AND
*                 a~buzei = b~buzei
*            WHERE a~bukrs = @lv_bukrs
*               AND a~gjahr = @lv_gjahr
*               AND a~lifnr IN @lr_supplier
**               AND a~xblnr IN @lr_xblnr
*               AND b~netdt = @lv_data_venc
*               AND a~wrbtr = @lv_valor_tit
*            INTO TABLE @DATA(lt_xbnlr_nmath).
*
*          IF sy-subrc = 0.
*
*            DATA(ls_dda_xblnr2) = VALUE ztfi_error_xblnr(
*                 bukrs = lv_bukrs
*                 gjahr = lv_gjahr
*                 cnpj = lv_cnpj
*                 due_date = <fs_file_240>-campo+107(8)
*                 reference_no = <fs_file_240>-campo+147(15) ).
*
*            MODIFY ztfi_error_xblnr FROM ls_dda_xblnr2.
*
*          ENDIF.
*
*        ENDIF.
*
*        CLEAR: lv_documento, lr_xblnr, lt_ref, lv_data_venc.
*
*      ENDIF.
*
*    ENDLOOP.
