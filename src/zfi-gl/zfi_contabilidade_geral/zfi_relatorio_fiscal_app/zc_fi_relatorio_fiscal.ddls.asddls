@EndUserText.label: 'Relat. de Totais CFOP(Entradas e Saídas)'
@UI.headerInfo: { typeName: 'CFOP',
                  typeNamePlural: 'CFOP' }

@ObjectModel: { query.implementedBy: 'ABAP:ZCLFI_RELAT_FISCAL'}
define custom entity ZC_FI_RELATORIO_FISCAL
{

      @UI           : { lineItem      : [ { position: 10 } ],
                        selectionField: [ { position: 60 } ]}
      @EndUserText.label: 'Local de Negócio'
  key Branch        : j_1bbranc_;
      @UI           : { lineItem:       [ { position: 20 } ],
                        selectionField: [ { position: 100 } ]}
      @EndUserText.label: 'Organização de Vendas' 
      @ObjectModel.text.element: ['OrgVendasText'] 
  key Vkorg         : vkorg;
      @UI           : { lineItem:       [ { position: 30 } ],
                        selectionField: [ { position: 50 } ]}
      @EndUserText.label: 'Material'
  key Material      : matnr;
      @UI           : { lineItem:       [ { position: 50 } ]}
      @EndUserText.label: 'NCM'
  key NCMCode       : steuc;
      @UI           : { lineItem:       [ { position: 60 } ],
                        selectionField: [ { position: 80 } ]}
      @EndUserText.label: 'CFOP'
  key CFOP          : char10;
      @UI           : { lineItem:       [ { position: 240 } ]}
      @EndUserText.label: 'Conta Contábil'
  key Sakn1         : j_1b_gl_account;
      @UI           : { lineItem:       [ { position: 80 } ]}
      @EndUserText.label: 'Unidade'
  key BaseUnit      : j_1bnetunt;
      @UI           : { lineItem:       [ { position: 40 } ]}
      @EndUserText.label: 'Descrição do Material'
      MaterialName  : maktx;
      @UI           : { lineItem:       [ { position: 70 } ]}
      @EndUserText.label: 'Quantidade'
      QtdUnit       : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 90 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Result. em KG'
      Quantidade2   : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 100 } ]} 
      @EndUserText.label: 'Unidade KG'
      UnitKG        : lrmei;
      @UI           : { lineItem:       [ { position: 110 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Frete'
      Frete         : ze_qtd_relfis;
      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_NF_IMPRESSA', element: 'Printd' } }]
      @Consumption.filter.selectionType: #SINGLE
      @UI           : { selectionField: [ { position: 160 } ]}
      @EndUserText.label: 'NF Impressa'
      Printd        : boolean;
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_TP_PROCESS_NF', element: 'TpProcNF' } }]
      @UI           : { selectionField: [ { position: 170 } ]}
      @EndUserText.label: 'Tipo de Documento'
      TpDoc         : j_1bmanual;
      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_TP_NF_ENTRAD', element: 'Entrad' } }]
      @UI           : { selectionField: [ { position: 180 } ]}
      @EndUserText.label: 'NF'
      TpNF          : j_1bentrad;
      @UI           : { lineItem:       [ { position: 120 } ]}
      @EndUserText.label: 'Valor sem frete'
      VlrSemFrete   : abap.dec( 17, 2 );
      @UI.hidden    : true
      @EndUserText.label: 'Moeda'
      Waerk         : waerk;
      @UI           : { lineItem:       [ { position: 130 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Base ICMS'
      ICMS_Base     : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 140 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Valor ICMS'
      ICMS_Valor    : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 150 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Base IPI'
      IPI_Base      : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 160 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Valor IPI'
      IPI_Valor     : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 170 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Base SUBST'
      SUBST_Base    : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 180 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Valor SUBS'
      SUBS_Valor    : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 190 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Valor PIS'
      PIS_Valor     : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 200 } ]}
      //      @DefaultAggregation: #SUM
      @EndUserText.label: 'Valor COFINS'
      COFINS_Valor  : ze_qtd_relfis;
      @UI           : { lineItem:       [ { position: 210 } ],
                        selectionField: [ { position: 60  } ]}
      @EndUserText.label: 'Área de Avaliação'
      ValuationArea : bwkey;
      @UI           : { lineItem:       [ { position: 220 } ],
                        selectionField: [ { position: 70  } ]}
      @EndUserText.label: 'Tipo de Avaliação'
      ValuationType : bwtar_d;
      @UI           : { lineItem:       [ { position: 230 } ]}
      @EndUserText.label: 'Segmento'
      Segment       : fb_segment;
      @UI           : { lineItem:       [ { position: 250 } ]}
      @EndUserText.label: 'Texto conta'
      SaknText      : txt50_skat;
      @UI           : { selectionField: [ { position: 10 } ]}
      @Consumption.filter.selectionType: #INTERVAL
      @EndUserText.label: 'Data de lançamento'
      @Consumption.filter.mandatory: true
      Pstdat        : j_1bpstdat;
      @UI           : { selectionField: [ { position: 30 } ]}
      @EndUserText.label: 'Nº nota fiscal'
      Nfnum         : j_1bnfnumb;
      @UI           : { selectionField: [ { position: 40 } ]}
      @EndUserText.label: 'Nº documento nove posições'
      Nfenum        : j_1bnfnum9;
      @UI           : { selectionField: [ { position: 90 } ]}
      @EndUserText.label: 'Empresa'
      Bukrs         : bukrs;
      @UI           : { selectionField: [ { position: 110 } ]}
      @EndUserText.label: 'Canal de Distribuição'
      Vtweg         : vtweg;
      @UI           : { selectionField: [ { position: 120 } ]}
      @EndUserText.label: 'Setor de Atividade'
      Spart         : spart;
      @UI           : { selectionField: [ { position: 140 } ]}
      @EndUserText.label: 'Domicílio Fiscal'
      Txjcd         : txjcd;
      @UI           : { selectionField: [ { position: 150 } ]}
      @EndUserText.label: 'ID Parceiro'
      Parid         : j_1bparid;
      @UI.hidden    : true
      @EndUserText.label: 'Desc. Org. Vendas'
      OrgVendasText : vtxtk;
      @UI           : { selectionField: [ { position: 20 } ]}
      @EndUserText.label: 'Nº documento'
      Docnum        : j_1bdocnum;
      @UI.hidden    : true
      @EndUserText.label: 'Nº item'
      Itmnum        : j_1bitmnum;

}
