@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo  Carga de Contratos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_TIPO_CARGA 
as select from dd07t as TipoCarga
{
    
      @ObjectModel.text.element: [ 'TipoCargaText' ]
  key domvalue_l as TipoCargaId,
      ddlanguage as Language,
      ddtext     as TipoCargaText
}
where
      domname    = 'ZD_CARGA_CONTRATOS'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
