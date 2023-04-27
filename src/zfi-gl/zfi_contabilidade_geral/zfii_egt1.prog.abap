*&---------------------------------------------------------------------*
*& Include          ZFII_EGT1
*&---------------------------------------------------------------------*

IF bseg-gsber IS INITIAL.

   if /xeit/cleit_abap_tools=>namespace_call_check( i_namespace = '/XEIT/'  ) = 0.

      bseg-gsber   = '1000'.
      bseg-prctr   = 'EMPGERAL'.
      bseg-segment = 'S001'.

   endif.

ENDIF.
