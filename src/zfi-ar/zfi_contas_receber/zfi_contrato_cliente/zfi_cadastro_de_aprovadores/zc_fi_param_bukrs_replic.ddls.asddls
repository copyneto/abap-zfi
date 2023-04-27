@EndUserText.label: 'Empresa para replicar'
@Metadata.allowExtensions: true
define abstract entity ZC_FI_PARAM_BUKRS_REPLIC
{

  @Consumption.valueHelpDefinition: [{
               entity: {
                   name: 'I_CompanyCodeVH',
                   element: 'CompanyCode'
               }
           }]
  bukrs_rep : bukrs;

}
