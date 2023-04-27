@AbapCatalog.sqlViewName: 'ZV_DIASEMANA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'DIA DA SEMANA'
define view ZI_FI_DIA_SEMANA 
as select from dd07t
{
      @ObjectModel.text.element: [ 'StatusText' ]
  key domvalue_l as StatusId,
//      ddlanguage as Language,
      ddtext     as StatusText
}
where
      domname    = 'ZD_DIA_SEMANA'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
