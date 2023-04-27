@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de interface - Contrato Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_CONTRATO_CRESC
  as select from ztfi_contrato
  composition [0..*] of ZI_FI_CAD_CRESCI  as _CadCresci
  composition [0..*] of ZI_FI_FAIXA_CRESC as _FaixaCresc
  composition [0..*] of ZI_FI_COMP_CRESCI as _CompCresci
  composition [0..*] of ZI_FI_FAMILIA_CRESC as _FamiliaCresc
{

  key doc_uuid_h            as DocUuidH,
      contrato              as Contrato,
      aditivo               as Aditivo,
      contrato_proprio      as Contrato_proprio,
      contrato_jurid        as Contrato_jurid,
      data_ini_valid        as Data_ini_valid,
      data_fim_valid        as Data_fim_valid,
      cnpj_principal        as CnpjPrincipal,
      razao_social          as RazaoSocial,
      bukrs                 as Bukrs,
      branch                as Branch,
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

      /* Associations */
      _CompCresci,
      _CadCresci,
      _FaixaCresc,
      _FamiliaCresc

}
where
  crescimento = 'X'
