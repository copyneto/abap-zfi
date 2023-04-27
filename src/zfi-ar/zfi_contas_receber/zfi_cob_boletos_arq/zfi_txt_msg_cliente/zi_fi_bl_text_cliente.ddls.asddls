@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Texto Mensagem do Cliente Boleto'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_BL_TEXT_CLIENTE
  as select from ztfi_blt_txtclnt

  association [0..1] to P_HouseBankAccountText as _Bank     on  $projection.Bukrs = _Bank.bukrs
                                                            and $projection.Hbkid = _Bank.hbkid
                                                            and 'P'               = _Bank.spras
  association [0..1] to t001                   as _T001     on  $projection.Bukrs = _T001.bukrs
  association [0..1] to kna1                   as _Customer on  $projection.Kunnr = _Customer.kunnr
{
      @EndUserText.label: 'Empresa'
  key bukrs                 as Bukrs,
      @EndUserText.label: 'Cliente'
  key kunnr                 as Kunnr,
      @EndUserText.label: 'Banco Empresa'
  key hbkid                 as Hbkid,
      @EndUserText.label: 'Texto Msg do Cliente'
      text                  as Text,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDate.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDate.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Bank,
      _T001,
      _Customer
}
