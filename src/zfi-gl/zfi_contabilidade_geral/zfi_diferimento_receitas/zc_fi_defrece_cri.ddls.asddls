@EndUserText.label: 'Difer Rec e Deduções Critério de Seleção'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_DEFRECE_CRI as projection on ZI_FI_DEFRECE_CRI {
    @ObjectModel.text.element: ['CompanyCodeName']
    @Consumption.valueHelpDefinition: [{ entity : {name: 'I_CompanyCode', element: 'CompanyCode'  } }]
    key Bukrs,
    @ObjectModel.text.element: ['RegionFromName']
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_FI_DEFRECE_ORIG', element: 'Region'  } }]
    key RegioFrom,
    @ObjectModel.text.element: ['RegionToName']
    @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_FI_DEFRECE_ORIG', element: 'Region'  } }]
    key RegioTo,
    Preventr,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    _CompanyCode.CompanyCodeName,
    _RegionFrom,
    _RegionTo,
    _RegionTo.RegionName as RegionToName,
    _RegionFrom.RegionName as RegionFromName 
    
   
}
