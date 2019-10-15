CLASS zcl_gha_gitlab_factory DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_merge_requests
      RETURNING
        VALUE(ri_instance) TYPE REF TO zif_gha_gitlab_merge_requests .
    CLASS-METHODS get_notes
      IMPORTING
        !iv_project_id  TYPE i
      RETURNING
        VALUE(ri_notes) TYPE REF TO zif_gha_gitlab_notes .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_GITLAB_FACTORY IMPLEMENTATION.


  METHOD get_merge_requests.

    ri_instance = NEW zcl_gha_gitlab_merge_requests( ).

  ENDMETHOD.


  METHOD get_notes.

    ri_notes = NEW zcl_gha_gitlab_notes( iv_project_id ).

  ENDMETHOD.
ENDCLASS.
