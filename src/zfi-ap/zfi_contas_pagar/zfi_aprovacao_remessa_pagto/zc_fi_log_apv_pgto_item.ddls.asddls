@EndUserText.label: 'Detalhes Log de Aprovação Pagamento'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_FI_LOG_APV_PGTO_ITEM
  as projection on ZI_FI_LOG_APV_PGTO_ITEM
{
  key Bukrs,
  key Data,
  key TipoRelatorio,
  key Hora,
  key GrpTesouraria,
      Valor,
      Moeda,
      Encerrador,
      EncUser,
      EncData,
      EncHora,
      Aprov1,
      Ap1User,
      Ap1Data,
      Ap1Hora,
      Aprov2,
      Ap2User,
      Ap2Data,
      Ap2Hora,
      Aprov3,
      Ap3User,
      Ap3Data,
      Ap3Hora,
      Hbkid,
      CompanyCodeName,
      CashPlanningGroupName,
      Text,
      BancoEmpresaText,

      DataDownload,
      HoraDownload,

      _Apv1.Text as Apv1Text,
      _Apv2.Text as Apv2Text,
      _Apv3.Text as Apv3Text,
      _Enc. Text as EncText,

      EncerradorCrit,
      Aprov1Crit,
      Aprov2Crit,
      Aprov3Crit,

      /* Associations */
      _Apv1,
      _Apv2,
      _Apv3,
      _Empresa,
      _Enc,
      _PlanGrp,
      _TpRel,
      
      _Header : redirected to parent ZC_FI_LOG_APV_PGTO
}
