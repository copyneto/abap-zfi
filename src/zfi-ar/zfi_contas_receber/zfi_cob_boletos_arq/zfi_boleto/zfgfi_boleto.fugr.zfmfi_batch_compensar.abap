FUNCTION zfmfi_batch_compensar.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_KUNNR) TYPE  KUNNR
*"     VALUE(IV_WAERS) TYPE  WAERS
*"     VALUE(IV_BUDAT) TYPE  BUDAT
*"     VALUE(IV_BUKRS) TYPE  BUKRS
*"     VALUE(IV_ANFBN) TYPE  ANFBN OPTIONAL
*"     VALUE(IV_CTU) LIKE  APQI-PUTACTIVE DEFAULT 'X'
*"     VALUE(IV_MODE) LIKE  APQI-PUTACTIVE DEFAULT 'N'
*"     VALUE(IV_UPDATE) LIKE  APQI-PUTACTIVE DEFAULT 'L'
*"     VALUE(IV_GROUP) LIKE  APQI-GROUPID OPTIONAL
*"     VALUE(IV_USER) LIKE  APQI-USERID OPTIONAL
*"     VALUE(IV_KEEP) LIKE  APQI-QERASE OPTIONAL
*"     VALUE(IV_HOLDDATE) LIKE  APQI-STARTDATE OPTIONAL
*"     VALUE(IV_NODATA) LIKE  APQI-PUTACTIVE DEFAULT ''
*"  EXPORTING
*"     VALUE(EV_ERRO) TYPE  CHAR1
*"     VALUE(EV_DOC_EST) TYPE  BELNR_D
*"     VALUE(EV_ITEM_EST) TYPE  BUZEI
*"     VALUE(EV_ANO_EST) TYPE  MJAHR
*"  CHANGING
*"     VALUE(CT_MSG) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  DATA: lv_dummy   TYPE char30,
        lv_mode    LIKE  apqi-putactive,
        lt_messtab TYPE TABLE OF bdcmsgcoll.


  PERFORM bdc_nodata      USING iv_nodata.

  PERFORM open_group      USING iv_group iv_user iv_keep iv_holddate iv_ctu.

  lv_mode = 'N'.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0131'.

  PERFORM bdc_field       USING: 'BDC_CURSOR'     'RF05A-XPOS1(03)',
                                 'bdc_okcode'     '=PA',
                                 'RF05A-AGKON'    iv_kunnr.
  WRITE iv_budat TO lv_dummy.

  PERFORM bdc_field       USING: 'BKPF-BUDAT'     lv_dummy,
                                 'BKPF-MONAT'     iv_budat+4(2),
                                 'BKPF-BUKRS'     iv_bukrs,
                                 'BKPF-WAERS'     iv_waers,
                                 'RF05A-AGUMS'    'R',
                                 'RF05A-XNOPS'    'X',
                                 'RF05A-XPOS1(01)' ''  ,
                                 'RF05A-XPOS1(03)' 'X'.

  PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.

  PERFORM bdc_field USING:
                                 'BDC_CURSOR'       'RF05A-SEL01(01)',
                                 'BDC_OKCODE'       '=BU',
                                 'RF05A-SEL01(01)'  iv_anfbn.


  PERFORM bdc_transaction TABLES  lt_messtab
                            USING  'FB1D'
                                   iv_ctu
                                   lv_mode
                                   iv_update.


  IF line_exists( lt_messtab[  msgtyp = 'E' ] ).         "#EC CI_STDSEQ
    ev_erro = abap_true.
    LOOP AT lt_messtab ASSIGNING FIELD-SYMBOL(<fs_messtab>).
      IF <fs_messtab>-msgtyp = 'E'.
        APPEND VALUE #(
          type   = <fs_messtab>-msgtyp
          id     = <fs_messtab>-msgid
          number = <fs_messtab>-msgnr
          field  = <fs_messtab>-fldname
        ) TO ct_msg.
      ENDIF.
    ENDLOOP.
  ENDIF.

  PERFORM close_group USING iv_ctu.

ENDFUNCTION.

INCLUDE bdcrecxy .
