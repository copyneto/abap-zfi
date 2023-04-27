@EndUserText.label: 'Consumo App Conciliação Manual DDA'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['Supplier', 'CompanyCode', 'ReferenceNo', 'DocNumber', 'FiscalYear']
define root view entity ZC_FI_CONCILIACAO_MANUAL_DDA
  as projection on ZI_FI_CONCILIACAO_MANUAL_DDA
{
  key       CompanyCode,
  key       Supplier,
  key       FiscalYear,
  key       DocNumber,
  key       ReferenceNo,
  key       AccountingItem,
  key       NotaFiscal,
            @Consumption.filter: {
              selectionType: #INTERVAL,
              multipleSelections: false
            }
  key       DueDate,
            @Consumption.filter: {
              selectionType: #INTERVAL,
              multipleSelections: false
            }
            @Semantics.dateTime: true
            DueDateConverted,
            ErrReason,
            Barcode,
            Amount,
            PostingDate,
            DocumentDate,
            AccountingDocumentType,
            CurrencyCode,
            AccountingDocumentAmount,
            PaymentMethod,
            ItemText,
            SupplierName,
            SupplierCNPJ,
            SupplierCPF,
            @EndUserText.label: 'CNPJ Fornecedor'
            @ObjectModel.virtualElement: true
            @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLFI_FORMATA_CPF_CNPJ_DDA'
            SupplierCNPJFormat,
            @EndUserText.label: 'CPF Fornecedor'
            @ObjectModel.virtualElement: true
            @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLFI_FORMATA_CPF_CNPJ_DDA'
            SupplierCPFFormat,
            SupplierCnpjRoot,
            @EndUserText.label : 'Associar Cód. de barras ao documento?'
            ConciliacaoManual
}
