@EndUserText.label: 'Popup Simular Contrato Cliente'
@Metadata.allowExtensions: true
define abstract entity zc_fi_simular_contrato_cliente
{
@ObjectModel.mandatory: true
  DataIniValid : dats;
  @ObjectModel.mandatory: true
  DataFimValid : dats;
}
