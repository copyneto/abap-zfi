@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Estorno de Solicitação LC - Log'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_SOLICIT_CORRE
  as select from ztfi_solcorrecao
{
  key bukrs                 as Bukrs,
  key kunnr                 as Kunnr,
  key belnr                 as Belnr,
  key buzei                 as Buzei,
  key gjhar                 as Gjhar,
  key datac                 as Datac,
  key horac                 as Horac,
      @Semantics.amount.currencyCode : 'waers'
      wrbtr                 as Wrbtr,
      netdt                 as Netdt,
      motivo                as Motivo,
      tipo                  as Tipo,
      belnrestorno          as Belnrestorno,
      buzeiestorno          as Buzeiestorno,
      gjharestorno          as Gjharestorno,
      verzn                 as Verzn,
      waers                 as Waers,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
