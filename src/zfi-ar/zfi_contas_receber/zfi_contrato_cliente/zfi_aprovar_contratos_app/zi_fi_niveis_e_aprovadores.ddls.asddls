@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Nivel e Aprovadores'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_NIVEIS_E_APROVADORES
  as select from ztfi_cad_nivel as _Nivel
  association [0..*] to ztfi_cad_aprovad as _Aprovadores on _Aprovadores.nivel = _Nivel.nivel

{
  key nivel                 as Nivel,
  key _Aprovadores.branch   as Branch,
  key _Aprovadores.bukrs    as Bukrs,
      _Aprovadores.bname    as Bname,
      _Aprovadores.email    as Email,
      desc_nivel            as DescNivel,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
