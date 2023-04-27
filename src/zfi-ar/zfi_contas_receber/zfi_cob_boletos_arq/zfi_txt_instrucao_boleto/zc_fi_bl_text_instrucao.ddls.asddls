@EndUserText.label: 'Texto Instrução Boletos-Projection View'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_BL_TEXT_INSTRUCAO
  as projection on ZI_FI_BL_TEXT_INSTRUCAO
{

      @ObjectModel.text.element: ['NameEmpr']
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ESH_N_HOUSEBANK_T012', element: 'bukrs'  } }]
      @UI.selectionField: [{ position: 10 }]
  key Bukrs,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ESH_N_HOUSEBANK_T012', element: 'hbkid'  } }]
      @UI.selectionField: [{ position: 20 }]
  key Hbkid,
      @ObjectModel.text.element: ['NomeBanco']
      @UI.selectionField: [{ position: 30 }]
      Bankl,
      @ObjectModel.text.element: ['NamePais']
      @UI.selectionField: [{ position: 40 }]
      Banks,
      /* Nome da Empresa */
      _T001.butxt  as NameEmpr,
      /* Nome do País*/
      _T005T.landx as NamePais,
      /* Nome do País*/
      _BNKA.banka  as NomeBanco,
      Text,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _T012,
      _T001,
      _T005T,
      _BNKA
}
