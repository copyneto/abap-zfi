class ZCLFI_CREDITOCLIENTE definition
  public
  final
  create public .

public section.

  methods CREDITOCLIENTE_MEMO
    importing
      !IS_FEBKO type FEBKO
      !IT_FTCLEAR type FEB_T_FTCLEAR
    changing
      !CT_FTPOST type FEB_T_FTPOST .
protected section.
private section.

  data GV_HKONT_ENTRADA type UKONT_042I .

  methods FI_DOCUMENT_CHANGE
    importing
      !IT_RENEG_I type ZTTFSCM_RENEG_I .
  methods POSTING_INTERFACE_CLEARING
    importing
      !IS_FTCLEAR type FTCLEAR
      !IS_BSEG type BSEG
      !IT_RENEG type ZTTFSCM_RENEG_I
    changing
      !CT_FTPOST type FEB_T_FTPOST .
ENDCLASS.



CLASS ZCLFI_CREDITOCLIENTE IMPLEMENTATION.


  METHOD creditocliente_memo.

    DATA: lt_bkpf    TYPE TABLE OF bkpf,
          lt_bseg    TYPE TABLE OF bseg,
          lt_reneg_i TYPE TABLE OF ztfscm_reneg_i.

    CONSTANTS: lc_memo       TYPE c VALUE 'S',
               lc_brad       TYPE c LENGTH 3 VALUE '237',
               lc_ff5        TYPE c LENGTH 4 VALUE 'FF.5',
               lc_p_ff5      TYPE c LENGTH 8 VALUE 'RFEBBU00'.

    DATA: lv_gjahr TYPE bseg-gjahr.

********************************
* Validação Banco de Bradesco
********************************
    CHECK is_febko-absnd(03) EQ lc_brad.
********************************
* Validação Banco de Bradesco
********************************

    READ TABLE it_ftclear ASSIGNING FIELD-SYMBOL(<fs_ftclear>) INDEX 1.

    IF sy-subrc IS INITIAL.

      lv_gjahr = <fs_ftclear>-selvon+10(04).

      SELECT empresa, documento, exercicio, item, vl_parcela
        FROM ztfscm_reneg_i
        INTO CORRESPONDING FIELDS OF TABLE @lt_reneg_i
        WHERE empresa_parc   EQ @<fs_ftclear>-agbuk
          AND documento_parc EQ @<fs_ftclear>-selvon(10)
          AND exercicio_parc EQ @lv_gjahr.

      IF sy-subrc IS INITIAL.

        SORT lt_reneg_i BY empresa documento exercicio.

        CALL FUNCTION 'FI_DOCUMENT_READ'
          EXPORTING
            i_bukrs     = <fs_ftclear>-agbuk
            i_belnr     = <fs_ftclear>-selvon(10)
            i_gjahr     = lv_gjahr
          TABLES
            t_bkpf      = lt_bkpf
            t_bseg      = lt_bseg
          EXCEPTIONS
            wrong_input = 1
            not_found   = 2
            OTHERS      = 3.

        IF sy-subrc IS INITIAL.

          READ TABLE lt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>) INDEX 1.

          IF sy-subrc IS INITIAL.

            IF <fs_bkpf>-bstat EQ lc_memo.

              READ TABLE lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>) INDEX 1.

              IF sy-subrc IS INITIAL.

                me->posting_interface_clearing(
                  EXPORTING
                    is_ftclear = <fs_ftclear>
                    is_bseg    = <fs_bseg>
                    it_reneg   = lt_reneg_i
                  CHANGING
                    ct_ftpost = ct_ftpost
                ).

              ENDIF.

            ENDIF.

          ENDIF.

        ENDIF.

      ENDIF.

      CLEAR: lv_gjahr.

    ENDIF.

  ENDMETHOD.


  METHOD fi_document_change.

    DATA(lo_config_tab_parametros) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    CONSTANTS: BEGIN OF lc_param_1,
                 modulo TYPE zi_ca_param_mod-modulo VALUE 'FI-AR',
                 chave1 TYPE zi_ca_param_par-chave1 VALUE 'ÁREA DE ADVERTENCIA',
                 chave2 TYPE zi_ca_param_par-chave2 VALUE 'ÁREA DE ADVERTENCIA',
                 chave3 TYPE zi_ca_param_par-chave3 VALUE 'NEG_INT',
               END OF lc_param_1,

               BEGIN OF lc_param_2,
                 modulo TYPE zi_ca_param_mod-modulo VALUE 'FI-AR',
                 chave1 TYPE zi_ca_param_par-chave1 VALUE 'CHAVE DE ADVERTENCIA',
                 chave2 TYPE zi_ca_param_par-chave2 VALUE 'CHAVE DE ADVERTENCIA',
                 chave3 TYPE zi_ca_param_par-chave3 VALUE 'NEG_DIA',
               END OF lc_param_2.

    DATA: lv_area_adv  TYPE c LENGTH 2,
          lv_chave_adv TYPE c LENGTH 2.

    DATA: lt_accchg TYPE TABLE OF accchg.

    TRY.
        lo_config_tab_parametros->m_get_single(
          EXPORTING
            iv_modulo = lc_param_1-modulo
            iv_chave1 = lc_param_1-chave1
            iv_chave2 = lc_param_1-chave2
            iv_chave3 = lc_param_1-chave3
          IMPORTING
            ev_param  = lv_area_adv ).

        lo_config_tab_parametros->m_get_single(
          EXPORTING
            iv_modulo = lc_param_2-modulo
            iv_chave1 = lc_param_2-chave1
            iv_chave2 = lc_param_2-chave2
            iv_chave3 = lc_param_2-chave3
          IMPORTING
            ev_param  = lv_chave_adv ).
      CATCH zcxca_tabela_parametros.
        RETURN.
    ENDTRY.

    IF lv_area_adv IS NOT INITIAL AND lv_chave_adv IS NOT INITIAL.

      LOOP AT it_reneg_i ASSIGNING FIELD-SYMBOL(<fs_reneg>).

        lt_accchg = VALUE #( BASE lt_accchg (
            fdname   = 'MSCHL'
            oldval   = 'A'
            newval   =  lv_chave_adv ) ).

        lt_accchg = VALUE #( BASE lt_accchg (
            fdname   = 'MABER'
            oldval   = '06'
            newval   =  lv_area_adv ) ).

        CALL FUNCTION 'FI_DOCUMENT_CHANGE'
          EXPORTING
            i_obzei   = '000'
            i_buzei   = '001'
            x_lock    = abap_true
            i_bukrs   = <fs_reneg>-empresa
            i_belnr   = <fs_reneg>-documento
            i_gjahr   = <fs_reneg>-exercicio
            i_upd_fqm = abap_true
          TABLES
            t_accchg  = lt_accchg.

        CLEAR: lt_accchg.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD posting_interface_clearing.

    DATA: lt_ftpost  TYPE TABLE OF ftpost.

    DATA: lv_count TYPE count_pi.

    DATA: lv_valor TYPE string.

    CONSTANTS: lc_chv_adv TYPE c VALUE 'R'.

    IF line_exists( ct_ftpost[ fnam = 'BSEG-HKONT' ] ).  "#EC CI_STDSEQ
      DATA(lv_hkont) = ct_ftpost[ fnam = 'BSEG-HKONT' ]-fval. "#EC CI_STDSEQ
    ENDIF.

    IF line_exists( ct_ftpost[ fnam = 'BKPF-BUDAT' ] ).  "#EC CI_STDSEQ
      DATA(lv_budat) = ct_ftpost[ fnam = 'BKPF-BUDAT' ]-fval. "#EC CI_STDSEQ
    ENDIF.

*********************************
* CABEÇALHO DO DOCUMENTO
*********************************

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'K'
         count  = '001'
         fnam   = 'BKPF-BUKRS'
         fval   = is_ftclear-agbuk ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'K'
         count  = '001'
         fnam   = 'BKPF-BLDAT'
         fval   = lv_budat ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'K'
         count  = '001'
         fnam   = 'BKPF-BUDAT'
         fval   = lv_budat ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'K'
         count  = '001'
         fnam   = 'BKPF-BLART'
         fval   = 'DE' ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'K'
         count  = '001'
         fnam   = 'BKPF-WAERS'
         fval   = 'BRL' ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'K'
         count  = '001'
         fnam   = 'BKPF-BKTXT'
         fval   = 'RENEGOCIAÇÃO' ) ).

***************************************
* ITENS DO DOCUMENTO - ENTRADA PGTO
***************************************

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'P'
         count  = '001'
         fnam   = 'RF05A-NEWBS'
         fval   = '40' ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'P'
         count  = '001'
         fnam   = 'BSEG-HKONT'
         fval   = lv_hkont ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'P'
         count  = '001'
         fnam   = 'BSEG-BUPLA'
         fval   = is_bseg-bupla ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'P'
         count  = '001'
         fnam   = 'COBL-GSBER'
         fval   = ' ' ) ).

    IF line_exists( ct_ftpost[ fnam = 'BSEG-WRBTR' ] ).  "#EC CI_STDSEQ
      lv_valor = ct_ftpost[ fnam = 'BSEG-WRBTR' ]-fval.  "#EC CI_STDSEQ
    ENDIF.

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'P'
         count  = '001'
         fnam   = 'BSEG-WRBTR'
         fval   = lv_valor ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'P'
         count  = '001'
         fnam   = 'BSEG-ZUONR'
         fval   = ' ' ) ).

    lt_ftpost = VALUE #( BASE lt_ftpost (
         stype  = 'P'
         count  = '001'
         fnam   = 'BSEG-ZFBDT'
         fval   = lv_budat ) ).

********************************
* CRÉDITO AO CLIENTE
********************************

    ADD 1 TO lv_count.

    LOOP AT it_reneg ASSIGNING FIELD-SYMBOL(<fs_reneg>).

      ADD 1 TO lv_count.

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'RF05A-NEWBS'
           fval   = '11' ) ).

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-HKONT'
           fval   = is_ftclear-agkon ) ).

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-BUPLA '
           fval   = is_bseg-bupla ) ).

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-GSBER'
           fval   = ' ' ) ).

      lv_valor = <fs_reneg>-vl_parcela.
      REPLACE '.' IN lv_valor WITH ','.
      CONDENSE lv_valor.

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-WRBTR'
           fval   = lv_valor ) ).

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-ZUONR'
           fval   = 'RENEGOCIAÇÃO' ) ).

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-ZFBDT'
           fval   = lv_budat ) ).

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-REBZG'
           fval   = <fs_reneg>-documento ) ).

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-REBZJ'
           fval   = <fs_reneg>-exercicio ) ).

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-REBZZ'
           fval   = <fs_reneg>-item ) ).

      lt_ftpost = VALUE #( BASE lt_ftpost (
           stype  = 'P'
           count  = lv_count
           fnam   = 'BSEG-MSCHL'
           fval   = lc_chv_adv ) ).

    ENDLOOP.

    CLEAR: ct_ftpost.

    ct_ftpost = lt_ftpost[].

    me->fi_document_change( it_reneg_i = it_reneg ).

  ENDMETHOD.
ENDCLASS.
