@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Lista de Contas'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_I_BillingDocumentItem as select from I_BillingDocumentItem {
 key BillingDocument,
 ReferenceSDDocument,
 PlantRegion,
 BillToPartyRegion,
 PriceDetnExchangeRate,
 SalesDocument
}
group by 
BillingDocument,
ReferenceSDDocument,
PlantRegion,
BillToPartyRegion,
PriceDetnExchangeRate,
SalesDocument

