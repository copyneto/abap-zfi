@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Autom. bancária - arquivos processados'
define root view entity ZI_FI_AUTOBANC_PROCFILE
  as select from ztfi_autbanc_prc
{
  key laufd                 as PaymentRunDate,
  key laufi                 as PaymentRunID,
  key xvorl                 as PaymentRunIsProposal,
  key zbukr                 as PayingCompanyCode,
  key lifnr                 as Supplier,
  key kunnr                 as Customer,
  key empfg                 as PaymentRecipient,
  key vblnr                 as PaymentDocument,
      diretorio             as Diretorio,
      type                  as Type,
      message               as Message,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt

}
