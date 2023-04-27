@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Reversão da Provisão PDC'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true

define root view entity ZI_FI_REVERSAO_PROVISAO_PDC
  as select from    I_OperationalAcctgDocItem as _AccountingDocumentItem

    left outer join ZI_FI_DC_PARAM_TIPO_DOC   as _ParamAccountingDocumentType on _ParamAccountingDocumentType.AccountingDocumentType = _AccountingDocumentItem.AccountingDocumentType

  association [1..1] to I_AccountingDocument as _AccountingDocument    on  _AccountingDocument.CompanyCode        = $projection.CompanyCode
                                                                       and _AccountingDocument.FiscalYear         = $projection.FiscalYear
                                                                       and _AccountingDocument.AccountingDocument = $projection.AccountingDocument

  association [0..1] to ZI_CA_VH_ZLSCH       as _PaymenthMethod        on  _PaymenthMethod.FormaPagamento = $projection.PaymentMethod
  association [0..1] to ZI_CA_VH_ZLSPR       as _PaymentBlockingReason on  _PaymentBlockingReason.BloqPagamento = $projection.PaymentBlockingReason
  association [0..1] to ZI_CA_VH_BRANCH      as _BusinessPlace         on  _BusinessPlace.CompanyCode   = $projection.CompanyCode
                                                                       and _BusinessPlace.BusinessPlace = $projection.BusinessPlace


{
      @Search.defaultSearchElement: true
  key _AccountingDocumentItem.CompanyCode,
      @Search.defaultSearchElement: true
  key _AccountingDocumentItem.AccountingDocument,
      @Search.defaultSearchElement: true
  key _AccountingDocumentItem.FiscalYear,
  key _AccountingDocumentItem.AccountingDocumentItem,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.Customer,
      _AccountingDocumentItem._CompanyCode.CompanyCodeName,
      _AccountingDocumentItem._Customer.CustomerName,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.PostingKey,
      _AccountingDocumentItem._PostingKey._PostingKeyText
      [1:Language = $session.system_language].PostingKeyName,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.SpecialGLCode,
      _AccountingDocumentItem._SpecialGLCode._Text
      [1:Language = $session.system_language].SpecialGLCodeLongName as SpecialGLCodeName,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.PaymentMethod,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.PaymentBlockingReason,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.AssignmentReference,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.DocumentItemText,

      case when _ParamAccountingDocumentType.AccountingDocumentType is not null
      then cast ( 'X' as boole_d )
      else cast ( ' ' as boole_d )
      end                                                           as AccountingDocumentTypeOk,

      case when _ParamAccountingDocumentType.AccountingDocumentType is not null
      then 3
      else 1
      end                                                           as AccountingDocumentTypeCrit,
      @Search.defaultSearchElement: true
      _AccountingDocument.AccountingDocumentType,
      _AccountingDocument._AccountingDocumentType._Text
      [1:Language = $session.system_language].AccountingDocumentTypeName,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.DocumentDate,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.PostingDate,
      @Search.defaultSearchElement: true
      _AccountingDocument.DocumentReferenceID,
      @Search.defaultSearchElement: true
      _AccountingDocument.AccountingDocumentHeaderText,
      @Search.defaultSearchElement: true
      _AccountingDocument.Reference1InDocumentHeader,
      @Search.defaultSearchElement: true
      _AccountingDocument.Reference2InDocumentHeader,
      _AccountingDocumentItem.BalanceTransactionCurrency,
      @Semantics.amount.currencyCode: 'BalanceTransactionCurrency'
      _AccountingDocumentItem.AmountInBalanceTransacCrcy,

      /* Campos para BAPI */

      @Search.defaultSearchElement: true
      _AccountingDocumentItem.Plant,
      _AccountingDocumentItem._Plant.PlantName,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.BusinessPlace,
      _BusinessPlace.BusinessPlaceName,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.CostCenter,
      _AccountingDocumentItem._CostCenterText
      [1:Language = $session.system_language].CostCenterName,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.BusinessArea,
      _AccountingDocumentItem._BusinessAreaText
      [1:Language = $session.system_language].BusinessAreaName,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.ProfitCenter,
      _AccountingDocumentItem._ProfitCenterText
      [1:Language = $session.system_language].ProfitCenterName,
      @Search.defaultSearchElement: true
      _AccountingDocumentItem.Segment,
      _AccountingDocumentItem._SegmentText
      [1:Language = $session.system_language].SegmentName,
      _AccountingDocumentItem.OperationalGLAccount,
      _AccountingDocumentItem.Reference1IDByBusinessPartner,
      _AccountingDocumentItem.Reference2IDByBusinessPartner,
      _AccountingDocumentItem.Reference3IDByBusinessPartner,

      /* Campos de filtro de seleção */

      _AccountingDocumentItem.FinancialAccountType,
      _AccountingDocumentItem.ClearingAccountingDocument,
      _AccountingDocumentItem.AccountingDocumentCategory,

      /* Campos Abstract */
      cast( '1' as ze_fi_revert_pdc )                               as RevertType,

      /* Associations */
      _AccountingDocument,
      _PaymenthMethod,
      _PaymentBlockingReason,
      _BusinessPlace
}

where
      _AccountingDocumentItem.FinancialAccountType       =  'D'                 -- Cliente 
  and _AccountingDocumentItem.ClearingAccountingDocument =  ''
  and _AccountingDocumentItem.AccountingDocumentCategory <> 'D'                 -- Documento de lançamento periódico 
  and _AccountingDocumentItem.AccountingDocumentCategory <> 'M'                 -- Documento modelo 
  and _AccountingDocument.Reference1InDocumentHeader     <> 'APPR'              -- Aprovados
  and _AccountingDocument.Reference1InDocumentHeader     <> 'REVERTIDOAPP'      -- Revertidos
