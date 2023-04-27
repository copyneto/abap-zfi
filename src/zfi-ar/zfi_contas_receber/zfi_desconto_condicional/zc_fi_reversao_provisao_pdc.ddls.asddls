@EndUserText.label: 'Reversão da Provisão PDC'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['CompanyCode', 'AccountingDocument', 'FiscalYear', 'AccountingDocumentItem' ]
@Search.searchable: true

define root view entity ZC_FI_REVERSAO_PROVISAO_PDC
  as projection on ZI_FI_REVERSAO_PROVISAO_PDC
    association [0..1] to ZI_FI_VH_REVERSAO_PDC as _ReversaoPopup on _ReversaoPopup.RevertType = $projection.RevertType
{
      @EndUserText.label: 'Empresa'
      @ObjectModel.text.element: ['CompanyCodeName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCode', element: 'CompanyCode' }}]
  key CompanyCode,
      @EndUserText.label: 'Nº Documento'
  key AccountingDocument,
      @EndUserText.label: 'Exercício'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_FiscalYearForCompanyCode', element: 'FiscalYear' },
                                           additionalBinding: [{  element: 'CompanyCode', localElement: 'CompanyCode' }]}]
  key FiscalYear,
      @EndUserText.label: 'Item'
  key AccountingDocumentItem,
      @EndUserText.label: 'Cliente'
      @ObjectModel.text.element: ['CustomerName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer', element: 'Customer' }}]
      Customer,
      CompanyCodeName,
      CustomerName,
      @EndUserText.label: 'Chave de Lançamento'
      @ObjectModel.text.element: ['PostingKeyName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PostingKey', element: 'PostingKey' }}]
      PostingKey,
      PostingKeyName,
      @EndUserText.label: 'Código Razão Especial'
      @ObjectModel.text.element: ['SpecialGLCodeName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SpecialGLCode', element: 'SpecialGLCode' }}]
      SpecialGLCode,
      SpecialGLCodeName,
      @EndUserText.label: 'Forma de Pagamento'
      @ObjectModel.text.element: ['PaymentMethodName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_ZLSCH', element: 'FormaPagamento' }}]
      PaymentMethod,
      _PaymenthMethod.FormaPagamentoText       as PaymentMethodName,
      @EndUserText.label: 'Bloqueio'
      @ObjectModel.text.element: ['PaymentBlockingReason']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_ZLSPR', element: 'BloqPagamento' }}]
      PaymentBlockingReason,
      _PaymentBlockingReason.BloqPagamentoText as PaymentBlockingReasonName,
      @EndUserText.label: 'Atribuição'
      AssignmentReference,
      @EndUserText.label: 'Texto do Item'
      DocumentItemText,
      @EndUserText.label: 'Tp.Doc. Autorizado'
      AccountingDocumentTypeOk,
      @EndUserText.label: 'Tipo de Documento'
      @ObjectModel.text.element: ['AccountingDocumentTypeName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_AccountingDocumentType', element: 'AccountingDocumentType' }}]
      AccountingDocumentType,
      AccountingDocumentTypeName,
      AccountingDocumentTypeCrit,
      @EndUserText.label: 'Data do Documento'
      DocumentDate,
      @EndUserText.label: 'Data de Lançamento'
      PostingDate,
      @EndUserText.label: 'Referência'
      DocumentReferenceID,
      @EndUserText.label: 'Texto do Cabeçalho'
      AccountingDocumentHeaderText,
      @EndUserText.label: 'Chave de Ref. 1'
      Reference1InDocumentHeader,
      @EndUserText.label: 'Chave de Ref. 2'
      Reference2InDocumentHeader,
      @EndUserText.label: 'Moeda'
      BalanceTransactionCurrency,
      @EndUserText.label: 'Montante'
      AmountInBalanceTransacCrcy,
      @EndUserText.label: 'Centro'
      @ObjectModel.text.element: ['PlantName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Plant', element: 'Plant' }}]
      Plant,
      PlantName, 
      @EndUserText.label: 'Local de Negócio'
      @ObjectModel.text.element: ['BusinessPlaceName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_BRANCH', element: 'BusinessPlace' },
                                           additionalBinding: [{  element: 'CompanyCode', localElement: 'CompanyCode' }]}]
      BusinessPlace,
      BusinessPlaceName,
      @EndUserText.label: 'Centro de custo'
      @ObjectModel.text.element: ['CostCenterName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CostCenter', element: 'CostCenter' }}]
      CostCenter,
      CostCenterName,
      @EndUserText.label: 'Divisão'
      @ObjectModel.text.element: ['BusinessAreaName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BusinessArea', element: 'BusinessArea' }}]
      BusinessArea,
      BusinessAreaName,
      @EndUserText.label: 'Centro de lucro'
      @ObjectModel.text.element: ['ProfitCenterName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProfitCenter', element: 'ProfitCenter' }}]
      ProfitCenter,
      ProfitCenterName,
      @EndUserText.label: 'Segmento'
      @ObjectModel.text.element: ['SegmentName']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Segment', element: 'Segment' }}]
      Segment,
      SegmentName,
      @EndUserText.label: 'Conta Razão'
      OperationalGLAccount,
      @EndUserText.label: 'Chave de Ref. 1 Item'
      Reference1IDByBusinessPartner,
      @EndUserText.label: 'Chave de Ref. 2 Item'
      Reference2IDByBusinessPartner,
      @EndUserText.label: 'Chave de Ref. 3 Item'
      Reference3IDByBusinessPartner,

      /* Campos Abstract */
      @EndUserText.label    : 'Reversão'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_REVERSAO_PDC', element: 'RevertType' } } ]
      RevertType,
      
      _ReversaoPopup
}
