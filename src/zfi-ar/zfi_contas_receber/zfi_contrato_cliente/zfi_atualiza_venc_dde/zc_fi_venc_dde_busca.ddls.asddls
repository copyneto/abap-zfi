@EndUserText.label: 'Buscar dados DDE'
@ObjectModel.query.implementedBy: 'ABAP:ZCLFI_QUERY_DDE_APP'
define root custom entity ZC_FI_VENC_DDE_BUSCA
{
      @UI             : { lineItem:       [ { position: 10 }],
                      selectionField: [ { position: 10 }] }


      @EndUserText.label: 'Empresa'
      @ObjectModel.text.element: ['CompanyCodeName']
  key bukrs           : bukrs;
      @UI             : { lineItem:       [ { position: 20 }],
                      selectionField: [ { position: 20 }] }
      @EndUserText.label: 'N° Documento'

  key belnr           : belnr_d;
      @UI             : { lineItem:       [ { position: 30 }],
                      selectionField: [ { position: 30 }] }
      @EndUserText.label: 'Exercicio'
  key gjahr           : gjahr;
      @UI             : { lineItem:       [ { position: 40 }],
                      selectionField: [ { position: 40 }] }
      @EndUserText.label: 'Item'
  key buzei           : buzei;
      @UI             : { lineItem:       [ { position: 50 }],
                      selectionField: [ { position: 50 }] }
      @EndUserText.label: 'Cliente'
      @ObjectModel.text.element: ['name1']
  key kunnr           : kunnr;
      @UI             : { lineItem:       [ { position: 60 }],
                      selectionField: [ { position: 60 }] }
      @EndUserText.label: 'Fatura'
  key vbeln           : vbeln_vf;
      @UI             : { lineItem:       [ { position: 70 }],
                      selectionField: [ { position: 70 }] }
      @EndUserText.label: 'Remessa'
  key vgbel           : vgbel;
      @UI             : { lineItem:       [ { position: 80 }],
                      selectionField: [ { position: 80 }] }
      @EndUserText.label: 'Data de entrega'
      DataEntrega     : datum;
      @UI.hidden      : true
      @UI.lineItem    : [{ type: #FOR_ACTION,dataAction: 'ATUALIZA', label: 'Atualizar' }]
      cnpjroot        : abap.char( 8 );
      @UI.hidden      : true
      CompanyCodeName : name1;
      @UI.hidden      : true
      name1           : name1;
      @UI.hidden      : true
      familia         : char2;
      @UI.hidden      : true
      classificacao   : katr2;
      @UI.hidden      : true
      budat           : budat;

      zuonr           : dzuonr;
      gsber           : gsber;
      xblnr           : xblnr1;
      sgtxt           : sgtxt;
      zlspr           : dzlspr;
      zterm           : dzterm;
      mansp           : mansp;
      zfbdt           : dzfbdt;
      zbd1t           : dzbd1t;
      zbd2t           : dzbd2t;
      zbd3t           : dzbd3t;
      dtws1           : dtat16;
      hbkid           : hbkid;
      xref3           : xref3;

      stcd1           : stcd1;
      stcd2           : stcd2;

      BKTXT           : bktxt;

      XREF1_HD        : xref1_hd;
      XREF2_HD        : xref2_hd;
      @UI             : { selectionField: [ { position: 90 }] }
      @Consumption.filter.selectionType: #SINGLE
      bldat           : bldat;
      @UI             : { selectionField: [ { position: 100 }] }
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_ZLSCH', element: 'FormaPagamento' }}]
      zlsch           : dzlsch;
      @UI             : { lineItem:       [ { position: 110 }],
                          selectionField: [ { position: 110 }] }
      @EndUserText.label: 'Chave Lançamento'
      @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_BSCHL', element: 'PostingKey' }}]
      @ObjectModel.text.element: ['PostingKeyName']
      bschl           : bschl;
      @UI.hidden      : true
      PostingKeyName  : text_bslt;
}
