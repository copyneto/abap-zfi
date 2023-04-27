@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Help search Financial Instr Product type'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_VH_FIINSTRPRODTTYPE
  as select from I_FinancialinstrProductType
  association [0..*] to I_FinancialInstrProdTypeText as _Text
    on  $projection.FinancialInstrumentProductType = _Text.FinancialInstrumentProductType
    and _Text.Language                             = $session.system_language
{

      @ObjectModel.text.element: ['FinancialInstrProdTypeName']
      @Search.defaultSearchElement: true
  key FinancialInstrumentProductType,
      TreasuryContractType,
      FinancialInstrProductCategory,
      _Text.FinancialInstrProdTypeName,
      /* Associations */
      _FinancialInstrProdCat,
      _Text
}
