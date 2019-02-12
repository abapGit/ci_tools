CLASS zcl_gha_github_factory DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_pull_requests
      RETURNING
        VALUE(ri_instance) TYPE REF TO zif_gha_github_pull_requests .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_GITHUB_FACTORY IMPLEMENTATION.


  METHOD get_pull_requests.

    ri_instance = NEW zcl_gha_github_pull_requests( ).

  ENDMETHOD.
ENDCLASS.
