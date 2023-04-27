@EndUserText.label: 'Clientes Raiz CNPJ - Contrato Cliente'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CLIENTES_CONT
  as projection on ZI_FI_CLIENTES_CONT
{
  key DocUuidH,
  key DocUuidRaiz,
  key Cliente,
  key Empresa,
  key RegiaoVendas,
      Contrato,
      Aditivo,
      CnpjRaiz,
      Atributo10,
      Cnpj,
      Nome1,
//      RegiaoVendas,
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
      _Contrato : redirected to ZC_FI_CONTRATO,
      _Raiz     : redirected to parent ZC_FI_RAIZ_CNPJ_CONT
}
