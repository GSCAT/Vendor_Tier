Select 		
CASE
			WHEN a11.PAR_VENDOR_ID = (-1) THEN a11.VENDOR_ID
			ELSE a11.PAR_VENDOR_ID END AS MasterVendorID,
	a11.PAR_VENDOR_ID,
	a21.VENDOR_LEGAL_DESC as PAR_VENDOR_LEGAL_DESC,
	a11.VENDOR_ID,
	b21.VENDOR_LEGAL_DESC as VENDOR_LEGAL_DESC,
	case
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = '3P' then '3P & Lic'
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'A_' then 'Accessories'
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'AL' then 'IP'
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'D_' then 'Denim and Woven Bottoms'
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'DW' then 'Denim and Woven Bottoms'
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'I_' then 'IP'
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'K_' then 'Knits'
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'KF' then 'Knits'
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'LC' then '3P & Lic'
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'S_' then 'Sweaters'	
		when SUBSTR(a112.AGT_DEPT_ABBR_DESC, 1, 2) = 'W_' then 'Wovens'
		else 'Category Other'
		end as Category,
	sum(ELC_AMT_USD * FCST_QTY) as Total_FCST_ELC
	
	FROM VIEWORDER.VIUFF_INBND_UNT_FCST_FCT a11
	
	left outer join	 VIEWORDER.VVLNL_VND_LEGAL_NM_LOOKUP a21
	 on (MasterVendorID = a21.VENDOR_ID)
	left outer join	 VIEWORDER.VVLNL_VND_LEGAL_NM_LOOKUP b21
	 on (a11.VENDOR_ID = b21.VENDOR_ID)
	 left outer join (Select  AGT_DEPT_ID, AGT_DEPT_ABBR_DESC  as AGT_DEPT_ABBR_DESC, SRC_LST_UPDT_DT from ViewDST.TAGDL_AGT_DEPT_LOOKUP 
		Qualify
		row_number() Over (partition by AGT_DEPT_ID order by SRC_LST_UPDT_DT desc)= 1 ) a112
			on a11.AGT_DEPT_ID = a112.AGT_DEPT_ID
	 
	 where ((a11.SHIP_CANCEL_DATE between DATE '2016-01-31' and CURRENT_DATE ) or (a11.PLANNED_STOCKED_DATE between DATE '2016-01-31' and CURRENT_DATE))
	 
	 group by
	 	MasterVendorID,
		a11.PAR_VENDOR_ID,
		a11.VENDOR_ID,
		a21.VENDOR_LGCY_ID,
		a21.VENDOR_LEGAL_DESC,
		b21.VENDOR_LEGAL_DESC,
		Category;