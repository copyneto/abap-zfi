@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View para daddos de cobrança-boleto'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_BOLETO
  as select from bsid_view as Cobranca
{

  key Cobranca.bukrs as Empresa,
  key Cobranca.belnr as Documento,
  key Cobranca.gjahr as Ano,
  key Cobranca.buzei as Item,
      Cobranca.kunnr as Cliente,
      Cobranca.bupla as LocalNegocio,
      Cobranca.zlsch as FormaPgto,
      Cobranca.gsber as Divisao,
      Cobranca.hbkid as Banco,
      case Cobranca.xref3 when ''
          then 'Emitir'
          else 'Emitido'
      end            as xref3,
      xblnr,
      @Semantics.amount.currencyCode: 'WAERS' 
      Cobranca.wrbtr as Montante,
      Cobranca.waers as waers

}
where
      Cobranca.shkzg <> 'H'
  and ( Cobranca.zlsch = 'D' or Cobranca.zlsch = 'Z' )
  and Cobranca.hbkid <> ''
  and Cobranca.umskz <> 'R'
