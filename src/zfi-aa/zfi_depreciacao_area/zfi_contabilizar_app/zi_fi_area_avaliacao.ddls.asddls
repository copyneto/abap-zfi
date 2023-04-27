@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Area de avaliação 01'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_AREA_AVALIACAO
  as select from Faa_Anlc as _C


  association [0..*] to Faa_Anlp as _P    on  _C.bukrs = _P.bukrs
                                          and _C.anln1 = _P.anln1
                                          and _C.anln2 = _P.anln2
                                          and _C.gjahr = _P.gjahr
                                          and _C.afabe = _P.afaber


  association [1..1] to t093b    as Moeda on  Moeda.bukrs = _C.bukrs
                                          and Moeda.afabe = _C.afabe
{
  key _C.bukrs      as Bukrs,
  key _C.anln1      as Anln1,
  key _C.anln2      as Anln2,
  key _C.gjahr      as Gjahr,
  key _C.afabe      as Afabe,
      _P.peraf      as Peraf,
      @Semantics.amount.currencyCode: 'Moeda'
      sum(_P.nafag) as Nafag,
      Moeda.waers   as Moeda

}

where
     _C.afabe = '01'
  or _C.afabe = '10'
  or _C.afabe = '11'
  or _C.afabe = '80'
  or _C.afabe = '82'
  or _C.afabe = '84'
group by
  bukrs,
  anln1,
  anln2,
  gjahr,
  afabe,
  _P.peraf,
  Moeda.waers
