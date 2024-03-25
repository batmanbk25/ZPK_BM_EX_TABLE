FUNCTION CONVERSION_EXIT_ZETMA_OUTPUT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(INPUT) TYPE  ANY
*"  EXPORTING
*"     REFERENCE(OUTPUT) TYPE  ANY
*"--------------------------------------------------------------------

  CALL FUNCTION 'CONVERSION_EXIT_ZZALL_OUTPUT'
    EXPORTING
      INPUT     = INPUT
      I_DOMNAME = 'ZDO_BM_EXTB_MATCHING'
    IMPORTING
      OUTPUT    = OUTPUT.

ENDFUNCTION.
