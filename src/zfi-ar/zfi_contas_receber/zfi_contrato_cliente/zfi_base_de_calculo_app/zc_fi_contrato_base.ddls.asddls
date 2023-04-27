@EndUserText.label: 'Contrato de cliente Base de Calculo'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_CONTRATO_BASE 
  as projection on ZI_FI_CONTRATO_BASE
{
  key Contrato,
      @EndUserText.label: 'Nº Aditivo'
  key Aditivo,
      ContratoProprio,
      @ObjectModel.text.element: ['EmpresaText']
      Empresa,
      @ObjectModel.text.element: ['BusinessPlaceName']
      LocalNegocios,
      DataIniValid,
      DataFinValid,
      Cliente,
      @ObjectModel.text.element: ['RazaoSoci']
      CNPJ,
      RazaoSoci,
      ProdContemplado,
      Status,
      GrpEconomico,
      Crescimento,
      CrescCriticality,
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
//      @EndUserText.label: 'Exercício p/ Execução'
//      @Consumption.valueHelpDefinition:   [{ entity: {name: 'C_FiscalYearForCompanyCodeVH', element: 'FiscalYear' } }]
//      Gjahr,
//      @EndUserText.label: 'Data de Lançamento'
//      Budat,
      
//    Wrbtr,
//    Bschl,
//    Blart,
//    Zuonr,
//    Kunnr,
//    Zlsch,
//    Sgtxt,
//    Netdt,
//    Xblnr,
//    Budat,
//    Bldat,
//    Augbl,
//    Augdt,
//    Vbeln,
//    Posnr,
//    Vgbel,
//    Vtweg,
//    Spart,
//    Bzirk,
//    Katr2,
//    Wwmt1,
//    Prctr,
//    Gsber,
//    TipoEntrega,
//    Xref1Hd,
//    StatusDde,
//    TipoApuracao,
//    TipoApImposto,
//    TipoImposto,
//    ImpostDesconsid,
//    MontLiqTax,
//    MontValido,
//    TipoDesconto,
//    CondDesconto,
//    Kostl,
//    MontBonus,
//    BonusCalculado,
//    ObsAjuste,

      /* Associations */
      _BASE : redirected to composition child ZC_FI_BASE_DE_CALCULO
}
