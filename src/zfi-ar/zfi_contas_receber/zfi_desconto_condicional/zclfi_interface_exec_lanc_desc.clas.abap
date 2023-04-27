"!<p>Classe processar Interface Executar Lançamento Desconto</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 15 de Março de 2022</p>
CLASS zclfi_interface_exec_lanc_desc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_infos_aux,
             coscen  TYPE string,
             kostl   TYPE kostl,
             gsber   TYPE gsber,
             prctr   TYPE prctr,
             segment TYPE fb_segment,
           END OF ty_infos_aux,
           tt_infos_aux TYPE TABLE OF ty_infos_aux.

    METHODS executar
      IMPORTING
        !is_input  TYPE zclfi_mt_agendamento_parcelas1
      EXPORTING
        !es_output TYPE zclfi_mt_agendamento_parcelas
      RAISING
        zcxca_erro_interface .
    METHODS get_info_auxiliares
      CHANGING ct_info TYPE tt_infos_aux.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF gc_erros,
        interface TYPE string VALUE 'ZCLFI_CL_SI_RECEBER_AGENDAMENT',
        metodo    TYPE string VALUE 'executar'                             ##NO_TEXT,
        classe    TYPE string VALUE 'ZCLFI_INTERFACE_EXEC_LANC_DESC'        ##NO_TEXT,
      END OF gc_erros,
      gc_s     TYPE bkpf-xref1_hd VALUE 'S',
      gc_kokrs TYPE kokrs         VALUE 'AC3C'.

    "! Return error raising
    METHODS error_raise
      IMPORTING
        !is_ret TYPE scx_t100key
      RAISING
        zcxca_erro_interface .

ENDCLASS.



CLASS ZCLFI_INTERFACE_EXEC_LANC_DESC IMPLEMENTATION.


  METHOD error_raise.
    RAISE EXCEPTION TYPE zcxca_erro_interface
      EXPORTING
        textid = VALUE #(
                          attr1 = is_ret-attr1
                          attr2 = is_ret-attr2
                          attr3 = is_ret-attr3
                          msgid = is_ret-msgid
                          msgno = is_ret-msgno
                          ).
  ENDMETHOD.


  METHOD executar.

    DATA: lt_accountgl      TYPE bapiacgl09_tab,
          lt_accountpayable TYPE bapiacap09_tab,
          lt_currencyamount TYPE bapiaccr09_tab,
          lt_extension2     TYPE bapiapoparex_tab,
          lt_info           TYPE tt_infos_aux,
          lt_return         TYPE bapiret2_t.

    DATA: lv_prctr   TYPE prctr,
          lv_gsber   TYPE gsber,
          lv_message TYPE bapiret2-message.

    DATA(ls_docheader) = VALUE bapiache09(
                                    obj_type    = is_input-mt_agendamento_parcelas-rfbu
                                    username    = sy-uname
                                    header_txt  = is_input-mt_agendamento_parcelas-header_txt
                                    comp_code   = is_input-mt_agendamento_parcelas-comp_code
                                    doc_date    = is_input-mt_agendamento_parcelas-doc_date
                                    pstng_date  = is_input-mt_agendamento_parcelas-pstng_date
                                    fisc_year   = is_input-mt_agendamento_parcelas-fisc_year
                                    fis_period  = is_input-mt_agendamento_parcelas-fis_period
                                    doc_type    = is_input-mt_agendamento_parcelas-doc_type
                                    ref_doc_no  = is_input-mt_agendamento_parcelas-ref_doc_no
                                    glo_ref1_hd = is_input-mt_agendamento_parcelas-xref1_hd
                                    glo_ref2_hd = is_input-mt_agendamento_parcelas-xref2_hd ).

    APPEND VALUE #( structure  = 'XREF1_HD'
                    valuepart1 = 1
                    valuepart2 = is_input-mt_agendamento_parcelas-xref1_hd )
                 TO lt_extension2.

    APPEND VALUE #( structure  = 'XREF2_HD'
                    valuepart1 = 1
                    valuepart2 = is_input-mt_agendamento_parcelas-xref2_hd )
                 TO lt_extension2.

    lt_info = VALUE #( FOR <fs_account_val> IN is_input-mt_agendamento_parcelas-account_models
                       ( coscen = <fs_account_val>-costcenter
                         kostl  = CONV kostl( <fs_account_val>-costcenter ) ) ).

    me->get_info_auxiliares( CHANGING ct_info = lt_info ).

    SORT lt_info BY coscen.

    LOOP AT is_input-mt_agendamento_parcelas-account_models
            ASSIGNING FIELD-SYMBOL(<fs_account>).
      READ TABLE lt_info
           ASSIGNING FIELD-SYMBOL(<fs_info>)
        WITH KEY coscen = <fs_account>-costcenter
        BINARY SEARCH.
      lv_prctr = <fs_info>-prctr.
      lv_gsber = <fs_info>-gsber.
      APPEND VALUE #( itemno_acc = <fs_account>-itemno_acc
                      gl_account = <fs_account>-gl_account
                      item_text  = <fs_account>-item_text
                      doc_type   = <fs_account>-kd
                      comp_code  = <fs_account>-comp_code
                      alloc_nmbr = <fs_account>-alloc_nmbr
                      costcenter = <fs_account>-costcenter
                      bus_area   = lv_gsber
                      profit_ctr = lv_prctr
                      segment    = <fs_info>-segment )
            TO lt_accountgl.

      APPEND VALUE #( structure  = 'BUPLA'
                      valuepart1 = <fs_account>-itemno_acc
                      valuepart2 = <fs_account>-bus_area )
                   TO lt_extension2.

    ENDLOOP.

    LOOP AT is_input-mt_agendamento_parcelas-account_payable_models
            ASSIGNING FIELD-SYMBOL(<fs_payable>).

      APPEND VALUE #( itemno_acc = <fs_payable>-itemno_acc
                      vendor_no  = <fs_payable>-vendor_no
                      item_text  = <fs_payable>-item_text
                      bline_date = <fs_payable>-bline_date
                      pymt_meth  = <fs_payable>-pymt_meth
                      comp_code  = <fs_payable>-comp_code
                      bus_area   = lv_gsber
                      alloc_nmbr = <fs_payable>-alloc_nmbr
                      profit_ctr = lv_prctr )
            TO lt_accountpayable.

    ENDLOOP.

    LOOP AT is_input-mt_agendamento_parcelas-currency_amount_models
             ASSIGNING FIELD-SYMBOL(<fs_amount>).

      APPEND VALUE #( itemno_acc = <fs_amount>-itemno_acc
                      currency   = <fs_amount>-currency
                      amt_doccur = <fs_amount>-amt_doccur )
            TO lt_currencyamount.

    ENDLOOP.

    DATA(lo_exec_lanc) = NEW zclfi_exec_lancamento_desconto(  ).

    IF lo_exec_lanc->verificar_lancamento( iv_xblnr  = ls_docheader-ref_doc_no
                                           iv_bukrs  = ls_docheader-comp_code
                                           iv_gjahr  = ls_docheader-fisc_year
                                           iv_blart  = ls_docheader-doc_type ) IS NOT INITIAL.
      "Contabilização já realizada
      MESSAGE e001(zfi_contab) INTO DATA(lv_msg).
      lt_return = VALUE #( ( type    = 'E'
                             id      = 'ZFI_CONTAB'
                             number  = '001'
                             message = lv_msg ) ).
    ELSE.
      lo_exec_lanc->executar(
        EXPORTING
          iv_commit         = abap_true
          is_docheader      = ls_docheader
          it_accountgl      = lt_accountgl
          it_accountpayable = lt_accountpayable
          it_currencyamount = lt_currencyamount
          it_extension2     = lt_extension2
        IMPORTING
          ev_type           = DATA(lv_type)
          ev_key            = DATA(lv_key)
          ev_sys            = DATA(lv_sys)
        RECEIVING
          rt_return         = lt_return ).
    ENDIF.

    SORT lt_return BY type.
    READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_return>)
                                       WITH KEY type = 'E'
                                       BINARY SEARCH.
    IF sy-subrc = 0 .

      IF lines( lt_return ) GT 1.
        READ TABLE lt_return ASSIGNING <fs_return> INDEX 2.
      ENDIF.

      IF <fs_return> IS ASSIGNED.
        CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
          EXPORTING
            id         = <fs_return>-id
            number     = <fs_return>-number
            language   = sy-langu
            textformat = 'ASC'
            message_v1 = <fs_return>-message_v1
            message_v2 = <fs_return>-message_v2
            message_v3 = <fs_return>-message_v3
            message_v4 = <fs_return>-message_v4
          IMPORTING
            message    = lv_message.

        es_output-mt_agendamento_parcelas_resp-type    = <fs_return>-type.
        es_output-mt_agendamento_parcelas_resp-message = lv_message.
      ENDIF.

    ELSE.
      es_output-mt_agendamento_parcelas_resp-type    = gc_s.
    ENDIF.

  ENDMETHOD.


  METHOD get_info_auxiliares.
    IF ct_info[] IS NOT INITIAL.

      SELECT  kokrs,
              kostl,
              datbi,
              gsber,
              prctr
        FROM csks
        INTO TABLE @DATA(lt_csks)
        FOR ALL ENTRIES IN @ct_info
      WHERE kokrs = @gc_kokrs
        AND kostl = @ct_info-kostl.

      IF sy-subrc = 0.
        SORT lt_csks BY kostl.

        SELECT prctr,
               datbi,
               kokrs,
               segment
          FROM cepc
          INTO TABLE @DATA(lt_cepc)
           FOR ALL ENTRIES IN @lt_csks
         WHERE prctr = @lt_csks-prctr
           AND kokrs = @gc_kokrs.

        IF sy-subrc = 0.
          SORT lt_cepc BY prctr.
          LOOP AT ct_info ASSIGNING FIELD-SYMBOL(<fs_info>).
            READ TABLE lt_csks ASSIGNING FIELD-SYMBOL(<fs_csks>)
                                             WITH KEY kostl = <fs_info>-kostl
                                             BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_info>-gsber = <fs_csks>-gsber.
              <fs_info>-prctr = <fs_csks>-prctr.
              READ TABLE lt_cepc
                   ASSIGNING FIELD-SYMBOL(<fs_cepc>)
                WITH KEY prctr = <fs_csks>-prctr
                BINARY SEARCH.
              IF sy-subrc = 0.
                <fs_info>-segment = <fs_cepc>-segment.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
