@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de interface - Cadastro de Parâmetros  RM'
define root view entity ZI_FI_PARAM_RM
  as select from ztfi_param_rm
{
  key bukrs                 as Bukrs,
  key gsber                 as Gsber,
  key bupla                 as Bupla,
      zmatriz               as Zmatriz,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
