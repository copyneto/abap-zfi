@AbapCatalog.sqlViewName: 'ZV_CONDDESC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Value Help - Condição de Desconto'
define view ZI_FI_COND_DESCONTO
  as select from ZI_FI_CONDICAO_DESCONTO
{
  key TipoCond,
  key Text
}
