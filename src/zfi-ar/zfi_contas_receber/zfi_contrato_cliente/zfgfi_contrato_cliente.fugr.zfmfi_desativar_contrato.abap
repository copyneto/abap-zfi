FUNCTION zfmfi_desativar_contrato.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_DOC_UUID_H) TYPE  SYSUUID_X16
*"----------------------------------------------------------------------

  DATA(lo_contrato) = NEW zclfi_contrato_cliente_util(  ).

  lo_contrato->desativar( iv_doc_uuid_h ).

ENDFUNCTION.
