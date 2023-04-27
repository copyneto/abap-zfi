@EndUserText.label: 'Parâmetros Concessão de Crédito'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_CONC_CRED
  as projection on ZI_FI_CONC_CRED
{
            @Consumption.valueHelpDefinition: [{entity: {name: 'I_COMPANYCODEVH', element: 'CompanyCode' }}]
  key       Empresa,
            @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_DOCTYPE', element: 'DocType' }}]
  key       TipoDoc,
            @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_BSCHL', element: 'PostingKey' }}]
  key       ChaveLanc,
            @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_FI_VH_IDENT', element: 'Identificacao' }}]
  key       Identificacao,
            @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_CA_VH_ZLSCH', element: 'FormaPagamento' }}]
  key       FormaPgto,
            @Consumption.valueHelpDefinition: [{entity: {name: 'ZI_FI_VH_ORIG', element: 'Origem' }}]
            Origem,
            DiasMin,
            moeda,
            ResidualMin,
            CreatedBy,
            CreatedAt,
            LastChangedBy,
            LastChangedAt,
            LocalLastChangedAt
}
