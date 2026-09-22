#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} F0601101
Grava PA6 com dados do Alias informados
 
@author Eduardo Fernandes 
@since  18/01/2017
@param cID, characters, descricao
@param cAliasTab, characters, descricao
@param nRecPA6, numeric, descricao
@param cOper, characters, descricao
@return Nil  

@project MAN0000007423040_EF_011
@cliente Rededor
@version P12.1.7
             
/*/
User Function F0601101(cID, cAliasTab, nRecPA6, cOper)
Local lRet		:= .T.
Local cTbl		:= "EF06006"
Local aValues 	:= {}
Local cFilTab	:= ""
Local cMatTab	:= ""
Local cTipRes	:= ""
Local cDtDemis	:= ""
Local aTblStru	:= {{"EF06006_ID"			, "VARCHAR", 36},;
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
					{"EF06006_OBSERVA"		, "VARCHAR", 200}}
						
Local aAreas   	:= {GetArea(), SRA->(GetArea())}							

If nRecPA6 == 0
	AEval(aAreas,{|x,y| RestArea(x) })
	Return .F.
Endif	

If cAliasTab == "SRG"
	PA6->(dbGoto(nRecPA6))

	If PA6->PA6_RECNOT > 0
		SRG->(dbGoto(PA6->PA6_RECNOT))  

		cFilTab	:= 	SRG->RG_FILIAL
		cMatTab	:= 	SRG->RG_MAT
		cTipRes 	:=	SRG->RG_TIPORES
		cDtDemis 	:= 	DtoS(SRG->RG_DATADEM)		
	Endif	
Endif

If Empty(cTipRes) .Or. Empty(cDtDemis)
	AEval(aAreas,{|x,y| RestArea(x) })
	Return .F.
Endif
				
// Gravação na tabela de interface.
aValues := {cId, cFilTab, cMatTab, cDtDemis, cTipRes, dDataBase, TIME(), cOper,"1","","",""}
lRet := U_F0600102(cTbl, aTblStru, aValues)

//Chama funcao para consumir WS ApData
If lRet 
	StartJob("U_F0600103",GetEnvServer(),.F.,{"01",cFilTab})
Endif	

//Restaura as areas
AEval(aAreas,{|x,y| RestArea(x) })

Return lRet