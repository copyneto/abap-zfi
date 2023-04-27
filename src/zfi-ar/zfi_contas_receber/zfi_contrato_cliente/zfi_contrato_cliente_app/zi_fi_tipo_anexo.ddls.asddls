@AbapCatalog.sqlViewName: 'ZV_TIPOANEXO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Tipo de Anexo - Contrato Cliente'
define view ZI_FI_TIPO_ANEXO
  as select from dd07t
{
      @ObjectModel.text.element: [ 'TipoDocText' ]
  key domvalue_l as TipoDoc,
      ddlanguage as Language,
      ddtext     as TipoDocText
}
where
      domname    = 'ZD_TIPO_ANEXO'
  and as4local   = 'A'
  and ddlanguage = $session.system_language
