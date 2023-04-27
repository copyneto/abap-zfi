@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro I_BR_NFTax - TaxGroup'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BR_NFTax_SUM
  as select from I_BR_NFTax as _BR_NFTax
  {
  key _BR_NFTax.BR_NotaFiscal,
  key _BR_NFTax.BR_NotaFiscalItem,
  key _BR_NFTax.TaxGroup,
  cast(_BR_NFTax.BR_NFItemBaseAmount as abap.dec(15,2))     as BR_NFItemBaseAmount,
  cast(_BR_NFTax.BR_NFItemOtherBaseAmount as abap.dec(15,2)) as BR_NFItemOtherBaseAmount,
  cast(_BR_NFTax.BR_NFItemExcludedBaseAmount as abap.dec(15,2))  as BR_NFItemExcludedBaseAmount,
  sum( cast(_BR_NFTax.BR_NFItemTaxAmount as abap.dec(15,2)) ) as BR_NFItemTaxAmount 
 }
 
group by   _BR_NFTax.BR_NotaFiscal,
  _BR_NFTax.BR_NotaFiscalItem,
  _BR_NFTax.TaxGroup,
  _BR_NFTax.BR_NFItemBaseAmount,
  _BR_NFTax.BR_NFItemOtherBaseAmount,
  _BR_NFTax.BR_NFItemExcludedBaseAmount
