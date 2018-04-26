SELECT PNM.PNM_AUTO_KEY, PNM.PN, MAX(LT.AVG_PO) , MAX(BO.SUM_PO), MAX(SI.SUM_STI_QTY), MAX(SU.SUM_STI_REVERSE),PNM.DESCRIPTION, 
WHS.WAREHOUSE_CODE, PNM.QTY_OH, PNM.LEAD_DAYS, PNM.IC_UDF_001, PNM.SAFETY_DAYS,
MAX(WHL.QTY_MIN), MAX(WHL.QTY_MAX), MAX(STI.TRAN_DATE),MAX(OH.SUM_QTY_AVAILABLE)  
        
FROM (  SELECT AVG((STM.REC_DATE -  POD.ENTRY_DATE )) AVG_PO , STM.PNM_AUTO_KEY, POD.WHS_AUTO_KEY
        FROM PO_DETAIL POD, STOCK STM, WAREHOUSE WHS
        WHERE POD.QTY_REC > 0
        AND POD.POD_AUTO_KEY = STM.POD_AUTO_KEY 
        AND POD.WHS_AUTO_KEY = WHS.WHS_AUTO_KEY
        AND POD.ENTRY_DATE BETWEEN {?Begin Date} AND {?End Date}
        GROUP BY STM.PNM_AUTO_KEY, POD.WHS_AUTO_KEY ) LT,       
        (
        SELECT SUM(POD.QTY_BACK_ORDER) SUM_PO , POD.PNM_AUTO_KEY, POD.WHS_AUTO_KEY
        FROM PO_DETAIL POD, PO_HEADER POH, WAREHOUSE WHS
        WHERE POD.QTY_BACK_ORDER >0  
        AND POH.OPEN_FLAG = 'T'
        AND POD.POH_AUTO_KEY = POH.POH_AUTO_KEY 
        AND POD.WHS_AUTO_KEY  = WHS.WHS_AUTO_KEY
        GROUP BY POD.PNM_AUTO_KEY, POD.WHS_AUTO_KEY) BO, 
        (
        SELECT SUM(STI.QTY) SUM_STI_QTY, PNM.PNM_AUTO_KEY, WHS.WHS_AUTO_KEY
        FROM STOCK_TI STI, PARTS_MASTER PNM, STOCK STM, WAREHOUSE WHS
        WHERE STM.PNM_AUTO_KEY = PNM.PNM_AUTO_KEY
        AND STM.STM_AUTO_KEY = STI.STM_AUTO_KEY
        AND STM.WHS_AUTO_KEY = WHS.WHS_AUTO_KEY
        AND STI.TRAN_DATE  BETWEEN {?Begin Date} AND {?End Date}
        AND STI.TI_TYPE = 'I'
        GROUP BY PNM.PNM_AUTO_KEY, WHS.WHS_AUTO_KEY) SI,
        (
        SELECT SUM(STI.QTY_REVERSE) SUM_STI_REVERSE, PNM.PNM_AUTO_KEY, WHS.WHS_AUTO_KEY
        FROM STOCK_TI STI, PARTS_MASTER PNM, STOCK STM, WAREHOUSE WHS
        WHERE STM.PNM_AUTO_KEY = PNM.PNM_AUTO_KEY
        AND STM.STM_AUTO_KEY = STI.STM_AUTO_KEY
        AND STM.WHS_AUTO_KEY = WHS.WHS_AUTO_KEY
        AND STI.TRAN_DATE  BETWEEN {?Begin Date} AND {?End Date}
        AND STI.TI_TYPE = 'I'
        GROUP BY PNM.PNM_AUTO_KEY, WHS.WHS_AUTO_KEY) SU,
        (
        SELECT SUM(STM.QTY_AVAILABLE) SUM_QTY_AVAILABLE, PNM.PNM_AUTO_KEY, WHS.WHS_AUTO_KEY
        FROM  PARTS_MASTER PNM, STOCK STM, WAREHOUSE WHS
        WHERE STM.PNM_AUTO_KEY = PNM.PNM_AUTO_KEY
        AND STM.WHS_AUTO_KEY = WHS.WHS_AUTO_KEY
        GROUP BY PNM.PNM_AUTO_KEY, WHS.WHS_AUTO_KEY) OH,
                                
                                
  PARTS_MASTER PNM, STOCK STM, WAREHOUSE WHS, STOCK_TI STI, WAREHOUSE_LEVEL WHL

  WHERE LT.PNM_AUTO_KEY (+) = STM.PNM_AUTO_KEY
  AND LT.WHS_AUTO_KEY (+) = STM.WHS_AUTO_KEY
  AND BO.WHS_AUTO_KEY (+) = STM.WHS_AUTO_KEY 
  AND BO.PNM.AUTO_KEY (+) = STM.pnm_auto_key   
  AND SI.PNM_AUTO_KEY (+)= STM.PNM_AUTO_KEY
  AND SI.WHS_AUTO_KEY (+)= STM.WHS_AUTO_KEY
  AND SU.PNM_AUTO_KEY (+)= STM.PNM_AUTO_KEY
  AND SU.WHS_AUTO_KEY (+)= STM.WHS_AUTO_KEY
  AND OH.PNM_AUTO_KEY (+)= STM.PNM_AUTO_KEY
  AND OH.WHS_AUTO_KEY (+)= STM.WHS_AUTO_KEY
  AND STI.STM_AUTO_KEY (+)= STM.STM_AUTO_KEY  
  AND WHL.PNM_AUTO_KEY (+) = PNM.PNM_AUTO_KEY 
  AND STM.PNM_AUTO_KEY = PNM.PNM_AUTO_KEY
  AND STM.WHS_AUTO_KEY = WHS.WHS_AUTO_KEY

  
  GROUP BY WHS.WHS_AUTO_KEY, PNM.PNM_AUTO_KEY, PNM.PN, PNM.DESCRIPTION, WHS.WAREHOUSE_CODE, 
  PNM.QTY_OH, PNM.LEAD_DAYS, PNM.IC_UDF_001, PNM.SAFETY_DAYS
  
  ORDER BY PNM.PN ASC