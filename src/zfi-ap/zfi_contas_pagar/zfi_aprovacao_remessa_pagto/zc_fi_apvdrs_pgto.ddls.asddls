@EndUserText.label: 'Gestão de Aprovadores de Pagamento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true


define root view entity ZC_FI_APVDRS_PGTO
  as projection on ZI_FI_APVDRS_PGTO
{
      @Consumption.valueHelpDefinition: [{ entity: { element: 'CompanyCode', name: 'C_CompanyCodeValueHelp' } }]
      @ObjectModel.text.element: ['TextoEmpresa']
  key Empresa,
      @Consumption.valueHelpDefinition: [{ entity: { element: 'bname', name: 'P_USER_ADDR' } }]
      @ObjectModel.text.element: ['TextoUsuario']
  key Usuario,
      @Consumption.valueHelpDefinition: [{ entity: { element: 'DomvalueL', name: 'ZI_FI_VH_NIVEL_APROV' } }]
      @ObjectModel.text.element: ['TextoNivel']
   Nivel,
      DataInicio,
      DataFim,
      //Controle
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      //Associações para texto
      TextoEmpresa,
      TextoUsuario,
      TextoNivel


}
