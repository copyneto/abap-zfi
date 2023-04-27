@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Converte unidade de medida'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CONVERTE_UM
  as select from I_BR_NFItem     as NFItem
    inner join   I_BR_NFDocument as NF            on NF.BR_NotaFiscal = NFItem.BR_NotaFiscal

    inner join   marm            as _ConverteToUN on  _ConverteToUN.matnr = NFItem.Material
                                                  and _ConverteToUN.meinh = NFItem.BaseUnit

  association [1..1] to marm as _UnidadeMedida on  _UnidadeMedida.matnr = $projection.Material
                                               and _UnidadeMedida.meinh = 'KG'
{
  key NFItem.BR_NotaFiscal                                                                                                              as NumeroDocumento,
  key NFItem.BR_NotaFiscalItem                                                                                                          as NumeroDocumentoItem,
      NFItem.Material                                                                                                                   as Material,
      NFItem.BaseUnit                                                                                                                   as UnidadeMedida,
      _UnidadeMedida.umrez                                                                                                              as FatorConversaoUN,
      _UnidadeMedida.meinh                                                                                                              as UnidadePeso,
      _UnidadeMedida.umren                                                                                                              as FatorConversao,

      (cast(NFItem.QuantityInBaseUnit as abap.fltp) * cast(_ConverteToUN.umren as abap.fltp)) / cast(_ConverteToUN.umrez as abap.fltp ) as ValorConvUN,
      _UnidadeMedida
}
