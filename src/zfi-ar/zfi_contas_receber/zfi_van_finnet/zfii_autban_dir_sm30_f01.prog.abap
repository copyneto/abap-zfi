***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Config. diretórios p/ automatização Bancária VAN FINNET*
*** AUTOR : Anderson Miazato - META                                   *
*** FUNCIONAL: Raphael Rocha - META                                   *
*** DATA : 15.10.2021                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 15.10.2021 | Anderson Miazato   | Desenvolvimento inicial         *
***********************************************************************

*----------------------------------------------------------------------*
***INCLUDE ZFII_AUTBAN_DIR_SM30_F01.
*----------------------------------------------------------------------*
FORM f_fill_system_fields.

  GET TIME STAMP FIELD DATA(lv_now).

  ztfi_autbanc_dir-created_by = COND #( WHEN ztfi_autbanc_dir-created_by IS INITIAL THEN sy-uname ).
  ztfi_autbanc_dir-created_at = COND #( WHEN ztfi_autbanc_dir-created_at IS INITIAL THEN lv_now ).

  ztfi_autbanc_dir-last_changed_by = sy-uname.
  ztfi_autbanc_dir-last_changed_at = lv_now.
  ztfi_autbanc_dir-local_last_changed_at = lv_now.

ENDFORM.
