@AbapCatalog.sqlViewName: 'ZVFI_GETFAM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca dados família'
define view ZI_FI_GET_FAMILIA
  as select distinct from I_BillingDocExtdItemBasic
{

  key BillingDocument,
      min(BillingDocumentItem) as item
      
}
group by
  BillingDocument
