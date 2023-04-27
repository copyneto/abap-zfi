*&---------------------------------------------------------------------*
*& Include LZFGFI_SOL_CORRECAOO01
*&---------------------------------------------------------------------*
MODULE tbc_sol_correc_change_tc_attr OUTPUT.
  DESCRIBE TABLE gt_itens LINES tbc_sol_correc-lines.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'STANDARD'.
ENDMODULE.
