@EndUserText.label: 'CDS de Contrato Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_CONTRATO_CLIENTE
  as projection on ZI_FI_CONTRATO_CLIENTE
{

  key Contrato,
      @EndUserText.label: 'Nº Aditivo'
  key Aditivo,
      RazaoSocial,
      NomeFantasia,
      ContratoProprio,
      @ObjectModel.text.element: ['EmpresaText']
      Empresa,
      @ObjectModel.text.element: ['BusinessPlaceName']
      LocalNegocios,
      DataIniValid,
      DataFinValid,
      Cliente,
      CNPJ,
      RazaoSoci,
      ProdContemplado,
      Status,
      GrpEconomico,
      Crescimento,
      CrescCriticality,
      Contabilizado,
      ContabilizadoCriti,
      AjusteAnual,
      @EndUserText.label: 'Exercício'
      ExercAtual,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _Empresa.EmpresaText      as EmpresaText,
      _LocNeg.BusinessPlaceName as BusinessPlaceName,
      @EndUserText.label: 'Exercício p/ Execução'
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'C_FiscalYearForCompanyCodeVH', element: 'FiscalYear' } }]
      Gjahr,
      @EndUserText.label: 'Data de Lançamento'
      Budat,
      /* Associations */
      _LOG : redirected to composition child ZC_FI_LOG_CALC_CRESCIMENTO
}
