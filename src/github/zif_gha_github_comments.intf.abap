INTERFACE zif_gha_github_comments
  PUBLIC .


  TYPES:
    BEGIN OF ty_list,
      id   TYPE i,
      body TYPE string,
    END OF ty_list .
  TYPES:
    ty_list_tt TYPE STANDARD TABLE OF ty_list WITH EMPTY KEY .

  METHODS create
    IMPORTING
      !iv_issue_number TYPE i
      !iv_body         TYPE string .
  METHODS get
    IMPORTING
      !iv_number TYPE i .
  METHODS list
    IMPORTING
      !iv_issue      TYPE i
    RETURNING
      VALUE(rt_list) TYPE ty_list_tt .
ENDINTERFACE.
