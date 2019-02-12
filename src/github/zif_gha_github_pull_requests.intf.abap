INTERFACE zif_gha_github_pull_requests
  PUBLIC .

  TYPES:
    BEGIN OF ty_list,
      number   TYPE i,
      title    TYPE string,
      state    TYPE string,
      html_url TYPE string,
      body     TYPE string,
      base_ref TYPE string,
      base_sha TYPE string,
      head_ref TYPE string,
      head_sha TYPE string,
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
  METHODS update
    IMPORTING
      !iv_number TYPE i
      !iv_state  TYPE string .

ENDINTERFACE.
