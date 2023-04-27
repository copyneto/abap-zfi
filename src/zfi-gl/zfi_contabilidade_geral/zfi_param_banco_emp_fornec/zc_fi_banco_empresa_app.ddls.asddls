@EndUserText.label: 'Aplicativo Banco Empresa do Fornecedor'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_BANCO_EMPRESA_APP
  as projection on ZI_FI_BANCO_EMPRESA_APP
{
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_BUKRS', element: 'Empresa' }}]
      @ObjectModel.text.element: ['EmpText']
  key Bukrs,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_BANK', element: 'BanKey' }}]
      @ObjectModel.text.element: ['BankText']
  key Banco,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_HBKID', element: 'BancoEmpresa' },
                                           additionalBinding: [{ element: 'Empresa', localElement: 'Bukrs' }]} ]
      @ObjectModel.text.element: ['BancEmpText']
      Hbkid,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZI_CA_VH_HKTID', element: 'Hktid' },
                                           additionalBinding: [{ element: 'Bukrs', localElement: 'Bukrs' },
                                                               { element: 'Hbkid', localElement: 'Hbkid' }]} ]
      @ObjectModel.text.element: ['HktidText']
      HKtid,
      @ObjectModel.text.element: ['CreaName']
      CreatedBy,
      CreatedAt,
      @ObjectModel.text.element: ['ModName']
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _Bukrs.EmpresaText      as EmpText,
      _Bank.BankName          as BankText,
      _Hbkid.BancoEmpresaText as BancEmpText,
      _Hktid.Text1            as HktidText,
      _UserCre.Text           as CreaName,
      _UserMod.Text           as ModName


}
