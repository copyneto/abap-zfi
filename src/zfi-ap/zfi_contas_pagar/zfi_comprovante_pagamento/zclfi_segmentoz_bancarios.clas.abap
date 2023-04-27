"!<p><h2>Dados bancários do segmento Z</h2></p>
"!<p><strong>Autor:</strong> Anderson Miazato</p>
"!<p><strong>Data:</strong> 14 de set de 2021</p>
CLASS zclfi_segmentoz_bancarios DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      "! Dados do banco pagante
      BEGIN OF ty_dados_banco,
        bukrs TYPE /bsnagt/p_t012-bukrs,
        hbkid TYPE /bsnagt/p_t012-hbkid,
        bankl TYPE /bsnagt/p_t012-bankl,
        name1 TYPE /bsnagt/p_t012-name1,
      END OF ty_dados_banco,

      "! Dados da conta pagante
      BEGIN OF ty_conta_principal,
        bukrs TYPE V_T012k_DDL-bukrs,
        hbkid TYPE V_T012k_DDL-hbkid,
        hktid TYPE V_T012k_DDL-hktid,
        bankn TYPE V_T012k_DDL-bankn,
        bkont TYPE V_T012k_DDL-bkont,
      END OF ty_conta_principal.

    METHODS:
      "! Inicializa dados do objeto referenciado
      "! @parameter is_febko | Cabeçalho extrato conta eletrônico
      "! @parameter is_febep | Itens extrato conta eletrônico
      constructor IMPORTING is_febko TYPE febko
                            is_febep TYPE febep,

      "! Retorna dados do banco e agência da conta bancária principal
      "! @parameter rs_result | Dados do banco
      get_dados_bancarios RETURNING VALUE(rs_result) TYPE zclfi_segmentoz_bancarios=>ty_dados_banco,

      "! Seleciona conta bancária principal relacionada ao extrato
      set_dados_bancarios,

      "! Retorna dados da conta bancária principal
      "! @parameter rs_result | Conta bancária
      get_conta_principal RETURNING VALUE(rs_result) TYPE zclfi_segmentoz_bancarios=>ty_conta_principal,

      "! Retorna dados da conta bancária principal relacionada ao extrato
      set_conta_principal.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      "! Cabeçalho de extrato eletrônico da conta
      gs_febko           TYPE febko,
      "! Item do extrato eletrônico da conta
      gs_febep           TYPE febep,
      "! Banco e Agência pagante
      gs_dados_banco     TYPE ty_dados_banco,
      "! Conta bancária pagante
      gs_conta_principal TYPE ty_conta_principal.

ENDCLASS.


CLASS zclfi_segmentoz_bancarios IMPLEMENTATION.
  METHOD get_dados_bancarios.
    rs_result = me->gs_dados_banco.
  ENDMETHOD.

  METHOD set_dados_bancarios.

    SELECT SINGLE
        bukrs,
        hbkid,
        bankl,
        name1
    FROM /bsnagt/p_t012
        WHERE bukrs EQ @me->gs_febko-bukrs
          AND hbkid EQ @me->gs_febko-hbkid
    INTO @me->gs_dados_banco.

  ENDMETHOD.

  METHOD get_conta_principal.
    rs_result = me->gs_conta_principal.
  ENDMETHOD.

  METHOD set_conta_principal.

    SELECT SINGLE
        bukrs,
        hbkid,
        hktid,
        bankn,
        bkont
    FROM V_T012k_DDL
        WHERE bukrs EQ @me->gs_febko-bukrs
          AND hbkid EQ @me->gs_febko-hbkid
    INTO @me->gs_conta_principal.

  ENDMETHOD.

  METHOD constructor.

    me->gs_febko = is_febko.

    me->gs_febep = is_febep.

    me->set_dados_bancarios( ).

    me->set_conta_principal( ).

  ENDMETHOD.

ENDCLASS.
