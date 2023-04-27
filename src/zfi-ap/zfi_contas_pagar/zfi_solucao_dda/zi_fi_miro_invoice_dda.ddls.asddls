@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Dados da MIRO para DDA'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZI_FI_MIRO_INVOICE_DDA
  as select from I_AccountingDocument as AccountingDocument
  association [0..1] to bseg as _Segment on  $projection.CompanyCode        = _Segment.bukrs
                                         and $projection.AccountingDocument = _Segment.belnr
                                         and $projection.FiscalYear         = _Segment.gjahr
{
  key CompanyCode,
  key AccountingDocument,
  key FiscalYear,
      AccountingDocumentType,
      PostingDate,
      DocumentReferenceID,
      ReferenceDocumentType,
      OriginalReferenceDocument,
      Currency,
      //      @Semantics.amount.currencyCode: 'Currency'
      //      _Segment.wrbtr as Amount,
      //      _Segment.zlsch as PaymentMethod,
      //      _Segment.sgtxt as AccountText,
      //      _Segment.lifnr as Supplier,


      //      Associations
      _Segment
}
where
     _Segment.zlsch = 'B'
  or _Segment.zlsch = ''
group by
  CompanyCode,
  AccountingDocument,
  FiscalYear,
  AccountingDocumentType,
  PostingDate,
  DocumentReferenceID,
  ReferenceDocumentType,
  OriginalReferenceDocument,
  Currency
