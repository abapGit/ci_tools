CLASS zcl_agci_unit_test_pdf DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS output
      IMPORTING
        !iv_devclass TYPE devclass
      RAISING
        zcx_abapgit_exception .
  PROTECTED SECTION.

    METHODS call_smartform
      IMPORTING
        !is_coverage TYPE zcl_agci_unit_tests=>ty_cov_result .
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



  ENDMETHOD.
ENDCLASS.
