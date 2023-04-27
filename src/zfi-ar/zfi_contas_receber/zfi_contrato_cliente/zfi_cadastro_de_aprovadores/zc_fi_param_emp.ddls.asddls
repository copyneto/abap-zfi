@EndUserText.label: 'Botão de Contabilizar'
@Metadata.allowExtensions: true
define abstract entity ZC_FI_PARAM_EMP
{

  @Consumption.valueHelpDefinition: [{
               entity: {
                   name: 'I_CompanyCodeVH',
                   element: 'CompanyCode'
               }
           }]
  @EndUserText.label: 'Empresa2'
  Empresa : bukrs;

}
