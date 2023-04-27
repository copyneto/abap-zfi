@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Log de Aprovação dos Pagamentos'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_LOG_APV_PGTO
  as select from ZI_FI_LOG_APV_PGTO_H as _Log
  association to I_CompanyCode           as _Empresa on _Empresa.CompanyCode = $projection.Empresa
  association to ZI_FI_VH_TIPOREL        as _TpRel   on _TpRel.Value = $projection.TipoRelatorio
  composition of ZI_FI_LOG_APV_PGTO_ITEM as _Item
  
{
      @ObjectModel.text.element: ['CompanyCodeName']
  key _Log.Bukrs   as Empresa,
  key _Log.Data,
      @ObjectModel.text.element: ['Text']
  key _Log.Tiporel as TipoRelatorio,
  key _Log.Hora    as Hora,
  key _Log.Fdgrv   as GrpTesouraria,
      _Log.Fdgrv    as Fdgrv,

      @Semantics.amount.currencyCode: 'Moeda'
      _Log.Valor,
      Moeda,
      _Log.Encerrador,
      _Log.Aprov1,
      _Log.Aprov2,
      _Log.Aprov3,

      _Empresa.CompanyCodeName,
      _TpRel.Text,

      _Empresa,
      _TpRel,

      _Item
}
