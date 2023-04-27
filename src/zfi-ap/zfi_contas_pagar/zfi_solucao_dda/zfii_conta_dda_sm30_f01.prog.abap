***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Conta p/ juros ou desconto DDA                         *
*** AUTOR : Anderson Miazato - META                                   *
*** FUNCIONAL: Fernando Siqueira - META                               *
*** DATA : 13.10.2021                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 13.10.2021 | Anderson Miazato   | Desenvolvimento inicial         *
***********************************************************************
*----------------------------------------------------------------------*
***INCLUDE ZFII_CONTA_DDA_SM30_F01.
*----------------------------------------------------------------------*
FORM f_fill_system_fields.

  GET TIME STAMP FIELD DATA(lv_now).

  ztfi_conta_dda-created_by = COND #( WHEN ztfi_conta_dda-created_by IS INITIAL THEN sy-uname ).
  ztfi_conta_dda-created_at = COND #( WHEN ztfi_conta_dda-created_at IS INITIAL THEN lv_now ).

  ztfi_conta_dda-last_changed_by = sy-uname.
  ztfi_conta_dda-last_changed_at = lv_now.
  ztfi_conta_dda-local_last_changed_at = lv_now.

ENDFORM.
