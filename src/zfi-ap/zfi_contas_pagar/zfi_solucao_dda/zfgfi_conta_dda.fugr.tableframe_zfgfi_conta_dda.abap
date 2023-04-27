*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZFGFI_CONTA_DDA
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZFGFI_CONTA_DDA    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
