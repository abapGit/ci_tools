INTERFACE zif_gha_github_check_suites
  PUBLIC .

  TYPES: BEGIN OF ty_suite,
           id         TYPE i,
           status     TYPE string,
           conclusion TYPE string,
         END OF ty_suite.

  TYPES: ty_suites TYPE STANDARD TABLE OF ty_suite WITH DEFAULT KEY.

  METHODS list
    IMPORTING
      !iv_ref        TYPE string
    RETURNING
      VALUE(rt_list) TYPE ty_suites.

ENDINTERFACE.
