@AbapCatalog.sqlViewName: 'ZV_TVK2T'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Value Help - TVK2T'
define view ZI_FI_ATRIBUTE2_CMASTER as select from tvk2t {
    key katr2 as Id,
    vtext as Text
} where spras = $session.system_language
