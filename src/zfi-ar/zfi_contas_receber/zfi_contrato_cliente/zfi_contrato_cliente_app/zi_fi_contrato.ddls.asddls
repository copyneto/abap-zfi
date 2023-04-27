@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Gestão de Contrato Cliente'
@Metadata.allowExtensions: true
define root view entity ZI_FI_CONTRATO
  as select from ztfi_contrato

  composition [0..*] of ZI_FI_RAIZ_CNPJ_CONT         as _Raiz
  composition [0..*] of ZI_FI_ANEXOS                 as _Anexos
  composition [0..*] of ZI_FI_COND_CONT              as _Cond
  composition [0..*] of ZI_FI_PROV_CONT              as _Prov
  composition [0..*] of ZI_FI_JANELA_CONT            as _Janela
  composition [0..*] of ZI_FI_NIVEIS_APROV_CONTRATO  as _Aprovadores
  composition [0..*] of ZI_FI_RETORNO_APROV          as _RetAprov

  association [0..1] to ZI_FI_STATUS_CONTRATO        as _Status  on  _Status.StatusId = $projection.Status
  association [0..1] to ZI_CA_VH_BRANCH              as _Branch  on  _Branch.CompanyCode   = $projection.Bukrs
                                                                 and _Branch.BusinessPlace = $projection.Branch
  association [0..1] to ZI_CA_VH_VTWEG               as _Canal   on  $projection.Canal = _Canal.CanalDistrib
  association [0..1] to I_CompanyCodeVH              as _Emp     on  $projection.Bukrs = _Emp.CompanyCode
  association [0..1] to ZI_CA_VH_KATR10              as _At10    on  $projection.GrpContratos = _At10.katr10
  association [0..1] to ZI_CA_VH_KATR3               as _At3     on  $projection.Abrangencia = _At3.katr3
  association [0..1] to ZI_CA_VH_KATR5               as _At5     on  $projection.Estrutura = _At5.katr5
  association [0..1] to ZI_CA_VH_KATR6               as _At6     on  $projection.Canalpdv = _At6.katr6
  association [0..1] to ZI_CA_VH_FORMA_PAGTO         as _Pgto    on  $projection.FormaPagto = _Pgto.FormaPagtoId
  association [0..1] to ZI_FI_TIPO_ENTREGA           as _Ent     on  $projection.TipoEntrega = _Ent.TpEntrega
  association [0..1] to ZI_FI_GRP_COND               as _Grpcond on  $projection.GrpCond = _Grpcond.Kdkgr


  association [0..1] to ZI_FI_DESC_NIVEL_APROV_ATUAL as _Nivel   on  $projection.DocUuidH = _Nivel.DocUuidH


{

  key doc_uuid_h                as DocUuidH,
      contrato                  as Contrato,
      aditivo                   as Aditivo,
      razao_social,
      cnpj_principal,
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
      _Grpcond.Vtext            as GrpCondText,
      chamado                   as Chamado,
      cnpj_principal            as CnpjPrincipal,
      razao_social              as RazaoSocial,
      nome_fantasia             as NomeFantasia,
      prazo_pagto               as PrazoPagto,
      forma_pagto               as FormaPagto,
      _Pgto.Texto               as FormaPagtoTxt,
      resp_legal                as RespLegal,
      resp_legal_gtcor          as RespLegalGtcor,
      prod_contemplado          as ProdContemplado,
      observacao                as Observacao,
      status                    as Status,
      status_anexo              as StatusAnexo,
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
      _Ent.TpEntregaText        as TpEntregaText,
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
      local_last_changed_at     as LocalLastChangedAt,

      aprov1                    as Aprov1,
      dataaprov1                as Dataaprov1,
      hora_aprov1               as HoraAprov1,
      aprov2                    as Aprov2,
      dataaprov2                as Dataaprov2,
      hora_aprov2               as HoraAprov2,
      aprov3                    as Aprov3,
      dataaprov3                as Dataaprov3,
      hora_aprov3               as HoraAprov3,
      aprov4                    as Aprov4,
      dataaprov4                as Dataaprov4,
      hora_aprov4               as HoraAprov4,
      aprov5                    as Aprov5,
      dataaprov5                as Dataaprov5,
      hora_aprov5               as HoraAprov5,
      aprov6                    as Aprov6,
      dataaprov6                as Dataaprov6,
      hora_aprov6               as HoraAprov6,
      aprov7                    as Aprov7,
      dataaprov7                as Dataaprov7,
      hora_aprov7               as HoraAprov7,
      aprov8                    as Aprov8,
      dataaprov8                as Dataaprov8,
      hora_aprov8               as HoraAprov8,
      aprov9                    as Aprov9,
      dataaprov9                as Dataaprov9,
      hora_aprov9               as HoraAprov9,
      aprov10                   as Aprov10,
      dataaprov10               as Dataaprov10,
      hora_aprov10              as HoraAprov10,
      _Nivel.Nivel              as Nivel,
      _Nivel.DescNivel          as DescNivel,

      _Raiz,
      _Anexos,
      _Cond,
      _Prov,
      _Janela,
      _Aprovadores,
      _RetAprov
}
