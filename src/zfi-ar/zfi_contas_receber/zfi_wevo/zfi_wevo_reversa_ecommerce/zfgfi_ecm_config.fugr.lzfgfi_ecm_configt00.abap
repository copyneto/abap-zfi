*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_ECM_CONFIG.................................*
DATA:  BEGIN OF STATUS_ZTFI_ECM_CONFIG               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_ECM_CONFIG               .
CONTROLS: TCTRL_ZTFI_ECM_CONFIG
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_ECM_CONFIG               .
TABLES: ZTFI_ECM_CONFIG                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
