@AbapCatalog.sqlViewName: 'ZVFI_MAXENTREGA'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca ultima data do TM'
define view ZI_FI_ENTREGA_TM_LAST
  as select from ZI_FI_ENTREGA_TM
{

  Remessa,
  max(DataEntrega) as DataEntrega

}
group by
  Remessa
