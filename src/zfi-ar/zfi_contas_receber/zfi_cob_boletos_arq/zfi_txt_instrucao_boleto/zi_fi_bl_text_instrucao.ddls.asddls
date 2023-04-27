@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Texto Instrução Boletos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_BL_TEXT_INSTRUCAO
  as select from ztfi_blt_txtinst

  association [0..1] to ESH_N_HOUSEBANK_T012 as _T012  on  $projection.Bukrs = _T012.bukrs
                                                       and $projection.Hbkid = _T012.hbkid
  association [0..1] to t001                 as _T001  on  $projection.Bukrs = _T001.bukrs
  association [0..1] to t005t                as _T005T on  $projection.Banks = _T005T.land1
                                                       and 'P'               = _T005T.spras
  association [0..1] to bnka                 as _BNKA  on  $projection.Banks = _BNKA.banks
                                                       and $projection.Bankl = _BNKA.bankl

{
      @EndUserText.label: 'Empresa'
  key bukrs                 as Bukrs,
      @EndUserText.label: 'Banco Empresa'
  key hbkid                 as Hbkid,
      @EndUserText.label: 'Chave do Banco'
      _T012.bankl           as Bankl,
      @EndUserText.label: 'País do Banco'
      _T012.banks           as Banks,
      @EndUserText.label: 'Linha de texto'
      text                  as Text,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDate.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDate.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _T012,
      _T001,
      _T005T,
      _BNKA
}
