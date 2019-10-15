class ZCL_GHA_GITLAB_FACTORY definition
  public
  create public .

public section.

  class-methods GET_MERGE_REQUESTS
    returning
      value(RI_INSTANCE) type ref to ZIF_GHA_GITLAB_MERGE_REQUESTS .
  class-methods GET_NOTES
    importing
      !IV_PROJECT_ID type I
    returning
      value(RI_NOTES) type ref to ZIF_GHA_GITLAB_NOTES .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_GHA_GITLAB_FACTORY IMPLEMENTATION.


  METHOD get_merge_requests.

    ri_instance = NEW zcl_gha_gitlab_merge_requests( ).

  ENDMETHOD.


  METHOD get_notes.

    ri_notes = NEW zcl_gha_gitlab_notes( iv_project_id ).

  ENDMETHOD.
ENDCLASS.
