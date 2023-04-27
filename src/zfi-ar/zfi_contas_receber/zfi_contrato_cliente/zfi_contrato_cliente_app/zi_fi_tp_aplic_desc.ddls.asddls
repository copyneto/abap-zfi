@AbapCatalog.sqlViewName: 'ZV_TPAPLIC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo Aplicação Desconto'
define view ZI_FI_TP_APLIC_DESC
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoAplicText' ]
  key domvalue_l as TipoAplicId,
      ddlanguage as Language,
      ddtext     as TipoAplicText
}
where
      domname    = 'ZD_APLICA_DESC'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
