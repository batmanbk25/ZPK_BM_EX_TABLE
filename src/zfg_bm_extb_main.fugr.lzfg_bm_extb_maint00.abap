*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTB_BM_EXTB_TAB.................................*
DATA:  BEGIN OF STATUS_ZTB_BM_EXTB_TAB               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTB_BM_EXTB_TAB               .
CONTROLS: TCTRL_ZTB_BM_EXTB_TAB
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZTB_BM_EXTB_TAB               .
TABLES: ZTB_BM_EXTB_TAB                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
