@AbapCatalog.sqlViewName: 'ZV_TPDESC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de Desconto'
define view ZI_FI_TP_DESCONTO
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoDescText' ]
  key domvalue_l as TipoDescId,
      ddlanguage as Language,
      ddtext     as TipoDescText
}
where
      domname    = 'ZD_DESCONTO'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
