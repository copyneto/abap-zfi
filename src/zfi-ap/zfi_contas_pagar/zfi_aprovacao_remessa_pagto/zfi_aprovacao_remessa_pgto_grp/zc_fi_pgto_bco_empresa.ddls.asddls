@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Projeção - Pagamento bco empresa'
@Metadata.allowExtensions: true
define root view entity ZC_FI_PGTO_BCO_EMPRESA
  as projection on ZI_FI_PGTO_BCO_EMPRESA
  association [0..*] to ZC_FI_PROG_PAG_DOC_ITENS as _Itens on  _Itens.CompanyCode   = $projection.CompanyCode
                                                           and _Itens.HouseBank     = $projection.Bank
                                                           and _Itens.PaymentMethod = $projection.PaymentMethod
                                                           and _Itens.NetDueDate    = $projection.NetDueDate
                                                           and _Itens.RunHourTo     = $projection.RunHourTo
                                                           and _Itens.RepType       = $projection.RepType
{
  key Bank,
      //      @EndUserText.label       : 'Forma de pagamento'
  key PaymentMethod,
      @Consumption: { valueHelpDefinition: [{ entity: { name: 'C_CompanyCodeValueHelp', element: 'CompanyCode' } } ],
                                              filter: { mandatory: true, selectionType: #SINGLE } }
      //      @EndUserText.label: 'Empresa'
  key CompanyCode,
      @Consumption: { filter: { mandatory: true, selectionType: #SINGLE } }
      //      @EndUserText.label       : 'Data de pagamento'
  key NetDueDate,
  key RunHourTo,
      @Consumption: { valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_TIPOREL', element: 'Value' } }],
                                              filter: { mandatory: true, selectionType: #SINGLE } }
      //      @EndUserText.label: 'Tipo de relatório'
  key RepType,
      Status,
      //      @EndUserText.label       : 'Pgto do dia'
      @Aggregation.default: #SUM
      PaidAmountInPaytCurrency,
      //      //      @EndUserText.label       : 'Em aberto'
      //      @Aggregation.default: #SUM
      //      OpenAmount,
      //      //      @EndUserText.label       : 'Bloqueado'
      //      @Aggregation.default: #SUM
      //      BlockedAmount,
      PaymentCurrency,
      BankName,
      PaymentMethodName,
      CompanyCodeName,
      RepTypeText,

      StatusText,

      /* Associations */
      _Company,
      _Bank,
      _PmntMtd,
      _Currency,
      _TipoRel,
      _Itens

      //      _DocItens
}
where
  PaidAmountInPaytCurrency > 0
