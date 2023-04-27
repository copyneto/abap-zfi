@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Interface Prov. de Contr. Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_PROVISAO_CLI
  as select from    ztfi_cont_cont as c
    left outer join bseg           as g on  c.bukrs = g.bukrs
                                        and c.gjahr = g.gjahr
                                        and g.buzei = c.numero_item
                                        and c.belnr = g.belnr
    left outer join bkpf           as b on  b.bukrs = g.bukrs
                                        and b.belnr = g.belnr
                                        and b.gjahr = g.gjahr

{
  key   c.contrato          as NumContrato,
  key   c.aditivo           as NumAditivo,
  key   c.bukrs             as Empresa,
  key   c.kunnr             as Cliente,
  key   c.belnr             as NumDoc,
  key   c.numero_item       as Item,
  key   c.gjahr             as Exercicio,
        c.budat             as DataLanc,
        @Semantics.amount.currencyCode: 'Moeda'
        c.wrbtr             as Montante,
        c.bzirk             as RegVendas,
        c.canal             as CanalDist,
        c.setor             as SetorAtivid,
        c.vkorg             as OrgVendas,
        c.status_provisao   as StatusProv,
        c.doc_provisao      as DocProv,
        c.exerc_provisao    as ExercProv,
        @Semantics.amount.currencyCode: 'Moeda'
        c.mont_provisao     as MontProv,
        c.doc_liquidacao    as DocLiq,
        c.exerc_liquidacao  as ExercLiq,
        @Semantics.amount.currencyCode: 'Moeda'
        c.mont_liquidacao   as MontLiq,
        c.doc_estorno       as DocEstorno,
        c.exerc_estorno     as ExcEstorno,
        @Semantics.amount.currencyCode: 'Moeda'
        c.mont_estorno      as MontEstorno,
        c.tipo_desc         as TipDesc,
        c.tipo_dado         as TipDado,
        c.waers             as Moeda,
        b.xblnr             as Referencia,
        //        ''                 as Referencia,
        g.zlsch             as FormaPgto,
        //        ''                 as FormaPgto,
        b.xref1_hd          as ChaveRef,
        //        ''                 as ChaveRef,
        g.mansp             as BloqAdv,
        //        ''                 as BloqAdv,
        cast( '' as datum ) as venc_prov,
        cast( '' as datum ) as venc_liqui
}
