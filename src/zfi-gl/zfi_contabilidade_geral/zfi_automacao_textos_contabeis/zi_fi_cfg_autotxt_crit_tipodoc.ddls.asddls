@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Automação textos-Crit.sel.Tipo Documento'
define view entity ZI_FI_CFG_AUTOTXT_CRIT_TIPODOC
  as select from ztfi_sel_tpdoc

  association        to parent ZI_FI_CFG_AUTO_TEXTOS_REGRAS as _Regras
    on $projection.IdRegra = _Regras.IdRegra

  association [1..1] to ZI_CA_PARAM_SIGN                    as _Sign
    on $projection.SignDocType = _Sign.DomvalueL

  association [1..1] to ZI_CA_PARAM_DDOPTION                as _DDOption
    on $projection.OptDocType = _DDOption.DomvalueL

{
  key id                    as IdSelDocType,
      id_regra              as IdRegra,
      cod_criterio          as CritSelDocType,

      @EndUserText.label: 'Sinal'
      sign                  as SignDocType,
      @EndUserText.label: 'Opção'
      opt                   as OptDocType,
      @EndUserText.label: 'Tipo Documento De'
      low                   as LowDocType,
      @EndUserText.label: 'Tipo Documento Até'
      high                  as HighDocType,

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


      _Sign.Text            as SignTextDocType,
      _DDOption.Text        as OptTextDocType,

      /* Associations */
      _Regras
}
