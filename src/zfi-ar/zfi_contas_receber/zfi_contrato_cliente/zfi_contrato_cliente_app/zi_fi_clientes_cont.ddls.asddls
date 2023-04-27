@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Clientes Raiz CNPJ - Contrato Cliente'

@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CLIENTES_CONT
  as select from ztfi_cnpj_client
  association [1..1] to ZI_FI_CONTRATO              as _Contrato on  $projection.DocUuidH = _Contrato.DocUuidH
  association        to parent ZI_FI_RAIZ_CNPJ_CONT as _Raiz     on  $projection.DocUuidH    = _Raiz.DocUuidH
                                                                 and $projection.DocUuidRaiz = _Raiz.DocUuidRaiz
  association [0..1] to but0id                      as _Bandeira on  $projection.Cliente = _Bandeira.partner
                                                                 and _Bandeira.type      = 'BANDEI'
  association [0..1] to but0id                      as _GrupoEco on  $projection.Cliente = _GrupoEco.partner
                                                                 and _GrupoEco.type      = 'GRUECO'
  association [0..1] to kna1                                     on  $projection.Cliente = kna1.kunnr
  association [0..1] to knvv                                     on  $projection.Cliente = knvv.kunnr
  association [0..1] to knb1                                     on  $projection.Cliente = knb1.kunnr

{
  key doc_uuid_h            as DocUuidH,
  key doc_uuid_raiz         as DocUuidRaiz,
  key cliente               as Cliente,
  key knb1.bukrs            as Empresa,
  key knvv.bzirk            as RegiaoVendas,
      _Raiz.CnpjRaiz        as CnpjRaiz,
      _Contrato.Contrato    as Contrato,
      _Contrato.Aditivo     as Aditivo,
      kna1.katr10           as Atributo10,
      cnpj                  as Cnpj,
      nome1                 as Nome1,
      knb1.zwels            as FormaPagamento,
      knvv.zterm            as CondPagamentos,
      knvv.vwerk            as Centro,
      knvv.vkorg            as OrgVendas,
      knvv.vtweg            as CanalDistribuicao,
      knvv.spart            as SetorAtividade,
      kna1.katr2            as ClassifCnpj,
      //      classif_cnpj                 as ClassifCnpj,
      _GrupoEco.idnumber    as GrupoEconomico,
      _Bandeira.idnumber    as Bandeira,
      kna1.katr5            as Abrangencia,
      kna1.katr7            as Estrutura,
      kna1.katr8            as CanalPDV,
      knvv.vkbur            as EscritorioVendas,
      knvv.vkgrp            as EquipeVendas,
      kna1.kdkg1            as GruposCondicoes,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Raiz,
      _Contrato // Make association public
}
where
  knb1.bukrs = _Contrato.Bukrs
