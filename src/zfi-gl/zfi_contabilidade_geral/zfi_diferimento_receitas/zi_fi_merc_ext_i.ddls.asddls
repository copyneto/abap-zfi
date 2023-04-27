@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Mercado Externo Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_MERC_EXT_I
  as select from bseg as _bseg
    inner join ZI_FI_MERC_EXT_LOG    as _Header on      _Header.bukrs = _bseg.bukrs
                                                    and _Header.belnr = _bseg.belnr
                                                    and _Header.gjahr = _bseg.gjahr
    
    inner join   I_BillingDocument     as _VendasHeader on  ( _VendasHeader.AccountingDocument             =  _Header.awkey
                                                        or _VendasHeader.AccountingDocument             =  _Header.belnr )


    inner join   ZI_FI_I_BillingDocumentItem as _VendasItem   on  _VendasItem.BillingDocument     = _VendasHeader.BillingDocument
  

  association to parent ZI_FI_MERC_EXT_H as _MercExtHeader on  _MercExtHeader.Empresa = $projection.Empresa
                                                           and _MercExtHeader.NumDoc  = $projection.NumDoc
                                                           and _MercExtHeader.Ano     = $projection.Ano


{
  key _bseg.bukrs   as Empresa,
  key _bseg.belnr   as NumDoc,
  key _bseg.gjahr   as Ano,
  key _bseg.buzei   as Item,
      _bseg.kunnr   as Cliente,
      _bseg.hkont   as Conta,
      _bseg.gsber   as Divisao, 
      _bseg.zuonr   as Atribuicao,
      _bseg.sgtxt   as TextItem,
      _bseg.shkzg   as CredDeb,
      _bseg.bupla   as LocalNegocio,
      _bseg.prctr   as CentroLucro,
      _bseg.kostl   as CentroCusto,
      _bseg.segment as Segmento, 
      _MercExtHeader.Moeda,
      _MercExtHeader.CurrencyBRL,
      cast( ( cast( _bseg.wrbtr as abap.dec( 13, 3 ))  * _VendasItem.PriceDetnExchangeRate ) as abap.dec( 13, 2 ) ) as Valor ,
      
      case _bseg.shkzg
          when 'S' then 3
          when 'H' then 1
      end     as ValorCriticality,

      _MercExtHeader

}
