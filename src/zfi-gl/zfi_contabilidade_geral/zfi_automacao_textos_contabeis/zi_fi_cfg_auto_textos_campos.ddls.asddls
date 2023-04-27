@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Autom textos contáb Campos das regras'
define view entity ZI_FI_CFG_AUTO_TEXTOS_CAMPOS
  as select from ztfi_autotxt_cmp

  association to parent ZI_FI_CFG_AUTO_TEXTOS_REGRAS as _Regras
    on $projection.IdRegra = _Regras.IdRegra

  association to ZI_FI_VH_AUTOTXT_CAMPOS             as _NomeCampo
    on $projection.Campo = _NomeCampo.Valor

{
  key id                    as Id,
      id_regra              as IdRegra,
      campo                 as Campo,
      ordenacao             as Ordenacao,

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

      _NomeCampo.Texto      as NomeCampo,
      /* Associations */
      _Regras,
      _NomeCampo
}
