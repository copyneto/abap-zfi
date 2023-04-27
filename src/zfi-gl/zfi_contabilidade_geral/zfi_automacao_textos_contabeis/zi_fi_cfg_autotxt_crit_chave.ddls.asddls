@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automação textos-Crit.sel.Chave Lancto'
define view entity ZI_FI_CFG_AUTOTXT_CRIT_CHAVE
  as select from ztfi_sel_chave

  association        to parent ZI_FI_CFG_AUTO_TEXTOS_REGRAS as _Regras
    on $projection.IdRegra = _Regras.IdRegra

  association [1..1] to ZI_CA_PARAM_SIGN                    as _Sign
    on $projection.SignPostingKey = _Sign.DomvalueL

  association [1..1] to ZI_CA_PARAM_DDOPTION                as _DDOption
    on $projection.OptPostingKey = _DDOption.DomvalueL

{
  key id                    as IdSelPostingKey,
      id_regra              as IdRegra,
      cod_criterio          as CritSelPostingKey,

      @EndUserText.label: 'Sinal'
      sign                  as SignPostingKey,
      @EndUserText.label: 'Opção'
      opt                   as OptPostingKey,
      @EndUserText.label: 'Chave Lancto De'
      low                   as LowPostingKey,
      @EndUserText.label: 'Chave Lancto Até'
      high                  as HighPostingKey,

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


      _Sign.Text            as SignTextPostingKey,
      _DDOption.Text        as OptTextPostingKey,

      /* Associations */
      _Regras
}
