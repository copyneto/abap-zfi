@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Agrupamento do Relatório Fiscal'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_FILTRO_RELATORIO_FISCAL
  as select from    I_BR_NFItem               as _Lin

    inner join      vbrk                      as _Vbrk                on  _Vbrk.belnr = _Lin.BR_NFSourceDocumentNumber
                                                                      and _Vbrk.belnr is not initial
    inner join      I_BR_NFDocument           as _Doc                 on _Doc.BR_NotaFiscal = _Lin.BR_NotaFiscal
    left outer join VC_INTEGRATION_VBAK       as _Vbak                on _Vbak.VBELN = _Lin.BR_NotaFiscal
    left outer join ZI_FI_FILTRO_TAX_ENTDSAID as _Tax_ICMS            on  _Tax_ICMS.BR_NotaFiscal     = _Lin.BR_NotaFiscal
                                                                      and _Tax_ICMS.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem
                                                                      and _Tax_ICMS.TaxGroup          = 'ICMS'
    left outer join cepc                      as _Cepc                on _Cepc.prctr = _Lin.ProfitCenter
    left outer join FNDEI_EKKO_FILTER         as _Ekko                on _Ekko.EBELN = _Lin.PurchaseOrder
    left outer join ZI_FI_FILTRO_SKAT         as _GLText              on _GLText.saknr = _Lin.GLAccount
    left outer join FNDEI_KNA1_FILTER         as _Kna1                on _Kna1.KUNNR = _Doc.BR_NFPartner
    left outer join FNDEI_LFA1_FILTER         as _Lfa1                on _Lfa1.LIFNR = _Doc.BR_NFPartner


    left outer join ZI_FI_CONVERTE_UM         as _ConverteUM          on  _ConverteUM.NumeroDocumento     = _Lin.BR_NotaFiscal
                                                                      and _ConverteUM.NumeroDocumentoItem = _Lin.BR_NotaFiscalItem

    left outer join mara                      as _mara                on _mara.matnr = _Lin.Material

    left outer join marm                      as _mara_uni_to_default on  _mara_uni_to_default.matnr = _Lin.Material
                                                                      and _mara_uni_to_default.meinh = _Lin.BaseUnit

    left outer join marm                      as _mara_uni_to_kg      on  _mara_uni_to_kg.matnr = _Lin.Material
                                                                      and _mara_uni_to_kg.meinh = 'KG'

    left outer join marm                      as _marm                on  _marm.matnr = _Lin.Material
                                                                      and _marm.meinh = 'KG'

    left outer join ZI_FI_NFTAX_ICST_IPI      as _NFtax               on  _NFtax.BR_NotaFiscal     = _Lin.BR_NotaFiscal
                                                                      and _NFtax.BR_NotaFiscalItem = _Lin.BR_NotaFiscalItem

  association [1..1] to ZI_FI_ICST_IPI as _NFtax_frete on  _NFtax_frete.BR_NotaFiscal     = $projection.Docnum
                                                       and _NFtax_frete.BR_NotaFiscalItem = $projection.Itmnum

  association [1..1] to ZI_CA_VH_VKORG as _OrgVendas   on  _OrgVendas.OrgVendas = $projection.Vkorg

{

  key _Lin.BR_NotaFiscal                                                                                                           as Docnum,
  key _Lin.BR_NotaFiscalItem                                                                                                       as Itmnum,
      _Vbrk.vkorg                                                                                                                  as Vkorg,
      _Lin.Material                                                                                                                as Material,
      _Lin.MaterialName                                                                                                            as MaterialName,
      _Lin.NCMCode                                                                                                                 as NCMCode,
      case when _Lin.BR_CFOPCode is initial then ''
            else concat( substring(_Lin.BR_CFOPCode, 1, 4),
                concat( '/', substring(_Lin.BR_CFOPCode, 5, 2) ) )
            end                                                                                                                    as CFOP,
      cast(_Lin.QuantityInBaseUnit as abap.dec( 13, 2 )  )                                                                         as QtdUnit,
      _Lin.BaseUnit                                                                                                                as BaseUnit,
      //      fltp_to_dec((_ConverteUM.ValorConvUN *  cast(_ConverteUM.FatorConversao as abap.fltp)) / cast(_ConverteUM.FatorConversaoUN as abap.fltp ) as abap.dec(15,2))             as Quantidade2,
      //      fltp_to_dec((cast(_Lin.QuantityInBaseUnit as abap.fltp) *  cast(_mara_uni_to_default.umrez as abap.fltp)) / cast(_marm.umren as abap.fltp ) as abap.dec(15,2))             as Quantidade2,

      fltp_to_dec(

      (
      cast(_Lin.QuantityInBaseUnit as abap.fltp) *  cast(_mara_uni_to_default.umrez as abap.fltp)
      )
      /
      cast(_mara_uni_to_default.umren as abap.fltp )
      /
      cast(_mara_uni_to_kg .umrez as abap.fltp)
      *
      cast(_mara_uni_to_kg .umren as abap.fltp )

      as abap.dec(15,2))                                                                                                           as Quantidade2,
      _ConverteUM.UnidadePeso                                                                                                      as UnitKG,
      cast(_Lin.BR_NFNetFreightAmount as abap.dec( 15, 2 ) )                                                                       as Frete,
      _Doc.BR_NFIsPrinted                                                                                                          as Printd,
      _Doc.BR_NFIsCreatedManually                                                                                                  as TpDoc,
      _Doc.BR_NFIsIncomingIssdByCust                                                                                               as TpNF,
      //      case
      //            when _NFtax.SUBS_Valor is not null
      //            then cast(_Lin.BR_NFTotalAmount as abap.dec( 15, 2 )) + cast(_NFtax.IPI_Valor  as abap.dec( 15, 2 ) ) + cast(_NFtax.SUBS_Valor as abap.dec( 15, 2 ) ) - cast(_Lin.BR_NFNetFreightAmount as abap.dec( 15, 2 ) )
      //            else cast(_Lin.BR_NFTotalAmount as abap.dec( 15, 2 )) + cast(_NFtax.IPI_Valor  as abap.dec( 15, 2 ) ) - cast(_Lin.BR_NFNetFreightAmount as abap.dec( 15, 2 ) ) end as VlrSemFrete,
      //      cast(_Lin.NetValueAmount as abap.dec( 15, 2 )) - cast(_Lin.BR_NFNetFreightAmount as abap.dec( 15, 2 ) ) as VlrSemFrete,

      cast(_Lin.BR_NFTotalAmount as abap.dec( 15, 2 )) - cast(_Lin.BR_NFNetFreightAmount as abap.dec( 15, 2 )) + _NFtax_frete.Taxval as VlrSemFrete, 
      _Doc.SalesDocumentCurrency                                                                                                   as Waerk,
      _Tax_ICMS.BR_NFItemBaseAmount                                                                                                as ICMS_Base,
      _Tax_ICMS.BR_NFItemTaxAmount                                                                                                 as ICMS_Valor,
      cast(_NFtax.IPI_Base as abap.dec( 15, 2 ) )                                                                                  as IPI_Base,
      cast(_NFtax.IPI_Valor  as abap.dec( 15, 2 ) )                                                                                as IPI_Valor,
      cast(_NFtax.SUBST_Base as abap.dec( 15, 2 ) )                                                                                as SUBST_Base,
      cast(_NFtax.SUBS_Valor as abap.dec( 15, 2 ) )                                                                                as SUBS_Valor,
      cast(_NFtax.PIS_Valor  as abap.dec( 15, 2 ) )                                                                                as PIS_Valor,
      cast(_NFtax.COFINS_Valor as abap.dec( 15, 2 ) )                                                                              as COFINS_Valor,
      _Lin.ValuationArea                                                                                                           as ValuationArea,
      _Lin.ValuationType                                                                                                           as ValuationType,
      _Cepc.segment                                                                                                                as Segment,
      _Lin.GLAccount                                                                                                               as sakn1,
      _GLText.DescSaknr                                                                                                            as SaknText,
      _Doc.BR_NFPostingDate                                                                                                        as Pstdat,
      _Doc.BR_NFNumber                                                                                                             as Nfnum,
      _Doc.BR_NFeNumber                                                                                                            as Nfenum,
      _Doc.CompanyCode                                                                                                             as Bukrs,
      _Vbrk.vtweg                                                                                                                  as Vtweg,
      _Vbrk.spart                                                                                                                  as Spart,
      _Doc.BusinessPlace                                                                                                           as Branch,
      case when _Kna1.TXJCD is not initial
                 then _Kna1.TXJCD
                 else _Lfa1.TXJCD end                                                                                              as Txjcd,
      _Doc.BR_NFPartner                                                                                                            as Parid,
      _OrgVendas.OrgVendasText                                                                                                     as OrgVendasText,

      //      _NFtax,
      _OrgVendas
}
