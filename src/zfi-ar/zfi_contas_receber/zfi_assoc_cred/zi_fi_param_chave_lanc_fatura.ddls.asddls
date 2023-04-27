@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Parâmetros de Chaves de Lanç. de Fatura'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_PARAM_CHAVE_LANC_FATURA
  as select from ztca_param_val
{
  key modulo,
  key chave1,
  key chave2,
  key chave3,
  key cast( low as bschl ) as ChaveLancamento
}
where
      modulo = 'FI-AR'
  and chave1 = 'PDC'
  and chave2 = 'BSCHL'
  and chave3 = 'FATU'
