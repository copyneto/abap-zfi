*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_campos DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:

      BEGIN OF gc_existe_ordenacao,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '015',
      END OF gc_existe_ordenacao,

      BEGIN OF gc_existe_campo,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '003',
      END OF gc_existe_campo,

      BEGIN OF gc_campos_obrigatorios,
        id     TYPE symsgid VALUE 'ZFI_AUTO_TXT_CONTAB',
        number TYPE symsgno VALUE '011',
      END OF gc_campos_obrigatorios.

    METHODS validaCampo FOR VALIDATE ON SAVE
      IMPORTING keys FOR Campos~validaCampo.
    METHODS validaOrdem FOR VALIDATE ON SAVE
      IMPORTING keys FOR Campos~validaOrdem.

ENDCLASS.

CLASS lcl_campos IMPLEMENTATION.

  METHOD validaCampo.

    READ ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
      ENTITY Campos
        FIELDS ( IdRegra
                 Campo
                 Ordenacao ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_campos) FAILED DATA(ls_erros).


    IF lt_campos IS INITIAL.
      RETURN.
    ENDIF.

    SELECT id_regra,
           campo,
           ordenacao
      FROM ztfi_autotxt_cmp
      FOR ALL ENTRIES IN @lt_campos
      WHERE id_regra = @lt_campos-idregra
        AND campo = @lt_campos-campo
        INTO TABLE @DATA(lt_campo_existente).

    IF sy-subrc EQ 0.
      SORT lt_campo_existente BY campo.
    ENDIF.


    LOOP AT lt_campos ASSIGNING FIELD-SYMBOL(<fs_campos>).

      APPEND VALUE #(
        %tky        = <fs_campos>-%tky
        %state_area = 'VALIDAR_CAMPO' )
      TO reported-regras.


      READ TABLE lt_campo_existente ASSIGNING FIELD-SYMBOL(<fs_campo_existente>)
          WITH KEY campo = <fs_campos>-campo
           BINARY SEARCH.

      IF sy-subrc EQ 0.

        APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

        APPEND VALUE #(
          %tky        = <fs_campos>-%tky
          %state_area = 'VALIDAR_CAMPO'
          %msg        =  new_message(
            id       = gc_existe_campo-id
            number   = gc_existe_campo-number
            severity = if_abap_behv_message=>severity-error
            v1       = |{ <fs_campo_existente>-campo ALPHA = OUT }|
            v2       = |{ <fs_campo_existente>-ordenacao ALPHA = OUT }|
          )
          %element-campo = if_abap_behv=>mk-on
        ) TO reported-campos.

      ENDIF.


      IF <fs_campos>-Campo IS INITIAL.

        APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

        APPEND VALUE #(
          %tky        = <fs_campos>-%tky
          %state_area = 'VALIDAR_CAMPO'
          %msg        =  new_message(
            id       = gc_campos_obrigatorios-id
            number   = gc_campos_obrigatorios-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-campo = if_abap_behv=>mk-on
        ) TO reported-campos.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validaOrdem.


     READ ENTITIES OF zi_fi_cfg_auto_textos_regras IN LOCAL MODE
      ENTITY Campos
        FIELDS ( IdRegra
                 Campo
                 Ordenacao ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_campos) FAILED DATA(ls_erros).


    IF lt_campos IS INITIAL.
      RETURN.
    ENDIF.


    SELECT id,
           id_regra,
           campo,
           ordenacao
      FROM ztfi_autotxt_cmp
      FOR ALL ENTRIES IN @lt_campos
      WHERE id_regra = @lt_campos-idregra
        AND ordenacao = @lt_campos-ordenacao
        INTO TABLE @DATA(lt_ordenacao_existente).

    IF sy-subrc EQ 0.
      SORT lt_ordenacao_existente BY ordenacao.
    ENDIF.

    LOOP AT lt_campos ASSIGNING FIELD-SYMBOL(<fs_campos>).

      APPEND VALUE #(
        %tky        = <fs_campos>-%tky
        %state_area = 'VALIDAR_ORDEM' )
      TO reported-regras.

      READ TABLE lt_ordenacao_existente ASSIGNING FIELD-SYMBOL(<fs_ordenacao_existente>)
          WITH KEY ordenacao = <fs_campos>-Ordenacao
           BINARY SEARCH.

      IF sy-subrc EQ 0 and <fs_ordenacao_existente>-id ne <fs_campos>-id.


        APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

        APPEND VALUE #(
          %tky        = <fs_campos>-%tky
          %state_area = 'VALIDAR_ORDEM'
          %msg        =  new_message(
            id       = gc_existe_ordenacao-id
            number   = gc_existe_ordenacao-number
            severity = if_abap_behv_message=>severity-error
            v1       = |{ <fs_ordenacao_existente>-ordenacao ALPHA = OUT }|
            v2       = |{ <fs_ordenacao_existente>-campo ALPHA = OUT }|
          )
          %element-campo = if_abap_behv=>mk-on
        ) TO reported-campos.

      ENDIF.

      IF <fs_campos>-Ordenacao IS INITIAL.

        APPEND VALUE #( %tky = <fs_campos>-%tky ) TO failed-campos.

        APPEND VALUE #(
          %tky        = <fs_campos>-%tky
          %state_area = 'VALIDAR_ORDEM'
          %msg        =  new_message(
            id       = gc_campos_obrigatorios-id
            number   = gc_campos_obrigatorios-number
            severity = if_abap_behv_message=>severity-error
          )
          %element-ordenacao = if_abap_behv=>mk-on
        ) TO reported-campos.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
