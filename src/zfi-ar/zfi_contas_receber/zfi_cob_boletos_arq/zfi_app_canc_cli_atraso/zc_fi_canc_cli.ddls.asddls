@EndUserText.label: 'Cancel. clientes e por dias de atraso'

@UI: { headerInfo: { typeName: 'Dados do cancelamento', // Object Page
                     typeNamePlural: 'Cancel. clientes e por dias de atraso', // List Report
                     title: { type: #STANDARD, value: 'belnr' } } }

@ObjectModel: { query.implementedBy: 'ABAP:ZCLFI_DIAS_ATRASO'}
define root custom entity zc_fi_canc_cli
{
      // ------------------------------------------------------
      // Informações de cabeçalho
      // ------------------------------------------------------
      @UI.facet: [ { id:              'Cancela',
                     purpose:         #STANDARD,
                     type:            #IDENTIFICATION_REFERENCE,
                     label:           'Dados do cancelamento', // Object page deploy
                     position:        10
                     } ]
      // ------------------------------------------------------
      // Informações de campo
      // ------------------------------------------------------

      @UI      : {  lineItem:       [ { position: 10 } ],
                    identification: [ { position: 10 } ],
                    selectionField: [ { position: 10  } ] }
  key bukrs    : bukrs;
      @UI      : {  lineItem:       [ { position: 40 } ],
              identification: [ { position: 40 } ],
              selectionField: [ { position: 20 } ] }
  key belnr    : belnr_d;
      @UI      : {  lineItem:       [ { position: 50 } ],
              identification: [ { position: 50 } ]  }
  key buzei    : buzei;
      @UI      : {  lineItem:       [ { position: 60 } ],
              identification: [ { position: 60 } ],
              selectionField: [ { position: 40 } ] }
  key gjahr    : gjahr;
      @UI      : {  lineItem:       [ { position: 20 } ],
            identification: [ { position: 20 } ],
            selectionField: [ { position: 50 } ] }
  key kunnr    : kunnr;
      @UI      : {  lineItem:       [ { position: 30 } ],
            identification: [ { position: 30 } ] }
      name1    : name1_gp;
      @UI      : {  lineItem:       [ { position: 70 } ],
              identification: [ { position: 70 } ],
              selectionField: [ { position: 30 } ] }
      bldat    : bldat;
      @UI      : {  lineItem:       [ { position: 80 } ],
              identification: [ { position: 80 } ] }
      bschl    : bschl;
      @UI      : {  lineItem:       [ { position: 90 } ],
              identification: [ { position: 90 } ] }
      blart    : blart;
      @UI      : {  lineItem:       [ { position: 100 } ],
              identification: [ { position: 100 } ] }
      anfbn    : anfbn;
      @UI      : {  lineItem:       [ { position: 110 } ],
              identification: [ { position: 110 } ] }
      zuonr    : dzuonr;

      @UI      : {  lineItem:       [ { position: 120 } ],
                    identification: [ { position: 120, label: 'Qtd. dias em atraso' } ],
                    selectionField: [ { position: 60  } ] }
      @EndUserText.label: 'Qtd. dias em atraso'
      diasAtra : verz1;

      @UI      : {  lineItem:       [ { position: 130 } ],
                    identification: [ { position: 130 } ] }
      @EndUserText.label: 'Montante em moeda interna '
      dmbtr    : abap.dec( 23, 2 );

      @UI      : {  lineItem:       [ { position: 140 } ],
        identification: [ { position: 140 } ] }
      xblnr    : xblnr1;

      @UI      : {  lineItem:       [ { position: 150 } ],
                    identification: [ { position: 150 } ] }
      hbkid    : hbkid;

      @UI      : {  lineItem:       [ { position: 160 } ],
                    identification: [ { position: 160 } ] }
      zlsch    : schzw_bseg;

      @UI      : {  lineItem:       [ { position: 170 } ],
              identification: [ { position: 170 } ] }
      rebzg    : rebzg;

      @UI      : {  lineItem:       [ { position: 180 } ],
                    identification: [ { position: 180 } ] }
      @EndUserText.label: 'Montante em moeda do documento'
      wrbtr    : abap.dec( 23, 2 );

      @UI      : {  lineItem:       [ { position: 190 } ],
              identification: [ { position: 190 } ] }
      waers    : waers;
      @UI      : {  lineItem:       [ { position: 200 } ],
              identification: [ { position: 200 } ] }
      zfbdt    : dzfbdt;
      @UI      : {  lineItem:       [ { position: 210 } ],
              identification: [ { position: 210 } ] }
      zbd1t    : dzbd1t;
      @UI      : {  lineItem:       [ { position: 220 } ],
              identification: [ { position: 220 } ] }
      zbd2t    : dzbd2t;
      @UI      : {  lineItem:       [ { position: 230 } ],
              identification: [ { position: 230 } ] }
      zbd3t    : dzbd3t;
      // ------------------------------------------------------
      // Buttons information
      // ------------------------------------------------------
      @UI.lineItem      : [ { position: 240, type: #FOR_ACTION, dataAction: 'cancelar', label: 'Cancelamento Dia de Atraso', invocationGrouping: #CHANGE_SET } ]
      Action   : abap.char(1);
}
