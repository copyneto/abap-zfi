@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Valida se registro já foi executado'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_FI_MERC_EXT_LOG
  as select from    P_BKPF_COM    as Header

    left outer join ZI_FI_LOG_DIF as _Log on  Header.bukrs = _Log.Empresa
                                          and Header.belnr = _Log.NumDoc
                                          and Header.gjahr = _Log.Ano
{
  key Header.bukrs,
  key Header.belnr,
  key Header.gjahr,
      Header.bldat,
      Header.budat,
      Header.monat,
      Header.blart,
      Header.waers,
      Header.xblnr,
      Header.bktxt,
      Header.awkey,

      case
        when _Log.Empresa is null then 'X'
        else ''
      end        as ChaveExiste,

      _Log.Empresa as EmpresaLog,
      _Log.NumDoc  as NumDocLog,
      _Log.Ano     as AnoLog
}
