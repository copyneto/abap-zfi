@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface Log Concessão de Crédito'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_LOGCONCRED
  as select from ztfi_logconcred
{
  key bukrs,
  key zdoccon,
  key zitemdoccon,
  key zexerciciodoccon,  
  key kunnr,
  key stcd1,
  key stcd2,
  key zfatura,
      zitemfatura,
      zexerciciofatura,
      @Semantics.amount.currencyCode : 'waers'
      wrbtr,
      bschl,
      netdt,
      zlsch,
      zuonr,
      xblnr,
      blart,
      xref1_hd,
      xref2_hd,
      zcredito,
      zitemcredito,
      zexerciciocredito,
      @Semantics.amount.currencyCode : 'waers'
      zwrbtr,
      zbschl,
      znetdt,
      zzlsch,
      zzuonr,
      zxblnr,
      zblart,
      zxref1_hd,
      zxref2_hd,
      umskz,
      zresidualnao,
      zvencimentonao,
      zdadosfor,
      zdata,
      zhora,
      bname,
      waers



}
