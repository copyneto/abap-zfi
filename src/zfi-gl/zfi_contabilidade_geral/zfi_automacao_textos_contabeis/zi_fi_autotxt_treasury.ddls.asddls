@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automação textos contábeis - Dados TRM'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_AUTOTXT_TREASURY
  as select from P_TracvAccitem as TreasuryItem
  association to I_PositionIdentifier as _PositionIdentifier
    on $projection.PosIdentityUUID = _PositionIdentifier.TrsyPositionIdentificationUUID
{

      /* Baseado na view TRACV_ACCITEM*/
  key TreasuryItem.DocumentUUID,
  key TreasuryItem.AccountingDocumentItemRef,
      cast( right( TreasuryItem.AccountingDocumentItemRef, 3 ) as buzei ) as AccountingItemBuzei,
      TreasuryItem.PosContexUUID,
      TreasuryItem.TreasuryUpdateType,
      TreasuryItem.TreasuryUpdateTypeName,
      TreasuryItem.AccountingDocument,
      TreasuryItem.FiscalYear,
      TreasuryItem.PosIdentityUUID,
      _PositionIdentifier.TrsyPositionIdentificationUUID,
      _PositionIdentifier.FinancialInstrumentProductType,
      _PositionIdentifier.CompanyCode,
      /* Associations */
      _PositionIdentifier

}
