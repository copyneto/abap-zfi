@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Formas de Desconto'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FORMA_DESCONTO
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoFormaText' ]
  key domvalue_l as TipoFormaId,
      ddlanguage as Language,
      ddtext     as TipoFormaText
}
where
      domname    = 'ZD_FORM_DESCONTO'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
