@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection Cockpit Créditos Clientes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_FI_COCKPIT_CREDITOS_CLI
  as projection on ZI_FI_COCKPIT_CREDITOS_CLI as _Credidos
{
  key Empresa,
  key Cliente,
  key RaizId,
  key RaizSn,  
  key Documento,
  key Ano,
  key Linha,
      CodCliente,
      @Semantics.amount.currencyCode: 'Moeda'
      Residual,
      TipoDocumento,
      ChaveLancamento,
      CodigoRZE,
      VencimentoLiquido,
      Atribuicao,
      Referencia,
      DataLancamento,
      FormaPagamento,
      CondicaoPagamento,
      Moeda,
 //     @Aggregation.default: #SUM
      @Semantics.amount.currencyCode: 'Moeda'
      Montante,
      Desconto,
      
      /* Associations */
      _Associ : redirected to parent ZC_FI_COCKPIT_ASSOCIACAO_CRE
}
