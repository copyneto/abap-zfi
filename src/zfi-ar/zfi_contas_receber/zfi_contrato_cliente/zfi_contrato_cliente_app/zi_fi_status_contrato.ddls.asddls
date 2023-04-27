@AbapCatalog.sqlViewName: 'ZV_STATUSCONT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Status Contrato Cliente'
define view ZI_FI_STATUS_CONTRATO
  as select from dd07t
{
      @ObjectModel.text.element: [ 'StatusText' ]
  key domvalue_l as StatusId,
      ddlanguage as Language,
      ddtext     as StatusText
}
where
      domname    = 'ZD_STATUS_CONTRATO'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
