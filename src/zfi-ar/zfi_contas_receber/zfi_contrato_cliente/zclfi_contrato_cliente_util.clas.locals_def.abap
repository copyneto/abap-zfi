*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

* ===========================================================================
* CONSTANTES
* ===========================================================================

CONSTANTS:

  BEGIN OF gc_cds,
    contrato     TYPE string VALUE 'CONTRATO',          " Contrato
    raiz         TYPE string VALUE 'RAIZ',              " Raiz
    cliente      TYPE string VALUE 'CLIENTE',           " Cliente
    anexo        TYPE string VALUE 'ANEXO',             " Anexo
    cond         TYPE string VALUE 'COND',              " Condições Desconto
    janela       TYPE string VALUE 'JANELA',            " Janela
    prov         TYPE string VALUE 'PROV',              " Provisão
    prov_familia TYPE string VALUE 'PROV_FAMILIA',      " Provisão: Famílias
    aprovadores  TYPE string VALUE 'APROVADORES',       " Aprovadores
  END OF gc_cds.
