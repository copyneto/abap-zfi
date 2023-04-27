FUNCTION zfmfi_contab_reav.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IT_LINHAS) TYPE  ZCTGFI_CONTAB_DEPRE
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"--------------------------------------------------------------------
  NEW zclfi_contab_depre_util( )->executa_reav(
    EXPORTING
      it_linhas = it_linhas
    IMPORTING
      et_return = et_return ).

ENDFUNCTION.
