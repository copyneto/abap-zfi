@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Mercado Externo Header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_MERC_EXT_H_BRL
  as select from ZI_FI_MERC_EXT_LOG    as Header

    inner join   I_BillingDocument     as _VendasHeader on  ( _VendasHeader.AccountingDocument             =  Header.awkey
                                                        or _VendasHeader.AccountingDocument             =  Header.belnr )
                                                        and ( _VendasHeader.BillingDocumentType =  'Z002' 
                                                         or  _VendasHeader.BillingDocumentType =  'Y078' )
                                                        and _VendasHeader.CustomerAccountAssignmentGroup <> '03'

    inner join   ZI_FI_I_BillingDocumentItem as _VendasItem   on  _VendasItem.BillingDocument     = _VendasHeader.BillingDocument
    
    inner join   ZI_FI_ORDEM_FRETE     as _OrdemFrete   on _OrdemFrete.Remessa = _VendasItem.ReferenceSDDocument

    inner join   vbak                  as _OdemVendas   on  _OdemVendas.vbeln          = _VendasItem.SalesDocument
//                                                        and _OdemVendas.zz1_dataem_sdh = '00000000'

{
  key Header.bukrs as Empresa,
  key Header.belnr as NumDoc,
  key Header.gjahr as Ano,
      Header.bldat as DataDocumento,
      Header.budat as DataLancamento,
      Header.monat as Mes,
      Header.blart as TipoDocumento,
      Header.waers as Moeda,
      Header.xblnr as Referencia,
      Header.bktxt as TextoCab,
      @EndUserText.label: 'Data Lançamento'
      ''           as DataLanc,
      @EndUserText.label: 'Data Estorno'
      ''           as DataEstorno,
      //      Header.awkey as ChaveRef,
      _VendasItem.ReferenceSDDocument,
      _VendasHeader.TransactionCurrency      as TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _VendasHeader.TotalNetAmount           as TotalNetAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _VendasHeader.TotalTaxAmount           as TotalTaxAmount,
      cast( _VendasHeader.TotalNetAmount as abap.dec( 13, 3 )) * _VendasItem.PriceDetnExchangeRate as TotalNetBRL,
      cast( _VendasHeader.TotalTaxAmount as abap.dec( 13, 3 )) * _VendasItem.PriceDetnExchangeRate as TotalTaxBRL,

//    @Semantics.amount.currencyCode: 'CurrencyBRL'
//    currency_conversion(
//       amount             => _VendasHeader.TotalNetAmount,
//        source_currency    => _VendasHeader.TransactionCurrency,
//        target_currency    => cast('BRL' as abap.cuky),
//        exchange_rate_date => _VendasHeader.BillingDocumentDate
//      )        as TotalNetBRL,
//    @Semantics.amount.currencyCode: 'CurrencyBRL'
//    currency_conversion(
//        amount             => _VendasHeader.TotalTaxAmount,
//        source_currency    => _VendasHeader.TransactionCurrency,
//        target_currency    => cast('BRL' as abap.cuky),
//        exchange_rate_date => _VendasHeader.BillingDocumentDate
//      )        as TotalTaxBRL,
    cast('BRL' as abap.cuky) as CurrencyBRL,      
    cast( _VendasHeader.TotalNetAmount as abap.dec( 13, 2 )) as Amount,
    _OdemVendas.zz1_dataem_sdh,
    _VendasItem.SalesDocument,
    _VendasHeader.BillingDocumentType
    }
where
  Header.ChaveExiste = 'X' 
  and _OdemVendas.zz1_dataem_sdh is initial
