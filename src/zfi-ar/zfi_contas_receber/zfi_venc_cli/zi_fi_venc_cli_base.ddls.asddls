@AbapCatalog.sqlViewName: 'ZVFI_VENCCLI'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Busca dados para Interface'
define view ZI_FI_VENC_CLI_BASE
  as select distinct from  bsid_view              as b
    inner join             kna1                   as k on b.kunnr = k.kunnr
    left outer to one join P_BSEG_COM             as p on  p.belnr = b.belnr
                                                       and p.bukrs = b.bukrs
                                                       and p.gjahr = b.gjahr
                                                       and p.buzei = b.buzei
    left outer to one join bsad_view              as d on  d.belnr = b.belnr
                                                       and d.bukrs = b.bukrs
                                                       and d.gjahr = b.gjahr
                                                       and d.buzei = b.buzei
    left outer to one join I_BillingDocumentBasic as i on b.vbeln = i.BillingDocument
    left outer to one join ztfi_obsvenc           as o on  o.belnr = b.belnr
                                                       and o.bukrs = b.bukrs
                                                       and o.gjahr = b.gjahr
                                                       and o.buzei = b.buzei
  association [0..*] to knvv as v on  v.kunnr = $projection.Cliente
                                  and v.vtweg = $projection.CanalDist
                                  and v.spart = $projection.SetorAtiv

{
  key b.bukrs               as Empresa,
  key b.belnr               as NoDocumento,
  key b.gjahr               as Exercicio,
  key b.kunnr               as Cliente,
      k.name1               as NomeCliente,
      o.datamod             as DataMod,
      b.buzei               as Item,
      b.blart               as TpDocumento,
      b.budat               as DataLanc,
      b.zfbdt               as DtBase,
      b.mansp               as BlocAdvert,
      b.vbeln               as DocFaturamento,
      b.zlsch               as FormaPagto,
      @Semantics.amount.currencyCode: 'Moeda'
      b.wrbtr               as MontMoedaInt,
      b.zbd1t               as Dia1,
      b.zbd2t               as Dia2,
      b.zbd3t               as DiasLiq,
      b.waers               as Moeda,
      p.netdt               as VencimentoEm,
      d.augdt               as DataComp,
      v.vkbur               as EscritorioVendas,
      i.SalesDistrict       as RegiaoVendas,
      i.DistributionChannel as CanalDist,
      i.Division            as SetorAtiv,
      ''                    as ContRegist,
      o.usermod             as UsuarioMod,
      $session.system_date  as Hoje,
      ''                    as VencOrigem,
      ''                    as DiasProrrog,
      o.obs                 as Observacao
}
