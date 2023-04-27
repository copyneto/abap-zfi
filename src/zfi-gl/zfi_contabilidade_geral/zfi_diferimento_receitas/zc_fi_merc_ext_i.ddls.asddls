@EndUserText.label: 'CDS de Projeção - Mercado Externo Item'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_MERC_EXT_I
  as projection on ZI_FI_MERC_EXT_I
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
      CurrencyBRL,
      @EndUserText.label: 'Valor'
      Valor,
      ValorCriticality,
      /* Associations */
      _MercExtHeader : redirected to parent ZC_FI_MERC_EXT_H
}
