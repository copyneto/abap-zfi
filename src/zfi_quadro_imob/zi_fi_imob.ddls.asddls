@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Imobilizado'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

define root view entity ZI_FI_IMOB
  as select from    anla            as a
    inner join      Faa_Anlc        as b on  a.bukrs = b.bukrs
                                         and a.anln1 = b.anln1
                                         and a.anln2 = b.anln2
                                         and b.afabe = '80'
    inner join      anlz            as c on  a.bukrs = c.bukrs
                                         and a.anln1 = c.anln1
                                         and a.anln2 = c.anln2
    inner join      t093b           as d on  b.bukrs = d.bukrs
                                         and d.afabe = '80'
    inner join      t001            as g on a.bukrs = g.bukrs
  //    inner join      tcurr           as h on  h.kurst = 'Z'
  //                                         and h.fcurr = g.waers
  //                                         and h.tcurr = 'USD'
    left outer join ztfi_imob_param as i on i.zclas = a.anlkl
{

  key a.anln1,
  key a.anln2,
  key a.bukrs,
  key b.gjahr,
  key b.afabe,
      a.aktiv,
      a.anlkl,
      a.bstdt,
      c.gsber,
      d.waers,
      @Semantics.amount.currencyCode : 'waers'
      sum(b.kansw) as kansw,
      @Semantics.amount.currencyCode : 'waers'
      sum(b.knafa) as knafa,
      @Semantics.amount.currencyCode : 'waers'
      sum(b.answl) as answl,
      @Semantics.amount.currencyCode : 'waers'
      sum(b.nafag) as nafag,
      g.waers      as Moeda,
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
  b.afabe,
  a.aktiv,
  a.anlkl,
  a.bstdt,
  c.gsber,
  d.waers,
  g.waers,
  i.zaqui,
  i.zdepr
