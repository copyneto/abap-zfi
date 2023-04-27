@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Periodicidades Crescimento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_PERIODICIDADE
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoPeriodoText' ]
  key domvalue_l as TipoPeriodoId,
      ddlanguage as Language,
      ddtext     as TipoPeriodoText
}
where
      domname    = 'ZD_PERIODICIDADE'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
