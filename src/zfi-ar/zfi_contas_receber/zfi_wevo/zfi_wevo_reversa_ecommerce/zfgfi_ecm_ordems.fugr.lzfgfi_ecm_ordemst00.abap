*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_ECM_ORDEMSD................................*
DATA:  BEGIN OF STATUS_ZTFI_ECM_ORDEMSD              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_ECM_ORDEMSD              .
CONTROLS: TCTRL_ZTFI_ECM_ORDEMSD
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_ECM_ORDEMSD              .
TABLES: ZTFI_ECM_ORDEMSD               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
