@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Interface Concessão de Crédito'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_CONC_CRED
  as select from ztfi_conc_cred
{
  key bukrs                 as Empresa,
  key blart                 as TipoDoc,
  key bschl                 as ChaveLanc,
  key zid                   as Identificacao,
  key zlspr                 as FormaPgto,
      zorig                 as Origem,
      //      zlspr                 as FormaPgto,
      mindays               as DiasMin,
      moeda,
      @Semantics.amount.currencyCode : 'moeda'
      minres                as ResidualMin,
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
