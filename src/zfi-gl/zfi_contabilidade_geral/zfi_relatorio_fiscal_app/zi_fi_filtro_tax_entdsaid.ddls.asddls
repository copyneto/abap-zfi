@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro de Imposto'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FILTRO_TAX_ENTDSAID
  as select from I_BR_NFTax
{
  key BR_NotaFiscal,
  key BR_NotaFiscalItem,
      TaxGroup,
      cast(sum(BR_NFItemBaseAmount) as abap.dec( 15, 2 ) ) as BR_NFItemBaseAmount,
      cast(sum(BR_NFItemTaxAmount) as abap.dec( 15, 2 ))   as BR_NFItemTaxAmount
}
group by
  BR_NotaFiscal,
  BR_NotaFiscalItem,
  TaxGroup
