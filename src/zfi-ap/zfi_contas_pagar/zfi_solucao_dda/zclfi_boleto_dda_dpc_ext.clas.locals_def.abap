*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

CONSTANTS:
  BEGIN OF gc_entity,
    PdfFile       TYPE string VALUE 'PdfFile',
    downloadcheck TYPE string VALUE 'DownloadCheck',
    Memory        TYPE string VALUE 'Memory',
  END OF gc_entity.
