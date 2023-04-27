@EndUserText.label: 'CDS Abstrata - Pop-up contabilização'
@Metadata.allowExtensions: true
define abstract entity ZI_FI_CONTAB_POPUP
{
  @Consumption.filter:{ mandatory:true }
  DataLanc    : datum;
  DataEstorno : datum;

}
