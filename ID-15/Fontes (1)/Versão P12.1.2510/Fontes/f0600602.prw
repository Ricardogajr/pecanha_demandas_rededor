#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} F0600602
Integracao Aprovacao Rescisao x ApData
 
@author Eduardo Fernandes 
@since  19/12/2016
@param cID, characters, descricao
@param cAliasTab, characters, descricao
@param nRecTab, numeric, descricao
@param cOper, characters, descricao
@return Nil  

@project MAN0000007423040_EF_006
@cliente Rededor
@version P12.1.7
             
/*/
User Function F0600602(cID, cAliasTab, nRecTab, cOper)
	Local lRet		:= .T.
	Local cTbl		:= "EF06006"
	Local aValues 	:= {}
	Local aRH4		:= {}
	Local cFilTab	:= ""
	Local cMatTab	:= ""
	Local cTipRes	:= ""
	Local cDtDemis	:= ""
	Local aTblStru	:= {{"EF06006_ID"			, "VARCHAR", 32},;
						{"EF06006_FILIAL"		, "VARCHAR", 8},;
						{"EF06006_MATRICULA"	, "VARCHAR", 6},;
						{"EF06006_DTATEND"		, "VARCHAR", 8},;
						{"EF06006_MOTIVO"		, "VARCHAR", 6},;
						{"EF06006_DTTRANSAC"	, "VARCHAR", 8},;
						{"EF06006_HRTRANSAC"	, "VARCHAR", 8},;
						{"EF06006_OPERACAO"		, "VARCHAR", 6},;
						{"EF06006_STATUS"		, "VARCHAR", 10},;
						{"EF06006_DTPROCESS"	, "VARCHAR", 8},;
						{"EF06006_HRPROCESS"	, "VARCHAR", 8},;					
						{"EF06006_OBSERVA"		, "VARCHAR", 700}}
						
	Local aAreas   	:= {GetArea(), RH3->(GetArea()), RH4->(GetArea()), SRG->(GetArea())}							
	
	Begin Sequence 
		If nRecTab == 0
			lRet := .F. 
			Break
		Endif	
		
		If cAliasTab == "RH3"
			RH3->(dbGoto(nRecTab))
			RH4->(dbSetOrder(1))
			If !RH4->(DbSeek(RH3->RH3_FILIAL + RH3->RH3_CODIGO + "1"))
				lRet := .F. 
				Break
			Else //Carrega os itens
				RH4->(dbEval({|| AAdd(aRH4,{RH4_CAMPO, RH4_VALNOV})},,; 
				{|| RH4_FILIAL + RH4_CODIGO == RH3->RH3_FILIAL + RH3->RH3_CODIGO }))
			Endif
			
			cFilTab	:= RH3->RH3_FILIAL
			cMatTab	:= 	RH3->RH3_MAT
			cTipRes 	:= IIF(AScan(aRH4,{|x| x[1] == "P10_CODRES" }) > 0, aRH4[AScan(aRH4,{|x| x[1] == "P10_CODRES" }),2],"")
			cDtDemis 	:= IIF(AScan(aRH4,{|x| x[1] == "P10_DTDEMI" }) > 0, aRH4[AScan(aRH4,{|x| x[1] == "P10_DTDEMI" }),2],"")
			If "/" $ cDtDemis
				cDtDemis := DToS(CToD(cDtDemis))
			EndIf
		ElseIf cAliasTab == "SRG"
			SRG->(dbGoto(nRecTab))
		
			cFilTab	:= 	SRG->RG_FILIAL
			cMatTab	:= 	SRG->RG_MAT
			cTipRes 	:=	SRG->RG_TIPORES
			cDtDemis 	:= 	DtoS(SRG->RG_DATADEM)
		Endif
		
		If Empty(cTipRes) .Or. Empty(cDtDemis)
			lRet := .F. 
			Break
		Endif
						
		// Gravação na tabela de interface.
		aValues := {AllTrim(cId), AllTrim(cFilTab), AllTrim(cMatTab), AllTrim(cDtDemis), AllTrim(cTipRes), dDataBase, TIME(), cOper,"1","","",""}
		lRet := U_F0600102(cTbl, aTblStru, aValues)
		
		//Chama funcao para consumir WS ApData
		If lRet 
			StartJob("U_F0600603",GetEnvServer(),.F.,{"01",cFilTab})
		Endif
	End Sequence	
	
	//Restaura as areas
	AEval(aAreas,{|x,y| RestArea(x) })

Return lRet