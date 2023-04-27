@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS - Para recuperar o Contrato'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zi_fi_taxnumber as select from zibp_taxnumber {
    key BusinessPartner,
    cast( substring(BPTaxNumber, 1, 8 ) as ze_cpnj_princi ) as RaizSub
} where BPTaxType = 'BR1'
