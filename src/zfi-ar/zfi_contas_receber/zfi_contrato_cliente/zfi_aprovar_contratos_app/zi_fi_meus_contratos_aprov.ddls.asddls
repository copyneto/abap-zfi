@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Meus Contratos Para Aprovação'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_MEUS_CONTRATOS_APROV
  as select from     ztfi_contrato
    right outer join ZI_FI_CONT_PROX_NIVEL as _Prox on  ztfi_contrato.doc_uuid_h = _Prox.DocUuidH
                                                    and ztfi_contrato.aditivo    = _Prox.Aditivo
                                                    and ztfi_contrato.contrato   = _Prox.Contrato
{
  key ztfi_contrato.doc_uuid_h            as DocUuidH,
  key ztfi_contrato.contrato              as Contrato,
  key ztfi_contrato.aditivo               as Aditivo,
      ztfi_contrato.razao_social          as RazaoSocial,
      ztfi_contrato.cnpj_principal        as CNPJ,
      ztfi_contrato.contrato_proprio      as ContratoProprio,
      ztfi_contrato.contrato_jurid        as ContratoJurid,
      ztfi_contrato.data_ini_valid        as DataIniValid,
      ztfi_contrato.data_fim_valid        as DataFimValid,
      ztfi_contrato.bukrs                 as Bukrs,
      ztfi_contrato.branch                as Branch,
      ztfi_contrato.grp_contratos         as GrpContratos,
      ztfi_contrato.grp_cond              as GrpCond,
      ztfi_contrato.chamado               as Chamado,
      ztfi_contrato.prazo_pagto           as PrazoPagto,
      ztfi_contrato.forma_pagto           as FormaPagto,
      ztfi_contrato.resp_legal            as RespLegal,
      ztfi_contrato.resp_legal_gtcor      as RespLegalGtcor,
      ztfi_contrato.prod_contemplado      as ProdContemplado,
      ztfi_contrato.observacao            as Observacao,
      ztfi_contrato.status                as Status,
      ztfi_contrato.desativado            as Desativado,
      ztfi_contrato.canal                 as Canal,
      ztfi_contrato.grp_economico         as GrpEconomico,
      ztfi_contrato.abrangencia           as Abrangencia,
      ztfi_contrato.estrutura             as Estrutura,
      ztfi_contrato.canalpdv              as Canalpdv,
      ztfi_contrato.tipo_entrega          as TipoEntrega,
      ztfi_contrato.data_entrega          as DataEntrega,
      ztfi_contrato.data_fatura           as DataFatura,
      ztfi_contrato.crescimento           as Crescimento,
      ztfi_contrato.ajuste_anual          as AjusteAnual,
      ztfi_contrato.data_assinatura       as DataAssinatura,
      ztfi_contrato.multas                as Multas,
      ztfi_contrato.renov_aut             as RenovAut,
      ztfi_contrato.alerta_vig            as AlertaVig,
      ztfi_contrato.alerta_enviado        as AlertaEnviado,
      ztfi_contrato.alerta_data_envio     as AlertaDataEnvio,
      ztfi_contrato.created_by            as CreatedBy,
      ztfi_contrato.created_at            as CreatedAt,
      ztfi_contrato.last_changed_by       as LastChangedBy,
      ztfi_contrato.last_changed_at       as LastChangedAt,
      ztfi_contrato.local_last_changed_at as LocalLastChangedAt,
      _Prox.Nivel                         as Nivel,
      _Prox.DescNivel                     as DescNivel
}

where
  ztfi_contrato.status = '1'
  or //1 Criado
  ztfi_contrato.status = '3'
  or //3   Em Aprovação
  ztfi_contrato.status = '4'
  or //4   Aprovado
  ztfi_contrato.status = '7'
  or //7   Aditivado
  ztfi_contrato.status = '8' //8   Renovado
