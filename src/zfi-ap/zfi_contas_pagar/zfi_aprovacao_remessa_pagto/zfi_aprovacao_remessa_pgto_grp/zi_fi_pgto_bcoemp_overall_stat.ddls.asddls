@AbapCatalog.sqlViewName: 'ZVFIBCOEMPOVRS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Status'
define view ZI_FI_PGTO_BCOEMP_OVERALL_STAT
  as select from ZI_FI_PROG_PAGAMENTO_P
{
      //  key CompanyCode,
      //  key CashPlanningGroup,
  key HouseBank,
  key PaymentMethod,
  key NetDueDate,
      max( case when encerrador = 'X' and aprov1 = 'X' and aprov2 = 'X' and aprov3 = 'X'
                then 3
           else case when encerrador is initial and aprov1 is initial and aprov2 is initial and aprov3 is initial
                     then 0
                     else 2
                end
           end ) as Status
}
group by
//  CompanyCode,
//  CashPlanningGroup,
  HouseBank,
  PaymentMethod,
  NetDueDate
