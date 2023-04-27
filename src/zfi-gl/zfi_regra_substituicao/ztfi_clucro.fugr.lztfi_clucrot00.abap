*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_CLUCRO.....................................*
DATA:  BEGIN OF STATUS_ZTFI_CLUCRO                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_CLUCRO                   .
CONTROLS: TCTRL_ZTFI_CLUCRO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTFI_CLUCRO                   .
TABLES: ZTFI_CLUCRO                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
