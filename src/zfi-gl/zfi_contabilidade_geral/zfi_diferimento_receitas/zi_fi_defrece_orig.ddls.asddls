@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Difer Rec e Deduções (Critério Origem)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_DEFRECE_ORIG as select from I_RegionText { 
key Country,
key Region,
key Language,
RegionName

} where Country = 'BR'
   and Language = 'P'
