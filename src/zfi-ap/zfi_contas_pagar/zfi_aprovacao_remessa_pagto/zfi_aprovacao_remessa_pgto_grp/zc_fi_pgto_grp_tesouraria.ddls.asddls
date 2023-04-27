@EndUserText.label: 'Pagamento por grupo de tesouraria'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_PGTO_GRP_TESOURARIA
  as projection on ZI_FI_PGTO_GRP_TESOURARIA
{

      @Consumption: { valueHelpDefinition: [{ entity: { name:    'C_CompanyCodeValueHelp', element: 'CompanyCode' } } ],
                                   filter: { mandatory: true, selectionType: #SINGLE } }
  key CompanyCode,
      @Consumption             : { filter: { mandatory: true, selectionType: #SINGLE } }
  key NetDueDate,
  key RunHourTo,
  key CashPlanningGroup,
      @Consumption             : { valueHelpDefinition: [{ entity: { name:    'ZI_FI_VH_TIPOREL', element: 'Value' } }],
                                   filter  : { mandatory: true, selectionType: #SINGLE } }
  key RepType,
  key PaymentRunID,
      @Aggregation.default: #SUM
      PaidAmountInPaytCurrency,
      PaymentCurrency,
      //      DownloadDate,

      @Aggregation.default: #SUM
      OpenAmount,
      @Aggregation.default: #SUM
      BlockedAmount,
      encerrador,
      encerradorcrit,
      encerradortext,
      aprov1,
      aprov1crit,
      aprov1text,
      aprov2,
      aprov2crit,
      aprov2text,
      aprov3,
      aprov3crit,
      aprov3text,
      CompanyCodeName,
      CashPlanningGroupName,
      RepTypeText,
      Username,

      /* Associations */
      _Company,
      _Fdgrv,
      _TipoRel
}
