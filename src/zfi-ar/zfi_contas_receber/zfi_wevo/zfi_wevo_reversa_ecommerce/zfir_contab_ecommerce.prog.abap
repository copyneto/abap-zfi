***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: WEVO - Contabilização do E-Commerce                    *
*** AUTOR    : Alysson Anjos – META                                   *
*** FUNCIONAL: Raphael Rocha – META                                   *
*** DATA     : 24/11/2021                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR        | DESCRIÇÃO                              *
***-------------------------------------------------------------------*
***           |              |                                        *
***********************************************************************
*&---------------------------------------------------------------------*
*& Report ZFIR_CONTAB_ECOMMERCE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfir_contab_ecommerce.
TABLES: ztfi_wevo_contab.

SELECTION-SCREEN BEGIN OF BLOCK a1.

  SELECT-OPTIONS: s_bstkd FOR ztfi_wevo_contab-bstkd.

  PARAMETERS: p_nomsg TYPE char1 NO-DISPLAY.

SELECTION-SCREEN END OF BLOCK a1.

START-OF-SELECTION.

  PERFORM f_main.

*&---------------------------------------------------------------------*
*&      Form  F_MAIN
*&---------------------------------------------------------------------*
FORM f_main.

  DATA: lt_processados TYPE STANDARD TABLE OF ztfi_wevo_contab,
        lt_retorno     TYPE STANDARD TABLE OF zsfi_retrn_ctreversa,
        lt_retorno_aux TYPE STANDARD TABLE OF zsfi_retrn_ctreversa,
        lt_contab      TYPE STANDARD TABLE OF ztfi_wevo_contab.

  DATA: ls_processados TYPE ztfi_wevo_contab.

  DATA: lv_subrc   TYPE  sy-subrc,
        lv_msg     TYPE  bapi_msg,
        lv_belnr   TYPE  bseg-belnr,
        lv_gjahr   TYPE  bseg-gjahr,
        lv_bukrs   TYPE  bseg-bukrs,
        lv_belnr_f TYPE  bseg-belnr,
        lv_gjahr_f TYPE  bseg-gjahr,
        lv_bukrs_f TYPE  bseg-bukrs.

  SELECT *
    FROM ztfi_wevo_contab
   WHERE bstkd IN @s_bstkd " Se estiver em branco deve buscar tudo
    INTO TABLE @lt_contab.

  IF lt_contab[] IS NOT INITIAL.

    DATA(lo_contab) = NEW zclfi_contab_reversa( ).

    FREE: lt_retorno_aux[].
    lo_contab->valida_reversa( IMPORTING et_retorno = lt_retorno_aux[]
                                CHANGING ct_contab  = lt_contab[] ).

    IF lt_retorno_aux[] IS NOT INITIAL.
      APPEND LINES OF lt_retorno_aux TO lt_retorno.

      LOOP AT lt_retorno_aux ASSIGNING FIELD-SYMBOL(<fs_retorno>).
        IF <fs_retorno>-bstkd IS NOT INITIAL.
          ls_processados-bstkd = <fs_retorno>-bstkd.
          APPEND ls_processados TO lt_processados.
          CLEAR ls_processados.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lt_contab[] IS NOT INITIAL.

      FREE: lt_retorno_aux[].
      lo_contab->contabiliza_reversa( EXPORTING it_contab  = lt_contab[]
                                      IMPORTING et_retorno = lt_retorno_aux[] ).
      IF lt_retorno_aux[] IS NOT INITIAL.
        APPEND LINES OF lt_retorno_aux TO lt_retorno.

        LOOP AT lt_retorno_aux ASSIGNING <fs_retorno>.
          IF <fs_retorno>-subrc = 0
         AND <fs_retorno>-bstkd IS NOT INITIAL
         AND <fs_retorno>-belnr IS NOT INITIAL.
            ls_processados-bstkd = <fs_retorno>-bstkd.
            APPEND ls_processados TO lt_processados.
            CLEAR ls_processados.
          ENDIF.
        ENDLOOP.

        IF lt_processados[] IS NOT INITIAL.
          DELETE ztfi_wevo_contab FROM TABLE lt_processados.
          IF sy-subrc IS INITIAL.
            COMMIT WORK AND WAIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF p_nomsg IS INITIAL.
      " Exibir no LOG do JOB
      LOOP AT lt_retorno ASSIGNING <fs_retorno>.

        WRITE: / <fs_retorno>-msg.

      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.
