@EndUserText.label: 'Retirar bloqueios'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_RET_BLOQ
  as projection on ZI_RET_BLOQ
{
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }]
      @EndUserText.label: 'Empresa'
  key bukrs,
      @Consumption.valueHelpDefinition: [ { entity:  { name:    'I_Customer_VH', element: 'Customer' } }]
      @EndUserText.label: 'Cliente'
  key kunnr,
      @EndUserText.label: 'Numero documento'
  key belnr,
      @EndUserText.label: 'Item Doc'
  key buzei,
      @EndUserText.label: 'Exercício'
  key gjahr,
      xblnr,
      zuonr,
      hbkid,
      zlsch,
      blart,
      zlspr,
      bschl,
      zterm,
      netdt,
      sgtxt,
      zumsk,
      umskz,
      gsber,
      dmbtr,
      bktxt,
      cpudt,
      cputm,
      koart
}
