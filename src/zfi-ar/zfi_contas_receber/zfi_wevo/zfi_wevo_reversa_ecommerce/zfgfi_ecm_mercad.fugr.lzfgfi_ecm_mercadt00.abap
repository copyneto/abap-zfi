*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_ECM_MERCADR................................*
DATA:  BEGIN OF STATUS_ZTFI_ECM_MERCADR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_ECM_MERCADR              .
CONTROLS: TCTRL_ZTFI_ECM_MERCADR
            TYPE TABLEVIEW USING SCREEN '9000'.
*.........table declarations:.................................*
TABLES: *ZTFI_ECM_MERCADR              .
TABLES: ZTFI_ECM_MERCADR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
