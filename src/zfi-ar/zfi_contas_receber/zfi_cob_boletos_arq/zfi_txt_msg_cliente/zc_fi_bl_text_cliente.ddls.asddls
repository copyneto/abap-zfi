@EndUserText.label: 'Texto Msg Cliente Boleto-Projection View'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_BL_TEXT_CLIENTE
  as projection on ZI_FI_BL_TEXT_CLIENTE
{
      @ObjectModel.text.element: ['NameEmpr']
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ESH_N_HOUSEBANK_T012', element: 'bukrs'  } }]
      @UI.selectionField: [{ position: 20 }]
  key Bukrs,
      @ObjectModel.text.element: ['NameClient']
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ESH_N_KNA1_KNB1_KNB1_CUSTOMER', element: 'kunnr'  } }]
      @UI.selectionField: [{ position: 10 }]
  key Kunnr,
      @ObjectModel.text.element: ['NameBanco']
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ESH_N_HOUSEBANK_T012', element: 'hbkid'  } }]
      @UI.selectionField: [{ position: 30 }]
  key Hbkid,
      /* Nome da Empresa */
      _T001.butxt     as NameEmpr,
      /* Nome do Cliente */
      _Customer.name1 as NameClient,
      /* Nome do Banco */
      _Bank.text1     as NameBanco,
      Text,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Bank,
      _T001,
      _Customer
}
