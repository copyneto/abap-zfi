@EndUserText.label: 'Reversão da Provisão (Popup)'
define abstract entity ZI_FI_REVERSAO_PROVISAO_POPUP
{
  @EndUserText.label    : 'Reversão'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_FI_VH_REVERSAO_PDC', element: 'RevertType' } } ]
  key RevertType   : ze_fi_revert_pdc;
  @EndUserText.label: 'Data do Documento'
  DocumentDate : fis_bldat;
  @EndUserText.label: 'Data de Lançamento'
  PostingDate  : fis_budat;

}
