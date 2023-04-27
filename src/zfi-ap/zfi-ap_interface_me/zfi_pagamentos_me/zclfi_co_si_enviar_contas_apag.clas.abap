class ZCLFI_CO_SI_ENVIAR_CONTAS_APAG definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods SI_ENVIAR_CONTAS_APAGAR_OUT
    importing
      !OUTPUT type ZCLFI_MT_CONTAS_APAGAR
    exporting
      !INPUT type ZCLFI_MT_CONTAS_APAGAR_RESP
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZCLFI_CO_SI_ENVIAR_CONTAS_APAG IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZCLFI_CO_SI_ENVIAR_CONTAS_APAG'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method SI_ENVIAR_CONTAS_APAGAR_OUT.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'OUTPUT' kind = '0' value = ref #( OUTPUT ) )
    ( name = 'INPUT' kind = '1' value = ref #( INPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'SI_ENVIAR_CONTAS_APAGAR_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
