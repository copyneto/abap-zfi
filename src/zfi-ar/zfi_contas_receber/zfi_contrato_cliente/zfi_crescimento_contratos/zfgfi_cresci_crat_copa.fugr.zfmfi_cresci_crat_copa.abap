FUNCTION zfmfi_cresci_crat_copa.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_KEY) TYPE  ZI_FI_LOG_CALC_CRESCIMENTO OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  TYPES: BEGIN OF ty_rateio,
           kunnr      TYPE ztfi_calc_cresci-kunnr,
           vtweg      TYPE ztfi_calc_cresci-vtweg,
           bzirk      TYPE ztfi_calc_cresci-bzirk,
           familia_cl TYPE ztfi_calc_cresci-familia_cl,
           plant      TYPE werks_d,
           montante   TYPE ze_mont_crescimento,
         END OF ty_rateio.


  DATA: lt_inputdata TYPE STANDARD TABLE OF bapi_copa_data,
        lt_fieldlist TYPE STANDARD TABLE OF bapi_copa_field,
        lt_return    TYPE STANDARD TABLE OF bapiret2,
        lt_rateio    TYPE TABLE OF ty_rateio.

  DATA: ls_rateio TYPE ty_rateio.

  DATA: lv_tot     TYPE ze_bonus_calcul,
        lv_tot_rat TYPE ze_bonus_calcul,
        lv_line    TYPE rke_record_id.

  CONSTANTS: lc_error       TYPE sy-msgty            VALUE 'E',
             lc_concern     TYPE bapi0017-op_concern VALUE 'AR3C',
             lc_moeda       TYPE rke_rec_waers       VALUE 'BRL',
             lc_field_bukrs TYPE rke_field           VALUE 'BUKRS',
             lc_field_budat TYPE rke_field           VALUE 'BUDAT',
             lc_field_kndnr TYPE rke_field           VALUE 'KNDNR',
             lc_field_vtweg TYPE rke_field           VALUE 'VTWEG',
             lc_field_bzirk TYPE rke_field           VALUE 'BZIRK',
             lc_field_wwmt1 TYPE rke_field           VALUE 'WWMT1',
             lc_field_werks TYPE rke_field           VALUE 'WERKS',
             lc_field_vv001 TYPE rke_field           VALUE 'VV001'.

  SELECT *
        FROM ztfi_calc_cresci
        WHERE contrato = @is_key-contrato
          AND aditivo = @is_key-aditivo
          AND exerc_atual = @is_key-exercatual
          AND exerc_anter = @is_key-exercanter
          AND ciclo = @is_key-ciclo
           INTO TABLE @DATA(lt_crescim).

  IF sy-subrc IS INITIAL.

    DATA(lt_crescim_fae) = lt_crescim[].
    SORT lt_crescim_fae BY bukrs
                           belnr
                           gjahr
                           buzei.

    DELETE ADJACENT DUPLICATES FROM lt_crescim_fae COMPARING bukrs
                                                             belnr
                                                             gjahr
                                                             buzei.

    SELECT bukrs,
           belnr,
           gjahr,
           buzei,
           vbeln
      FROM bseg
       FOR ALL ENTRIES IN @lt_crescim_fae
     WHERE bukrs = @lt_crescim_fae-bukrs
       AND belnr = @lt_crescim_fae-belnr
       AND gjahr = @lt_crescim_fae-gjahr
       AND buzei = @lt_crescim_fae-buzei
      INTO TABLE @DATA(lt_bsid).

    IF sy-subrc IS INITIAL.

      SORT lt_bsid BY bukrs
                      belnr
                      gjahr
                      buzei.

      DATA(lt_bsid_fae) = lt_bsid[].
      SORT lt_bsid_fae BY vbeln.
      DELETE ADJACENT DUPLICATES FROM lt_bsid_fae COMPARING vbeln.

      SELECT billingdocument,
             billingdocumentitem,
             plant
        FROM i_billingdocumentitembasic
         FOR ALL ENTRIES IN @lt_bsid_fae
       WHERE billingdocument = @lt_bsid_fae-vbeln
        INTO TABLE @DATA(lt_itens).

      IF sy-subrc IS INITIAL.
        SORT lt_itens BY billingdocument.
      ENDIF.
    ENDIF.
  ENDIF.



  LOOP AT lt_crescim ASSIGNING FIELD-SYMBOL(<fs_crescim2>).

    READ TABLE lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid2>)
                                     WITH KEY bukrs = <fs_crescim2>-bukrs
                                              belnr = <fs_crescim2>-belnr
                                              gjahr = <fs_crescim2>-gjahr
                                              buzei = <fs_crescim2>-buzei
                                              BINARY SEARCH.
    IF sy-subrc IS INITIAL.

      READ TABLE lt_itens ASSIGNING FIELD-SYMBOL(<fs_itens2>)
                                        WITH KEY billingdocument = <fs_bsid2>-vbeln
                                        BINARY SEARCH.
      IF sy-subrc IS INITIAL.

        ls_rateio-familia_cl = <fs_crescim2>-familia_cl.
        ls_rateio-kunnr = <fs_crescim2>-kunnr.
        ls_rateio-vtweg = <fs_crescim2>-vtweg.
        ls_rateio-bzirk = <fs_crescim2>-bzirk.
        ls_rateio-plant = <fs_itens2>-plant.
        IF <fs_crescim2>-mont_bonus IS NOT INITIAL.
          ls_rateio-montante = <fs_crescim2>-mont_bonus.
        ELSE.
          ls_rateio-montante = <fs_crescim2>-bonus_calculado.
        ENDIF..
        COLLECT ls_rateio INTO lt_rateio.

      ENDIF.

    ENDIF.
  ENDLOOP.


  LOOP AT lt_rateio ASSIGNING FIELD-SYMBOL(<fs_rateio>).

    lv_line = lv_line + 1.

    " BUKRS
    lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
                                                fieldname = lc_field_bukrs
                                                value     = is_key-bukrs
                                                currency  = lc_moeda ) ).
*    " BUKRS
*    lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_bukrs ) ).

    " BUDAT
    lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
                                                fieldname = lc_field_budat
                                                value     = sy-datum
                                                currency  = lc_moeda ) ).
*    " BUDAT
*    lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_budat ) ).

    " KNDNR
    lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
                                                fieldname = lc_field_kndnr
                                                value     = <fs_rateio>-kunnr
                                                currency  = lc_moeda ) ).
*    " KNDNR
*    lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_kndnr ) ).

    " VTWEG
    lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
                                                fieldname = lc_field_vtweg
                                                value     = <fs_rateio>-vtweg
                                                currency  = lc_moeda ) ).
*    " VTWEG
*    lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_vtweg ) ).

    " BZIRK
    lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
                                                fieldname = lc_field_bzirk
                                                value     = <fs_rateio>-bzirk
                                                currency  = lc_moeda ) ).
*    " BZIRK
*    lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_bzirk ) ).

    " WWMT1
    lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
                                                fieldname = lc_field_wwmt1
                                                value     = <fs_rateio>-familia_cl
                                                currency  = lc_moeda ) ).
*    " WWMT1
*    lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_wwmt1 ) ).

    " WERKS
    lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
                                                fieldname = lc_field_werks
                                                value     = <fs_rateio>-plant
                                                currency  = lc_moeda ) ).
*    " WERKS
*    lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_werks ) ).

    " VV001
    lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
                                                fieldname = lc_field_vv001
                                                value     = <fs_rateio>-montante
                                                currency  = lc_moeda ) ).
*    " VV001
*    lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_vv001 ) ).
  ENDLOOP.

  lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_bukrs ) ).
  lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_budat ) ).
  lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_kndnr ) ).
  lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_vtweg ) ).
  lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_bzirk ) ).
  lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_wwmt1 ) ).
  lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_werks ) ).
  lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_vv001 ) ).

**  LOOP AT lt_crescim ASSIGNING FIELD-SYMBOL(<fs_crescim>).
**
**    READ TABLE lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>)
**                                     WITH KEY bukrs = <fs_crescim>-bukrs
**                                              belnr = <fs_crescim>-belnr
**                                              gjahr = <fs_crescim>-gjahr
**                                              buzei = <fs_crescim>-buzei
**                                              BINARY SEARCH.
**    IF sy-subrc IS INITIAL.
**
**      READ TABLE lt_itens ASSIGNING FIELD-SYMBOL(<fs_itens>)
**                                        WITH KEY billingdocument = <fs_bsid>-vbeln
**                                        BINARY SEARCH.
**      IF sy-subrc IS INITIAL.
**
**        lv_line = lv_line + 1.
**
**        " BUKRS
**        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
**                                                    fieldname = lc_field_bukrs
**                                                    value     = <fs_crescim>-bukrs
**                                                    currency  = lc_moeda ) ).
**        " BUKRS
**        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_bukrs ) ).
**
**        " BUDAT
**        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
**                                                    fieldname = lc_field_budat
**                                                    value     = <fs_crescim>-budat
**                                                    currency  = lc_moeda ) ).
**        " BUDAT
**        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_budat ) ).
**
**        " KNDNR
**        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
**                                                    fieldname = lc_field_kndnr
**                                                    value     = <fs_crescim>-kunnr
**                                                    currency  = lc_moeda ) ).
**        " KNDNR
**        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_kndnr ) ).
**
**        " VTWEG
**        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
**                                                    fieldname = lc_field_vtweg
**                                                    value     = <fs_crescim>-vtweg
**                                                    currency  = lc_moeda ) ).
**        " VTWEG
**        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_vtweg ) ).
**
**        " BZIRK
**        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
**                                                    fieldname = lc_field_bzirk
**                                                    value     = <fs_crescim>-bzirk
**                                                    currency  = lc_moeda ) ).
**        " BZIRK
**        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_bzirk ) ).
**
**        " WWMT1
**        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
**                                                    fieldname = lc_field_wwmt1
**                                                    value     = <fs_crescim>-familia_cl
**                                                    currency  = lc_moeda ) ).
**        " WWMT1
**        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_wwmt1 ) ).
**
**        " WERKS
**        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
**                                                    fieldname = lc_field_werks
**                                                    value     = <fs_itens>-plant
**                                                    currency  = lc_moeda ) ).
**        " WERKS
**        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_werks ) ).
**
**        " VV001
**        lt_inputdata = VALUE #( BASE lt_inputdata ( record_id = lv_line
**                                                    fieldname = lc_field_vv001
**                                                    value     = lv_tot_rat
**                                                    currency  = lc_moeda ) ).
**        " VV001
**        lt_fieldlist = VALUE #( BASE lt_fieldlist ( fieldname = lc_field_vv001 ) ).
**
**      ENDIF.
**    ENDIF.
**
**  ENDLOOP.

  CALL FUNCTION 'BAPI_COPAACTUALS_POSTCOSTDATA'
    EXPORTING
      operatingconcern = lc_concern
      testrun          = space
    TABLES
      inputdata        = lt_inputdata
      fieldlist        = lt_fieldlist
      return           = lt_return.

  IF line_exists( lt_return[ type = lc_error ] ).        "#EC CI_STDSEQ
    et_return[] = lt_return[].
    "Erro no lançamento COPA
    et_return = VALUE #( ( id = 'ZFI_BASE_CALCULO'
                           type = 'E'
                           number = 035 ) ).
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    "Documento(s) de CO-PA contabilizado(s) com sucesso
    et_return = VALUE #( ( id = 'ZFI_BASE_CALCULO'
                           type = 'S'
                           number = 034 ) ).
  ENDIF.

ENDFUNCTION.
