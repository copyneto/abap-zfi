@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Manutenção de Contas'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_MAN_CONTAS
  as select from ztfi_cont_depre as Contas
{
  key anlkl                 as Anlkl,
  key afaber                as Afaber,
      deprec_fiscal         as DeprecFiscal,
      despesa_fiscal        as DespesaFiscal,
      deprec_societaria     as DeprecSocietaria,
      despesa_societaria    as DespesaSocietaria,
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
