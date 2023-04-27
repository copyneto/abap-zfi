@AbapCatalog.sqlViewName: 'ZVFUFORDOC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Documento Fornecedor'
define view ZI_FI_FORN_DOC
  as select from rbkp as _R

    inner join   lfa1 as _For on _R.lifnr = _For.lifnr

{

  key belnr      as Belnr,
  key gjahr      as Gjahr,
      xblnr      as Xblnr,
      _R.lifnr   as lifnr,
      _For.name1 as Name1
}
