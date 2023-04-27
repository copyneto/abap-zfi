@AbapCatalog.sqlViewName: 'ZV_TPAPURA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de Apuração'
define view ZI_FI_TP_APURACAO
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoApuraText' ]
  key domvalue_l as TipoApuraId,
      ddlanguage as Language,
      ddtext     as TipoApuraText
}
where
      domname    = 'ZD_TP_APURACAO'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
