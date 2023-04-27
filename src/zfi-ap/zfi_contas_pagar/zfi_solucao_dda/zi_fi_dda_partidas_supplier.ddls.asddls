@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'DDA - Seleção de partidas por fornecedor'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_DDA_PARTIDAS_SUPPLIER
  as select from    bsik_view       as PartidasAberto
    left outer join ZI_FI_ERROR_DDA as Error_DDA on  PartidasAberto.bukrs   = Error_DDA.CompanyCode
                                                 and PartidasAberto.lifnr   = Error_DDA.Supplier
                                                 and PartidasAberto.gjahr   = Error_DDA.FiscalYear
//                                                 and PartidasAberto.xblnr = Error_DDA.ReferenceNo
                                                  
                                                  
                                                 and PartidasAberto.belnr = Error_DDA.DocNumber

{

  key PartidasAberto.bukrs           as CompanyCode,
  key PartidasAberto.lifnr           as Supplier,
  key PartidasAberto.gjahr           as FiscalYear,
  key PartidasAberto.belnr           as DocNumber,
  key PartidasAberto.xblnr           as ReferenceNo,
  key PartidasAberto.buzei           as AccountingItem,
  key Error_DDA.ReferenceNo          as NotaFiscal,
  key Error_DDA.DueDate,
      Error_DDA.Barcode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Error_DDA.Amount,
      Error_DDA.PostingDate,
      Error_DDA.ErrReason,
      PartidasAberto.bldat           as DocumentDate,
      PartidasAberto.blart           as AccountingDocumentType,
      PartidasAberto.waers           as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      PartidasAberto.wrbtr           as AccountingDocumentAmount,
      PartidasAberto.zlsch           as PaymentMethod,
      PartidasAberto.zlspr           as BlockPay,
      PartidasAberto.sgtxt           as ItemText,
      Error_DDA._Supplier.SupplierName,
      Error_DDA.CnpjSemZero          as SupplierCNPJ,
      Error_DDA._Supplier.TaxNumber2 as SupplierCPF,
      Error_DDA.StatusCheck

}

//  Alteração 02/08/2022 - LSCHEPP
// and Error_DDA.ErrReason   = 'V' "o código acima estava com 'V'. Incluído a condição 'A'
// incluído no left outer join na CDS ZIFI_ERROR_DDA a condição abaixo:
// and PartidasAberto.belnr = Error_DDA.DocNumber (linha 16) - LSCHEPP
