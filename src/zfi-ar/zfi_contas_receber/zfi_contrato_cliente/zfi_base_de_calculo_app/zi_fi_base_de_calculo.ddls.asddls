@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Base de Cálculo'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
    }
define view entity ZI_FI_BASE_DE_CALCULO
  as select from ztfi_calc_cresci as _Cresci

  association        to parent ZI_FI_CONTRATO_BASE as _Contrato on  _Contrato.Contrato = $projection.Contrato
                                                                and _Contrato.Aditivo  = $projection.Aditivo

  association [0..1] to ZI_CA_VH_BUKRS             as _Empresa  on  _Empresa.Empresa = $projection.Bukrs
  association [0..1] to ZI_CA_VH_VTWEG             as _Canal    on  _Canal.CanalDistrib = $projection.Vtweg
  association [0..1] to ZI_CA_VH_BSCHL             as _Posting  on  _Posting.PostingKey = $projection.Bschl
  association [0..1] to ZI_CA_VH_ZLSCH             as _FormaP   on  _FormaP.FormaPagamento = $projection.Zlsch
  association [0..1] to ZI_CA_VH_SPART             as _SetorA   on  _SetorA.SetorAtividade = $projection.Spart
  association [0..1] to ZI_CA_VH_BZIRK             as _RegiaoV  on  _RegiaoV.RegiaoVendas = $projection.Bzirk
  association [0..1] to ZI_CA_VH_KATR2             as _katr2    on  _katr2.katr2 = $projection.Katr2

  association [0..1] to bkpf                       as _bkpf     on  _bkpf.belnr = $projection.Belnr
                                                                and _bkpf.bukrs = $projection.Bukrs
                                                                and _bkpf.gjahr = $projection.Gjahr

{

  key    _Cresci.contrato                                   as Contrato,
  key    _Cresci.aditivo                                    as Aditivo,
  key    _Cresci.bukrs                                      as Bukrs,
  key    _Cresci.belnr                                      as Belnr,
  key    _Cresci.gjahr                                      as Gjahr,
  key    _Cresci.buzei                                      as Buzei,
         @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_FI_VH_AJUSTE_ANUAL', element: 'XFLD' } }]
  key    _Cresci.ajuste_anual                               as AjusteAnual,
  key    _Cresci.gsber                                      as Gsber,
  key    _Cresci.familia_cl                                 as FamiliaCl,
  key    _Cresci.chave_manual                               as ChaveManual,
         _Cresci.tipo_comparacao                            as TipoComparacao,
         _Cresci.perid_avaliado                             as PeridAvaliado,
         _Cresci.ciclo                                      as Ciclo,
         _Cresci.exerc_anter                                as Exerc_anter,
         _Cresci.exerc_atual                                as Exerc_atual,

         _bkpf.waers                                        as Moeda,
         @Semantics.amount.currencyCode: 'Moeda'
         _Cresci.wrbtr                                      as Wrbtr,
         //         _Cresci.wrbtr as abap.dec( 11,2 ))            as Wrbtr,
         @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_VTWEG', element: 'PostingKey' } }]
         _Cresci.bschl                                      as Bschl,
         _Cresci.blart                                      as Blart,
         _Cresci.zuonr                                      as Zuonr,
         _Cresci.kunnr                                      as Kunnr,
         @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_ZLSCH', element: 'FormaPagamento' } }]
         _Cresci.zlsch                                      as Zlsch,
         _Cresci.sgtxt                                      as Sgtxt,
         _Cresci.netdt                                      as Netdt,
         _Cresci.xblnr                                      as Xblnr,
         _Cresci.budat                                      as Budat,
         _Cresci.bldat                                      as Bldat,
         _Cresci.augbl                                      as Augbl,
         _Cresci.augdt                                      as Augdt,
         _Cresci.vbeln                                      as Vbeln,
         _Cresci.posnr                                      as Posnr,
         _Cresci.vgbel                                      as Vgbel,
         @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_VTWEG', element: 'CanalDistrib' } }]
         _Cresci.vtweg                                      as Vtweg,
         @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_SPART', element: 'SetorAtividade' } }]
         _Cresci.spart                                      as Spart,
         @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_BZIRK', element: 'RegiaoVendas' } }]
         _Cresci.bzirk                                      as Bzirk,
         @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_KATR2', element: 'katr2' } }]
         _Cresci.katr2                                      as Katr2,
         _Cresci.wwmt1                                      as Wwmt1,
         _Cresci.prctr                                      as Prctr,
         _Cresci.tipo_entrega                               as TipoEntrega,
         _Cresci.xref1_hd                                   as Xref1Hd,
         _Cresci.status_dde                                 as StatusDde,
         _Cresci.tipo_apuracao                              as TipoApuracao,
         _Cresci.tipo_ap_imposto                            as TipoApImposto,
         _Cresci.tipo_imposto                               as TipoImposto,
         @EndUserText.label: 'Montante do Imposto Desconsiderado'
         cast(_Cresci.impost_desconsid as abap.dec( 11,2 )) as ImpostDesconsid,
         @EndUserText.label: 'Montante Líquido Impostos'
         cast(_Cresci.mont_liq_tax  as abap.dec( 11,2 ))    as MontLiqTax,
         @EndUserText.label: 'Montante Válido'
         cast(_Cresci.mont_valido  as abap.dec( 11,2 ))     as MontValido,
         _Cresci.tipo_desconto                              as TipoDesconto,
         _Cresci.cond_desconto                              as CondDesconto,
         _Cresci.kostl                                      as Kostl,
         @EndUserText.label: 'Montante Bônus'
         cast(_Cresci.mont_bonus  as abap.dec( 11,2 ))      as MontBonus,
         @EndUserText.label: 'Bônus Calculado'
         cast(_Cresci.bonus_calculado as abap.dec( 11,2 ))  as BonusCalculado,
         @EndUserText.label: 'Observação'
         _Cresci.obs_ajuste                                 as ObsAjuste,
         //         contrato                                   as NewContrato,
         //         aditivo                                    as NewAditivo,
         @Consumption.valueHelpDefinition:   [{ entity: {name: 'ZI_CA_VH_BUKRS', element: 'Empresa' } }]
         _Cresci.bukrs                                      as NewBukrs,
         _Cresci.belnr                                      as NewBelnr,
         @Consumption.valueHelpDefinition:   [{ entity: {name: 'C_FiscalYearForCompanyCodeVH', element: 'FiscalYear' } }]
         _Cresci.gjahr                                      as NewGjahr,
         _Cresci.buzei                                      as NewBuzei,
         _Cresci.ajuste_anual                               as NewAjusteAnual,
         _Cresci.gsber                                      as NewGsber,
         _Cresci.familia_cl                                 as NewFamiliaCl,
         _Cresci.chave_manual                               as NewChaveFamilia,

         _Cresci.created_at                                 as CreatedAt,
         _Cresci.created_by                                 as CreatedBy,

         /* Associations */
         _Contrato,
         _Empresa,
         _Canal,
         _Posting,
         _FormaP,
         _SetorA,
         _RegiaoV,
         _katr2


}
