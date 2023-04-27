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


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: s_BUKRS FOR ls_screen-bukrs OBLIGATORY,
                  s_KUNNR FOR ls_screen-kunnr,
                  s_BELNR FOR ls_screen-belnr,
                  s_BUZEI FOR ls_screen-buzei,
                  s_GJHAR FOR ls_screen-gjahr,
                  s_XBLNR FOR ls_screen-xblnr,
                  s_ZUONR FOR ls_screen-zuonr,
                  s_HBKID FOR ls_screen-hbkid,
                  s_ZLSCH FOR ls_screen-zlsch.

SELECTION-SCREEN END OF BLOCK b1.
