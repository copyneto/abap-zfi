@EndUserText.label: 'Carga de Contratos Header'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_CARGA_CONTRATOH 
as projection on ZI_FI_CARGA_CONTRATOH 
{
    key DocUuidH,
    Documentno,
    DataCarga,
    TipoCarga,
//    TipoCargaText,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt
    /* Associations */
//    _Carga
}
