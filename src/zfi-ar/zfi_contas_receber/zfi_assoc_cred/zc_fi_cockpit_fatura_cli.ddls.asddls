@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection Cockpit Fatura Clientes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_FI_COCKPIT_FATURA_CLI
  as projection on ZI_FI_COCKPIT_FATURA_CLI as _Fatura
{
  key Empresa,
  key Cliente,
  key RaizId,
  key RaizSn,  
  key Documento,
  key Ano,
  key Linha,
      CodCliente,
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
      @Semantics.amount.currencyCode: 'Moeda'
      Montante,
      Desconto,
      @EndUserText.label: 'Marcado'
      Marcado,
      @EndUserText.label: 'Marcado'
      MarcadoCriticality,
      
      /* Associations */
      _Associ : redirected to parent ZC_FI_COCKPIT_ASSOCIACAO_CRE
}

