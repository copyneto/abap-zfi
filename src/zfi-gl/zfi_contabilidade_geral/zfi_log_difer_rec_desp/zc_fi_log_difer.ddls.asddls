@EndUserText.label: 'Log de Diferimento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true

root view entity zc_fi_log_difer
  as projection on zi_fi_log_difer
{
  key IntNum,
      Empresa,
      NumrDoc,
      Ano,
      DataLanc,
      Hora,
      Message
}
