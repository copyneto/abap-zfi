@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Reversão da Provisão PDC (Crédito)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_REVERSAO_PROVISAO_PDC_50
  as select from    I_OperationalAcctgDocItem as _AccountingDocumentItem

  association [1..1] to I_AccountingDocument as _AccountingDocument    on  _AccountingDocument.CompanyCode        = $projection.CompanyCode
                                                                       and _AccountingDocument.FiscalYear         = $projection.FiscalYear
                                                                       and _AccountingDocument.AccountingDocument = $projection.AccountingDocument

  association [0..1] to ZI_CA_VH_ZLSCH       as _PaymenthMethod        on  _PaymenthMethod.FormaPagamento = $projection.PaymentMethod
  association [0..1] to ZI_CA_VH_ZLSPR       as _PaymentBlockingReason on  _PaymentBlockingReason.BloqPagamento = $projection.PaymentBlockingReason
  association [0..1] to ZI_CA_VH_BRANCH      as _BusinessPlace         on  _BusinessPlace.CompanyCode   = $projection.CompanyCode
                                                                       and _BusinessPlace.BusinessPlace = $projection.BusinessPlace

{
  key _AccountingDocumentItem.CompanyCode,
  key _AccountingDocumentItem.AccountingDocument,
  key _AccountingDocumentItem.FiscalYear,
  key _AccountingDocumentItem.AccountingDocumentItem,
      _AccountingDocumentItem.Customer,
      _AccountingDocumentItem._Customer.CustomerName,
      _AccountingDocumentItem.PostingKey,
      _AccountingDocumentItem._PostingKey._PostingKeyText
      [1:Language = $session.system_language].PostingKeyName,
      _AccountingDocumentItem.SpecialGLCode,
      _AccountingDocumentItem._SpecialGLCode._Text
      [1:Language = $session.system_language].SpecialGLCodeLongName as SpecialGLCodeName,
      _AccountingDocumentItem.PaymentMethod,
      _AccountingDocumentItem.PaymentBlockingReason,
      _AccountingDocumentItem.AssignmentReference,
      _AccountingDocumentItem.DocumentItemText,
      _AccountingDocument.AccountingDocumentType,
      _AccountingDocument._AccountingDocumentType._Text
      [1:Language = $session.system_language].AccountingDocumentTypeName,
      _AccountingDocumentItem.DocumentDate,
      _AccountingDocumentItem.PostingDate,
      _AccountingDocument.DocumentReferenceID,
      _AccountingDocument.AccountingDocumentHeaderText,
      _AccountingDocument.Reference1InDocumentHeader,
      _AccountingDocument.Reference2InDocumentHeader,
      _AccountingDocumentItem.BalanceTransactionCurrency,
      @Semantics.amount.currencyCode: 'BalanceTransactionCurrency'
      _AccountingDocumentItem.AmountInBalanceTransacCrcy,
      _AccountingDocumentItem.Plant,
      _AccountingDocumentItem._Plant.PlantName,
      _AccountingDocumentItem.BusinessPlace,
      _BusinessPlace.BusinessPlaceName,
      _AccountingDocumentItem.CostCenter,
      _AccountingDocumentItem._CostCenterText
      [1:Language = $session.system_language].CostCenterName,
      _AccountingDocumentItem.BusinessArea,
      _AccountingDocumentItem._BusinessAreaText
      [1:Language = $session.system_language].BusinessAreaName,
      _AccountingDocumentItem.ProfitCenter,
      _AccountingDocumentItem._ProfitCenterText
      [1:Language = $session.system_language].ProfitCenterName,
      _AccountingDocumentItem.Segment,
      _AccountingDocumentItem._SegmentText
      [1:Language = $session.system_language].SegmentName,
      _AccountingDocumentItem.OperationalGLAccount,
      _AccountingDocumentItem.Reference1IDByBusinessPartner,
      _AccountingDocumentItem.Reference2IDByBusinessPartner,
      _AccountingDocumentItem.Reference3IDByBusinessPartner,
      _AccountingDocumentItem.FinancialAccountType,
      _AccountingDocumentItem.ClearingAccountingDocument,
      _AccountingDocumentItem.AccountingDocumentCategory,

      /* Associations */
      _AccountingDocument,
      _PaymenthMethod,
      _PaymentBlockingReason,
      _BusinessPlace
}

where
      _AccountingDocumentItem.FinancialAccountType       =  'S'         -- Conta razão
  and _AccountingDocumentItem.ClearingAccountingDocument =  ''
  and _AccountingDocumentItem.AccountingDocumentCategory <> 'D'         -- Documento de lançamento periódico 
  and _AccountingDocumentItem.AccountingDocumentCategory <> 'M'         -- Documento modelo 
