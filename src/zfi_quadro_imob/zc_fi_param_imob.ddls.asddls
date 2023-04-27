@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Parâmetros imobilizados'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['Zclas']
@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_FI_PARAM_IMOB
  as projection on zi_fi_param_imob
{
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'Zi_ca_vh_anla', element : 'anlkl' }}]
  key Zclas,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'Zi_ca_vh_skat', element : 'Saknr' }}]
      Zaqui,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'Zi_ca_vh_skat', element : 'Saknr' }}]
      Zdepr,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
