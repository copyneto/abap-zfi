@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Denominação Coligadas por Empresa'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_DENM_COLIGADA_EMPRESA
  as select from ztfi_denm_coliga

  association [0..1] to ZI_CA_VH_BUKRS  as _Bukrs   on  _Bukrs.Empresa = $projection.Bukrs

  association [0..1] to ZI_CA_VH_BRANCH as _Branch  on  _Branch.CompanyCode   = $projection.Bukrs
                                                    and _Branch.BusinessPlace = $projection.Branch

  association [0..1] to ZI_CA_VH_USER   as _UserCre on  _UserCre.Bname = $projection.CreatedBy

  association [0..1] to ZI_CA_VH_USER   as _UserMod on  _UserMod.Bname = $projection.LastChangedBy

{
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_BUKRS', element: 'Empresa' }}]
  key bukrs                 as Bukrs,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_BRANCH', element: 'BusinessPlace' },
                                 additionalBinding: [{ element: 'CompanyCode', localElement: 'Bukrs' }]}]

  key branch                as Branch,
  key chave                 as Chave,
      conteudo              as Conteudo,
      descricao             as Descricao,
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
      _Branch,
      _UserCre,
      _UserMod
}
