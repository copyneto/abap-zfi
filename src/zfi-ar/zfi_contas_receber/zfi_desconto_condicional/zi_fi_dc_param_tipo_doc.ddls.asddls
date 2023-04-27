@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de documento'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_DC_PARAM_TIPO_DOC
  as select from ztca_param_val
{
  key cast( low as blart ) as AccountingDocumentType
}
where
      modulo = 'FI-AR'
  and chave1 = 'PDC'
  and chave2 = 'SELECIONA'
  and chave3 = 'TIPODOC'
  and sign   = 'I'
  and opt    = 'EQ'
  and low    is not initial

group by
  low
