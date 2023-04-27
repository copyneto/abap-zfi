@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Detalhes Log de Aprovação Pagamento'
define view entity ZI_FI_LOG_APV_PGTO_ITEM
  as select from    ZI_FI_LOG_APV_PGTO_I as _Log

    left outer join ZI_CA_VH_HBKID       as _Bank on  _Bank.BancoEmpresa = _Log.Hbkid
                                                  and _Bank.Empresa      = _Log.Bukrs
  association to I_PlanningGroup           as _PlanGrp on  _PlanGrp.CashPlanningGroup = $projection.GrpTesouraria
  association to ZI_FI_VH_APROV            as _Apv1    on  _Apv1.DomvalueL = $projection.Aprov1
  association to ZI_FI_VH_APROV            as _Apv2    on  _Apv2.DomvalueL = $projection.Aprov2
  association to ZI_FI_VH_APROV            as _Apv3    on  _Apv3.DomvalueL = $projection.Aprov3
  association to ZI_FI_VH_APROV            as _Enc     on  _Enc.DomvalueL = $projection.Encerrador
  association to ZI_FI_VH_TIPOREL          as _TpRel   on  _TpRel.Value = $projection.TipoRelatorio
  association to I_CompanyCode             as _Empresa on  _Empresa.CompanyCode = $projection.Bukrs

  association to parent ZI_FI_LOG_APV_PGTO as _Header  on  _Header.Empresa       = $projection.Bukrs
                                                       and _Header.Data          = $projection.Data
                                                       and _Header.TipoRelatorio = $projection.TipoRelatorio
//                                                       and _Header.grptesouraria = $projection.GrpTesouraria
                                                       and _Header.Hora          = $projection.Hora

                                                       and _Header.GrpTesouraria  = $projection.GrpTesouraria

{
      @ObjectModel.text.element: ['CompanyCodeName']
  key _Log.Bukrs,
  key _Log.Data,
      @ObjectModel.text.element: ['Text']
  key _Log.TipoRelatorio,
  key _Log.Hora,
      @ObjectModel.text.element: ['CashPlanningGroupName']
  key _Log.GrpTesouraria,
      @Semantics.amount.currencyCode: 'Moeda'
      _Log.Valor,
      _Log.Moeda,
      _Log.Encerrador,
      _Log.EncUser,
      _Log.EncData,
      _Log.EncHora,
      _Log.Aprov1,
      _Log.Ap1User,
      _Log.Ap1Data,
      _Log.Ap1Hora,
      _Log.Aprov2,
      _Log.Ap2User,
      _Log.Ap2Data,
      _Log.Ap2Hora,
      _Log.Aprov3,
      _Log.Ap3User,
      _Log.Ap3Data,
      _Log.Ap3Hora,
      @ObjectModel.text.element: ['BancoEmpresaText']
      _Log.Hbkid,

      _Log.DataDownload,
      _Log.HoraDownload,

      _Apv1.Text as Apv1Text,
      _Apv2.Text as Apv2Text,
      _Apv3.Text as Apv3Text,
      _Enc.Text  as EncText,

      _Log.EncerradorCrit,
      _Log.Aprov1Crit,
      _Log.Aprov2Crit,
      _Log.Aprov3Crit,

      _Empresa.CompanyCodeName,
      _PlanGrp._Text[Language = $session.system_language].CashPlanningGroupName,
      _TpRel.Text,
      _Bank.BancoEmpresaText,

      /* Associations */
      _Apv1,
      _Apv2,
      _Apv3,
      _Empresa,
      _Enc,
      _PlanGrp,
      _TpRel,
      _Header
}
