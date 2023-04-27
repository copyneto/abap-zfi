CLASS zclfi_process_fbl5h DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS process_sol
      IMPORTING
        it_itens          TYPE zctgfi_itens_correcao
      RETURNING
        VALUE(rv_retorno) TYPE abap_bool.



  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_bseg,
        bukrs TYPE bseg-bukrs,
        belnr TYPE bseg-belnr,
        gjahr TYPE bseg-gjahr,
        buzei TYPE bseg-buzei,
        koart TYPE bseg-koart,
        bschl TYPE bseg-bschl,
        anfbn TYPE bseg-anfbn,
        bldat TYPE bseg-h_bldat,
        zfbdt TYPE bseg-zfbdt,
        zbd1t TYPE bseg-zbd1t,
        zbd2t TYPE bseg-zbd2t,
        zbd3t TYPE bseg-zbd3t,
      END OF ty_bseg.
    DATA gt_bseg TYPE SORTED TABLE OF ty_bseg WITH UNIQUE KEY primary_key COMPONENTS bukrs belnr gjahr buzei.
    DATA gt_bseg_select TYPE SORTED TABLE OF ty_bseg WITH UNIQUE KEY primary_key COMPONENTS bukrs belnr gjahr buzei.

    DATA gv_erro TYPE boolean.
    DATA gv_dummy TYPE string.
    DATA gt_msg TYPE bapiret2_tab.

    DATA gv_doc_est TYPE belnr_d.
    DATA gv_item_est TYPE buzei.
    DATA gv_ano_est TYPE mjahr.

    METHODS process_doc_fi
      IMPORTING
        is_item TYPE zsfi_itens_correcao.

    METHODS fill_fields
      CHANGING
        ct_fields TYPE tpit_t_fname.
    METHODS fill_bseg_bapi
      IMPORTING
        is_item          TYPE zsfi_itens_correcao
      RETURNING
        VALUE(rs_result) TYPE bseg.

    METHODS process_batch
      IMPORTING
        is_item TYPE zsfi_itens_correcao.
    METHODS msg.
    METHODS insert_log
      IMPORTING
        is_item TYPE zsfi_itens_correcao.
    METHODS init_process.
    METHODS save_msg.

    METHODS:
      selecionar_tipo_conta
        IMPORTING
          it_itens TYPE zctgfi_itens_correcao,

      busca_dias_atraso
        IMPORTING
          is_item           TYPE zsfi_itens_correcao
        RETURNING
          VALUE(rv_retorno) TYPE verzn.



ENDCLASS.



CLASS zclfi_process_fbl5h IMPLEMENTATION.


  METHOD process_sol.

    selecionar_tipo_conta( it_itens ).

    LOOP AT it_itens ASSIGNING FIELD-SYMBOL(<fs_item>).

      init_process(  ).

      process_doc_fi( <fs_item> ).

      process_batch( <fs_item> ).

      insert_log( <fs_item> ).

      save_msg( ).

    ENDLOOP.

    SORT gt_msg BY type.
    READ TABLE gt_msg TRANSPORTING NO FIELDS WITH KEY type = 'E' BINARY SEARCH.
    IF sy-subrc <> 0.
      rv_retorno = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD fill_fields.

    FIELD-SYMBOLS <fs_field> LIKE LINE OF ct_fields.

    CLEAR ct_fields.

    APPEND INITIAL LINE TO ct_fields ASSIGNING <fs_field>.
    <fs_field>-fname = 'ZFBDT'.
    <fs_field>-aenkz = abap_true.

    APPEND INITIAL LINE TO ct_fields ASSIGNING <fs_field>.
    <fs_field>-fname = 'ZBD1T'.
    <fs_field>-aenkz = abap_true.

    APPEND INITIAL LINE TO ct_fields ASSIGNING <fs_field>.
    <fs_field>-fname = 'ZBD2T'.
    <fs_field>-aenkz = abap_true.

    APPEND INITIAL LINE TO ct_fields ASSIGNING <fs_field>.
    <fs_field>-fname = 'DTWS1'.
    <fs_field>-aenkz = abap_true.

    APPEND INITIAL LINE TO ct_fields ASSIGNING <fs_field>.
    <fs_field>-fname = 'MANSP'.
    <fs_field>-aenkz = abap_true.
  ENDMETHOD.


  METHOD fill_bseg_bapi.

    rs_result  = VALUE bseg(
        bukrs = is_item-bukrs
        belnr = is_item-belnr
        gjahr = is_item-gjahr
        buzei = is_item-buzei
        bschl = VALUE #( gt_bseg_select[
          bukrs = is_item-bukrs
          belnr = is_item-belnr
          gjahr = is_item-gjahr
          buzei = is_item-buzei
        ]-bschl OPTIONAL )
        koart = VALUE #( gt_bseg_select[
          bukrs = is_item-bukrs
          belnr = is_item-belnr
          gjahr = is_item-gjahr
          buzei = is_item-buzei
        ]-koart OPTIONAL )
        anfbn =  VALUE #( gt_bseg_select[
          bukrs = is_item-bukrs
          belnr = is_item-belnr
          gjahr = is_item-gjahr
          buzei = is_item-buzei
        ]-anfbn OPTIONAL )
        zfbdt = is_item-novovencimento
        zbd1t = space
        zbd2t = space
        dtws1 = '06' "(Alteração de Vencimento)
        mansp = 'K' "(Prorrogação Manual)
            ).

  ENDMETHOD.


  METHOD process_doc_fi.

    DATA(ls_bseg) = fill_bseg_bapi( is_item ).

    DATA lt_acchg TYPE TABLE OF accchg.

    lt_acchg = VALUE #(
    ( fdname = 'ZFBDT'
      newval = is_item-novovencimento )
    ( fdname = 'ZBD1T'
      newval = '' )
    ( fdname = 'ZBD2T'
      newval = '' )
    ( fdname = 'MANSP'
      newval = 'K' )
    ).

    IF ls_bseg-anfbn IS NOT INITIAL.

      APPEND INITIAL LINE TO lt_acchg ASSIGNING FIELD-SYMBOL(<fs_chg>).
      <fs_chg>-fdname = 'DTWS1'.
      <fs_chg>-newval = '06'.

    ENDIF.

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_buzei              = ls_bseg-buzei
        i_bukrs              = ls_bseg-bukrs
        i_belnr              = ls_bseg-belnr
        i_gjahr              = ls_bseg-gjahr
      TABLES
        t_accchg             = lt_acchg
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.

    IF sy-subrc <> 0.

      gv_erro = abap_true.

      "Erro ao tentar modificar documento: &1 &2 &3
      MESSAGE e004(zfi_cont_rcb) WITH is_item-belnr is_item-gjahr is_item-bukrs INTO gv_dummy.
      msg( ).

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
      "Documento modificado com sucesso: &1 &2 &3
      MESSAGE s005(zfi_cont_rcb) WITH is_item-belnr is_item-gjahr is_item-bukrs INTO gv_dummy.
      msg( ).
    ENDIF.


  ENDMETHOD.


  METHOD process_batch.

    DATA: lv_error TYPE boolean.
    DATA: lt_return TYPE bapiret2_tab.

    CHECK gv_erro = abap_false.

    DATA(lv_anfbn) = VALUE #( gt_bseg_select[
          bukrs = is_item-bukrs
          belnr = is_item-belnr
          gjahr = is_item-gjahr
          buzei = is_item-buzei
        ]-anfbn OPTIONAL ).

    CHECK lv_anfbn IS NOT INITIAL.

    CALL FUNCTION 'ZFMFI_BATCH_COMPENSAR'
      EXPORTING
        iv_kunnr    = is_item-kunnr
        iv_waers    = 'BRL'
        iv_budat    = is_item-novovencimento
        iv_bukrs    = is_item-bukrs
        iv_anfbn    = lv_anfbn
      IMPORTING
        ev_erro     = lv_error
        ev_doc_est  = gv_doc_est
        ev_item_est = gv_item_est
        ev_ano_est  = gv_ano_est
      CHANGING
        ct_msg      = lt_return.

    APPEND LINES OF lt_return TO gt_msg.
    IF lv_error = abap_true.
      gv_erro = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD msg.

    APPEND INITIAL LINE TO gt_msg ASSIGNING FIELD-SYMBOL(<fs_msg>).

    <fs_msg> = VALUE #(
      type       = sy-msgty
      id         = sy-msgid
      number     = sy-msgno
      message_v1 = sy-msgv1
      message_v2 = sy-msgv2
      message_v3 = sy-msgv3
      message_v4 = sy-msgv4
    ).
  ENDMETHOD.


  METHOD insert_log.

    CHECK gv_erro = abap_false.

    DATA ls_obs TYPE ztfi_obsvenc.

    DATA lv_timestampl TYPE timestampl.
    GET TIME STAMP FIELD lv_timestampl.

    DATA(ls_log) = VALUE ztfi_solcorrecao(
        bukrs = is_item-bukrs
        kunnr = is_item-kunnr
        belnr = is_item-belnr
        buzei = is_item-buzei
        gjhar = is_item-gjahr
        datac = sy-datum
        horac = sy-uzeit
        wrbtr = is_item-wrbtr
        netdt = COND #( WHEN is_item-novovencimento IS INITIAL THEN is_item-netdt ELSE is_item-novovencimento )
        verzn = busca_dias_atraso( is_item )
        motivo = is_item-motivo_pro
        tipo = 'PRORROGAÇÃO'
        belnrestorno = gv_doc_est
        buzeiestorno = gv_item_est
        gjharestorno = gv_ano_est
        created_by   = sy-uname
        created_at   = lv_timestampl
        local_last_changed_at = lv_timestampl
    ).

    ls_obs-buzei    = is_item-buzei.
    ls_obs-bukrs    = is_item-bukrs.
    ls_obs-belnr    = is_item-belnr.
    ls_obs-gjahr    = is_item-gjahr.
    ls_obs-usermod  = sy-uname.
    ls_obs-datamod  = sy-datum.

    MODIFY ztfi_obsvenc FROM ls_obs.

    MODIFY ztfi_solcorrecao FROM ls_log.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD init_process.

    CLEAR: gv_erro,
           gt_msg,
           gv_doc_est,
           gv_item_est,
           gv_ano_est,
           gv_dummy.


  ENDMETHOD.


  METHOD save_msg.

    DATA(lo_msg) = NEW zclfi_save_msg(  ).

    lo_msg->save_ballog(
      EXPORTING
        iv_subobject = 'FBL5H'
        it_msg       = gt_msg
    ).

  ENDMETHOD.


  METHOD selecionar_tipo_conta.
    CHECK it_itens IS NOT INITIAL.

    DATA(lt_itens) = it_itens.
    SORT lt_itens BY bukrs belnr gjahr buzei.
    DELETE ADJACENT DUPLICATES FROM lt_itens COMPARING bukrs belnr gjahr buzei.
    gt_bseg = CORRESPONDING #( lt_itens ).

    SELECT table_bseg~bukrs, table_bseg~belnr, table_bseg~gjahr, table_bseg~buzei, table_bseg~koart, table_bseg~bschl,
          table_bseg~anfbn, table_bseg~h_bldat, table_bseg~zfbdt, table_bseg~zbd1t, table_bseg~zbd2t, table_bseg~zbd3t
    FROM @gt_bseg AS local_bseg
    INNER JOIN bseg AS table_bseg
    ON  table_bseg~bukrs = local_bseg~bukrs AND
        table_bseg~belnr = local_bseg~belnr AND
        table_bseg~gjahr = local_bseg~gjahr AND
        table_bseg~buzei = local_bseg~buzei
    INTO TABLE @gt_bseg_select.
  ENDMETHOD.


  METHOD busca_dias_atraso.
    DATA(ls_item) = VALUE rfposxext( BASE CORRESPONDING #( is_item
      MAPPING
        konto = kunnr
*        dmshb = dmbtr
        wrshb = wrbtr
      )
      koart = 'D' ).

    DATA(ls_bseg_select) = VALUE #( gt_bseg_select[
      bukrs = is_item-bukrs
      belnr = is_item-belnr
      gjahr = is_item-gjahr
      buzei = is_item-buzei
    ] OPTIONAL ).

    ls_item-bldat = ls_bseg_select-bldat.
    ls_item-zfbdt = ls_bseg_select-zfbdt.
    ls_item-zbd1t = ls_bseg_select-zbd1t.
    ls_item-zbd2t = ls_bseg_select-zbd2t.
    ls_item-zbd3t = ls_bseg_select-zbd3t.

    DATA(ls_t001) = VALUE t001( bukrs = is_item-bukrs ).

    CALL FUNCTION 'ITEM_DERIVE_FIELDS'
      EXPORTING
        s_t001    = ls_t001
        key_date  = sy-datum
        xopvw     = abap_true
      CHANGING
        s_item    = ls_item
      EXCEPTIONS
        bad_input = 1
        OTHERS    = 2.
    IF sy-subrc NE 0.

      MESSAGE ID 'ZFI_CONT_RCB' TYPE 'E' NUMBER '006' INTO DATA(ls_msg)
       WITH is_item-belnr is_item-bukrs is_item-buzei.
      APPEND VALUE #(
        type       = sy-msgty
        id         = sy-msgid
        number     = sy-msgno
        message_v1 = sy-msgv1
        message_v2 = sy-msgv2
        message_v3 = sy-msgv3
        message_v4 = sy-msgv4
      ) TO gt_msg.
    ELSE.
      rv_retorno = COND #(
        WHEN ls_item-verz1 > 1
        THEN ls_item-verz1
        ELSE '00000000'
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
