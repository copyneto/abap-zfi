@AbapCatalog.sqlViewName: 'ZVFI_DDAPART'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Partidas em aberto p/ conciliação DDA'
define view ZI_FI_DDA_PARTIDAS
  as select distinct from ZI_FI_DDA_PARTIDAS_REFERENCENO as PartidasPorReferencia
{

  key       CompanyCode,
  key       Supplier,
  key       FiscalYear,
  key       DocNumber,
  key       ReferenceNo,
  key       AccountingItem,
  key       NotaFiscal,
  key       DueDate,
            Barcode,
            Amount,
            PostingDate,
            ErrReason,
            DocumentDate,
            AccountingDocumentType,
            CurrencyCode,
            @Semantics.amount.currencyCode: 'CurrencyCode'
            AccountingDocumentAmount,
            PaymentMethod,
            BlockPay,
            ItemText,
            SupplierName,
            SupplierCNPJ,
            SupplierCPF

}


union select distinct from ZI_FI_DDA_PARTIDAS_SUPPLIER as PartidasPorFornecedor
{

  key       CompanyCode,
  key       Supplier,
  key       FiscalYear,
  key       DocNumber,
  key       ReferenceNo,
  key       AccountingItem,
  key       NotaFiscal,
  key       DueDate,
            Barcode,
            Amount,
            PostingDate,
            ErrReason,
            DocumentDate,
            AccountingDocumentType,
            CurrencyCode,
            @Semantics.amount.currencyCode: 'CurrencyCode'
            AccountingDocumentAmount,
            PaymentMethod,
            BlockPay,
            ItemText,
            SupplierName,
            SupplierCNPJ,
            SupplierCPF

}

//union select distinct from ZI_FI_DDA_PARTIDAS_SOMENTE_NF as PartidasPorSomenteNotaFiscal
//{
//
//  key       CompanyCode,
//  key       Supplier,
//  key       FiscalYear,
//  key       DocNumber,
//  key       ReferenceNo,
//  key       AccountingItem,
//  key       NotaFiscal,
//  key       DueDate,
//            Barcode,
//            Amount,
//            PostingDate,
//            ErrReason,
//            DocumentDate,
//            AccountingDocumentType,
//            CurrencyCode,
//            @Semantics.amount.currencyCode: 'CurrencyCode'
//            AccountingDocumentAmount,
//            PaymentMethod,
//            BlockPay,
//            ItemText,
//            SupplierName,
//            SupplierCNPJ,
//            SupplierCPF
//
//}

//union select distinct from yi_teste_02 as teste
//{
//  key       CompanyCode,
//  key       Supplier,
//  key       FiscalYear,
//  key       DocNumber,
//  key       ReferenceNo,
//  key       AccountingItem,
//  key       NotaFiscal,
//  key       DueDate,
//            Barcode,
//            Amount,
//            PostingDate,
//            ErrReason,
//            DocumentDate,
//            AccountingDocumentType,
//            CurrencyCode,
//            @Semantics.amount.currencyCode: 'CurrencyCode'
//            AccountingDocumentAmount,
//            PaymentMethod,
//            BlockPay,
//            ItemText,
//            SupplierName,
//            SupplierCNPJ,
//            SupplierCPF
//}
