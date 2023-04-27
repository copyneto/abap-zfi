@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automação textos-Crit.sel.Tp Atualização'
define view entity ZI_FI_CFG_AUTOTXT_CRIT_FLOWTP
  as select from ztfi_sel_flowtp

  association        to parent ZI_FI_CFG_AUTO_TEXTOS_REGRAS as _Regras
    on $projection.IdRegra = _Regras.IdRegra

  association [1..1] to ZI_CA_PARAM_SIGN                    as _Sign
    on $projection.SignTreasuryUpdateType = _Sign.DomvalueL

  association [1..1] to ZI_CA_PARAM_DDOPTION                as _DDOption
    on $projection.OptTreasuryUpdateType = _DDOption.DomvalueL

{
  key id                    as IdSelTreasuryUpdateType,
      id_regra              as IdRegra,
      cod_criterio          as CritSelTreasuryUpdateType,

      @EndUserText.label: 'Sinal'
      sign                  as SignTreasuryUpdateType,
      @EndUserText.label: 'Opção'
      opt                   as OptTreasuryUpdateType,
      @EndUserText.label: 'Tipo de Atualização De'
      low                   as LowTreasuryUpdateType,
      @EndUserText.label: 'Tipo de Atualização Até'
      high                  as HighTreasuryUpdateType,

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


      _Sign.Text            as SignTextTreasuryUpdateType,
      _DDOption.Text        as OptTextTreasuryUpdateType,

      /* Associations */
      _Regras
}
