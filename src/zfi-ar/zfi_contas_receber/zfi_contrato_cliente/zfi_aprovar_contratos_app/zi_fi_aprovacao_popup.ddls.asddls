@EndUserText.label: 'Pop UP - Observação da Aprovação'
@Metadata.allowExtensions: true
define abstract entity ZI_FI_APROVACAO_POPUP
{
  @EndUserText.label: 'Observação'
  @UI.multiLineText: true
  Observacao : ze_obs_aprov;
}
