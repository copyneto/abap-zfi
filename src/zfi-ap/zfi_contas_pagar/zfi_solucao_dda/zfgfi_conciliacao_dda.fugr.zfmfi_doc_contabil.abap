FUNCTION zfmfi_doc_contabil.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      IT_SEGTO STRUCTURE  ZTFI_DDA_SEGTO_G
*"      IT_HEADER STRUCTURE  ZTFI_DDA_HEADER
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ty_bsik_key,
           bukrs TYPE bukrs,
           gjahr TYPE gjahr,
           xblnr TYPE xblnr1,
           belnr TYPE belnr_d,
         END OF ty_bsik_key,
         BEGIN OF ty_bsik_item,
           lifnr TYPE lifnr,
           bukrs TYPE  bukrs,
           belnr TYPE belnr_d,
           gjahr TYPE gjahr,
         END OF ty_bsik_item.

  CONSTANTS: BEGIN OF lc_fieldname,
               barcode TYPE fieldname VALUE 'GLO_REF1',
               e       TYPE status2_br  VALUE 'E',
               b       TYPE err_br VALUE 'B',
               v       TYPE err_br VALUE 'V',
               a       TYPE dzlspr VALUE 'A',
               k       TYPE koart  VALUE 'K',
               zlsch_b TYPE fieldname VALUE 'ZLSCH',
               zuonr   TYPE fieldname VALUE 'ZUONR',
               dda     TYPE char4 VALUE 'DDA_',
               message TYPE char255 VALUE 'Divergence in reference',
             END OF lc_fieldname.

  DATA: lr_xblnr         TYPE RANGE OF xblnr,
        gt_error_dda     TYPE STANDARD TABLE OF j1b_error_dda,
        lt_tab_bsik_key  TYPE TABLE OF ty_bsik_key,
        lt_error_dda_key TYPE TABLE OF j1b_error_dda,
        lt_bsik_item     TYPE TABLE OF ty_bsik_item.


  WAIT UP TO 7 SECONDS.

*  DATA(lv_data) = VALUE #( it_header[ 1 ]-data_arq  OPTIONAL ).
  DATA(lv_data) = VALUE #( it_segto[ 1 ]-data_arq  OPTIONAL ).

  IF lv_data IS NOT INITIAL.
    DATA(lv_data_resul) = lc_fieldname-dda && lv_data+6(2) && '.' && lv_data+4(2) && '.' && lv_data(4).
  ENDIF.

  CHECK it_segto[] IS NOT INITIAL.

  lt_tab_bsik_key = VALUE #( FOR ls_segto IN it_segto
                             ( xblnr = ls_segto-belnr
                               belnr = ls_segto-belnr
                               bukrs = ls_segto-bukrs
                               gjahr = ls_segto-gjahr ) ).

  SORT lt_tab_bsik_key. DELETE ADJACENT DUPLICATES FROM lt_tab_bsik_key.

  CHECK lt_tab_bsik_key IS NOT INITIAL.

  CLEAR: lt_bsik_item.


  SELECT lifnr, bukrs, belnr, gjahr FROM bsik_view
            FOR ALL ENTRIES IN @lt_tab_bsik_key
            WHERE bukrs EQ @lt_tab_bsik_key-bukrs
              AND gjahr EQ @lt_tab_bsik_key-gjahr
              AND xblnr EQ @lt_tab_bsik_key-xblnr
              INTO TABLE @lt_bsik_item.

  SELECT lifnr, bukrs, belnr, gjahr FROM bsik_view
          FOR ALL ENTRIES IN @lt_tab_bsik_key
          WHERE bukrs EQ @lt_tab_bsik_key-bukrs
            AND gjahr EQ @lt_tab_bsik_key-gjahr
            AND belnr EQ @lt_tab_bsik_key-belnr
            APPENDING TABLE @lt_bsik_item.

  CHECK lt_bsik_item IS NOT INITIAL.

  SELECT lifnr, bukrs, belnr, gjahr, netdt FROM bseg
            FOR ALL ENTRIES IN @lt_bsik_item
            WHERE bukrs = @lt_bsik_item-bukrs
              AND belnr = @lt_bsik_item-belnr
              AND gjahr = @lt_bsik_item-gjahr
              AND koart = @lc_fieldname-k
              AND zlspr <> @lc_fieldname-a
              INTO TABLE @DATA(lt_bseg).

  CHECK lt_bseg[] IS NOT INITIAL.

  SELECT b~*, a~documentreferenceid FROM i_accountingdocument AS a
  INNER JOIN j1b_error_dda AS b
  ON  b~bukrs   = a~companycode
  AND b~gjahr   = a~fiscalyear
  AND b~doc_num = a~accountingdocument
  FOR ALL ENTRIES IN @lt_bseg
   WHERE  bukrs        = @lt_bseg-bukrs
     AND  doc_num      = @lt_bseg-belnr
     AND  gjahr        = @lt_bseg-gjahr
        INTO TABLE @DATA(lt_acount).

  LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>).
    IF <fs_bseg>-netdt IS NOT INITIAL.
      lv_data_resul = lc_fieldname-dda && <fs_bseg>-netdt+6(2) && '.' && <fs_bseg>-netdt+4(2) && '.' && <fs_bseg>-netdt(4).
    ENDIF.

    DATA(ls_result) = VALUE #( lt_acount[ b-bukrs = <fs_bseg>-bukrs b-doc_num = <fs_bseg>-belnr b-gjahr = <fs_bseg>-gjahr ]  OPTIONAL ).

    APPEND VALUE j1b_error_dda( status_check = lc_fieldname-e
          lifnr        = <fs_bseg>-lifnr
          reference_no = ls_result-documentreferenceid
          doc_num      = ls_result-b-doc_num
          miro_invoice = ls_result-b-miro_invoice
          bukrs        = <fs_bseg>-bukrs
          gjahr        = <fs_bseg>-gjahr
          cnpj         = ls_result-b-cnpj
          due_date     = ls_result-b-due_date ) TO lt_error_dda_key.
  ENDLOOP.

  SORT lt_error_dda_key. DELETE ADJACENT DUPLICATES FROM lt_error_dda_key.

  IF lt_error_dda_key IS NOT INITIAL.

    SELECT *
      FROM j1b_error_dda
      FOR ALL ENTRIES IN @lt_error_dda_key
      WHERE status_check = @lt_error_dda_key-status_check
        AND lifnr        = @lt_error_dda_key-lifnr
        AND reference_no = @lt_error_dda_key-reference_no
        AND doc_num      = @lt_error_dda_key-doc_num
        AND miro_invoice = @lt_error_dda_key-miro_invoice
        AND bukrs        = @lt_error_dda_key-bukrs
        AND gjahr        = @lt_error_dda_key-gjahr
        AND cnpj         = @lt_error_dda_key-cnpj
        AND due_date     = @lt_error_dda_key-due_date
      INTO TABLE @DATA(lt_j1b_error_dda).

    SORT lt_j1b_error_dda BY status_check lifnr reference_no doc_num
                             miro_invoice bukrs gjahr cnpj due_date.
  ENDIF.

  LOOP AT lt_bseg ASSIGNING <fs_bseg>.

    ls_result = VALUE #( lt_acount[ b-bukrs = <fs_bseg>-bukrs b-doc_num = <fs_bseg>-belnr b-gjahr = <fs_bseg>-gjahr ]  OPTIONAL ).

    CHECK ls_result IS NOT INITIAL.

    " Validação comentada pois a referencia no arquivo foi trocado pelo numero do documento BELNR
***    IF ls_result-b-reference_no NE ls_result-documentreferenceid.
***
***      DATA(ls_dda_erro) = VALUE j1b_error_dda(
***        id           = '@0A@'
***        status_check = lc_fieldname-e
***        lifnr        = <fs_bseg>-lifnr
***        reference_no = ls_result-documentreferenceid
***        doc_num      = ls_result-b-doc_num
***        miro_invoice = ls_result-b-miro_invoice
***        bukrs        = <fs_bseg>-bukrs
***        gjahr        = <fs_bseg>-gjahr
***        cnpj         = ls_result-b-cnpj
***        due_date     = ls_result-b-due_date
***        amount       = ls_result-b-amount
***        barcode      = ls_result-b-barcode
***        rec_num      = ls_result-b-rec_num
***        partner      = ls_result-b-partner
***        issue_date   = ls_result-b-issue_date
***        posting_date = ls_result-b-posting_date
***        err_reason   = lc_fieldname-v
***        msg          = lc_fieldname-message
***      ) .
***
***      IF  ls_dda_erro IS NOT INITIAL.
***
***        MODIFY j1b_error_dda FROM ls_result-b.
***
***        IF sy-subrc EQ 0.
***          COMMIT WORK.
***        ENDIF.
***
***      ENDIF.
***
***    ELSE.
    READ TABLE lt_j1b_error_dda TRANSPORTING NO FIELDS WITH KEY status_check = lc_fieldname-e
                                                                lifnr        = <fs_bseg>-lifnr
                                                                reference_no = ls_result-documentreferenceid
                                                                doc_num      = ls_result-b-doc_num
                                                                miro_invoice = ls_result-b-miro_invoice
                                                                bukrs        = <fs_bseg>-bukrs
                                                                gjahr        = <fs_bseg>-gjahr
                                                                cnpj         = ls_result-b-cnpj
                                                                due_date     = ls_result-b-due_date BINARY SEARCH.

    IF sy-subrc <> 0.

      lv_data_resul = lc_fieldname-dda && ls_result-b-due_date(2) && '.' && ls_result-b-due_date+2(2) && '.' && ls_result-b-due_date+4(4).

      DATA(lt_accchg) = VALUE fdm_t_accchg(
                ( fdname = lc_fieldname-zlsch_b
                  newval = lc_fieldname-b )
                ( fdname = 'ZFBDT'
                  newval = |{ ls_result-b-due_date+4(4) }{ ls_result-b-due_date+2(2) }{ ls_result-b-due_date(2) }| )
                ( fdname = lc_fieldname-zuonr
                  newval = lv_data_resul  )
                ( fdname = 'ZBD1T'
                  newval = 0 ) ).

      IF lt_accchg IS NOT INITIAL.

        CALL FUNCTION 'FI_DOCUMENT_CHANGE'
          EXPORTING
            i_lifnr              = <fs_bseg>-lifnr
            i_bukrs              = <fs_bseg>-bukrs
            i_belnr              = <fs_bseg>-belnr
            i_gjahr              = <fs_bseg>-gjahr
          TABLES
            t_accchg             = lt_accchg
          EXCEPTIONS
            no_reference         = 1
            no_document          = 2
            many_documents       = 3
            wrong_input          = 4
            overwrite_creditcard = 5
            OTHERS               = 6.

        IF sy-subrc EQ 0.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.

        ENDIF.

      ENDIF.
    ENDIF.
****    ENDIF.
  ENDLOOP.


ENDFUNCTION.
