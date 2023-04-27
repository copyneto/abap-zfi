@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Mercado Externo Header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_MERC_EXT_H
  as select from ZI_FI_MERC_EXT_H_BRL as Header

  composition [1..*] of ZI_FI_MERC_EXT_I as _MercExtItem

{
key Header.Empresa,
key Header.NumDoc,
key Header.Ano,
Header.DataDocumento,
Header.DataLancamento,
Header.Mes,
Header.TipoDocumento,
Header.Moeda,
Header.Referencia,
Header.TextoCab,
Header.DataLanc, 
Header.DataEstorno, 
Header.ReferenceSDDocument,
Header.TransactionCurrency,
@Semantics.amount.currencyCode: 'TransactionCurrency'
Header.TotalNetAmount,
@Semantics.amount.currencyCode: 'TransactionCurrency'
Header.TotalTaxAmount,
@Semantics.amount.currencyCode: 'CurrencyBRL'
Header.TotalNetBRL,
@Semantics.amount.currencyCode: 'CurrencyBRL'
Header.TotalTaxBRL,
Header.CurrencyBRL,
cast( Header.TotalNetBRL as abap.dec( 13, 2 ))  + cast( Header.TotalTaxBRL as abap.dec( 13, 2 ))  as TotalAmountBRL,
Header.Amount,
_MercExtItem
}
