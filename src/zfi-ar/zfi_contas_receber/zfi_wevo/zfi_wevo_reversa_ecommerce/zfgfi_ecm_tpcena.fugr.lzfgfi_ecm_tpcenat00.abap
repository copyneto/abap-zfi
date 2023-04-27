*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_ECM_TPCENAR................................*
DATA:  BEGIN OF STATUS_ZTFI_ECM_TPCENAR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_ECM_TPCENAR              .
CONTROLS: TCTRL_ZTFI_ECM_TPCENAR
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_ECM_TPCENAR              .
TABLES: ZTFI_ECM_TPCENAR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
