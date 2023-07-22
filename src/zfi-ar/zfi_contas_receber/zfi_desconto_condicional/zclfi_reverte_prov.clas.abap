"! <p class="shorttext synchronized" lang="pt">Reversão da Provisão PDC</p>
CLASS zclfi_reverte_prov DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! Método Constructor
    "! Necessário informar BUKRS, BELNR, GJAHR e BLART
    METHODS constructor IMPORTING it_bukrs TYPE bukrs_ran_itab
                                  it_belnr TYPE belnr_ran_tab
                                  it_gjahr TYPE mmda_im_tty_gjahr
                                  it_blart TYPE fud_t_blart_range.

    "! Método para execução e processamento
    "! da Reversão da Provisão PDC
    METHODS main_process RETURNING VALUE(rt_return) TYPE bapiret2_tt.
  PROTECTED SECTION.


private section.

  types:
    BEGIN OF ty_bkpf,
        bukrs    TYPE bkpf-bukrs,
        belnr    TYPE bkpf-belnr,
        gjahr    TYPE bkpf-gjahr,
        buzei    TYPE bseg-buzei,
        awkey    TYPE bkpf-awkey,
        xref1_hd TYPE bkpf-xref1_hd,
        xref2_hd TYPE bkpf-xref2_hd,
        augbl    TYPE bseg-augbl,
        augdt    TYPE bseg-augdt,
      END OF  ty_bkpf .
  types:
    BEGIN OF ty_bkpf_bseg,
        bukrs    TYPE bkpf-bukrs,
        belnr    TYPE bkpf-belnr,
        gjahr    TYPE bkpf-gjahr,
        buzei    TYPE bseg-buzei,
        awkey    TYPE bkpf-awkey,
        xref1_hd TYPE bkpf-xref1_hd,
        xref2_hd TYPE bkpf-xref2_hd,
        xblnr    TYPE bkpf-xblnr,
        bktxt    TYPE bkpf-bktxt,

        augbl    TYPE bseg-augbl,
        augdt    TYPE bseg-augdt,
        dmbtr    TYPE bseg-dmbtr,
        werks    TYPE bseg-werks,
        zuonr    TYPE bseg-zuonr,
        sgtxt    TYPE bseg-sgtxt,
        bupla    TYPE bseg-bupla,
        kostl    TYPE bseg-kostl,
        gsber    TYPE bseg-gsber,
        prctr    TYPE bseg-prctr,
        segment  TYPE bseg-segment,
        kunnr    TYPE bseg-kunnr,
        xref1    TYPE bseg-xref1,
        zlsch    TYPE bseg-zlsch,
      END OF ty_bkpf_bseg .

  constants GC_MODULO type ZTCA_PARAM_PAR-MODULO value 'FI-AR' ##NO_TEXT.
  constants GC_CHAVE1 type ZTCA_PARAM_PAR-CHAVE1 value 'PDC' ##NO_TEXT.
  constants GC_CHAVE2 type ZTCA_PARAM_PAR-CHAVE2 value 'REVERSAO' ##NO_TEXT.
  constants GC_CHAVE2_B type ZTCA_PARAM_PAR-CHAVE2 value 'STATUSAGENDADO' ##NO_TEXT.
  constants GC_CHAVE2_C type ZTCA_PARAM_PAR-CHAVE2 value 'STATUSPROVISIONADO' ##NO_TEXT.
  constants GC_CHAVE3 type ZTCA_PARAM_PAR-CHAVE3 value 'CONCH50' ##NO_TEXT.
  constants GC_CHAVE3_B type ZTCA_PARAM_PAR-CHAVE3 value 'TIPODOC' ##NO_TEXT.
  constants GC_CURR type CHAR3 value 'BRL' ##NO_TEXT.
  constants GC_CHAVE_LANC_09 type CHAR2 value '09' ##NO_TEXT.
  constants GC_CODIGO_DEBITO_S type BSEG-SHKZG value 'S' ##NO_TEXT.
  data GV_HKONT type HKONT .
  data GV_DOC_TYPE type BLART .
  data:
    gr_blart01 TYPE RANGE OF blart .
  data:
    gr_blart02 TYPE RANGE OF blart .
  data:
    gr_belnr TYPE RANGE OF bkpf-belnr .
  data:
    gr_bukrs TYPE RANGE OF bkpf-bukrs .
  data:
    gr_gjahr TYPE RANGE OF bkpf-gjahr .
  data:
    gt_bkpf_bseg TYPE TABLE OF ty_bkpf_bseg .
  data:
    gt_bkpf      TYPE TABLE OF ty_bkpf .
  data GT_RETURN type BAPIRET2_TT .
  data GO_LOG type ref to ZCLCA_SAVE_LOG .
  constants GC_TCODE type SYTCODE value 'ZFIREVERSAO_PDC' ##NO_TEXT.
  constants GC_SUB type BALSUBOBJ value 'LOG_JOB' ##NO_TEXT.

    "! Método para seleção dos dados
    "!
  methods GET_DATA .
    "! Método para buscar documentos da BKPF
  methods GET_BKPF .
    "!Método para seleção de documento da BKPF e BSEG
  methods GET_BKPF_BSEG .
    "! Método para verificar se o pagamento já foi efetuado
  methods CHECK_PAYMENT .
    "! Método para execução da Reversão via BAPI
  methods EXEC_REVERT .
    "! Método para preenchimento do Header da BAPI
  methods FILL_HEADER
    importing
      !IS_BKPF type TY_BKPF_BSEG
    returning
      value(RS_HEADER) type BAPIACHE09 .
    "! Método para preenchimento do accountgl da BAPI
  methods FILL_ACCOUNTGL
    importing
      !IS_BKPF type TY_BKPF_BSEG
      !IV_ITEMNO_ACC type BAPIACGL09-ITEMNO_ACC
      !IV_GL_ACCOUNT type BAPIACGL09-GL_ACCOUNT
      !IV_STAT_CON type BAPIACGL09-STAT_CON
    returning
      value(RT_ACCOUNTGL) type BAPIACGL09_TAB .
    "! Método para preenchimento do accountreceivable da BAPI
  methods FILL_ACCOUNTRECEIVABLE
    importing
      !IS_BKPF type TY_BKPF_BSEG
      !IV_ITEMNO_ACC type BAPIACGL09-ITEMNO_ACC
      !IV_PMNT_BLOCK type BAPIACAR09-PMNT_BLOCK
      !IV_SP_GL_IND type BAPIACAR09-SP_GL_IND
    returning
      value(RT_ACCOUNTRECEIVABLE) type BAPIACAR09_TAB .
    "! Método para preenchimento do currencyamount da BAPI
  methods FILL_CURRENCYAMOUNT
    importing
      !IS_BKPF type TY_BKPF_BSEG
      !IV_ITEMNO_ACC type BAPIACGL09-ITEMNO_ACC
    returning
      value(RT_CURRENCYAMOUNT) type BAPIACCR09_TAB .
  methods FILL_EXTENSION2
    importing
      !IS_BKPF type TY_BKPF_BSEG
      !IV_ITEMNO_ACC type BAPIACGL09-ITEMNO_ACC
      !IV_DEB_CRED type CHAR1
    returning
      value(RT_EXTENSION2) type TT_BAPIPAREX .
  methods FILL_ACCOUNTPAYABLE
    importing
      !IS_BKPF type TY_BKPF_BSEG
      !IV_GL_ACCOUNT type BAPIACGL09-GL_ACCOUNT
      !IV_ITEMNO_ACC type BAPIACGL09-ITEMNO_ACC
    returning
      value(RT_ACCOUNTPAYABLE) type BAPIACAP09_TAB .
    "! Método busca de dados na tabela de parâmetro
  methods GET_PARAM .
ENDCLASS.



CLASS ZCLFI_REVERTE_PROV IMPLEMENTATION.


  METHOD constructor.

    gr_belnr = it_belnr.
    gr_bukrs = it_bukrs.
    gr_gjahr = it_gjahr.
    gr_blart01 = it_blart.

    go_log = NEW zclca_save_log( gc_tcode ).

    go_log->create_log( gc_sub ).

  ENDMETHOD.


  METHOD main_process.

    get_data(  ).
    exec_revert(  ).

    go_log->add_msgs( gt_return ).
    go_log->save( ).

    rt_return = gt_return.

  ENDMETHOD.


  METHOD get_data.

    get_param(  ).
    get_bkpf(  ).
    check_payment(  ).
    get_bkpf_bseg(  ).

  ENDMETHOD.


  METHOD get_bkpf.

    SELECT a~bukrs
           a~belnr
           a~gjahr
           b~buzei
           a~awkey
           a~xref1_hd
           a~xref2_hd
           b~augbl
           b~augdt
           FROM bkpf AS a
           INNER JOIN bseg AS b
              ON b~bukrs EQ a~bukrs
             AND b~belnr EQ a~belnr
             AND b~gjahr EQ a~gjahr
           INTO TABLE gt_bkpf
           WHERE a~bukrs IN gr_bukrs
             AND a~belnr IN gr_belnr
             AND a~gjahr IN gr_gjahr
             AND a~blart IN gr_blart01.

    SORT gt_bkpf BY bukrs
                    belnr
                    gjahr
                    buzei.

  ENDMETHOD.


  METHOD get_bkpf_bseg.

    DATA: lr_gjahr TYPE RANGE OF bkpf-gjahr,
          lr_belnr TYPE RANGE OF bkpf-belnr,
          lr_bukrs TYPE RANGE OF bkpf-bukrs.

    lr_gjahr = VALUE #(  FOR ls_bkpf IN gt_bkpf ( sign = 'I'
                                                 option = 'EQ'
                                                 low = ls_bkpf-gjahr ) ).

    LOOP AT gt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>).

      IF <fs_bkpf>-xref1_hd(1) NE 'R'.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_bkpf>-xref1_hd+14(4)   ) TO lr_gjahr.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_bkpf>-xref1_hd(10)  )    TO lr_belnr.
        APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_bkpf>-xref1_hd+10(4)  )  TO lr_bukrs.

      ENDIF.

    ENDLOOP.

    SORT : lr_gjahr BY low,
           lr_belnr BY low,
           lr_bukrs BY low.

    DELETE ADJACENT DUPLICATES FROM : lr_gjahr, lr_belnr, lr_bukrs COMPARING low.

    CHECK NOT lr_gjahr[]  IS INITIAL AND NOT lr_belnr[]  IS INITIAL AND NOT lr_bukrs[] IS INITIAL.

    SELECT a~bukrs
           a~belnr
           a~gjahr
           b~buzei
           a~awkey
           a~xref1_hd
           a~xref2_hd
           a~xblnr
           a~bktxt

           b~augbl
           b~augdt
           b~dmbtr
           b~werks
           b~zuonr
           b~sgtxt
           b~bupla
           b~kostl
           b~gsber
           b~prctr
           b~segment
           b~kunnr
           b~xref1
           b~zlsch
           FROM bkpf AS a
           INNER JOIN bseg AS b
              ON b~bukrs EQ a~bukrs
             AND b~belnr EQ a~belnr
             AND b~gjahr EQ a~gjahr
           INTO TABLE gt_bkpf_bseg
           WHERE a~bukrs IN lr_bukrs
             AND a~belnr IN lr_belnr
             AND a~gjahr IN lr_gjahr
             AND a~blart IN gr_blart02.

    IF sy-subrc EQ 0.

      SORT gt_bkpf_bseg BY bukrs
                     belnr
                     gjahr
                     buzei.

    ELSE.

      gt_return = VALUE #( ( type       = 'E'
                             id         = 'ZFI_DESCONTO_COND'
                             number     = 009
                             message_v1 = <fs_bkpf>-belnr  ) ).

    ENDIF.

  ENDMETHOD.


  METHOD check_payment.

    DATA(lo_verif_pag) = NEW zclfi_verificar_pag_efetuado(  ).

    DATA lt_bkpf_new TYPE TABLE OF ty_bkpf_bseg.

    DATA(lt_bkpf_aux) = gt_bkpf.
    SORT lt_bkpf_aux BY augbl.

    DELETE lt_bkpf_aux WHERE augbl IS INITIAL.

    SORT lt_bkpf_aux BY belnr gjahr bukrs.

    LOOP AT lt_bkpf_aux ASSIGNING FIELD-SYMBOL(<fs_bkpf>).

      IF <fs_bkpf>-augdt IS NOT INITIAL
      AND <fs_bkpf>-augbl IS NOT INITIAL.

        DATA(lv_pag_efetuado) = lo_verif_pag->verifica( iv_bukrs = <fs_bkpf>-bukrs
                                                        iv_belnr = <fs_bkpf>-belnr
                                                        iv_gjahr = <fs_bkpf>-gjahr ).

        IF lv_pag_efetuado IS NOT INITIAL.

          LOOP AT gt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf_append>) FROM line_index( gt_bkpf[ bukrs = <fs_bkpf>-bukrs
                                                                                             belnr = <fs_bkpf>-belnr
                                                                                             gjahr = <fs_bkpf>-gjahr ] ).
            IF <fs_bkpf_append>-bukrs NE <fs_bkpf>-bukrs
            OR <fs_bkpf_append>-belnr NE <fs_bkpf>-belnr
            OR <fs_bkpf_append>-gjahr NE <fs_bkpf>-gjahr.
              EXIT.
            ENDIF.

            APPEND <fs_bkpf_append> TO lt_bkpf_new.

          ENDLOOP.

        ENDIF.

      ENDIF.

    ENDLOOP.

    gt_bkpf = lt_bkpf_new.

  ENDMETHOD.


  METHOD exec_revert.

    CONSTANTS : lc_error TYPE c VALUE 'E'.

    DATA: lt_accountgl         TYPE bapiacgl09_tab,
          lt_accountreceivable TYPE bapiacar09_tab,
          lt_currencyamount    TYPE bapiaccr09_tab,
          lt_return            TYPE TABLE OF bapiret2,
          lt_acc               TYPE TABLE OF accchg,
          lt_extension2        TYPE TABLE OF bapiparex.

    DATA: lv_obj_type     TYPE bapiache09-obj_type,
          lv_obj_key      TYPE bapiache09-obj_key,
          lv_obj_sys      TYPE bapiache09-obj_sys,
          lv_belnr        TYPE bkpf-belnr,

          lv_bukrs_change TYPE  bukrs,
          lv_belnr_change TYPE  belnr_d,
          lv_gjahr_change TYPE  gjahr,
          lv_buzei_change TYPE  bseg-buzei,
          lv_itemno_acc   TYPE bapiacgl09-itemno_acc.

    DATA(lv_lines) = lines( gt_bkpf_bseg ).
*    BREAK dpina.
    LOOP AT gt_bkpf_bseg ASSIGNING FIELD-SYMBOL(<fs_bkpf_bseg>).

      DATA(lv_tabix) = sy-tabix.

      IF lv_belnr IS INITIAL
       OR lv_belnr NE <fs_bkpf_bseg>-belnr.

        DATA(ls_header) = fill_header( <fs_bkpf_bseg> ).

        lv_belnr = <fs_bkpf_bseg>-belnr.
        lv_itemno_acc = 1.

      ELSE.

        ADD 1 TO lv_itemno_acc.

      ENDIF.

      IF <fs_bkpf_bseg>-kunnr IS INITIAL.



*        DATA(lt_accountgl_aux) = fill_accountgl( is_bkpf = <fs_bkpf_bseg>
*                                                 iv_gl_account = gv_hkont
*                                                 iv_itemno_acc = lv_itemno_acc
*                                                 iv_stat_con = space "CONV #( '50' )
*                                                ).

        DATA(lt_accountpayable) = fill_accountpayable( is_bkpf = <fs_bkpf_bseg>
                                                       iv_gl_account = gv_hkont
                                                       iv_itemno_acc = lv_itemno_acc ).

*        DATA(lt_accountreceivable_aux) = fill_accountreceivable( is_bkpf = <fs_bkpf_bseg>
*                                                                 iv_itemno_acc =  CONV #( <fs_bkpf_bseg>-buzei )
*                                                                 iv_pmnt_block = space
*                                                                 iv_sp_gl_ind = space ).


        DATA(lt_currencyamount_aux) = fill_currencyamount( is_bkpf = <fs_bkpf_bseg>
                                                            iv_itemno_acc =  lv_itemno_acc ) .

        DATA(lt_extension2_aux) = fill_extension2( is_bkpf = <fs_bkpf_bseg>
                                                   iv_deb_cred = space
                                                   iv_itemno_acc =  lv_itemno_acc ).

      ENDIF.

      IF <fs_bkpf_bseg>-kunnr IS NOT INITIAL.

*        lt_accountgl_aux = fill_accountgl( is_bkpf = <fs_bkpf_bseg>
*                                           iv_gl_account = space
*                                           iv_itemno_acc =  CONV #( <fs_bkpf_bseg>-buzei )
*                                           iv_stat_con = space "CONV #( '09' )
*                                         ).

        DATA(lt_accountreceivable_aux) = fill_accountreceivable( is_bkpf = <fs_bkpf_bseg>
                                                           iv_itemno_acc =  lv_itemno_acc
                                                           iv_pmnt_block = 'A'
                                                           iv_sp_gl_ind  = 'C'
                                                         ).

        lt_currencyamount_aux = fill_currencyamount( is_bkpf = <fs_bkpf_bseg>
                                                     iv_itemno_acc =   lv_itemno_acc ) .



        lt_extension2_aux = fill_extension2( is_bkpf = <fs_bkpf_bseg>
                                             iv_deb_cred = gc_codigo_debito_s
                                             iv_itemno_acc =  lv_itemno_acc ).

      ENDIF.

*      IF lt_accountgl_aux IS NOT INITIAL.
*        APPEND LINES OF lt_accountgl_aux TO lt_accountgl.
*      ENDIF.

      IF lt_accountreceivable_aux IS NOT INITIAL.
        APPEND LINES OF lt_accountreceivable_aux TO lt_accountreceivable.
      ENDIF.

      IF lt_currencyamount_aux IS NOT INITIAL.
        APPEND LINES OF lt_currencyamount_aux TO lt_currencyamount.
      ENDIF.

      IF lt_extension2_aux  IS NOT INITIAL .
        APPEND LINES OF lt_extension2_aux  TO lt_extension2 .
      ENDIF.

      CLEAR: "lt_accountgl_aux,
             lt_accountreceivable_aux,
             lt_currencyamount_aux,
             lt_extension2_aux .

      DATA(lv_next) = lv_tabix + 1.

      IF lv_lines EQ lv_tabix "If Last line
        OR gt_bkpf_bseg[ lv_next ]-belnr NE lv_belnr. "If next line is a different DOC

*        BREAK dpina.
        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
          EXPORTING
            documentheader    = ls_header
*           customercpd       =
*           contractheader    =
          IMPORTING
            obj_type          = lv_obj_type
            obj_key           = lv_obj_key
            obj_sys           = lv_obj_sys
          TABLES
*           accountgl         = lt_accountgl
            accountreceivable = lt_accountreceivable
            accountpayable    = lt_accountpayable
*           accounttax        =
            currencyamount    = lt_currencyamount
*           criteria          =
*           valuefield        =
*           extension1        =
            return            = lt_return
*           paymentcard       =
*           contractitem      =
            extension2        = lt_extension2
*           realestate        =
*           accountwt         =
          .


        IF lv_obj_key IS NOT INITIAL
        AND lv_obj_key NE '$'.

          TRY.
              DATA(ls_data) = gt_bkpf[ xref1_hd = <fs_bkpf_bseg>-awkey ].

              lv_bukrs_change = ls_data-bukrs.
              lv_belnr_change = ls_data-belnr.
              lv_gjahr_change = ls_data-gjahr.
              lv_buzei_change = ls_data-buzei.

              APPEND VALUE #( fdname = 'XREF1_HD'
                              oldval = ls_data-xref1_hd
                              newval = |R{ ls_data-xref1_hd }| ) TO lt_acc.


              CALL FUNCTION 'FI_DOCUMENT_CHANGE'
                EXPORTING
                  i_buzei              = lv_buzei_change
                  i_bukrs              = lv_bukrs_change
                  i_belnr              = lv_belnr_change
                  i_gjahr              = lv_gjahr_change
                TABLES
                  t_accchg             = lt_acc
                EXCEPTIONS
                  no_reference         = 1
                  no_document          = 2
                  many_documents       = 3
                  wrong_input          = 4
                  overwrite_creditcard = 5
                  OTHERS               = 6.

              IF sy-subrc <> 0.
                RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
              ENDIF.

            CATCH cx_sy_itab_line_not_found.
          ENDTRY.


          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

*      gt_return = VALUE #( ( type       = 'I'
*                             id         = 'ZFI_DESCONTO_COND'
*                             number     = 009
*                             message_v1 = ''  ) ).

          APPEND VALUE #( type    = 'S'
                          id      = 'ZFI_DESCONTO_COND'
                          number  = 010
                          message_v1 = lv_obj_key(10)
                          message_v2 = lv_obj_key+10(4)
                          message_v3 = lv_obj_key+14(4) ) TO gt_return.

        ELSE.

          LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_error>).
            IF <fs_error>-type EQ lc_error.
              <fs_error>-message_v4 = <fs_bkpf_bseg>-awkey.

              APPEND <fs_error> TO gt_return.
            ENDIF.
          ENDLOOP.

*          READ TABLE gt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>) WITH KEY xref1_hd = <fs_bkpf_bseg>-awkey.
          IF line_exists( gt_bkpf[ xref1_hd = <fs_bkpf_bseg>-awkey ] ).

*            IF <fs_bkpf> IS ASSIGNED.

            APPEND VALUE #( type       = 'E'
                            id         = 'ZFI_DESCONTO_COND'
                            number     = 011
                            message_v1 = gt_bkpf[ xref1_hd = <fs_bkpf_bseg>-awkey ]-belnr ) TO gt_return.
*                            message_v1 = <fs_bkpf>-belnr ) TO gt_return.

          ENDIF.

        ENDIF.

        CLEAR: ls_header,

               lv_obj_type,
               lv_obj_key,
               lv_obj_sys,
               lv_bukrs_change,
               lv_belnr_change,
               lv_gjahr_change,
               lv_buzei_change,
               lt_accountgl,
               lt_currencyamount,
               lt_return,
               lt_acc.


      ENDIF.

    ENDLOOP.

    IF gt_return[] IS INITIAL.
      gt_return = VALUE #( ( type   = 'I'
                             id     = 'ZFI_DESCONTO_COND'
                             number = 008 ) ).
    ENDIF.

  ENDMETHOD.


  METHOD fill_header.


    rs_header-pstng_date = sy-datum.
    rs_header-doc_date   = sy-datum.
    rs_header-username   = sy-uname.
    rs_header-fis_period = sy-datum+5(1).
*    rs_header-pymt_cur_iso = lc_curr.
    rs_header-doc_type = gv_doc_type.
    rs_header-comp_code = is_bkpf-bukrs.
    rs_header-ref_doc_no = is_bkpf-xblnr.
    rs_header-header_txt = is_bkpf-bktxt.
*    rs_header-xref2_hd = is_bkpf-xref2_hd.







  ENDMETHOD.


  METHOD fill_accountgl.


    APPEND VALUE #(
                    itemno_acc = iv_itemno_acc
*                    stat_con   = iv_stat_con
                    gl_account = iv_gl_account
*                    customer   = is_bkpf-kunnr
*                    ref_key_1  = is_bkpf-xref1
                    bus_area   = is_bkpf-gsber
*                    ac_doc_no  = is_bkpf-zuonr
                    item_text  = is_bkpf-sgtxt
*                    profit_ctr = is_bkpf-prctr
                    costcenter = is_bkpf-kostl
                    segment    =  is_bkpf-segment
*                    FB_SEGMENT = is_bkpf-segment < not ex

     ) TO rt_accountgl.


  ENDMETHOD.


  METHOD fill_accountreceivable.

    APPEND VALUE #( itemno_acc = iv_itemno_acc
                    customer   = is_bkpf-kunnr
                    bus_area   = is_bkpf-gsber
                    paymt_ref  = is_bkpf-belnr
                    alloc_nmbr = is_bkpf-zuonr
                    pymt_meth  = is_bkpf-zlsch
                    pmnt_block = iv_pmnt_block
                    sp_gl_ind = iv_sp_gl_ind
                    item_text = is_bkpf-sgtxt
                    profit_ctr  = is_bkpf-prctr

                  ) TO rt_accountreceivable.

  ENDMETHOD.


  METHOD fill_currencyamount.

    DATA: lv_dmbtr TYPE dmbrt.

    IF iv_itemno_acc EQ 1.
      lv_dmbtr = is_bkpf-dmbtr.
    ELSE.
      lv_dmbtr = is_bkpf-dmbtr * -1.
    ENDIF.

    APPEND VALUE #( itemno_acc = iv_itemno_acc
                    currency   = gc_curr
                    currency_iso =  gc_curr
                    amt_doccur = lv_dmbtr  ) TO rt_currencyamount.

  ENDMETHOD.


  METHOD get_param.

    DATA: lr_conta  TYPE RANGE OF hkont,
          lr_tp_doc TYPE RANGE OF blart.

    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
                                         iv_chave1 = me->gc_chave1
                                         iv_chave2 = me->gc_chave2
                                         iv_chave3 = me->gc_chave3
                               IMPORTING et_range  = lr_conta ).

        TRY.
            gv_hkont = lr_conta[ 1 ]-low.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

      CATCH zcxca_tabela_parametros.
    ENDTRY.

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
                                         iv_chave1 = me->gc_chave1
                                         iv_chave2 = me->gc_chave2
                                         iv_chave3 = me->gc_chave3_b
                               IMPORTING et_range  = lr_tp_doc ).

        TRY.
            gv_doc_type = lr_tp_doc[ 1 ]-low.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

      CATCH zcxca_tabela_parametros.
    ENDTRY.

*    TRY.
*        CLEAR lr_tp_doc.
*        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
*                                         iv_chave1 = me->gc_chave1
*                                         iv_chave2 = me->gc_chave2_b
*                                         iv_chave3 = me->gc_chave3_b
*                               IMPORTING et_range  = lr_tp_doc ).
*
*        IF lr_tp_doc IS NOT INITIAL.
*          gr_blart01 = lr_tp_doc.
*        ENDIF.
*
*      CATCH zcxca_tabela_parametros.
*    ENDTRY.

    TRY.
        CLEAR lr_tp_doc.
        lo_param->m_get_range( EXPORTING iv_modulo = me->gc_modulo
                                         iv_chave1 = me->gc_chave1
                                         iv_chave2 = me->gc_chave2_c
                                         iv_chave3 = me->gc_chave3_b
                               IMPORTING et_range  = lr_tp_doc ).

        IF lr_tp_doc IS NOT INITIAL.
          gr_blart02 = lr_tp_doc.
        ENDIF.

      CATCH zcxca_tabela_parametros.
    ENDTRY.

  ENDMETHOD.


  METHOD fill_accountpayable.


    APPEND VALUE #( itemno_acc   = iv_itemno_acc
                    gl_account   = iv_gl_account
                    alloc_nmbr   = is_bkpf-zuonr
                    item_text    = is_bkpf-sgtxt
                    bus_area     = is_bkpf-gsber
                    profit_ctr   =  is_bkpf-prctr ) TO rt_accountpayable  .

  ENDMETHOD.


  METHOD fill_extension2.



*    lt_extension2[]         = VALUE #( BASE lt_extension2 (
*                                       structure  = 'BUPLA'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = is_reversao-BusinessPlace )
*                                       (
*                                       structure  = 'BSCHL'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = gc_bapi_contabil-chave_lanc_09 )
*                                       (
*                                       structure  = 'SHKZG'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = gc_bapi_contabil-codigo_debito_s )
*                                       (
*                                       structure  = 'XREF1_HD'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = is_reversao-Reference1InDocumentHeader )
*                                       (
*                                       structure  = 'XREF2_HD'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = is_reversao-Reference2InDocumentHeader )
*                                       (
*                                       structure  = 'XREF1'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = is_reversao-Reference1IDByBusinessPartner )
*                                       (
*                                       structure  = 'XREF2'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = gc_bapi_contabil-app )
*                                       (
*                                       structure  = 'XREF3'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = |{ is_reversao-AccountingDocument }-{ is_reversao-FiscalYear }-{ is_reversao-AccountingDocumentItem  }| ) ).

*    APPEND VALUE #( structure  = 'BUPLA'
*                    valuepart1 = iv_itemno_acc
*                    valuepart2 = is_reversao-businessplace  ) TO  rt_extension2 .

    IF iv_deb_cred EQ gc_codigo_debito_s.

      APPEND VALUE #( structure  = 'BSCHL'
                      valuepart1 = iv_itemno_acc
                      valuepart2 = gc_chave_lanc_09  ) TO  rt_extension2 .

      APPEND VALUE #( structure  = 'SHKZG'
                      valuepart1 = iv_itemno_acc
                      valuepart2 = iv_deb_cred ) TO  rt_extension2 .


      APPEND VALUE #( structure  = 'XREF1'
                      valuepart1 = iv_itemno_acc
                      valuepart2 = is_bkpf-xref1  ) TO  rt_extension2 .

      APPEND VALUE #( structure  = 'XREF2_HD'
                      valuepart1 = iv_itemno_acc
                      valuepart2 = is_bkpf-xref2_hd  ) TO  rt_extension2 .

    ELSE.

      APPEND VALUE #( structure  = 'BUPLA'
                      valuepart1 = iv_itemno_acc
                      valuepart2 = is_bkpf-bupla ) TO  rt_extension2 .


      APPEND VALUE #( structure  = 'WERKS'
                valuepart1 = iv_itemno_acc
                valuepart2 = is_bkpf-werks ) TO  rt_extension2 .


      APPEND VALUE #( structure  = 'KOSTL'
          valuepart1 = iv_itemno_acc
          valuepart2 = is_bkpf-kostl ) TO  rt_extension2 .

      APPEND VALUE #( structure  = 'SEGMENT'
    valuepart1 = iv_itemno_acc
    valuepart2 = is_bkpf-segment ) TO  rt_extension2 .


*          lt_extension2[]         = VALUE #( BASE lt_extension2 (
*                                       structure  = 'BUPLA'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = ls_reversao_50-BusinessPlace )
*                                       (
*                                       structure  = 'WERKS'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = ls_reversao_50-Plant )
*                                       (
*                                       structure  = 'KOSTL'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = ls_reversao_50-CostCenter )
*                                       (
*                                       structure  = 'SEGMENT'
*                                       valuepart1 = lv_itemno
*                                       valuepart2 = ls_reversao_50-Segment ) ).


    ENDIF.


  ENDMETHOD.
ENDCLASS.
