@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Soma do imobilizado'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity zi_fi_imob_sum
  as select from ZI_FI_IMOB   as a
    inner join   ZI_FI_IMOB34 as _imob34 on  a.anln1 = _imob34.anln1
                                         and a.anln2 = _imob34.anln2
                                         and a.bukrs = _imob34.bukrs
                                         and a.bstdt = _imob34.bstdt
                                         and a.gjahr = _imob34.gjahr
{
  key a.anln1,
  key a.anln2,
  key a.bukrs,
  key a.gjahr, 
  key a.afabe,
      a.aktiv,
      a.anlkl,
      a.bstdt,
      a.gsber,
      a.waers,
      @Semantics.amount.currencyCode : 'waers'
      a.kansw,
      @Semantics.amount.currencyCode : 'waers'
      a.knafa,
      cast( a.answl as abap.dec(23,2) )                                          as answl,
      cast( a.nafag as abap.dec(23,2) )                                          as nafag,
      a.zaqui,
      a.zdepr,
      a.Moeda                                                                    as Moeda,
      cast( _imob34.answl as abap.dec(23,2) )                                    as answl34,
      cast( _imob34.nafag as abap.dec(23,2) )                                    as nafag34,
      cast( _imob34.kansw as abap.dec(23,2) )                                    as kansw34,
      cast( _imob34.knafa as abap.dec(23,2) )                                    as knafa34,
      sum(cast( a.answl  as abap.dec(23,2) ) + cast( a.nafag as abap.dec(23,2))) as vlContab,
      cast( 0 as abap.dec(23,5) )                                                as ukurs,
      cast( 0 as abap.dec(23,2) )                                                as valorAq,
      cast( 0 as abap.dec(23,2) )                                                as Deprec,
      cast( 0 as abap.dec(23,2) )                                                as vlContab34,
      cast( 0 as abap.dec(23,2) )                                                as valorAqAjuste,
      cast( 0 as abap.dec(23,2) )                                                as DeprecAcum,
      cast( '' as abap.sstring( 100 ) )                                          as mensagem
}
group by
  a.anln1,
  a.anln2,
  a.bukrs,
  a.gjahr,
  a.afabe,
  a.aktiv,
  a.anlkl,
  a.bstdt,
  a.gsber,
  a.waers,
  a.kansw,
  a.knafa,
  a.answl,
  a.nafag,
  a.zaqui,
  a.zdepr,
  a.Moeda,
  _imob34.answl,
  _imob34.nafag,
  _imob34.kansw,
  _imob34.knafa  
