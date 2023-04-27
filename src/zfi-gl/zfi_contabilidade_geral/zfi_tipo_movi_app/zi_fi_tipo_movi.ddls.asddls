@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de Movimento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_TIPO_MOVI
  as select from ztfi_tipo_movi
  association to ZI_CA_VH_PLANCONTAS          as _TPlancontas on  _TPlancontas.ChartOfAccounts = $projection.PlanContas
                                                              and _TPlancontas.Language        = $session.system_language
  association to I_GLAccountText              as _ContaTxt    on  _ContaTxt.ChartOfAccounts = $projection.PlanContas
                                                              and _ContaTxt.GLAccount = $projection.Conta
                                                              and _ContaTxt.Language  = $session.system_language
  association to I_DebitCreditCodeText        as _ChaveTxt    on  _ChaveTxt.DebitCreditCode = $projection.chaveLanc
                                                              and _ChaveTxt.Language        = $session.system_language
  association to ZI_CA_VH_BEWAR               as _MovTxt      on  _MovTxt.Trtyp = $projection.TipoMov
                                                              and _MovTxt.Langu = $session.system_language

  association to I_AccountingDocumentTypeText as _TpDocTxt    on  _TpDocTxt.AccountingDocumentType = $projection.TipoDoc
                                                              and _TpDocTxt.Language               = $session.system_language
{


  key ktopl                                as PlanContas,
  key hkont                                as Conta,
  key shkzg                                as chaveLanc,
  key blart                                as TipoDoc,
  key bewar                                as TipoMov,
      _TPlancontas.ChartOfAccountsName,
      _ContaTxt.GLAccountName              as GLAccountName,
      _ChaveTxt.DebitCreditCodeName        as ChaveTxt,
      _MovTxt.Txt                          as TpMovTxt,
      _TpDocTxt.AccountingDocumentTypeName as TpDocTxt,
      @Semantics.user.createdBy: true
      created_by                           as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                           as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                      as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                      as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                as LocalLastChangedAt
}
