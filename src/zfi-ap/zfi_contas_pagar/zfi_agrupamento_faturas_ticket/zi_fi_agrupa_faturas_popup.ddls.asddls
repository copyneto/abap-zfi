@EndUserText.label: 'Popup entrada de campos para agrupamento'
@Metadata.allowExtensions: true
define abstract entity ZI_FI_AGRUPA_FATURAS_POPUP
{

  @ObjectModel.mandatory: true
  selCompanyCode  : bukrs;

  @ObjectModel.mandatory: true
  selFornAgrupa   : ze_forn_agrupador;

  @ObjectModel.mandatory: true
  selDueDate      : dzfbdt;

  @ObjectModel.mandatory: true
  selReference    : xblnr1;

  @ObjectModel.mandatory: true
  selPostingDate  : budat;

  @ObjectModel.mandatory: true
  selDocumentDate : bldat;

  @ObjectModel.mandatory: true
  selCostCenter   : kostl;

  @Semantics.amount.currencyCode : 'selCurrency'
  selDesconto     : ze_fi_valdesconto_agrp;

  @Semantics.currencyCode: true
  selCurrency     : waers;

}
