@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Gestão de Contrato Cliente'
@Metadata.allowExtensions: true
define root view entity ZI_FI_CONTRATO_BASE_RENOVACAO
  as select from ztfi_contrato



  association [0..1] to ZI_FI_STATUS_CONTRATO as _Status on  _Status.StatusId = $projection.Status
  association [0..1] to ZI_CA_VH_BRANCH       as _Branch on  _Branch.CompanyCode   = $projection.Bukrs
                                                         and _Branch.BusinessPlace = $projection.Branch
  association [0..1] to ZI_CA_VH_VTWEG        as _Canal  on  $projection.Canal = _Canal.CanalDistrib
  association [0..1] to I_CompanyCodeVH       as _Emp    on  $projection.Bukrs = _Emp.CompanyCode
  association [0..1] to ZI_CA_VH_KATR10       as _At10   on  $projection.GrpContratos = _At10.katr10
  association [0..1] to ZI_CA_VH_KATR3        as _At3    on  $projection.Abrangencia = _At3.katr3
  association [0..1] to ZI_CA_VH_KATR5        as _At5    on  $projection.Estrutura = _At5.katr5
  association [0..1] to ZI_CA_VH_KATR6        as _At6    on  $projection.Canalpdv = _At6.katr6
  association [0..1] to ZI_CA_VH_FORMA_PAGTO  as _Pgto   on  $projection.FormaPagto = _Pgto.FormaPagtoId

{

  key doc_uuid_h                as DocUuidH,
  key contrato                  as Contrato,
  key aditivo                   as Aditivo,
      razao_social              as RazaoSocial,
      cnpj_principal            as CNPJ,
      contrato_proprio          as ContratoProprio,
      contrato_jurid            as ContratoJurid,
      data_ini_valid            as DataIniValid,
      data_fim_valid            as DataFimValid,
      bukrs                     as Bukrs,
      _Emp.CompanyCodeName      as CompanyCodeName,
      branch                    as Branch,
      _Branch.BusinessPlaceName as BusinessPlaceName,
      grp_contratos             as GrpContratos,
      _At10.Name                as GrpContratosTxt,
      grp_cond                  as GrpCond,
      chamado                   as Chamado,
      prazo_pagto               as PrazoPagto,
      forma_pagto               as FormaPagto,
      _Pgto.Texto               as FormaPagtoTxt,
      resp_legal                as RespLegal,
      resp_legal_gtcor          as RespLegalGtcor,
      prod_contemplado          as ProdContemplado,
      observacao                as Observacao,
      status                    as Status,
      _Status.StatusText        as StatusText,
      desativado                as Desativado,
      canal                     as Canal,
      _Canal.CanalDistribText   as CanalTxt,
      grp_economico             as GrpEconomico,
      abrangencia               as Abrangencia,
      _At3.Name                 as AbrangenciaTxt,
      estrutura                 as Estrutura,
      _At5.Name                 as EstruturaTxt,
      canalpdv                  as Canalpdv,
      _At6.Name                 as CanalpdvTxt,
      tipo_entrega              as TipoEntrega,
      data_entrega              as DataEntrega,
      data_fatura               as DataFatura,
      crescimento               as Crescimento,
      ajuste_anual              as AjusteAnual,
      data_assinatura           as DataAssinatura,
      multas                    as Multas,
      renov_aut                 as RenovAut,
      alerta_vig                as AlertaVig,
      alerta_enviado            as AlertaEnviado,
      alerta_data_envio         as AlertaDataEnvio,
      @Semantics.user.createdBy: true
      created_by                as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at           as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at     as LocalLastChangedAt

   
}
