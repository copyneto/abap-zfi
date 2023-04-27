@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automação textos-Crit.sel.Tp Produto'
define view entity ZI_FI_CFG_AUTOTXT_CRIT_PRODTP
  as select from ztfi_sel_prodtp

  association        to parent ZI_FI_CFG_AUTO_TEXTOS_REGRAS as _Regras
    on $projection.IdRegra = _Regras.IdRegra

  association [1..1] to ZI_CA_PARAM_SIGN                    as _Sign
    on $projection.SignFIProdType = _Sign.DomvalueL

  association [1..1] to ZI_CA_PARAM_DDOPTION                as _DDOption
    on $projection.OptFIProdType = _DDOption.DomvalueL

{
  key id                    as IdSelFIProdType,
      id_regra              as IdRegra,
      cod_criterio          as CritSelFIProdType,

      @EndUserText.label: 'Sinal'
      sign                  as SignFIProdType,
      @EndUserText.label: 'Opção'
      opt                   as OptFIProdType,
      @EndUserText.label: 'Tipo de Produto De'
      low                   as LowFIProdType,
      @EndUserText.label: 'Tipo de Produto Até'
      high                  as HighFIProdType,

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


      _Sign.Text            as SignTextFIProdType,
      _DDOption.Text        as OptTextFIProdType,

      /* Associations */
      _Regras
}
