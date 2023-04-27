*&---------------------------------------------------------------------*
*& Include          ZFII_EGT2
*&---------------------------------------------------------------------*
  data: l_sbeln type /xeit/esbeln.

  import sbeln to l_sbeln from memory id '$EGT-SH$'.

  if sy-subrc is initial
   and not bseg-ktosl eq 'WRX'.

      move l_sbeln to bseg-zuonr.

  endif.
