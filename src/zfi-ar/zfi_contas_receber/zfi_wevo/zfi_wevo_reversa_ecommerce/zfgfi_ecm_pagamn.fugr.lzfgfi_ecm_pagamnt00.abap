*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_ECM_PAGAMNT................................*
DATA:  BEGIN OF STATUS_ZTFI_ECM_PAGAMNT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_ECM_PAGAMNT              .
CONTROLS: TCTRL_ZTFI_ECM_PAGAMNT
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_ECM_PAGAMNT              .
TABLES: ZTFI_ECM_PAGAMNT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
