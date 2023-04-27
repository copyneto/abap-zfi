@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Regut last creation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #XL,
  dataClass: #MIXED
}
define view entity zi_regut_last_creation
  as select from regut
{
  key zbukr,
  key laufd,
  key laufi,
  key xvorl,
      max(tsdat) as tsdat,
      max(tstim) as tstim,
      max(dwdat) as dwdat
}
group by
  zbukr,
  laufd,
  laufi,
  xvorl
