*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_ECM_CENAR..................................*
DATA:  BEGIN OF STATUS_ZTFI_ECM_CENAR                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_ECM_CENAR                .
CONTROLS: TCTRL_ZTFI_ECM_CENAR
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_ECM_CENAR                .
TABLES: ZTFI_ECM_CENAR                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
