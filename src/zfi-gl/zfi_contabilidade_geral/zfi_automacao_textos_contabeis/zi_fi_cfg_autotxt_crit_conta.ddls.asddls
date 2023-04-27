@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automação textos-Crit.sel.Conta Contábil'
define view entity ZI_FI_CFG_AUTOTXT_CRIT_CONTA
  as select from ztfi_sel_conta

  association        to parent ZI_FI_CFG_AUTO_TEXTOS_REGRAS as _Regras
    on $projection.IdRegra = _Regras.IdRegra

  association [1..1] to ZI_CA_PARAM_SIGN                    as _Sign
    on $projection.SignAccount = _Sign.DomvalueL

  association [1..1] to ZI_CA_PARAM_DDOPTION                as _DDOption
    on $projection.OptAccount = _DDOption.DomvalueL

{
  key id                    as IdSelAccount,
      id_regra              as IdRegra,
      cod_criterio          as CritSelAccount,

      @EndUserText.label: 'Sinal'
      sign                  as SignAccount,
      @EndUserText.label: 'Opção'
      opt                   as OptAccount,
      @EndUserText.label: 'Conta De'
      low                   as LowAccount,
      @EndUserText.label: 'Conta Até'
      high                  as HighAccount,

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


      _Sign.Text            as SignTextAccount,
      _DDOption.Text        as OptTextAccount,

      /* Associations */
      _Regras
}
