@EndUserText.label: 'CDS Custom - Aprovação de Contas a Pagar'
@ObjectModel: { query.implementedBy: 'ABAP:ZCLFI_APROV_CONTAS_PAGAR_QUERY'}

@UI.headerInfo: { typeNamePlural: 'Aprovações de Contas a Pagar' , typeName: 'Aprovação de Contas a Pagar',
  title: { type: #STANDARD, value: 'CompanyCode' },
  description: { type: #STANDARD, value: 'CompanyCode' } }

define root custom entity ZC_FI_APROV_CONTAS_PAGAR
{

      @UI                      : { selectionField: [{position: 10}],
                                   lineItem:       [{type: #FOR_ACTION,  dataAction: 'approv' , label: 'Aprovar' }]}
      @Consumption             : { valueHelpDefinition: [{ entity: { name:    'C_CompanyCodeValueHelp', element: 'CompanyCode' } }],
                                   filter  : { mandatory: true, selectionType: #SINGLE }}
      @ObjectModel.foreignKey.association: '_CompanyCode'
      @ObjectModel.text.element: ['CompanyCodeName']
      @EndUserText.label       : 'Empresa'
  key CompanyCode              : bukrs;

      @UI                      : { selectionField: [{position: 20}]}
      @Consumption             : { filter: { mandatory: true, selectionType: #SINGLE } }
      @EndUserText.label       : 'Data de Pagamento'
  key NetDueDate               : abap.char(8);

      @Consumption             : { filter.hidden: true }
      @EndUserText.label       : 'Hora Final'
  key RunHourTo                : abap.char(6);

      @UI                      : { selectionField: [{position: 30}],
                                   textArrangement: #TEXT_ONLY}
      @Consumption             : { valueHelpDefinition: [{ entity: { name:    'ZI_FI_VH_TIPOREL', element: 'Value' } }],
                                   filter  : { mandatory: true, selectionType: #SINGLE } }
      @ObjectModel.text.element: ['RepTypeText']
      @EndUserText.label       : 'Tipo de Relatório'
  key RepType                  : ze_tiporel;

      @UI                      : { lineItem:       [{position: 50}],
                                   textArrangement: #TEXT_LAST }
      @Consumption.filter.hidden: true
      @ObjectModel.text.element: ['CashPlanningGroupName']
      @Semantics.text          : true
      @EndUserText.label       : 'Grupo de Tesouraria'
  key CashPlanningGroup        : fdgrv;

      hbkid                    : hbkid;

      rzawe                    : rzawe;

      @Consumption             : { filter.hidden: true }
      @EndUserText.label       : 'Hora Inicial'
      RunHourFrom              : uzeit;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Nome do Grupo de Tesouraria'
      CashPlanningGroupName    : ltxt1;

      @Consumption             : { filter.hidden: true }
      @UI                      : { lineItem:       [{position: 60, type: #WITH_URL, url: '_URL.PaymentDocument' }]}
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      @EndUserText.label       : 'Pgto do Dia'
      //      @Aggregation.default: #SUM
      PaidAmountInPaytCurrency : abap.dec(15,2);

      @Consumption             : { filter.hidden: true }
      @UI                      : { lineItem:       [{position: 70, type: #WITH_URL, url: '_URL.OpenDocument' }]}
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      @EndUserText.label       : 'Em Aberto'
      //      @Aggregation.default: #SUM
      OpenAmount               : abap.dec(15,2);

      @Consumption             : { filter.hidden: true }
      @UI                      : { lineItem:       [{position: 80, type: #WITH_URL, url: '_URL.BlockedDocument' }]}
      @Semantics.amount.currencyCode: 'PaymentCurrency'
      @EndUserText.label       : 'Bloqueado'
      blockedAmount            : abap.dec(15,2);

      @Consumption             : { filter.hidden: true }
      @ObjectModel.foreignKey.association: '_PaymentCurrency'
      @EndUserText.label       : 'Moeda'
      @Semantics.currencyCode  :true
      PaymentCurrency          : waers;

      @UI                      : { lineItem:       [{position: 10, criticality: 'EncerradorCrit'}],
                                   textArrangement: #TEXT_ONLY }
      @Consumption.filter.hidden: true
      @ObjectModel.text.element: ['EncerradorText']
      Encerrador               : ze_aprov;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Status Encerrador'
      EncerradorText           : text10;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Criticidade Encerrador'
      EncerradorCrit           : ukm_stat_exposure_criticality;

      @UI                      : { lineItem:       [{position: 20, criticality: 'Aprov1Crit'}],
                                   textArrangement: #TEXT_ONLY }
      @Consumption.filter.hidden: true
      @ObjectModel.text.element: ['Aprov1Text']
      Aprov1                   : ze_aprov;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Status Aprovador 1'
      Aprov1Text               : text10;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Criticidade Aprovador 1'
      Aprov1Crit               : ukm_stat_exposure_criticality;

      @UI                      : { lineItem:       [{position: 30, criticality: 'Aprov2Crit'}],
                                   textArrangement: #TEXT_ONLY }
      @Consumption.filter.hidden: true
      @ObjectModel.text.element: ['Aprov2Text']
      Aprov2                   : ze_aprov;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Status Aprovador 2'
      Aprov2Text               : text10;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Criticidade Aprovador 2'
      Aprov2Crit               : ukm_stat_exposure_criticality;

      @UI                      : { lineItem:       [{position: 40, criticality: 'Aprov3Crit'}],
                                   textArrangement: #TEXT_ONLY }
      @Consumption.filter.hidden: true
      @ObjectModel.text.element: ['Aprov3Text']
      Aprov3                   : ze_aprov;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Status Aprovador 3'
      Aprov3Text               : text10;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Criticidade Aprovador 3'
      Aprov3Crit               : ukm_stat_exposure_criticality;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Nome da Empresa'
      CompanyCodeName          : butxt;

      @Consumption.filter.hidden: true
      @EndUserText.label       : 'Descrição do Tipo'
      RepTypeText              : val_text;

      @UI.hidden               : true
      nivelatual               : abap.char( 1 );
      @UI.hidden               : true
      username                 : uname;
      @UI.hidden               : true
      dwdat                    : dodat;
      @UI.hidden               : true
      dwusr                    : dousr;

      _URL                     : association [1..1] to zc_fi_aprov_doc_pgto on  _URL.CompanyCode       = $projection.CompanyCode
                                                                            and _URL.NetDueDate        = $projection.NetDueDate
                                                                            and _URL.CashPlanningGroup = $projection.CashPlanningGroup
                                                                            and _URL.RunHourFrom       = $projection.RunHourFrom
                                                                            and _URL.RunHourTo         = $projection.RunHourTo;
      _CompanyCode             : association [1..1] to I_CompanyCode on _CompanyCode.CompanyCode = $projection.CompanyCode;
      _RepType                 : association [1..1] to ZI_FI_VH_TIPOREL on _RepType.Value = $projection.RepType;
      _PlanningGroup           : association [0..1] to I_PlanningGroup on _PlanningGroup.CashPlanningGroup = $projection.CashPlanningGroup;
      _PaymentCurrency         : association [1..1] to I_Currency on _PaymentCurrency.Currency = $projection.PaymentCurrency;
}
