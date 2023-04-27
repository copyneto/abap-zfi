@EndUserText.label: 'CDS de projeção - Contrato Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true

@ObjectModel.semanticKey: ['Contrato', 'Aditivo']
define root view entity ZC_FI_CONTRATO_CRESC
  as projection on ZI_FI_CONTRATO_CRESC
{
  key DocUuidH,
      Contrato,
      Aditivo,
      Contrato_proprio,
      Contrato_jurid,
      Data_ini_valid,
      Data_fim_valid,
      CnpjPrincipal,
      RazaoSocial,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH', element: 'CompanyCode' }}]
      Bukrs,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_CA_VH_BRANCH', element: 'BusinessPlace' },
                                           additionalBinding: [{  element: 'CompanyCode', localElement: 'Bukrs' }] }]
      Branch,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _CadCresci  : redirected to composition child ZC_FI_CAD_CRESCI,
      _CompCresci : redirected to composition child ZC_FI_COMP_CRESCI,
      _FaixaCresc : redirected to composition child ZC_FI_FAIXA_CRESC,
      _FamiliaCresc : redirected to composition child ZC_FI_FAMILIA_CRESC

}
