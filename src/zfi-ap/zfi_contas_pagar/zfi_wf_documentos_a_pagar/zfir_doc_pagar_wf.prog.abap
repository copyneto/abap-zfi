***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: JOB - Atualização de Documentos                        *
*** AUTOR    : Bruno Costa – META                                     *
*** FUNCIONAL: Raphael Rocha – META                                   *
*** DATA     : 12.08.2022                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR                 | DESCRIÇÃO                     *
***-------------------------------------------------------------------*
*** 12.08.22  | Bruno Costa           | Criação do programa           *
***********************************************************************
REPORT zfir_doc_pagar_wf.
**********************************************************************
* Tela de Seleção
**********************************************************************
PARAMETERS: p_belnr TYPE belnr_d,
            p_bukrs TYPE bukrs,
            p_gjahr TYPE gjahr,
            p_buzei TYPE buzei,
            p_zlspr TYPE dzlspr,
            p_stgrd TYPE stgrd,
            p_pymnt TYPE flag,
            p_rever TYPE flag.
**********************************************************************
* Inicio da Seleção
**********************************************************************
START-OF-SELECTION.

  IF p_pymnt EQ abap_true.

    DATA: ls_bseg   TYPE bseg,
          lt_buztab TYPE tpit_t_buztab,
          lt_fldtab TYPE tpit_t_fname,
          lt_errtab TYPE tpit_t_errdoc.

    DATA: lv_wf TYPE char02.

    lv_wf = abap_true.

    EXPORT lv_wf FROM lv_wf TO MEMORY ID 'ZCLFI_DOC_PAGAR_WF'.

    SELECT bukrs belnr gjahr buzei koart bschl
    APPENDING CORRESPONDING FIELDS OF TABLE lt_buztab
      FROM bseg
     WHERE bukrs EQ p_bukrs
       AND belnr EQ p_belnr
       AND gjahr EQ p_gjahr
       AND buzei EQ p_buzei.

    ls_bseg-zlspr = p_zlspr.

    APPEND INITIAL LINE TO lt_fldtab ASSIGNING FIELD-SYMBOL(<fs_fldtab>).
    <fs_fldtab>-fname = 'ZLSPR'.

    IF NOT lt_buztab[] IS INITIAL.

      CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
        EXPORTING
          s_bseg     = ls_bseg
        IMPORTING
          errtab     = lt_errtab[]
        TABLES
          it_buztab  = lt_buztab
          it_fldtab  = lt_fldtab
        EXCEPTIONS
          bdc_errors = 1
          OTHERS     = 2.

      IF sy-subrc EQ 0.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

      ENDIF.

    ENDIF.

  ELSEIF p_rever EQ abap_true.

    CALL FUNCTION 'CALL_FB08'
      EXPORTING
        i_bukrs      = p_bukrs
        i_belnr      = p_belnr
        i_gjahr      = p_gjahr
        i_stgrd      = p_stgrd
      EXCEPTIONS
        not_possible = 1
        OTHERS       = 2.

    IF sy-subrc EQ 0.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*       EXPORTING
*         WAIT          =
*       IMPORTING
*         RETURN        =
        .

    ENDIF.

  ENDIF.
