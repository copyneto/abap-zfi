"!<p>Classe para verificar permissões no Objeto de Autorização-Constante: <strong>gc_object</strong>
"!<p><strong>Autor:</strong> Alexsander Haas - Meta</p>
"!<p><strong>Data:</strong> 27/04/2022</p>
CLASS zclfi_auth_zfiwerks DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    "! Objeto de Autorização
    CONSTANTS gc_object TYPE xuobject VALUE 'ZFIWERKS'.

    CONSTANTS:
      "! Campos do Objeto de Autorização
      BEGIN OF gc_id,
        actvt TYPE fieldname VALUE 'ACTVT',
        werks TYPE fieldname VALUE 'WERKS',
      END OF gc_id,

      "! Ações básicas do Objeto de Autorização
      BEGIN OF gc_actvt,
        anexar_criar TYPE char2 VALUE '01',
        modificar    TYPE char2 VALUE '02',
        exibir       TYPE char2 VALUE '03',
        imprimir     TYPE char2 VALUE '04',
        bloquear     TYPE char2 VALUE '05',
        eliminar     TYPE char2 VALUE '06',
        ativar_gerar TYPE char2 VALUE '07',
      END OF gc_actvt.

    CLASS-METHODS:
      "! Verifica autorização por Centro para ação "Criar"
      "! @parameter iv_werks  | Centro
      "! @parameter rv_check  | Com Autorização=ABAP_TRUE/ Sem Autorização=ABAP_FALSE
      werks_create
        IMPORTING iv_werks        TYPE werks_d
        RETURNING VALUE(rv_check) TYPE abap_bool,

      "! Verifica autorização por Centro para ação "Update"
      "! @parameter iv_werks  | Centro
      "! @parameter rv_check  | Com Autorização=ABAP_TRUE/ Sem Autorização=ABAP_FALSE
      werks_update
        IMPORTING iv_werks        TYPE werks_d
        RETURNING VALUE(rv_check) TYPE abap_bool,

      "! Verifica autorização por Centro para ação "Delete"
      "! @parameter iv_werks  | Centro
      "! @parameter rv_check  | Com Autorização=ABAP_TRUE/ Sem Autorização=ABAP_FALSE
      werks_delete
        IMPORTING iv_werks        TYPE werks_d
        RETURNING VALUE(rv_check) TYPE abap_bool,

      "! Verifica autorização por Centro e Centro para ação do parâmetro IV_ACTVT
      "! @parameter iv_werks  | Centro
      "! iv_actvt             | Atividade a Validar
      "! @parameter rv_check  | Com Autorização=ABAP_TRUE/ Sem Autorização=ABAP_FALSE
      check_custom
        IMPORTING iv_werks        TYPE werks_d OPTIONAL
                  iv_actvt        TYPE char2
        RETURNING VALUE(rv_check) TYPE abap_bool.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZCLFI_AUTH_ZFIWERKS IMPLEMENTATION.


  METHOD werks_create.

    AUTHORITY-CHECK OBJECT gc_object
      ID gc_id-actvt FIELD gc_actvt-anexar_criar
      ID gc_id-werks FIELD iv_werks.

    IF sy-subrc IS INITIAL.
      rv_check = abap_true.
    ELSE.
      rv_check = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD werks_update.

    AUTHORITY-CHECK OBJECT gc_object
      ID gc_id-actvt FIELD gc_actvt-modificar
      ID gc_id-werks FIELD iv_werks.

    IF sy-subrc IS INITIAL.
      rv_check = abap_true.
    ELSE.
      rv_check = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD werks_delete.

    AUTHORITY-CHECK OBJECT gc_object
      ID gc_id-actvt FIELD gc_actvt-eliminar
      ID gc_id-werks FIELD iv_werks.

    IF sy-subrc IS INITIAL.
      rv_check = abap_true.
    ELSE.
      rv_check = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD check_custom.

    AUTHORITY-CHECK OBJECT gc_object
    ID gc_id-actvt FIELD iv_actvt
    ID gc_id-werks FIELD iv_werks.

    IF sy-subrc IS INITIAL.
      rv_check = abap_true.
    ELSE.
      rv_check = abap_false.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
