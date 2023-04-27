@EndUserText.label: 'Projection da conta de contrapartida'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity zc_fi_defrece_hkoncontra as projection on ZI_fi_defrece_hkoncontra {
    key HkontFrom,
    @EndUserText.label: 'Conta de Contra Partida'
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_FI_DEFRECE_LHKONT', element: 'saknr'  } }]
    key HkontContra,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
   _DEFRECE_HKONT: redirected to parent ZC_FI_DEFRECE_HKONT
}
