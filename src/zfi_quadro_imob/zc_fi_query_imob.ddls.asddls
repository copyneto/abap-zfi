@EndUserText.label: 'Relatório imobilizados'

@UI.headerInfo: { typeName: 'Relatório CPC02',
                  typeNamePlural: 'Relatório CPC02' }

@ObjectModel: { query.implementedBy: 'ABAP:ZCLFI_CALC_DATE'}
define custom entity ZC_FI_QUERY_IMOB
{

      @UI           : { lineItem:        [ { position: 10 } ],
             identification:  [ { position: 10 } ],
             selectionField:  [ { position: 10 } ] }
  key anln1         : anln1;

      @UI           : { lineItem:        [ { position: 20 } ],
             identification:  [ { position: 20 } ],
             selectionField:  [ { position: 20 } ] }
  key anln2         : anln2;

      @UI           : { lineItem:        [ { position: 70 } ],
        identification:  [ { position: 70 } ],
        selectionField:  [ { position: 70 } ] }
  key bukrs         : bukrs;
      @UI.hidden    : true
  key afabe         : afabe_d;

      @UI           : { lineItem:        [ { position: 30, label: 'Data de Aquisição' } ],
             identification:  [ { position: 30 } ],
             selectionField:  [ { position: 30 } ] }
      @EndUserText.label: 'Data do Relatório'
      aktiv         : aktivd;

      @UI           : { lineItem:        [ { position: 40 } ],
            identification:  [ { position: 40 } ]}
      @DefaultAggregation          : #SUM
      @EndUserText.label: 'Valor aquisição_80'
      answl         : abap.dec( 23, 2 );

      @UI           : { lineItem:        [ { position: 50 } ],
            identification:  [ { position: 50 } ]}
      @EndUserText.label: 'Depreciação acumulada_80'
      @DefaultAggregation          : #SUM
      nafag         : abap.dec( 23, 2 );

      @UI           : { lineItem:        [ { position: 60 } ],
            identification:  [ { position: 60 } ] }
      @EndUserText.label: 'Vr Contab_80'
      @DefaultAggregation          : #SUM
      vlContab      : abap.dec( 23, 2 );

      @UI           : { lineItem:        [ { position: 80 } ],
            identification:  [ { position: 80 } ],
            selectionField:  [ { position: 80 } ] }
      gsber         : gsber;

      @UI           : { lineItem:        [ { position: 90 } ],
        identification:  [ { position: 90 } ],
        selectionField:  [ { position: 90 } ] }
      anlkl         : anlkl;

      @UI           : { lineItem:        [ { position: 100 } ],
               identification:  [ { position: 100 } ] }
      @EndUserText.label: 'DOLAR STRAUSS ValorAquis_34'
      @DefaultAggregation          : #SUM
      valorAq       : abap.dec( 23, 2 );

      @UI           : { lineItem:        [ { position: 110 } ],
             identification:  [ { position: 110 } ] }
      @EndUserText.label: 'DOLAR STRAUSS DeprecAcum_34'
      @DefaultAggregation          : #SUM
      Deprec        : abap.dec( 23, 2 );

      @UI           : { lineItem:        [ { position: 120 } ],
            identification:  [ { position: 120 } ] }
      @EndUserText.label: 'DOLAR STRAUSS VrContab_34'
      @DefaultAggregation          : #SUM
      vlContab34    : abap.dec( 23, 2 );

      @UI           : { lineItem:        [ { position: 130 } ],
              identification:  [ { position: 130 } ] }
      @EndUserText.label: 'AJUSTE CPC02 ValorAquis'
      @DefaultAggregation          : #SUM
      valorAqAjuste : abap.dec( 23, 2 );

      @UI           : { lineItem:        [ { position: 140 } ],
             identification:  [ { position: 140 } ] }
      @EndUserText.label: 'AJUSTE CPC02 DeprecAcum'
      @DefaultAggregation          : #SUM
      DeprecAcum    : abap.dec( 23, 2 );

      @UI           : { lineItem:        [ { position: 150 } ],
              identification:  [ { position: 150 } ] }
      @EndUserText.label: 'Conta CPC02 AQUISICAO'
      zaqui         : ze_aqui;

      @UI           : { lineItem:        [ { position: 160 } ],
           identification:  [ { position: 160 } ] }
      @EndUserText.label: 'Conta AJUSTE CPC02 DEPREC'

      zdepr         : ze_depr;

      @UI           : { lineItem:        [ { position: 170 } ],
      identification:  [ { position: 170 } ] }
      @EndUserText.label: 'Mensagem'
      mensagem      : abap.sstring( 100 );

      @UI.hidden    : true
      ukurs         : abap.dec( 23, 5 );
      @UI.hidden    : true
      Moeda         : waers;
      @UI.hidden    : true
      bstdt         : bstdt;
      @UI.hidden    : true
      waers         : waers;
      @UI.hidden    : true
      kansw         : abap.dec( 23, 2 );
      @UI.hidden    : true
      knafa         : abap.dec( 23, 2 );
      @UI.hidden    : true
      answl34       : abap.dec( 23, 2 );
      @UI.hidden    : true
      nafag34       : abap.dec( 23, 2 );


}
