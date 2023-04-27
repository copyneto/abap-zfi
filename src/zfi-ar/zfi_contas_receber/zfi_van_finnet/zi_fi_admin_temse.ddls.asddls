@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS tabela REGUT'
define root view entity ZI_FI_ADMIN_TEMSE
  as select from regut
{
  key zbukr    as Zbukr,
  key banks    as Banks,
  key laufd    as Laufd,
  key laufi    as Laufi,
  key xvorl    as Xvorl,
  key dtkey    as Dtkey,
  key lfdnr    as Lfdnr,
      waers    as Waers,
      rbetr    as Rbetr,
      renum    as Renum,
      dtfor    as Dtfor,
      tsnam    as Tsnam,
      tsdat    as Tsdat,
      tstim    as Tstim,
      tsusr    as Tsusr,
      dwnam    as Dwnam,
      dwdat    as Dwdat,
      dwtim    as Dwtim,
      dwusr    as Dwusr,
      kadat    as Kadat,
      katim    as Katim,
      kausr    as Kausr,
      report   as Report,
      fsnam    as Fsnam,
      usrex    as Usrex,
      edinum   as Edinum,
      grpno    as Grpno,
      dttyp    as Dttyp,
      guid     as Guid,
      saprl    as Saprl,
      codepage as Codepage,
      status   as Status
}
