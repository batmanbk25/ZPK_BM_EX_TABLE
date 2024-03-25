*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZFG_BM_EXTB_MAIN
*   generation date: 19.11.2022 at 11:20:06
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZFG_BM_EXTB_MAIN   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
