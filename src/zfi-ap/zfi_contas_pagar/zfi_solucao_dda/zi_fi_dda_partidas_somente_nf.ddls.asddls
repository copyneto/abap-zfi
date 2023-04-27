@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'DDA - Seleção por nota fiscal'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_DDA_PARTIDAS_SOMENTE_NF
  as select from bsik_view       as PartidasAberto
    inner join   ZI_FI_ERROR_DDA as Error_DDA on  Error_DDA.CompanyCode = PartidasAberto.bukrs
                                              and Error_DDA.Supplier    = PartidasAberto.lifnr
                                              and Error_DDA.FiscalYear  = PartidasAberto.gjahr



{

  key  PartidasAberto.bukrs                                                                                                       as CompanyCode,
  key  PartidasAberto.lifnr                                                                                                       as Supplier,
  key  PartidasAberto.gjahr                                                                                                       as FiscalYear,
  key  PartidasAberto.belnr                                                                                                       as DocNumber,
  key  PartidasAberto.buzei                                                                                                       as AccountingItem,
  key  max(Error_DDA.ReferenceNo)                                                                                                 as NotaFiscal,
  key  cast( concat( substring( PartidasAberto.bldat, 7, 2),
             concat( substring( PartidasAberto.bldat, 5, 2), substring( PartidasAberto.bldat, 1, 4) ) ) as char8 preserving type) as DueDate,
       PartidasAberto.xblnr                                                                                                       as ReferenceNo,
       Error_DDA.Barcode,
       @Semantics.amount.currencyCode: 'CurrencyCode'
       Error_DDA.Amount,
       PartidasAberto.budat                                                                                                       as PostingDate,
       Error_DDA.ErrReason,
       PartidasAberto.bldat                                                                                                       as DocumentDate,
       PartidasAberto.blart                                                                                                       as AccountingDocumentType,
       PartidasAberto.waers                                                                                                       as CurrencyCode,
       @Semantics.amount.currencyCode: 'CurrencyCode'
       PartidasAberto.wrbtr                                                                                                       as AccountingDocumentAmount,
       PartidasAberto.zlsch                                                                                                       as PaymentMethod,
       PartidasAberto.zlspr                                                                                                       as BlockPay,
       PartidasAberto.sgtxt                                                                                                       as ItemText,
       Error_DDA._Supplier.SupplierName,
       Error_DDA.CnpjSemZero                                                                                                      as SupplierCNPJ,
       Error_DDA._Supplier.TaxNumber2                                                                                             as SupplierCPF,
       Error_DDA.StatusCheck

}

where
        Error_DDA.DocNumber != ''
  and(
        Error_DDA.StatusCheck = 'S'
    and Error_DDA.Barcode     = ''
    and Error_DDA.ErrReason   = ''
    and Error_DDA.Amount      = PartidasAberto.wrbtr
  )
  
group by
  PartidasAberto.bukrs,
  PartidasAberto.lifnr,
  PartidasAberto.gjahr,
  PartidasAberto.belnr,
  PartidasAberto.buzei,
  PartidasAberto.budat,
  PartidasAberto.xblnr,
  Error_DDA.Barcode,
  Error_DDA.Amount,
  Error_DDA.PostingDate,
  Error_DDA.ErrReason,
  PartidasAberto.bldat,
  PartidasAberto.blart,
  PartidasAberto.waers,
  PartidasAberto.wrbtr,
  PartidasAberto.zlsch,
  PartidasAberto.zlspr,
  PartidasAberto.sgtxt,
  Error_DDA._Supplier.SupplierName,
  Error_DDA.CnpjSemZero,
  Error_DDA._Supplier.TaxNumber2,
  Error_DDA.StatusCheck
