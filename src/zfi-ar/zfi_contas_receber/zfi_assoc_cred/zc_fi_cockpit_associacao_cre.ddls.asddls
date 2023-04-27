@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection Cockpit Associação Créditos'
@Metadata.allowExtensions: true
define root view entity ZC_FI_COCKPIT_ASSOCIACAO_CRE
  as projection on ZI_FI_COCKPIT_ASSOCIACAO_CRE as _Associ
{
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_BUKRS', element: 'Empresa' } }]
  key Empresa,
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_KUNNR', element: 'Kunnr' }}]
  key Cliente,
//      @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_RAIZCODID', element: 'RaizId' }}]
      @EndUserText.label: 'Raiz ID'
  key RaizId,
      @EndUserText.label: 'Raiz ID Sim/Não'
      @Consumption.filter:{ mandatory:true, defaultValue: ' ', selectionType: #SINGLE }
  key RaizSn,
      _Empresa.EmpresaText as EmpresaText,
      _RaizId.Nome         as Nome,
      Montante,
      FaturaMontante,
      TotalizadorDetalhe1,
      TotalizadorDetalhe2,
      TotalizadorDetalhe3,
      TotalizadorDetalhe4,

      /* Associations */
      _Creditos     : redirected to composition child ZC_FI_COCKPIT_CREDITOS_CLI,
      _Fatura       : redirected to composition child ZC_FI_COCKPIT_FATURA_CLI
      

}
