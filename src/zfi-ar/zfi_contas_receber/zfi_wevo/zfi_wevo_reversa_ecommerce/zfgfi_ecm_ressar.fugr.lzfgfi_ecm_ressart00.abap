*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_ECM_RESSARC................................*
DATA:  BEGIN OF STATUS_ZTFI_ECM_RESSARC              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_ECM_RESSARC              .
CONTROLS: TCTRL_ZTFI_ECM_RESSARC
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_ECM_RESSARC              .
TABLES: ZTFI_ECM_RESSARC               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
