@AbapCatalog.sqlViewName: 'ZV_TPAPIMPOST'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo Apuração Devoluções'
define view ZI_FI_TP_AP_IMPOST
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoApDevolucText' ]
  key domvalue_l as TipoApDevoluc,
      ddlanguage as Language,
      ddtext     as TipoApDevolucText
}
where
      domname    = 'ZD_TP_AP_IMPOST'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
