*&---------------------------------------------------------------------*
*& Include zfii_exec_reversao_def
*&---------------------------------------------------------------------*

CLASS lcl_report DEFINITION.

  PUBLIC SECTION.

    TYPES: ty_t_data TYPE TABLE OF zsfi_output_revert.


    METHODS: display_report IMPORTING it_data TYPE ty_t_data.

  PRIVATE SECTION.

ENDCLASS.
