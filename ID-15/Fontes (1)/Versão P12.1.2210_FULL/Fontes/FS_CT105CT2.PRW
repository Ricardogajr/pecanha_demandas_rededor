#Include 'Protheus.ch'

/*
ExecBlock("CT105CT2", .F., .F., {__nQuantas, dDatalanc,cLote,cSubLote,cDoc,lCusto,lItem,lCLVL,nTotInf,_lAtSldBase,_lReproc })
*/

User Function CT105CT2()

Local	n_Quantas 		:= ParamIxb[1]
Local	dDatalanc 		:= ParamIxb[2]
Local	cLote 			:= ParamIxb[3]
Local	cSubLote 		:= ParamIxb[4]
Local	cDoc 			:= ParamIxb[5]
/*
Local	lCusto 			:= aParamIxb[6]
Local	lItem 			:= aParamIxb[7]
Local	lCLVL 			:= aParamIxb[8]
Local	nTotInf 		:= aParamIxb[9]
Local	lAtSldBase 		:= aParamIxb[10]
Local	lReproc  		:= aParamIxb[11]
*/
//
IF ISINCALLSTACK("U_F1304001")
	U_F1304002(n_Quantas, dDatalanc, cLote, cSubLote, cDoc)
ENDIF	
	
Return(Nil)


