INTERFACE zif_gha_gitlab_projects
  PUBLIC .

  TYPES: BEGIN OF ty_project,
           id                  TYPE i,
           description         TYPE string,
           name                TYPE string,
           path_with_namespace TYPE string,
           default_branch      TYPE string,
           http_url_to_repo    TYPE string,
           web_url             TYPE string,
           visibility          TYPE string,
         END OF ty_project.

  TYPES: ty_projects TYPE STANDARD TABLE OF ty_project WITH EMPTY KEY.

  METHODS list_by_user
    IMPORTING
      !iv_user           TYPE string
    RETURNING
      VALUE(rt_projects) TYPE ty_projects.
ENDINTERFACE.
