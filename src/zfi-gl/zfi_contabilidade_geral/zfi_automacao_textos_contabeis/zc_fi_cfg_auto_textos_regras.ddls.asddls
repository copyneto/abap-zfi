@EndUserText.label: 'Proj Regras Automação textos contábeis'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_FI_CFG_AUTO_TEXTOS_REGRAS
  as projection on ZI_FI_CFG_AUTO_TEXTOS_REGRAS
{
  key IdRegra,
      Regra,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_VH_COMPANY', element: 'CompanyCode' }  } ]
      Bukrs,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_VH_DOCTYPE', element: 'DocType' }  } ]
      Blart,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_SAKNR_PC3C', element: 'GLAccount' } } ]
      Hkont,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_CA_VH_BSCHL', element: 'PostingKey' }  } ]
      Bschl,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_TREASURYUPDATETYPE', element: 'TreasuryUpdateType' }  } ]
      Dis_flowty,
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_FI_VH_FIINSTRPRODTTYPE', element: 'FinancialInstrumentProductType' }  } ]
      Gsart,
      TextoFixo,
      Descricao,
      RegraLabel,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Campos          : redirected to composition child ZC_FI_CFG_AUTO_TEXTOS_CAMPOS,
      _Empresa         : redirected to composition child ZC_FI_CFG_AUTOTXT_CRIT_EMPRESA,
      _TipoDocumento   : redirected to composition child ZC_FI_CFG_AUTOTXT_CRIT_TIPODOC,
      _ContaContabil   : redirected to composition child ZC_FI_CFG_AUTOTXT_CRIT_CONTA,
      _ChaveLancto     : redirected to composition child ZC_FI_CFG_AUTOTXT_CRIT_CHAVE,
      _TipoAtualizacao : redirected to composition child ZC_FI_CFG_AUTOTXT_CRIT_FLOWTP,
      _TipoProduto     : redirected to composition child ZC_FI_CFG_AUTOTXT_CRIT_PRODTP

}
