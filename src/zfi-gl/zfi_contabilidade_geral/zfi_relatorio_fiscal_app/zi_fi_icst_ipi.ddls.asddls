@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro I_BR_NFTax - TaxGroup'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_ICST_IPI
  as select from I_BR_NFTax as _Tax
  //    left outer join I_BR_NFItem as _Item on  _Tax.BR_NotaFiscal     = _Item.BR_NotaFiscal
  //                                         and _Tax.BR_NotaFiscalItem = _Item.BR_NotaFiscalItem

{

  key  _Tax.BR_NotaFiscal                                     as BR_NotaFiscal,
  key  _Tax.BR_NotaFiscalItem                                 as BR_NotaFiscalItem,
       sum( cast(_Tax.BR_NFItemTaxAmount as abap.dec(15,2)) ) as Taxval
       //       sum( cast(_Tax.BR_NFItemTaxAmount as abap.dec(13,2)) ) + cast(_Item.NetValueAmount as abap.dec(13,2)) as Taxval
}
where
     _Tax.TaxGroup = 'IPI'
  or _Tax.TaxGroup = 'ICST' 
group by
  _Tax.BR_NotaFiscal,
  _Tax.BR_NotaFiscalItem
//  _Item.NetValueAmount
