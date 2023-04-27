@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log Concessão de Crédito'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_LOGCONCRED_CONV
  as select from ztfi_logconcred
{
  key bukrs,
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
      cast( substring(zitemcredito,4, 3) as abap.numc( 3 ) ) as zitemcredito,
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
      zdoccon,
      zitemdoccon,
      zexerciciodoccon,
      zdata,
      zhora,
      bname,
      waers



}
