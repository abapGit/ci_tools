CLASS zcl_gha_github_comments DEFINITION
  PUBLIC
  CREATE PROTECTED

  GLOBAL FRIENDS zcl_gha_github_factory .

  PUBLIC SECTION.

    INTERFACES zif_gha_github_comments .
  PROTECTED SECTION.

    DATA mv_owner TYPE string .
    DATA mv_repo TYPE string .

    METHODS constructor
      IMPORTING
        !iv_owner TYPE string
        !iv_repo  TYPE string .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GHA_GITHUB_COMMENTS IMPLEMENTATION.


  METHOD constructor.

    mv_owner = iv_owner.
    mv_repo = iv_repo.

  ENDMETHOD.


  METHOD zif_gha_github_comments~create.

    ASSERT 0 = 1. " todo

  ENDMETHOD.


  METHOD zif_gha_github_comments~get.

    ASSERT 0 = 1. " todo

  ENDMETHOD.


  METHOD zif_gha_github_comments~list.

* todo, add input parameter "since"

    DATA(lo_client) = zcl_gha_http_client=>create_by_url(
      |https://api.github.com/repos/{ mv_owner }/{ mv_repo }/issues/{ iv_issue }/comments| ).

    DATA(li_response) = lo_client->send_receive( ).

    DATA(lv_data) = li_response->get_cdata( ).

    BREAK-POINT.

  ENDMETHOD.
ENDCLASS.
