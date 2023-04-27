"Name: \FU:BAPI_ACC_DOCUMENT_POST\SE:END\EI
ENHANCEMENT 0 ZEIFI_PEDIDO_COMPRA.

*    IF obj_key IS NOT INITIAL.
*      TRY.
*
*      NEW zclfi_partidas_abertas( iv_obj_key = obj_key )->send_interface_me(  ).
*
*      CATCH zcxca_erro_interface.
*      ENDTRY.
*    ENDIF.

ENDENHANCEMENT.
