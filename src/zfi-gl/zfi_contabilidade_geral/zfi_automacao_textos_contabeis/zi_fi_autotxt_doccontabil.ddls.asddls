@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Documento contábil'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_AUTOTXT_DOCCONTABIL
  as select from P_BKPF_COM

  association to ZI_FI_AUTOTXT_NF as _NF
    on $projection.xblnr = _NF.vgbel
{
  key bukrs,
  key belnr,
  key gjahr,
      blart,
      bldat,
      budat,
      monat,
      xblnr,
      bktxt,
      _NF.BR_NFeNumber,
      /* Associations */
      _NF

}
