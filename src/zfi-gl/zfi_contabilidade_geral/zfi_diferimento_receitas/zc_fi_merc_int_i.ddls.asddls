@EndUserText.label: 'CDS de Projeção - Mercado Interno Item'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_MERC_INT_I
  as projection on ZI_FI_MERC_INT_I
{
  key Empresa,
  key NumDoc,
  key Ano,
  key Item,
      Cliente,
      Conta,
      Divisao,
      Atribuicao,
      TextItem,
      CredDeb,
      LocalNegocio,
      CentroLucro,
      CentroCusto,
      Segmento,
      Moeda,
      @EndUserText.label: 'Valor'
      Valor,
      ValorCriticality,
      /* Associations */
      _MercIntHeader: redirected to parent ZC_FI_MERC_INT_H
}
