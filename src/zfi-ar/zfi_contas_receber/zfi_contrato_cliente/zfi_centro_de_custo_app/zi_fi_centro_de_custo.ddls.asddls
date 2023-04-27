@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Centro de custo - Cadastro'
define root view entity ZI_FI_CENTRO_DE_CUSTO
  as select from ztfi_cad_cc

  association [0..1] to ZI_CA_VH_BZIRK as _Region on  $projection.Region = _Region.RegiaoVendas
  association [0..1] to ZI_CA_VH_BUKRS as _Bukrs  on  $projection.Bukrs = _Bukrs.Empresa
  association [0..1] to ZI_FI_VH_GSBER as _Gsber  on  $projection.Gsber = _Gsber.Gsber
  association [0..1] to I_CostCenterVH as _Cost   on  $projection.Kostl     = _Cost.CostCenter
                                                  and _Cost.ControllingArea = 'AC3C'

{
  key bukrs                    as Bukrs,
  key gsber                    as Gsber,
  key region                   as Region,
      kostl                    as Kostl,
      _Region.RegiaoVendasText as RegionTxt,
      _Bukrs.EmpresaText       as EmpresaTxt,
      _Gsber.Gtext             as GsberTxt,
      _Cost.CostCenterName     as CostCenterTxt,
      @Semantics.user.createdBy: true
      created_by               as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at               as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by          as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt
}
