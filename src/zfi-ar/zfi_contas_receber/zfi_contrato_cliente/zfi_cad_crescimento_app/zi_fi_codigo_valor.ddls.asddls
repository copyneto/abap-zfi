@AbapCatalog.sqlViewName: 'ZV_CODVAL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de códigos de valor'
define view ZI_FI_CODIGO_VALOR
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoDescText' ]
  key domvalue_l as TipoDescId,
      ddlanguage as Language,
      ddtext     as TipoDescText
}
where
      domname    = 'ZD_CODIGO_VALOR'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
