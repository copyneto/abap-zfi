@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro I_BR_NFTax - TaxGroup'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_NFTAX_ICST_IPI
  as select from I_BR_NFItem as _Lin
  inner join  I_BR_NFDocument as _Doc        on  _Doc.BR_NotaFiscal = _Lin.BR_NotaFiscal

  left outer join ZI_BR_NFTax_SUM  as _NFtax_ICST on  _NFtax_ICST.BR_NotaFiscal     = _Lin.BR_NotaFiscal
                                                 and _NFtax_ICST.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem 
                                                 and _NFtax_ICST.TaxGroup          = 'ICST'

  left outer join ZI_BR_NFTax_SUM  as _NFtax_IPI  on  _NFtax_IPI.BR_NotaFiscal     = _Lin.BR_NotaFiscal
                                                 and _NFtax_IPI.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem 
                                                 and _NFtax_IPI.TaxGroup          = 'IPI'

  left outer join ZI_BR_NFTax_SUM  as _NFtax_PIS  on _NFtax_PIS.BR_NotaFiscal     = _Lin.BR_NotaFiscal
                                                 and _NFtax_PIS.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem 
                                                 and _NFtax_PIS.TaxGroup          =  'PIS'

  left outer join ZI_BR_NFTax_SUM  as _NFtax_COFI on  _NFtax_COFI.BR_NotaFiscal     = _Lin.BR_NotaFiscal
                                                 and _NFtax_COFI.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem 
                                                 and _NFtax_COFI.TaxGroup          =  'COFI'

//  left outer join I_BR_NFTax      as _NFtax_ICST on  _NFtax_ICST.BR_NotaFiscal     = _Lin.BR_NotaFiscal
//                                                 and _NFtax_ICST.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem 
//                                                 and _NFtax_ICST.TaxGroup          = 'ICST'
//
//  left outer join  I_BR_NFTax      as _NFtax_IPI  on  _NFtax_IPI.BR_NotaFiscal     = _Lin.BR_NotaFiscal
//                                                 and _NFtax_IPI.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem 
//                                                 and _NFtax_IPI.TaxGroup          = 'IPI'
//
//  left outer join  I_BR_NFTax      as _NFtax_PIS  on _NFtax_PIS.BR_NotaFiscal     = _Lin.BR_NotaFiscal
//                                                 and _NFtax_PIS.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem 
//                                                 and _NFtax_PIS.TaxGroup          =  'PIS'
//
//  left outer join  I_BR_NFTax      as _NFtax_COFI on  _NFtax_COFI.BR_NotaFiscal     = _Lin.BR_NotaFiscal
//                                                 and _NFtax_COFI.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem 
//                                                 and _NFtax_COFI.TaxGroup          =  'COFI'
  
{

  key _Lin.BR_NotaFiscal                                          as BR_NotaFiscal,
  key _Lin.BR_NotaFiscalItem                                      as BR_NotaFiscalItem,
      _Doc.SalesDocumentCurrency                                  as SalesDocumentCurrency,
      @Semantics.amount.currencyCode:'SalesDocumentCurrency'
      _NFtax_ICST.BR_NFItemTaxAmount as Taxval_ICST,
      @Semantics.amount.currencyCode:'SalesDocumentCurrency'
      _NFtax_IPI.BR_NFItemExcludedBaseAmount as EXCBAS_IPI,
      @Semantics.amount.currencyCode:'SalesDocumentCurrency'
      _NFtax_IPI.BR_NFItemOtherBaseAmount as OTHBAS_IPI,
      @Semantics.amount.currencyCode:'SalesDocumentCurrency'
      _NFtax_IPI.BR_NFItemBaseAmount     as IPI_Base,
      @Semantics.amount.currencyCode:'SalesDocumentCurrency'
      _NFtax_IPI.BR_NFItemTaxAmount   as IPI_Valor,
      @Semantics.amount.currencyCode:'SalesDocumentCurrency'
      _NFtax_ICST.BR_NFItemBaseAmount as SUBST_Base,
      @Semantics.amount.currencyCode:'SalesDocumentCurrency'
      _NFtax_ICST.BR_NFItemTaxAmount  as SUBS_Valor,
      @Semantics.amount.currencyCode:'SalesDocumentCurrency'
      _NFtax_PIS.BR_NFItemTaxAmount  as PIS_Valor,
      @Semantics.amount.currencyCode:'SalesDocumentCurrency'
      _NFtax_COFI.BR_NFItemTaxAmount  as COFINS_Valor
}
