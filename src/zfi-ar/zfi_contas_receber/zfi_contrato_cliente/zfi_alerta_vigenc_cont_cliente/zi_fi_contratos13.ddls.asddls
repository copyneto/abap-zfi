@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Alerta de Vigência Contratos Cliente'
define root view entity ZI_FI_CONTRATOS13 as select from ztfi_contratos13
association [0..1] to j_1bbrancht   as _LocalEmpresa on _LocalEmpresa.bukrs =  $projection.Empresa
                                                     and _LocalEmpresa.branch =  $projection.LocalNegocio
                                                     and _LocalEmpresa.language =  $session.system_language
association [0..1] to t001 as _Empresa on _Empresa.bukrs =  $projection.Empresa
                                       and _Empresa.spras =  $session.system_language                                                     
{
    key id                as Id,
    key empresa           as Empresa,
    key local_negocio     as LocalNegocio,
     email                as Email,
    _LocalEmpresa.name    as Nome,
    _Empresa.butxt        as Name1,   
    @Semantics.user.createdBy: true
    created_by            as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at            as CreatedAt,
    @Semantics.user.lastChangedBy: true
    last_changed_by       as LastChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at       as LastChangedAt,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt
}
