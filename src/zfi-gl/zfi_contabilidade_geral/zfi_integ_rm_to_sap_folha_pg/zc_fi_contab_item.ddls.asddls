@EndUserText.label: 'CDS de Projeção - Contabilização Item'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CONTAB_ITEM
  as projection on ZI_FI_CONTAB_ITEM
{
  key Id,
  key Identificacao,
  key Item,
      DebCred,
      Atribuicao,
      Conta,
      Divisao,
      CentroCusto,
      CentroLucro,
      @EndUserText.label: 'Segmento'
      Segmento,
      @EndUserText.label: 'Texto item'
      TextoItem,
      @EndUserText.label: 'Valor'
      Valor,
      ValorCriticality,
      Moeda,
      @EndUserText.label: 'Mensagem'
      TextoErro,
      /* Associations */
      _Header : redirected to parent ZC_FI_CONTAB_CAB
}
