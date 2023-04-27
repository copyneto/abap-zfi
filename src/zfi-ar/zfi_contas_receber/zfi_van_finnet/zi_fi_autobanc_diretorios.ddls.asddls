@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automatização Bancária - Diretórios'
define root view entity ZI_FI_AUTOBANC_DIRETORIOS
  as select from ztfi_autbanc_dir
{
  key bukrs                 as CompanyCode,
      tipo                  as Tipo,
      diretorio             as Diretorio,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt

}
