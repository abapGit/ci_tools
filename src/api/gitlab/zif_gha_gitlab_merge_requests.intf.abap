INTERFACE zif_gha_gitlab_merge_requests
  PUBLIC .


  TYPES:
    BEGIN OF ty_merge_request,
      id               TYPE i,
      iid              TYPE i,
      project_id       TYPE i,
      title            TYPE string,
      description      TYPE string,
      state            TYPE string,
      sha              TYPE string,
      target_branch    TYPE string,
      source_branch    TYPE string,
      work_in_progress TYPE string,
    END OF ty_merge_request .
  TYPES:
    ty_merge_request_list TYPE STANDARD TABLE OF ty_merge_request WITH EMPTY KEY .

  TYPES:
    BEGIN OF ty_pipeline,
      id     TYPE i,
      sha    TYPE string,
      ref    TYPE string,
      status TYPE string,
    END OF ty_pipeline .
  TYPES:
    ty_pipeline_list TYPE STANDARD TABLE OF ty_pipeline WITH EMPTY KEY .

  METHODS list
    IMPORTING
      !iv_project_id TYPE i
      !iv_state      TYPE string OPTIONAL
    RETURNING
      VALUE(rt_list) TYPE ty_merge_request_list .
  METHODS list_pipelines
    IMPORTING
      !iv_project_id        TYPE i
      !iv_merge_request_iid TYPE i
    RETURNING
      VALUE(rt_list)        TYPE ty_pipeline_list .
ENDINTERFACE.
