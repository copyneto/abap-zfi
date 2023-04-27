@AbapCatalog.sqlViewName: 'ZFIVHSTATUS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Value Help status log'
@ObjectModel.resultSet.sizeCategory: #XS
define view ZI_FI_VH_STATUS_LOG
  as select from dd07t
{
      @UI.hidden: true
  key domname    as Domname,
      @UI.hidden: true
  key ddlanguage as Ddlanguage,
      @UI.hidden: true
  key as4local   as As4local,
      @UI.hidden: true
  key valpos     as Valpos,
      @UI.hidden: true
  key as4vers    as As4vers,

      @ObjectModel.text.element: ['StatusText']
  key domvalue_l as Status,
      @Semantics.text: true
      ddtext     as StatusText

}
where
  domname = 'ZD_FI_STATUS'
