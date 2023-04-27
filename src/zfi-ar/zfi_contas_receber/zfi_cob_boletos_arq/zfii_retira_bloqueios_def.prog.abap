***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Retirada de Bloqueios das faturas para execução em JOB.*
*** AUTOR    : [Denilson Pasini Pina] –[META]                         *
*** FUNCIONAL: [Raphael Rocha]                                        *
*** DATA     : [10.09.2021]                                           *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR        | DESCRIÇÃO                              *
***-------------------------------------------------------------------*
***           |              |                                        *
***********************************************************************
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.

    METHODS:
      display_report,
      constructor IMPORTING it_tab TYPE zctgfi_retira_bloq.


  PRIVATE SECTION.

    CONSTANTS: gc_error  TYPE char1 VALUE 'E',
               gc_status TYPE sypfkey VALUE 'STATUS_0100'.

    DATA: gt_outtab TYPE zctgfi_retira_bloq.

    DATA: go_table   TYPE REF TO cl_salv_table.

    METHODS: on_user_command FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.

ENDCLASS.
