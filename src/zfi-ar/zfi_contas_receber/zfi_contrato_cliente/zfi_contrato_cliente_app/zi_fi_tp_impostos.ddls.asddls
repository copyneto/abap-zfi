@AbapCatalog.sqlViewName: 'ZV_TPIMPOS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de Impostos'
define view ZI_FI_TP_IMPOSTOS
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoImpText' ]
  key domvalue_l as TipoImpId,
      ddlanguage as Language,
      ddtext     as TipoImpText
}
where
      domname    = 'ZD_TIP_IMPOSTO'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
