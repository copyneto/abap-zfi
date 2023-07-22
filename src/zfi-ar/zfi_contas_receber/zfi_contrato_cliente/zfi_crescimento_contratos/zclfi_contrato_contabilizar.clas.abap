CLASS zclfi_contrato_contabilizar DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS execute
      IMPORTING
        !is_key    TYPE zsfi_contab_key
      EXPORTING
        !et_return TYPE bapiret2_t .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS gc_prm_modulo TYPE ze_param_modulo VALUE 'FI-AR' ##NO_TEXT.
    CONSTANTS gc_chv_calcres TYPE ze_param_chave VALUE 'CONTRATOS' ##NO_TEXT.
    CONSTANTS gc_chv_ctrazao TYPE ze_param_chave VALUE 'CLIENTE_FAC12' ##NO_TEXT.
    CONSTANTS gc_chv_blart TYPE ze_param_chave VALUE 'CLIENTE_FAC11' ##NO_TEXT.
ENDCLASS.



CLASS ZCLFI_CONTRATO_CONTABILIZAR IMPLEMENTATION.


  METHOD execute.

    TYPES:
      BEGIN OF ty_gsber,
        gsber TYPE gsber,
      END OF ty_gsber.

    DATA: lt_gsber          TYPE STANDARD TABLE OF ty_gsber,
          lt_accountpayable TYPE STANDARD TABLE OF bapiacap09,
          lt_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
          lt_return         TYPE STANDARD TABLE OF bapiret2,
          lt_accountgl      TYPE STANDARD TABLE OF bapiacgl09.

    DATA: lr_craz40 TYPE RANGE OF saknr,
          lr_craz50 TYPE RANGE OF saknr,
          lr_blart  TYPE RANGE OF blart.

    DATA: ls_gsber TYPE ty_gsber.

    DATA: lv_bonus_cal TYPE ze_bonus_calcul,
          lv_bonus_rat TYPE ze_bonus_calcul,
          lv_totline   TYPE i,
          lv_item      TYPE posnr_acc,
          lv_obj_type  TYPE bapiache09-obj_type,
          lv_obj_key   TYPE bapiache09-obj_key,
          lv_obj_sys   TYPE bapiache09-obj_sys.

    CONSTANTS: lc_cres     TYPE char10     VALUE 'CRESC-',
               lc_cres_atr TYPE acpi_zuonr VALUE 'CRESCIMENTO',
               lc_moeda    TYPE waers      VALUE 'BRL',
               lc_40       TYPE acpi_kstaz VALUE 'S',
               lc_50       TYPE acpi_kstaz VALUE 'H',
               lc_error    TYPE sy-msgty   VALUE 'E'.

    SELECT ajuste_anual,
           bukrs,
           nome_fantasia
      FROM ztfi_contrato
     WHERE contrato = @is_key-contrato
       AND aditivo  = @is_key-aditivo
      INTO @DATA(ls_contrt)
        UP TO 1 ROWS.
    ENDSELECT.

    SELECT contrato,
           aditivo,
           periodicidade
      FROM ztfi_cad_cresci
     WHERE contrato = @is_key-contrato
       AND aditivo  = @is_key-aditivo
      INTO @DATA(ls_cresci)
        UP TO 1 ROWS.
    ENDSELECT.

    SELECT contrato,
           aditivo,
           bukrs,
           belnr,
           gjahr,
           buzei,
           ajuste_anual,
           gsber,
           familia_cl,
           spart,
           bzirk,
           vtweg,
           prctr,
           bonus_calculado
      FROM ztfi_calc_cresci
     WHERE contrato     = @is_key-contrato
       AND aditivo      = @is_key-aditivo
       AND ajuste_anual = @ls_contrt-ajuste_anual
      INTO TABLE @DATA(lt_cresci).

    IF sy-subrc IS INITIAL.
      SORT lt_cresci BY contrato
                        aditivo.

      DATA(lt_cresci_fae) = lt_cresci[].
      SORT lt_cresci_fae BY bzirk
                            vtweg.

      DELETE ADJACENT DUPLICATES FROM lt_cresci_fae COMPARING bzirk
                                                              vtweg.

      SELECT region,
*             canal,
*             setor,
             kostl
        FROM ztfi_cad_cc
         FOR ALL ENTRIES IN @lt_cresci_fae
       WHERE region = @lt_cresci_fae-bzirk
*         AND canal  = @lt_cresci_fae-vtweg
*         AND setor  = @lt_cresci_fae-spart
        INTO TABLE @DATA(lt_cad_cc).

      IF sy-subrc IS INITIAL.

        SORT lt_cad_cc BY kostl.
        DELETE ADJACENT DUPLICATES FROM lt_cad_cc COMPARING kostl.


        CLEAR lv_bonus_cal.
        lv_bonus_cal = is_key-mont_crescimento.

        LOOP AT lt_cresci ASSIGNING FIELD-SYMBOL(<fs_crescimento>).
          ls_gsber-gsber = <fs_crescimento>-gsber.
          APPEND ls_gsber TO lt_gsber.
        ENDLOOP.

        SORT: lt_gsber BY gsber.
        DELETE ADJACENT DUPLICATES FROM lt_gsber COMPARING gsber.

        SELECT kostl, prctr
        FROM csks
        INTO TABLE @DATA(lt_csks)
        FOR ALL ENTRIES IN @lt_cad_cc
        WHERE kostl = @lt_cad_cc-kostl
         AND datbi >= @sy-datum.

        SORT: lt_csks BY kostl.

        DATA(lv_line1) = lines( lt_gsber ).
        DATA(lv_line2) = lines( lt_cad_cc ).

        lv_totline = lv_line1 * lv_line2.

        " Total Rateado
        lv_bonus_rat = lv_bonus_cal / lv_totline.


        DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

        TRY.
            lo_param->m_get_range( EXPORTING iv_modulo = gc_prm_modulo
                                             iv_chave1 = 'CRESCIMENTO'
                                             iv_chave2 = 'CONTARAZAO40'
                                   IMPORTING et_range  = lr_craz40 ).

          CATCH zcxca_tabela_parametros.
            RETURN.
        ENDTRY.

        DATA(ls_craz) = lr_craz40[ 1 ].

        TRY.
            lo_param->m_get_range( EXPORTING iv_modulo = gc_prm_modulo
                                             iv_chave1 = 'CRESCIMENTO'
                                             iv_chave2 = 'CONTARAZAO50'
                                   IMPORTING et_range  = lr_craz50 ).

          CATCH zcxca_tabela_parametros.
            RETURN.
        ENDTRY.

        DATA(ls_craz2) = lr_craz50[ 1 ].

        TRY.
            lo_param->m_get_range( EXPORTING iv_modulo = gc_prm_modulo
                                             iv_chave1 = 'CRESCIMENTO'
                                             iv_chave2 = 'TIPODOC'
                                             iv_chave3 = 'LANCAR'
                                   IMPORTING et_range  = lr_blart ).

          CATCH zcxca_tabela_parametros.
            RETURN.
        ENDTRY.

        DATA(ls_blart) = lr_blart[ 1 ].

        DATA(ls_docheader) = VALUE bapiache09( doc_date   = sy-datum
                                               pstng_date = is_key-budat_screen
                                               doc_type   = ls_blart-low
                                               comp_code  = ls_contrt-bukrs
                                               fis_period = is_key-budat_screen+4(2)
                                               ref_doc_no = ls_cresci-periodicidade
                                               username   = sy-uname
                                               header_txt = text-001 ).



        LOOP AT lt_gsber ASSIGNING FIELD-SYMBOL(<fs_gsber>).

          LOOP AT lt_cad_cc ASSIGNING FIELD-SYMBOL(<fs_kostl>). "#EC CI_NESTED


            READ TABLE lt_csks ASSIGNING FIELD-SYMBOL(<fs_csks>) WITH KEY kostl = <fs_kostl>-kostl
                                                                              BINARY SEARCH.

            IF sy-subrc <> 0.
              "Erro centro de custo valida
            ENDIF.

            lv_item = lv_item + 1.

            lt_accountgl = VALUE #( BASE lt_accountgl ( itemno_acc = lv_item
                                                        bus_area   = <fs_gsber>-gsber
                                                        gl_account = ls_craz-low
                                                        alloc_nmbr = lc_cres_atr
                                                        item_text  = |{ lc_cres }{ ls_contrt-nome_fantasia }|
                                                        costcenter = <fs_kostl>-kostl
                                                        profit_ctr = <fs_csks>-prctr
                                                        segment    = space ) ).

            lt_currencyamount = VALUE #( BASE lt_currencyamount ( itemno_acc = lv_item
                                                                  currency   = lc_moeda
                                                                  amt_doccur = lv_bonus_rat ) ).

            lv_item = lv_item + 1.

            lt_accountgl = VALUE #( BASE lt_accountgl ( itemno_acc = lv_item
                                                        bus_area   = <fs_gsber>-gsber
                                                        gl_account = ls_craz2-low
                                                        alloc_nmbr = lc_cres_atr
                                                        item_text  = |{ lc_cres }{ ls_contrt-nome_fantasia }|
                                                        costcenter = <fs_kostl>-kostl
                                                        profit_ctr = <fs_csks>-prctr
                                                        segment    = space ) ).

            lt_currencyamount = VALUE #( BASE lt_currencyamount ( itemno_acc = lv_item
                                                                  currency   = lc_moeda
                                                                  amt_doccur = lv_bonus_rat * -1 ) ).

          ENDLOOP.
        ENDLOOP.

        IF lt_accountgl[] IS NOT INITIAL.
          CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
            EXPORTING
              documentheader = ls_docheader
            IMPORTING
              obj_type       = lv_obj_type
              obj_key        = lv_obj_key
              obj_sys        = lv_obj_sys
            TABLES
              accountgl      = lt_accountgl
              currencyamount = lt_currencyamount
              return         = lt_return.

          IF line_exists( lt_return[ type = lc_error ] ). "#EC CI_STDSEQ

            "Erro no lançamento da contabilização
            et_return = VALUE #( ( id = 'ZFI_BASE_CALCULO'
                                   type = 'E'
                                   number = 036 ) ).
            APPEND LINES OF lt_return TO et_return.

          ELSE.

            UPDATE ztfi_log_clcresc
                SET belnr = lv_obj_key(10)
                    gjahr = lv_obj_key+14(4)
                 WHERE contrato = is_key-contrato
                   AND aditivo = is_key-aditivo.

            "Nº Doc. & Empresa & Exercício & Contabilizado com Sucesso
            et_return = VALUE #( ( id = 'ZFI_BASE_CALCULO'
                                   type = 'S'
                                   number = 037
                                   message_v1 = lv_obj_key(10)
                                   message_v2 = lv_obj_key+10(4)
                                   message_v3 = lv_obj_key+14(4) ) ).

            DATA(ls_key) = VALUE zsfi_cresc_copa_key( contrato = is_key-contrato
                                                      aditivo  = is_key-aditivo
                                                      mont_crescimento = is_key-mont_crescimento ).

            CALL FUNCTION 'ZFMFI_CRESCI_CRAT_COPA'
              EXPORTING
                is_key    = ls_key
              IMPORTING
                et_return = lt_return.

            APPEND LINES OF lt_return TO et_return.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
