@EndUserText.label: 'Clientes do CNPJ Raiz'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_RAIZ_CLIENTES
  as projection on ZI_FI_RAIZ_CLIENTES
{
  key DocUuidH,
  key DocUuidRaiz,
  key Cliente,
       @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH', element: 'CompanyCode' }}]
  key Empresa,
      CnpjRaiz, 
      Contrato, 
      Aditivo,
      Atributo10,
      Cnpj,
      Nome1,
      RegiaoVendas,
      FormaPagamento,
      CondPagamentos,
      Centro,
      OrgVendas,
      CanalDistribuicao,
      SetorAtividade,
      ClassifCnpj,
      GrupoEconomico,
      Bandeira,
      Abrangencia,
      Estrutura,
      CanalPDV,
      EscritorioVendas,
      EquipeVendas,
      GruposCondicoes,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Raiz : redirected to parent ZC_FI_RAIZ_CNPJ
}
