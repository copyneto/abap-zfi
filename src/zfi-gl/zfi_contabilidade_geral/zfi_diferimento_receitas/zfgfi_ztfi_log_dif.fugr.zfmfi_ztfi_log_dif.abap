FUNCTION ZFMFI_ZTFI_LOG_DIF.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IT_ZTFI_LOG_DIF) TYPE  ZCTGFI_ZTFI_LOG_DIF
*"     VALUE(IT_ZTFI_LOG_DIF_MSG) TYPE  ZCTGFI_ZTFI_LOG_DIF_MSG
*"----------------------------------------------------------------------

  MODIFY ztfi_log_dif     FROM TABLE IT_ZTFI_LOG_DIF.
  MODIFY ztfi_log_dif_msg FROM TABLE it_ztfi_log_dif_msg.
  commit work and wait.

ENDFUNCTION.
