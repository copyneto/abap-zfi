@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Filtro de Documentos Z021'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_MERC_EXT_FLT_PREC
  as select from vbfa
    inner join   vbak on  vbak.vbeln = vbfa.vbelv
                      and vbak.auart = 'Z021'
{

  key vbfa.vbeln,
      vbfa.vbelv,
      vbak.zz1_dataem_sdh
}
where
  vbfa.vbtyp_v = 'C'
