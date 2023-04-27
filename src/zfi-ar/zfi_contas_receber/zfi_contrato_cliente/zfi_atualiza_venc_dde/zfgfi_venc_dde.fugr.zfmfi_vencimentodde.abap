FUNCTION zfmfi_vencimentodde.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_BUZEI) TYPE  BSEG-BUZEI OPTIONAL
*"     VALUE(IV_BUKRS) TYPE  BSEG-BUKRS OPTIONAL
*"     VALUE(IV_BELNR) TYPE  BSEG-BELNR OPTIONAL
*"     VALUE(IV_GJAHR) TYPE  BSEG-GJAHR OPTIONAL
*"     VALUE(IV_PRAZO) TYPE  ZE_PRAZO OPTIONAL
*"     VALUE(IV_ENTREGA) TYPE  DATUM OPTIONAL
*"     VALUE(IS_CDS) TYPE  ZC_FI_VENC_DDE_BUSCA OPTIONAL
*"  CHANGING
*"     VALUE(CT_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  ct_return = NEW zclfi_dde_function( is_cds )->execute( ).

ENDFUNCTION.
