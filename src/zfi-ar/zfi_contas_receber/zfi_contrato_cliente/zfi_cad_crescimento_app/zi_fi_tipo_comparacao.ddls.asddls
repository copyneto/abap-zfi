@AbapCatalog.sqlViewName: 'ZV_TPCOMPARAC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo Comparação - Crescimento'
define view ZI_FI_TIPO_COMPARACAO
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoComparacaoText' ]
  key domvalue_l as TipoComparacaoId,
      ddlanguage as Language,
      ddtext     as TipoComparacaoText
}
where
      domname    = 'ZD_COMPARACAO'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
