@EndUserText.label: 'Consumption da ZI_FI_CONT_REVERS_LOG'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_FI_CONT_REVERS_LOG
  as projection on ZI_FI_cont_revers_log
{
      @ObjectModel.text.element: ['DescCodCenario']
  key CodCenario,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_BUKRS', element: 'Empresa'  } }]
      @UI.selectionField: [{ position: 10 }]
  key Bukrs,
  key Bstkd,
      @UI.selectionField: [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_BUPLA', element: 'Branch' },
                                           additionalBinding: [{ element: 'Bukrs', localElement: 'Bukrs' }]} ]
  key Bupla,
  key Zlsch,
      @UI.selectionField: [{ position: 40 }]
  key DataI,
  key HoraI,
  key UserI,
      @UI.selectionField: [{ position: 30 }]
      Gsber,
      Belnr,
      Gjahr,
      BukrsD,
      @ObjectModel.text.element: ['DescCodTpCenario']
      CodTipoCenario,
      @ObjectModel.text.element: ['DescCodOrdem']
      CodOrdem,
      @ObjectModel.text.element: ['DescCodPag']
      CodPgto,
      @ObjectModel.text.element: ['DescCodRessarc']
      CodRessarcimento,
      @ObjectModel.text.element: ['DescCodMercad']
      CodMercadoria,
      Vbeln,
      Lifnr,
      @UI.hidden: true
      Waers,
      Zvou,
      VlrRestituir,
      IdPedido,
      VlrTax,
      Voucher,
      Adm,
      Nsu,
      DtVenda,
      NomeIdent,
      Status,
      TxPerc,
      IdSalesForce,
      Reservado1,
      Reservado2,
      Reservado3,
      Reservado4,
      Reservado5,
      Reservado6,
      Reservado7,
      Reservado8,
      Reservado9,
      Reservado10,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _CodCenario.descricao   as DescCodCenario,
      _CodMercad.descricao    as DescCodMercad,
      _CodRessarc.descricao   as DescCodRessarc,
      _CodPagment.descricao   as DescCodPag,
      _CodOrdemSD.descricao   as DescCodOrdem,
      _CodTpCenario.descricao as DescCodTpCenario,

      /* Associations */
      _T001
}
