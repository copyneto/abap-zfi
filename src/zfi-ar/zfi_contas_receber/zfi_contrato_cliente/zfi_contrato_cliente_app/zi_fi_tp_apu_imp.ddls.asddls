@AbapCatalog.sqlViewName: 'ZV_TPAPIMP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo Apuração Imposto'
define view ZI_FI_TP_APU_IMP
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoApImpText' ]
  key domvalue_l as TipoApImpId,
      ddlanguage as Language,
      ddtext     as TipoApImpText
}
where
      domname    = 'ZD_TP_AP_IMPOST'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
