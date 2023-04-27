@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automação textos-Crit.sel. Empresa'
define view entity ZI_FI_CFG_AUTOTXT_CRIT_EMPRESA
  as select from ztfi_sel_empr

  association        to parent ZI_FI_CFG_AUTO_TEXTOS_REGRAS as _Regras
    on $projection.IdRegra = _Regras.IdRegra

  association [1..1] to ZI_CA_PARAM_SIGN                    as _Sign
    on $projection.SignCompany = _Sign.DomvalueL

  association [1..1] to ZI_CA_PARAM_DDOPTION                as _DDOption
    on $projection.OptCompany = _DDOption.DomvalueL

{
  key id                    as IdSelCompany,
      id_regra              as IdRegra,
      cod_criterio          as CritSelCompany,

      @EndUserText.label: 'Sinal'
      sign                  as SignCompany,
      @EndUserText.label: 'Opção'
      opt                   as OptCompany,
      @EndUserText.label: 'Empresa De'
      low                   as LowCompany,
      @EndUserText.label: 'Empresa Até'
      high                  as HighCompany,

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


      _Sign.Text            as SignTextCompany,
      _DDOption.Text        as OptTextCompany,

      /* Associations */
      _Regras
}
