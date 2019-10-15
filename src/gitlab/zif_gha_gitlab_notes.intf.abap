INTERFACE zif_gha_gitlab_notes
  PUBLIC .


  TYPES:
    BEGIN OF ty_list,
      id   TYPE i,
      body TYPE string,
    END OF ty_list .
  TYPES:
    ty_list_tt TYPE STANDARD TABLE OF ty_list WITH EMPTY KEY .

  METHODS create_merge_request
    IMPORTING
      !iv_merge_request_iid TYPE i
      !iv_body              TYPE string .
  METHODS list_merge_request
    IMPORTING
      !iv_merge_request_iid TYPE i
    RETURNING
      VALUE(rt_list)        TYPE ty_list_tt .
ENDINTERFACE.
