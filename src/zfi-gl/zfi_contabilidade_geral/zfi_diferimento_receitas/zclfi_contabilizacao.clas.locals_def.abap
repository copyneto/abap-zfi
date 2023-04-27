*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
CONSTANTS:
  gc_BillingDocumentType TYPE fkart VALUE 'Z002',
  gc_type                TYPE char4 VALUE 'TMFU',
  gc_type_c              TYPE char4 VALUE 'C',
  gc_cod                 TYPE stgrd VALUE '06',
  gc_dif                 TYPE /scmtms/tor_event VALUE 'DIFERIMENTO',
  gc_entr_cli            TYPE /scmtms/tor_event VALUE 'ENTREGUE_NO_CLIENTE',
  gc_online              TYPE char11 VALUE 'Online' ##NO_TEXT,
  gc_job                 TYPE char11 VALUE 'Job',
  gc_tpcnt_o             TYPE c VALUE 'O',
  gc_tpcnt_R             TYPE c VALUE 'R',
  gc_tpcnt_C             TYPE c VALUE 'C',
  gc_tpcnt_I             TYPE c VALUE 'I',
  gc_status_erro         TYPE c VALUE '3',
  gc_status_ok           TYPE c VALUE '2',
  gc_type_erro           TYPE c VALUE 'E'.
