@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help search Anla'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Zi_ca_vh_anla
  as select from anla as a
    inner join   ankt as b on  a.anlkl = b.anlkl
                           and a.spras = b.spras
{
  key a.anlkl,
      b.txk50,
      @UI.hidden: true
      a.spras
}
group by
  a.anlkl,
  b.txk50,
  a.spras
