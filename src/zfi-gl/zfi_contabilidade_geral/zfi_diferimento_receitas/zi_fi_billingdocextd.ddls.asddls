@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS View Billing Doc Extd'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_BillingDocExtd
  as select from I_BillingDocExtdItemBasic as BillingDocExtd
{
  key BillingDocument     as BillingDoc,
  key BillingDocumentItem as BillingDocItem,
      BillToPartyRegion   as BillToPartyRegion,
      PlantRegion         as PlantRegion

}
