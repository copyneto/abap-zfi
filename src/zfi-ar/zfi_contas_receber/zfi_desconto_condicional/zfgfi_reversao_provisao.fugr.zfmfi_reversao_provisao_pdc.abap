FUNCTION zfmfi_reversao_provisao_pdc.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_REVERSAO) TYPE  ZI_FI_REVERSAO_PROVISAO_PDC
*"     VALUE(IS_REVERSAO_POPUP) TYPE  ZI_FI_REVERSAO_PROVISAO_POPUP
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  FREE: et_return.

  DATA(lo_events) = NEW zclfi_reversao_provisao_events( ).

  lo_events->bapi_revert_documents( EXPORTING is_reversao       = is_reversao
                                              is_reversao_popup = is_reversao_popup
                                    IMPORTING et_return         = et_return ).

ENDFUNCTION.
