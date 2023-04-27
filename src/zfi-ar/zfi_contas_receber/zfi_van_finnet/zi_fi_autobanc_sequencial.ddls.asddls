@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Autom. bancária - sequencial do arquivo'
define root view entity ZI_FI_AUTOBANC_SEQUENCIAL
  as select from ztfi_autbanc_seq
{
  key banco as Banco,
  key data  as Data,
      seq   as Seq
}
