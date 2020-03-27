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
      BEGIN OF ty_coverage_st,
        object       TYPE sobj_name,
        executed     TYPE i,
        not_executed TYPE i,
        percentage   TYPE decfloat16,
        type         TYPE string,
      END OF ty_coverage_st .
    TYPES:
      ty_coverage_tt TYPE STANDARD TABLE OF ty_coverage_st WITH EMPTY KEY .
    TYPES:
      BEGIN OF ty_coverage_pct_st,
        branch_percentage    TYPE p LENGTH 5 DECIMALS 2,
        block_percentage     TYPE p LENGTH 5 DECIMALS 2,
        statement_percentage TYPE p LENGTH 5 DECIMALS 2,
      END OF ty_coverage_pct_st.

    TYPES:
      BEGIN OF ty_result,
        tadir       TYPE tadir,
        has_skipped TYPE abap_bool,
        tests       TYPE ty_tests,
        coverages   TYPE ty_coverage_tt,
      END OF ty_result .
    TYPES:
      ty_results TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY .

    TYPES:
      BEGIN OF ty_cov_result,
        coverage TYPE ty_coverage_pct_st,
        results  TYPE ty_results,
      END OF ty_cov_result.

    METHODS run
      IMPORTING
        !iv_devclass      TYPE devclass
      RETURNING
        VALUE(rt_results) TYPE ty_results
      RAISING
        zcx_abapgit_exception .
    METHODS run_with_coverage
      IMPORTING
        !iv_devclass         TYPE devclass
      RETURNING
        VALUE(rs_cov_result) TYPE ty_cov_result
      RAISING
        zcx_abapgit_exception .
  PROTECTED SECTION.

    METHODS calc_coverage_pct
      IMPORTING
        !it_results            TYPE ty_results
      RETURNING
        VALUE(rs_coverage_pct) TYPE ty_coverage_pct_st .
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
    METHODS run_coverage
      IMPORTING
        !is_tadir             TYPE tadir
      EXPORTING
        !et_tests             TYPE ty_tests
        !ev_has_skipped_tests TYPE abap_bool
        !et_coverages         TYPE ty_coverage_tt
      RAISING
        cx_scv_call_error .
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


  METHOD calc_coverage_pct.

    DATA: lv_branch_exe      TYPE i,
          lv_branch_total    TYPE i,
          lv_block_exe       TYPE i,
          lv_block_total     TYPE i,
          lv_statement_exe   TYPE i,
          lv_statement_total TYPE i.

    LOOP AT it_results INTO DATA(ls_result).
      LOOP AT ls_result-coverages INTO DATA(ls_coverage).
        CASE ls_coverage-type.
          WHEN 'Branch Coverage'.
            lv_branch_exe = lv_branch_exe + ls_coverage-executed.
            lv_branch_total = lv_branch_total + ls_coverage-executed + ls_coverage-not_executed.
          WHEN 'Processing Block Coverage'.
            lv_block_exe = lv_block_exe + ls_coverage-executed.
            lv_block_total = lv_block_total + ls_coverage-not_executed.
          WHEN 'Statement Coverage'.
            lv_statement_exe = lv_statement_exe + ls_coverage-executed.
            lv_statement_total = lv_statement_total + ls_coverage-executed + ls_coverage-not_executed.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.

    rs_coverage_pct-branch_percentage = lv_branch_exe / lv_branch_total * 100.
    rs_coverage_pct-block_percentage = lv_block_exe / lv_block_total * 100.
    rs_coverage_pct-statement_percentage = lv_statement_exe / lv_statement_total * 100.

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
    DELETE lt_tadir WHERE object <> 'CLAS' AND object <> 'PROG' AND object <> 'FUGR'.

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


  METHOD run_coverage.

    CONSTANTS: lc_harmless TYPE saunit_d_allowed_risk_level VALUE 11,
               lc_medium   TYPE saunit_d_allowed_rt_duration VALUE 24.

    DATA: lo_casted             TYPE REF TO cl_saunit_internal_result,
          lo_cvrg_rslt_provider TYPE REF TO if_aucv_cvrg_rslt_provider.

    get_runner( abap_true )->run_for_program_keys(
      EXPORTING
        i_limit_on_duration_category = lc_medium
        i_limit_on_risk_level        = lc_harmless
        i_program_keys               = VALUE #( ( CORRESPONDING #( is_tadir MAPPING obj_type = object ) ) )
      IMPORTING
        e_aunit_result               = DATA(li_aunit)
        e_coverage_result            = lo_cvrg_rslt_provider ).

    DATA(lo_result) = lo_cvrg_rslt_provider->build_coverage_result( ).

    LOOP AT lo_result->get_coverages( ) INTO DATA(ls_coverages).
      INSERT VALUE #( object       = is_tadir-obj_name
                      executed     = ls_coverages->get_executed( )
                      not_executed = ls_coverages->get_not_executed( )
                      percentage   = ls_coverages->get_percentage( )
                      type         = ls_coverages->type->text
                      ) INTO TABLE et_coverages.
    ENDLOOP.

    lo_casted ?= li_aunit.

    ev_has_skipped_tests = lo_casted->f_task_data-info-has_skipped.

    et_tests = analyze_result( lo_casted ).

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


  METHOD run_with_coverage.

    DATA(lt_tadir) = zcl_abapgit_factory=>get_tadir( )->read( iv_devclass ).
    DELETE lt_tadir WHERE object <> 'CLAS' AND object <> 'PROG' AND object <> 'FUGR'.

    LOOP AT lt_tadir INTO DATA(ls_tadir).

      TRY.
          run_coverage(
            EXPORTING
              is_tadir             = CORRESPONDING #( ls_tadir )
            IMPORTING
              et_tests             = DATA(lt_tests)
              ev_has_skipped_tests = DATA(lv_has_skipped)
              et_coverages         = DATA(lt_coverages) ).
        CATCH cx_scv_call_error.
          CONTINUE.
      ENDTRY.

      APPEND VALUE #(
        tadir       = CORRESPONDING #( ls_tadir )
        has_skipped = lv_has_skipped
        tests       = lt_tests
        coverages   = lt_coverages ) TO rs_cov_result-results.

    ENDLOOP.

    rs_cov_result-coverage = calc_coverage_pct( rs_cov_result-results ).

  ENDMETHOD.
ENDCLASS.
