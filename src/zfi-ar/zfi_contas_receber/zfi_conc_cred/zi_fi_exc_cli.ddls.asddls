@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Interface Exclusão de Clientes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_EXC_CLI 
    as select from ztfi_exc_cli 
    association [0..1] to ZI_CA_VH_CUSTOMER as _Customer  on  $projection.kunnr = _Customer.Customer
{
    key kunnr ,
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
        
        _Customer
}
