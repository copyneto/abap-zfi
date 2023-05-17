"!<p><strong>Essa classe é utilizada para executar o job de concessão de crédito</strong>
"!<p><strong>Autor:</strong> Anderson Macedo - Meta</p>
"!<p><strong>Data:</strong> 27/11/2021</p>
class ZCLFI_PROG_CONC_CRED definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_refdata,
        belnr TYPE REF TO data,
        bukrs TYPE REF TO data,
        fat   TYPE REF TO data,
      END OF ty_refdata .
  types:
    ty_t_cds TYPE TABLE OF zi_fi_prog_conc_cred WITH DEFAULT KEY .

  data GS_REFDATA type TY_REFDATA .

  methods CONSTRUCTOR .
  methods GET_CNPJ_ROOT
    importing
      !IT_CDS type TY_T_CDS .
  methods MIN_DAYS_IS_VALID
    importing
      !IV_NETDT type BSEG-NETDT
      !IV_MINDAYS type ZTFI_CONC_CRED-MINDAYS
    returning
      value(RV_RETURN) type ABAP_BOOL .
  methods PROCESS .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_selopt,
        belnr TYPE RANGE OF belnr_d,
        bukrs TYPE RANGE OF bukrs,
        fat   TYPE RANGE OF belnr_d,
      END OF ty_selopt .
  types:
    BEGIN OF ty_credatr,
        bukrs TYPE bseg-bukrs,
        rebzg TYPE bseg-rebzg,
        rebzj TYPE bseg-rebzj,
        rebzz TYPE bseg-rebzz,
      END OF ty_credatr .
  types:
    BEGIN OF ty_retira_cli,
        kunnr TYPE kunnr,
      END OF ty_retira_cli .
  types:
    ty_t_retira_cli TYPE TABLE OF ty_retira_cli .
  types:
    ty_t_logtab TYPE TABLE OF ztfi_logconcred .
  types:
    ty_t_credatr TYPE TABLE OF ty_credatr .
  types:
    ty_t_root TYPE TABLE OF zi_ca_get_kunnr_by_cnpjroot .
  types:
    ty_t_billing TYPE TABLE OF zi_fi_get_billing_venc .
  types:
    ty_t_doccred TYPE TABLE OF zi_fi_get_doc_cred .
  types:
    ty_t_logtab_db TYPE TABLE OF zi_fi_logconcred_conv .

  data GS_SELOPT type TY_SELOPT .
  data GT_RETIRA_CLI type TY_T_RETIRA_CLI .
  data:
    gt_pdc TYPE TABLE OF zi_fi_prog_conc_cred .
  data:
    gt_devol TYPE TABLE OF zi_fi_prog_conc_cred .
  data GS_HEADER type BAPIACHE09 .
  data GT_CURR type ACID_BAPIACCR09_T .
  data GT_RETURN type TT_BAPIRET2 .
  data GT_REC type BAPIACAR09_TAB .
  data GT_PAY type BAPIACAP09_TAB .
  data GT_GL type BAPIACGL09_TAB .
  data GT_LOGTAB type TY_T_LOGTAB .
  data GT_LOGTAB_DB type TY_T_LOGTAB_DB .
  data GT_CREDATR type TY_T_CREDATR .
  data GT_ROOT type TY_T_ROOT .
  data GT_BILLING type TY_T_BILLING .
  data GT_ROOT_MAIN type TY_T_ROOT .
  data GT_DOCCRED type TY_T_DOCCRED .
  constants GC_CURRENCY type WAERS value 'BRL' ##NO_TEXT.
  constants GC_PDC type CHAR3 value 'PDC' ##NO_TEXT.
  constants GC_DEVOLUCAO type CHAR3 value 'DEV' ##NO_TEXT.
  data GO_LOG type ref to ZCLCA_SAVE_LOG .
  constants GC_TCODE type SY-TCODE value 'ZFICONCREDITO' ##NO_TEXT.
  constants GC_SUB type BALSUBOBJ value 'LOG_JOB' ##NO_TEXT.
  data GV_BAPI_OK type ABAP_BOOL .
  data GV_CONTA40 type HKONT .
  data GV_CONTA50 type HKONT .
  data GV_DOCDEV type CHAR2 .
  data GV_DOCPDC type CHAR2 .
  data GV_DOCFORN type CHAR2 .
  constants GC_RAZAO type CHAR1 value 'C' ##NO_TEXT.
  data GT_EXT2 type TT_BAPIPAREX .
  data GV_DOC_KEY type AWKEY .
  data GV_ZERO_ROWS type ABAP_BOOL .
  data GV_PROCESSED type ABAP_BOOL .

  methods CREDITO_ASSOCIADO_LOG
    importing
      !IS_CDS type ZI_FI_PROG_CONC_CRED
    returning
      value(RV_RETURN) type ABAP_BOOL .
  methods SUBTRAI_CREDITOS_ASSOCIADOS
    changing
      !CS_BILLING type ZI_FI_GET_BILLING_VENC .
  methods APPEND_MSGS .
  methods BAPI_CHECK .
    "! Rotina de efetivação da bapi
  methods BAPI_COMMIT .
    "! Rotina de execução da bapi
  methods BAPI_POST .
  methods CHECK_DEVOL_FORN
    importing
      !IV_PROC type CHAR3
      !IS_CRED type ZI_FI_PROG_CONC_CRED
    returning
      value(RV_VALUE) type ABAP_BOOL .
  methods CHECK_NO_DATA .
    "! Rotina de limpeza dos objetos
  methods CLEAR_OBJECTS .
  methods CONV_SELOPT .
    "! Rotina de devolução
  methods DEVOL .
  methods DOC_CHANGE
    importing
      !IS_FAT type ZI_FI_GET_BILLING_VENC .
    "! Rotina de preenchimento da bapi
    "! @parameter is_line      | linha de dados
  methods FILL_BAPI_DATA
    importing
      !IS_LINE type ZI_FI_PROG_CONC_CRED .
  methods FILL_BAPI_DEVOL
    importing
      !IS_CRED type ZI_FI_PROG_CONC_CRED
      !IS_FAT type ZI_FI_GET_BILLING_VENC .
  methods FILL_BAPI_DEVOL_FORN
    importing
      !IS_CRED type ZI_FI_PROG_CONC_CRED
      !IS_FAT type ZI_FI_GET_BILLING_VENC .
  methods FILL_BAPI_PDC
    importing
      !IS_CRED type ZI_FI_PROG_CONC_CRED
      !IS_FAT type ZI_FI_GET_BILLING_VENC .
  methods GET_BILLING_DOC .
    "! Rotina de busca dos dados
  methods GET_DEVOL_DATA .
  methods GET_DOC_CRED .
  methods GET_LOG_DOC_CRED
    importing
      !IT_CDS type TY_T_CDS .
    "! Rotina de busca dos dados
  methods GET_PDC_DATA .
  methods GET_RETIRA_CLI
    importing
      !IT_CDS type TY_T_CDS .
  methods GET_TABLE_PARAMETERS .
  methods LOGTAB_ERROR
    importing
      !IS_CRED type ZI_FI_PROG_CONC_CRED
      !IS_FAT type ZI_FI_GET_BILLING_VENC
      !IV_NOTRES type ABAP_BOOL optional
      !IV_NOTDIAS type ABAP_BOOL optional .
  methods LOGTAB_SUCCESS
    importing
      !IS_CRED type ZI_FI_PROG_CONC_CRED
      !IS_FAT type ZI_FI_GET_BILLING_VENC .
  methods MSG_DOC_CREATED
    importing
      !IV_OBJ type BAPIACHE09-OBJ_KEY .
  methods MSG_NO_BANK_DATA
    importing
      !IV_KUNNR type KUNNR .
  methods MSG_NO_DATA_FOUND .
    "! Rotina processo PDC
  methods PDC .
  methods PROCESSA_DEVOL_PADRAO
    importing
      !IS_CDS type ZI_FI_PROG_CONC_CRED
      !IS_BILLING type ZI_FI_GET_BILLING_VENC .
  methods PROCESSA_DEV_FORN
    importing
      !IS_CDS type ZI_FI_PROG_CONC_CRED
      !IS_BILLING type ZI_FI_GET_BILLING_VENC .
  methods PROCESSA_PDC
    importing
      !IS_CDS type ZI_FI_PROG_CONC_CRED
      !IS_BILLING type ZI_FI_GET_BILLING_VENC .
  methods PROCESS_CRED
    importing
      !IS_CDS type ZI_FI_PROG_CONC_CRED
      !IV_PROC type CHAR3 .
  methods RETIRA_CLIENTE
    importing
      !IV_CLI type KUNNR
    returning
      value(RV_RETURN) type ABAP_BOOL .
  methods RUN_FB1D
    importing
      !IS_FAT type ZI_FI_GET_BILLING_VENC .
  methods SAVE_LOGTAB .
  methods ADD_MSG
    importing
      !IV_TYPE type BAPI_MTYPE
      !IV_ID type SYMSGID default 'ZFI_CONCRED'
      !IV_NUMBER type SYMSGNO
      !IV_MESSAGE type BAPI_MSG optional
      !IV_MESSAGE_V1 type SYMSGV optional
      !IV_MESSAGE_V2 type SYMSGV optional
      !IV_MESSAGE_V3 type SYMSGV optional
      !IV_MESSAGE_V4 type SYMSGV optional .
  methods PROCESSA_DEVOLUCAO
    importing
      !IS_CDS type ZI_FI_PROG_CONC_CRED
      !IV_PROC type CHAR3
      !IS_BILLING type ZI_FI_GET_BILLING_VENC .
ENDCLASS.



CLASS ZCLFI_PROG_CONC_CRED IMPLEMENTATION.


  METHOD bapi_commit.

    IF gv_bapi_ok IS NOT INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

    ENDIF.

  ENDMETHOD.


  METHOD bapi_post.

    DATA: lt_return TYPE tt_bapiret2.

    CLEAR: gt_return, gv_doc_key.

    IF gv_bapi_ok IS NOT INITIAL.

      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader    = gs_header
        IMPORTING
          obj_key           = gv_doc_key
        TABLES
          accountgl         = gt_gl
          accountreceivable = gt_rec
          accountpayable    = gt_pay
          currencyamount    = gt_curr
          extension2        = gt_ext2
          return            = lt_return.

      IF gv_doc_key IS INITIAL.
        CLEAR gv_bapi_ok.
        APPEND LINES OF lt_return TO gt_return.

      ELSE.
        gv_bapi_ok = abap_true.
        gv_processed = abap_true.

        add_msg( iv_type        = 'S'
                 iv_number      = '003'
                 iv_message_v1  = CONV #( gv_doc_key(10) )
                 iv_message_v2  = CONV #( gv_doc_key+10(4) )
                 iv_message_v3  = CONV #( gv_doc_key+14(4) ) ).

        CLEAR lt_return.

      ENDIF.

      append_msgs( ).

    ENDIF.

  ENDMETHOD.


  METHOD clear_objects.

    CLEAR: gs_header,
           gt_curr  ,
           gt_return,
           gt_rec   ,
           gt_pay   ,
           gt_gl    ,
           gt_ext2  .

  ENDMETHOD.


  METHOD devol.

    get_devol_data( ).
    get_log_doc_cred( gt_devol ).

    get_cnpj_root( gt_devol ).
    get_retira_cli( gt_devol ).
    get_billing_doc( ).
    get_doc_cred( ).

    DELETE ADJACENT DUPLICATES FROM gt_billing COMPARING rootcnpj bukrs belnr gjahr buzei.

    LOOP AT gt_devol ASSIGNING FIELD-SYMBOL(<fs_devol>).

      IF NOT credito_associado_log( <fs_devol> ).

        process_cred( is_cds  = <fs_devol>
                      iv_proc = gc_devolucao ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD fill_bapi_data.

    gs_header-doc_date    = sy-datum.
    gs_header-pstng_date  = sy-datum.
    gs_header-doc_type    = 'DE'.
    gs_header-comp_code   = is_line-bukrs.
    gs_header-fis_period  = is_line-budat+5(1).
    gs_header-ref_doc_no  = is_line-belnr.
    gs_header-header_txt  = is_line-belnr.

    APPEND INITIAL LINE TO gt_rec ASSIGNING FIELD-SYMBOL(<fs_rec>).

    <fs_rec>-pymt_amt       = is_line-dmbtr.
    <fs_rec>-bus_area       = is_line-gsber.
    <fs_rec>-customer       = is_line-kunnr.
    <fs_rec>-businessplace  = is_line-bupla.
    <fs_rec>-item_text      = is_line-belnr.

  ENDMETHOD.


  METHOD get_devol_data.

    SELECT * FROM zi_fi_prog_conc_cred
      INTO TABLE @gt_devol
      WHERE belnr IN @gs_selopt-belnr
        AND bukrs IN @gs_selopt-bukrs
*        AND blart = 'RV'
        AND bschl = '11'.

    IF gt_devol IS INITIAL AND gt_pdc IS INITIAL.
      gv_zero_rows = abap_true.
    ELSE.
      CLEAR gv_zero_rows.
      SORT gt_devol BY bukrs belnr gjahr buzei.
    ENDIF.

  ENDMETHOD.


  METHOD get_pdc_data.

    SELECT * FROM zi_fi_prog_conc_cred
      INTO TABLE @gt_pdc
      WHERE belnr IN @gs_selopt-belnr
        AND bukrs IN @gs_selopt-bukrs
*        AND blart = 'DD'
        AND bschl = '19'
        AND zlsch = '8'.

    IF gt_pdc IS INITIAL.
      gv_zero_rows = abap_true.
    ELSE.
      CLEAR gv_zero_rows.
    ENDIF.

  ENDMETHOD.


  METHOD pdc.

    get_pdc_data( ).
    get_log_doc_cred( gt_pdc ).

    get_cnpj_root( gt_pdc ).
    get_retira_cli( gt_pdc ).
    get_billing_doc( ).
    get_doc_cred( ).

    DELETE ADJACENT DUPLICATES FROM gt_billing COMPARING rootcnpj bukrs belnr gjahr buzei.

    LOOP AT gt_pdc ASSIGNING FIELD-SYMBOL(<fs_pdc>).

      IF NOT credito_associado_log( <fs_pdc> ).

        process_cred( is_cds  = <fs_pdc>
                      iv_proc = gc_pdc ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD process.

    conv_selopt( ).
    pdc( ).
    devol( ).
    check_no_data( ).
    save_logtab( ).
    go_log->save( ).

  ENDMETHOD.


  METHOD conv_selopt.

    DATA: lo_ref_descr   TYPE REF TO cl_abap_structdescr.
    DATA: lt_detail      TYPE abap_compdescr_tab.

    FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE,
                   <fs_ref>   TYPE REF TO data.

    lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( me->gs_refdata ).
    lt_detail[] = lo_ref_descr->components.

    LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<fs_det>).

      ASSIGN COMPONENT <fs_det>-name OF STRUCTURE me->gs_refdata TO <fs_ref>.
      ASSIGN COMPONENT <fs_det>-name OF STRUCTURE me->gs_selopt  TO FIELD-SYMBOL(<fs_selopt>).

      ASSIGN <fs_ref>->* TO <fs_table>.
      IF <fs_table> IS ASSIGNED.
        <fs_selopt> = <fs_table>.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_cnpj_root.

    DATA(lt_cds) = it_cds.

    SORT lt_cds BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_cds COMPARING kunnr.

    IF lt_cds IS NOT INITIAL.

      SELECT * FROM zi_ca_get_kunnr_by_cnpjroot
        INTO TABLE @gt_root
        FOR ALL ENTRIES IN @lt_cds
        WHERE clientebase = @lt_cds-kunnr.

      SORT gt_root BY rootcnpj cliente.

      gt_root_main = gt_root.

      DELETE ADJACENT DUPLICATES FROM gt_root_main COMPARING rootcnpj cliente.

    ENDIF.

  ENDMETHOD.


  METHOD get_billing_doc.

    IF gt_root IS NOT INITIAL.

      SELECT * FROM zi_fi_get_billing_venc
        INTO TABLE @gt_billing
        FOR ALL ENTRIES IN @gt_root
        WHERE bukrs IN @gs_selopt-bukrs
          AND kunnr EQ @gt_root-cliente
          AND belnr IN @gs_selopt-fat.

      SORT gt_billing BY rootcnpj bukrs belnr gjahr buzei buzei_koart.

    ENDIF.

  ENDMETHOD.


  METHOD min_days_is_valid.

    DATA lv_days TYPE i.
    DATA lv_negative TYPE i.

    lv_days = iv_netdt - sy-datum.

    IF lv_days >= 0 AND lv_days >= iv_mindays.
      rv_return = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD get_doc_cred.

    IF gt_billing IS NOT INITIAL.

      SELECT * FROM zi_fi_get_doc_cred
        INTO TABLE @gt_doccred
        FOR ALL ENTRIES IN @gt_billing
        WHERE bukrs = @gt_billing-bukrs
          AND rebzg = @gt_billing-belnr
          AND rebzj = @gt_billing-gjahr
          AND rebzz = @gt_billing-buzei.

    ENDIF.

  ENDMETHOD.


  METHOD retira_cliente.

    READ TABLE gt_retira_cli WITH KEY kunnr = iv_cli TRANSPORTING NO FIELDS BINARY SEARCH.
    IF sy-subrc = 0.
      rv_return = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD process_cred.

    DATA lt_billing TYPE ty_t_billing.

    data lv_residual type dmbtr.

    SORT gt_doccred BY rebzg rebzj rebzz.
    SORT gt_root_main BY cliente.

    CLEAR gv_processed.

    add_msg( iv_type        = 'I'
             iv_number      = '007'
             iv_message_v1  = CONV #( is_cds-bukrs )
             iv_message_v2  = CONV #( is_cds-belnr )
             iv_message_v3  = CONV #( is_cds-gjahr )
             iv_message_v4  = CONV #( is_cds-buzei ) ).

    IF retira_cliente( is_cds-kunnr ).

      add_msg( iv_type        = 'E'
               iv_number      = '005'
               iv_message_v1  = CONV #( is_cds-kunnr ) ).
      RETURN.

    ENDIF.

    READ TABLE gt_root_main ASSIGNING FIELD-SYMBOL(<fs_root_main>) WITH KEY cliente = is_cds-kunnr
                                                                   BINARY SEARCH.

    IF <fs_root_main> IS ASSIGNED.

      READ TABLE gt_billing WITH KEY rootcnpj = <fs_root_main>-rootcnpj
                                     bukrs    = is_cds-bukrs
                            TRANSPORTING NO FIELDS BINARY SEARCH.

      DATA(lv_index) = sy-tabix.

      LOOP AT gt_billing ASSIGNING FIELD-SYMBOL(<fs_billing>) FROM lv_index.

        IF <fs_billing>-rootcnpj NE <fs_root_main>-rootcnpj
          OR <fs_billing>-bukrs NE is_cds-bukrs.
          EXIT.
        ENDIF.

        clear_objects( ).

        IF min_days_is_valid( iv_netdt   = <fs_billing>-netdt
                              iv_mindays = <fs_billing>-mindays ).

          IF <fs_billing>-zbd1p IS NOT INITIAL.
            <fs_billing>-dmbtr = <fs_billing>-dmbtr - ( <fs_billing>-dmbtr * ( <fs_billing>-zbd1p / 100 ) ).
          ENDIF.

          subtrai_creditos_associados( CHANGING cs_billing = <fs_billing> ).

          IF <fs_billing>-dmbtr EQ 0.

            add_msg( iv_type        = 'E'
                     iv_number      = '006'
                     iv_message_v1  = CONV #( <fs_billing>-bukrs )
                     iv_message_v2  = CONV #( <fs_billing>-belnr )
                     iv_message_v3  = CONV #( <fs_billing>-gjahr )
                     iv_message_v4  = CONV #( <fs_billing>-buzei ) ).

            CONTINUE.

          ENDIF.

          IF <fs_billing>-dmbtr >= is_cds-dmbtr.

            lv_residual = <fs_billing>-dmbtr - is_cds-dmbtr.

            IF lv_residual >= <fs_billing>-minres.

              IF iv_proc EQ gc_pdc.

                processa_pdc( is_cds     = is_cds
                              is_billing = <fs_billing> ).

              ELSEIF iv_proc EQ gc_devolucao.

                processa_devolucao( is_cds     = is_cds
                                    iv_proc    = iv_proc
                                    is_billing = <fs_billing> ).

              ENDIF.

            ELSE.

              add_msg( iv_type        = 'E'
                       iv_number      = '002'
                       iv_message_v1  = CONV #( <fs_billing>-belnr )
                       iv_message_v2  = CONV #( <fs_billing>-gjahr )
                       iv_message_v3  = CONV #( <fs_billing>-buzei ) ).

            ENDIF.

            EXIT.

          ELSE.

            add_msg( iv_type        = 'E'
                     iv_number      = '008'
                     iv_message_v1  = CONV #( <fs_billing>-bukrs )
                     iv_message_v2  = CONV #( <fs_billing>-belnr )
                     iv_message_v3  = CONV #( <fs_billing>-gjahr )
                     iv_message_v4  = CONV #( <fs_billing>-buzei ) ).

          ENDIF.

        ELSE.

          add_msg( iv_type        = 'E'
                   iv_number      = '001'
                   iv_message_v1  = CONV #( <fs_billing>-belnr )
                   iv_message_v2  = CONV #( <fs_billing>-gjahr )
                   iv_message_v3  = CONV #( <fs_billing>-buzei ) ).

        ENDIF.

        IF gv_processed IS NOT INITIAL.
          EXIT.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD processa_devolucao.

    IF check_devol_forn( iv_proc = iv_proc
                         is_cred = is_cds ).

      IF is_cds-zlsch EQ 'T'.

        IF is_billing-bankl IS NOT INITIAL.

          processa_dev_forn( is_cds     = is_cds
                             is_billing = is_billing ).

        ELSE.

          add_msg( iv_type        = 'E'
                   iv_number      = '004'
                   iv_message_v1  = CONV #( is_billing-kunnr )
                   iv_message_v2  = CONV #( is_billing-belnr )
                   iv_message_v3  = CONV #( is_billing-gjahr )
                   iv_message_v4  = CONV #( is_billing-buzei ) ).


        ENDIF.

      ELSE.

        processa_dev_forn( is_cds     = is_cds
                           is_billing = is_billing ).

      ENDIF.

    ELSE.

      processa_devol_padrao( is_cds     = is_cds
                             is_billing = is_billing ).

    ENDIF.

  ENDMETHOD.


  METHOD processa_pdc.

    fill_bapi_pdc( is_cred = is_cds
                   is_fat  = is_billing ).

    bapi_check( ).
    bapi_post( ).
    bapi_commit( ).
    doc_change( is_billing ).
    run_fb1d( is_billing ).
    logtab_success( is_cred = is_cds
                    is_fat  = is_billing ).

  ENDMETHOD.


  METHOD processa_dev_forn.

    clear_objects( ).

    fill_bapi_devol_forn( is_cred = is_cds
                          is_fat  = is_billing ).

    bapi_check( ).
    bapi_post( ).
    bapi_commit( ).

    logtab_success( is_cred = is_cds
                    is_fat  = is_billing ).

  ENDMETHOD.


  METHOD fill_bapi_pdc.

    DATA lv_item_no TYPE bapiacgl09-itemno_acc.
    DATA lv_kostl   TYPE bseg-kostl.
    DATA lv_prctr   TYPE bseg-prctr.
    DATA lv_segment TYPE bseg-segment.

    IF is_fat-kostl IS NOT INITIAL.
      lv_kostl = is_fat-kostl.
    ELSE.
      lv_kostl = is_cred-kostl.
    ENDIF.

    IF is_fat-prctr IS NOT INITIAL.
      lv_prctr = is_fat-prctr.
    ELSE.
      lv_prctr = is_cred-prctr.
    ENDIF.

    IF is_fat-segment IS NOT INITIAL.
      lv_segment = is_fat-segment.
    ELSE.
      lv_segment = is_cred-segment.
    ENDIF.

    gs_header-doc_date    = sy-datum.
    gs_header-pstng_date  = sy-datum.
    gs_header-doc_type    = gv_docpdc.
    gs_header-comp_code   = is_cred-bukrs.
    gs_header-fis_period  = sy-datum+5(1).
    gs_header-ref_doc_no  = is_cred-xblnr.
    gs_header-header_txt  = is_cred-bktxt.
    gs_header-username    = sy-uname.

    ADD 1 TO lv_item_no.
    APPEND INITIAL LINE TO gt_rec ASSIGNING FIELD-SYMBOL(<fs_rec>).

    <fs_rec>-itemno_acc = lv_item_no.
    <fs_rec>-customer   = is_cred-kunnr.
    <fs_rec>-bus_area   = is_fat-gsber.
    <fs_rec>-sp_gl_ind  = gc_razao.
    <fs_rec>-alloc_nmbr = is_cred-zuonr.
    <fs_rec>-item_text  = is_cred-sgtxt.
    <fs_rec>-profit_ctr = is_cred-prctr.

    APPEND INITIAL LINE TO gt_curr ASSIGNING FIELD-SYMBOL(<fs_curr>).

    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = is_cred-dmbtr.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING FIELD-SYMBOL(<fs_ext>).
    <fs_ext>-structure  = 'BUPLA'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_cred-bupla.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XREF1_HD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = 'CONC_MANUAL'.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XREF2_HD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_fat-xref2_hd.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'FILKD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = ''.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XFILKD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = ''.


    ADD 1 TO lv_item_no.
    APPEND INITIAL LINE TO gt_rec ASSIGNING <fs_rec>.

    <fs_rec>-itemno_acc = lv_item_no.
    <fs_rec>-customer   = is_fat-kunnr.
    <fs_rec>-bus_area   = is_fat-gsber.
    <fs_rec>-paymt_ref  = is_fat-belnr.
    <fs_rec>-bank_id    = is_fat-hbkid.
    <fs_rec>-pymt_meth  = is_fat-zlsch.
    <fs_rec>-alloc_nmbr = is_cred-zuonr.
    <fs_rec>-item_text  = is_cred-sgtxt.
*    <fs_rec>-profit_ctr = is_fat-prctr.
    <fs_rec>-profit_ctr = lv_prctr.

    APPEND INITIAL LINE TO gt_curr ASSIGNING <fs_curr>.

    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = is_cred-dmbtr * -1.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'BSCHL'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = '17'.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'BUPLA'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_cred-bupla.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'REBZG'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_fat-belnr.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'REBZJ'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_fat-gjahr.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'REBZZ'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_fat-buzei.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'FILKD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = ''.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XFILKD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = ''.


    ADD 1 TO lv_item_no.
    APPEND INITIAL LINE TO gt_gl ASSIGNING FIELD-SYMBOL(<fs_gl>).

    <fs_gl>-itemno_acc = lv_item_no.

    <fs_gl>-gl_account = gv_conta40.
    <fs_gl>-bus_area   = is_fat-gsber.
    <fs_gl>-item_text  = is_cred-sgtxt.
    <fs_gl>-costcenter = lv_kostl.
*    <fs_gl>-segment    = is_fat-segment.
    <fs_gl>-segment    = lv_segment.

    APPEND INITIAL LINE TO gt_curr ASSIGNING <fs_curr>.

    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = is_cred-dmbtr.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'BUPLA'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_cred-bupla.

    ADD 1 TO lv_item_no.
    APPEND INITIAL LINE TO gt_gl ASSIGNING <fs_gl>.
    <fs_gl>-itemno_acc = lv_item_no.
    <fs_gl>-gl_account = gv_conta50.
    <fs_gl>-bus_area   = is_fat-gsber.
    <fs_gl>-item_text  = is_cred-sgtxt.
    <fs_gl>-costcenter = lv_kostl.
*    <fs_gl>-segment    = is_fat-segment.
    <fs_gl>-segment    = lv_segment.

    APPEND INITIAL LINE TO gt_curr ASSIGNING <fs_curr>.

    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = is_cred-dmbtr * -1 .

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'BUPLA'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_cred-bupla.

  ENDMETHOD.


  METHOD bapi_check.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader    = gs_header
      TABLES
        accountgl         = gt_gl
        accountreceivable = gt_rec
        accountpayable    = gt_pay
        currencyamount    = gt_curr
        extension2        = gt_ext2
        return            = gt_return.

    SORT gt_return BY type.

    READ TABLE gt_return WITH KEY type = 'E' TRANSPORTING NO FIELDS BINARY SEARCH.
    IF sy-subrc = 0.
      append_msgs( ).
    ELSE.
      gv_bapi_ok = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD fill_bapi_devol.

    DATA lv_item_no TYPE bapiacgl09-itemno_acc.

    DATA lv_venc    TYPE scdatum.

    CALL FUNCTION 'J_1B_FI_NETDUE'
      EXPORTING
        zfbdt   = is_cred-zfbdt
        zbd1t   = is_cred-zbd1t
        zbd2t   = is_cred-zbd2t
        zbd3t   = is_cred-zbd3t
      IMPORTING
        duedate = lv_venc.

    gs_header-doc_date    = sy-datum.
    gs_header-pstng_date  = sy-datum.
    gs_header-doc_type    = gv_docdev.
    gs_header-comp_code   = is_cred-bukrs.
    gs_header-fis_period  = sy-datum+5(1).
    gs_header-ref_doc_no  = is_cred-xblnr.
    gs_header-header_txt  = is_cred-bktxt.
    gs_header-username    = sy-uname.

    ADD 1 TO lv_item_no.
    APPEND INITIAL LINE TO gt_rec ASSIGNING FIELD-SYMBOL(<fs_rec>).

    <fs_rec>-itemno_acc = lv_item_no.
    <fs_rec>-customer   = is_cred-kunnr.
    <fs_rec>-bus_area   = is_fat-gsber.
    <fs_rec>-bline_date = lv_venc.
    <fs_rec>-pymt_meth  = is_fat-zlsch.
    <fs_rec>-alloc_nmbr = is_cred-zuonr.
    <fs_rec>-item_text  = is_cred-sgtxt.
    <fs_rec>-profit_ctr = is_cred-prctr.

    APPEND INITIAL LINE TO gt_curr ASSIGNING FIELD-SYMBOL(<fs_curr>).

    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = is_cred-dmbtr.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING FIELD-SYMBOL(<fs_ext>).
    <fs_ext>-structure  = 'BUPLA'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_cred-bupla.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XREF1_HD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = 'CONC_MANUAL'.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XREF2_HD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_fat-xref2_hd.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'BSCHL'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = '07'.

    ADD 1 TO lv_item_no.
    APPEND INITIAL LINE TO gt_rec ASSIGNING <fs_rec>.

    <fs_rec>-itemno_acc = lv_item_no.
    <fs_rec>-customer   = is_fat-kunnr.
    <fs_rec>-bus_area   = is_fat-gsber.
    <fs_rec>-bline_date = lv_venc.
    <fs_rec>-branch     = is_fat-bupla.
    <fs_rec>-paymt_ref  = is_fat-belnr.
    <fs_rec>-bank_id    = is_fat-hbkid.
    <fs_rec>-pymt_meth  = is_fat-zlsch.
    <fs_rec>-alloc_nmbr = is_cred-zuonr.
    <fs_rec>-item_text  = is_cred-sgtxt.
    <fs_rec>-profit_ctr = is_fat-prctr.

    APPEND INITIAL LINE TO gt_curr ASSIGNING <fs_curr>.

    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = is_cred-dmbtr * -1.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'BSCHL'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = '17'.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'BUPLA'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_cred-bupla.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'REBZG'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_fat-belnr.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'REBZJ'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_fat-gjahr.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'REBZZ'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_fat-buzei.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'FILKD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = ''.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XFILKD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = ''.

  ENDMETHOD.


  METHOD doc_change.

    DATA lt_change TYPE fdm_t_accchg.

    IF is_fat-anfbn IS NOT INITIAL.

      APPEND INITIAL LINE TO lt_change ASSIGNING FIELD-SYMBOL(<fs_chg>).
      <fs_chg>-fdname = 'DTWS1'.
      <fs_chg>-newval = '04'.

      CALL FUNCTION 'FI_DOCUMENT_CHANGE'
        EXPORTING
          i_buzei              = is_fat-buzei
          i_bukrs              = is_fat-bukrs
          i_belnr              = is_fat-belnr
          i_gjahr              = is_fat-gjahr
        TABLES
          t_accchg             = lt_change
        EXCEPTIONS
          no_reference         = 1
          no_document          = 2
          many_documents       = 3
          wrong_input          = 4
          overwrite_creditcard = 5
          OTHERS               = 6.

      IF sy-subrc <> 0.
        RETURN.
      ELSE.
        bapi_commit( ).
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD run_fb1d.

    DATA lv_doc_est TYPE belnr_d.
    DATA lv_item_est TYPE buzei.
    DATA lv_ano_est TYPE mjahr.

    DATA: lv_error TYPE boolean.
    DATA: lt_return TYPE bapiret2_tab.

    IF is_fat-anfbn IS NOT INITIAL.

      CALL FUNCTION 'ZFMFI_BATCH_COMPENSAR'
        EXPORTING
          iv_kunnr    = is_fat-kunnr
          iv_waers    = 'BRL'
          iv_budat    = is_fat-budat
          iv_bukrs    = is_fat-bukrs
          iv_anfbn    = is_fat-anfbn
        IMPORTING
          ev_erro     = lv_error
          ev_doc_est  = lv_doc_est
          ev_item_est = lv_item_est
          ev_ano_est  = lv_ano_est
        CHANGING
          ct_msg      = lt_return.

      go_log->add_msgs( lt_return ).

    ENDIF.

  ENDMETHOD.


  METHOD msg_doc_created.

    APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_return>).
    <fs_return>-type = 'S'.
    <fs_return>-message = |{ TEXT-m03 } { iv_obj(10) }/{ iv_obj+10(4) }/{ iv_obj+14(4) } { TEXT-m04 }|.

  ENDMETHOD.


  METHOD constructor.

    go_log = NEW zclca_save_log( gc_tcode ).

    go_log->create_log( gc_sub ).

    get_table_parameters( ).

  ENDMETHOD.


  METHOD get_retira_cli.

    DATA(lt_cds) = it_cds.
    SORT lt_cds BY kunnr.
    DELETE ADJACENT DUPLICATES FROM lt_cds COMPARING kunnr.

    IF lt_cds IS NOT INITIAL.

      SELECT kunnr
        FROM ztfi_exc_cli
        INTO TABLE gt_retira_cli
        FOR ALL ENTRIES IN lt_cds
        WHERE kunnr = lt_cds-kunnr.

    ENDIF.

    sort gt_retira_cli by kunnr.

  ENDMETHOD.


  METHOD get_table_parameters.

    CONSTANTS: lc_fi      TYPE ztca_param_par-modulo VALUE 'FI-AR',
               lc_chave1  TYPE ztca_param_par-chave1 VALUE 'CONCESSAO_CRED',
               lc_conta40 TYPE ztca_param_par-chave2 VALUE 'CONTA_RAZ_PDC_40',
               lc_conta50 TYPE ztca_param_par-chave2 VALUE 'CONTA_RAZ_PDC_50',
               lc_docforn TYPE ztca_param_par-chave2 VALUE 'TIPODOC_FORNECEDOR',
               lc_docpdc  TYPE ztca_param_par-chave2 VALUE 'TIPODOC_PDC',
               lc_docdev  TYPE ztca_param_par-chave2 VALUE 'TIPODOC_DEVOLUCAO'.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.

        lo_param->m_get_single( EXPORTING iv_modulo = lc_fi
                                          iv_chave1 = lc_chave1
                                          iv_chave2 = lc_conta40
                                IMPORTING ev_param = gv_conta40 ).

        lo_param->m_get_single( EXPORTING iv_modulo = lc_fi
                                          iv_chave1 = lc_chave1
                                          iv_chave2 = lc_conta50
                                IMPORTING ev_param = gv_conta50 ).

        lo_param->m_get_single( EXPORTING iv_modulo = lc_fi
                                          iv_chave1 = lc_chave1
                                          iv_chave2 = lc_docpdc
                                IMPORTING ev_param = gv_docpdc ).

        lo_param->m_get_single( EXPORTING iv_modulo = lc_fi
                                          iv_chave1 = lc_chave1
                                          iv_chave2 = lc_docdev
                                IMPORTING ev_param = gv_docdev ).

        lo_param->m_get_single( EXPORTING iv_modulo = lc_fi
                                          iv_chave1 = lc_chave1
                                          iv_chave2 = lc_docforn
                                IMPORTING ev_param = gv_docforn ).

      CATCH zcxca_tabela_parametros.

        RETURN.

    ENDTRY.

  ENDMETHOD.


  METHOD logtab_success.

    DATA ls_logtab TYPE ztfi_logconcred.

    DATA: lr_bschl TYPE RANGE OF bschl.

    IF gv_doc_key IS NOT INITIAL.

      ls_logtab-bukrs = is_cred-bukrs.
      ls_logtab-kunnr = is_cred-kunnr.
      ls_logtab-stcd1 = is_cred-stcd1.
      ls_logtab-stcd2 = is_cred-stcd2.

      ls_logtab-zfatura          = is_fat-belnr.
      ls_logtab-zitemfatura      = is_fat-buzei.
      ls_logtab-zexerciciofatura = is_fat-gjahr.
      ls_logtab-wrbtr            = is_fat-wrbtr   .
      ls_logtab-bschl            = is_fat-bschl   .
      ls_logtab-netdt            = is_fat-netdt   .
      ls_logtab-zlsch            = is_fat-zlsch   .
      ls_logtab-zuonr            = is_fat-zuonr   .
      ls_logtab-xblnr            = is_fat-xblnr   .
      ls_logtab-blart            = is_fat-blart   .
      ls_logtab-xref1_hd         = is_fat-xref1_hd.
      ls_logtab-xref2_hd         = is_fat-xref2_hd.

      ls_logtab-zcredito          =  is_cred-belnr   .
      ls_logtab-zitemcredito      =  is_cred-buzei   .
      ls_logtab-zexerciciocredito =  is_cred-gjahr   .
      ls_logtab-zwrbtr            =  is_cred-wrbtr   .
      ls_logtab-zbschl            =  is_cred-bschl   .
      ls_logtab-znetdt            =  is_cred-netdt   .
      ls_logtab-zzlsch            =  is_cred-zlsch   .
      ls_logtab-zzuonr            =  is_cred-zuonr   .
      ls_logtab-zxblnr            =  is_cred-xblnr   .
      ls_logtab-zblart            =  is_cred-blart   .
      ls_logtab-zxref1_hd         =  is_cred-xref1_hd.
      ls_logtab-zxref2_hd         =  is_cred-xref2_hd.

      ls_logtab-zdoccon           = gv_doc_key(10).
      ls_logtab-zexerciciodoccon  = gv_doc_key+14(4).

      lr_bschl = VALUE #( sign = 'I' option = 'EQ' ( low = '07' )
                                                   ( low = '17' )
                                                   ( low = '19' ) ).

      WAIT UP TO 1 SECONDS.

      SELECT buzei, bschl
        FROM bseg
        INTO TABLE @DATA(lt_bschl)
        WHERE bukrs EQ @is_cred-bukrs
          AND belnr EQ @ls_logtab-zdoccon
          AND gjahr EQ @ls_logtab-zexerciciodoccon
          AND bschl IN @lr_bschl.

      IF lt_bschl IS NOT INITIAL.

        SORT lt_bschl BY bschl.

        READ TABLE lt_bschl ASSIGNING FIELD-SYMBOL(<fs_bschl>) WITH KEY bschl = 17
                                                               BINARY SEARCH.

        IF sy-subrc <> 0.

          READ TABLE lt_bschl ASSIGNING <fs_bschl> WITH KEY bschl = 19
                                                   BINARY SEARCH.

          IF sy-subrc <> 0.

            READ TABLE lt_bschl ASSIGNING <fs_bschl> WITH KEY bschl = 07
                                                     BINARY SEARCH.

            IF sy-subrc = 0.
              ls_logtab-zitemdoccon = <fs_bschl>-buzei.
            ENDIF.

          ELSE.
            ls_logtab-zitemdoccon = <fs_bschl>-buzei.
          ENDIF.

        ELSE.
          ls_logtab-zitemdoccon = <fs_bschl>-buzei.
        ENDIF.

      ENDIF.

      SELECT buzei
        FROM bseg
        INTO ls_logtab-umskz
        UP TO 1 ROWS
        WHERE bukrs = is_cred-bukrs
          AND belnr = ls_logtab-zdoccon
          AND gjahr = ls_logtab-zexerciciodoccon
          AND bschl = '09'.
      ENDSELECT.

*      SELECT SINGLE bankn
*        FROM lfbk
*        INTO ls_logtab-zdadosfor
*        WHERE lifnr = is_cred-kunnr.
*
*      IF sy-subrc <> 0.
*        ls_logtab-zdadosfor = 'NÃO'.
*      ELSE.
*        CLEAR ls_logtab-zdadosfor.
*      ENDIF.


      ls_logtab-zdata = sy-datum.
      ls_logtab-zhora = sy-uzeit.
      ls_logtab-bname = sy-uname.

      APPEND ls_logtab TO gt_logtab.
      CLEAR ls_logtab.

    ENDIF.

  ENDMETHOD.


  METHOD save_logtab.

    MODIFY ztfi_logconcred FROM TABLE gt_logtab.

  ENDMETHOD.


  METHOD fill_bapi_devol_forn.

    DATA lv_item_no TYPE bapiacgl09-itemno_acc.
    DATA lv_date    TYPE scdatum.
    DATA lv_venc    TYPE scdatum.
    DATA lv_day     TYPE cind.

    CALL FUNCTION 'J_1B_FI_NETDUE'
      EXPORTING
        zfbdt   = is_cred-zfbdt
        zbd1t   = is_cred-zbd1t
        zbd2t   = is_cred-zbd2t
        zbd3t   = is_cred-zbd3t
      IMPORTING
        duedate = lv_venc.

    lv_date = lv_venc.

    DO 7 TIMES.

      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
        EXPORTING
          date                         = lv_date
          factory_calendar_id          = 'BR'
        IMPORTING
          date                         = lv_date
        EXCEPTIONS
          calendar_buffer_not_loadable = 1
          correct_option_invalid       = 2
          date_after_range             = 3
          date_before_range            = 4
          date_invalid                 = 5
          factory_calendar_not_found   = 6
          OTHERS                       = 7.

      IF sy-subrc <> 0.
        CLEAR lv_date.
        EXIT.
      ELSE.
        CALL FUNCTION 'DATE_COMPUTE_DAY'
          EXPORTING
            date = lv_date
          IMPORTING
            day  = lv_day.
      ENDIF.

      IF lv_day EQ '6' OR lv_day EQ '7'.
        ADD 1 TO lv_date.
      ELSE.
        EXIT.
      ENDIF.

    ENDDO.

    gs_header-doc_date    = sy-datum.
    gs_header-pstng_date  = sy-datum.
    gs_header-doc_type    = gv_docforn.
    gs_header-comp_code   = is_cred-bukrs.
    gs_header-fis_period  = sy-datum+5(1).
    gs_header-ref_doc_no  = is_cred-xblnr.
    gs_header-header_txt  = is_cred-bktxt.
    gs_header-username    = sy-uname.

    ADD 1 TO lv_item_no.
    APPEND INITIAL LINE TO gt_pay ASSIGNING FIELD-SYMBOL(<fs_pay>).

    <fs_pay>-itemno_acc = lv_item_no.
    <fs_pay>-bus_area   = is_fat-gsber.
    <fs_pay>-bline_date = lv_date.
    <fs_pay>-alloc_nmbr = is_cred-zuonr.
    <fs_pay>-pymt_meth  = is_cred-zlsch.
    <fs_pay>-item_text  = is_cred-sgtxt.
    <fs_pay>-profit_ctr = is_cred-prctr.
    <fs_pay>-vendor_no  = is_cred-kunnr.
    <fs_pay>-bank_id    = is_cred-hbkid.

    APPEND INITIAL LINE TO gt_curr ASSIGNING FIELD-SYMBOL(<fs_curr>).

    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = is_cred-dmbtr * -1.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING FIELD-SYMBOL(<fs_ext>).
    <fs_ext>-structure  = 'BUPLA'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_cred-bupla.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XREF1_HD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = 'PAGAR_DEVOL'.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XREF2_HD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_fat-xref2_hd.

    ADD 1 TO lv_item_no.
    APPEND INITIAL LINE TO gt_rec ASSIGNING FIELD-SYMBOL(<fs_rec>).

    <fs_rec>-itemno_acc = lv_item_no.
    <fs_rec>-customer   = is_fat-kunnr.
    <fs_rec>-bus_area   = is_fat-gsber.
    <fs_rec>-bline_date = lv_date.
    <fs_rec>-pymt_meth  = is_cred-zlsch.
    <fs_rec>-branch     = is_fat-bupla.
    <fs_rec>-paymt_ref  = is_fat-belnr.
    <fs_rec>-alloc_nmbr = is_cred-zuonr.
    <fs_rec>-item_text  = is_cred-sgtxt.
    <fs_rec>-profit_ctr = is_fat-prctr.

    APPEND INITIAL LINE TO gt_curr ASSIGNING <fs_curr>.

    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = is_cred-dmbtr.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'BSCHL'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = '07'.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'BUPLA'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = is_cred-bupla.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'FILKD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = ''.

    APPEND INITIAL LINE TO gt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XFILKD'.
    <fs_ext>-valuepart1 = lv_item_no.
    <fs_ext>-valuepart2 = ''.

  ENDMETHOD.


  METHOD check_devol_forn.

    DATA: lr_zlsch TYPE RANGE OF bseg-zlsch.

    lr_zlsch = VALUE #( sign = 'I' option = 'EQ' ( low = 'B' )
                                                 ( low = 'T' ) ).

    IF iv_proc = gc_devolucao
*      AND is_cred-blart EQ 'RV'
      AND is_cred-bschl EQ '11'
      AND is_cred-zlsch IN lr_zlsch.

      rv_value = abap_true.

    ENDIF.

  ENDMETHOD.


  METHOD logtab_error.

    DATA ls_logtab TYPE ztfi_logconcred.

    IF gv_doc_key IS NOT INITIAL.

      ls_logtab-bukrs = is_cred-bukrs.
      ls_logtab-kunnr = is_cred-kunnr.
      ls_logtab-stcd1 = is_cred-stcd1.
      ls_logtab-stcd2 = is_cred-stcd2.

      ls_logtab-zfatura          = is_fat-belnr.
      ls_logtab-zitemfatura      = is_fat-buzei.
      ls_logtab-zexerciciofatura = is_fat-gjahr.
      ls_logtab-wrbtr            = is_fat-wrbtr   .
      ls_logtab-bschl            = is_fat-bschl   .
      ls_logtab-netdt            = is_fat-netdt   .
      ls_logtab-zlsch            = is_fat-zlsch   .
      ls_logtab-zuonr            = is_fat-zuonr   .
      ls_logtab-xblnr            = is_fat-xblnr   .
      ls_logtab-blart            = is_fat-blart   .
      ls_logtab-xref1_hd         = is_fat-xref1_hd.
      ls_logtab-xref2_hd         = is_fat-xref2_hd.

      ls_logtab-zcredito          =  is_cred-belnr   .
      ls_logtab-zitemcredito      =  is_cred-buzei   .
      ls_logtab-zexerciciocredito =  is_cred-gjahr   .
      ls_logtab-zwrbtr            =  is_cred-wrbtr   .
      ls_logtab-zbschl            =  is_cred-bschl   .
      ls_logtab-znetdt            =  is_cred-netdt   .
      ls_logtab-zzlsch            =  is_cred-zlsch   .
      ls_logtab-zzuonr            =  is_cred-zuonr   .
      ls_logtab-zxblnr            =  is_cred-xblnr   .
      ls_logtab-zblart            =  is_cred-blart   .
      ls_logtab-zxref1_hd         =  is_cred-xref1_hd.
      ls_logtab-zxref2_hd         =  is_cred-xref2_hd.

      IF iv_notres IS NOT INITIAL.
        ls_logtab-zresidualnao = 'NÃO'.
      ENDIF.

      IF iv_notdias IS NOT INITIAL.
        ls_logtab-zvencimentonao = 'NÃO'.
      ENDIF.

      SELECT SINGLE bankn
        FROM lfbk
        INTO ls_logtab-zdadosfor
        WHERE lifnr = is_cred-kunnr.

      IF sy-subrc <> 0.
        ls_logtab-zdadosfor = 'NÃO'.
      ELSE.
        CLEAR ls_logtab-zdadosfor.
      ENDIF.

      ls_logtab-zdoccon           = gv_doc_key(10).
      ls_logtab-zexerciciodoccon  = gv_doc_key+14(4).

      ls_logtab-zdata = sy-datum.
      ls_logtab-zhora = sy-uzeit.
      ls_logtab-bname = sy-uname.

      APPEND ls_logtab TO gt_logtab.
      CLEAR ls_logtab.

    ENDIF.

  ENDMETHOD.


  METHOD msg_no_data_found.

    APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_return>).
    <fs_return>-type       = 'E'.
    <fs_return>-message_v1 = TEXT-m02.
    <fs_return>-id         = '00'.
    <fs_return>-number     = '398'.

  ENDMETHOD.


  METHOD msg_no_bank_data.

    APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_return>).
    <fs_return>-type = 'E'.
    <fs_return>-message = |{ TEXT-m05 } { iv_kunnr } { TEXT-m06 }|.

  ENDMETHOD.


  METHOD check_no_data.

    IF gv_zero_rows IS NOT INITIAL.
      msg_no_data_found( ).
      append_msgs( ).
    ENDIF.

  ENDMETHOD.


  METHOD get_log_doc_cred.

    DATA(lt_cds) = it_cds.

    IF lt_cds IS NOT INITIAL.

      SORT lt_cds BY bukrs
                     belnr
                     buzei
                     gjahr.

      DELETE ADJACENT DUPLICATES FROM lt_cds COMPARING bukrs
                                                       belnr
                                                       buzei
                                                       gjahr.

      SELECT *                                          "#EC CI_SEL_DEL
        FROM zi_fi_logconcred_conv
        FOR ALL ENTRIES IN @lt_cds
        WHERE bukrs             = @lt_cds-bukrs
          AND zcredito          = @lt_cds-belnr
          AND zitemcredito      = @lt_cds-buzei
          AND zexerciciocredito = @lt_cds-gjahr
        INTO TABLE @gt_logtab_db.

      IF sy-subrc IS INITIAL.

        SORT gt_logtab_db BY bukrs
                             zcredito
                             zitemcredito
                             zexerciciocredito.

        DELETE ADJACENT DUPLICATES FROM gt_logtab_db COMPARING bukrs
                                                               zcredito
                                                               zitemcredito
                                                               zexerciciocredito.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD PROCESSA_DEVOL_PADRAO.

    fill_bapi_devol( is_cred = is_cds
                     is_fat  = is_billing ).

    bapi_check( ).
    bapi_post( ).
    bapi_commit( ).
    doc_change( is_billing ).
    run_fb1d( is_billing ).
    logtab_success( is_cred = is_cds
                    is_fat  = is_billing ).

  ENDMETHOD.


  METHOD add_msg.

    APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_ret>).
    <fs_ret>-type       = iv_type      .
    <fs_ret>-id         = iv_id        .
    <fs_ret>-number     = iv_number    .
    <fs_ret>-message    = iv_message   .
    <fs_ret>-message_v1 = iv_message_v1.
    <fs_ret>-message_v2 = iv_message_v2.
    <fs_ret>-message_v3 = iv_message_v3.
    <fs_ret>-message_v4 = iv_message_v4.

    append_msgs( ).

  ENDMETHOD.


  METHOD APPEND_MSGS.

    go_log->add_msgs( gt_return ).
    REFRESH gt_return.

  ENDMETHOD.


  METHOD credito_associado_log.

    "Verifica no banco de dados se o crédito já foi associado
    READ TABLE gt_logtab_db WITH KEY bukrs             = is_cds-bukrs
                                     zcredito          = is_cds-belnr
                                     zitemcredito      = is_cds-buzei
                                     zexerciciocredito = is_cds-gjahr
                            BINARY SEARCH TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.
      rv_return = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD subtrai_creditos_associados.

    READ TABLE gt_doccred ASSIGNING FIELD-SYMBOL(<fs_doccred>) WITH KEY rebzg = cs_billing-belnr
                                                                        rebzj = cs_billing-gjahr
                                                                        rebzz = cs_billing-buzei
                                                               BINARY SEARCH.

    IF sy-subrc IS INITIAL.
      cs_billing-dmbtr = cs_billing-dmbtr - <fs_doccred>-dmbtr.
    ENDIF.

    DATA(lt_logtab) = gt_logtab[].
    SORT lt_logtab BY zfatura zitemfatura zexerciciofatura.
    DELETE lt_logtab WHERE zfatura          NE cs_billing-belnr AND "#EC CI_STDSEQ
                           zitemfatura      NE cs_billing-gjahr AND
                           zexerciciofatura NE cs_billing-buzei.

    LOOP AT lt_logtab ASSIGNING FIELD-SYMBOL(<fs_logtab>).
      cs_billing-dmbtr = cs_billing-dmbtr - <fs_logtab>-zwrbtr.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
