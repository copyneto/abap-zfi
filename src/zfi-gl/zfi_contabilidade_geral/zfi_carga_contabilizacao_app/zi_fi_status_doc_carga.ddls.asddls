@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Carga Contabilização - Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_STATUS_DOC_CARGA
  as select from dd07t as StatusCarga
{
      @ObjectModel.text.element: [ 'StatusText' ]
  key domvalue_l as StatusId,
      ddlanguage as Language,
      ddtext     as StatusText
}
where
      domname    = 'ZD_STATUS_DOC'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
