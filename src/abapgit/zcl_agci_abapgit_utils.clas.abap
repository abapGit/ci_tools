CLASS zcl_agci_abapgit_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS find_repo_by_package
      IMPORTING
        !iv_package    TYPE devclass
      RETURNING
        VALUE(ro_repo) TYPE REF TO zcl_abapgit_repo_online
      RAISING
        zcx_abapgit_exception .
    METHODS find_repo_by_url
      IMPORTING
        !iv_url1       TYPE string
        !iv_url2       TYPE string OPTIONAL
      RETURNING
        VALUE(ro_repo) TYPE REF TO zcl_abapgit_repo_online
      RAISING
        zcx_abapgit_exception .
    METHODS list_branches
      IMPORTING
        !io_repo           TYPE REF TO zcl_abapgit_repo_online
      RETURNING
        VALUE(rt_branches) TYPE zif_abapgit_git_definitions=>ty_git_branch_list_tt
      RAISING
        zcx_abapgit_exception .
    METHODS pull_branch
      IMPORTING
        !io_repo TYPE REF TO zcl_abapgit_repo_online
        !iv_name TYPE string
      RAISING
        zcx_abapgit_exception .
    METHODS pull_by_sha1
      IMPORTING
        !io_repo TYPE REF TO zcl_abapgit_repo_online
        !iv_sha1 TYPE string
      RAISING
        zcx_abapgit_exception .
  PROTECTED SECTION.

    METHODS overwrite_all
      IMPORTING
        !is_checks       TYPE zif_abapgit_definitions=>ty_deserialize_checks
      RETURNING
        VALUE(rs_checks) TYPE zif_abapgit_definitions=>ty_deserialize_checks .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AGCI_ABAPGIT_UTILS IMPLEMENTATION.


  METHOD find_repo_by_package.

    DATA(lt_list) = zcl_abapgit_repo_srv=>get_instance( )->list( ).

    LOOP AT lt_list INTO DATA(lo_repo).
      IF lo_repo->is_offline( ) = abap_false.
        DATA(lo_online) = CAST zcl_abapgit_repo_online( lo_repo ).
        IF lo_online->get_package( ) = iv_package.
          ro_repo = lo_online.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD find_repo_by_url.

    DATA(lt_list) = zcl_abapgit_repo_srv=>get_instance( )->list( ).

    LOOP AT lt_list INTO DATA(lo_repo).
      IF lo_repo->is_offline( ) = abap_false.
        DATA(lo_online) = CAST zcl_abapgit_repo_online( lo_repo ).
        IF lo_online->get_url( ) = iv_url1 OR lo_online->get_url( ) = iv_url2.
          ro_repo = lo_online.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD list_branches.

    DATA(lo_branch_list) = zcl_abapgit_git_transport=>branches( io_repo->get_url( ) ).

    rt_branches = lo_branch_list->get_all( ).

  ENDMETHOD.


  METHOD overwrite_all.

    rs_checks = is_checks.

    LOOP AT rs_checks-overwrite ASSIGNING FIELD-SYMBOL(<ls_overwrite>).
      <ls_overwrite>-decision = 'Y'.
    ENDLOOP.

    LOOP AT rs_checks-warning_package ASSIGNING FIELD-SYMBOL(<ls_warning_package>).
      <ls_warning_package>-decision = 'Y'.
    ENDLOOP.

    IF rs_checks-requirements-met = 'N'.
      rs_checks-requirements-decision = 'Y'.
    ENDIF.

    ASSERT rs_checks-transport-required = abap_false.
* todo, set rs_checks-transport-transport to transport number if required.

  ENDMETHOD.


  METHOD pull_branch.

    io_repo->select_branch( iv_name ).

    DATA(ls_checks) = overwrite_all( io_repo->deserialize_checks( ) ).

    DATA(lo_log) = NEW zcl_abapgit_log( ).

    io_repo->deserialize(
      is_checks = ls_checks
      ii_log    = lo_log ).

    DATA(lt_status) = io_repo->status( ).

* todo, check log and status

  ENDMETHOD.


  METHOD pull_by_sha1.

    DATA(lt_branches) = list_branches( io_repo ).

    READ TABLE lt_branches INTO DATA(ls_branch) WITH KEY sha1 = iv_sha1.
    IF sy-subrc = 0.
      pull_branch( io_repo = io_repo
                   iv_name = ls_branch-name ).
    ELSE.
      zcx_abapgit_exception=>raise( |Branch for SHA1 not found| ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
