@AccessControl.authorizationCheck: #CHECK
@AbapCatalog.viewEnhancementCategory: [#NONE]
@EndUserText.label: 'Cnpj Raiz'
@Metadata.allowExtensions: true
define view entity ZI_FI_RAIZ_CNPJ_CONT
  as select from ztfi_raiz_cnpj as _Raiz

  association to parent ZI_FI_CONTRATO      as _Contrato on $projection.DocUuidH = _Contrato.DocUuidH
  composition [0..*] of ZI_FI_CLIENTES_CONT as _Clientes

{
  key doc_uuid_h            as DocUuidH,
  key doc_uuid_raiz         as DocUuidRaiz,
      cnpj_raiz             as CnpjRaiz,
      _Contrato.Contrato    as Contrato,
      _Contrato.Aditivo     as Aditivo,
      razao_soci            as RazaoSoci,
      nome_fanta            as NomeFanta,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Contrato,
      _Clientes
}
