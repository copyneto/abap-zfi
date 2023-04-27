@AbapCatalog.sqlViewName: 'ZV_TPENTRE'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de Entrega: Contrato Cliente'
define view ZI_FI_TIPO_ENTREGA
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TpEntregaText' ]
  key domvalue_l as TpEntrega,
      ddlanguage as Language,
      ddtext     as TpEntregaText
}
where
      domname    = 'ZD_TIPO_ENTREGA'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
