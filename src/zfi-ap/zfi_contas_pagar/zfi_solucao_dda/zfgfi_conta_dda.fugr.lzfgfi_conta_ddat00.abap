*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTFI_CONTA_DDA..................................*
DATA:  BEGIN OF STATUS_ZTFI_CONTA_DDA                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTFI_CONTA_DDA                .
CONTROLS: TCTRL_ZTFI_CONTA_DDA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZTFI_CONTA_DDA                .
TABLES: ZTFI_CONTA_DDA                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
