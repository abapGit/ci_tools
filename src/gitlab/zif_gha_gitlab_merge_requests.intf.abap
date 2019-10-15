INTERFACE zif_gha_gitlab_merge_requests
  PUBLIC .


  TYPES:
    BEGIN OF ty_list,
      id            TYPE i,
      iid           TYPE i,
      project_id    TYPE i,
      title         TYPE string,
      description   TYPE string,
      state         TYPE string,
      sha           TYPE string,
      target_branch TYPE string,
      source_branch TYPE string,
    END OF ty_list .
  TYPES:
    ty_list_tt TYPE STANDARD TABLE OF ty_list WITH EMPTY KEY .

  METHODS list
    IMPORTING
      !iv_project_id TYPE i
      !iv_state      TYPE string OPTIONAL
    RETURNING
      VALUE(rt_list) TYPE ty_list_tt .
ENDINTERFACE.
