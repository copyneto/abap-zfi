@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Interface - Família de Crescimento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FAMILIA_CRESC
  as select from ztfi_cresc_famil
  association to parent ZI_FI_CONTRATO_CRESC as _Crescimento on  $projection.DocUuidH = _Crescimento.DocUuidH

  association to ZI_CO_FAMILIA_CL            as _Familia     on  $projection.FamiliaCl = _Familia.Wwmt1
                                                             and _Familia.Spras        = $session.system_language
{
  key doc_uuid_h            as DocUuidH,
  key doc_uuid_familia      as DocUuidFamilia,
      familia_cl            as FamiliaCl,
      _Familia.Bezek        as FamiliaClTxt,
      contrato              as Contrato,
      aditivo               as Aditivo,
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

      //Association
      _Crescimento,
      _Familia
}
