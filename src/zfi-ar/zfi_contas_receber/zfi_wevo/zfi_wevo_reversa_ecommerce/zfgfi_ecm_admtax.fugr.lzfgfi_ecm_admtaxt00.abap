*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_ECM_ADM_TAX................................*
DATA:  BEGIN OF STATUS_ZTFI_ECM_ADM_TAX              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_ECM_ADM_TAX              .
CONTROLS: TCTRL_ZTFI_ECM_ADM_TAX
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_ECM_ADM_TAX              .
TABLES: ZTFI_ECM_ADM_TAX               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
