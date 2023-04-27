@EndUserText.label: 'Popup Venc. Cliente'
@Metadata.allowExtensions: true
define abstract entity ZI_FI_VENC_F01_POPUP
{
  novaDataVenc  : datum;
  motivoProrrog : abap.char( 2 );
  observ        : abap.char( 100 );
}
