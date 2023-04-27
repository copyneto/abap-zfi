FUNCTION zfmsd_histo_pgto_cliente.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_S_ZKNB4) TYPE  ZTSD_KNB4
*"  EXPORTING
*"     VALUE(EV_S_RETUNR) TYPE  BAPIRET2
*"----------------------------------------------------------------------
***********************************************************************
***                   © 3corações                                   ***
***********************************************************************
***                  Migração de dados                                *
*** DESCRIÇÃO: Atualização dos valores da tabela KNB4 no ECC para S4  *
*** AUTOR : Luiz Carlos M. Timbó Jr.                                  *
*** FUNCIONAL:                                                        *
*** DATA : 16.08.2022                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA | AUTOR | DESCRIÇÃO                                          *
***-------------------------------------------------------------------*
***      |       |                                                    *
***********************************************************************
  IF iv_s_zknb4 IS NOT INITIAL.
    ev_s_retunr-id     = '00'.
    ev_s_retunr-number = '368'.
    ev_s_retunr-message_v1 = 'Cliente' && ` ` && iv_s_zknb4-kunnr && '-' && iv_s_zknb4-bukrs.
    MODIFY ztsd_knb4 FROM iv_s_zknb4.
    IF sy-subrc IS INITIAL.
      ev_s_retunr-type = 'S'.
      ev_s_retunr-message_v2 = 'atualizado.'.
    ELSE.
      ev_s_retunr-type = 'E'.
      ev_s_retunr-message_v2 = 'erro atualização.'.
    ENDIF.

    CALL FUNCTION 'PSHLP_CACHE_FG_GET_MSG_TXT'
      EXPORTING
        msgid       = ev_s_retunr-id
        msgno       = ev_s_retunr-number
        msgv1       = ev_s_retunr-message_v1
        msgv2       = ev_s_retunr-message_v2
        msgv3       = ev_s_retunr-message_v3
        msgv4       = ev_s_retunr-message_v4
      IMPORTING
        messagetext = ev_s_retunr-message.
  ENDIF.
ENDFUNCTION.
