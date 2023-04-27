"!<p>Classe para verificar permissões no Objeto de Autorização-Constante: <strong>gc_object</strong>
"!<p><strong>Autor:</strong> Alexsander Haas - Meta</p>
"!<p><strong>Data:</strong> 27/04/2022</p>
CLASS zclfi_auth_zfimtable DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! Objeto de Autorização
    CONSTANTS gc_object TYPE xuobject VALUE 'ZFIMTABLE'.

    CONSTANTS:
      "! Campos do Objeto de Autorização
      BEGIN OF gc_id,
        actvt TYPE fieldname VALUE 'ACTVT',
        table TYPE fieldname VALUE 'TABLE',
      END OF gc_id,

      "! Ações básicas do Objeto de Autorização
      BEGIN OF gc_actvt,
        anexar_criar TYPE char2 VALUE '01',
        modificar    TYPE char2 VALUE '02',
        exibir       TYPE char2 VALUE '03',
        eliminar     TYPE char2 VALUE '06',
      END OF gc_actvt.

    CLASS-METHODS:
      "! Verifica autorização pelo Nome da Tabela para ação "Criar"
      "! @parameter iv_table  | Nome da Tabela de Manutenção
      "! @parameter rv_check  | Com Autorização=ABAP_TRUE/ Sem Autorização=ABAP_FALSE
      create
        IMPORTING iv_table        TYPE tabname_auth
        RETURNING VALUE(rv_check) TYPE abap_bool,

      "! Verifica autorização pelo Nome da Tabela para ação "Update"
      "! @parameter iv_table  | Nome da Tabela de Manutenção
      "! @parameter rv_check  | Com Autorização=ABAP_TRUE/ Sem Autorização=ABAP_FALSE
      update
        IMPORTING iv_table        TYPE tabname_auth
        RETURNING VALUE(rv_check) TYPE abap_bool,

      "! Verifica autorização pelo Nome da Tabela para ação "Delete"
      "! @parameter iv_table  | Nome da Tabela de Manutenção
      "! @parameter rv_check  | Com Autorização=ABAP_TRUE/ Sem Autorização=ABAP_FALSE
      delete
        IMPORTING iv_table        TYPE tabname_auth
        RETURNING VALUE(rv_check) TYPE abap_bool.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZCLFI_AUTH_ZFIMTABLE IMPLEMENTATION.


  METHOD create.

    AUTHORITY-CHECK OBJECT gc_object
      ID gc_id-actvt FIELD gc_actvt-anexar_criar
      ID gc_id-table FIELD iv_table.

    IF sy-subrc IS INITIAL.
      rv_check = abap_true.
    ELSE.
      rv_check = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD update.

    AUTHORITY-CHECK OBJECT gc_object
      ID gc_id-actvt FIELD gc_actvt-modificar
      ID gc_id-table FIELD iv_table.

    IF sy-subrc IS INITIAL.
      rv_check = abap_true.
    ELSE.
      rv_check = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD delete.

    AUTHORITY-CHECK OBJECT gc_object
      ID gc_id-actvt FIELD gc_actvt-eliminar
      ID gc_id-table FIELD iv_table.

    IF sy-subrc IS INITIAL.
      rv_check = abap_true.
    ELSE.
      rv_check = abap_false.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
