@EndUserText.label: 'Proximos Niveis de Aprovação'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CONT_PROX_NIVEL as projection on ZI_FI_CONT_PROX_NIVEL {
    key DocUuidH,
    key Contrato,
    key Aditivo,
    Nivel,
    Bukrs,
    CompanyCodeName,
    Branch,
    BusinessPlaceName,
    Bname,
    Email,
    DescNivel,
    /* Associations */
    _Contrato : redirected to parent ZC_FI_CONT_APROVACAO
}
