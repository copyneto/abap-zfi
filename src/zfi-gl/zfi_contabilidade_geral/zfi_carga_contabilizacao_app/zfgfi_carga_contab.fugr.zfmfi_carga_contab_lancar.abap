FUNCTION zfmfi_carga_contab_lancar.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_DOC_UUID_H) TYPE  ZTFI_CARGA_H-DOC_UUID_H
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------
  DATA(lo_lancar) = NEW zclfi_carga_contabilizacao( ).

  lo_lancar->lancar(
    EXPORTING
      iv_doc    = iv_doc_uuid_h
    IMPORTING
      et_return = et_return  ).

  lo_lancar->salvar_log(
    EXPORTING
      iv_doc    = iv_doc_uuid_h
      it_return = et_return
  ).


ENDFUNCTION.
