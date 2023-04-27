*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
  CONSTANTS:
  BEGIN OF gc_cds,
    credito         TYPE string VALUE 'CREDITO',                       " Crédito
    fatura          TYPE string VALUE 'FATURA',                        " Fatura
  END OF gc_cds,
  BEGIN OF gc_proc,
    associacao_credito         TYPE string VALUE 'ASSOCIACAO_CREDITO', " Associação Crédito
    pagar_fornecedor           TYPE string VALUE 'PAGAR_FORNECEDOR',   " Pagar Fornecedor
  END OF gc_proc.
