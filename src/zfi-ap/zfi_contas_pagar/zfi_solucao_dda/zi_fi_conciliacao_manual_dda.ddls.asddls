@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface p/ Conciliação manual DDA'
@Metadata.allowExtensions: true
define root view entity ZI_FI_CONCILIACAO_MANUAL_DDA
  as select from    ZI_FI_DDA_PARTIDAS as Partidas
    left outer join P_BKPF_COM         as bkpf on  bkpf.bukrs = Partidas.CompanyCode
                                               and bkpf.belnr = Partidas.DocNumber
                                               and bkpf.gjahr = Partidas.FiscalYear
{

  key Partidas.CompanyCode,
  key Partidas.Supplier,
  key Partidas.FiscalYear,
  key Partidas.DocNumber,
  key Partidas.ReferenceNo,
  key Partidas.AccountingItem,
  key max(Partidas.NotaFiscal)                                        as NotaFiscal,
  key Partidas.DueDate,
      cast( concat( concat( substring(Partidas.DueDate, 5, 4),
                            substring(Partidas.DueDate, 3, 2)
                    ),
                   substring(Partidas.DueDate, 1, 2) ) as abap.dats ) as DueDateConverted,
      max(Partidas.ErrReason)                                         as ErrReason,
      max(Partidas.Barcode)                                           as Barcode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      max(Partidas.Amount)                                            as Amount,
      Partidas.PostingDate,
      Partidas.DocumentDate,
      Partidas.AccountingDocumentType,
      Partidas.CurrencyCode,
      Partidas.AccountingDocumentAmount,
      Partidas.PaymentMethod,
      Partidas.BlockPay,
      Partidas.ItemText,
      max(Partidas.SupplierName)                                      as SupplierName,
      max(Partidas.SupplierCNPJ)                                      as SupplierCNPJ,
      max(Partidas.SupplierCPF)                                       as SupplierCPF,
      cast( ''  as abap.char(20))                                     as SupplierCNPJFormat,
      cast( ''  as abap.char(20))                                     as SupplierCPFFormat,
      cast ( 'X' as xfeld preserving type )                           as ConciliacaoManual,
      max(substring(Partidas.SupplierCNPJ, 1, 8))                     as SupplierCnpjRoot,
      bkpf.bktxt


}

group by
  Partidas.CompanyCode,
  Partidas.Supplier,
  Partidas.FiscalYear,
  Partidas.DocNumber,
  Partidas.ReferenceNo,
  Partidas.AccountingItem,
  Partidas.DueDate,
  Partidas.PostingDate,
  Partidas.DocumentDate,
  Partidas.AccountingDocumentType,
  Partidas.CurrencyCode,
  Partidas.AccountingDocumentAmount,
  Partidas.PaymentMethod,
  Partidas.BlockPay,
  Partidas.ItemText,
//  Partidas.SupplierCNPJ,
  bkpf.bktxt
