@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipos de Comparação - Crescimento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_TIPO_COMPARAR
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoCompText' ]
  key domvalue_l as TipoCompId,
      ddlanguage as Language,
      ddtext     as TipoCompText
}
where
      domname    = 'ZD_COMPARACAO'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
