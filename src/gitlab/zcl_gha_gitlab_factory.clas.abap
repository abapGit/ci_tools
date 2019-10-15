CLASS zcl_gha_gitlab_factory DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_merge_requests
      RETURNING
        VALUE(ri_instance) TYPE REF TO zif_gha_gitlab_merge_requests .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_GITLAB_FACTORY IMPLEMENTATION.


  METHOD get_merge_requests.

    ri_instance = NEW zcl_gha_gitlab_merge_requests( ).

  ENDMETHOD.
ENDCLASS.
