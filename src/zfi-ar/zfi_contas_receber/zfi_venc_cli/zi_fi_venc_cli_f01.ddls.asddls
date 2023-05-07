@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface Venc Mod Part de Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_VENC_CLI_F01
  as select from    bsid_view                    as b
    inner join      kna1                         as k     on b.kunnr = k.kunnr
    left outer join ZI_FI_GET_DTENTREGA_BY_VBELN as deliv on b.vbeln = deliv.vbeln
    left outer join P_BSEG_COM                   as p     on  p.belnr = b.belnr
                                                          and p.bukrs = b.bukrs
                                                          and p.gjahr = b.gjahr
                                                          and p.buzei = b.buzei
    left outer join I_BillingDocumentBasic       as i     on b.vbeln = i.BillingDocument
    left outer join ZI_CA_VH_MANSP               as m     on b.mansp = m.BloqAdv
{
  key b.bukrs                                                          as Empresa,
  key b.kunnr                                                          as Cliente,
  key b.belnr                                                          as NoDocumento,
  key b.gjahr                                                          as Exercicio,
  key b.buzei                                                          as Item,
      k.stcd1                                                          as Cnpj,
      k.stcd2                                                          as Cpf,
      k.name1                                                          as Nome1,
      b.blart                                                          as TpDocumento,
      b.sgtxt                                                          as Texto,
      b.xblnr                                                          as Referencia,
      b.zuonr                                                          as Atribuicao,
      b.budat                                                          as DataLanc,
      b.gsber                                                          as Divisao,
      b.zlsch                                                          as FormaPagto,
      b.mansp                                                          as BloqAdvert,
      m.BloqAdvText                                                    as Denominacao,
      p.netdt                                                          as VencimentoEm,
      b.zterm                                                          as CondPgto,
      b.anfbn                                                          as DocProc,
      //      @ObjectModel.virtualElement: true
      //      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCLMM_CDS_REMRET'
      dats_days_between(p.netdt, $session.system_date)                 as DiasAtraso,
      @Semantics.amount.currencyCode: 'Moeda'
      b.wrbtr                                                          as MontMoedaInt,
      b.waers                                                          as Moeda,
      b.vbeln                                                          as DocFaturamento,
      i.DistributionChannel                                            as CanalDist,
      i.Division                                                       as SetorAtiv,
      b.bukrs                                                          as OrgVendas,
      i.Region                                                         as Regiao,
      cast( deliv.DataEntrega as datum )                               as DataEntrega,
      dats_days_between(b.budat, cast( deliv.DataEntrega as datum )  ) as DifLanc,
      //''                                               as DifLanc,
      k.katr10                                                         as Atributo10,
      k.kdkg1                                                          as GrpCondicoes,
      ''                                                               as novaDataVenc,
      ''                                                               as motivoProrrog,
      ''                                                               as observ

}
