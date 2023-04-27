@AbapCatalog.sqlViewName: 'ZI_FI_CALC_TOT_U'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Calcular Totais Créditos/Faturas'
define view ZI_FI_CALCULA_TOTAIS as select from ZI_FI_GROUP_CREDITOS_CLI as Grp {
  Grp.Empresa        as Empresa,
  Grp.Cliente        as Cliente,
  Grp.RaizId         as RaizId,
  Grp.RaizSn         as RaizSn,
  Grp.TotalCreditos  as TotalCreditos,
  Grp.TotalResidual  as TotalResidual,
  Grp.TotalFatura    as TotalFatura

} union select from ZI_FI_GROUP_CREDITOS_CLI as Grp
  inner join ZI_FI_SOMA_CREDITO as Cred on Cred.empresa = Grp.Empresa {
  Grp.Empresa        as Empresa,
  Cred.cliente        as Cliente,
  Cred.raizid         as RaizId,
  Cred.raizsn         as RaizSn,
  Cred.TotalCreditos  as TotalCreditos,
  Cred.TotalResidual  as TotalResidual,
  Cred.TotalFatura    as TotalFatura
} union  select from ZI_FI_GROUP_CREDITOS_CLI as Grp
 inner join ZI_FI_SOMA_FATURA as Fat on Fat.empresa = Grp.Empresa
{
  Grp.Empresa       as Empresa,
  Fat.cliente        as Cliente,
  Fat.raizid         as RaizId,
  Fat.raizsn         as RaizSn,
  Fat.TotalCreditos  as TotalCreditos,
  Fat.TotalResidual  as TotalResidual,
  Fat.TotalFatura    as TotalFatura
}
