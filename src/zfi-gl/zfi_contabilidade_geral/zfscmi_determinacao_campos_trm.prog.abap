***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Preenchimentos de campos TRM                           *
*** AUTOR : Luciano Casado - GFX Consultoria                          *
*** FUNCIONAL: Joelson Matias - 3Corações                             *
*** DATA : 13.01.2023                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 13.01.2023 | Luciano Casado   | Desenvolvimento inicial           *
***********************************************************************


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Obtendo o centro de lucro para preencher                          "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

IF ch_accit_c-prctr IS INITIAL OR ch_accit_d-prctr IS INITIAL.
  "Buscando o centro de custo
  SELECT SINGLE kostl
    FROM tracc_addaccdata
    INTO @DATA(lv_kostl)
    WHERE company_code = @im_data-company_code
      AND aa_ref       = @im_data-aa_ref.

  IF sy-subrc IS INITIAL.
    "Obtendo o centro de lucro
    SELECT SINGLE prctr
      FROM csks
      INTO @DATA(lv_prctr)
      WHERE kokrs = 'AC3C'
        AND kostl = @lv_kostl
        AND datbi = '99991231'.
  ENDIF.

  "Preenchendo centro de lucro
  IF ch_accit_c-prctr IS INITIAL.
    ch_accit_c-prctr = lv_prctr.
  ENDIF.

  IF ch_accit_d-prctr IS INITIAL.
    ch_accit_d-prctr = lv_prctr.
  ENDIF.
ENDIF.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Obtendo o segmento para preencher                                 "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
IF ch_accit_c-segment IS INITIAL AND ch_accit_c-prctr IS NOT INITIAL.
  SELECT SINGLE segment
    FROM cepc
    INTO @ch_accit_c-segment
    WHERE kokrs = 'AC3C'
      AND prctr = @ch_accit_c-prctr
      AND datbi = '99991231'.
ENDIF.

IF ch_accit_d-segment IS INITIAL AND ch_accit_d-prctr IS NOT INITIAL.
  SELECT SINGLE segment
    FROM cepc
    INTO @ch_accit_d-segment
    WHERE kokrs = 'AC3C'
      AND prctr = @ch_accit_d-prctr
      AND datbi = '99991231'.
ENDIF.
