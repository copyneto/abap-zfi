*&---------------------------------------------------------------------*
*& Include zfii_fill_zlspr
*&---------------------------------------------------------------------*
  DATA: lr_hbkid TYPE RANGE OF bseg-hbkid,
        lr_zlspr TYPE RANGE OF bseg-zlspr,
        lr_blart TYPE RANGE OF bkpf-blart.

  CONSTANTS:
    BEGIN OF lc_param,
      modulo   TYPE ztca_param_par-modulo VALUE 'FI',
      emp      TYPE ztca_param_par-chave1 VALUE 'EMP',
      bloq     TYPE ztca_param_par-chave2 VALUE 'BOL_BLOQUEIO',
      bancoemp TYPE ztca_param_par-chave2 VALUE 'BOL_BANCOEMPRESA',
      tipodoc  TYPE ztca_param_par-chave2 VALUE 'BOL_TIPODEDOCUMENTO',
    END OF lc_param.

  CLEAR: lr_hbkid[],
         lr_zlspr[].

  DATA(lo_param) = NEW zclca_tabela_parametros( ).

  TRY.
      lo_param->m_get_range( EXPORTING iv_modulo = lc_param-modulo
                                       iv_chave1 = |{ lc_param-emp }{ bseg-bukrs }|
                                       iv_chave2 = lc_param-tipodoc
                             IMPORTING et_range  = lr_blart ).
    CATCH zcxca_tabela_parametros INTO DATA(lo_cx).
      WRITE lo_cx->get_text( ).
  ENDTRY.
  IF bkpf-blart NOT IN lr_blart.
    RETURN.
  ENDIF.

  TRY.
      lo_param->m_get_range( EXPORTING iv_modulo = lc_param-modulo
                                       iv_chave1 = |{ lc_param-emp }{ bseg-bukrs }|
                                       iv_chave2 = lc_param-bloq
                             IMPORTING et_range  = lr_zlspr ).

      lo_param->m_get_range( EXPORTING iv_modulo = lc_param-modulo
                                       iv_chave1 = |{ lc_param-emp }{ bseg-bukrs }|
                                       iv_chave2 = lc_param-bancoemp
                             IMPORTING et_range  = lr_hbkid ).

    CATCH zcxca_tabela_parametros INTO lo_cx.
      WRITE lo_cx->get_text( ).
  ENDTRY.


  IF lr_zlspr IS NOT INITIAL.
    DATA(ls_zlspr) = lr_zlspr[ 1 ].
    IF sy-subrc = 0.
      bseg-zlspr = CONV dzlspr( ls_zlspr-low ).
    ENDIF.
  ENDIF.

  IF lr_hbkid IS NOT INITIAL.
    DATA(ls_hbkid) = lr_hbkid[ 1 ].
    IF sy-subrc = 0.
      bseg-hbkid = CONV hbkid( ls_hbkid-low ).
    ENDIF.
  ENDIF.
