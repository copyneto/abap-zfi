*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

TYPES:
  BEGIN OF ty_approver,
    bukrs             TYPE bukrs,
    fdgrv             TYPE fdgrv,
    uname             TYPE uname,
    nivel             TYPE ze_nivel_aprov,
    hora              TYPE uzeit,
    tiporel           TYPE ze_tiporel,
*    encerrador        TYPE ze_aprov,
*    aprov1            TYPE ze_aprov,
*    aprov2            TYPE ze_aprov,
*    aprov3            TYPE ze_aprov,
*    encerradorcrit(1) TYPE c,
*    aprov1crit(1)     TYPE c,
*    aprov2crit(1)     TYPE c,
*    aprov3crit(1)     TYPE c,
*    encerradortext    TYPE text10,
*    aprov1text        TYPE text10,
*    aprov2text        TYPE text10,
*    aprov3text        TYPE text10,
  END OF ty_approver.

CONSTANTS:
  gc_mg_id TYPE sy-msgid VALUE 'ZFI_APRV_PGTO',

  BEGIN OF gc_msg_no,
    m_000 TYPE sy-msgno VALUE '000',
    m_001 TYPE sy-msgno VALUE '001',
    m_002 TYPE sy-msgno VALUE '002',
  END OF gc_msg_no.
