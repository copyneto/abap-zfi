*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_AUTBANC_DIR................................*
DATA:  BEGIN OF STATUS_ZTFI_AUTBANC_DIR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_AUTBANC_DIR              .
CONTROLS: TCTRL_ZTFI_AUTBANC_DIR
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_AUTBANC_DIR              .
TABLES: ZTFI_AUTBANC_DIR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
