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
DATA: ls_screen TYPE zclfi_retira_bloqueios=>ty_screen.

data: go_desb type REF TO ZCLFI_RETIRA_BLOQUEIOS.

data: gv_okcode type syucomm.
