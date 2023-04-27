class ZCLFI_BAPI_DDA definition
  public
  final
  create public .

public section.

  types:
    TT_RETURN type STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
  types:
    BEGIN OF ty_input,
        bukrs   TYPE bukrs,
        belnr   TYPE belnr_d,
        gjahr   TYPE gjahr,
        buzei   TYPE buzei,
        lifnr   TYPE lifnr,
        barcode TYPE brcde,
        xblnr   TYPE xblnr,
      END OF ty_input .

  constants:
    BEGIN OF gc_fixo,
        tcode    TYPE sy-tcode       VALUE 'FB05',
        sgfunct  TYPE rfipi-sgfunct  VALUE 'C',
        agkoa    TYPE koart          VALUE 'K',
        blart    TYPE blart          VALUE 'KP',
        newbs    TYPE rf05a-newbs    VALUE '31',
        zlsch    TYPE bseg-zlsch     VALUE 'B',
        maior    TYPE rf05a-newbs    VALUE '50',
        menor    TYPE rf05a-newbs    VALUE '40',
        auglv    TYPE auglv          VALUE 'UMBUCHNG',
        selfd    TYPE fld30_f05a     VALUE 'BELNR',
        agums    TYPE agums          VALUE 'ABCDE',
        function TYPE funct_pi       VALUE 'C',
        mode     TYPE allgazmd       VALUE 'N',
        erro     TYPE char1          VALUE 'E',
      END OF gc_fixo .

  methods CONSTRUCTOR
    importing
      !IS_INPUT type TY_INPUT .
  methods PROCESS
    returning
      value(RT_RETURN) type TT_RETURN .
protected section.
private section.

  types:
    BEGIN OF ty_bkpf,
      bukrs TYPE bkpf-bukrs,
      belnr TYPE bkpf-belnr,
      gjahr TYPE bkpf-gjahr,
      bldat TYPE bkpf-bldat,
      budat TYPE bkpf-budat,
      xblnr TYPE bkpf-xblnr,
      bktxt TYPE bkpf-bktxt,
      waers TYPE bkpf-waers,
    END OF ty_bkpf .
  types:
    BEGIN OF ty_dda,
      doc_num    TYPE  j1b_error_dda-doc_num,
      bukrs      TYPE  j1b_error_dda-bukrs,
      gjahr      TYPE  j1b_error_dda-gjahr,
      due_date   TYPE  j1b_error_dda-due_date,
      amount     TYPE  j1b_error_dda-amount,
      err_reason TYPE  j1b_error_dda-err_reason,
    END OF ty_dda .
  types:
    BEGIN OF ty_bseg,
      bukrs TYPE bseg-bukrs,
      belnr TYPE bseg-belnr,
      gjahr TYPE bseg-gjahr,
      buzei TYPE bseg-buzei,
      wrbtr TYPE bseg-wrbtr,
      sgtxt TYPE bseg-sgtxt,
      zlspr TYPE bseg-zlspr,
      hbkid TYPE bseg-hbkid,
      bupla TYPE bseg-bupla,
      hktid TYPE bseg-hktid,
    END OF ty_bseg .
  types:
    BEGIN OF ty_conta,
      bukrs     TYPE bukrs,
      valor_tol TYPE ztfi_conta_dda-valor_tol,
      conta_low TYPE ze_conta_lim_inferior,
      kostl     TYPE kostl,
    END OF ty_conta .
  types:
    BEGIN OF ty_error,
      bukrs        TYPE ztfi_error_xblnr-bukrs,
      gjahr        TYPE ztfi_error_xblnr-gjahr,
      reference_no TYPE ztfi_error_xblnr-reference_no,
    END OF ty_error .

  data GT_BLNTAB type RE_T_EX_BLNTAB .
  data GT_FTCLEAR type FEB_T_FTCLEAR .
  data GT_FTPOST type FEB_T_FTPOST .
  data GT_FTTAX type FEB_T_FTTAX .
  data GV_TESTE type CHAR1 value 'X' ##NO_TEXT.
  data GS_INPUT type TY_INPUT .
  data GS_BKPF type TY_BKPF .
  data GS_DDA type J1B_ERROR_DDA .
  data GS_BSEG type TY_BSEG .
  data GS_CONTA type TY_CONTA .
  data GT_CHANGE type FDM_T_ACCCHG .
  data GS_KEY type BSEG_KEY .
  data GT_RETURN type TT_BAPIRET2 .
  data GS_DDA_NEW type J1B_ERROR_DDA .
  data GV_SUCESS type CHAR1 .
  data GS_DDAERROR_CP type ZTFI_DDAERROR_CP .
  data GS_ERROR type TY_ERROR .
  data GV_ERRO type ABAP_BOOL .

  methods END_MESSAGE .
  methods FILL_CHANGE_C .
  methods FILL_CHANGE_D .
  methods UPDATE_DDA_TABLE .
  methods FILL_CHANGE_A .
  methods ALIGN_LEFT
    importing
      !IV_VALUE type ANY
    returning
      value(RV_VALUE) type BDC_FVAL .
  methods DATE_OUT
    importing
      !IV_DATUM type DATUM
    returning
      value(RV_DATE) type CHAR10 .
  methods FORMAT_DATE
    importing
      !IV_DATE type J_1BDUE2
    returning
      value(RV_DATE) type DATUM .
  methods FORMAT_ZUONR
    importing
      !IV_DATE type J_1BDUE2
    returning
      value(RV_ZUONR) type CHAR14 .
  methods FORMAT_AMOUNT
    importing
      !IV_AMOUNT type J_1BXL16
    returning
      value(RV_AMOUNT) type BSEG-WRBTR .
  methods FILL_FTCLEAR .
  methods FILL_FTPOST .
  methods SET_FTPOST_VALUE
    importing
      !IV_STYPE type STYPE_PI
      !IV_COUNT type COUNT_PI
      !IV_FNAM type BDC_FNAM
      !IV_FVAL type BDC_FVAL .
  methods GET_DATA .
  methods POST_CLEARING .
  methods DOC_CHANGE .
  methods BAPI_COMMIT .
  methods POST_START .
ENDCLASS.



CLASS ZCLFI_BAPI_DDA IMPLEMENTATION.


  METHOD align_left.

    rv_value = iv_value.

    SHIFT rv_value LEFT DELETING LEADING space.

    REPLACE ALL OCCURRENCES OF '.' IN rv_value WITH ','.

  ENDMETHOD.


  METHOD bapi_commit.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

  ENDMETHOD.


  METHOD constructor.

    gs_input = is_input.

  ENDMETHOD.


  METHOD date_out.

    rv_date = |{ iv_datum+6(2) }.{ iv_datum+4(2) }.{ iv_datum(4) }|.

  ENDMETHOD.


  METHOD doc_change.

    FIELD-SYMBOLS: <fs_return> LIKE LINE OF gt_return.

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_buzei              = gs_key-buzei
        i_bukrs              = gs_key-bukrs
        i_belnr              = gs_key-belnr
        i_gjahr              = gs_key-gjahr
      TABLES
        t_accchg             = gt_change
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.

    IF sy-subrc = 0.

      IF gs_dda-err_reason EQ 'A'.

        APPEND INITIAL LINE TO gt_return ASSIGNING <fs_return>.
        <fs_return>-id         = 'ZFI_SOLUCAO_DDA'.
        <fs_return>-type       = 'S'.
        <fs_return>-number     = '015'.
        <fs_return>-message_v1 = gs_key-belnr.
        <fs_return>-message_v2 = gs_key-bukrs.
        <fs_return>-message_v3 = gs_key-gjahr.

      ELSE.

        APPEND INITIAL LINE TO gt_return ASSIGNING <fs_return>.
        <fs_return>-id         = 'ZFI_SOLUCAO_DDA'.
        <fs_return>-type       = 'S'.
        <fs_return>-number     = '012'.
        <fs_return>-message_v1 = gs_key-belnr.
        <fs_return>-message_v2 = gs_key-bukrs.
        <fs_return>-message_v3 = gs_key-gjahr.

      ENDIF.

      gv_sucess = abap_true.

    ELSE.

      IF gs_dda-err_reason EQ 'A'.

        APPEND INITIAL LINE TO gt_return ASSIGNING <fs_return>.
        <fs_return>-id         = 'ZFI_SOLUCAO_DDA'.
        <fs_return>-type       = 'E'.
        <fs_return>-number     = '016'.

      ELSE.

        APPEND INITIAL LINE TO gt_return ASSIGNING <fs_return>.
        <fs_return>-id         = 'ZFI_SOLUCAO_DDA'.
        <fs_return>-type       = 'E'.
        <fs_return>-number     = '013'.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD end_message.

    APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_return1>).
    <fs_return1>-id         = 'ZFI_SOLUCAO_DDA'.
    <fs_return1>-type       = 'I'.
    <fs_return1>-number     = '014'.

  ENDMETHOD.


  METHOD fill_change_a.

    REFRESH: gt_change.
    CLEAR gv_sucess.

    DATA(lt_return) = gt_return.
    SORT lt_return BY id number.

    READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_ret>) WITH KEY id     = 'F5'
                                                                   number = '312'
                                                          BINARY SEARCH.

    IF sy-subrc = 0.

      gv_sucess = abap_true.

      gs_key-belnr = <fs_ret>-message_v1.
      gs_key-bukrs = <fs_ret>-message_v2.
      gs_key-gjahr = gs_input-gjahr.
      gs_key-buzei = '001'.

      APPEND INITIAL LINE TO gt_change ASSIGNING FIELD-SYMBOL(<fs_chg>).
      <fs_chg>-fdname = 'GLO_REF1'.
      <fs_chg>-newval = gs_input-barcode.

    ENDIF.

  ENDMETHOD.


  METHOD FILL_CHANGE_C.

    REFRESH: gt_change.

    gs_key-belnr = gs_input-belnr.
    gs_key-bukrs = gs_input-bukrs.
    gs_key-gjahr = gs_input-gjahr.
    gs_key-buzei = gs_input-buzei.

    APPEND INITIAL LINE TO gt_change ASSIGNING FIELD-SYMBOL(<fs_chg>).
    <fs_chg>-fdname = 'GLO_REF1'.
    <fs_chg>-newval = gs_input-barcode.

    APPEND INITIAL LINE TO gt_change ASSIGNING <fs_chg>.
    <fs_chg>-fdname = 'ZLSCH'.
    <fs_chg>-newval = gc_fixo-zlsch.

    APPEND INITIAL LINE TO gt_change ASSIGNING <fs_chg>.
    <fs_chg>-fdname = 'ZUONR'.
    <fs_chg>-newval = format_zuonr( gs_dda-due_date ).

  ENDMETHOD.


  METHOD fill_change_d.

    REFRESH: gt_change.

    gs_key-belnr = gs_input-belnr.
    gs_key-bukrs = gs_input-bukrs.
    gs_key-gjahr = gs_input-gjahr.
    gs_key-buzei = gs_input-buzei.

    APPEND INITIAL LINE TO gt_change ASSIGNING FIELD-SYMBOL(<fs_chg>).
    <fs_chg>-fdname = 'ZTERM'.
    <fs_chg>-newval = space.

    APPEND INITIAL LINE TO gt_change ASSIGNING <fs_chg>.
    <fs_chg>-fdname = 'GLO_REF1'.
    <fs_chg>-newval = gs_input-barcode.

    APPEND INITIAL LINE TO gt_change ASSIGNING <fs_chg>.
    <fs_chg>-fdname = 'ZBD1T'.
    <fs_chg>-newval = space.

    APPEND INITIAL LINE TO gt_change ASSIGNING <fs_chg>.
    <fs_chg>-fdname = 'ZFBDT'.
    <fs_chg>-newval = format_date( gs_dda-due_date ).

    APPEND INITIAL LINE TO gt_change ASSIGNING <fs_chg>.
    <fs_chg>-fdname = 'ZUONR'.
    <fs_chg>-newval = format_zuonr( gs_dda-due_date ).

    APPEND INITIAL LINE TO gt_change ASSIGNING <fs_chg>.
    <fs_chg>-fdname = 'ZLSCH'.
    <fs_chg>-newval = gc_fixo-zlsch.

  ENDMETHOD.


  METHOD fill_ftclear.

    DATA lv_key TYPE char17.

    lv_key = gs_bseg-belnr && gs_bseg-gjahr && gs_bseg-buzei.

    APPEND INITIAL LINE TO gt_ftclear ASSIGNING FIELD-SYMBOL(<fs_ftc>).

    <fs_ftc>-agkoa  = gc_fixo-agkoa.
    <fs_ftc>-agkon  = gs_input-lifnr.
    <fs_ftc>-agbuk  = gs_input-bukrs.
    <fs_ftc>-agums  = gc_fixo-agums.
    <fs_ftc>-xnops  = abap_true.
    <fs_ftc>-selfd  = gc_fixo-selfd.
    <fs_ftc>-selvon = lv_key.
    <fs_ftc>-selbis = lv_key.

  ENDMETHOD.


  METHOD fill_ftpost.

    DATA lv_diff TYPE bseg-wrbtr.

    DATA(lv_wrbtr) = format_amount( gs_dda-amount ).

    set_ftpost_value( iv_stype = 'K' iv_count = '001' iv_fnam = 'BKPF-BLDAT' iv_fval = CONV #( date_out( gs_bkpf-bldat ) ) ).
    set_ftpost_value( iv_stype = 'K' iv_count = '001' iv_fnam = 'BKPF-BUDAT' iv_fval = CONV #( date_out( gs_bkpf-budat ) ) ).
    set_ftpost_value( iv_stype = 'K' iv_count = '001' iv_fnam = 'BKPF-BLART' iv_fval = CONV #( gc_fixo-blart ) ).
    set_ftpost_value( iv_stype = 'K' iv_count = '001' iv_fnam = 'BKPF-BUKRS' iv_fval = CONV #( gs_bkpf-bukrs ) ).
    set_ftpost_value( iv_stype = 'K' iv_count = '001' iv_fnam = 'BKPF-WAERS' iv_fval = CONV #( gs_bkpf-waers ) ).
    set_ftpost_value( iv_stype = 'K' iv_count = '001' iv_fnam = 'BKPF-XBLNR' iv_fval = CONV #( gs_bkpf-xblnr ) ).
    set_ftpost_value( iv_stype = 'K' iv_count = '001' iv_fnam = 'BKPF-BKTXT' iv_fval = CONV #( gs_bkpf-bktxt ) ).

    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'RF05A-NEWBS' iv_fval = CONV #( gc_fixo-newbs ) ).

    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-HKONT' iv_fval = CONV #( gs_input-lifnr ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-WRBTR' iv_fval = align_left( lv_wrbtr ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-BUPLA' iv_fval = CONV #( gs_bseg-bupla ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-ZTERM' iv_fval = ' ' ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-ZBD1T' iv_fval = ' ' ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-ZLSPR' iv_fval = CONV #( gs_bseg-zlspr ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-SGTXT' iv_fval = CONV #( gs_bseg-sgtxt ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-ZUONR' iv_fval = CONV #( format_zuonr( gs_dda-due_date ) ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-ZFBDT' iv_fval = CONV #( date_out( format_date( gs_dda-due_date ) ) ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-ZLSCH' iv_fval = CONV #( gc_fixo-zlsch ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-HBKID' iv_fval = CONV #( gs_bseg-hbkid ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '001' iv_fnam = 'BSEG-HKTID' iv_fval = CONV #( gs_bseg-hktid ) ).

    IF gs_bseg-wrbtr > lv_wrbtr.
      set_ftpost_value( iv_stype = 'P' iv_count = '002' iv_fnam = 'RF05A-NEWBS' iv_fval = CONV #( gc_fixo-maior ) ).
    ELSE.
      set_ftpost_value( iv_stype = 'P' iv_count = '002' iv_fnam = 'RF05A-NEWBS' iv_fval = CONV #( gc_fixo-menor ) ).
    ENDIF.

    lv_diff = gs_bseg-wrbtr - lv_wrbtr.

    IF lv_diff < 0.
      MULTIPLY lv_diff BY -1.
    ENDIF.

    IF lv_diff > gs_conta-valor_tol.
      gv_erro = abap_true.

      APPEND INITIAL LINE TO gt_return ASSIGNING FIELD-SYMBOL(<fs_return>).
      <fs_return>-id         = 'ZFI_SOLUCAO_DDA'.
      <fs_return>-type       = 'E'.
      <fs_return>-number     = '021'.
      <fs_return>-message_v1 = gs_dda-doc_num.

    ENDIF.

    set_ftpost_value( iv_stype = 'P' iv_count = '002' iv_fnam = 'BSEG-HKONT' iv_fval = CONV #( gs_conta-conta_low ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '002' iv_fnam = 'BSEG-WRBTR' iv_fval = align_left( lv_diff ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '002' iv_fnam = 'BSEG-BUPLA' iv_fval = CONV #( gs_bseg-bupla ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '002' iv_fnam = 'BSEG-SGTXT' iv_fval = CONV #( gs_bseg-sgtxt ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '002' iv_fnam = 'BSEG-ZUONR' iv_fval = CONV #( format_zuonr( gs_dda-due_date ) ) ).
    set_ftpost_value( iv_stype = 'P' iv_count = '002' iv_fnam = 'COBL-KOSTL' iv_fval = CONV #( gs_conta-kostl ) ).

  ENDMETHOD.


  METHOD format_amount.

    rv_amount = iv_amount / 100.

  ENDMETHOD.


  method FORMAT_DATE.

    rv_date = iv_date+4(4) && iv_date+2(2) && iv_date(2).

  endmethod.


  METHOD format_zuonr.

    rv_zuonr = |DDA_{ iv_date(2) }.{ iv_date+2(2) }.{ iv_date+4(4) }|.

  ENDMETHOD.


  METHOD get_data.

    SELECT SINGLE
      bukrs, belnr, gjahr,
      bldat, budat, xblnr,
      bktxt, waers
      FROM bkpf
      INTO @gs_bkpf
      WHERE bukrs = @gs_input-bukrs
        AND belnr = @gs_input-belnr
        AND gjahr = @gs_input-gjahr.


    SELECT *
      FROM j1b_error_dda
      INTO @gs_dda
      UP TO 1 ROWS
      WHERE status_check = @gc_fixo-erro
        AND lifnr        = @gs_input-lifnr
        AND bukrs        = @gs_input-bukrs
        AND doc_num      = @gs_input-belnr
        AND gjahr        = @gs_input-gjahr.
    ENDSELECT.

    SELECT
      bukrs, belnr, gjahr,
      buzei, wrbtr, sgtxt,
      zlspr, hbkid, bupla, hktid
      FROM bseg
      INTO @gs_bseg
      UP TO 1 ROWS
      WHERE bukrs = @gs_input-bukrs
        AND belnr = @gs_input-belnr
        AND gjahr = @gs_input-gjahr
        AND koart = 'K'.
    ENDSELECT.

    SELECT SINGLE
      bukrs, valor_tol, conta_low ,kostl
      FROM ztfi_conta_dda
      INTO @gs_conta
      WHERE bukrs = @gs_input-bukrs.

    SELECT
      bukrs, gjahr, reference_no
      FROM ztfi_error_xblnr
      INTO @gs_error
      UP TO 1 ROWS
      WHERE bukrs        = @gs_dda-bukrs
        AND gjahr        = @gs_dda-gjahr
        AND reference_no = @gs_dda-reference_no.
    ENDSELECT.

  ENDMETHOD.


  METHOD post_clearing.

    DATA ls_mensagem TYPE bapiret2.

    CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
      EXPORTING
        i_auglv                    = gc_fixo-auglv
        i_tcode                    = gc_fixo-tcode
        i_sgfunct                  = gc_fixo-sgfunct
        i_no_auth                  = abap_true
      IMPORTING
        e_msgid                    = ls_mensagem-id
        e_msgno                    = ls_mensagem-number
        e_msgty                    = ls_mensagem-type
        e_msgv1                    = ls_mensagem-message_v1
        e_msgv2                    = ls_mensagem-message_v2
        e_msgv3                    = ls_mensagem-message_v3
        e_msgv4                    = ls_mensagem-message_v4
      TABLES
        t_blntab                   = gt_blntab
        t_ftclear                  = gt_ftclear
        t_ftpost                   = gt_ftpost
        t_fttax                    = gt_fttax
      EXCEPTIONS
        clearing_procedure_invalid = 1
        clearing_procedure_missing = 2
        table_t041a_empty          = 3
        transaction_code_invalid   = 4
        amount_format_error        = 5
        too_many_line_items        = 6
        company_code_invalid       = 7
        screen_not_found           = 8
        no_authorization           = 9
        OTHERS                     = 10.

    IF sy-subrc = 0.
      APPEND ls_mensagem TO gt_return.
    ENDIF.

  ENDMETHOD.


  METHOD post_start.

    CALL FUNCTION 'POSTING_INTERFACE_START'
      EXPORTING
        i_function         = gc_fixo-function
        i_mode             = gc_fixo-mode
        i_user             = sy-uname
      EXCEPTIONS
        client_incorrect   = 1
        function_invalid   = 2
        group_name_missing = 3
        mode_invalid       = 4
        update_invalid     = 5
        OTHERS             = 6.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

  ENDMETHOD.


  METHOD process.

    get_data( ).

    CASE gs_dda-err_reason.
      WHEN 'A'.

        fill_ftclear( ).
        fill_ftpost( ).

        IF gv_erro IS INITIAL.

          post_start( ).
          post_clearing( ).
          fill_change_a( ).
          doc_change( ).

          update_dda_table( ).

        ENDIF.

      WHEN 'C'.

        fill_change_c( ).
        doc_change( ).

        update_dda_table( ).

        bapi_commit( ).

      WHEN 'D'.

        fill_change_d( ).
        doc_change( ).

        update_dda_table( ).

        bapi_commit( ).

      WHEN 'V'.

        IF gs_error IS NOT INITIAL.

          fill_change_d( ).
          doc_change( ).

          update_dda_table( ).

          bapi_commit( ).

        ENDIF.

    ENDCASE.

    end_message( ).

    rt_return = gt_return.

  ENDMETHOD.


  METHOD set_ftpost_value.

    APPEND INITIAL LINE TO gt_ftpost ASSIGNING FIELD-SYMBOL(<fs_post>).

    <fs_post>-stype = iv_stype.
    <fs_post>-count = iv_count.
    <fs_post>-fnam  = iv_fnam .
    <fs_post>-fval  = iv_fval .

  ENDMETHOD.


  METHOD update_dda_table.

    IF gv_sucess IS NOT INITIAL.

      gs_dda_new = gs_dda.
      gs_dda_new-msg          = TEXT-m01.
      gs_dda_new-id           = icon_green_light.
      gs_dda_new-status_check = 'S'.
      gs_dda_new-reference_no = gs_input-xblnr.

      CLEAR gs_dda_new-err_reason.

      MODIFY j1b_error_dda FROM gs_dda_new.
      DELETE j1b_error_dda FROM gs_dda.

      IF gs_dda-err_reason EQ 'A'.

        gs_ddaerror_cp-belnr      = gs_input-belnr.
        gs_ddaerror_cp-bukrs      = gs_input-bukrs.
        gs_ddaerror_cp-gjahr      = gs_input-gjahr.
        gs_ddaerror_cp-doc_comp   = gs_key-belnr.
        gs_ddaerror_cp-created_by = sy-uname.

        MODIFY ztfi_ddaerror_cp FROM gs_ddaerror_cp.

      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
