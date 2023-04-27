@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Simulação de Vigência Contratos Cliente'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity zi_fi_simul_contratos_cliente
  as select from    ztfi_simul_contr as _simul_contr
    left outer join ztfi_contrato    as _contrato on  _contrato.aditivo  = _simul_contr.aditivo
                                                  and _contrato.contrato = _simul_contr.contrato
  association [0..1] to I_CompanyCodeVH              as _Emp                    on  _Emp.CompanyCode = $projection.Bukrs

  association [0..1] to ZI_CA_VH_VTWEG               as _Canal                  on  _Canal.CanalDistrib = $projection.Canal
  association [0..1] to ZI_CO_FAMILIA_CL             as _Familia                on  $projection.FamiliaCl = _Familia.Wwmt1

  association [0..1] to ZI_FI_TP_DESCONTO            as _TpDesc                 on  $projection.TipoDesconto = _TpDesc.TipoDescId
  association [0..1] to ZI_FI_CONDICAO_DESCONTO      as _Cond                   on  $projection.CondDesconto = _Cond.TipoCond
  association [0..1] to ZI_FI_TP_APLIC_DESC          as _Aplic                  on  $projection.AplicaDesconto = _Aplic.TipoAplicId
  association [0..1] to ZI_FI_ATRIBUTE2_CMASTER      as _CMaster                on  $projection.ClassifCnpj = _CMaster.Id
  association [0..1] to I_DivisionText               as _Division               on  $projection.Setor  = _Division.Division
                                                                                and _Division.Language = $session.system_language
  association [0..1] to I_BusinessAreaText           as _BusinessArea           on  _BusinessArea.BusinessArea = $projection.Gsber
                                                                                and _BusinessArea.Language     = $session.system_language
  association [0..1] to I_AccountingDocumentTypeText as _AccountingDocumentType on  _AccountingDocumentType.AccountingDocumentType = $projection.Blart
                                                                                and _AccountingDocumentType.Language               = $session.system_language
{
  key   _simul_contr.contrato                                 as Contrato,
  key   _simul_contr.aditivo                                  as Aditivo,
        @ObjectModel.text: { element: ['CompanyCodeName'] }
  key   _simul_contr.bukrs                                    as Bukrs,
  key   _simul_contr.belnr                                    as Belnr,
  key   _simul_contr.buzei                                    as Buzei,
  key   _simul_contr.gjahr                                    as Gjahr,
  key   _simul_contr.vbeln                                    as Vbeln,
  key   _simul_contr.posnr                                    as Posnr,
        @ObjectModel.text: { element: ['CondDescontoTxt'] }
  key   _simul_contr.cond_desconto                            as CondDesconto,
        //      _contrato.razao_social                                as razao_social,
        //      _contrato.cnpj_principal                              as cnpj_principal,
        _simul_contr.xblnr                                    as Xblnr,
        _simul_contr.cliente                                  as Cliente,
        _simul_contr.augdt                                    as Augdt,
        _simul_contr.augbl                                    as Augbl,
        @ObjectModel.text: { element: ['BlartTxt'] }
        _simul_contr.blart                                    as Blart,
        _simul_contr.bschl                                    as Bschl,
        _simul_contr.budat                                    as Budat,
        _simul_contr.netdt                                    as Netdt,
        @ObjectModel.text: { element: ['GsberTxt'] }
        _simul_contr.gsber                                    as Gsber,
        _simul_contr.xref1_hd                                 as Xref1Hd,
        _simul_contr.zbd1p                                    as Zbd1p,
        @ObjectModel.text: { element: ['ClassificCnpjText'] }
        _simul_contr.classif_cnpj                             as ClassifCnpj,
        @ObjectModel.text: { element: ['CanalTxt'] }
        _simul_contr.canal                                    as Canal,
        @ObjectModel.text: { element: ['SetorTxt'] }
        _simul_contr.setor                                    as Setor,
        @ObjectModel.text: { element: ['FamiliaClTxt'] }
        _simul_contr.familia_cl                               as FamiliaCl,
        _simul_contr.flagfamtodos                             as Flagfamtodos,
        @ObjectModel.text: { element: ['TipoDescTxt'] }
        _simul_contr.tipo_desconto                            as TipoDesconto,

        cast( _simul_contr.wrbtr as abap.dec( 11, 2 ) )       as Montante,
        cast( _simul_contr.wrbtrcal as abap.dec( 11, 2 ) )    as MontanteCalculado,
        @ObjectModel.text: { element: ['AplicaDescontoTxt'] }
        _simul_contr.aplica_desconto                          as AplicaDesconto,
        cast( _simul_contr.montdesccom as abap.dec( 11, 2 ) ) as MontanteDesconto,
        _simul_contr.bzirk                                    as RegiaoVendas,
        _simul_contr.created_by                               as CreatedBy,
        _simul_contr.created_at                               as CreatedAt,
        _simul_contr.last_changed_by                          as LastChangedBy,
        _simul_contr.last_changed_at                          as LastChangedAt,
        _simul_contr.local_last_changed_at                    as LocalLastChangedAt,
        @UI.hidden: true
        _Emp.CompanyCodeName                                  as CompanyCodeName,
        @UI.hidden: true
        _Canal.CanalDistribText                               as CanalTxt,
        @UI.hidden: true
        _TpDesc.TipoDescText                                  as TipoDescTxt,
        @UI.hidden: true
        _Cond.Text                                            as CondDescontoTxt,
        @UI.hidden: true
        _CMaster.Text                                         as ClassificCnpjText,
        @UI.hidden: true
        _Aplic.TipoAplicText                                  as AplicaDescontoTxt,
        @UI.hidden: true
        _Familia.Bezek                                        as FamiliaClTxt,
        @UI.hidden: true
        _BusinessArea.BusinessAreaName                        as GsberTxt,
        @UI.hidden: true
        _Division.DivisionName                                as SetorTxt,
        @UI.hidden: true
        _AccountingDocumentType.AccountingDocumentTypeName    as BlartTxt

}
