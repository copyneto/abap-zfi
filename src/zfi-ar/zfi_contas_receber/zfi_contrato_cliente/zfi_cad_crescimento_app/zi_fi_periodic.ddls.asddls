@AbapCatalog.sqlViewName: 'ZV_PERIODIC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo Periodicidade - Crescimento'
define view ZI_FI_PERIODIC
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoPeriodicidadeText' ]
  key domvalue_l as TipoPeriodicidade,
      ddlanguage as Language,
      ddtext     as TipoPeriodicidadeText
}
where
      domname    = 'ZD_PERIODICIDADE'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
