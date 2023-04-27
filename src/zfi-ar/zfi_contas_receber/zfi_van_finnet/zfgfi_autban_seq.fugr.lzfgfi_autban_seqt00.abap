*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_AUTBANC_SEQ................................*
DATA:  BEGIN OF STATUS_ZTFI_AUTBANC_SEQ              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_AUTBANC_SEQ              .
CONTROLS: TCTRL_ZTFI_AUTBANC_SEQ
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTFI_AUTBANC_SEQ              .
TABLES: ZTFI_AUTBANC_SEQ               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
