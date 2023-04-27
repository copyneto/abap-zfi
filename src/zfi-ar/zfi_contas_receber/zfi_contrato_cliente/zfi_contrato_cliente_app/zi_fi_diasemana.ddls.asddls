@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Dominio Dia da semana'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_DIASEMANA
  as select from dd07t
{
      @ObjectModel.text.element: [ 'DiasemanaText' ]
  key domvalue_l as Diasemana,
      ddlanguage as Language,
      ddtext     as DiasemanaText
}
where
      domname    = 'ZD_DIA_SEMANA'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
