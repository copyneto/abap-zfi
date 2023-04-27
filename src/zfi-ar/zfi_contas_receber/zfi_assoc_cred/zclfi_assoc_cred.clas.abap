CLASS zclfi_assoc_cred DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS bapi_post
      EXPORTING
        !ev_documento TYPE belnr_d
        !ev_exercicio TYPE gjahr
        !ev_empresa   TYPE bukrs .
    METHODS process
      EXPORTING
        !ev_documento TYPE belnr_d
        !ev_exercicio TYPE gjahr
        !ev_empresa   TYPE bukrs
        !et_msg       TYPE bapiret2_t .
protected section.
private section.

  data GT_ACC_GL type BAPIACGL09_TAB .
  data GT_ACC_REC type BAPIACAR09_TAB .
  data GT_CURRENCY type BAPIACCR09_TAB .
  data GS_HEADER type BAPIACHE09 .
  data GT_MSG_EX type BAPIRET2_T .
  data GT_RETURN type BAPIRET2_T .
  data GV_ERROR type BOOLEAN .
  data GV_DUMMY type STRING .
  constants GC_E type CHAR1 value 'E' ##NO_TEXT.
  constants GC_RFBV type CHAR4 value 'RFBV' ##NO_TEXT.
  constants GC_BKPFF type CHAR5 value 'BKPFF' ##NO_TEXT.
  constants GC_CURRENCY type WAERS value 'BRL' ##NO_TEXT.

  methods FILL_BAPI .
  methods FILL_HEADER .
  methods APPEND_MSG .
  methods BAPI_CHECK .
  methods FILL_ITEMS .
  methods CLEAR_ALL .
  methods EXEC_BAPI
    exporting
      !EV_DOCUMENTO type BELNR_D
      !EV_EXERCICIO type GJAHR
      !EV_EMPRESA type BUKRS .
  methods BAPI_SUCCESS
    returning
      value(RV_RETURN) type ABAP_BOOL .
ENDCLASS.



CLASS ZCLFI_ASSOC_CRED IMPLEMENTATION.


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


  METHOD bapi_check.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader    = me->gs_header
      TABLES
        accountgl         = me->gt_acc_gl
        accountreceivable = me->gt_acc_rec
        currencyamount    = me->gt_currency
        return            = me->gt_return.

    DATA(lt_return) = me->gt_return.
    SORT lt_return BY type.

    READ TABLE lt_return WITH KEY type = gc_e TRANSPORTING NO FIELDS
                         BINARY SEARCH.

    IF sy-subrc = 0.
      gv_error = abap_true.
      append_msg( ).
    ENDIF.

    LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<fs_msg>).

      MESSAGE ID <fs_msg>-id
            TYPE <fs_msg>-type
          NUMBER <fs_msg>-number
            WITH <fs_msg>-message_v1
                 <fs_msg>-message_v2
                 <fs_msg>-message_v3
                 <fs_msg>-message_v4
            INTO gv_dummy.

      append_msg( ).

    ENDLOOP.

  ENDMETHOD.


  METHOD bapi_post.

    DATA: lv_obj_key TYPE bapiache09-obj_key.

    ##FM_PAR_MIS
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader    = me->gs_header
      IMPORTING
        obj_key           = lv_obj_key
      TABLES
        accountgl         = me->gt_acc_gl
        accountreceivable = me->gt_acc_rec
        currencyamount    = me->gt_currency.

    "Erro no lançamento
    IF line_exists( me->gt_return[ type = gc_e ] )."#EC CI_STDSEQ
      gv_error = abap_true.
      "Error ao tentar criar lançamento: &1 &2 &3 &4
* MESSAGE e001 WITH gs_lanc_prov-bukrs gs_lanc_prov-banfn gs_lanc_prov-bnfpo INTO gv_dummy.
      append_msg( ).
    ENDIF.

    LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<fs_msg>).

      MESSAGE ID <fs_msg>-id
            TYPE <fs_msg>-type
          NUMBER <fs_msg>-number
            WITH <fs_msg>-message_v1
                 <fs_msg>-message_v2
                 <fs_msg>-message_v3
                 <fs_msg>-message_v4
            INTO gv_dummy.

      append_msg( ).

    ENDLOOP.

  ENDMETHOD.


  METHOD bapi_success.

    DATA(lt_msg_ex) = gt_msg_ex.
    SORT lt_msg_ex BY id type number.

    READ TABLE gt_msg_ex TRANSPORTING NO FIELDS WITH KEY id     = 'RW'
                                                         type   = 'S'
                                                         number = '638'
                         BINARY SEARCH.
    IF sy-subrc = 0.
      rv_return = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD clear_all.

    CLEAR: gs_header,
           gv_dummy,
           gv_error,
           gt_acc_gl,
           gt_acc_rec,
           gt_currency,
*           gt_extension,
*           gt_extension2,
           gt_msg_ex,
           gt_return.

  ENDMETHOD.


  METHOD exec_bapi.

    fill_bapi( ).
    bapi_check( ).

    CHECK gv_error = abap_false.

    bapi_post( IMPORTING ev_documento = ev_documento
                         ev_exercicio = ev_exercicio
                         ev_empresa   = ev_empresa ).

  ENDMETHOD.


  METHOD fill_bapi.

    fill_header( ).

    fill_items( ).

  ENDMETHOD.


  METHOD fill_header.

    CLEAR: gs_header.

    me->gs_header-pstng_date  = sy-datum.
    me->gs_header-doc_date    = sy-datum.
    me->gs_header-doc_type    = 'DE'.
    me->gs_header-fisc_year   = sy-datum(4).
    me->gs_header-fis_period  = sy-datum+4(2).
    me->gs_header-ref_doc_no  = 'is_line-belnr'.
    me->gs_header-header_txt  = 'is_line-belnr'.
    me->gs_header-username    = sy-uname.
    me->gs_header-comp_code   = 'is_line-bukrs'.

    me->gs_header-bus_act     = gc_rfbv.
    me->gs_header-doc_status  = '2'.
    me->gs_header-obj_type    = gc_bkpff.

  ENDMETHOD.


  METHOD fill_items.

    DATA: lv_item_no TYPE bapiacgl09-itemno_acc.
    DATA: lv_req TYPE char10,
          lv_num TYPE char10.

    ADD 1 TO lv_item_no.

    APPEND INITIAL LINE TO me->gt_acc_gl ASSIGNING FIELD-SYMBOL(<fs_gl>).
    <fs_gl>-itemno_acc = lv_item_no.
    <fs_gl>-comp_code  = 'is_line-bukrs'.
    <fs_gl>-fisc_year  = 'is_line-docdate(4)'.
    <fs_gl>-pstng_date = 'is_line-docdate'.
    <fs_gl>-bus_area   = 'is_line-gsber'.
    <fs_gl>-customer   = 'is_line-kunnr'.
    <fs_gl>-profit_ctr = 'is_line-prctr'.
    <fs_gl>-segment    = ''.
    <fs_gl>-item_text      = 'is_line-belnr'.

    APPEND INITIAL LINE TO me->gt_currency ASSIGNING FIELD-SYMBOL(<fs_curr>).
    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = 'is_line-dmbtr'.

    ADD 1 TO lv_item_no.

    APPEND INITIAL LINE TO me->gt_acc_gl ASSIGNING <fs_gl>.
    <fs_gl>-itemno_acc = lv_item_no.
    <fs_gl>-comp_code  = 'is_line-bukrs'.
    <fs_gl>-fisc_year  = 'is_line-docdate(4)'.
    <fs_gl>-pstng_date = 'is_line-docdate'.
    <fs_gl>-bus_area   = 'is_line-gsber'.
    <fs_gl>-customer   = 'is_line-kunnr'.
    <fs_gl>-profit_ctr = 'is_line-prctr'.
    <fs_gl>-segment    = ''.
    <fs_gl>-item_text  = 'is_line-belnr'.
    <fs_gl>-ac_doc_no  = 'is_line-belnr'.


    APPEND INITIAL LINE TO me->gt_currency ASSIGNING <fs_curr>.
    <fs_curr>-itemno_acc   = lv_item_no.
    <fs_curr>-currency_iso = gc_currency.
    <fs_curr>-amt_doccur   = 'is_line-dmbtr'.


  ENDMETHOD.


  METHOD process.

    clear_all( ).

    exec_bapi( IMPORTING ev_documento = ev_documento
                         ev_exercicio = ev_exercicio
                         ev_empresa   = ev_empresa ).

    et_msg = gt_msg_ex.

  ENDMETHOD.
ENDCLASS.
