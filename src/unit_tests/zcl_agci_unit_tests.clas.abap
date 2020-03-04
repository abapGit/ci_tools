CLASS zcl_agci_unit_tests DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_test,
        program_name TYPE objname,
        class_name   TYPE objname,
        method_name  TYPE objname,
        kind         TYPE c LENGTH 1,
      END OF ty_test .
    TYPES:
      ty_tests TYPE STANDARD TABLE OF ty_test WITH EMPTY KEY .
    TYPES:
      BEGIN OF ty_result,
        tadir       TYPE tadir,
        has_skipped TYPE abap_bool,
        tests       TYPE ty_tests,
      END OF ty_result .
    TYPES:
      ty_results TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY .

    METHODS run
      IMPORTING
        !iv_devclass      TYPE devclass
      RETURNING
        VALUE(rt_results) TYPE ty_results
      RAISING
        zcx_abapgit_exception .
  PROTECTED SECTION.

    METHODS analyze_result
      IMPORTING
        !io_result      TYPE REF TO cl_saunit_internal_result
      RETURNING
        VALUE(rt_tests) TYPE ty_tests .
    METHODS get_runner
      IMPORTING
        !iv_coverage     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_runner) TYPE REF TO cl_aucv_test_runner_abstract .
    METHODS run_normal
      IMPORTING
        !is_tadir             TYPE tadir
      EXPORTING
        !et_tests             TYPE ty_tests
        !ev_has_skipped_tests TYPE abap_bool .
    METHODS has_tests
      IMPORTING
        !is_tadir           TYPE tadir
      RETURNING
        VALUE(rv_has_tests) TYPE abap_bool .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AGCI_UNIT_TESTS IMPLEMENTATION.


  METHOD analyze_result.

    LOOP AT io_result->f_task_data-programs INTO DATA(ls_program).
      DATA(lv_program_index) = sy-tabix.
      LOOP AT ls_program-classes INTO DATA(ls_class).
        DATA(lv_class_index) = sy-tabix.
        LOOP AT ls_class-methods INTO DATA(ls_method).
          DATA(lv_method_index) = sy-tabix.

          READ TABLE io_result->f_task_data-alerts_by_indicies WITH KEY
            program_ndx = lv_program_index
            class_ndx = lv_class_index
            method_ndx = lv_method_index
            INTO DATA(ls_alert).
          IF sy-subrc = 0.
            DATA(lv_kind) = ls_alert-alerts[ 1 ]-kind.
          ELSE.
            CLEAR lv_kind.
          ENDIF.

          APPEND VALUE #(
            program_name = ls_program-info-name
            class_name   = ls_class-info-name
            method_name  = ls_method-info-name
            kind         = lv_kind ) TO rt_tests.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_runner.

    DATA: lo_passport TYPE REF TO object.


    CALL METHOD ('\PROGRAM=SAPLSAUCV_GUI_RUNNER\CLASS=PASSPORT')=>get
      RECEIVING
        result = lo_passport.

    IF iv_coverage = abap_true.
      ro_runner = cl_aucv_test_runner_coverage=>create( lo_passport ).
    ELSE.
      ro_runner = cl_aucv_test_runner_standard=>create( lo_passport ).
    ENDIF.

  ENDMETHOD.


  METHOD has_tests.

    DATA(ls_aunit_info) = cl_aunit_prog_info=>get_program_info(
      allow_commit = abap_true
      obj_type     = is_tadir-object
      obj_name     = is_tadir-obj_name ).

    rv_has_tests = ls_aunit_info-has_tests.

  ENDMETHOD.


  METHOD run.

    DATA(lt_tadir) = zcl_abapgit_factory=>get_tadir( )->read( iv_devclass ).
    DELETE lt_tadir WHERE object <> 'CLAS'.

    LOOP AT lt_tadir INTO DATA(ls_tadir).

      IF has_tests( CORRESPONDING #( ls_tadir ) ) = abap_false.
        CONTINUE.
      ENDIF.

      run_normal(
        EXPORTING
          is_tadir             = CORRESPONDING #( ls_tadir )
        IMPORTING
          et_tests             = DATA(lt_tests)
          ev_has_skipped_tests = DATA(lv_has_skipped) ).

      APPEND VALUE #(
        tadir       = CORRESPONDING #( ls_tadir )
        has_skipped = lv_has_skipped
        tests       = lt_tests ) TO rt_results.

    ENDLOOP.

  ENDMETHOD.


  METHOD run_normal.

    CONSTANTS: lc_harmless TYPE saunit_d_allowed_risk_level VALUE 11,
               lc_medium   TYPE saunit_d_allowed_rt_duration VALUE 24.

    DATA: lo_casted TYPE REF TO cl_saunit_internal_result.

    get_runner( )->run_for_program_keys(
      EXPORTING
        i_limit_on_duration_category = lc_medium
        i_limit_on_risk_level        = lc_harmless
        i_program_keys               = VALUE #( ( CORRESPONDING #( is_tadir MAPPING obj_type = object ) ) )
      IMPORTING
        e_aunit_result               = DATA(li_aunit) ).

    lo_casted ?= li_aunit.

    ev_has_skipped_tests = lo_casted->f_task_data-info-has_skipped.

    et_tests = analyze_result( lo_casted ).

  ENDMETHOD.
ENDCLASS.
