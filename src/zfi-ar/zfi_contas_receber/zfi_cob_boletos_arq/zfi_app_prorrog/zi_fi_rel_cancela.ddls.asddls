@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Relatório de Cancelamentos - View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define root view entity ZI_FI_REL_CANCELA
  as select from ztfi_solcorrecao
  association [0..1] to P_USER_ADDR as _User on _User.bname = $projection.CreatedBy
{
  key bukrs                 as Bukrs,
  key kunnr                 as Kunnr,
  key belnr                 as Belnr,
  key buzei                 as Buzei,
  key gjhar                 as Gjhar,
  key datac                 as Datac,
  key horac                 as Horac,
      @Semantics.amount.currencyCode: 'Waers'
      wrbtr                 as Wrbtr,
      netdt                 as Netdt,
      motivo                as Motivo,
      tipo                  as Tipo,
      belnrestorno          as Belnrestorno,
      buzeiestorno          as Buzeiestorno,
      gjharestorno          as Gjharestorno,
      verzn                 as Verzn,
      waers                 as Waers,
      _User.NAME_TEXTC      as CreatedByUserName,
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
