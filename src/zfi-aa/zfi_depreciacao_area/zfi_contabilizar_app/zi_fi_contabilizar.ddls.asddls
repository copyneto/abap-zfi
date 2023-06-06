@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Dados de Contabilização'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_FI_CONTABILIZAR
  as select from    ZI_FI_GRP_AREA_SUM as _Ava
  //  as select from    ZI_FI_GRP_AREA_AVA_CONTAS as _Ava


    left outer join ztfi_contab_log    as _Cont   on  _Ava.Bukrs   = _Cont.bukrs
                                                  and _Ava.Anln1   = _Cont.anln1
                                                  and _Ava.Anln2   = _Cont.anln2
                                                  and _Ava.Anlkl   = _Cont.anlkl
                                                  and _Ava.gsber   = _Cont.gsber
                                                  and _Ava.kostl   = _Cont.kostl
                                                  and _Ava.gjahr   = _Cont.gjahr
                                                  and _Ava.peraf   = _Cont.peraf
                                                  and _Cont.contab = 'X'

    left outer join ztfi_contab_log    as _Reav   on  _Ava.Bukrs = _Reav.bukrs
                                                  and _Ava.Anln1 = _Reav.anln1
                                                  and _Ava.Anln2 = _Reav.anln2
                                                  and _Ava.Anlkl = _Reav.anlkl
                                                  and _Ava.gsber = _Reav.gsber
                                                  and _Ava.kostl = _Reav.kostl
                                                  and _Ava.gjahr = _Reav.gjahr
                                                  and _Ava.peraf = _Reav.peraf
                                                  and _Reav.reav = 'X'

    left outer join Faa_Anlc           as _C      on  _Ava.Bukrs = _C.bukrs
                                                  and _Ava.Anln1 = _C.anln1
                                                  and _Ava.Anln2 = _C.anln2
                                                  and _Ava.gjahr = _C.gjahr
                                                  and _C.afabe   = '80'

    left outer join anlb               as _Anlb80 on  _Anlb80.bukrs = _Ava.Bukrs
                                                  and _Anlb80.anln1 = _Ava.Anln1
                                                  and _Anlb80.anln2 = _Ava.Anln2
                                                  and _Anlb80.afabe = '80'

    left outer join anlb               as _Anlb01 on  _Anlb01.bukrs = _Ava.Bukrs
                                                  and _Anlb01.anln1 = _Ava.Anln1
                                                  and _Anlb01.anln2 = _Ava.Anln2
                                                  and _Anlb01.afabe = '01'

  association [0..*] to t001 as t001 on  $projection.Bukrs = t001.bukrs
  association [0..*] to ankt as ankt on  ankt.spras        = $session.system_language
                                     and $projection.Anlkl = ankt.anlkl

{
  key  _Ava.Bukrs,
  key  _Ava.Anln1,
  key  _Ava.Anln2,
  key  _Ava.Anlkl,
  key  _Ava.gsber,
  key  _Ava.kostl,
  key  _Ava.gjahr,
  key  _Ava.peraf,
       ankt.txk50                                                                                                         as AnlklTxt,
       _Ava.Aktiv,
       t001.waers                                                                                                         as Moeda,

       cast( _Ava.Nafag01 as abap.dec( 12, 2 )  )                                                                         as Nafag01,
       cast( _Ava.Nafag10 as abap.dec( 12, 2 )  )                                                                         as Nafag10,
       cast( _Ava.Nafag11 as abap.dec( 12, 2 )  )                                                                         as Nafag11,
       cast( _Ava.Nafag80 as abap.dec( 12, 2 )  )                                                                         as Nafag80,
       cast( _Ava.Nafag82 as abap.dec( 12, 2 )  )                                                                         as Nafag82,
       cast( _Ava.Nafag84 as abap.dec( 12, 2 )  )                                                                         as Nafag84,


       //       cast( _C.kansw as abap.dec( 12, 2 )  ) + cast( _C.answl as abap.dec( 12, 2 )  )                                    as ANSWL_80,
       //       cast( _C.nafag as abap.dec( 12, 2 )  )                                                                             as NAFAG_80,
       //
       //       cast( cast(  _C.answl as abap.dec( 15, 4 ) ) - cast( abs( _C.nafag) as abap.dec( 15, 4 ) )  as abap.dec( 12, 2 ) ) as Valorcont80,

       _Anlb80.afabg                                                                                                      as Afabg_80,
       _Anlb01.afabg                                                                                                      as Afabg_01,

       cast( cast( _Ava.ANSWL_80 as abap.dec( 15, 4 ) )-
            cast(  _Ava.NAFAG_80_CALC as abap.dec( 15, 4 ) )  as abap.dec( 12, 2 ) )                                      as NAFAG_80_CALC,

       cast( cast( _Ava.Nafag80 as abap.dec( 15, 4 ) )-
            cast(  _Ava.Nafag01 as abap.dec( 15, 4 ) )  as abap.dec( 12, 2 ) )                                            as Ajus80_01,
       cast( cast( _Ava.Nafag82 as abap.dec( 15, 4 ) )-
            cast(  _Ava.Nafag10 as abap.dec( 15, 4 ) )  as abap.dec( 12, 2 ) )                                            as Ajus82_10,
       cast( cast( _Ava.Nafag84 as abap.dec( 15, 4 ) )-
            cast(  _Ava.Nafag11 as abap.dec( 15, 4 ) )  as abap.dec( 12, 2 ) )                                            as Ajus84_11,

       cast( cast( _Ava.Nafag01 as abap.dec( 15, 4 ) ) +
       cast( _Ava.Nafag10 as abap.dec( 15, 4 ) ) +
       cast( _Ava.Nafag11 as abap.dec( 15, 4 ) ) +
       ( cast( _Ava.Nafag80 as abap.dec( 15, 4 ) ) - cast(  _Ava.Nafag01 as abap.dec( 15, 4 ) ) ) +
       ( cast( _Ava.Nafag82 as abap.dec( 15, 4 ) ) - cast(  _Ava.Nafag10 as abap.dec( 15, 4 ) ) ) +
       ( cast( _Ava.Nafag84 as abap.dec( 15, 4 ) ) - cast(  _Ava.Nafag11 as abap.dec( 15, 4 ) ) ) as abap.dec( 12, 2 )  ) as Total,
       _Ava.ContaDepFiscal_01,
       _Ava.ContaDepFiscal_10,
       _Ava.ContaDepFiscal_11,
       _Ava.ContaDespFiscal_01,
       _Ava.ContaDespFiscal_10,
       _Ava.ContaDespFiscal_11,
       _Ava.ContaDepFiscal_80,
       _Ava.ContaDepFiscal_82,
       _Ava.ContaDepFiscal_84,
       _Ava.ContaDespFiscal_80,
       _Ava.ContaDespFiscal_82,
       _Ava.ContaDespFiscal_84,
       _Cont.belnr                                                                                                        as Belnr,
       case coalesce( _Cont.belnr, '')
          when '' then 1
          else 3
       end                                                                                                                as StatusCriticality,
       _Reav.belnr_reav                                                                                                   as BelnrReav,
       case coalesce( _Reav.belnr_reav, '')
          when '' then 1
          else 3
       end                                                                                                                as StatusCriticalityReav
}
