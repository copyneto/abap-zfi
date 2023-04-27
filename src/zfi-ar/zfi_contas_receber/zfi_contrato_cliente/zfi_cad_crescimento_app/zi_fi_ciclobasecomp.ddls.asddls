@AbapCatalog.sqlViewName: 'ZV_CICLOBASCOMP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo Ciclos Base Comparação'
define view ZI_FI_CICLOBASECOMP
  as select from dd07t
{
      @EndUserText.label: 'Valor'
      @ObjectModel.text.element: [ 'TipoDescText' ]
  key domvalue_l as TipoDescId,
//      ddlanguage as Language,
      @EndUserText.label: 'Ciclo'
      ddtext     as TipoDescText
}
where
      domname    = 'ZD_CICLOBASECOMP'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
