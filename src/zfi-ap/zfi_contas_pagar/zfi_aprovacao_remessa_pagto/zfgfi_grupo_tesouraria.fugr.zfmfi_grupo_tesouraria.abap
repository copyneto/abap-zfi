FUNCTION zfmfi_grupo_tesouraria.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IT_DOC_FDGRV) TYPE  ZCTGFI_DOC_FDGRV
*"----------------------------------------------------------------------
  DATA: lv_longo         TYPE timestampl,
        ls_doc_fdgrv     TYPE ztfi_doc_fdgrv,
        lt_doc_fdgrv_upd TYPE TABLE OF ztfi_doc_fdgrv,
        ls_log_apv_pgt   TYPE ztfi_log_apv_pgt.


  DATA(lt_doc_fdgrv) = it_doc_fdgrv.

  SORT lt_doc_fdgrv. DELETE ADJACENT DUPLICATES FROM lt_doc_fdgrv.
  CHECK lt_doc_fdgrv IS NOT INITIAL.


  SELECT companycode, accountingdocument, fiscalyear, accountingdocumentitem, netduedate, cashplanninggroup, reptype, paidamountinpaytcurrency
    FROM zi_fi_prog_pag_docn
    FOR ALL ENTRIES IN @lt_doc_fdgrv
    WHERE companycode = @lt_doc_fdgrv-bukrs
*      AND accountingdocument = @lT_DOC_FDGRV-belnr
      AND fiscalyear = @lt_doc_fdgrv-gjahr
*      AND accountingdocumentitem = @lT_DOC_FDGRV-buzei
      AND netduedate = @lt_doc_fdgrv-netduedate
      AND cashplanninggroup = @lt_doc_fdgrv-fdgrv
      AND reptype = @lt_doc_fdgrv-tipo_rel
      INTO TABLE @DATA(lt_itens).

  SELECT companycode, accountingdocument, fiscalyear, accountingdocumentitem, netduedate, cashplanninggroup, reptype, paidamountinpaytcurrency
     FROM zi_fi_prog_pag_docn
     FOR ALL ENTRIES IN @lt_doc_fdgrv
     WHERE companycode = @lt_doc_fdgrv-bukrs
          AND accountingdocument = @lt_doc_fdgrv-belnr
       AND fiscalyear = @lt_doc_fdgrv-gjahr
          AND accountingdocumentitem = @lt_doc_fdgrv-buzei
       AND netduedate = @lt_doc_fdgrv-netduedate
       AND cashplanninggroup = @lt_doc_fdgrv-fdgrv
       AND reptype = @lt_doc_fdgrv-tipo_rel
       INTO TABLE @DATA(lt_itens_mod).

  DATA(ls_doc_fdgrv_1) = lt_doc_fdgrv[ 1 ].


  SELECT * UP TO 1 ROWS
    FROM ztfi_log_apv_pgt
    INTO @ls_log_apv_pgt
    WHERE bukrs = @ls_doc_fdgrv_1-bukrs
      AND fdgrv = @ls_doc_fdgrv_1-fdgrv
      AND data = @ls_doc_fdgrv_1-netduedate
      AND tiporel = @ls_doc_fdgrv_1-tipo_rel.
  ENDSELECT.

  IF sy-subrc = 0.

    DATA: lv_valor TYPE ze_valor_aprov.

    "Valor dos itens que estão sendo modificados
    LOOP AT lt_itens_mod ASSIGNING FIELD-SYMBOL(<fs_doc_mod>).
      lv_valor = lv_valor +  <fs_doc_mod>-paidamountinpaytcurrency.
    ENDLOOP.

    DATA(lv_lines_itens) = lines( lt_itens ).
    DATA(lv_lines_mod) = lines( it_doc_fdgrv ).

    IF lv_lines_itens = lv_lines_mod.

      ls_log_apv_pgt-fdgrv = ls_doc_fdgrv_1-newfdgrv.
      MODIFY ztfi_log_apv_pgt FROM ls_log_apv_pgt.

      DELETE FROM ztfi_log_apv_pgt WHERE bukrs = ls_log_apv_pgt-bukrs AND
                                    fdgrv = ls_doc_fdgrv_1-fdgrv AND
                                    data = ls_log_apv_pgt-data AND
                                    hora = ls_log_apv_pgt-hora AND
                                    tiporel = ls_log_apv_pgt-tiporel.
    ELSE.

      "Subtrai o valor dos itens que foi alterados
      ls_log_apv_pgt-valor = ls_log_apv_pgt-valor - lv_valor.
      MODIFY ztfi_log_apv_pgt FROM ls_log_apv_pgt.

      "Cria uma nova linha com o valor dos itens alterados
      ls_log_apv_pgt-valor = lv_valor.
      ls_log_apv_pgt-fdgrv = ls_doc_fdgrv_1-newfdgrv.
      MODIFY ztfi_log_apv_pgt FROM ls_log_apv_pgt.

    ENDIF.

  ENDIF.


  GET TIME STAMP FIELD lv_longo.

  SELECT *
   FROM ztfi_doc_fdgrv
   FOR ALL ENTRIES IN @lt_doc_fdgrv
   WHERE bukrs = @lt_doc_fdgrv-bukrs
     AND belnr = @lt_doc_fdgrv-belnr
     AND gjahr = @lt_doc_fdgrv-gjahr
     AND buzei = @lt_doc_fdgrv-buzei
   INTO TABLE @DATA(lt_doc_fdgrv_a).

  SORT lt_doc_fdgrv_a BY bukrs
                         belnr
                         gjahr
                         buzei.

  LOOP AT it_doc_fdgrv ASSIGNING FIELD-SYMBOL(<fs_doc_fdgrv>).
    ls_doc_fdgrv = CORRESPONDING #( <fs_doc_fdgrv> ).
    READ TABLE lt_doc_fdgrv_a TRANSPORTING NO FIELDS WITH KEY bukrs = <fs_doc_fdgrv>-bukrs
                                                              belnr = <fs_doc_fdgrv>-belnr
                                                              gjahr = <fs_doc_fdgrv>-gjahr
                                                              buzei = <fs_doc_fdgrv>-buzei BINARY SEARCH.

    IF sy-subrc <> 0.
      ls_doc_fdgrv-created_by = sy-uname.
      ls_doc_fdgrv-created_at = lv_longo.

    ENDIF.
    ls_doc_fdgrv-last_changed_by  = sy-uname.
    ls_doc_fdgrv-last_changed_at  = lv_longo.
    ls_doc_fdgrv-local_last_changed_at = lv_longo.
    ls_doc_fdgrv-fdgrv  = <fs_doc_fdgrv>-newfdgrv.
    APPEND ls_doc_fdgrv TO lt_doc_fdgrv_upd.
  ENDLOOP.

  MODIFY ztfi_doc_fdgrv FROM TABLE lt_doc_fdgrv_upd.

  COMMIT WORK AND WAIT.
ENDFUNCTION.
