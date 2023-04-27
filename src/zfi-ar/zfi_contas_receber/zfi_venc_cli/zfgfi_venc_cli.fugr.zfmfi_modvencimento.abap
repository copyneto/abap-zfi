FUNCTION zfmfi_modvencimento.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_BSEG) TYPE  BSEG
*"     VALUE(IS_PARAM) TYPE  ZI_FI_VENC_F01_POPUP
*"  TABLES
*"      CT_RETURN TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA lv_doc_est TYPE belnr_d.
  DATA lv_item_est TYPE buzei.
  DATA lv_ano_est TYPE mjahr.

  DATA: lv_error TYPE boolean.
  DATA: lt_return TYPE bapiret2_tab.

  DATA lt_change TYPE fdm_t_accchg.

  DATA ls_obs TYPE ztfi_obsvenc.

  FIELD-SYMBOLS: <fs_ret> LIKE LINE OF ct_return.

  IF is_bseg-h_bldat > is_param-novadatavenc.

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_VENCCLI'.
    <fs_ret>-type       = 'E'.
    <fs_ret>-number     = '003'.
    <fs_ret>-message_v1 = is_bseg-belnr.
    <fs_ret>-message_v2 = is_bseg-bukrs.
    <fs_ret>-message_v3 = is_bseg-gjahr.

    EXIT.

  ENDIF.

  APPEND INITIAL LINE TO lt_change ASSIGNING FIELD-SYMBOL(<fs_chg>).
  <fs_chg>-fdname = 'ZFBDT'.
  <fs_chg>-newval = is_param-novadatavenc.

  APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
  <fs_chg>-fdname = 'MANSP'.
  <fs_chg>-newval = is_param-motivoprorrog.

  APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
  <fs_chg>-fdname = 'ZBD1T'.
  <fs_chg>-newval = space.

  APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
  <fs_chg>-fdname = 'ZBD2T'.
  <fs_chg>-newval = space.

  APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
  <fs_chg>-fdname = 'ZBD3T'.
  <fs_chg>-newval = space.

  IF is_bseg-anfbn IS NOT INITIAL.

    APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
    <fs_chg>-fdname = 'DTWS1'.
    <fs_chg>-newval = '06'.

  ENDIF.


  CALL FUNCTION 'FI_DOCUMENT_CHANGE'
    EXPORTING
      i_buzei              = is_bseg-buzei
      i_bukrs              = is_bseg-bukrs
      i_belnr              = is_bseg-belnr
      i_gjahr              = is_bseg-gjahr
    TABLES
      t_accchg             = lt_change
    EXCEPTIONS
      no_reference         = 1
      no_document          = 2
      many_documents       = 3
      wrong_input          = 4
      overwrite_creditcard = 5
      OTHERS               = 6.

  IF sy-subrc = 0.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.

    ls_obs-buzei    = is_bseg-buzei.
    ls_obs-bukrs    = is_bseg-bukrs.
    ls_obs-belnr    = is_bseg-belnr.
    ls_obs-gjahr    = is_bseg-gjahr.
    ls_obs-obs      = is_param-observ.
    ls_obs-usermod  = sy-uname.
    ls_obs-datamod  = sy-datum.

    MODIFY ztfi_obsvenc FROM ls_obs.

    IF ct_return IS INITIAL.

      APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
      <fs_ret>-id         = 'ZFI_VENCCLI'.
      <fs_ret>-type       = 'I'.
      <fs_ret>-number     = '002'.

    ENDIF.


    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_VENCCLI'.
    <fs_ret>-type       = 'S'.
    <fs_ret>-number     = '001'.
    <fs_ret>-message_v1 = is_bseg-belnr.
    <fs_ret>-message_v2 = is_bseg-bukrs.
    <fs_ret>-message_v3 = is_bseg-gjahr.



    IF is_bseg-anfbn IS NOT INITIAL.

      CALL FUNCTION 'ZFMFI_BATCH_COMPENSAR'
        EXPORTING
          iv_kunnr    = is_bseg-kunnr
          iv_waers    = 'BRL'
          iv_budat    = is_param-novadatavenc
          iv_bukrs    = is_bseg-bukrs
          iv_anfbn    = is_bseg-anfbn
        IMPORTING
          ev_erro     = lv_error
          ev_doc_est  = lv_doc_est
          ev_item_est = lv_item_est
          ev_ano_est  = lv_ano_est
        CHANGING
          ct_msg      = lt_return.

      APPEND LINES OF lt_return TO ct_return.

    ENDIF.

  ELSE.

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = sy-msgid.
    <fs_ret>-type       = sy-msgty.
    <fs_ret>-number     = sy-msgno.
    <fs_ret>-message_v1 = sy-msgv1.
    <fs_ret>-message_v2 = sy-msgv2.
    <fs_ret>-message_v3 = sy-msgv3.
    <fs_ret>-message_v4 = sy-msgv4.

  ENDIF.

ENDFUNCTION.
