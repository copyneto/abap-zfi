@EndUserText.label: 'DD - Log'
@AccessControl.authorizationCheck: #CHECK
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_FI_CONTAB_LOG
  as projection on ZI_FI_CONTAB_LOG as Log
{
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_CompanyCodeVH', element: 'CompanyCode' }  } ]
      @Search.defaultSearchElement: true
  key Bukrs,
  key Anln1,
  key Anln2,
  key Anlkl,
  key Gsber,
  key Kostl,
  key Gjahr,
  key Peraf,
      @EndUserText.label: 'Doc. Societário'
      Belnr,
      @EndUserText.label: 'Doc. Reav'
      BelnrReav,
      @EndUserText: {
          label: 'Contabilizado',
          quickInfo: ''
      }
      Contab as Contab,
      @EndUserText: {
          label: 'Contabilizado Reav',
          quickInfo: ''
      }
      Reav   as Reav,
      @Search.defaultSearchElement: true
      @Consumption.filter.selectionType: #INTERVAL
      Cpudt,
      @Search.defaultSearchElement: true
      @Consumption.filter.selectionType: #INTERVAL
      Cputm,

      @Search.defaultSearchElement: true
      @Consumption.filter.selectionType: #INTERVAL
      @EndUserText.label: 'Data Reav'
      CpudtReav,
      @EndUserText.label: 'Hora Reav'
      @Search.defaultSearchElement: true
      @Consumption.filter.selectionType: #INTERVAL
      CputmReav




}
