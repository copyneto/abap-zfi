@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Aplicativo Banco Empresa do Fornecedor'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_BANCO_EMPRESA_APP
  as select from ztfi_banco_empr as Tab

  association        to ZI_CA_VH_BUKRS as _Bukrs   on  _Bukrs.Empresa = $projection.Bukrs
  association        to ZI_CA_VH_BANK  as _Bank    on  _Bank.BanKey = $projection.Banco
  association        to ZI_CA_VH_HBKID as _Hbkid   on  _Hbkid.Empresa      = $projection.Bukrs
                                                   and _Hbkid.BancoEmpresa = $projection.Hbkid
  association        to ZI_CA_VH_HKTID as _Hktid   on  _Hktid.Bukrs = $projection.Bukrs
                                                   and _Hktid.Hbkid = $projection.Hbkid
                                                   and _Hktid.Hktid = $projection.HKtid
  association [0..1] to ZI_CA_VH_USER  as _UserCre on  _UserCre.Bname = $projection.CreatedBy
  association [0..1] to ZI_CA_VH_USER  as _UserMod on  _UserMod.Bname = $projection.LastChangedBy
{
  key bukrs                 as Bukrs,
  key banco                 as Banco,
      hbkid                 as Hbkid,
      hktid                 as HKtid,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Bukrs,
      _Bank,
      _Hbkid,
      _Hktid,
      _UserCre,
      _UserMod

}
