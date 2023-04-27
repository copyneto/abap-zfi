FUNCTION zfmfi_envio_emailapp.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IT_ENVIO) TYPE  ZCTGFI_RFC_ENVIOEMAIL
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  CHAR1
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  DATA: lv_status_retorno TYPE char1.
  DATA lo_cl_envio TYPE REF TO zclfi_envio_email_alerta.
  CREATE OBJECT lo_cl_envio.

  lo_cl_envio->initialize_log( ).
  lo_cl_envio->envio_emailapp( EXPORTING it_emailapp = it_envio
                               IMPORTING ev_status_retorno = lv_status_retorno
                                         et_return = et_return ).
  es_return = lv_status_retorno.

ENDFUNCTION.
