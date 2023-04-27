*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_ECM_PARAMTR................................*
DATA:  BEGIN OF STATUS_ZTFI_ECM_PARAMTR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_ECM_PARAMTR              .
CONTROLS: TCTRL_ZTFI_ECM_PARAMTR
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_ECM_PARAMTR              .
TABLES: ZTFI_ECM_PARAMTR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
