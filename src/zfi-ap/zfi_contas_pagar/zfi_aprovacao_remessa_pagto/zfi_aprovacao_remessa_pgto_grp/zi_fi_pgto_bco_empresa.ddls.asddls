@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Pagamento por bco empresa'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_PGTO_BCO_EMPRESA
  as select from ZI_FI_PROG_PAGAMENTO_GRP as _Pgto

  association [1..1] to I_CompanyCode    as _Company  on  $projection.CompanyCode = _Company.CompanyCode

  association [1..1] to ZI_FI_VH_TIPOREL as _TipoRel  on  $projection.RepType = _TipoRel.Value
  association [1..1] to ZI_CA_VH_HBKID   as _Bank     on  $projection.Bank        = _Bank.BancoEmpresa
                                                      and $projection.CompanyCode = _Bank.Empresa
  association [1..1] to ZI_CA_VH_ZLSCH   as _PmntMtd  on  $projection.PaymentMethod = _PmntMtd.FormaPagamento
  association [1..1] to I_Currency       as _Currency on  $projection.PaymentCurrency = _Currency.Currency

  //  association [0..*] to ZI_FI_PROG_PAG_DOCN as _DocItens on  _DocItens.CompanyCode   = $projection.CompanyCode
  //                                                         and _DocItens.PaymentMethod = $projection.PaymentMethod
  //                                                         and _DocItens.NetDueDate    = $projection.NetDueDate
  //                                                         and _DocItens.HouseBank     = $projection.Bank
  //                                                         and _DocItens.PaymentMethod = $projection.PaymentMethod

{
      @ObjectModel.text.element: ['BankName']
      @ObjectModel.foreignKey.association: '_Bank'
  key _Pgto.Bank,
      @ObjectModel.text.element: ['PaymentMethodName']
      @ObjectModel.foreignKey.association: '_PmntMtd'
      @EndUserText.label: 'Forma Pagamento'
  key _Pgto.PaymentMethod,
      @ObjectModel.text.element: ['CompanyCodeName']
      @ObjectModel.foreignKey.association: '_Company'
  key _Pgto.CompanyCode,
  key _Pgto.NetDueDate,
  key _Pgto.RunHourTo,
      @ObjectModel.text.element: ['RepTypeText']
      @ObjectModel.foreignKey.association: '_TipoRel'
  key _Pgto.RepType,
      Status,
      @Aggregation.default: #SUM
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      cast( sum( _Pgto.PaidAmountInPaytCurrency ) as rwbtr ) as PaidAmountInPaytCurrency,
//      @Aggregation.default: #SUM
//      @Semantics.amount.currencyCode: 'PaymentCurrency'
//      cast( sum( OpenAmount ) as ze_aberto )                 as OpenAmount,
//      @Aggregation.default: #SUM
//      @Semantics.amount.currencyCode: 'PaymentCurrency'
//      cast( sum( BlockedAmount ) as ze_bloqueado )           as BlockedAmount,
      _Pgto.PaymentCurrency,
      _Bank.BancoEmpresaText                                 as BankName,
      _PmntMtd.FormaPagamentoText                            as PaymentMethodName,
      _Company.CompanyCodeName,
      _TipoRel.Text                                          as RepTypeText,

      @EndUserText.label: 'Status'
      StatusText,

      _Company,
      _Bank,
      _PmntMtd,
      _Currency,
      _TipoRel

      //      _DocItens

}
where
  Status = 3
group by
  Bank,
  PaymentMethod,
  CompanyCode,
  NetDueDate,
  RunHourTo,
  RepType,
  Status,
  //  PaidAmountInPaytCurrency,
  //  OpenAmount,
  //  BlockedAmount,
  PaymentCurrency,
  _Bank.BancoEmpresaText,
  _PmntMtd.FormaPagamentoText,
  _Company.CompanyCodeName,
  _TipoRel.Text,
  Status,
  StatusText
