@EndUserText.label: 'Contabilização'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_CONTABILIZAR
  as projection on ZI_FI_CONTABILIZAR
{
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_BUKRS', element: 'Empresa' } } ]
  key Bukrs,
  key Anln1,
  key Anln2,
  key Anlkl,
  key gsber,
  key kostl,
      @Consumption.filter: { mandatory: true }
  key gjahr,
      @Consumption.filter: { mandatory: true }
  key peraf,
      AnlklTxt,
      Aktiv,
      Moeda,
      @EndUserText.label: 'Depreciação Plan. Fiscal_01'
      Nafag01,
       @EndUserText.label: 'Depreciação Plan. Fiscal_10'
      Nafag10,
       @EndUserText.label: 'Depreciação Plan. Fiscal_11'
      Nafag11,
      Nafag80,
      Nafag82,
      Nafag84,

      @EndUserText.label: 'Valor aquisição 80'
      ANSWL_80,
      @EndUserText.label: 'Depreciação acumulada 80'
      NAFAG_80,
      @EndUserText.label: 'Valor Contab. 80'
      Valorcont80,
      
      @EndUserText.label: 'Contabilizado Societário'
      Belnr,
      StatusCriticality,
        
      BelnrReav,
      StatusCriticalityReav,

      Ajus80_01,
      Ajus82_10,
      Ajus84_11,
      Total,
      @EndUserText.label: 'Conta Deprec Acm Fiscal_01'
      ContaDepFiscal_01,
      @EndUserText.label: 'Conta Deprec Acm Fiscal_10'
      ContaDepFiscal_10,
      @EndUserText.label: 'Conta Deprec Acm Fiscal_11'
      ContaDepFiscal_11,
      @EndUserText.label: 'Conta Despesa Fiscal_01'
      ContaDespFiscal_01,
      @EndUserText.label: 'Conta Despesa Fiscal_10'
      ContaDespFiscal_10,
      @EndUserText.label: 'Conta Despesa Fiscal_11'
      ContaDespFiscal_11,
      @EndUserText.label: 'Conta Deprec Acm Societária_80'
      ContaDepFiscal_80,
      @EndUserText.label: 'Conta Deprec Acm Societária_82'
      ContaDepFiscal_82,
      @EndUserText.label: 'Conta Deprec Acm Societária_84'
      ContaDepFiscal_84,
      @EndUserText.label: 'Conta Despesa Societária_80'
      ContaDespFiscal_80,
      @EndUserText.label: 'Conta Despesa Societária_82'
      ContaDespFiscal_82,
      @EndUserText.label: 'Conta Despesa Societária_84'
      ContaDespFiscal_84
}
