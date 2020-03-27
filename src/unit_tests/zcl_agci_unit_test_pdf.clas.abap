CLASS zcl_agci_unit_test_pdf DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_info,
             sysid    LIKE sy-sysid,
             devclass TYPE devclass,
             url      TYPE string,
             branch   TYPE string,
             time     TYPE string,
           END OF ty_info.

    METHODS output
      IMPORTING
        !iv_devclass TYPE devclass
      RAISING
        zcx_abapgit_exception .
  PROTECTED SECTION.

    METHODS call_smartform
      IMPORTING
        !is_coverage TYPE zcl_agci_unit_tests=>ty_cov_result
        !is_info     TYPE ty_info .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AGCI_UNIT_TEST_PDF IMPLEMENTATION.


  METHOD call_smartform.

    DATA: lv_fm TYPE rs38l_fnam.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname = 'ZAGCI_UNIT_TEST_REPORT'
      IMPORTING
        fm_name  = lv_fm.

    CALL FUNCTION lv_fm
      EXPORTING
*       ARCHIVE_INDEX    =
*       ARCHIVE_INDEX_TAB          =
*       ARCHIVE_PARAMETERS         =
*       CONTROL_PARAMETERS         =
*       MAIL_APPL_OBJ    =
*       MAIL_RECIPIENT   =
*       MAIL_SENDER      =
*       OUTPUT_OPTIONS   =
*       USER_SETTINGS    = 'X'
        is_coverage      = is_coverage
        is_info          = is_info
* IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO  =
*       JOB_OUTPUT_OPTIONS         =
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        user_canceled    = 4
        OTHERS           = 5.
    IF sy-subrc <> 0.
      BREAK-POINT.
    ENDIF.

  ENDMETHOD.


  METHOD output.

    DATA(ls_coverage) = NEW zcl_agci_unit_tests( )->run_with_coverage( iv_devclass ).

    DATA(ls_info) = VALUE ty_info(
      sysid    = sy-sysid
      devclass = iv_devclass
      time     = |{ sy-datlo DATE = ENVIRONMENT } { sy-timlo TIME = ENVIRONMENT } { sy-zonlo }| ).

    DATA(lo_repo) = NEW zcl_agci_abapgit_utils( )->find_repo_by_package( iv_devclass ).
    IF lo_repo IS BOUND.
      ls_info-url = lo_repo->get_url( ).
      ls_info-branch = lo_repo->get_branch_name( ).
    ENDIF.

    call_smartform(
      is_coverage = ls_coverage
      is_info     = ls_info ).

  ENDMETHOD.
ENDCLASS.
