FUNCTION zfmfi_ret_bloq.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_LINHA) TYPE  ZSFI_RETIRA_BLOQ OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  CONSTANTS gc_zfi_cont_rcb TYPE msgid VALUE 'ZFI_CONT_RCB' ##NO_TEXT.
  CONSTANTS gc_e TYPE msgid VALUE 'E' ##NO_TEXT.
  CONSTANTS gc_s TYPE msgid VALUE 'S' ##NO_TEXT.
  CONSTANTS gc_modulo TYPE ze_param_modulo VALUE 'FI' ##NO_TEXT.
  CONSTANTS gc_chave1 TYPE ze_param_chave VALUE 'EMP2000' ##NO_TEXT.
  CONSTANTS gc_chave2 TYPE ze_param_chave VALUE 'RET_BLOQ_FAT' ##NO_TEXT.
  CONSTANTS gc_bloqueio TYPE ze_param_chave_3 VALUE 'BLOQUEIO' ##NO_TEXT.
  CONSTANTS gc_horas TYPE ze_param_chave_3 VALUE 'HORAS' ##NO_TEXT.


  DATA lt_buztab TYPE tpit_t_buztab.
  DATA lt_fldtab TYPE tpit_t_fname.
  DATA lt_errtab TYPE tpit_t_errdoc.
  DATA lt_log    TYPE TABLE OF zsfi_retira_bloq.



  "===== Verificar duração =====
  DATA lv_dif TYPE fahztd.
  DATA lr_horas TYPE RANGE OF fahztd.

  DATA(lo_param) = NEW zclca_tabela_parametros( ).

  TRY.
      lo_param->m_get_range( EXPORTING iv_modulo = 'FI'
                                       iv_chave1 = gc_chave1
                                       iv_chave2 = gc_chave2
                                       iv_chave3 = gc_horas
                             IMPORTING et_range  = lr_horas ).

    CATCH zcxca_tabela_parametros.
  ENDTRY.

  IF lr_horas IS NOT INITIAL.


    CLEAR lv_dif.

    CALL FUNCTION 'SD_CALC_DURATION_FROM_DATETIME'
      EXPORTING
        i_date1          = is_linha-cpudt
        i_time1          = is_linha-cputm
        i_date2          = sy-datum
        i_time2          = sy-uzeit
      IMPORTING
        e_tdiff          = lv_dif
      EXCEPTIONS
        invalid_datetime = 1
        OTHERS           = 2.

    DATA(lv_cad_time_string) = |{ lr_horas[ 1 ]-low }0000|.
    DATA(lv_cad_time) = CONV fahztd( lv_cad_time_string ).
    IF sy-subrc IS INITIAL.
      IF lv_dif LT lv_cad_time.
        "Documento ainda não possui prazo minimo para lib.
        et_return = VALUE #( (  id       = gc_zfi_cont_rcb
                                number   = 015
                                type = gc_e )
                              (  id       = gc_zfi_cont_rcb
                                number   = 014
                                type = gc_s ) ).
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.



  DATA(ls_bseg) = VALUE bseg(
        bukrs = is_linha-bukrs
        belnr = is_linha-belnr
        gjahr = is_linha-gjahr
        buzei = is_linha-buzei
        bschl = is_linha-bschl
        koart = is_linha-koart
        zlspr = space ).

  APPEND INITIAL LINE TO lt_buztab ASSIGNING FIELD-SYMBOL(<fs_buztab>).
  <fs_buztab>-bukrs = is_linha-bukrs.
  <fs_buztab>-belnr = is_linha-belnr.
  <fs_buztab>-gjahr = is_linha-gjahr.
  <fs_buztab>-buzei = is_linha-buzei.
  <fs_buztab>-bschl = is_linha-bschl.
  <fs_buztab>-koart = is_linha-koart.

  APPEND INITIAL LINE TO lt_fldtab ASSIGNING FIELD-SYMBOL(<fs_field>).
  <fs_field>-fname = 'ZLSPR'.
  <fs_field>-aenkz = abap_true.


  CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
  "#EC CI_IMUD_NESTED
  "#EC CI_SEL_NESTED
    EXPORTING
      s_bseg     = ls_bseg
    IMPORTING
      errtab     = lt_errtab
    TABLES
      it_buztab  = lt_buztab
      it_fldtab  = lt_fldtab
    EXCEPTIONS
      bdc_errors = 1
      OTHERS     = 2.

  IF sy-subrc IS INITIAL
    AND sy-batch IS NOT INITIAL.

    "Erro ao tentar retirar bloqueio: &1 &2 &3
    et_return = VALUE #( (  id       = gc_zfi_cont_rcb
                            number   = 013
                            type = gc_e )
                          (  id       = gc_zfi_cont_rcb
                            number   = 014
                            type = gc_s ) ).
  ELSE.

    "Documento &1 &2 &3 retirado bloqueio.
    et_return = VALUE #( (  id       = gc_zfi_cont_rcb
                            number   = 016
                            type = gc_s
                            message_v1 = is_linha-bukrs
                            message_v2 = is_linha-belnr
                            message_v3 = is_linha-gjahr )
                          (  id       = gc_zfi_cont_rcb
                            number   = 014
                            type = gc_s ) ).
  ENDIF.

  CLEAR:  lt_fldtab,  lt_buztab, ls_bseg, lt_errtab.



ENDFUNCTION.
