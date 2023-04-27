@EndUserText.label: 'Carga Contabilização - Itens'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_CARGA_ITEM
  as projection on zi_fi_carga_item
{
  key DocUuidH,
  key DocUuidDoc,
  key NumeroDoc,
  key DocUuidItem,
      NumeroItem,
      Shkzg,
      Zuonr,
      Hkont,
      Dmbtr,
      Waers,
      Bupla,
      Gsber,
      Kostl,
      Prctr,
      Segment,
      Sgtxt,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _H : redirected to parent ZC_FI_CARGA_H
}
