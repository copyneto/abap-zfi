*&---------------------------------------------------------------------*
*& Include          ZXVVFU08
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_doc_uuid_h,
         doc_uuid_h TYPE sysuuid_x16,
       END OF ty_doc_uuid_h.

DATA lt_uuid TYPE TABLE OF ty_doc_uuid_h.

INCLUDE zsdi_tratamento_ecommerce IF FOUND.
INCLUDE zsdi_caf_tratar_contabilizacao IF FOUND.
INCLUDE zsdi_excecao_centro_custo IF FOUND.
INCLUDE zsdi_condicao_contrato IF FOUND.
INCLUDE zfii_contratos_contab IF FOUND.
INCLUDE zsdi_ref_devol IF FOUND.
INCLUDE zsdi_distrato_sem_referencia IF FOUND.
