CLASS zclfi_totvs_doc_pagar DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS gc_status_sucesso TYPE ze_fi_status VALUE 'S' ##NO_TEXT.
    CONSTANTS gc_status_erro TYPE ze_fi_status VALUE 'E' ##NO_TEXT.

    METHODS processa_interface_doc_pagar
      IMPORTING
        !is_input TYPE zmt_dados_contas_pagar_rh
      RAISING
        zcxfi_totvs_doc_pagar .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gs_dados TYPE zmt_dados_contas_pagar_rh .
    DATA gv_seqlog TYPE ze_fi_identify .
    DATA:
      gt_log TYPE STANDARD TABLE OF ztfi_totvs_log .
    CONSTANTS gc_party TYPE party VALUE 'J_1BCG' ##NO_TEXT.
    CONSTANTS gc_kokrs TYPE kokrs VALUE 'AC3C' ##NO_TEXT.
    DATA gv_bukrs TYPE bukrs .
    DATA gv_branch TYPE j_1bbranc_ .
    DATA gt_erro TYPE bapiret2_tab .

    METHODS add_log
      IMPORTING
        !iv_type TYPE bapi_mtype
        !iv_msg  TYPE bapi_msg .
    METHODS call_bapi
      RAISING
        zcxfi_totvs_doc_pagar .
    METHODS check_data
      EXPORTING ev_return TYPE abap_bool
      RAISING
                zcxfi_totvs_doc_pagar .
    METHODS get_div_centro_lucro
      IMPORTING
        iv_centro_custo TYPE kostl
      EXPORTING
        ev_divisao      TYPE gsber
        ev_centro_lucro TYPE prctr
        ev_segmento     TYPE fb_segment.
    METHODS save_log
      IMPORTING iv_type TYPE bapi_mtype DEFAULT gc_status_sucesso
      RAISING
                zcxfi_totvs_doc_pagar .
ENDCLASS.



CLASS ZCLFI_TOTVS_DOC_PAGAR IMPLEMENTATION.


  METHOD add_log.

    DATA: lv_seq TYPE c LENGTH 10.

*    IF gv_seqlog IS INITIAL.
*
*      SELECT
**        ( MAX( identificacao ) + 1 ) AS id
*      SINGLE  identificacao
*      FROM ztfi_totvs_log
*      INTO gv_seqlog.
*
*      IF sy-subrc = 0.
*        gv_seqlog = gv_seqlog + 1.
*      ELSE.
*        gv_seqlog = '1'.
*      ENDIF.
*
*    ELSE.
*      gv_seqlog = gv_seqlog + 1.
*    ENDIF.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '01'
        object                  = 'ZMOVCAPRM'
      IMPORTING
        number                  = lv_seq
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.

    IF sy-subrc = 0.
      APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<fs_log>).
      <fs_log>-identificacao = lv_seq.
      <fs_log>-status        = iv_type. "gc_status_erro.
      <fs_log>-data          = sy-datum.
      <fs_log>-hora          = sy-uzeit.
      <fs_log>-mensagem      = iv_msg.
      <fs_log>-created_by    = sy-uname.
    ENDIF.

  ENDMETHOD.


  METHOD call_bapi.

    CONSTANTS:
      BEGIN OF lc_msg_doc_lancado,
        msgty TYPE bapiret2-type VALUE 'S',
        msgid TYPE bapiret2-id VALUE 'RW',
        msgno TYPE bapiret2-number VALUE  '605',
      END OF lc_msg_doc_lancado,

      BEGIN OF lc_erro_documento,
        msgty TYPE bapiret2-type VALUE 'E',
        msgid TYPE bapiret2-id VALUE 'RW',
        msgno TYPE bapiret2-number VALUE  '609',
      END OF lc_erro_documento.

    TYPES: BEGIN OF ty_key,
             belnr TYPE belnr_d,
             bukrs TYPE bukrs,
             gjahr TYPE gjahr,
           END OF ty_key.

    DATA: ls_header     TYPE bapiache09,
          lt_return     TYPE STANDARD TABLE OF bapiret2,
          lt_payable    TYPE STANDARD TABLE OF bapiacap09,
          lt_ammount    TYPE STANDARD TABLE OF bapiaccr09,
          lt_ACCOUNTGL  TYPE STANDARD TABLE OF bapiacgl09,
          lv_key        TYPE awkey,
          lv_item       TYPE i,
          ls_key        TYPE ty_key,
          lt_totvs      TYPE STANDARD TABLE OF ztfi_tovts_pagar,
          lv_msg        TYPE bapi_msg,
          lr_KOSTL      TYPE RANGE OF kostl,
          lt_extension2 TYPE bapiapoparex_tab,
          lv_fon_x_part TYPE abap_bool,
          lv_vlrposit   TYPE abap_bool,
          lr_cnpj       TYPE RANGE OF stcd1,
          lr_cpf        TYPE RANGE OF stcd2.

    CONSTANTS: lc_kokrs TYPE kokrs VALUE 'AC3C'.

    ls_header-username   = sy-uname.
    ls_header-comp_code  = gv_bukrs.
    ls_header-doc_date   = gs_dados-mt_dados_contas_pagar_rh-bldat."gs_dados-mt_dados_contas_pagar_rh-list-bldat.
    ls_header-pstng_date = gs_dados-mt_dados_contas_pagar_rh-budat.

*    ls_header-fisc_year  = gs_dados-mt_dados_contas_pagar_rh-bldat(4).
*    ls_header-fis_period = gs_dados-mt_dados_contas_pagar_rh-bldat+4(2).
    ls_header-doc_type   = gs_dados-mt_dados_contas_pagar_rh-blart.
    ls_header-header_txt = gs_dados-mt_dados_contas_pagar_rh-bktxt.
    ls_header-ref_doc_no = gs_dados-mt_dados_contas_pagar_rh-xblnr.

    lr_KOSTL = VALUE #( FOR ls_SAKNR IN gs_dados-mt_dados_contas_pagar_rh-accountgl
                           LET lv_sign   = 'I'
                               lv_option = 'EQ'
                           IN  sign      = lv_sign
                               option    = lv_option
                         ( low = ls_saknr-kostl ) ).


    IF lr_KOSTL IS NOT INITIAL.

      SELECT
        a~bukrs,
        a~kostl,
        a~gsber, "divisao
        a~prctr, "centro de lucro
        b~segment,
        c~bupla,
        c~zmatriz
      FROM csks AS a INNER JOIN cepc AS b
      ON
        b~prctr = a~prctr
        AND b~kokrs = @lc_kokrs
      INNER JOIN ztfi_param_rm AS c                    "#EC CI_BUFFJOIN
      ON
        c~bukrs = a~bukrs
        AND c~gsber = a~gsber
      WHERE
        a~bukrs = @gv_bukrs "@gs_dados-mt_dados_contas_pagar_rh-burks
        AND a~kostl IN @lr_KOSTL
        AND a~kokrs = @lc_kokrs
     INTO TABLE @DATA(lt_bupla).

      IF sy-subrc = 0.
        SORT lt_bupla BY bukrs zmatriz kostl.
      ENDIF.

    ENDIF.


    IF gs_dados-mt_dados_contas_pagar_rh-accountpayable IS NOT INITIAL.

      LOOP AT gs_dados-mt_dados_contas_pagar_rh-accountpayable ASSIGNING FIELD-SYMBOL(<fs_pay>).

        APPEND INITIAL LINE TO lr_cnpj ASSIGNING FIELD-SYMBOL(<fs_cnpj>).
        <fs_cnpj>-sign   = 'I'.
        <fs_cnpj>-option = 'EQ'.
        <fs_cnpj>-low   = <fs_pay>-lifnr.

        APPEND INITIAL LINE TO lr_cpf ASSIGNING FIELD-SYMBOL(<fs_cpf>).
        <fs_cpf>-sign   = 'I'.
        <fs_cpf>-option = 'EQ'.
        <fs_cpf>-low   = <fs_pay>-lifnr.
      ENDLOOP.

      IF lr_cnpj IS NOT INITIAL OR lr_cpf IS NOT INITIAL.
        SELECT
          CASE WHEN stcd1 = @space THEN stcd2 ELSE stcd1 END AS doc,
*          stcd2,
          lifnr
        FROM lfa1
        WHERE stcd1      IN @lr_cnpj
              OR stcd2   IN @lr_cpf
        INTO TABLE @DATA(lt_fornece).

        IF sy-subrc = 0.
          SORT lt_fornece BY doc.
        ENDIF.

      ENDIF.

    ENDIF.



*    SELECT
*      SINGLE xblnr
*    FROM
*      ztfi_tovts_event
*    WHERE
*      codtdo = @gs_dados-mt_dados_contas_pagar_rh-xblnr "@gs_dados-mt_dados_contas_pagar_rh-list-xblnr
*    INTO @ls_header-ref_doc_no.

*    ls_header-ref_doc_no = gs_dados-mt_dados_contas_pagar_rh-xblnr.

    lv_item = 1.

    IF lines(  gs_dados-mt_dados_contas_pagar_rh-accountgl ) = 1 AND lines( gs_dados-mt_dados_contas_pagar_rh-accountpayable ) = 1.
      lv_fon_x_part = abap_true.
    ENDIF.

    LOOP AT  gs_dados-mt_dados_contas_pagar_rh-accountpayable ASSIGNING <fs_pay>.

      APPEND INITIAL LINE TO lt_payable ASSIGNING FIELD-SYMBOL(<fs_playable>).
      <fs_playable>-itemno_acc = lv_item.

      <fs_playable>-pmnt_block = 'A'.

      UNPACK <fs_playable>-itemno_acc TO <fs_playable>-itemno_acc.

      IF lt_fornece IS NOT INITIAL .
        IF lines( gs_dados-mt_dados_contas_pagar_rh-accountpayable ) = 1.
          <fs_playable>-vendor_no = lt_fornece[ 1 ]-lifnr.
        ENDIF.
      ELSE.
        READ TABLE lt_fornece
        WITH KEY doc = <fs_pay>-lifnr
        BINARY SEARCH ASSIGNING FIELD-SYMBOL(<fs_fornece>).

        IF sy-subrc = 0.
          <fs_playable>-vendor_no = <fs_fornece>-lifnr.
        ENDIF.
      ENDIF.

*      <fs_playable>-vendor_no  = is_data-lifnr.

*      SELECT SINGLE saknr FROM skb1
*      WHERE bukrs     = @gv_bukrs
*            AND saknr = @is_data-hkont
*      INTO @DATA(lv_conta).

*      <fs_playable>-gl_account = lv_conta.

      IF lv_fon_x_part = abap_true .
        IF lt_bupla IS NOT INITIAL.
          <fs_playable>-businessplace = lt_bupla[ 1 ]-bupla.
        ENDIF.

      ELSE.

        READ TABLE lt_bupla
        WITH KEY bukrs = gv_bukrs "gs_dados-mt_dados_contas_pagar_rh-burks
                 zmatriz = abap_true
        BINARY SEARCH ASSIGNING FIELD-SYMBOL(<fs_bupla>).
        IF sy-subrc = 0.
          <fs_playable>-businessplace = <fs_bupla>-bupla.
        ENDIF.

      ENDIF.

      <fs_playable>-comp_code  = gv_bukrs.
*      <fs_playable>-bus_area   = <fs_playable>-businessplace.

      <fs_playable>-item_text  = <fs_pay>-sgtxt.
      <fs_playable>-profit_ctr = ''.

      <fs_playable>-bline_date = <fs_pay>-zfbdt. "data de vencimento

      APPEND INITIAL LINE TO lt_ammount ASSIGNING FIELD-SYMBOL(<fs_ammount>).

*      IF <fs_playable> IS ASSIGNED.
      <fs_ammount>-itemno_acc   = <fs_playable>-itemno_acc.
*      ENDIF.

      <fs_ammount>-currency_iso = gs_dados-mt_dados_contas_pagar_rh-waers.
*      <fs_ammount>-currency = gs_dados-mt_dados_contas_pagar_rh-waers.

*      <fs_ammount>-currency = CONV WAERS( <fs_pay>-amt_doccur ).
*      <fs_ammount>-currency = lv_valor.

      IF <fs_pay>-shkzg = 'S'. "debito - > positivo
        lv_vlrposit = abap_false.

        IF <fs_pay>-amt_doccur >= 0.
          <fs_ammount>-amt_doccur = <fs_pay>-amt_doccur.
        ELSE.
          <fs_ammount>-amt_doccur = ( <fs_pay>-amt_doccur * ( -1 ) ).
        ENDIF.

      ELSEIF <fs_pay>-shkzg = 'H'. "negativo
        lv_vlrposit = abap_true.

        IF <fs_pay>-amt_doccur <= 0.
          <fs_ammount>-amt_doccur = <fs_pay>-amt_doccur.
        ELSE.
          <fs_ammount>-amt_doccur = ( <fs_pay>-amt_doccur * ( -1 ) ).
        ENDIF.

      ENDIF.
*      <fs_ammount>-amt_doccur   = <fs_ammount>-currency.

      lv_item = lv_item + 1.
    ENDLOOP.

*    PROFIT_CTR - centro de lucro


    LOOP AT  gs_dados-mt_dados_contas_pagar_rh-accountgl ASSIGNING FIELD-SYMBOL(<fs_gl>).


*      CONDENSE <fs_gl>-amt_doccur NO-GAPS.
*      SHIFT <fs_gl>-amt_doccur RIGHT DELETING TRAILING '0'.

      APPEND INITIAL LINE TO lt_ACCOUNTGL ASSIGNING FIELD-SYMBOL(<fs_accountgl>).
      <fs_accountgl>-itemno_acc = lv_item.
      UNPACK <fs_accountgl>-itemno_acc TO <fs_accountgl>-itemno_acc.

      <fs_accountgl>-acct_type  = 'S'.

      <fs_accountgl>-gl_account = <fs_gl>-hkont.
      <fs_accountgl>-costcenter = <fs_gl>-kostl.

      IF <fs_gl>-hkont(1) EQ '4'.

        <fs_accountgl>-profit_ctr = <fs_gl>-prctr.
        <fs_accountgl>-bus_area   = COND #( WHEN line_exists( lt_bupla[ 1 ] ) THEN lt_bupla[ 1 ]-gsber ).

      ELSE.

        me->get_div_centro_lucro( EXPORTING iv_centro_custo = <fs_accountgl>-costcenter
                                  IMPORTING ev_centro_lucro = <fs_accountgl>-profit_ctr
                                            ev_divisao      = <fs_accountgl>-bus_area
                                            ev_segmento     = <fs_accountgl>-segment ).

        CLEAR <fs_accountgl>-costcenter.
*        <fs_accountgl>-profit_ctr = <fs_gl>-prctr.
*        <fs_accountgl>-bus_area   = COND #( WHEN line_exists( lt_bupla[ 1 ] ) THEN lt_bupla[ 1 ]-gsber ).

      ENDIF.


*      IF <fs_gl>-hkont(1) =  '1' OR <fs_gl>-hkont(1) = '2'.
*        <fs_accountgl>-profit_ctr = <fs_gl>-prctr.
*      ELSE.
*        <fs_accountgl>-costcenter = <fs_gl>-kostl.
*      ENDIF.
*
*      <fs_accountgl>-bus_area   = lt_bupla[ 1 ]-gsber.

      READ TABLE lt_bupla
      WITH KEY bukrs = gv_bukrs
               kostl = <fs_gl>-kostl
      BINARY SEARCH ASSIGNING <fs_bupla>.

      IF sy-subrc = 0.
*        IF  <fs_gl>-hkont(1) NE  '1' AND <fs_gl>-hkont(1) NE '2'.

        IF <fs_accountgl>-segment IS INITIAL.
          <fs_accountgl>-segment = <fs_bupla>-segment.
        ENDIF.
*        ENDIF.

        APPEND INITIAL LINE TO lt_extension2 ASSIGNING FIELD-SYMBOL(<fs_extension2>).
        <fs_extension2>-structure  = 'BUPLA'.
        <fs_extension2>-valuepart1 = <fs_accountgl>-itemno_acc.
        <fs_extension2>-valuepart2 = <fs_bupla>-bupla.
      ENDIF.

      APPEND INITIAL LINE TO lt_ammount ASSIGNING <fs_ammount>.

      <fs_ammount>-itemno_acc   = <fs_accountgl>-itemno_acc.
      <fs_ammount>-currency_iso = gs_dados-mt_dados_contas_pagar_rh-waers.

      IF lv_vlrposit = abap_true. "debito - > positivo
*        lv_vlrposit = abap_false.

        IF <fs_gl>-amt_doccur >= 0.
          <fs_ammount>-amt_doccur = <fs_gl>-amt_doccur.
        ELSE.
          <fs_ammount>-amt_doccur = ( <fs_gl>-amt_doccur * ( -1 ) ).
        ENDIF.

      ELSE.
*        lv_vlrposit = abap_true.

        IF <fs_gl>-amt_doccur <= 0.
          <fs_ammount>-amt_doccur = <fs_gl>-amt_doccur.
        ELSE.
          <fs_ammount>-amt_doccur = ( <fs_gl>-amt_doccur * ( -1 ) ).
        ENDIF.

      ENDIF.
*      <fs_ammount>-amt_doccur   = <fs_ammount>-currency.


      lv_item = lv_item + 1.
    ENDLOOP.



*    IF is_data-newbs = '40'.
*
*      APPEND INITIAL LINE TO lt_ammount ASSIGNING FIELD-SYMBOL(<fs_ammount>).
*
*      IF <fs_accountgl> IS ASSIGNED.
*        <fs_ammount>-itemno_acc   = <fs_accountgl>-itemno_acc.
*      ENDIF.
*
*      <fs_ammount>-currency_iso = is_data-waers.
*      <fs_ammount>-amt_doccur   = is_data-wrbtr.
*
*      IF is_data-wrbtr >= 0.
*        <fs_ammount>-currency = is_data-wrbtr.
*      ELSE.
*        <fs_ammount>-currency = ( is_data-wrbtr * ( -1 ) ).
*      ENDIF.
*
*      APPEND INITIAL LINE TO lt_ammount ASSIGNING <fs_ammount>.
*      IF <fs_playable> IS ASSIGNED.
*        <fs_ammount>-itemno_acc   = <fs_playable>-itemno_acc.
*      ENDIF.
*
*      <fs_ammount>-currency_iso = is_data-waers.
*      <fs_ammount>-amt_doccur   = is_data-wrbtr.
*
*      IF is_data-wrbtr <= 0.
*        <fs_ammount>-currency = is_data-wrbtr.
*      ELSE.
*        <fs_ammount>-currency = ( is_data-wrbtr * ( -1 ) ).
*      ENDIF.
*
*    ELSEIF is_data-newbs = '50'.
*
*      APPEND INITIAL LINE TO lt_ammount ASSIGNING <fs_ammount>.
*      IF <fs_accountgl> IS ASSIGNED.
*        <fs_ammount>-itemno_acc   = <fs_accountgl>-itemno_acc.
*      ENDIF.
*
*      <fs_ammount>-currency_iso = is_data-waers.
*      <fs_ammount>-amt_doccur   = is_data-wrbtr.
*
*      IF is_data-wrbtr <= 0.
*        <fs_ammount>-currency = is_data-wrbtr.
*      ELSE.
*        <fs_ammount>-currency = ( is_data-wrbtr * ( -1 ) ).
*      ENDIF.
*
*      APPEND INITIAL LINE TO lt_ammount ASSIGNING <fs_ammount>.
*      IF <fs_playable> IS ASSIGNED.
*        <fs_ammount>-itemno_acc   = <fs_playable>-itemno_acc.
*      ENDIF.
*
*      <fs_ammount>-currency_iso = is_data-waers.
*      <fs_ammount>-amt_doccur   = is_data-wrbtr.
*
*      IF is_data-wrbtr >= 0.
*        <fs_ammount>-currency = is_data-wrbtr.
*      ELSE.
*        <fs_ammount>-currency = ( is_data-wrbtr * ( -1 ) ).
*      ENDIF.
*
*    ENDIF.



    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = ls_header
      IMPORTING
        obj_key        = lv_key
      TABLES
        accountpayable = lt_payable
        accountgl      = lt_accountgl
        currencyamount = lt_ammount
        extension2     = lt_extension2
        return         = lt_return.

    SORT lt_return BY type id number.

    READ TABLE lt_return
    WITH KEY type = 'E'
    BINARY SEARCH TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

      " Remove mensagem de erro genérica. A próxima mensagem de erro será exibida no log
      READ TABLE lt_return
      WITH KEY type   = lc_erro_documento-msgty
               id     = lc_erro_documento-msgid
               number = lc_erro_documento-msgno
      BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        DELETE lt_return INDEX sy-tabix.
      ENDIF.


      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      me->add_log( iv_type = gc_status_erro
                   iv_msg  = CONV bapi_msg( lt_return[ type = gc_status_erro ]-message ) ). "#EC CI_STDSEQ
      me->save_log( iv_type = gc_status_erro ).

      "Erro ao criar ordem de venda
      RAISE EXCEPTION TYPE zcxfi_totvs_doc_pagar
        EXPORTING
          iv_textid   = zcxfi_totvs_doc_pagar=>gc_cxdocument_post_erro
          it_bapiret2 = lt_return.

    ELSE.
      ls_key = lv_key.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
      IF lt_return IS NOT INITIAL.

        READ TABLE lt_return
        WITH KEY type   = lc_msg_doc_lancado-msgty
                 id     = lc_msg_doc_lancado-msgid
                 number = lc_msg_doc_lancado-msgno
        BINARY SEARCH ASSIGNING FIELD-SYMBOL(<fs_msg>).

        IF sy-subrc EQ 0.
          lv_msg = <fs_msg>-message.
        ELSE.
          lv_msg  = lt_return[ 1 ]-message.
        ENDIF.
        me->add_log( iv_type = gc_status_sucesso iv_msg = lv_msg ).
        me->save_log( ).
      ENDIF.
      LOOP AT lt_payable ASSIGNING <fs_playable>.

        APPEND INITIAL LINE TO lt_totvs ASSIGNING FIELD-SYMBOL(<fs_totvs>).
        <fs_totvs>-bukrs = ls_key-bukrs.
        <fs_totvs>-belnr = ls_key-belnr.
        <fs_totvs>-gjahr = ls_key-gjahr.
        <fs_totvs>-buzei = <fs_playable>-itemno_acc.
        <fs_totvs>-budat = gs_dados-mt_dados_contas_pagar_rh-budat.
        <fs_totvs>-xblnr = gs_dados-mt_dados_contas_pagar_rh-xblnr.
        <fs_totvs>-data  = sy-datum.
        <fs_totvs>-hora  = sy-uzeit.
        <fs_totvs>-mensagem = lv_msg.
      ENDLOOP.

      IF lt_totvs IS NOT INITIAL.
        MODIFY ztfi_tovts_pagar FROM TABLE lt_totvs.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_data.

    DATA : lv_msg   TYPE bapi_msg,
           lv_erro  TYPE abap_bool,
           lr_SAKNR TYPE RANGE OF saknr.


    SELECT
     SINGLE companycode
    FROM
       p_companycodeaddl
    WHERE
      party = @gc_party
      AND paval = @gs_dados-mt_dados_contas_pagar_rh-burks "campo cgc da interface
    INTO @DATA(lv_company).

    IF sy-subrc = 0.
      lr_SAKNR = VALUE #( FOR ls_SAKNR IN gs_dados-mt_dados_contas_pagar_rh-accountgl
                            LET lv_sign   = 'I'
                                lv_option = 'EQ'
                            IN  sign      = lv_sign
                                option    = lv_option
                          ( low = ls_saknr-hkont ) ).


      IF lr_SAKNR IS NOT INITIAL.

        LOOP AT lr_saknr ASSIGNING FIELD-SYMBOL(<fs_saknr>).

          SELECT SINGLE saknr FROM skb1
          WHERE bukrs = @lv_company
            AND saknr = @<fs_saknr>-low "is_data-hkont
          INTO @DATA(lv_conta).

          IF sy-subrc NE 0.
            DATA(lo_erro) = NEW zcxfi_totvs_doc_pagar(
              iv_textid = zcxfi_totvs_doc_pagar=>gc_cxconta_razao_nao_existe
              iv_msgv1  = CONV msgv1( lv_conta )
              iv_msgv2  = CONV msgv2( lv_company )
            ).

            DATA(lt_retbapi) = lo_erro->get_bapiretreturn( ).
            LOOP AT lt_retbapi ASSIGNING FIELD-SYMBOL(<fs_bapi>). "#EC CI_NESTED
              APPEND INITIAL LINE TO gt_erro ASSIGNING FIELD-SYMBOL(<fs_erro>).
              <fs_erro> = <fs_bapi>.
            ENDLOOP.
            add_log( iv_type = gc_status_erro iv_msg = CONV bapi_msg( lo_erro->get_text( ) ) ).
            save_log( iv_type = gc_status_erro ).

            lv_erro = abap_true.

          ENDIF.

        ENDLOOP.

      ELSE.

        lo_erro = NEW zcxfi_totvs_doc_pagar(
          iv_textid = zcxfi_totvs_doc_pagar=>gc_cxconta_razao_nao_informada
          iv_msgv1  = CONV msgv1( lv_conta )
          iv_msgv2  = CONV msgv2( lv_company ) ).

        lt_retbapi = lo_erro->get_bapiretreturn( ).
        LOOP AT lt_retbapi ASSIGNING <fs_bapi>.
          APPEND INITIAL LINE TO gt_erro ASSIGNING <fs_erro>.
          <fs_erro> = <fs_bapi>.
        ENDLOOP.
        add_log( iv_type = gc_status_erro iv_msg = CONV bapi_msg( lo_erro->get_text( ) ) ).
        save_log( iv_type = gc_status_erro ).

        lv_erro = abap_true.

      ENDIF.

      LOOP AT gs_dados-mt_dados_contas_pagar_rh-accountgl ASSIGNING FIELD-SYMBOL(<fs_account>).

        SELECT SINGLE kostl
          FROM vfco_csks_shv_no_auth
         WHERE kokrs = @gc_kokrs
           AND bukrs = @lv_company
           AND kostl = @<fs_account>-kostl
          INTO @DATA(lv_kostl).                      "#EC CI_SEL_NESTED

        IF sy-subrc NE 0.

          lo_erro = NEW zcxfi_totvs_doc_pagar(
            iv_textid = zcxfi_totvs_doc_pagar=>gc_cxcentro_custo_nao_existe
            iv_msgv1  = CONV msgv1( <fs_account>-kostl )
          ).

          lt_retbapi = lo_erro->get_bapiretreturn( ).
          LOOP AT lt_retbapi ASSIGNING <fs_bapi>.        "#EC CI_NESTED
            APPEND INITIAL LINE TO gt_erro ASSIGNING <fs_erro>.
            <fs_erro> = <fs_bapi>.
          ENDLOOP.
          add_log( iv_type = gc_status_erro iv_msg = CONV bapi_msg( lo_erro->get_text( ) ) ).
          save_log( iv_type = gc_status_erro ).

          lv_erro = abap_true.

        ENDIF.

      ENDLOOP.

*      SELECT
*        SINGLE branch
*      FROM j_1bbranch
*      WHERE
*        bukrs      = @lv_company
*        AND branch = @is_data-bupla
*      INTO @DATA(lv_branch).
*
*      IF sy-subrc NE 0.
*
*        lo_erro  = NEW zcxfi_totvs_doc_pagar(
*                                             textid      =  zcxfi_totvs_doc_pagar=>filial_nao_existe
*                                             gv_msgv1    = CONV msgv1( is_data-bupla )
*                                           ).
*
*        lt_retbapi = lo_erro->get_bapiretreturn( ).
*
*        LOOP AT lt_retbapi ASSIGNING <fs_bapi>.
*          APPEND INITIAL LINE TO gt_erro ASSIGNING <fs_erro>.
*          <fs_erro> = <fs_bapi>.
*        ENDLOOP.
*        add_log( CONV bapi_msg( lo_erro->get_text( ) ) ).
*
*      ENDIF.

      gv_branch = ''.
      gv_bukrs = lv_company.

    ELSE.

      lo_erro = NEW zcxfi_totvs_doc_pagar(
        iv_textid = zcxfi_totvs_doc_pagar=>gc_cxcnpj_nao_existe
        iv_msgv1  = CONV msgv1( gs_dados-mt_dados_contas_pagar_rh-burks )
      ).

      lt_retbapi = lo_erro->get_bapiretreturn( ).
      LOOP AT lt_retbapi ASSIGNING <fs_bapi>.
        APPEND INITIAL LINE TO gt_erro ASSIGNING <fs_erro>.
        <fs_erro> = <fs_bapi>.
      ENDLOOP.
      add_log( iv_type = gc_status_erro iv_msg = CONV bapi_msg( lo_erro->get_text( ) ) ).
      save_log( iv_type = gc_status_erro ).

      lv_erro = abap_true.

    ENDIF.

    ev_return = lv_erro.

  ENDMETHOD.


  METHOD processa_interface_doc_pagar.

    gs_dados = is_input.

*    LOOP AT is_input-mt_dados_contas_pagar_rh-list ASSIGNING FIELD-SYMBOL(<fs_lista>).

    check_data( IMPORTING ev_return = DATA(lv_erro) ).

    CHECK lv_erro EQ abap_false.

    call_bapi(  ).

*    ENDLOOP.


  ENDMETHOD.


  METHOD save_log.

    IF gt_log IS NOT INITIAL.
      MODIFY ztfi_totvs_log FROM TABLE gt_log.
      COMMIT WORK AND WAIT.

      CHECK iv_type EQ gc_status_erro.

      "Erro no contas a pagar
      RAISE EXCEPTION TYPE zcxfi_totvs_doc_pagar
        EXPORTING
          iv_textid   = zcxfi_totvs_doc_pagar=>gc_cxvalidacao_dados
          it_bapiret2 = gt_erro.
    ENDIF.



  ENDMETHOD.


  METHOD get_div_centro_lucro.

    SELECT SINGLE gsber, prctr
    FROM csks
    INTO @DATA(ls_return)
    WHERE kostl = @iv_centro_custo
    AND   kokrs = @gc_kokrs.

    IF sy-subrc = 0.

      SELECT SINGLE segment
      FROM cepc
      WHERE prctr  = @ls_return-prctr
      AND   datbi >= @sy-datum
      AND   kokrs  = @gc_kokrs
      INTO @ev_segmento.

      ev_centro_lucro = ls_return-prctr.
      ev_divisao      = ls_return-gsber.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
