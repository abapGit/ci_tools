CLASS zcl_gha_github_factory DEFINITION
  PUBLIC
  CREATE PRIVATE .

  PUBLIC SECTION.

    CLASS-METHODS get_pull_requests
      IMPORTING
        !iv_owner          TYPE string
        !iv_repo           TYPE string
      RETURNING
        VALUE(ri_instance) TYPE REF TO zif_gha_github_pull_requests .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_GITHUB_FACTORY IMPLEMENTATION.


  METHOD get_pull_requests.

    ri_instance = NEW zcl_gha_github_pull_requests(
      iv_owner = iv_owner
      iv_repo  = iv_repo ).

  ENDMETHOD.
ENDCLASS.
