CLASS zclfi_dda_xblnr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS: gc_zero  TYPE c VALUE '0',
               gc_k     TYPE c VALUE 'K',
               gc_e     TYPE c VALUE 'E',
               gc_s     TYPE c VALUE 'S',
               gc_ponto TYPE c VALUE '.'.

    CONSTANTS: BEGIN OF gc_fieldname,
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
                 msgid   TYPE bapiret2-id VALUE 'ZFI_SOLUCAO_DDA',
               END OF gc_fieldname.

    TYPES:
      "! Tipo Arquivo 240 posições
      BEGIN OF ty_file_240,
        campo(240) TYPE c,
      END OF ty_file_240.

    TYPES:
      "! Categ. Tabela Arquivo 240 posições
      tt_file_240 TYPE STANDARD TABLE OF ty_file_240,
      tt_cds_rep  TYPE STANDARD TABLE OF zi_fi_cockpit_dda.

    DATA gt_file TYPE STANDARD TABLE OF ty_file_240.
    DATA gv_bukrs TYPE bseg-bukrs.

    DATA gr_supplier TYPE RANGE OF i_supplier-supplier.
    DATA gr_xblnr    TYPE RANGE OF bkpf-xblnr.

    METHODS:

      "! Processa Arquivo DDA
      process_file_ff5
        CHANGING ct_dados_arquivo TYPE tt_file_240,

      "! Reprocessa busca DDA
      reprocess_dda_ff5
        IMPORTING it_cds_rep TYPE ztt_j1b_error_dda
        EXPORTING et_return  TYPE bapiret2_tab,

      "! Reprocessa busca DDA
      processa_dda_manual
        IMPORTING is_dda_manual TYPE j1b_error_dda
                  iv_belnr      TYPE belnr_d
                  iv_buzei      TYPE buzei
        EXPORTING et_return     TYPE bapiret2_tab.

  PROTECTED SECTION.

  PRIVATE SECTION.

    METHODS: set_file
      IMPORTING
        VALUE(it_dados_arquivo) TYPE tt_file_240,

      get_bukrs
        EXCEPTIONS
          not_found,

      get_supplier
        IMPORTING
          iv_cnpj TYPE char14,

      get_xblnr
        IMPORTING
          iv_xbnlr TYPE xblnr1,
      update_j1b_dda
        IMPORTING
          is_process    TYPE j1b_error_dda
          iv_docnum     TYPE bseg-belnr
          iv_error_venc TYPE boolean OPTIONAL
          iv_error_mont TYPE boolean OPTIONAL,
      formart_valor
        IMPORTING
          iv_amount        TYPE j1b_error_dda-amount
        RETURNING
          VALUE(rv_result) TYPE bseg-wrbtr.

ENDCLASS.


CLASS zclfi_dda_xblnr IMPLEMENTATION.

  METHOD process_file_ff5.

    "Variables
    DATA: lv_indextb      TYPE sy-tabix,
          lv_tp_reg(01)   TYPE c,
          lv_segmento(01) TYPE c,
          lv_data(8)      TYPE c,
          lv_data_venc    TYPE datum,
          lv_gjahr        TYPE bseg-gjahr,
          lv_valor_tit    TYPE wrbtr,
          lv_cnpj         TYPE ztfi_dda_segto_g-num_insc.

    "Ranges


    set_file( ct_dados_arquivo  ).

    get_bukrs(
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2
    ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.


    LOOP AT me->gt_file ASSIGNING FIELD-SYMBOL(<fs_file_240>).
      lv_indextb = sy-tabix.

      CLEAR:
         lv_tp_reg, lv_segmento.

      lv_tp_reg = <fs_file_240>-campo+7(1).
      lv_segmento = <fs_file_240>-campo+13(1).

      "Segmento G
      IF lv_tp_reg = '3' AND
         lv_segmento = 'G'.

        CLEAR: lv_data, lv_data_venc, lv_cnpj,
               lv_gjahr, lv_valor_tit .
        lv_data = <fs_file_240>-campo+107(8).
        lv_data_venc = lv_data+4(4) && lv_data+2(2) && lv_data(2)..

        lv_cnpj = <fs_file_240>-campo+63(14).
        lv_gjahr = <fs_file_240>-campo+111(4).

        lv_valor_tit = <fs_file_240>-campo+115(13)  && gc_ponto && <fs_file_240>-campo+128(2) .

        "Buscar fornecedor - Raiz CNPJ
        get_supplier( CONV char14( lv_cnpj ) ).

        get_xblnr( CONV xblnr1( <fs_file_240>-campo+147(15) )  ).


        SELECT a~belnr, a~xblnr
          FROM bsik_view AS a
          INNER JOIN bseg AS b
            ON a~bukrs = b~bukrs AND
               a~belnr = b~belnr AND
               a~gjahr = b~gjahr AND
               a~buzei = b~buzei
          WHERE a~bukrs = @gv_bukrs
             AND a~gjahr = @lv_gjahr
             AND a~lifnr IN @gr_supplier
             AND a~xblnr IN @gr_xblnr
             AND b~netdt = @lv_data_venc
          INTO TABLE @DATA(lt_ref).

        IF lt_ref IS NOT INITIAL.

          IF lines( lt_ref ) = 1.
            "Altera arquivo processamento FF_5
            READ TABLE ct_dados_arquivo INDEX lv_indextb ASSIGNING FIELD-SYMBOL(<fs_file2>).
            IF sy-subrc = 0.
              CLEAR:<fs_file2>+147(15).
              <fs_file2>+147(15) = lt_ref[ 1 ]-xblnr.
            ENDIF.
          ELSE.

            DATA(ls_dda_xblnr) = VALUE ztfi_error_xblnr(
                bukrs = gv_bukrs
                gjahr = lv_gjahr
                cnpj = lv_cnpj
                due_date = <fs_file_240>-campo+107(8)
                reference_no = <fs_file_240>-campo+147(15) ).

            MODIFY ztfi_error_xblnr FROM ls_dda_xblnr.

          ENDIF.

        ELSE.

          SELECT a~belnr, a~xblnr
            FROM bsik_view AS a
            INNER JOIN bseg AS b
              ON a~bukrs = b~bukrs AND
                 a~belnr = b~belnr AND
                 a~gjahr = b~gjahr AND
                 a~buzei = b~buzei
            WHERE a~bukrs = @gv_bukrs
               AND a~gjahr = @lv_gjahr
               AND a~lifnr IN @gr_supplier
*               AND a~xblnr IN @lr_xblnr
               AND b~netdt = @lv_data_venc
               AND a~wrbtr = @lv_valor_tit
            INTO TABLE @DATA(lt_xbnlr_nmath).

          IF sy-subrc = 0.

            DATA(ls_dda_xblnr2) = VALUE ztfi_error_xblnr(
                 bukrs = gv_bukrs
                 gjahr = lv_gjahr
                 cnpj = lv_cnpj
                 due_date = <fs_file_240>-campo+107(8)
                 reference_no = <fs_file_240>-campo+147(15) ).

            MODIFY ztfi_error_xblnr FROM ls_dda_xblnr2.

          ENDIF.

        ENDIF.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD reprocess_dda_ff5.

    DATA: lv_msg    TYPE string,
          lv_amount TYPE bseg-wrbtr.



    LOOP AT it_cds_rep ASSIGNING FIELD-SYMBOL(<fs_process>).

      get_xblnr( <fs_process>-reference_no ).
      get_supplier( CONV char14( <fs_process>-cnpj+1(14) ) ).

      lv_amount = formart_valor( <fs_process>-amount ).

      SELECT SINGLE a~lifnr, a~bukrs, a~belnr, a~gjahr
          FROM bsik_view AS a
          INNER JOIN bseg AS b
            ON a~bukrs = b~bukrs AND
               a~belnr = b~belnr AND
               a~gjahr = b~gjahr AND
               a~buzei = b~buzei
          WHERE a~bukrs = @<fs_process>-bukrs
             AND a~gjahr = @<fs_process>-gjahr
             AND a~lifnr IN @gr_supplier
             AND a~xblnr IN @gr_xblnr
             AND a~wrbtr = @lv_amount
             AND b~netdt = @<fs_process>-due_date
          INTO @DATA(ls_documentp).

      "Encontrou documento
      IF sy-subrc = 0.

        DATA(lv_data_resul) = gc_fieldname-dda && <fs_process>-due_date+6(2) &&
                                               '.' && <fs_process>-due_date+4(2) &&
                                               '.' && <fs_process>-due_date(4).

        DATA(lt_accchg) = VALUE fdm_t_accchg(
                  ( fdname = gc_fieldname-zlsch_b
                    newval = gc_fieldname-b )
                  ( fdname = 'ZFBDT'
                    newval = <fs_process>-due_date )
                  ( fdname = gc_fieldname-zuonr
                    newval = lv_data_resul  )
                  ( fdname = 'ZBD1T'
                    newval = 0 )
                  ( fdname = 'GLO_REF1'
                    newval = <fs_process>-barcode )  ).

        IF lt_accchg IS NOT INITIAL.

          CALL FUNCTION 'FI_DOCUMENT_CHANGE'
            EXPORTING
              i_lifnr              = ls_documentp-lifnr
              i_bukrs              = ls_documentp-bukrs
              i_belnr              = ls_documentp-belnr
              i_gjahr              = ls_documentp-gjahr
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


            update_j1b_dda( is_process = <fs_process>
                            iv_docnum = ls_documentp-belnr  ).

            "Documento &1 processado com sucesso.
            MESSAGE s010(zfi_solucao_dda) INTO lv_msg.
            APPEND VALUE #( id         = gc_fieldname-msgid
                            type       = 'S'
                            number     = '009'
                            message_v1 = <fs_process>-reference_no ) TO et_return .

          ELSE.

            "Erro ao tentar atualizar fatura &1 &2
            MESSAGE e019(zfi_solucao_dda) INTO lv_msg.
            APPEND VALUE #( id         = gc_fieldname-msgid
                            type       = 'E'
                            number     = '019'
                            message_v1 = ls_documentp-belnr
                            message_v2 = ls_documentp-bukrs ) TO et_return .

          ENDIF.

        ENDIF."encontrou documento

      ELSE.

        "Tenta localizar fatura com vencimento diferente
        SELECT SINGLE a~lifnr, a~bukrs, a~belnr, a~gjahr
        FROM bsik_view AS a
        INNER JOIN bseg AS b
          ON a~bukrs = b~bukrs AND
             a~belnr = b~belnr AND
             a~gjahr = b~gjahr AND
             a~buzei = b~buzei
        WHERE a~bukrs = @<fs_process>-bukrs
           AND a~gjahr = @<fs_process>-gjahr
           AND a~lifnr IN @gr_supplier
           AND a~xblnr IN @gr_xblnr
           AND a~wrbtr = @lv_amount
*           AND b~netdt = @<fs_process>-due_date
        INTO @DATA(ls_documentp_venc).

        IF sy-subrc = 0.

          "Data de vencimento divergente &1
          MESSAGE s022(zfi_solucao_dda) INTO lv_msg.
          APPEND VALUE #( id         = gc_fieldname-msgid
                          type       = 'S'
                          number     = '022'
                          message_v1 = <fs_process>-reference_no ) TO et_return .

          update_j1b_dda( is_process = <fs_process>
                          iv_docnum = ls_documentp_venc-belnr
                          iv_error_venc = abap_true  ).

        ELSE.

          "Tenta localizar fatura com montante diferente
          SELECT SINGLE a~lifnr, a~bukrs, a~belnr, a~gjahr
          FROM bsik_view AS a
          INNER JOIN bseg AS b
            ON a~bukrs = b~bukrs AND
               a~belnr = b~belnr AND
               a~gjahr = b~gjahr AND
               a~buzei = b~buzei
          WHERE a~bukrs = @<fs_process>-bukrs
             AND a~gjahr = @<fs_process>-gjahr
             AND a~lifnr IN @gr_supplier
             AND a~xblnr IN @gr_xblnr
*             AND a~wrbtr = @<fs_process>-amount
             AND b~netdt = @<fs_process>-due_date
          INTO @DATA(ls_documentp_mont).

          IF sy-subrc = 0.

            "Montante divergente &1
            MESSAGE s023(zfi_solucao_dda) INTO lv_msg.
            APPEND VALUE #( id         = gc_fieldname-msgid
                            type       = 'S'
                            number     = '023'
                            message_v1 = <fs_process>-reference_no ) TO et_return .

            update_j1b_dda( is_process = <fs_process>
                            iv_docnum = ls_documentp_mont-belnr
                            iv_error_mont = abap_true  ).

          ELSE.

            "Tenta localizar fatura com xblnr diferente
            SELECT SINGLE a~lifnr, a~bukrs, a~belnr, a~gjahr
            FROM bsik_view AS a
            INNER JOIN bseg AS b
              ON a~bukrs = b~bukrs AND
                 a~belnr = b~belnr AND
                 a~gjahr = b~gjahr AND
                 a~buzei = b~buzei
            WHERE a~bukrs = @<fs_process>-bukrs
               AND a~gjahr = @<fs_process>-gjahr
               AND a~lifnr IN @gr_supplier
*               AND a~xblnr IN @gr_xblnr
             AND a~wrbtr = @lv_amount
               AND b~netdt = @<fs_process>-due_date
            INTO @DATA(ls_documentp_xblnr).

            IF sy-subrc = 0.

              DATA(ls_dda_xblnr2) = VALUE ztfi_error_xblnr(
                   bukrs = <fs_process>-bukrs
                   gjahr = <fs_process>-gjahr
                   cnpj = <fs_process>-cnpj
                   due_date = <fs_process>-due_date+6(2) && <fs_process>-due_date+4(2) && <fs_process>-due_date(4)
                   reference_no = <fs_process>-reference_no ).

              MODIFY ztfi_error_xblnr FROM ls_dda_xblnr2.

              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true.

              "NF divergente &1
              MESSAGE s024(zfi_solucao_dda) INTO lv_msg.
              APPEND VALUE #( id         = gc_fieldname-msgid
                              type       = 'S'
                              number     = '024'
                              message_v1 = <fs_process>-reference_no ) TO et_return .

            ELSE.

              "Fatura não localizada com todos critérios &1
              MESSAGE e017(zfi_solucao_dda) INTO lv_msg WITH <fs_process>-reference_no .
              APPEND VALUE #( id         = gc_fieldname-msgid
                              type       = 'E'
                              number     = '017'
                              message_v1 = <fs_process>-reference_no ) TO et_return .

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.


    ENDLOOP.

    "Processamento finalizad.
    MESSAGE s018(zfi_solucao_dda) INTO lv_msg.

    APPEND VALUE #( id         = gc_fieldname-msgid
                    type       = 'S'
                    number     = '018'
                    message_v1 = <fs_process>-reference_no ) TO et_return .

  ENDMETHOD.


  METHOD set_file.

    CLEAR: gt_file.
    me->gt_file = it_dados_arquivo.

  ENDMETHOD.


  METHOD get_bukrs.

***********************************************************************
    " Buscar empresa
***********************************************************************

    DATA: lv_paval  TYPE t001z-paval,
          lv_paval2 TYPE t001z-paval.

    CLEAR: gv_bukrs.
    READ TABLE me->gt_file ASSIGNING FIELD-SYMBOL(<fs_file>) INDEX 1.

    IF sy-subrc NE 0.
      RAISE not_found.
    ENDIF.

    lv_paval  = <fs_file>+19(08). "com zero incial
    lv_paval2 = <fs_file>+18(08). "sem zero  incial

    SELECT SINGLE bukrs
           FROM   t001z
           WHERE  paval EQ @lv_paval OR
                  paval EQ @lv_paval2
    INTO @gv_bukrs.
    IF sy-subrc NE 0.
      RAISE not_found.
    ENDIF.

  ENDMETHOD.


  METHOD get_supplier.

    DATA: lv_cnpj      TYPE ztfi_dda_segto_g-num_insc,
          lv_raiz_cnpj TYPE char8.

    DATA: lr_cnpj TYPE RANGE OF i_supplier-taxnumber1.

    CLEAR: me->gr_supplier.
    lv_cnpj = iv_cnpj.

    IF strlen( lv_cnpj ) < 14.
      lv_cnpj = shift_left( val = lv_cnpj sub = gc_zero ).
    ENDIF.

    lv_raiz_cnpj = lv_cnpj(8).
    APPEND VALUE #( sign = 'I'
                    option = 'CP'
                    low = lv_raiz_cnpj && '*' ) TO lr_cnpj.

    IF lr_cnpj IS NOT INITIAL .

      SELECT supplier
          FROM i_supplier
          WHERE taxnumber1 IN @lr_cnpj
          INTO TABLE @DATA(lt_supplier).

      IF lt_supplier IS NOT INITIAL.
        me->gr_supplier = VALUE #( FOR ls_supplier IN lt_supplier
                (  sign = 'I'
                   option = 'EQ'
                   low = ls_supplier ) ).
      ENDIF.

    ENDIF.


  ENDMETHOD.


  METHOD get_xblnr.

    DATA: lv_documento TYPE xblnr1.

    CLEAR: me->gr_xblnr.
    lv_documento = iv_xbnlr.
    IF lv_documento CO '0123456789'.

    ELSE.

*          SPLIT lv_documento AT '/' INTO DATA(lv_part1) DATA(lv_part2).
*          APPEND VALUE #( sign = 'I'
*                        option = 'CP'
*                        low = '*' && lv_part1 ) TO lr_xblnr.

      REPLACE '/' IN lv_documento WITH '-'.
    ENDIF.

    APPEND VALUE #( sign = 'I'
                    option = 'EQ'
                    low = lv_documento ) TO gr_xblnr.

    SHIFT lv_documento LEFT DELETING LEADING '0'.
    CONDENSE lv_documento NO-GAPS.

    APPEND VALUE #( sign = 'I'
                    option = 'CP'
                    low = '*' && lv_documento ) TO gr_xblnr.

  ENDMETHOD.


  METHOD update_j1b_dda.


    SELECT SINGLE *
      FROM j1b_error_dda
      WHERE status_check = @gc_e
*      and LIFNR = is_process-Supplier
        AND reference_no = @is_process-reference_no
        AND bukrs = @is_process-bukrs
        AND gjahr = @is_process-gjahr
        INTO @DATA(ls_error_dda).

    IF sy-subrc = 0.

      DELETE j1b_error_dda FROM ls_error_dda.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      IF iv_error_venc = abap_true.

        ls_error_dda-err_reason = 'D'.
        ls_error_dda-msg = 'Due Dates do not match'.
        ls_error_dda-lifnr = is_process-lifnr.
        ls_error_dda-doc_num = iv_docnum.

        MODIFY j1b_error_dda FROM ls_error_dda.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.

      ELSEIF iv_error_mont = abap_true.

        ls_error_dda-err_reason = 'A'.
        ls_error_dda-msg = 'Amounts do not match'.
        ls_error_dda-lifnr = is_process-lifnr.
        ls_error_dda-doc_num = iv_docnum.

        MODIFY j1b_error_dda FROM ls_error_dda.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.

      ELSE.


        CLEAR: ls_error_dda-err_reason, ls_error_dda-msg.
        ls_error_dda-id = '@08@'.
        ls_error_dda-status_check = 'S'.
        ls_error_dda-lifnr = is_process-lifnr.
        ls_error_dda-doc_num = iv_docnum.

        MODIFY j1b_error_dda FROM ls_error_dda.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.

      ENDIF.

    ENDIF.


  ENDMETHOD.

  METHOD processa_dda_manual.

    DATA lv_msg TYPE string.


    SELECT SINGLE lifnr, bukrs, belnr, gjahr, buzei
         FROM bsik_view
          WHERE bukrs = @is_dda_manual-bukrs
            AND gjahr = @is_dda_manual-gjahr
            AND belnr = @iv_belnr
            AND buzei = @iv_buzei
         INTO @DATA(ls_document).

    IF sy-subrc = 0.

      DATA(lv_data_resul) = gc_fieldname-dda && is_dda_manual-due_date+6(2) &&
                                             '.' && is_dda_manual-due_date+4(2) &&
                                             '.' && is_dda_manual-due_date(4).

      DATA(lt_accchg) = VALUE fdm_t_accchg(
                ( fdname = gc_fieldname-zlsch_b
                  newval = gc_fieldname-b )
                ( fdname = 'ZFBDT'
                  newval = is_dda_manual-due_date )
                ( fdname = gc_fieldname-zuonr
                  newval = lv_data_resul  )
                ( fdname = 'ZBD1T'
                  newval = 0 )
                ( fdname = 'GLO_REF1'
                  newval = is_dda_manual-barcode )  ).

      IF lt_accchg IS NOT INITIAL.

        CALL FUNCTION 'FI_DOCUMENT_CHANGE'
          EXPORTING
            i_lifnr              = ls_document-lifnr
            i_bukrs              = ls_document-bukrs
            i_belnr              = ls_document-belnr
            i_gjahr              = ls_document-gjahr
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


          update_j1b_dda( is_process = is_dda_manual
                          iv_docnum = ls_document-belnr  ).

          "Documento &1 processado com sucesso.
          MESSAGE s010(zfi_solucao_dda) INTO lv_msg.
          APPEND VALUE #( id         = gc_fieldname-msgid
                          type       = 'S'
                          number     = '009'
                          message_v1 = is_dda_manual-reference_no ) TO et_return .

        ELSE.

          "Erro ao tentar atualizar fatura &1 &2
          MESSAGE e019(zfi_solucao_dda) INTO lv_msg.
          APPEND VALUE #( id         = gc_fieldname-msgid
                          type       = 'E'
                          number     = '019'
                          message_v1 = ls_document-belnr
                          message_v2 = ls_document-bukrs ) TO et_return .

        ENDIF.

      ENDIF.

    ENDIF.

    "Processamento finalizad.
    MESSAGE s018(zfi_solucao_dda) INTO lv_msg.

    APPEND VALUE #( id         = gc_fieldname-msgid
                    type       = 'S'
                    number     = '018'
                    message_v1 = is_dda_manual-reference_no ) TO et_return .

  ENDMETHOD.


  METHOD formart_valor.


    CONSTANTS:
      lc_ponto TYPE c VALUE '.'.

    DATA: lv_valor(20)    TYPE c,
          lv_tam          TYPE i,
          lv_inteiros(20) TYPE c,
          lv_decimais(20) TYPE c,
          lv_casas(2)     TYPE n.

    lv_tam = strlen( iv_amount ).

    lv_casas = lv_tam - 2.

    lv_inteiros  = iv_amount(lv_casas).
    lv_decimais = iv_amount+lv_casas(2).

    CONDENSE: lv_inteiros, lv_decimais.

    CLEAR: lv_valor.

    CONCATENATE lv_inteiros lv_decimais INTO lv_valor
        SEPARATED BY lc_ponto.

    rv_result = lv_valor.


  ENDMETHOD.

ENDCLASS.
