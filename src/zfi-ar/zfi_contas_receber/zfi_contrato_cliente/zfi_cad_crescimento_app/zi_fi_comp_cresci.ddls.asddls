@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS interface - Base Comp. Crescimento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_COMP_CRESCI
  as select from ztfi_comp_cresci
  association to parent ZI_FI_CONTRATO_CRESC as _Crescimento on $projection.DocUuidH = _Crescimento.DocUuidH
  //                                                             and $projection.Contrato = _Crescimento.Contrato

  association to ZI_FI_CICLOBASECOMP         as _Text        on $projection.Ciclos = _Text.TipoDescId

{
  key doc_uuid_h            as DocUuidH,
  key doc_uuid_ciclo        as DocUuidCiclo,
      contrato              as Contrato,
      aditivo               as Aditivo,
      ciclos                as Ciclos,
      _Text.TipoDescText    as CiclosText,
      @Semantics.amount.currencyCode : 'Waers'
      mont_comp             as MontComp,
      waers                 as Waers,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Crescimento
}
