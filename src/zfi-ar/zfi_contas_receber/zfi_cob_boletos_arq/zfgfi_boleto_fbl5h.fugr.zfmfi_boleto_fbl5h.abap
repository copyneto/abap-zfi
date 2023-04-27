FUNCTION zfmfi_boleto_fbl5h.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IS_KEY) TYPE  ZCTGFI_BOLETO_DOCUMENTO
*"----------------------------------------------------------------------

  gt_key = is_key.

  CALL SCREEN 9001 STARTING AT 1 1
                     ENDING   AT 50 5.



ENDFUNCTION.
