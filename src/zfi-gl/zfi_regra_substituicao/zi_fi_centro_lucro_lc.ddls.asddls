@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Rel. centro de lucro p lanç. contabeis'
@VDM.viewType: #BASIC

define root view entity ZI_FI_CENTRO_LUCRO_LC
  as select from ztfi_clucro
{
  key empresa        as Empresa,
  key divisao        as Divisao,
  key conta_contabil as ContaContabil,
      centro_lucro   as CentroLucro,
      
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
