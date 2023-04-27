@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Relat.Totais por CFOP(Entradas e Saídas)'
@Metadata: {
             ignorePropagatedAnnotations: true,
             allowExtensions: true
           }
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM: {
        viewType: #COMPOSITE
        }
define view entity ZI_FI_RELATORIO_FISCAL
  as select from ZI_FI_FILTRO_RELATORIO_FISCAL
{
                 @EndUserText.label: 'Local de Negócio'
  key            Branch,
                 @EndUserText.label: 'Organização de Vendas'
                 @ObjectModel.text.element: ['OrgVendasText']
  key            Vkorg,
                 @EndUserText.label: 'Material'
  key            Material,
                 @EndUserText.label: 'NCM'
  key            NCMCode,
                 @EndUserText.label: 'CFOP'
  key            CFOP,
                 @EndUserText.label: 'Descrição do Material'
                 MaterialName,
                 @EndUserText.label: 'Quantidade'
                 sum(QtdUnit)      as QtdUnit,
                 @EndUserText.label: 'Unidade'
                 BaseUnit,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Result. em KG'
                 sum(Quantidade2)  as Quantidade2,
                 @EndUserText.label: 'Unidade KG'
                 UnitKG,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Frete'
                 sum(Frete)        as Frete,
                 @EndUserText.label: 'NF Impressa'
                 @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_NF_IMPRESSA', element: 'Printd' } }]
                 Printd,
                 @EndUserText.label: 'Tipo de Documento'
                 @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_TP_PROCESS_NF', element: 'TpProcNF' } }]
                 TpDoc,
                 @EndUserText.label: 'NF'
                 @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_TP_NF_ENTRAD', element: 'Entrad' } }]
                 TpNF,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Valor sem frete'
                 sum(VlrSemFrete)  as VlrSemFrete,
                 @EndUserText.label: 'Moeda'
                 Waerk,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Base ICMS'
                 sum(ICMS_Base)    as ICMS_Base,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Valor ICMS'
                 sum(ICMS_Valor)   as ICMS_Valor,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Base IPI'
                 sum(IPI_Base)     as IPI_Base,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Valor IPI'
                 sum(IPI_Valor)    as IPI_Valor,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Base SUBST'
                 sum(SUBST_Base)   as SUBST_Base,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Valor SUBS'
                 sum(SUBS_Valor)   as SUBS_Valor,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Valor PIS'
                 sum(PIS_Valor)    as PIS_Valor,
                 @DefaultAggregation: #SUM
                 @EndUserText.label: 'Valor COFINS'
                 sum(COFINS_Valor) as COFINS_Valor,
                 @EndUserText.label: 'Área de Avaliação'
                 ValuationArea,
                 @EndUserText.label: 'Tipo de Avaliação'
                 ValuationType,
                 @EndUserText.label: 'Segmento'
                 Segment,
                 @EndUserText.label: 'Conta Contábil'
                 sakn1,
                 @EndUserText.label: 'Texto conta'
                 SaknText,
                 @EndUserText.label: 'Data de lançamento'
                 @Consumption.filter.mandatory: true
                 Pstdat,
                 @EndUserText.label: 'Nº nota fiscal'
                 Nfnum,
                 @EndUserText.label: 'Nº documento nove posições'
                 Nfenum            as Nfenum,
                 @EndUserText.label: 'Empresa'
                 Bukrs,
                 @EndUserText.label: 'Canal de Distribuição'
                 Vtweg,
                 @EndUserText.label: 'Setor de Atividade'
                 Spart,
                 @EndUserText.label: 'Domicílio Fiscal'
                 Txjcd,
                 @EndUserText.label: 'ID Parceiro'
                 Parid,
                 @EndUserText.label: 'Desc. Org. Vendas'
                 OrgVendasText,
                 @EndUserText.label: 'Nº documento'
                 max(Docnum)       as Docnum,
                 @EndUserText.label: 'Nº item'
                 min(Itmnum)       as Itmnum,

                 /* Associations */
                 //                 _NFtax,
                 _OrgVendas

}
group by
  Branch,
  Vkorg,
  Material,
  NCMCode,
  CFOP,
  MaterialName,
  BaseUnit,
  UnitKG,
  Printd,
  TpDoc,
  TpNF,
  Waerk,
  ValuationArea,
  ValuationType,
  Segment,
  sakn1,
  SaknText,
  Pstdat,
  Nfnum,
  Nfenum,
  Bukrs,
  Vtweg,
  Spart,
  Txjcd,
  Parid,
  OrgVendasText
//
//    inner join      vbrk                      as _Vbrk       on  _Vbrk.belnr = _Lin.BR_NFSourceDocumentNumber
//                                                             and _Vbrk.belnr is not initial
//    inner join      YVIC_NFDOC_I              as _Doc        on _Doc.Docnum = _Lin.BR_NotaFiscal
//    left outer join VC_INTEGRATION_VBAK       as _Vbak       on _Vbak.VBELN = _Lin.BR_NotaFiscal
//    left outer join ZI_FI_FILTRO_TAX_ENTDSAID as _Tax_ICMS   on  _Tax_ICMS.BR_NotaFiscal     = _Lin.BR_NotaFiscal
//                                                             and _Tax_ICMS.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem
//                                                             and _Tax_ICMS.TaxGroup          = 'ICMS'
//    left outer join cepc                      as _Cepc       on _Cepc.prctr = _Lin.ProfitCenter
//    left outer join FNDEI_EKKO_FILTER         as _Ekko       on _Ekko.EBELN = _Lin.PurchaseOrder
//  //    left outer join ZI_FI_FILTRO_KONV   as _Vkonv    on _Vkonv.knumv = _Ekko.KNUMV
//    left outer join ZI_FI_FILTRO_SKAT         as _GLText     on _GLText.saknr = _Lin.GLAccount
//    left outer join FNDEI_KNA1_FILTER         as _Kna1       on _Kna1.KUNNR = _Doc.Parid
//    left outer join FNDEI_LFA1_FILTER         as _Lfa1       on _Lfa1.LIFNR = _Doc.Parid
//
//
//    left outer join ZI_FI_CONVERTE_UM         as _ConverteUM on  _ConverteUM.NumeroDocumento     = _Lin.BR_NotaFiscal
//                                                             and _ConverteUM.NumeroDocumentoItem = _Lin.BR_NotaFiscalItem
//
//  association [1..1] to ZI_FI_NFTAX_ICST_IPI as _NFtax     on  _NFtax.BR_NotaFiscal     = $projection.Docnum
//                                                           and _NFtax.BR_NotaFiscalItem = $projection.Itmnum
//  association [1..1] to ZI_CA_VH_VKORG       as _OrgVendas on  _OrgVendas.OrgVendas = $projection.Vkorg
//
//{
//
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_DOCNUM', element: 'Docnum' } }]
//      @EndUserText.label: 'Nº documento'
//  key _Lin.BR_NotaFiscal                                                                                                                                                 as Docnum,
//      @EndUserText.label: 'Nº item'
//  key _Lin.BR_NotaFiscalItem                                                                                                                                             as Itmnum,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_VKORG', element: 'Vkorg' } }]
//      @EndUserText.label: 'Organização de Vendas'
//      @ObjectModel.text.element: ['OrgVendasText']
//      _Vbrk.vkorg                                                                                                                                                        as Vkorg,
//      @EndUserText.label: 'Material'
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_MATERIAL', element: 'Material' } }]
//      _Lin.Material                                                                                                                                                      as Material,
//      @EndUserText.label: 'Descrição do Material'
//      _Lin.MaterialName                                                                                                                                                  as MaterialName,
//      @EndUserText.label: 'NCM'
//      _Lin.NCMCode                                                                                                                                                       as NCMCode,
//      //      @EndUserText.label: 'CFOP'
//      //      _Lin.BR_CFOPCode                                                                                                                                                   as CFOPCode,
//      @EndUserText.label: 'CFOP'
//      case when _Lin.BR_CFOPCode is initial then ''
//      else concat( substring(_Lin.BR_CFOPCode, 1, 4),
//          concat( '/', substring(_Lin.BR_CFOPCode, 5, 2) ) )
//      end                                                                                                                                                                as CFOP,
//
//      @EndUserText.label: 'Quantidade'
//      cast(_Lin.QuantityInBaseUnit as abap.dec( 13, 3 )  )                                                                                                               as QtdUnit,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_BASEUNIT_FLT', element: 'BaseUnit' } }]
//      @EndUserText.label: 'Unidade'
//      _Lin.BaseUnit                                                                                                                                                      as BaseUnit,
//
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Result. em KG'
//      //      (_ConverteUM.ValorConvUN *  cast(_ConverteUM.FatorConversao as abap.fltp)) / cast(_ConverteUM.FatorConversaoUN as abap.fltp ) as Quantidade2,
//      fltp_to_dec((_ConverteUM.ValorConvUN *  cast(_ConverteUM.FatorConversao as abap.fltp)) / cast(_ConverteUM.FatorConversaoUN as abap.fltp ) as abap.dec(15,2))       as Quantidade2,
//      @EndUserText.label: 'Unidade KG'
//      _ConverteUM.UnidadePeso                                                                                                                                            as UnitKG,
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Frete'
//      cast(_Lin.BR_NFNetFreightAmount as abap.dec( 15, 2 ) )                                                                                                             as Frete,
//      //      @EndUserText.label: 'Result. em KG'
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_BASEUNIT', element: 'UnitKG' } }]
//      //      case when _Lin.BaseUnit = 'KG'
//      //           then 'X'
//      //           else '' end                                             as UnitKG,
//      @EndUserText.label: 'NF Impressa'
//      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_NF_IMPRESSA', element: 'Printd' } }]
//      case when _Doc.Printd = 'X'
//           then 'X'
//           else ' ' end                                                                                                                                                  as Printd,
//
//      @EndUserText.label: 'Tipo de Documento'
//      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_TP_PROCESS_NF', element: 'TpProcNF' } }]
//      _Doc.Manual                                                                                                                                                        as TpDoc,
//      @EndUserText.label: 'NF'
//      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_TP_NF_ENTRAD', element: 'Entrad' } }]
//      _Doc.Entrad                                                                                                                                                        as TpNF,
//
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Valor sem frete'
//      //      case when _Lin.BR_NFFreightAmountWithTaxes is not initial
//      //           then cast(_Lin.BR_NFFreightAmountWithTaxes as abap.dec( 15, 2 ) ) - cast(_Doc.Nftot as abap.dec( 15, 2 ) )
//      //           else cast(_Doc.Nftot as abap.dec( 15, 2 ) )
//      //            end
//      //      cast(_Lin.BR_NFTotalAmount as abap.dec( 15, 2 )) + cast(_NFtax.IPI_Valor  as abap.dec( 15, 2 ) ) + cast(_NFtax.SUBS_Valor as abap.dec( 15, 2 ) ) - cast(_Lin.BR_NFNetFreightAmount as abap.dec( 15, 2 ) ) as VlrSemFrete,
//      case
//      when _NFtax.SUBS_Valor is not null
//      then cast(_Lin.BR_NFTotalAmount as abap.dec( 15, 2 )) + cast(_NFtax.IPI_Valor  as abap.dec( 15, 2 ) ) + cast(_NFtax.SUBS_Valor as abap.dec( 15, 2 ) ) - cast(_Lin.BR_NFNetFreightAmount as abap.dec( 15, 2 ) )
//      else cast(_Lin.BR_NFTotalAmount as abap.dec( 15, 2 )) + cast(_NFtax.IPI_Valor  as abap.dec( 15, 2 ) ) - cast(_Lin.BR_NFNetFreightAmount as abap.dec( 15, 2 ) ) end as VlrSemFrete,
//
//      @EndUserText.label: 'Moeda'
//      _Doc.Waerk                                                                                                                                                         as Waerk,
//      //      @Semantics.amount.currencyCode:'Waerk'
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Base ICMS'
//      _Tax_ICMS.BR_NFItemBaseAmount                                                                                                                                      as ICMS_Base,
//      //      @Semantics.amount.currencyCode:'Waerk'
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Valor ICMS'
//      _Tax_ICMS.BR_NFItemTaxAmount                                                                                                                                       as ICMS_Valor,
//      //      @Semantics.amount.currencyCode:'Waerk'
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Base IPI'
//      cast(_NFtax.IPI_Base as abap.dec( 15, 2 ) )                                                                                                                        as IPI_Base,
//      //      @Semantics.amount.currencyCode:'Waerk'
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Valor IPI'
//      cast(_NFtax.IPI_Valor  as abap.dec( 15, 2 ) )                                                                                                                      as IPI_Valor,
//      //      @Semantics.amount.currencyCode:'Waerk'
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Base SUBST'
//      cast(_NFtax.SUBST_Base as abap.dec( 15, 2 ) )                                                                                                                      as SUBST_Base,
//      //      @Semantics.amount.currencyCode:'Waerk'
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Valor SUBS'
//      cast(_NFtax.SUBS_Valor as abap.dec( 15, 2 ) )                                                                                                                      as SUBS_Valor,
//      //      @Semantics.amount.currencyCode:'Waerk'
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Valor PIS'
//      cast(_NFtax.PIS_Valor  as abap.dec( 15, 2 ) )                                                                                                                      as PIS_Valor,
//      //      @Semantics.amount.currencyCode:'Waerk'
//      @DefaultAggregation: #SUM
//      @EndUserText.label: 'Valor COFINS'
//      cast(_NFtax.COFINS_Valor as abap.dec( 15, 2 ) )                                                                                                                    as COFINS_Valor,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_ValuationArea', element: 'ValuationArea' } }]
//      @EndUserText.label: 'Área de Avaliação'
//      _Lin.ValuationArea                                                                                                                                                 as ValuationArea,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_VALUATIONTYPE', element: ' ValuationType' } }]
//      @EndUserText.label: 'Tipo de Avaliação'
//      _Lin.ValuationType                                                                                                                                                 as ValuationType,
//      @EndUserText.label: 'Segmento'
//      _Cepc.segment                                                                                                                                                      as Segment,
//      @EndUserText.label: 'Conta Contábil'
//      _Lin.GLAccount                                                                                                                                                     as sakn1,
//      @EndUserText.label: 'Texto conta'
//      _GLText.DescSaknr                                                                                                                                                  as SaknText,
//      @EndUserText.label: 'Data de lançamento'
//      @Consumption.filter.mandatory: true
//      _Doc.Pstdat                                                                                                                                                        as Pstdat,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_NFNUM', element: 'Nfnum' } }]
//      @EndUserText.label: 'Nº nota fiscal'
//      _Doc.Nfnum                                                                                                                                                         as Nfnum,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_NFENUM', element: 'Nfenum' } }]
//      @EndUserText.label: 'Nº documento nove posições'
//      _Doc.Nfenum                                                                                                                                                        as Nfenum,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_BUKRS', element: 'Bukrs' } }]
//      @EndUserText.label: 'Empresa'
//      _Doc.Bukrs                                                                                                                                                         as Bukrs,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_VTWEG', element: 'Vtweg' } }]
//      @EndUserText.label: 'Canal de Distribuição'
//      _Vbrk.vtweg                                                                                                                                                        as Vtweg,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_SPART', element: 'Spart' } }]
//      @EndUserText.label: 'Setor de Atividade'
//      _Vbrk.spart                                                                                                                                                        as Spart,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_BRANCH', element: 'Branch' } }]
//      @EndUserText.label: 'Local de Negócio'
//      _Doc.Branch                                                                                                                                                        as Branch,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_Txjcd', element: 'Txjcd' } }]
//      @EndUserText.label: 'Domicílio Fiscal'
//      case when _Kna1.TXJCD is not initial
//           then _Kna1.TXJCD
//           else _Lfa1.TXJCD end                                                                                                                                          as Txjcd,
//      //      @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_FISCAL_PARID', element: 'Parid' } }]
//      @EndUserText.label: 'ID Parceiro'
//      _Doc.Parid                                                                                                                                                         as Parid,
//      @EndUserText.label: 'Desc. Org. Vendas'
//      _OrgVendas.OrgVendasText                                                                                                                                           as OrgVendasText,
//
//      _NFtax,
//      _OrgVendas
//}
