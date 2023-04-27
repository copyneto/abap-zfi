FUNCTION zfmfi_aditivo_contrato.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_DOC_UUID_H) TYPE  ZTFI_CONTRATO-DOC_UUID_H
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  DATA(lo_exec) = NEW zclfi_aditivo_contrato(  ).

  lo_exec->executa(
    EXPORTING
      iv_doc_uuid_h =  iv_doc_uuid_h
    IMPORTING
      et_return     =  et_return  ).

ENDFUNCTION.
