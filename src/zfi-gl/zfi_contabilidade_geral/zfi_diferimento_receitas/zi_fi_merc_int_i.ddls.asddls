@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Mercado Interno Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_MERC_INT_I
  as select from bseg

  association to parent ZI_FI_MERC_INT_H as _MercIntHeader on  _MercIntHeader.Empresa = $projection.Empresa
                                                           and _MercIntHeader.NumDoc  = $projection.NumDoc
                                                           and _MercIntHeader.Ano     = $projection.Ano


{
  key bukrs   as Empresa,
  key belnr   as NumDoc,
  key gjahr   as Ano,
  key buzei   as Item,
      kunnr   as Cliente,
      hkont   as Conta,
      gsber   as Divisao,
      zuonr   as Atribuicao,
      sgtxt   as TextItem,
      shkzg   as CredDeb,
      bupla   as LocalNegocio,
      prctr   as CentroLucro,
      kostl   as CentroCusto,
      segment as Segmento,
      _MercIntHeader.Moeda,
      @Semantics.amount.currencyCode: 'Moeda'
      dmbtr   as Valor,

      case shkzg
          when 'S' then 3
          when 'H' then 1
      end     as ValorCriticality,

      _MercIntHeader
}
