FUNCTION zfmfi_download_file_fdta.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IT_REGUT) TYPE  EPIC_T_REGUT
*"----------------------------------------------------------------------

  PERFORM zcall_fdta(sapmfdta) USING it_regut.

ENDFUNCTION.
