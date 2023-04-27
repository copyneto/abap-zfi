@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS de Interface - Contabilização Cabeçalho'
define root view entity ZI_FI_CONTAB_CAB
  as select from ztfi_contab_cab as Header

  composition [0..*] of ZI_FI_CONTAB_ITEM              as _Item

  association [0..1] to ZI_FI_VH_STATUS_CONTABILIZACAO as _Status on  _Status.ObjectId = $projection.StatusCode
                                                                  and _Status.Language = $session.system_language
{
  key id                 as Id,
  key identificacao      as Identificacao,
      _Status.ObjectName as StatusText,
      status             as StatusCode,
      case status
          when 'S' then 3
          else 1
      end                as StatusCriticality,
      empresa            as Empresa,
      data_documento     as DataDocumento,
      data_lancamento    as DataLancamento,
      tipo_documento     as TipoDocumento,
      referencia         as Referencia,
      text_cab           as TextCab,
      text_status        as TextStatus,

      _Item
}
