@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Carga de Pendencias Header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_CARGA_PENDENCIAS
  as select from ztfi_cont_cont

{
  key  doc_cont_id           as Doc_guid,
  key  contrato              as Contrato,
  key  aditivo               as Aditivo,
  key  bukrs                 as Bukrs,
  key  belnr                 as Belnr,
  key  gjahr                 as Gjahr,
  key  numero_item           as NumeroItem,
       kunnr                 as Kunnr,
       budat                 as Budat,
       @Semantics.amount.currencyCode : 'Waers'
       wrbtr                 as Wrbtr,
       waers                 as Waers,
       bzirk                 as Bzirk,
       canal                 as Canal,
       setor                 as Setor,
       vkorg                 as Vkorg,
       tipo_desc             as TipoDesc,
       doc_provisao          as DocProvisao,
       exerc_provisao        as ExercProvisao,
       @Semantics.amount.currencyCode : 'Waers'
       mont_provisao         as MontProvisao,
       doc_liquidacao        as DocLiquidacao,
       exerc_liquidacao      as ExercLiquidacao,
       @Semantics.amount.currencyCode : 'Waers'
       mont_liquidacao       as MontLiquidacao,
       doc_estorno           as DocEstorno,
       exerc_estorno         as ExercEstorno,
       @Semantics.amount.currencyCode : 'Waers'
       mont_estorno          as MontEstorno,
       status_provisao       as StatusProvisao,
       tipo_dado             as TipoDado,
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
