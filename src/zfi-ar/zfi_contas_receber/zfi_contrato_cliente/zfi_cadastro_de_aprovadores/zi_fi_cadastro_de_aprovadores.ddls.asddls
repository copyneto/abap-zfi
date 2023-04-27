@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Configurar Níveis Aprovação e Usuário'
@AbapCatalog.viewEnhancementCategory: [#NONE]

define root view entity ZI_FI_CADASTRO_DE_APROVADORES
  as select from ztfi_cad_aprovad
  association [0..1] to I_CompanyCodeVH              as _Company       on $projection.Bukrs = _Company.CompanyCode
  association [0..1] to ZI_FI_VH_NIVEIS_DE_APROVACAO as _Niveis        on $projection.Nivel = _Niveis.Nivel
  association [0..1] to ZI_CA_VH_BRANCH              as _BusinessPlace on $projection.Branch = _BusinessPlace.BusinessPlace

{

  key nivel                            as Nivel,
  key bname                            as Bname,
  key bukrs                            as Bukrs,
  key branch                           as Branch,
      _Company.CompanyCodeName         as CompanyCodeName,
      _Niveis.Descricao                as DescNivel,
      _BusinessPlace.BusinessPlaceName as BusinessPlaceName,
      email                            as Email,
      @Semantics.user.createdBy: true
      created_by                       as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                       as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                  as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                  as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at            as LocalLastChangedAt
}
