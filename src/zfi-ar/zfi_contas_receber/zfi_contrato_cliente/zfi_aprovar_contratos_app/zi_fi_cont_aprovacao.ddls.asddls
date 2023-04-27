@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Contrato por Niveis e Aprovação'
@Metadata.allowExtensions: true
define root view entity ZI_FI_CONT_APROVACAO
  as select from ZI_FI_MEUS_CONTRATOS_APROV
  composition [0..*] of ZI_FI_CONT_PROX_NIVEL as _Aprovar
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

  key DocUuidH,
  key Contrato                   as Contrato,
  key Aditivo                    as Aditivo,
      RazaoSocial,
      CNPJ,
      ContratoProprio,
      ContratoJurid,
      DataIniValid,
      DataFimValid,
      Bukrs                      as Bukrs,
      _Emp.CompanyCodeName       as CompanyCodeName,
      Branch                     as Branch,
      _Branch.BusinessPlaceName  as BusinessPlaceName,
      GrpContratos,
      _At10.Name                 as GrpContratosTxt,
      GrpCond,
      Chamado                    as Chamado,
      PrazoPagto,
      FormaPagto,
      _Pgto.Texto                as FormaPagtoTxt,
      RespLegal,
      RespLegalGtcor,
      ProdContemplado,
      Observacao                 as Observacao,
      Status                     as Status,
      _Status.StatusText         as StatusText,
      Desativado                 as Desativado,
      Canal                      as Canal,
      _Canal.CanalDistribText    as CanalTxt,
      GrpEconomico,
      Abrangencia                as Abrangencia,
      _At3.Name                  as AbrangenciaTxt,
      Estrutura                  as Estrutura,
      _At5.Name                  as EstruturaTxt,
      Canalpdv                   as Canalpdv,
      _At6.Name                  as CanalpdvTxt,
      TipoEntrega,
      DataEntrega,
      DataFatura,
      Crescimento                as Crescimento,
      AjusteAnual,
      DataAssinatura,
      Multas                     as Multas,
      RenovAut,
      AlertaVig,
      AlertaEnviado,
      AlertaDataEnvio,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      Nivel,
      DescNivel,

      cast( '' as ze_obs_aprov ) as AbsObservacao,
      _Aprovar

}
