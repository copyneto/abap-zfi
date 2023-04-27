@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Config. Automação textos contábeis'
define root view entity ZI_FI_CFG_AUTO_TEXTOS_REGRAS
  as select from ztfi_autotext

  composition [1..*] of ZI_FI_CFG_AUTO_TEXTOS_CAMPOS   as _Campos

  composition [1..*] of ZI_FI_CFG_AUTOTXT_CRIT_EMPRESA as _Empresa

  composition [1..*] of ZI_FI_CFG_AUTOTXT_CRIT_TIPODOC as _TipoDocumento

  composition [1..*] of ZI_FI_CFG_AUTOTXT_CRIT_CONTA   as _ContaContabil

  composition [1..*] of ZI_FI_CFG_AUTOTXT_CRIT_CHAVE   as _ChaveLancto

  composition [1..*] of ZI_FI_CFG_AUTOTXT_CRIT_FLOWTP  as _TipoAtualizacao

  composition [1..*] of ZI_FI_CFG_AUTOTXT_CRIT_PRODTP  as _TipoProduto

{
  key id                                                as IdRegra,
      regra                                             as Regra,
      bukrs                                             as Bukrs,
      blart                                             as Blart,
      hkont                                             as Hkont,
      bschl                                             as Bschl,
      dis_flowtype                                      as Dis_flowty,
      product_type                                      as Gsart,
      texto_fixo                                        as TextoFixo,
      descricao                                         as Descricao,
      concat_with_space('Regra', ltrim(regra, '0'), 1 ) as RegraLabel,
      @Semantics.user.createdBy: true
      created_by                                        as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                                        as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                                   as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                                   as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                             as LocalLastChangedAt,
      /* Associations */
      _Campos,
      _Empresa,
      _TipoDocumento,
      _ContaContabil,
      _ChaveLancto,
      _TipoAtualizacao,
      _TipoProduto

}
