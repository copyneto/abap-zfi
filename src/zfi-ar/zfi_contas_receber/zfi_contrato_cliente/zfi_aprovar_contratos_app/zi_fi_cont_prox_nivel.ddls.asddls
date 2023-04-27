@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Proximos Niveis de Aprovação'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CONT_PROX_NIVEL
  as select from ZI_FI_PROXIMO_NIV_APROV

  association        to parent ZI_FI_CONT_APROVACAO as _Contrato on  $projection.DocUuidH = _Contrato.DocUuidH
                                                                 and $projection.Contrato = _Contrato.Contrato
                                                                 and $projection.Aditivo  = _Contrato.Aditivo
                                                                 
  association [0..1] to I_CompanyCodeVH             as _Emp      on  $projection.Bukrs = _Emp.CompanyCode
  association [0..1] to ZI_CA_VH_BRANCH             as _Branch   on  _Branch.CompanyCode   = $projection.Bukrs
                                                                 and _Branch.BusinessPlace = $projection.Branch
{
  key DocUuidH,
  key Contrato,
  key Aditivo,
      Nivel,
      Bukrs,
      _Emp.CompanyCodeName      as CompanyCodeName,
      Branch,
      _Branch.BusinessPlaceName as BusinessPlaceName,
      Bname,
      Email,
      DescNivel,
      
      _Contrato
}
