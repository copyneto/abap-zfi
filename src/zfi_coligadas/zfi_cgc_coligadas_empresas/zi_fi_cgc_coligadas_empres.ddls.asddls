@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CGC das Coligadas por Empresa'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_CGC_COLIGADAS_EMPRES
  as select from ztfi_cgc_coligad

  association [0..1] to ZI_CA_VH_BUKRS as _Bukrs   on  _Bukrs.Empresa = $projection.Bukrs

  association [0..1] to ZI_CA_VH_BUPLA as _Bupla   on  _Bupla.Bukrs  = $projection.Bukrs
                                                   and _Bupla.Branch = $projection.Bupla

  association [0..1] to ZI_CA_VH_KUNNR as _Kunnr   on  _Kunnr.Kunnr = $projection.Kunnr

  association [0..1] to ZI_CA_VH_LIFNR as _Lifnr   on  _Lifnr.LifnrCode = $projection.Lifnr

  association [0..1] to ZI_CA_VH_VKORG as _Vkorg   on  _Vkorg.OrgVendas = $projection.Vkorg

  association [0..1] to ZI_CA_VH_KUNNR as _Client  on  _Client.Kunnr = $projection.ColCi

  association [0..1] to ZI_CA_VH_USER  as _UserCre on  _UserCre.Bname = $projection.CreatedBy

  association [0..1] to ZI_CA_VH_USER  as _UserMod on  _UserMod.Bname = $projection.LastChangedBy

{
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_BUKRS', element: 'Empresa' }}]
  key bukrs                 as Bukrs,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_BUPLA', element: 'Branch' },
                                 additionalBinding: [{ element: 'Bukrs', localElement: 'Bukrs' }]}]
  key bupla                 as Bupla,
  key cgc                   as Cgc,

      case when cgc is initial or cgc is null then ''
         else concat( substring(cgc, 1, 2),
              concat( '.',
              concat( substring(cgc, 3, 3),
              concat( '.',
              concat( substring(cgc, 6, 3),
              concat( '/',
              concat( substring(cgc, 9, 4),
              concat( '-',  substring(cgc, 13, 2) ) ) ) ) ) ) ) )
      end                   as CNPJText,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_KUNNR', element: 'Kunnr' }}]
      kunnr                 as Kunnr,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_LIFNR', element: 'LifnrCode' }}]
      lifnr                 as Lifnr,
      filial                as Filial,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_VKORG', element: 'OrgVendas' }}]
      vkorg                 as Vkorg,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_KUNNR', element: 'Kunnr' }}]
      col_ci                as ColCi,
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
      _Bupla,
      _Kunnr,
      _Lifnr,
      _Vkorg,
      _Client,
      _UserCre,
      _UserMod
}
