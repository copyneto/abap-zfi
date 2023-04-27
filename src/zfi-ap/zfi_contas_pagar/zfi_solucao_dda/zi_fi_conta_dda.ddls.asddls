@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Config. conta pagto p/ diferença DDA '
@Metadata.allowExtensions: true
define root view entity ZI_FI_CONTA_DDA
  as select from ztfi_conta_dda

  association to t001           as _Empresas on $projection.CompanyCode = _Empresas.bukrs
  association to ZI_CA_VH_KOSTL as _CC       on $projection.CentroCusto = _CC.CentroCusto

{
  key bukrs                 as CompanyCode,
      @Semantics.amount.currencyCode: 'Moeda'
      valor_tol             as ValorTolerancia,
      conta_low             as ContaLow,
      conta_high            as ContaHig,
      data_tol              as DataTolerancia,
      zlsch                 as PaymentMethod,
      blart                 as DocumentType,
      kostl                 as CentroCusto,
      _CC.Descricao         as DescCentroCusto,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDate.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      // Make association public
      _Empresas.waers       as Moeda,
      _Empresas.butxt       as CompanyName,
      _Empresas
}
