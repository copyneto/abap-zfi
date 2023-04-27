@AbapCatalog.sqlViewName: 'ZV_CODMONT'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de códigos de valor'
define view ZI_FI_COD_MONTANTE
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoCodMontText' ]
  key domvalue_l as TipoCodMont,
      ddlanguage as Language,
      ddtext     as TipoCodMontText
}
where
      domname    = 'ZD_CODIGO_VALOR'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
