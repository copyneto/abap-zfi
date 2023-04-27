@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'View Imobilizado 34'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_IMOB34
  as select from    anla            as a
    inner join      Faa_Anlc        as b on  a.bukrs = b.bukrs
                                         and a.anln1 = b.anln1
                                         and a.anln2 = b.anln2
                                         and b.afabe = '34'
    inner join      t093b           as d on  d.bukrs = b.bukrs
                                         and d.afabe = b.afabe
    left outer join ztfi_imob_param as i on i.zclas = a.anlkl
{

  key a.anln1,
  key a.anln2,
  key a.bukrs,
      b.gjahr,
      a.aktiv,
      a.anlkl,
      a.bstdt,
      d.waers,
      @Semantics.amount.currencyCode : 'waers'
      sum(b.kansw) as kansw,
      @Semantics.amount.currencyCode : 'waers'
      sum(b.knafa) as knafa,
      b.afabe,
      @Semantics.amount.currencyCode : 'waers'
      sum(b.answl) as answl,
      @Semantics.amount.currencyCode : 'waers'
      sum(b.nafag) as nafag,
      i.zaqui,
      i.zdepr

}
where
  a.deakt is initial
group by
  a.anln1,
  a.anln2,
  a.bukrs,
  b.gjahr,
  a.aktiv,
  a.anlkl,
  a.bstdt,
  d.waers,
  b.afabe,
  i.zaqui,
  i.zdepr
