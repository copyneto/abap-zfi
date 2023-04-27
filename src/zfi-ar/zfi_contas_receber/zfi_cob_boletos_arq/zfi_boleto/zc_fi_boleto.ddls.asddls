@EndUserText.label: 'Consumption para ZI_FI_BOLETO'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_BOLETO
  as projection on ZI_FI_BOLETO
{
  @Search.defaultSearchElement: true
  key Empresa,
  @Search.defaultSearchElement: true
  key Documento,
  @Search.defaultSearchElement: true
  key Ano,
  @Search.defaultSearchElement: true
  key Item,
  @Search.defaultSearchElement: true
  Cliente,
  @Search.defaultSearchElement: true
  LocalNegocio,
  @Search.defaultSearchElement: true  
  FormaPgto,
  @Search.defaultSearchElement: true  
  Montante,
  waers,
  @Search.defaultSearchElement: true
  Divisao,
  @Search.defaultSearchElement: true
      Banco,
      xref3
}
