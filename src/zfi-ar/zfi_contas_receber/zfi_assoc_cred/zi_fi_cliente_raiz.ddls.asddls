@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Raiz CNPJ por Cliente'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_CLIENTE_RAIZ as select from ZI_FI_CLIENTE_RAIZ_U {
    key Cliente,
        RaizId,
        Nome
}
group by Cliente, RaizId, Nome

