INTERFACE zif_gha_github_pull_requests
  PUBLIC .

  TYPES: BEGIN OF ty_branch,
           ref       TYPE string,
           sha       TYPE string,
           html_url  TYPE string,
           clone_url TYPE string,
         END OF ty_branch.

  TYPES:
    BEGIN OF ty_list,
      number   TYPE i,
      title    TYPE string,
      state    TYPE string,
      html_url TYPE string,
      body     TYPE string,
      base     TYPE ty_branch,
      head     TYPE ty_branch,
    END OF ty_list .
  TYPES:
    ty_list_tt TYPE STANDARD TABLE OF ty_list WITH EMPTY KEY .

  METHODS create
    IMPORTING
      !iv_title        TYPE string
      !iv_head         TYPE string
      !iv_base         TYPE string
      !iv_body         TYPE string OPTIONAL
    RETURNING
      VALUE(rv_number) TYPE i .
  METHODS get
    IMPORTING
      !iv_number TYPE i .
  METHODS list
    RETURNING
      VALUE(rt_list) TYPE ty_list_tt .
  METHODS merge
    IMPORTING
      !iv_number       TYPE i
      !iv_merge_method TYPE string .
  METHODS update
    IMPORTING
      !iv_number TYPE i
      !iv_state  TYPE string .
ENDINTERFACE.
