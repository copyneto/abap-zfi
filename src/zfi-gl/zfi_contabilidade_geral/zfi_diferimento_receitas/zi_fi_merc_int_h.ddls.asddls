@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS de Interface - Mercado Interno Hea'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_MERC_INT_H
  as select from    ZI_FI_MERC_INT_LOG          as Header

    inner join      I_BillingDocument           as _VendasHeader          on  (
                 _VendasHeader.AccountingDocument                                                                          =  Header.awkey
                 or _VendasHeader.AccountingDocument                                                                       =  Header.belnr
               )
                                                                          and (
                                                                             _VendasHeader.BillingDocumentType             =  'Z001'
                                                                             or _VendasHeader.BillingDocumentType          =  'Z015'
                                                                             or _VendasHeader.BillingDocumentType          =  'Z018'
                                                                             or _VendasHeader.BillingDocumentType          =  'Y065'
                                                                             or _VendasHeader.BillingDocumentType          =  'Z003'
                                                                             or _VendasHeader.BillingDocumentType          =  'Z009'
                                                                           )
                                                                          and _VendasHeader.CustomerAccountAssignmentGroup <> '03'

    inner join      ZI_FI_I_BillingDocumentItem as _VendasItem            on _VendasItem.BillingDocument = _VendasHeader.BillingDocument

    inner join      ZI_FI_ORDEM_FRETE           as _OrdemFrete            on _OrdemFrete.Remessa = _VendasItem.ReferenceSDDocument

    inner join      ZI_FI_DEFRECE_CRI           as _Criterio              on  _Criterio.Bukrs     = Header.bukrs
                                                                          and _Criterio.RegioFrom = _VendasItem.PlantRegion
                                                                          and _Criterio.RegioTo   = _VendasItem.BillToPartyRegion

    left outer join ZI_FI_TRANSPORDEXECUTION    as _FI_TRANSPORDEXECUTION on _FI_TRANSPORDEXECUTION.TransportationOrderUUID = _OrdemFrete.ParentKey

    left outer join I_TranspOrdExecution        as _TranspOrdExecution    on  _TranspOrdExecution.TransportationOrderUUID = _FI_TRANSPORDEXECUTION.TransportationOrderUUID
                                                                          and _TranspOrdExecution.TranspOrdExecution      = _FI_TRANSPORDEXECUTION.IdOrdExecution

  //    left outer join ZI_FI_LOG_DIFER_DOC_PROC as _DocProcessados on  _DocProcessados.Empresa = Header.bukrs
  //                                                                and _DocProcessados.Belnr   = Header.belnr
  //                                                                and _DocProcessados.Gjahr   = Header.gjahr

  composition [1..*] of ZI_FI_MERC_INT_I as _MercIntItem

  //  association [0..*] to ZI_FI_BillingDocExtd as BillingDocExtdItemBasic on BillingDocBasic.BillingDocument = BillingDocBasic.BillingDocument

{
  key Header.bukrs                                                                                                                             as Empresa,
  key Header.belnr                                                                                                                             as NumDoc,
  key Header.gjahr                                                                                                                             as Ano,
      _OrdemFrete.OrdemFrete                                                                                                                   as OrdemFrete,
      Header.bldat                                                                                                                             as DataDocumento,
      Header.budat                                                                                                                             as DataLancamento,
      Header.monat                                                                                                                             as Mes,
      Header.blart                                                                                                                             as TipoDocumento,
      Header.waers                                                                                                                             as Moeda,
      Header.xblnr                                                                                                                             as Referencia,
      Header.bktxt                                                                                                                             as TextoCab,
      @EndUserText.label: 'Data Lançamento'
      ''                                                                                                                                       as DataLanc,
      @EndUserText.label: 'Data Estorno'
      ''                                                                                                                                       as DataEstorno,
      coalesce( _Criterio.Preventr, 0 )                                                                                                        as Dias,
      _VendasHeader.BillingDocument                                                                                                            as Remessa,
      _VendasHeader.BillingDocumentDate                                                                                                        as DataRemessa,
      _VendasItem.ReferenceSDDocument,
      _VendasHeader.OverallBillingStatus,
      _VendasHeader.TransactionCurrency                                                                                                        as TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _VendasHeader.TotalNetAmount                                                                                                             as TotalNetAmount,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _VendasHeader.TotalTaxAmount                                                                                                             as TotalTaxAmount,
      ( cast( _VendasHeader.TotalNetAmount as abap.dec( 13, 2) ) + cast( _VendasHeader.TotalTaxAmount as abap.dec( 13, 2) ) )                  as TotalDocument,
      @EndUserText.label: 'Data Diferimento'
      tstmp_to_dats( _TranspOrdExecution.TranspOrdEvtActualDateTime, abap_system_timezone( $session.client,'NULL' ), $session.client, 'NULL' ) as DataAtual,
      case
       when _TranspOrdExecution.TranspOrdEvtActualDateTime is null then ''
       when substring( tstmp_to_dats( _TranspOrdExecution.TranspOrdEvtActualDateTime, abap_system_timezone( $session.client,'NULL' ), $session.client, 'NULL' ), 5, 2 ) <>
            substring( cast(  Header.bldat as abap.char( 08 )), 5, 2 ) then 'Sim'
       when _TranspOrdExecution.TranspOrdEvtActualDateTime <> 0 then 'Não'
       else ''
      end                                                                                                                                      as AptoDiferimento,
      cast( _VendasHeader.TotalNetAmount as abap.dec( 13, 2 ) )                                                                                as Amount,
      _MercIntItem
      /*      substring(_VendasHeader.BillingDocumentDate, 5, 2) as TESTE1,
            substring(dats_add_days( _VendasHeader.BillingDocumentDate, _Criterio.Preventr, 'INITIAL' ), 5, 2) as TESTE2,
            case
             when substring(_VendasHeader.BillingDocumentDate, 5, 2) <> substring(dats_add_days( _VendasHeader.BillingDocumentDate, _Criterio.Preventr, 'INITIAL' ), 5, 2) then 'OK'
             else 'NOK'
             end as TESTE3,
            coalesce( _Criterio.Bukrs, 'NOK' ) as TESTECRITERIO */
}
where
  //      substring(_VendasHeader.BillingDocumentDate, 5, 2) <> substring(dats_add_days( _VendasHeader.BillingDocumentDate, _Criterio.Preventr, 'INITIAL' ), 5, 2)
  //  and _VendasHeader.OverallBillingStatus                 =  'B' //PODEM SER CONTABILIZADOS
  //and
  Header.ChaveExiste = 'X'
