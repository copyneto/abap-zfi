*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVFI_AUTBANC_LOG................................*
TABLES: ZVFI_AUTBANC_LOG, *ZVFI_AUTBANC_LOG. "view work areas
CONTROLS: TCTRL_ZVFI_AUTBANC_LOG
TYPE TABLEVIEW USING SCREEN '9000'.
DATA: BEGIN OF STATUS_ZVFI_AUTBANC_LOG. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZVFI_AUTBANC_LOG.
* Table for entries selected to show on screen
DATA: BEGIN OF ZVFI_AUTBANC_LOG_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZVFI_AUTBANC_LOG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVFI_AUTBANC_LOG_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZVFI_AUTBANC_LOG_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZVFI_AUTBANC_LOG.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZVFI_AUTBANC_LOG_TOTAL.

*.........table declarations:.................................*
TABLES: ZTFI_AUTBANC_LOG               .
