@EndUserText.label: 'Difer Rec e Deduções (De/Para Contas)'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_DEFRECE_HKONT as projection on ZI_FI_DEFRECE_HKONT 

{
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_FI_DEFRECE_LHKONT', element: 'saknr'  } }]
    key HkontFrom,
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_FI_DEFRECE_LHKONT', element: 'saknr'  } }]
    HkontTo,   
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_DEFRECE_VH_TYP', element: 'DomvalueL' } }]    
    Tpcnt,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    displayContraPartida,
    _hkoncontra: redirected to composition child zc_fi_defrece_hkoncontra
    
}
