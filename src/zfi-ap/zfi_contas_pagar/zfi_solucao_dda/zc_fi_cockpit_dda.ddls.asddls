@EndUserText.label: 'Consumo Cockpit DDA'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true

define root view entity ZC_FI_COCKPIT_DDA
  as projection on ZI_FI_COCKPIT_DDA
{
  key StatusCheck,
      @Consumption.valueHelpDefinition: [
          { entity:  { name:    'I_Supplier_VH',
                       element: 'Supplier' }
          }]
      @ObjectModel.text: { element: ['SupplierName'] }
  key Supplier,
  key ReferenceNo,
  key DocNumber,
  key MiroInvoice,
      @Consumption.valueHelpDefinition: [{
              entity: {
                  name: 'ZI_CA_VH_COMPANY',
                  element: 'CompanyCode'
              }
            }]
      @ObjectModel.text: { element: ['CompanyName'] }
  key CompanyCode,

      @Consumption.valueHelpDefinition: [{
        entity: {
            name: 'C_CnsldtnFiscalYearVH',
            element: 'FiscalYear'
        }
      }]
  key FiscalYear,
  key Cnpj,

      @Consumption.filter: {
        selectionType: #INTERVAL,
        multipleSelections: false
      }
  key DueDate,

      @Consumption.filter: {
        selectionType: #INTERVAL,
        multipleSelections: false
      }
  key DataArq,

      @Consumption.filter: {
        selectionType: #INTERVAL,
        multipleSelections: false
      }
      @Semantics.dateTime: true
      DueDateConverted,
      Amount,
      DueDateDoc,
      ErrorXblnr,
      Barcode,
      RecNum,
      Partner,
      @Consumption.filter: {
        selectionType: #INTERVAL,
        multipleSelections: false
      }
      @Semantics.dateTime: true
      IssueDate,
      @Consumption.filter: {
        selectionType: #INTERVAL,
        multipleSelections: false
      }
      @Semantics.dateTime: true
      PostingDate,
      @Consumption.valueHelpDefinition: [{
      entity: {
      name: 'ZI_FI_VH_ERRORREASONDDA',
      element: 'DomvalueL' }}]
      @ObjectModel.text.element: ['Text']
      ErrReason,
      Msg,
      ChaveReferencia,
      CnpjSemZero,
      CompanyName,
      SupplierName,
      SupplierCNPJ,
      SupplierCPF,
      @ObjectModel.virtualElement: true
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLFI_FORMATA_CPF_CNPJ_DDA'
      @ObjectModel.filter.transformedBy: 'ABAP:ZCLFI_FILTRO_CPF_CNPJ_DDA'
      CNPJFormat,
      @EndUserText.label: 'CNPJ Fornecedor'
      @ObjectModel.virtualElement: true
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLFI_FORMATA_CPF_CNPJ_DDA'
      SupplierCNPJFormat,
      @EndUserText.label: 'CPF Fornecedor'
      @ObjectModel.virtualElement: true
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLFI_FORMATA_CPF_CNPJ_DDA'
      SupplierCPFFormat,
      Currency,
      DocComp,
      @UI.hidden: true
      Text,

      nfdiv_belnr,
      nfdiv_buzei,

      /* Associations */
      _Company,
      //      _MiroInvoice,
      _Supplier,
      _Error
}
