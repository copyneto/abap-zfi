CLASS zclfi_contab_depre_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS executa
      IMPORTING it_linhas TYPE zctgfi_contab_depre
      EXPORTING et_return TYPE bapiret2_t.

    METHODS executa_reav
      IMPORTING it_linhas TYPE zctgfi_contab_depre
      EXPORTING et_return TYPE bapiret2_t.

  PROTECTED SECTION.
private section.

  constants GC_CURRENCY type WAERS value 'BRL' ##NO_TEXT.
  constants GC_DOC_TYPE type CHAR2 value 'AA' ##NO_TEXT.
  constants GC_E type CHAR1 value 'E' ##NO_TEXT.
  data GS_HEADER type BAPIACHE09 .
  data GT_ACC_GL type BAPIACGL09_TAB .
  data GT_ACC_REC type BAPIACAR09_TAB .
  data GT_CURRENCY type BAPIACCR09_TAB .
  data GT_RETURN type BAPIRET2_T .
  data GT_MSG_EX type BAPIRET2_T .
  data GV_DUMMY type STRING .
  data:
    gt_items_sum TYPE TABLE OF zsfi_contab_depre_item_lanc .
  data GV_DATA_LANC type DATUM .

  methods APPEND_MSG .
  methods FILL_BAPI
    changing
      !CT_LINHAS type ZCTGFI_CONTAB_DEPRE .
  methods FILL_HEADER
    importing
      !IT_LINHAS type ZCTGFI_CONTAB_DEPRE .
  methods FILL_ITEMS
    changing
      !CT_LINHAS type ZCTGFI_CONTAB_DEPRE .
  methods GET_CENTRO_LUCRO
    importing
      !IS_LINHA type ZSFI_CONTAB_DEPRE_ITEM_LANC
    returning
      value(RV_RESULT) type BAPIACGL09-PROFIT_CTR .
  methods EXEC_BAPI
    importing
      !IV_REAV type BOOLEAN optional
      !IT_LINHAS type ZCTGFI_CONTAB_DEPRE .
  methods SAVE_LOG_SUCESS
    importing
      !IT_LINHAS type ZCTGFI_CONTAB_DEPRE
      !IV_BELNR type BELNR_D .
  methods FILL_ITEM_80
    importing
      !IS_LINHA type ZSFI_CONTAB_DEPRE .
  methods FILL_ITEM_82
    importing
      !IS_LINHA type ZSFI_CONTAB_DEPRE .
  methods FILL_ITEM_84
    importing
      !IS_LINHA type ZSFI_CONTAB_DEPRE .
  methods FILL_ITEM_01_REAV
    importing
      !IS_LINHA type ZSFI_CONTAB_DEPRE .
  methods FILL_ITEM_10_REAV
    importing
      !IS_LINHA type ZSFI_CONTAB_DEPRE .
  methods FILL_ITEM_11_REAV
    importing
      !IS_LINHA type ZSFI_CONTAB_DEPRE .
  methods FILL_ITEM_BAPI
    importing
      !IV_REAV type BOOLEAN optional .
  methods FILL_BAPI_REAV
    importing
      !IT_LINHAS type ZCTGFI_CONTAB_DEPRE .
  methods FILL_HEADER_REAV
    importing
      !IT_LINHAS type ZCTGFI_CONTAB_DEPRE .
  methods FILL_ITEMS_REAV
    importing
      !IT_LINHAS type ZCTGFI_CONTAB_DEPRE .
  methods SAVE_LOG_SUCESS_REAV
    importing
      !IT_LINHAS type ZCTGFI_CONTAB_DEPRE
      !IV_BELNR type BELNR_D .
ENDCLASS.



CLASS ZCLFI_CONTAB_DEPRE_UTIL IMPLEMENTATION.


  METHOD executa.

    CLEAR: gt_msg_ex.

    DATA(lt_linhas) = it_linhas[].

    fill_bapi( CHANGING ct_linhas = lt_linhas  ).

    exec_bapi( lt_linhas ).

    et_return = gt_msg_ex.

  ENDMETHOD.


  METHOD executa_reav.

    CLEAR: gt_msg_ex.

    fill_bapi_reav( it_linhas ).

    exec_bapi( iv_reav = abap_true
               it_linhas = it_linhas ).

    et_return = gt_msg_ex.

  ENDMETHOD.


  METHOD append_msg.

    DATA(ls_message) = VALUE bapiret2( type       = sy-msgty
                                       id         = sy-msgid
                                       number     = sy-msgno
                                       message_v1 = sy-msgv1
                                       message_v2 = sy-msgv2
                                       message_v3 = sy-msgv3
                                       message_v4 = sy-msgv4 ).
    APPEND ls_message TO gt_msg_ex.

  ENDMETHOD.


  METHOD fill_bapi.

*    fill_header( ct_linhas ).

    fill_items( CHANGING ct_linhas = ct_linhas ).

  ENDMETHOD.


  METHOD fill_header.

    DATA: lv_last_day  TYPE datum,
          lv_day_peraf TYPE datum.

    CLEAR: gs_header, gv_data_lanc.

    READ TABLE it_linhas ASSIGNING FIELD-SYMBOL(<fs_linha>) INDEX 1.
    IF sy-subrc = 0.

      lv_day_peraf = <fs_linha>-gjahr && <fs_linha>-peraf+1(2) && '01'.

      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = lv_day_peraf
        IMPORTING
          last_day_of_month = lv_last_day
        EXCEPTIONS
          day_in_no_date    = 1
          OTHERS            = 2.
      IF sy-subrc <> 0.
        lv_last_day = sy-datum.
      ENDIF.

      gv_data_lanc = lv_last_day.


      me->gs_header-pstng_date = lv_last_day.
      me->gs_header-doc_date   = lv_last_day.
*      me->gs_header-fisc_year   = lv_last_day(4).
*      me->gs_header-fis_period  = lv_last_day+4(2).
      me->gs_header-comp_code  = <fs_linha>-bukrs.
      me->gs_header-ref_doc_no = lv_last_day+4(2) && '/' && lv_last_day(4).
      me->gs_header-header_txt = lv_last_day+4(2) && '/' && lv_last_day(4).
      me->gs_header-doc_type   = me->gc_doc_type.
      me->gs_header-username   = sy-uname.
    ENDIF.

  ENDMETHOD.


  METHOD fill_items.

    DATA: lt_linhas	TYPE zctgfi_contab_depre.

    LOOP AT ct_linhas ASSIGNING FIELD-SYMBOL(<fs_linha>).

      IF <fs_linha>-ajust80_01 IS INITIAL
     AND <fs_linha>-ajust82_10 IS INITIAL
     AND <fs_linha>-ajust84_11 IS INITIAL.

        " Valores de ajustes zerados. &1 &2
        MESSAGE w004(zfi_contab_depre) WITH <fs_linha>-anlkl
                                            <fs_linha>-anln1
                                            <fs_linha>-anln2
                                       INTO gv_dummy.
        append_msg( ).

        CONTINUE.

      ENDIF.

      APPEND <fs_linha> TO lt_linhas.

      fill_item_80( <fs_linha> ).
      fill_item_82( <fs_linha> ).
      fill_item_84( <fs_linha> ).

    ENDLOOP.

    ct_linhas = lt_linhas.

*    fill_item_bapi(  ).

  ENDMETHOD.


  METHOD get_centro_lucro.

    SELECT SINGLE prctr
   INTO rv_result
   FROM csks
   WHERE kokrs = is_linha-bukrs
     AND kostl = is_linha-kostl.


  ENDMETHOD.


  METHOD exec_bapi.

    DATA: lt_linhas_aux   TYPE zctgfi_contab_depre,
          lt_linhas_prc   TYPE zctgfi_contab_depre,
          lt_acc_gl_aux   TYPE bapiacgl09_tab,
          lt_currency_aux	TYPE bapiaccr09_tab.

    DATA: lv_obj_key TYPE bapiache09-obj_key,
          lv_texto   TYPE char50,
          lv_item_no TYPE bapiacgl09-itemno_acc.

    SELECT kokrs,
           kostl,
           prctr
      FROM csks
       FOR ALL ENTRIES IN @gt_items_sum
     WHERE kokrs = @gt_items_sum-bukrs
       AND kostl = @gt_items_sum-kostl
      INTO TABLE @DATA(lt_result).

    IF sy-subrc IS INITIAL.
      SORT lt_result BY kokrs
                        kostl.
    ENDIF.

    CLEAR lv_item_no.

    SORT gt_items_sum BY bukrs
                         gsber
                         kostl
                         gjahr.

    DATA(lt_itens_key) = gt_items_sum[].

    DELETE ADJACENT DUPLICATES FROM lt_itens_key COMPARING bukrs
                                                           gsber
                                                           kostl
                                                           gjahr.

    DATA(lt_linhas) = it_linhas[].
    SORT lt_linhas BY bukrs
                      gsber
                      kostl
                      gjahr.

    LOOP AT lt_itens_key ASSIGNING FIELD-SYMBOL(<fs_itens_key>).

      READ TABLE lt_linhas TRANSPORTING NO FIELDS
                                         WITH KEY bukrs = <fs_itens_key>-bukrs
                                                  gsber = <fs_itens_key>-gsber
                                                  kostl = <fs_itens_key>-kostl
                                                  gjahr = <fs_itens_key>-gjahr
                                                  BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        LOOP AT lt_linhas ASSIGNING FIELD-SYMBOL(<fs_linhas>) FROM sy-tabix.
          IF <fs_linhas>-bukrs NE <fs_itens_key>-bukrs
          OR <fs_linhas>-gsber NE <fs_itens_key>-gsber
          OR <fs_linhas>-kostl NE <fs_itens_key>-kostl
          OR <fs_linhas>-gjahr NE <fs_itens_key>-gjahr.
            EXIT.
          ENDIF.

          APPEND <fs_linhas> TO lt_linhas_aux.

        ENDLOOP.
      ENDIF.

      READ TABLE gt_items_sum TRANSPORTING NO FIELDS
                                            WITH KEY bukrs = <fs_itens_key>-bukrs
                                                     gsber = <fs_itens_key>-gsber
                                                     kostl = <fs_itens_key>-kostl
                                                     gjahr = <fs_itens_key>-gjahr
                                                     BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        LOOP AT gt_items_sum ASSIGNING FIELD-SYMBOL(<fs_item>).
          IF <fs_item>-bukrs NE <fs_itens_key>-bukrs
          OR <fs_item>-gsber NE <fs_itens_key>-gsber
          OR <fs_item>-kostl NE <fs_itens_key>-kostl
          OR <fs_item>-gjahr NE <fs_itens_key>-gjahr.
            EXIT.
          ENDIF.

          lv_item_no = lv_item_no + 1.

          APPEND INITIAL LINE TO lt_acc_gl_aux ASSIGNING FIELD-SYMBOL(<fs_gl>).
          <fs_gl>-itemno_acc = lv_item_no.
          <fs_gl>-comp_code  = <fs_item>-bukrs.
          <fs_gl>-gl_account = <fs_item>-conta.
          <fs_gl>-bus_area   = <fs_item>-gsber.
          <fs_gl>-costcenter = <fs_item>-kostl.

          READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<fs_result>)
                                             WITH KEY kokrs = <fs_item>-bukrs
                                                      kostl = <fs_item>-kostl
                                                      BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            <fs_gl>-profit_ctr = <fs_result>-prctr.
          ENDIF.

          IF iv_reav = abap_true.
            CONCATENATE 'VR REF DEPR REAV' gv_data_lanc+4(2) '/' gv_data_lanc(4) INTO <fs_gl>-item_text SEPARATED BY space.
          ELSE.
            CONCATENATE 'VR REF DEPR SOC ' gv_data_lanc+4(2) '/' gv_data_lanc(4) INTO <fs_gl>-item_text SEPARATED BY space.
          ENDIF.

          APPEND INITIAL LINE TO lt_currency_aux ASSIGNING FIELD-SYMBOL(<fs_curr>).
          <fs_curr>-itemno_acc   = lv_item_no.
          <fs_curr>-currency_iso = gc_currency.
          <fs_curr>-amt_doccur   = <fs_item>-valor.

        ENDLOOP.

        IF ( lines( me->gt_acc_gl ) + lines( lt_acc_gl_aux ) ) LE 900.

          APPEND LINES OF lt_acc_gl_aux TO me->gt_acc_gl.
          APPEND LINES OF lt_currency_aux TO me->gt_currency.
          APPEND LINES OF lt_linhas_aux TO lt_linhas_prc.

          FREE: lt_acc_gl_aux[],
                lt_currency_aux[],
                lt_linhas_aux[].

        ELSE.

          fill_header( lt_linhas ).

          CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
            EXPORTING
              documentheader = me->gs_header
            IMPORTING
              obj_key        = lv_obj_key
            TABLES
              accountgl      = me->gt_acc_gl
              currencyamount = me->gt_currency
              return         = me->gt_return.

          " Erro no lançamento
          IF line_exists( me->gt_return[ type = gc_e ] ). "#EC CI_STDSEQ
            " Error ao tentar criar lançamento: &1 &2 &3 &4
            MESSAGE e001(zfi_contab_depre) WITH gs_header-comp_code
                                                gs_header-doc_type
                                                INTO gv_dummy.
            append_msg( ).

            APPEND LINES OF me->gt_return TO me->gt_msg_ex.

          ELSE.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.

            " Documento criado com sucesso: &1 &2 &3
            MESSAGE s002(zfi_contab_depre) WITH lv_obj_key(10)
                                                lv_obj_key+10(4)
                                                lv_obj_key+14(4)
                                                INTO gv_dummy.
            append_msg( ).

            IF iv_reav = abap_true.
              save_log_sucess_reav( EXPORTING it_linhas = lt_linhas_prc
                                              iv_belnr  = lv_obj_key(10) ).
            ELSE.
              save_log_sucess( EXPORTING it_linhas = lt_linhas_prc
                                         iv_belnr  = lv_obj_key(10) ).
            ENDIF.

          ENDIF.

          FREE: me->gt_acc_gl[],
                me->gt_currency[],
                me->gt_return[],
                lt_linhas_prc[].

          CLEAR: me->gs_header,
                 lv_obj_key.

          CLEAR lv_item_no.
          APPEND LINES OF lt_acc_gl_aux TO me->gt_acc_gl.
          LOOP AT me->gt_acc_gl[] ASSIGNING FIELD-SYMBOL(<fs_acc_gl>).
            ADD 1 TO lv_item_no.
            <fs_acc_gl>-itemno_acc = lv_item_no.
          ENDLOOP.

          CLEAR lv_item_no.
          APPEND LINES OF lt_currency_aux TO me->gt_currency.
          LOOP AT me->gt_currency[] ASSIGNING FIELD-SYMBOL(<fs_currency>).
            ADD 1 TO lv_item_no.
            <fs_currency>-itemno_acc = lv_item_no.
          ENDLOOP.

          APPEND LINES OF lt_linhas_aux TO lt_linhas_prc.

          CLEAR lv_item_no.

          FREE: lt_acc_gl_aux[],
                lt_currency_aux[],
                lt_linhas_aux[].

        ENDIF.
      ENDIF.

    ENDLOOP.

    IF me->gt_acc_gl[] IS NOT INITIAL.

      fill_header( lt_linhas ).

      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader = me->gs_header
        IMPORTING
          obj_key        = lv_obj_key
        TABLES
          accountgl      = me->gt_acc_gl
          currencyamount = me->gt_currency
          return         = me->gt_return.

      " Erro no lançamento
      IF line_exists( me->gt_return[ type = gc_e ] ).    "#EC CI_STDSEQ
        " Error ao tentar criar lançamento: &1 &2 &3 &4
        MESSAGE e001(zfi_contab_depre) WITH gs_header-comp_code
                                            gs_header-doc_type
                                            INTO gv_dummy.
        append_msg( ).

        APPEND LINES OF me->gt_return TO me->gt_msg_ex.

      ELSE.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.

        " Documento criado com sucesso: &1 &2 &3
        MESSAGE s002(zfi_contab_depre) WITH lv_obj_key(10)
                                            lv_obj_key+10(4)
                                            lv_obj_key+14(4)
                                            INTO gv_dummy.
        append_msg( ).

        IF iv_reav = abap_true.
          save_log_sucess_reav( EXPORTING it_linhas = lt_linhas_prc
                                          iv_belnr  = lv_obj_key(10) ).
        ELSE.
          save_log_sucess( EXPORTING it_linhas = lt_linhas_prc
                                     iv_belnr  = lv_obj_key(10) ).
        ENDIF.

      ENDIF.

      FREE: me->gt_acc_gl[],
            me->gt_currency[],
            me->gt_return[],
            lt_linhas_prc[].

      CLEAR: me->gs_header,
             lv_obj_key.

    ENDIF.

*    LOOP AT gt_items_sum ASSIGNING FIELD-SYMBOL(<fs_item>).
*
*      lv_item_no = lv_item_no + 1.
*
*      APPEND INITIAL LINE TO me->gt_acc_gl ASSIGNING FIELD-SYMBOL(<fs_gl>).
*      <fs_gl>-itemno_acc = lv_item_no.
*      <fs_gl>-comp_code  = <fs_item>-bukrs.
*      <fs_gl>-gl_account = <fs_item>-conta.
*      <fs_gl>-bus_area   = <fs_item>-gsber.
*      <fs_gl>-costcenter = <fs_item>-kostl.
*
*      READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<fs_result>)
*                                         WITH KEY kokrs = <fs_item>-bukrs
*                                                  kostl = <fs_item>-kostl
*                                                  BINARY SEARCH.
*      IF sy-subrc IS INITIAL.
*        <fs_gl>-profit_ctr = <fs_result>-prctr.
*      ENDIF.
*
*      IF iv_reav = abap_true.
*        CONCATENATE 'VR REF DEPR REAV' gv_data_lanc+4(2) '/' gv_data_lanc(4) INTO <fs_gl>-item_text SEPARATED BY space.
*      ELSE.
*        CONCATENATE 'VR REF DEPR SOC ' gv_data_lanc+4(2) '/' gv_data_lanc(4) INTO <fs_gl>-item_text SEPARATED BY space.
*      ENDIF.
*
*      APPEND INITIAL LINE TO me->gt_currency ASSIGNING FIELD-SYMBOL(<fs_curr>).
*      <fs_curr>-itemno_acc   = lv_item_no.
*      <fs_curr>-currency_iso = gc_currency.
*      <fs_curr>-amt_doccur   = <fs_item>-valor.
*
*    ENDLOOP.
*
*    CHECK me->gt_acc_gl IS NOT INITIAL.
*
*    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*      EXPORTING
*        documentheader = me->gs_header
*      IMPORTING
*        obj_key        = lv_obj_key
*      TABLES
*        accountgl      = me->gt_acc_gl
*        currencyamount = me->gt_currency
*        return         = me->gt_return.
*
*    "Erro no lançamento
*    IF line_exists( me->gt_return[ type = gc_e ] ).      "#EC CI_STDSEQ
*      "Error ao tentar criar lançamento: &1 &2 &3 &4
*      ##MG_MISSING
*      MESSAGE e001(zfi_contab_depre) WITH gs_header-comp_code gs_header-doc_type INTO gv_dummy.
*      append_msg( ).
*
*      APPEND LINES OF me->gt_return TO me->gt_msg_ex.
*
*    ELSE.
*
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          wait = abap_true.
*
*      " Documento criado com sucesso: &1 &2 &3
*      MESSAGE s002(zfi_contab_depre) WITH lv_obj_key(10) lv_obj_key+10(4) lv_obj_key+14(4) INTO gv_dummy.
*      append_msg( ).
*
*      IF iv_reav = abap_true.
*        save_log_sucess_reav(
*          EXPORTING
*              it_linhas = it_linhas
*              iv_belnr = lv_obj_key(10)  ).
*      ELSE.
*        save_log_sucess(
*          EXPORTING
*              it_linhas = it_linhas
*              iv_belnr = lv_obj_key(10)  ).
*      ENDIF.
*
*    ENDIF.

  ENDMETHOD.


  METHOD save_log_sucess.

    DATA lt_log TYPE TABLE OF ztfi_contab_log.

    SELECT *
    FROM ztfi_contab_log
    INTO TABLE @DATA(lt_log_table)
    FOR ALL ENTRIES IN @it_linhas
    WHERE bukrs = @it_linhas-bukrs AND
          anln1 = @it_linhas-anln1 AND
          anln2 = @it_linhas-anln2 AND
          anlkl = @it_linhas-anlkl AND
          gsber = @it_linhas-gsber AND
          kostl = @it_linhas-kostl AND
          gjahr = @it_linhas-gjahr AND
          peraf = @it_linhas-peraf."#EC CI_FAE_LINES_ENSURED


    LOOP AT it_linhas ASSIGNING FIELD-SYMBOL(<fs_linha>).

      APPEND INITIAL LINE TO lt_log ASSIGNING FIELD-SYMBOL(<fs_log>).

      READ TABLE lt_log_table ASSIGNING FIELD-SYMBOL(<fs_log_table>) WITH KEY bukrs = <fs_linha>-bukrs
                                                                  anln1 = <fs_linha>-anln1
                                                                  anln2 = <fs_linha>-anln2
                                                                  anlkl = <fs_linha>-anlkl
                                                                  gsber = <fs_linha>-gsber
                                                                  kostl = <fs_linha>-kostl
                                                                  gjahr = <fs_linha>-gjahr
                                                                  peraf = <fs_linha>-peraf."#EC CI_STDSEQ
      IF sy-subrc = 0.
        MOVE-CORRESPONDING <fs_log_table> TO <fs_log>.
      ENDIF.

      <fs_log>-bukrs = <fs_linha>-bukrs.
      <fs_log>-belnr = iv_belnr.
      <fs_log>-anln1 = <fs_linha>-anln1.
      <fs_log>-anln2 = <fs_linha>-anln2.
      <fs_log>-anlkl = <fs_linha>-anlkl.
      <fs_log>-gsber = <fs_linha>-gsber.
      <fs_log>-kostl = <fs_linha>-kostl.
      <fs_log>-gjahr = <fs_linha>-gjahr.
      <fs_log>-peraf = <fs_linha>-peraf.
      <fs_log>-contab = abap_true.
      <fs_log>-cpudt = sy-datum.
      <fs_log>-cputm = sy-uzeit.
    ENDLOOP..

    MODIFY ztfi_contab_log FROM TABLE lt_log.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD save_log_sucess_reav.

    DATA lt_log TYPE TABLE OF ztfi_contab_log.

    SELECT mandt,
           bukrs,
           anln1,
           anln2,
           anlkl,
           gsber,
           kostl,
           gjahr,
           peraf,
           belnr,
           belnr_reav,
           contab,
           reav,
           cpudt,
           cputm,
           cpudt_reav,
           cputm_reav
      FROM ztfi_contab_log
      INTO TABLE @DATA(lt_log_table)
       FOR ALL ENTRIES IN @it_linhas
     WHERE bukrs = @it_linhas-bukrs
       AND anln1 = @it_linhas-anln1
       AND anln2 = @it_linhas-anln2
       AND anlkl = @it_linhas-anlkl
       AND gsber = @it_linhas-gsber
       AND kostl = @it_linhas-kostl
       AND gjahr = @it_linhas-gjahr
       AND peraf = @it_linhas-peraf.          "#EC CI_FAE_LINES_ENSURED

    LOOP AT it_linhas ASSIGNING FIELD-SYMBOL(<fs_linha>).

      APPEND INITIAL LINE TO lt_log ASSIGNING FIELD-SYMBOL(<fs_log>).

      READ TABLE lt_log_table ASSIGNING FIELD-SYMBOL(<fs_log_table>) WITH KEY bukrs = <fs_linha>-bukrs
                                                                  anln1 = <fs_linha>-anln1
                                                                  anln2 = <fs_linha>-anln2
                                                                  anlkl = <fs_linha>-anlkl
                                                                  gsber = <fs_linha>-gsber
                                                                  kostl = <fs_linha>-kostl
                                                                  gjahr = <fs_linha>-gjahr
                                                                  peraf = <fs_linha>-peraf. "#EC CI_STDSEQ
      IF sy-subrc = 0.
        MOVE-CORRESPONDING <fs_log_table> TO <fs_log>.
      ENDIF.

      <fs_log>-bukrs = <fs_linha>-bukrs.
      <fs_log>-belnr_reav = iv_belnr.
      <fs_log>-anln1 = <fs_linha>-anln1.
      <fs_log>-anln2 = <fs_linha>-anln2.
      <fs_log>-anlkl = <fs_linha>-anlkl.
      <fs_log>-gsber = <fs_linha>-gsber.
      <fs_log>-kostl = <fs_linha>-kostl.
      <fs_log>-gjahr = <fs_linha>-gjahr.
      <fs_log>-peraf = <fs_linha>-peraf.
      <fs_log>-reav = abap_true.
      <fs_log>-cpudt_reav = sy-datum.
      <fs_log>-cputm_reav = sy-uzeit.

    ENDLOOP..

    MODIFY ztfi_contab_log FROM TABLE lt_log.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.


  ENDMETHOD.


  METHOD fill_item_80.

    DATA: ls_item_sum TYPE zsfi_contab_depre_item_lanc.
    DATA: lv_conta80_01 TYPE hkont,
          lv_conta80_02 TYPE hkont.

    CHECK is_linha-ajust80_01 <> 0.
    "@@ 3.1.3.3.    Conta Deprec Acm Societária_80
    IF is_linha-ajust80_01 > 0.
      lv_conta80_01 = is_linha-deprec_societ80.
      lv_conta80_02 = is_linha-despesa_societ80.
    ELSE.
      lv_conta80_01 = is_linha-despesa_societ80.
      lv_conta80_02 = is_linha-deprec_societ80.
    ENDIF.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-ajust80_01 ).
    ls_item_sum-conta = lv_conta80_01.
    COLLECT ls_item_sum INTO gt_items_sum.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-ajust80_01 ) * -1.
    ls_item_sum-conta = lv_conta80_02.
    COLLECT ls_item_sum INTO gt_items_sum.

  ENDMETHOD.


  METHOD fill_item_82.

    DATA: ls_item_sum TYPE zsfi_contab_depre_item_lanc.
    DATA: lv_conta82_01 TYPE hkont,
          lv_conta82_02 TYPE hkont.

    CHECK is_linha-ajust82_10 <> 0.

    "@@ 3.1.3.3.    Conta Deprec Acm Societária_80
    IF is_linha-ajust82_10 > 0.
      lv_conta82_01 = is_linha-deprec_societ82.
      lv_conta82_02 = is_linha-despesa_societ82.
    ELSE.
      lv_conta82_01 = is_linha-despesa_societ82.
      lv_conta82_02 = is_linha-deprec_societ82.
    ENDIF.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-ajust82_10 ).
    ls_item_sum-conta = lv_conta82_01.
    COLLECT ls_item_sum INTO gt_items_sum.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-ajust82_10 ) * -1.
    ls_item_sum-conta = lv_conta82_02.
    COLLECT ls_item_sum INTO gt_items_sum.

  ENDMETHOD.


  METHOD fill_item_84.

    DATA: ls_item_sum TYPE zsfi_contab_depre_item_lanc.

    DATA: lv_conta84_01 TYPE hkont,
          lv_conta84_02 TYPE hkont.

    check is_linha-ajust84_11 <> 0.

    "@@ 3.1.3.3.    Conta Deprec Acm Societária_80
    IF is_linha-ajust84_11 > 0.
      lv_conta84_01 = is_linha-deprec_societ84.
      lv_conta84_02 = is_linha-despesa_societ84.
    ELSE.
      lv_conta84_01 = is_linha-despesa_societ84.
      lv_conta84_02 = is_linha-deprec_societ84.
    ENDIF.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-ajust84_11 ).
    ls_item_sum-conta = lv_conta84_01.
    COLLECT ls_item_sum INTO gt_items_sum.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-ajust84_11 ) * -1.
    ls_item_sum-conta = lv_conta84_02.
    COLLECT ls_item_sum INTO gt_items_sum.


  ENDMETHOD.


  METHOD fill_item_bapi.

    DATA: lv_texto   TYPE char50,
          lv_item_no TYPE bapiacgl09-itemno_acc.

    SELECT kokrs,
           kostl,
           prctr
      FROM csks
       FOR ALL ENTRIES IN @gt_items_sum
     WHERE kokrs = @gt_items_sum-bukrs
       AND kostl = @gt_items_sum-kostl
      INTO TABLE @DATA(lt_result).

    IF sy-subrc IS INITIAL.
      SORT lt_result BY kokrs
                        kostl.
    ENDIF.

    CLEAR lv_item_no.

    LOOP AT gt_items_sum ASSIGNING FIELD-SYMBOL(<fs_item>).

      lv_item_no = lv_item_no + 1.

      APPEND INITIAL LINE TO me->gt_acc_gl ASSIGNING FIELD-SYMBOL(<fs_gl>).
      <fs_gl>-itemno_acc = lv_item_no.
      <fs_gl>-comp_code  = <fs_item>-bukrs.
      <fs_gl>-gl_account = <fs_item>-conta.
      <fs_gl>-bus_area   = <fs_item>-gsber.
      <fs_gl>-costcenter = <fs_item>-kostl.

      READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<fs_result>)
                                         WITH KEY kokrs = <fs_item>-bukrs
                                                  kostl = <fs_item>-kostl
                                                  BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        <fs_gl>-profit_ctr = <fs_result>-prctr.
      ENDIF.

      IF iv_reav = abap_true.
        CONCATENATE 'VR REF DEPR REAV' gv_data_lanc+4(2) '/' gv_data_lanc(4) INTO <fs_gl>-item_text SEPARATED BY space.
      ELSE.
        CONCATENATE 'VR REF DEPR SOC ' gv_data_lanc+4(2) '/' gv_data_lanc(4) INTO <fs_gl>-item_text SEPARATED BY space.
      ENDIF.

      APPEND INITIAL LINE TO me->gt_currency ASSIGNING FIELD-SYMBOL(<fs_curr>).
      <fs_curr>-itemno_acc   = lv_item_no.
      <fs_curr>-currency_iso = gc_currency.
      <fs_curr>-amt_doccur   = <fs_item>-valor.

    ENDLOOP.

  ENDMETHOD.


  METHOD fill_bapi_reav.

    fill_header_reav( it_linhas ).

    fill_items_reav( it_linhas ).

  ENDMETHOD.


  METHOD fill_header_reav.

    DATA: lv_last_day  TYPE datum,
          lv_day_peraf TYPE datum.

    CLEAR: gs_header, gv_data_lanc.

    READ TABLE it_linhas ASSIGNING FIELD-SYMBOL(<fs_linha>) INDEX 1.
    IF sy-subrc = 0.

      lv_day_peraf = <fs_linha>-gjahr && <fs_linha>-peraf+1(2) && '01'.

      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = lv_day_peraf
        IMPORTING
          last_day_of_month = lv_last_day
        EXCEPTIONS
          day_in_no_date    = 1
          OTHERS            = 2.
      IF sy-subrc <> 0.
        lv_last_day = sy-datum.
      ENDIF.

      gv_data_lanc = lv_last_day.

      me->gs_header-pstng_date  = lv_last_day.
      me->gs_header-doc_date    = lv_last_day.
*      me->gs_header-fisc_year   = sy-datum(4).
*      me->gs_header-fis_period  = sy-datum+4(2).
      me->gs_header-comp_code   = <fs_linha>-bukrs.
      me->gs_header-ref_doc_no   = lv_last_day+4(2) && '/' && lv_last_day(4).
      me->gs_header-header_txt   = 'VR REF DEPR REAV ' && lv_last_day+4(2) && '/' && lv_last_day(4).
      me->gs_header-doc_type    = me->gc_doc_type.
      me->gs_header-username    = sy-uname.
    ENDIF.


  ENDMETHOD.


  METHOD fill_items_reav.

    LOOP AT it_linhas ASSIGNING FIELD-SYMBOL(<fs_linha>).

      IF <fs_linha>-nafag10 IS INITIAL AND
         <fs_linha>-nafag11 IS INITIAL.

        "Valores de ajustes zerados. &1 &2
        MESSAGE w004(zfi_contab_depre) WITH <fs_linha>-anlkl <fs_linha>-anln1 <fs_linha>-anln2 INTO gv_dummy.
        append_msg( ).

        CONTINUE.

      ENDIF.

*      fill_item_01_reav( <fs_linha> ).
      fill_item_10_reav( <fs_linha> ).
      fill_item_11_reav( <fs_linha> ).

    ENDLOOP.

    fill_item_bapi( iv_reav = abap_true  ).

  ENDMETHOD.


  METHOD fill_item_01_reav.

    DATA: ls_item_sum TYPE zsfi_contab_depre_item_lanc.
    DATA: lv_conta01_01 TYPE hkont,
          lv_conta01_02 TYPE hkont.

    check is_linha-nafag01  <> 0.

    "@@ 3.1.3.3.    Conta Deprec Acm Societária_80
    IF is_linha-nafag01 > 0.
      lv_conta01_01 = is_linha-deprec_fiscal01.
      lv_conta01_02 = is_linha-despesa_fiscal01.
    ELSE.
      lv_conta01_01 = is_linha-despesa_fiscal01.
      lv_conta01_02 = is_linha-deprec_fiscal01.
    ENDIF.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-ajust80_01 ).
    ls_item_sum-conta = lv_conta01_01.
    COLLECT ls_item_sum INTO gt_items_sum.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-ajust80_01 ) * -1.
    ls_item_sum-conta = lv_conta01_02.
    COLLECT ls_item_sum INTO gt_items_sum.


  ENDMETHOD.


  METHOD fill_item_10_reav.


    DATA: ls_item_sum TYPE zsfi_contab_depre_item_lanc.
    DATA: lv_conta10_01 TYPE hkont,
          lv_conta10_02 TYPE hkont.

    check is_linha-nafag10 <> 0.

    "@@ 3.1.3.3.    Conta Deprec Acm Societária_80
    IF is_linha-nafag10 > 0.
      lv_conta10_01 = is_linha-deprec_fiscal10.
      lv_conta10_02 = is_linha-despesa_fiscal10.
    ELSE.
      lv_conta10_01 = is_linha-despesa_fiscal10.
      lv_conta10_02 = is_linha-deprec_fiscal10.
    ENDIF.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-nafag10 ).
    ls_item_sum-conta = lv_conta10_01.
    COLLECT ls_item_sum INTO gt_items_sum.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-nafag10 ) * -1.
    ls_item_sum-conta = lv_conta10_02.
    COLLECT ls_item_sum INTO gt_items_sum.

  ENDMETHOD.


  METHOD fill_item_11_reav.

    DATA: ls_item_sum TYPE zsfi_contab_depre_item_lanc.

    DATA: lv_conta11_01 TYPE hkont,
          lv_conta11_02 TYPE hkont.

    check is_linha-nafag11 <> 0.

    "@@ 3.1.3.3.    Conta Deprec Acm Societária_80
    IF is_linha-nafag11 > 0.
      lv_conta11_01 = is_linha-deprec_fiscal11.
      lv_conta11_02 = is_linha-despesa_fiscal11.
    ELSE.
      lv_conta11_01 = is_linha-despesa_fiscal11.
      lv_conta11_02 = is_linha-deprec_fiscal11.
    ENDIF.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-nafag11 ).
    ls_item_sum-conta = lv_conta11_01.
    COLLECT ls_item_sum INTO gt_items_sum.

    ls_item_sum-bukrs = is_linha-bukrs.
    ls_item_sum-gsber = is_linha-gsber.
    ls_item_sum-kostl = is_linha-kostl.
    ls_item_sum-gjahr = sy-datum(4).
    ls_item_sum-valor = abs( is_linha-nafag11 ) * -1.
    ls_item_sum-conta = lv_conta11_02.
    COLLECT ls_item_sum INTO gt_items_sum.


  ENDMETHOD.
ENDCLASS.
