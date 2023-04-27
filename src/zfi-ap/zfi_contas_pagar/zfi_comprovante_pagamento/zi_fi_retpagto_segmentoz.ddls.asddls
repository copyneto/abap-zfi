@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Retorno de pagto. Segmento Z'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory: #XL,
    dataClass: #TRANSACTIONAL
}
@Metadata.allowExtensions: true

define root view entity ZI_FI_RETPAGTO_SEGMENTOZ
  as select from ztfi_retpag_segz as SegmentoZ

  association        to t001                 as _Empresas         on $projection.Empresa = _Empresas.bukrs

  association        to I_BusinessPartnerVH  as _Fornecedor       on $projection.Fornecedor = _Fornecedor.BusinessPartner

  association [0..1] to ZI_FI_VH_MULTIBANCOS as _Bancos           on $projection.Banco = _Bancos.Banco

  association [0..1] to ZI_FI_VH_MULTIBANCOS as _BancosFavorecido on $projection.BancoFavor = _BancosFavorecido.Banco

  association [0..1] to ZI_FI_VH_MULTIBANCOS as _BancosEmpresa    on $projection.BancoEmpresa = _BancosEmpresa.Banco

{
  key bukrs                              as Empresa,
  key lifnr                              as Fornecedor,
  key belnr                              as Fatura,
  key nbbln_eb                           as DocContabAuxiliar,
  key zgjahr                             as ExercicioCompensacao,
  key hbkid                              as BancoEmpresa,
  key zlsch                              as FormaPagto,
      buzei                              as Item,
      gjahr                              as Exercicio,

      cast( dmbtr as abap.dec( 12, 2 ) ) as Montante,
      augdt                              as DataCompensacao,
      kukey_eb                           as ChaveBreve,
      zautenticaban                      as AutenticacaoBanc,
      zcontroleban                       as ControleBanc,
      zbanco                             as Banco,
      zagencia                           as Agencia,
      zcontacor                          as ContaCorrente,
      zbancofav                          as BancoFavor,
      zagenciafav                        as AgenciaFavor,
      zcontafav                          as ContaFavor,
      @Semantics.user.createdBy: true
      created_by                         as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                         as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                    as LastChangedBy,
      @Semantics.systemDate.lastChangedAt: true
      last_changed_at                    as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at              as LocalLastChangedAt,

      _Empresas.waers                    as Moeda,
      _Empresas,
      _Fornecedor,
      _Bancos,
      _BancosFavorecido,
      _BancosEmpresa
}
