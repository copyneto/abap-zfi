@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help search Treasury Update Type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{ by: 'TreasuryUpdateType', direction: #ASC }] }]
define view entity ZI_FI_VH_TREASURYUPDATETYPE
  as select from I_Treasuryupdatetype as TreasuryUpdateType
  association to I_Treasuryupdatetypetext as _Text
    on  $projection.TreasuryUpdateType = _Text.TreasuryUpdateType
    and _Text.Language                 = $session.system_language
{

      @ObjectModel.text.element: ['Text']
      @Search.defaultSearchElement: true
  key TreasuryUpdateType.TreasuryUpdateType as TreasuryUpdateType,
      @Search.defaultSearchElement: true
      _Text.TreasuryUpdateTypeName          as Text
}
