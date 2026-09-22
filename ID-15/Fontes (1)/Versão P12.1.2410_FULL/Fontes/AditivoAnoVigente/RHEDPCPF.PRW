#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} RHEDPCPF
@author Artur Antunes
@since 03/12/2020
@version 1.0
@description Dependentes com CPF Inconsistente
@type function
/*/

User Function RHEDPCPF() 

Local aArea    := GetArea()
Private oExcel := nil 
private aPergs := {}

FWMsgRun(, {|| fProcRel() }, "CPFs Inconsistentes...", "Processando, aguarde..." )
RestArea(aArea)  
return   


Static Function fProcRel()

local cArqXML     := "RHEDPCPF_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
local cTitPlan    := ""
local cNomePlan   := ""
local nc          := 0
local cNomeFil    := CapitalAce(Alltrim(SM0->M0_FILIAL) + " - " + Alltrim(SM0->M0_NOMECOM))
local cNomeGrp    := CapitalAce(SM0->M0_NOME)
private aFiliais  := {}
private cEmpresa  := "" 
private cTitulo   := "Dependentes com CPFs Inconsistentes"  
private aBrancoIP := {}   
private aBranco   := {}   
private aInvalIP  := {}   
private aInval    := {}   
private aIgualTIP := {}   
private aIgualT   := {}   
private aDuplicIP := {}   
private aDuplic   := {}  
private aCadFunIP := {}
private aCadFun   := {}
private aCpfPrOp  := {}   
private cFilSelec := ""
private oExcel    := nil   

///fUpdateSXB()
If !fPergunte()
	Return
endif

if MV_PAR01 == '1'
	U_xF3SM0FL()
	cFilSelec := U_xF3RETFL()
else
	cFilSelec := cFilAnt
endif

if Empty(cFilSelec)
	cFilSelec := cFilAnt
endif

if !(";" $ cFilSelec)
	cFilSelec += ";"
endif
aFiliais := StrTokArr(cFilSelec, ';')		

if Len(aFiliais) > 1
	cEmpresa := cNomeGrp
else
	cEmpresa := cNomeFil
endif

dbselectarea("RHS")
RHS->(DbSetOrder(1))
DbSelectArea("SRB")
//SRB->(DbSetOrder(2))//testar indice
SRB->(DbSetOrder(1))
DbSelectArea("SRA")
SRA->(DbSetOrder(1))
DbSelectArea("SRD")
SRD->(DbSetOrder(3))
DbSelectArea("SRC")
SRC->(DbSetOrder(4))
if MV_PAR10 == '1'
	dbselectarea("ZZB")
endif	

for nc:=1 to len(aFiliais)
	Processa({|| fCarregaCpf(aFiliais[nc])},"Carregando CPFs Filial: "+aFiliais[nc]+"...","Carregando CPFs Filial: "+aFiliais[nc]+"...")
next nc

if len(aBrancoIP) > 0 .or. len(aBranco) > 0 .or. len(aInvalIP ) > 0 .or. len(aInval ) > 0 .or.;
   len(aIgualTIP) > 0 .or. len(aIgualT) > 0 .or. len(aDuplicIP) > 0 .or. len(aDuplic) > 0 .or.;
   len(aCadFunIP) > 0 .or. len(aCadFun) > 0
      
   if MV_PAR10 == '1'
   		Processa({|| fProcOper()},"Carregando CPFs Operadora...","CPFs Operadora...")
   endif   
   
   ASORT(aDuplicIP,,,{|x,y| x[9]+x[1]+x[2]+x[7] < y[9]+y[1]+y[2]+y[7] } )
   ASORT(aDuplic  ,,,{|x,y| x[9]+x[1]+x[2]+x[7] < y[9]+y[1]+y[2]+y[7] } )
         
   oExcel := ARSexcel():New() 

   cTitPlan    := "IR PL - CPF BRANCO"
   cNomePlan   := "Dependentes (IRRF/PL) com CPFs Em Branco"
   FWMsgRun(, {|| fGeraPlan(aBrancoIP,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )
    
   cTitPlan    := "IR PL - CPF INVALIDO"
   cNomePlan   := "Dependentes (IRRF/PL) com CPFs Invalidos"
   FWMsgRun(, {|| fGeraPlan(aInvalIP,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )

   cTitPlan    := "IR PL - CPF IGUAL TIT"
   cNomePlan   := "Dependentes (IRRF/PL) com CPFs Iguais ao do Titular"
   FWMsgRun(, {|| fGeraPlan(aIgualTIP,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )

   cTitPlan    := "IR PL - CPF DUPLICADO"
   cNomePlan   := "Dependentes (IRRF/PL) com CPFs Duplicados"
   FWMsgRun(, {|| fGeraPlan(aDuplicIP,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )

   cTitPlan    := "IR PL - CPF DEP IGUAL NA SRA"
   cNomePlan   := "Dependentes (IRRF/PL) com CPFs iguais na SRA"
   FWMsgRun(, {|| fGeraPlan(aCadFunIP,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )
 
   cTitPlan    := "OUTROS - CPF BRANCO"
   cNomePlan   := "Outros Dependentes com CPFs Em Branco"
   FWMsgRun(, {|| fGeraPlan(aBranco,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )
   
   cTitPlan    := "OUTROS - CPF INVALIDO"
   cNomePlan   := "Outros Dependentes com CPFs Invalidos"
   FWMsgRun(, {|| fGeraPlan(aInval,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )

   cTitPlan    := "OUTROS - CPF IGUAL TIT"
   cNomePlan   := "Outros Dependentes com CPFs Iguais ao do Titular"
   FWMsgRun(, {|| fGeraPlan(aIgualT,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )

   cTitPlan    := "OUTROS - CPF DUPLICADO"
   cNomePlan   := "Outros Dependentes com CPFs Duplicados"
   FWMsgRun(, {|| fGeraPlan(aDuplic,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )

   cTitPlan    := "OUTROS - CPF DEP IGUAL NA SRA"
   cNomePlan   := "Dependentes (IRRF/PL) com CPFs iguais na SRA"
   FWMsgRun(, {|| fGeraPlan(aCadFun,cTitPlan,cNomePlan) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )

   if MV_PAR10 == '1'
   		cTitPlan    := "CPF - PROTHEUS x OPERADORA"
   		cNomePlan   := "CPFs Inconsistentes - PROTHEUS x OPERADORA"
   		FWMsgRun(, {|| fGeraPlan(aCpfPrOp,cTitPlan,cNomePlan,2) }, "Aba "+cTitPlan+"...", "Processando, aguarde..." )
   endif
   
   FWMsgRun(, {|| fGeraParametros() }, "Gerando Aba Parametros...", "Processando, aguarde..." )
   FWMsgRun(, {|| oExcel:SaveXml(Alltrim(MV_PAR09),cArqXML,.T.) }, "Gerando Planilha...", "Processando, aguarde..." )
else
   MsgInfo('CPFs inconsistentes nao localizados!')	
endif

Return


//Perguntas
Static Function fPergunte()
local cLoad	    := "RHDPCPFZ" + cEmpAnt 
local lRet		:= .F.   
local aSimNao	:= {"1=Sim","2=Nao"} 

MV_PAR01 := '1'
MV_PAR02 := space(TamSx3('RA_MAT')[1])
MV_PAR03 := space(TamSx3('RA_MAT')[1])
MV_PAR04 := space(TamSx3('RA_CC')[1])
MV_PAR05 := space(TamSx3('RA_CC')[1])
MV_PAR06 := space(6)  
MV_PAR07 := space(6)
MV_PAR08 := space(5)
MV_PAR09 := space(200)
MV_PAR10 := '2'

aAdd( aPergs ,{2,"Seleciona Filiais"	,MV_PAR01,aSimNao,80,".T.",.F.})
aAdd( aPergs ,{1,"Matricula De " 	 	,MV_PAR02 ,""  ,".t."  		   ,'SRA'	,'.T.',80,.F.})	
aAdd( aPergs ,{1,"Matricula Ate" 	 	,MV_PAR03 ,""  ,"NAOVAZIO()"   ,'SRA'	,'.T.',80,.F.})	
aAdd( aPergs ,{1,"C. Custo De " 	 	,MV_PAR04 ,""  ,".t."  		   ,'CTT'	,'.T.',80,.F.})	
aAdd( aPergs ,{1,"C. Custo Ate" 	 	,MV_PAR05 ,""  ,"NAOVAZIO()"   ,'CTT'	,'.T.',80,.F.})	
aAdd( aPergs ,{1,"Periodo De (AAAAMM)"  ,MV_PAR06 ,""  ,".t."   	   ,''   	,'.T.',80,.F.})	
aAdd( aPergs ,{1,"Periodo Ate (AAAAMM)"	,MV_PAR07 ,""  ,".t."   	   ,''   	,'.T.',80,.F.})	
aAdd( aPergs ,{1,"Situacao" 		 	,MV_PAR08 ,""  ,"fSituacao()"  ,''   	,'.T.',80,.F.})	
aAdd( aPergs ,{6,"Pasta Destino"   		,MV_PAR09,"" ,".t.","",80,.F.," ","C:\",128+16} )
//aAdd( aPergs ,{2,"Ver. CPF Operadora"	,MV_PAR10,aSimNao,80,".T.",.F.})
	
If ParamBox(aPergs ,cTitulo,,,,,,,,cLoad,.T.,.T.)  
    lRet := .T.
 	if empty(MV_PAR09) 
		MV_PAR09 := AllTrim(GetTempPath()) 	
	endif  		
endif
return lRet


//Valida numero cpf
Static Function ChkCPF2(cCPF)
Local nCic01	:= nCic02	:= nCic03 := nCic04 := nCic05 := 0
Local nCic06	:= nCic07	:= nCic08 := nCic09 := nCic10 := nCic11 := 0
Local nXcic 	:= nYcic 	:= nWcic  := nKcic  := 0
Local nDig1Cic := nDig2Cic := 0
Local nAux		:= 0

If Replicate(Left(cCPF,1),11) == cCPF
	Return (.F.)
EndIf

If len(alltrim(cCPF)) # 11
	Return (.F.)
EndIf

For nAux := 1 to 11
	If !(SubStr(cCpf,nAux,1) $ "1234567890")
		Return(.F.)
	EndIf
Next nAux

nCic01  := Val(SubStr(cCPF,01,01))
nCic02  := Val(SubStr(cCPF,02,01))
nCic03  := Val(SubStr(cCPF,03,01))
nCic04  := Val(SubStr(cCPF,04,01))
nCic05  := Val(SubStr(cCPF,05,01))
nCic06  := Val(SubStr(cCPF,06,01))
nCic07  := Val(SubStr(cCPF,07,01))
nCic08  := Val(SubStr(cCPF,08,01))
nCic09  := Val(SubStr(cCPF,09,01))
nCic10  := Val(SubStr(cCPF,10,01))
nCic11  := Val(SubStr(cCPF,11,01))

// Consistencia do 1?Numero do Digito
nXcic := (nCic01 * 10) + (nCic02 * 9) + (nCic03 * 8) + (nCic04 * 7) + (nCic05 * 6)
nXcic += (nCic06 *  5) + (nCic07 * 4) + (nCic08 * 3) + (nCic09 * 2)
nYcic := Int( nXcic / 11 )
nWcic := nYcic * 11
nKcic := nXcic - nWcic

If nKcic = 0 .OR. nKcic = 1
	nDig1Cic := 0
Else
	nDig1Cic := 11 - nKcic
EndIf

If nDig1Cic != nCic10
	Return (.F.)
EndIf

// Consistencia do 2?Numero do Digito
nXcic := (nCic01 * 11) + (nCic02 * 10) + (nCic03 * 9) + (nCic04 * 8) + (nCic05 * 7)
nXcic += (nCic06 *  6) + (nCic07 *	5) + (nCic08 * 4) + (nCic09 * 3) + (nCic10 * 2)
nYcic = Int( nXcic / 11 )
nWcic = nYcic * 11
nKcic = nXcic - nWcic

If nKcic = 0 .OR. nKcic = 1
	nDig2Cic = 0
Else
	nDig2Cic = 11 - nKcic
EndIf

If nDig2Cic != nCic11
	Return (.F.)
EndIf

Return (.T.)


Static Function fInQRY(cCar)
Local cRetorno := ""
Local cRet     :=StrTran(cCar,"*","")
Local x        := 0
if !empty(cRet)
	For X=1 To Len(cRet)
	   cRetorno+="'"+SubStr(cRet,X,1)+"',"
	Next
	cRetorno:=Left(cRetorno,Len(cRetorno)-1)
endif	
Return(cRetorno)


Static Function fInQRY2(cCar,cSep)
Local cRetorno := ""
Local aTemp    := StrTokArr2(cCar, cSep,.T.)   
Local x        := 0
For X=1 To Len(aTemp)
   if !empty(aTemp[x])	
   		cRetorno += "'" + Alltrim(aTemp[x]) + "',"
   endif		
Next x
cRetorno:=Left(cRetorno,Len(cRetorno)-1)	
Return(cRetorno)


Static Function fRetDepPer(cFilp,cMatp,cCodp)
Local cRet    := ""
local dDtIni  := stod("")
local dDtFin  := stod("")
local nMeses  := 0
local nx      := 0
local aPeriod := {}

if MV_PAR06 == MV_PAR07
	aadd(aPeriod,MV_PAR06)
else
	dDtIni := stod(MV_PAR06+"15")
	dDtFin := stod(MV_PAR07+"15")
	nMeses := DateDiffMonth(dDtIni,dDtFin)
	aadd(aPeriod,AnoMes(dDtIni))
	for nx:=1 to nMeses
		dDtIni := MonthSum(dDtIni,1)
		aadd(aPeriod,AnoMes(dDtIni))
	next nx
endif

for nx:= 1 to len(aPeriod)
	if RHS->(DbSeek(cFilp+cMatp+aPeriod[nx]))
		While !RHS->(Eof()) .and. RHS->(RHS_FILIAL+RHS_MAT+RHS_COMPPG) == cFilp+cMatp+aPeriod[nx]
			if RHS->RHS_CODIGO == cCodp	.and. !(RHS->RHS_COMPPG $ cRet)    		  
				cRet += RHS->RHS_COMPPG+" | "
			endif
			RHS->(DbSkip())
		End
	endif
next nx
return cRet



Static Function fDepPerRet(cFilp,cMatp,cCodp)
Local cRet := ""

If Select("TRHS") > 0
	TRHS->(dbCloseArea())
EndIf
cQry := " SELECT RHS_FILIAL, RHS_MAT, RHS_CODIGO, RHS_COMPPG " + CRLF 
cQry += " FROM "+RETSQLNAME("RHS") + " RHS " + CRLF
cQry += " WHERE RHS.RHS_FILIAL = '"+Alltrim(cFilp)+"' "+CRLF
cQry += "  AND RHS.RHS_MAT     = '"+Alltrim(cMatp)+"' "+CRLF
cQry += "  AND RHS.RHS_CODIGO  = '"+Alltrim(cCodp)+"' "+CRLF
cQry += "  AND RHS.RHS_COMPPG  BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "+CRLF    
cQry += "  AND RHS.D_E_L_E_T_  = ' ' " + CRLF
cQry += " GROUP BY RHS_FILIAL, RHS_MAT, RHS_CODIGO, RHS_COMPPG " + CRLF 

TCQUERY cQry ALIAS "TRHS" NEW
TRHS->(DbGoTop())  
While !TRHS->(EOF())     
	cRet += TRHS->RHS_COMPPG+" | "
	TRHS->(DbSkip())  
end
return cRet



Static Function fExistPeriod(cFilp,cMatp)
Local lRet    := .f.
local dDtIni  := stod("")
local dDtFin  := stod("")
local nMeses  := 0
local nx      := 0
local aPeriod := {}

if MV_PAR06 == MV_PAR07
	aadd(aPeriod,MV_PAR06)
else
	dDtIni := stod(MV_PAR06+"15")
	dDtFin := stod(MV_PAR07+"15")
	nMeses := DateDiffMonth(dDtIni,dDtFin)
	aadd(aPeriod,AnoMes(dDtIni))
	for nx:=1 to nMeses
		dDtIni := MonthSum(dDtIni,1)
		aadd(aPeriod,AnoMes(dDtIni))
	next nx
endif

for nx:= 1 to len(aPeriod)
	if SRD->(DbSeek(cFilp+cMatp+aPeriod[nx]))
		lRet := .t.
		exit
	endif
next nx

if !lRet
	for nx:= 1 to len(aPeriod)
		if SRC->(DbSeek(cFilp+cMatp+aPeriod[nx]))
			lRet := .t.
			exit
		endif
	next nx
endif	
return lRet



Static Function fRetCpfOp(aTemp)
Local cRet    := ""
Local cCpfTit := aTemp[4]
Local cNomeDep:= aTemp[8]
Local aMatOp  := {}
Local nx	  := 0

ZZB->(DbSetOrder(2))
if ZZB->(DbSeek( XFILIAL("ZZB")+PADR(cCpfTit,11)+PADR("TITULAR",20) ))
	While !ZZB->(Eof()) .and. ZZB->(ZZB_FILIAL+ZZB_CPF+ZZB_PARENT) == XFILIAL("ZZB")+PADR(cCpfTit,11)+PADR("TITULAR",20)
		AADD(aMatOp,ZZB->ZZB_MATOP)		
		ZZB->(DbSkip())
	End
endif 

ZZB->(DbSetOrder(3)) 
if len(aMatOp) > 0
	for nx:=1 to len(aMatOp)
		if ZZB->(DbSeek( XFILIAL("ZZB")+PADR(cNomeDep,70)+aMatOp[nx] ))
			cRet := ZZB->ZZB_CPF
			exit
		endif
	next nx    
endif	                                                                                                                           
return cRet


Static Function fTemDupcpf(cCicT,cCicD,cFilx,cMatx,lDepenPlIr)

Local lRet   	 := .F.
Local cQry   	 := ""
Local cGrau  	 := ""
Local cDepPlano  := ""
Local cDepPeriod := ""
Local nCount 	 := 0
Local aTemp		 := {}
Local nPos   	 := 0
Local cSituacP   := ""

If !Empty(cCicD)
	
    If Select("TSRB") > 0
	  TSRB->(dbCloseArea())
    EndIf
    
	cQry := " SELECT RB_FILIAL,RB_MAT,RB_COD,RB_NOME,RB_CIC,RB_DTNASC,RB_GRAUPAR,RB_TIPIR,RB_PLSAUDE " + CRLF 
	cQry += " FROM "+RETSQLNAME("SRB") + " SRB " + CRLF
	cQry += " WHERE SRB.RB_CIC     =  '"+Alltrim(cCicD)+"' "+CRLF
	cQry += "  AND SRB.D_E_L_E_T_  = ' ' " + CRLF
				
    TCQUERY cQry ALIAS "TSRB" NEW
    TSRB->(DbGoTop())  
    SRA->(DbSetOrder(1))
    
    While !TSRB->(EOF())     
    	
    	if SRA->(DbSeek( TSRB->RB_FILIAL+TSRB->RB_MAT ))
    	    		    		    		
    		if 	( SRA->RA_ADMISSA <= LastDate(STOD(MV_PAR07+"01")) .and. Alltrim(SRA->RA_CIC) <> Alltrim(cCicT) ) .and. ;
    			(  empty(SRA->RA_DEMISSA) .or. ( SRA->RA_DEMISSA >= stod(MV_PAR06+"01") .AND. SRA->RA_DEMISSA <=  LastDate(STOD(MV_PAR07+"01")) ) )
    			
		    	//cSituacP := ""
		    	//fSitFunc(TM01->RB_FILIAL,TM01->RB_MAT,stod(MV_PAR06+"01"),LastDate(STOD(MV_PAR07+"01")),@cSituacP)
		    	//if cSituacP $ MV_PAR08 
		    	    	   		   	
			   		cGrau := ''
					do case
						case TSRB->RB_GRAUPAR = 'P'
							cGrau := 'PAI/MAE'
						case TSRB->RB_GRAUPAR = 'C'
							cGrau := 'CONJUGE/COMPANHEIRO'
						case TSRB->RB_GRAUPAR = 'O'
							cGrau := 'AGREGADO/OUTROS'
						case TSRB->RB_GRAUPAR = 'F'
							cGrau := 'FILHO/FILHA'
						case TSRB->RB_GRAUPAR = 'E'
							cGrau := 'ENTEADO/ENTEADA'		
					endcase
			
					cDepPlano  := iif(TSRB->RB_PLSAUDE == '1',"SIM","NAO")
					cDepPeriod := fDepPerRet(TSRB->RB_FILIAL,TSRB->RB_MAT,TSRB->RB_COD)
					aTemp      := { TSRB->RB_FILIAL,TSRB->RB_MAT,SRA->RA_NOME,SRA->RA_CIC,SRA->RA_ADMISSA,SRA->RA_DEMISSA,;
									TSRB->RB_COD,TSRB->RB_NOME,TSRB->RB_CIC,STOD(TSRB->RB_DTNASC), cGrau, cDepPlano,iif(!empty(cDepPeriod),"SIM","NAO"),cDepPeriod,""}
			    	
			   	   	if lDepenPlIr
			   	   		nPos := aScan( aDuplicIP, {|x| x[1]+x[2]+x[7] == TSRB->RB_FILIAL + TSRB->RB_MAT + TSRB->RB_COD } )	
			   	   		if nPos == 0
			   	   			AADD(aDuplicIP,aTemp)
			   	   			AADD(aCpfPrOp,aTemp)   	   			
			   	   		endif	
			   	   	else    
			   	   		nPos := aScan( aDuplic, {|x| x[1]+x[2]+x[7] == TSRB->RB_FILIAL + TSRB->RB_MAT + TSRB->RB_COD } )	
			   	   		if nPos == 0
			   	   			AADD(aDuplic,aTemp)
			   	   			AADD(aCpfPrOp,aTemp) 
			   	   		endif		    	   		
			   	   	endif
			   	   	nCount ++
			   	//endif
			endif
		endif	   	
   		TSRB->(DBSKIP())
    End  
                         
    TSRB->(dbCloseArea())

	SRB->(DbSetOrder(1))    
    cQry := " SELECT SRB.RB_FILIAL, SRB.RB_MAT, SRB.RB_CIC, COUNT(*) XQTD "+CRLF 
    cQry += " FROM  " + RETSQLNAME("SRB") + " SRB "+CRLF
    cQry += " WHERE SRB.D_E_L_E_T_  = ' ' "+CRLF 
    cQry += "  AND SRB.RB_FILIAL =  '"+Alltrim(cFilx)+"' "+CRLF
    cQry += "  AND SRB.RB_MAT =  '"+Alltrim(cMatx)+"' "+CRLF
    cQry += "  AND SRB.RB_CIC =  '"+Alltrim(cCicD)+"' "+CRLF
    cQry += "  AND SRB.RB_CIC <> ' ' "+CRLF       
    cQry += " GROUP BY SRB.RB_FILIAL, SRB.RB_MAT, SRB.RB_CIC "+CRLF
    cQry += " HAVING COUNT(*) > 1 "+CRLF
    TCQUERY cQry ALIAS "TSRB" NEW
    TSRB->(DbGoTop())
    while !TSRB->(EOF())     
   		if TSRB->XQTD > 0 		
 
   			if SRA->(DbSeek( TSRB->RB_FILIAL+TSRB->RB_MAT )) .and. SRB->(DbSeek( TSRB->RB_FILIAL+TSRB->RB_MAT ))  				
   				while !SRB->(eof()) .and. SRB->RB_FILIAL+SRB->RB_MAT+SRB->RB_CIC == TSRB->RB_FILIAL+TSRB->RB_MAT+TSRB->RB_CIC  
 
			    	cGrau := ''
					do case
						case SRB->RB_GRAUPAR = 'P'
							cGrau := 'PAI/MAE'
						case SRB->RB_GRAUPAR = 'C'
							cGrau := 'CONJUGE/COMPANHEIRO'
						case SRB->RB_GRAUPAR = 'O'
							cGrau := 'AGREGADO/OUTROS'
						case SRB->RB_GRAUPAR = 'F'
							cGrau := 'FILHO/FILHA'
						case SRB->RB_GRAUPAR = 'E'
							cGrau := 'ENTEADO/ENTEADA'		
					endcase
					
					cDepPlano  := iif(SRB->RB_PLSAUDE == '1',"SIM","NAO")
					cDepPeriod := fDepPerRet(SRB->RB_FILIAL,SRB->RB_MAT,SRB->RB_COD)
					aTemp      := { SRB->RB_FILIAL,SRB->RB_MAT,SRA->RA_NOME,SRA->RA_CIC,SRA->RA_ADMISSA,SRA->RA_DEMISSA,;
							        SRB->RB_COD,SRB->RB_NOME,SRB->RB_CIC,SRB->RB_DTNASC,cGrau, cDepPlano,iif(!empty(cDepPeriod),"SIM","NAO"),cDepPeriod,""}
	    	
			   	   	if lDepenPlIr
			   	   		nPos := aScan( aDuplicIP, {|x| x[1]+x[2]+x[7] == SRB->RB_FILIAL + SRB->RB_MAT + SRB->RB_COD } )	
			   	   		if nPos == 0
			   	   			AADD(aDuplicIP,aTemp)
			   	   			AADD(aCpfPrOp,aTemp) 
			   	   		endif	
			   	   	else    
			   	   		nPos := aScan( aDuplic, {|x| x[1]+x[2]+x[7] == SRB->RB_FILIAL + SRB->RB_MAT + SRB->RB_COD } )	
			   	   		if nPos == 0
			   	   			AADD(aDuplic,aTemp)
			   	   			AADD(aCpfPrOp,aTemp) 
			   	   		endif		    	   		
			   	   	endif	   			   			
   					nCount ++
   					SRB->(DbSkip())
   				end
   			endif
   		endif
   		TSRB->(DbSkip())
    end                       
    TSRB->(dbCloseArea())
    
Endif

If nCount > 0
   lRet := .T. 
Endif
Return lRet



//Carregando CPF
Static Function fCarregaCpf(cFilx)

Local cQry  	 := ""
Local cGrau  	 := ""
Local nPos  	 := 0
Local cDepPlano  := ""
Local cDepPeriod := ""
Local cSituacP   := ""
Local aTemp 	 := {}
Local lDepenPlIr := .f.
local nRegAtu    := 0
local nTotReg    := 0
local lIncons    := .f.

cQry := " SELECT RB_FILIAL,RB_MAT,RA_NOME,RA_CIC,RA_ADMISSA,RA_DEMISSA,RB_COD,RB_NOME,RB_CIC,RB_DTNASC,RB_GRAUPAR,RB_TIPIR,RB_PLSAUDE " + CRLF 
cQry += " FROM "+RETSQLNAME("SRB") + " SRB, " + CRLF
cQry += "      "+RETSQLNAME("SRA") + " SRA " + CRLF
cQry += " WHERE SRA.RA_FILIAL  = '"+Alltrim(cFilx)+"' " + CRLF
cQry += "  AND SRB.RB_FILIAL   = SRA.RA_FILIAL " + CRLF
cQry += "  AND SRB.RB_MAT      = SRA.RA_MAT " + CRLF
cQry += "  AND (SRA.RA_DEMISSA = ' ' OR RA_DEMISSA BETWEEN '"+MV_PAR06+"01"+"' AND '"+dtos(LastDate(STOD(MV_PAR07+"01")))+"' ) " + CRLF
cQry += "  AND SRA.RA_ADMISSA  <= '"+dtos(LastDate(STOD(MV_PAR07+"01")))+"' " + CRLF
cQry += "  AND SRA.RA_MAT      BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' " + CRLF
cQry += "  AND SRA.RA_CC       BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' " + CRLF 
//cQry += "  AND SRA.RA_SITFOLH  IN (" +fInQRY(MV_PAR08)+ ") " + CRLF
cQry += "  AND SRB.D_E_L_E_T_  = ' ' " + CRLF
cQry += "  AND SRA.D_E_L_E_T_  = ' ' " + CRLF
cQry += " GROUP BY RB_FILIAL,RB_MAT,RA_NOME,RA_CIC,RA_ADMISSA,RA_DEMISSA,RB_COD,RB_NOME,RB_CIC,RB_DTNASC,RB_GRAUPAR,RB_TIPIR,RB_PLSAUDE " + CRLF 

if Select("TM01") > 0
	TM01->(DbCloseArea())
EndIf
FWMsgRun(, {|| DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry),"TM01", .F., .T.) },"Carregando Consulta Filial: "+cFilx+"...", "Carregando, Filial: "+cFilx+"..." )
TM01->(DbGoTop())
Count To nTotReg 
if nTotReg < 1
	return
endif
TM01->(dbGoTop())
ProcRegua(nTotReg)

While !TM01->(Eof())

	nRegAtu++
	IncProc( "Fil: " + cFilx + " - Status Geral: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")	

	//if fExistPeriod(TM01->RB_FILIAL,TM01->RB_MAT)
	DbSelectArea("SRA")
	SRA->(DbSetOrder(1))
	
	lIncons  := .f.
	cSituacP := ""
	fSitFunc(TM01->RB_FILIAL,TM01->RB_MAT,stod(MV_PAR06+"01"),LastDate(STOD(MV_PAR07+"01")),@cSituacP)
	if cSituacP $ MV_PAR08 
	
		cGrau := ''
		do case
			case TM01->RB_GRAUPAR = 'P'
				cGrau := 'PAI/MAE'
			case TM01->RB_GRAUPAR = 'C'
				cGrau := 'CONJUGE/COMPANHEIRO'
			case TM01->RB_GRAUPAR = 'O'
				cGrau := 'AGREGADO/OUTROS'
			case TM01->RB_GRAUPAR = 'F'
				cGrau := 'FILHO/FILHA'
			case TM01->RB_GRAUPAR = 'E'
				cGrau := 'ENTEADO/ENTEADA'		
		endcase
	
		lDepenPlIr := TM01->RB_TIPIR $ "123" .or. TM01->RB_PLSAUDE == '1'
		cDepPlano  := iif(TM01->RB_PLSAUDE == '1',"SIM","NAO")	
		aTemp      := { TM01->RB_FILIAL,TM01->RB_MAT,TM01->RA_NOME,TM01->RA_CIC,STOD(TM01->RA_ADMISSA),STOD(TM01->RA_DEMISSA),;
						TM01->RB_COD,TM01->RB_NOME,TM01->RB_CIC,STOD(TM01->RB_DTNASC),cGrau,cDepPlano,"","",""}
		
	    do case
	    	case EMPTY(TM01->RB_CIC) // EM BRANCO    	
	    		
	    		lIncons    := .t.
	    		cDepPeriod := fDepPerRet(TM01->RB_FILIAL,TM01->RB_MAT,TM01->RB_COD)
	    		aTemp[13]  := iif(!empty(cDepPeriod),"SIM","NAO")
	    		aTemp[14]  := cDepPeriod
	    		    		
		    	if lDepenPlIr
		    		AADD(aBrancoIP,aTemp)
		    		AADD(aCpfPrOp,aTemp) 
		    	else    
		    		AADD(aBranco,aTemp)
		    		AADD(aCpfPrOp,aTemp) 
		    	endif
	
	    	case !ChkCPF2(TM01->RB_CIC) // NUMERO INVALIDO 	
	
	    		lIncons    := .t.
	    		cDepPeriod := fDepPerRet(TM01->RB_FILIAL,TM01->RB_MAT,TM01->RB_COD)
	    		aTemp[13]  := iif(!empty(cDepPeriod),"SIM","NAO")
	    		aTemp[14]  := cDepPeriod
	    	
		    	if lDepenPlIr
		    		AADD(aInvalIP,aTemp)
		    		AADD(aCpfPrOp,aTemp) 
		    	else    
		    		AADD(aInval,aTemp)
		    		AADD(aCpfPrOp,aTemp) 
		    	endif
	
	    	case ALLTRIM(TM01->RB_CIC) == ALLTRIM(TM01->RA_CIC) // DEPENDENTE IGUAL AO DO TITULAR 	
	
	    		lIncons    := .t.
	    		cDepPeriod := fDepPerRet(TM01->RB_FILIAL,TM01->RB_MAT,TM01->RB_COD)
	    		aTemp[13]  := iif(!empty(cDepPeriod),"SIM","NAO")
	    		aTemp[14]  := cDepPeriod
	
		    	if lDepenPlIr
		    		AADD(aIgualTIP,aTemp)
		    		AADD(aCpfPrOp,aTemp) 
		    	else    
		    		AADD(aIgualT,aTemp)
		    		AADD(aCpfPrOp,aTemp) 
		    	endif
			
	    	case fTemDupcpf(TM01->RA_CIC,TM01->RB_CIC,TM01->RB_FILIAL,TM01->RB_MAT,lDepenPlIr) //DUPLICADO	
		    	
	    		lIncons    := .t.
	    		cDepPeriod := fDepPerRet(TM01->RB_FILIAL,TM01->RB_MAT,TM01->RB_COD)
	    		aTemp[13]  := iif(!empty(cDepPeriod),"SIM","NAO")
	    		aTemp[14]  := cDepPeriod
	
	    	   	if lDepenPlIr
	    	   		nPos := aScan( aDuplicIP, {|x| x[1]+x[2]+x[7] == TM01->RB_FILIAL + TM01->RB_MAT + TM01->RB_COD } )	
	    	   		if nPos == 0
	    	   			AADD(aDuplicIP,aTemp)
	    	   			AADD(aCpfPrOp,aTemp) 
	    	   		endif	
	    	   	else    
	    	   		nPos := aScan( aDuplic, {|x| x[1]+x[2]+x[7] == TM01->RB_FILIAL + TM01->RB_MAT + TM01->RB_COD } )	
	    	   		if nPos == 0
	    	   			AADD(aDuplic,aTemp)
	    	   			AADD(aCpfPrOp,aTemp) 
	    	   		endif		    	   		
	    	   	endif			
		endcase   
		
		if !lIncons
		
			SRA->(DbSetOrder(20))
			if SRA->( DbSeek( TM01->RB_CIC )) // CPF DEPENDENTE NO CADASTRO DE FUNCIONARIOS	
	
		   		cDepPeriod := fDepPerRet(TM01->RB_FILIAL,TM01->RB_MAT,TM01->RB_COD)
		   		aTemp[13]  := iif(!empty(cDepPeriod),"SIM","NAO")
		   		aTemp[14]  := cDepPeriod
		    	
		    	if lDepenPlIr
		    		AADD(aCadFunIP,aTemp)
		    		AADD(aCpfPrOp ,aTemp) 
		    	else    
		    		AADD(aCadFun  ,aTemp)
		    		AADD(aCpfPrOp ,aTemp) 
		    	endif
		    endif	
	    endif
	endif
	TM01->(DbSkip())
end
return



Static function fProcOper()
local nc 		 := 0
local nRegAtu    := 0
local nTotReg    := len(aCpfPrOp)

ProcRegua(0)
ASORT(aCpfPrOp,,,{|x,y| x[1]+x[2]+x[8] < y[1]+y[2]+y[8] } )
ProcRegua(nTotReg)

for nc:=1 to len(aCpfPrOp)
	nRegAtu++
	IncProc( "Fil: " + aCpfPrOp[nc,1] + " - Status operadora: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")	
	
	aCpfPrOp[nc,15] := fRetCpfOp(aCpfPrOp[nc])
next nc
return



Static function fGeraPlan(aPlan,cNomePlan,cTitPlan,nLayout)

local nc		:= 0
local cCab1Fon	:= 'Calibri' 
local cCab1TamF	:= 8   
local cCab1CorF := '#FFFFFF'
local cCab1Fun	:= '#4F81BD'

local cFonte1	 := 'Arial'
local nTamFont1	 := 12   
local cCorFont1  := '#FFFFFF'
local cCorFun1	 := '#4F81BD'

local cFonte2	 := 'Arial'
local nTamFont2	 := 8   
local cCorFont2  := "#000000"
local cCorFun2	 := "#FFFFFF"
default nLayout  := 1

if len(aPlan) == 0
	return
endif

if nLayout == 1

	oExcel:AddPlanilha(cNomePlan,{20,60,60,160,80,70,70,70,160,80,70,120,90,150},6)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,12) 
	oExcel:AddLinha(15)
	oExcel:AddCelula( "Emissao: " + dtoc(DATE()),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,12) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitPlan,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,12) 
	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()  
	oExcel:AddCelula("Filial"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Matricula"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"					,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CPF"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Admissao"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Demissao"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Codigo Depen."		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome Depen."  		,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CPF Depen."			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DT Nasc. Depen."		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Parentesco"	  		,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	//oExcel:AddCelula("Dep PL Saude Atual"   ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dep PL Saude Periodo"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Periodos PL Saude"	,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	                            
	for nc:=1 to len(aPlan)
	
		oExcel:AddLinha(16) 
		oExcel:AddCelula()   
	
		oExcel:AddCelula( aPlan[nc,1] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,2] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,3] ,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,4] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,5] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,6] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,7] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,8] ,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,9] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,10],0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,11],0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		//oExcel:AddCelula( aPlan[nc,12],0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,13],0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,14],0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	
	next nc 
	
else

	oExcel:AddPlanilha(cNomePlan,{20,60,60,60,160,80,80,70,120,90,150},6)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,9) 
	oExcel:AddLinha(15)
	oExcel:AddCelula( "Emissao: " + dtoc(DATE()),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,9) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitPlan,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,9) 
	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()  
	oExcel:AddCelula("Filial"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Matricula"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Codigo Depen."		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome Depen."  		,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CPF Protheus"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CPF Operadora"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DT Nasc. Depen."		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Parentesco"	  		,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	//oExcel:AddCelula("Dep PL Saude Atual"   ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dep PL Saude Periodo"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Periodos PL Saude"	,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	                            
	for nc:=1 to len(aPlan)
	
		oExcel:AddLinha(16) 
		oExcel:AddCelula()   
	
		oExcel:AddCelula( aPlan[nc,1]  ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,2]  ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,7]  ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,8]  ,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,9]  ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,15] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,10] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,11] ,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		//oExcel:AddCelula( aPlan[nc,9] ,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,13],0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula( aPlan[nc,14],0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	
	next nc 
endif	
return


 //Gera parametros
Static Function fGeraParametros()

local nCont		 := 0 
local cCorFundo  := ""
local cTitulo	 := 'Parametros'

local cFonte1    := 'Calibri' 
local nTamFont1  := 9
local cCorFont1  := '#FFFFFF'
local cCorFund1  := '#4F81BD'

local cFonte2    := 'Arial' 
local nTamFont2  := 9
local cCorFont2  := '#000000'

aPergs[1,3] := MV_PAR01 
aPergs[2,3] := MV_PAR02  
aPergs[3,3] := MV_PAR03     
aPergs[4,3] := MV_PAR04     
aPergs[5,3] := MV_PAR05     
aPergs[6,3] := MV_PAR06 
aPergs[7,3] := MV_PAR07  
aPergs[8,3] := MV_PAR08     
aPergs[9,3] := MV_PAR09 
if MV_PAR10 == '1'    
	aPergs[10,3]:= MV_PAR10
endif	     

oExcel:AddPlanilha('Parametros',{30,80,120,270})
oExcel:AddLinha(18)
oExcel:AddCelula(cTitulo,0,'C','Arial',12,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
oExcel:AddLinha(15)
oExcel:AddLinha(12) 
oExcel:AddCelula()
oExcel:AddCelula( "Sequencia" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
oExcel:AddCelula( "Pergunta"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
oExcel:AddCelula( "Conteudo"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 

for nCont := 1 to Len(aPergs)	
	
	oExcel:AddLinha(16) 
	oExcel:AddCelula()
	oExcel:AddCelula( strzero(nCont,2) ,0,'C',cFonte2,nTamFont2,cCorFont2,,,,.T.,.T.,.T.,.T.)  
	oExcel:AddCelula( aPergs[nCont,2]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,,.T.,.T.,.T.,.T.)  
	oExcel:AddCelula( aPergs[nCont,3]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,,.T.,.T.,.T.,.T.) // Conteudo 

next nCont

oExcel:AddLinha(15)
oExcel:AddLinha(12) 
oExcel:AddCelula( "Filiais Selecionadas" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.,.T.,2,2)  

for nCont := 1 to Len(aFiliais)	

	oExcel:AddLinha(16) 
	oExcel:AddCelula( aFiliais[nCont] ,0,'C',cFonte2,nTamFont2,cCorFont2,,,,.T.,.T.,.T.,.T.,.T.,2,2)   

next nCont

Return 



//Descricao Consulta Especifica							              
static _xcSM0fRET := "" 
static _xaLINSM0F := {}

user Function xF3SM0FL()     
 
local aArea     := GetArea()
local oDlg		:= nil 
local oCombo	:= nil 
local oButPesq  := nil 
local oGet		:= nil
local oButOK	:= nil 
local oButCan 	:= nil 
local nLargBot	:= 30  
local nAltBot	:= 11
local nInterv   := 3 
local nTempInt  := 0  
local nVertBot  := 250
private lCheck  := .f.
private nPos    := 1  
private cPesq	:= space(100)
private aCombo	:= {"Filial","Nome"}
private cCombo	:= ""
private oBrowse := nil  
private oboOK   := LoadBitmap(GetResources(),'LBTICK')    
private oboNO   := LoadBitmap(GetResources(),'LBNO')   
private aCamLab := {''," Filial"," Nome"}
private aCamTam := {15,35,300}

_xcSM0fRET := ""
FWMsgRun(, {|| fCarrDados() }, "Carregando Filiais...", "Aguarde..." )
	
oDlg:=MSDialog():New(0,0,530,700,"Selecione as Filiais",,,,,CLR_BLACK,,,,.T.) 

oCombo   := tComboBox():New(3,3,{|u|if(PCount()>0,cCombo:=u,cCombo)},aCombo,200,10,oDlg,,{|| OrdBrowse() },,,,.T.,,,,,,,,,'cCombo')
oGet     := TGet():New(17,3,{|u| if(PCount()>0,cPesq:=u,cPesq)},oDlg,200,10,,,,,,,,.T.,,,,,,,,,,'cPesq')
oButPesq := TButton():New(3,205,'Pesquisar',oDlg,{|| pesqBrow()},40,11,,,,.T.)

// Marca / Desmarca - todos
oCheck1 := TCheckBox():New(41,04,'',{|| lCheck},oDlg,15,15,,{|| ( lCheck:=!lCheck,MarDesAll(lCheck) )},,,,,,.T.,,,)
oSay1   := tSay():new(41 ,12,{|| "Marcar/Desmarcar Todos"},oDlg,,,,,,.T.,,,100,10)  

oBrowse := TWBrowse():New( 50,03,350,190,,aCamLab,aCamTam, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
oBrowse:SetArray(_xaLINSM0F) 
oBrowse:bLine:={||{  Iif(_xaLINSM0F[oBrowse:nAt,01]=='OK',oboOK,oboNO), _xaLINSM0F[oBrowse:nAt,02],_xaLINSM0F[oBrowse:nAt,03] }}      
oBrowse:bLDblClick := {|| Iif(_xaLINSM0F[oBrowse:nAt,01]=='OK',_xaLINSM0F[oBrowse:nAt,01]:='NO',_xaLINSM0F[oBrowse:nAt,01]:='OK') }

nTempInt += nInterv
oButOK   := TButton():New(nVertBot,nTempInt,'OK',oDlg,{|| fRetMark(),oDlg:End() },nLargBot,nAltBot,,,,.T.) 
nTempInt += nInterv + nLargBot
oButCan  := TButton():New(nVertBot,nTempInt,'Cancelar',oDlg,{|| _xcSM0fRET:="",oDlg:End() },nLargBot,nAltBot,,,,.T.)

oDlg:activate(,,,.T.)

RestArea(aArea) 
Return .T.


user Function xF3RETFL() //Retorno da Consulta
return _xcSM0fRET


static function fCarrDados()
Local aAreax   := GetArea()
local cMvPar   := ""	
local nRecnox  := SM0->(recno())
_xaLINSM0F := {}
OpenSm0() 
SM0->(DbSetOrder(1))
SM0->(dbgotop()) 
SM0->(DbSeek(cEmpAnt)) 
While !SM0->(EOF()) .and. cEmpAnt == SM0->M0_CODIGO 
	AADD( _xaLINSM0F, { iif(Alltrim(SM0->M0_CODFIL) $ cMvPar,"OK","NO"), Alltrim(SM0->M0_CODFIL), Alltrim(SM0->M0_FILIAL) + " - " + Alltrim(SM0->M0_NOMECOM) } )  
    SM0->(dbskip())
enddo
SM0->(DbGoTo(nRecnox))
RestArea(aAreax)
return    


static function OrdBrowse() // ordena Browse--------------------------------------------------------
if cCombo == aCombo[2]  
	aSort( _xaLINSM0F,,,{ |x,y| ( x[3]+x[2] ) < ( y[3]+y[2] ) } ) 
	oBrowse:GoBottom()
	oBrowse:GoTop() 
else
	aSort( _xaLINSM0F,,,{ |x,y| ( x[2]+x[3] ) < ( y[2]+y[3] ) } ) 
	oBrowse:GoBottom()
	oBrowse:GoTop() 
endif	
return       


static function pesqBrow() // realiza a busca da pesquisa no array e posiciona o ponteiro -------------------   
if cCombo == aCombo[2] 
	nPos:= ASCANX(_xaLINSM0F,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
	if nPos == 0
		oBrowse:SetFocus() 
		oBrowse:GoPosition(1) 
		nPos:= ASCANX(_xaLINSM0F,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },1)
	endif   
	oBrowse:SetFocus()
	if nPos > 0
		oBrowse:GoPosition(nPos) 
	endif	
else
	nPos:= ASCANX(_xaLINSM0F,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)  
	if nPos == 0
		oBrowse:SetFocus() 
		oBrowse:GoPosition(1) 
		nPos:= ASCANX(_xaLINSM0F,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },1)  
	endif   
	oBrowse:SetFocus() 
	if nPos > 0
		oBrowse:GoPosition(nPos)
	endif
endif	
return 
               

static function fRetMark()
local nk := 0
_xcSM0fRET := ""
for nk:=1 to len(_xaLINSM0F)
	if _xaLINSM0F[nk,1] <> 'OK'
		loop
	endif
	_xcSM0fRET += _xaLINSM0F[nk,2]+";"
next nk 
return	


static function MarDesAll(pCheck)
local nTempLin  := oBrowse:nAt 
local nx		:= 0
for nx := 1 to len(_xaLINSM0F)
	_xaLINSM0F[nx,1]:= iif(pCheck,'OK','NO')
next nx 
oBrowse:GoPosition(len(_xaLINSM0F))
oBrowse:GoPosition(nTempLin)
return  


static function fTrataStr(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "·ÈÌÛ˙"+"¡…Õ”⁄"
Local cCircu := "‚ÍÓÙ˚"+"¬ Œ‘€"
Local cTrema := "‰ÎÔˆ¸"+"ƒÀœ÷‹"
Local cCrase := "‡ËÏÚ˘"+"¿»Ã“Ÿ" 
Local cTio   := "„ı√’"
Local cCecid := "Á«"
Local cMaior := "&lt;"
Local cMenor := "&gt;"
cString := strtran(Alltrim(cString),'"','')
cString := upper(cString)

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString 
	cString := strTran( cString, cMaior, "" ) 
EndIf
If cMenor$ cString 
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|' 
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString


//cria consulta especifica se necessario
Static function fUpdateSXB()
	dbselectarea("SXB")  
	SXB->(DbSetOrder(1)) 
	/*if !SXB->(DbSeek('SM0MFL'))
	
		SXB->(RecLock("SXB",.t.))
		SXB->XB_ALIAS 	:= 'SM0MFL' 
		SXB->XB_TIPO  	:= '1'
		SXB->XB_SEQ   	:= '01' 
		SXB->XB_COLUNA 	:= 'RE'
		SXB->XB_DESCRI 	:= 'Selecione as Filiais'
		SXB->XB_DESCSPA := 'Selecione as Filiais'
		SXB->XB_DESCENG := 'Selecione as Filiais'
		SXB->XB_CONTEM 	:= 'SXB'
		SXB->(MsUnLock())
	
		dbselectarea("SXB")
		SXB->(RecLock("SXB",.t.))
		SXB->XB_ALIAS 	:= 'SM0MFL' 
		SXB->XB_TIPO  	:= '2'
		SXB->XB_SEQ   	:= '01' 
		SXB->XB_COLUNA 	:= '01'
		SXB->XB_DESCRI 	:= ''
		SXB->XB_DESCSPA := ''
		SXB->XB_DESCENG := ''
		SXB->XB_CONTEM 	:= 'U_xF3SM0FL()' 
		SXB->(MsUnLock())
	
		dbselectarea("SXB")
		SXB->(RecLock("SXB",.t.))
		SXB->XB_ALIAS 	:= 'SM0MFL' 
		SXB->XB_TIPO  	:= '5'
		SXB->XB_SEQ   	:= '01' 
		SXB->XB_COLUNA 	:= ''
		SXB->XB_DESCRI 	:= ''
		SXB->XB_DESCSPA := ''
		SXB->XB_DESCENG := ''
		SXB->XB_CONTEM 	:= 'U_xF3RETFL()' 
		SXB->(MsUnLock())
	endif	*/
return














User function RHECAROP() 
FWMsgRun(, {|| fCarrOpera() },"Carregando Arq Operadora...", "Processando, aguarde..." )
return   

Static function fCarrOpera()
local aDir := {}
local nx   := 0    
local cDiretorio := "C:\totvs\operadora2\"
aDir := DIRECTORY(cDiretorio+"*.csv","S")
DbSelectArea("ZZB")
DbSetOrder(1)
for nx:=1 to len(aDir)	
	FWMsgRun(, {|| fLerOpera(cDiretorio + Alltrim(aDir[nx,1]) ) },"Carregando Arq Operadora...", Alltrim(aDir[nx,1])+"..." )
next nx
return


static function fLerOpera(cArquivo)

local aLinha    := {}
local nPosTemp1 := 0    
local nPosTemp2 := 0    
local nPosTemp3 := 0    
local nPosTemp4 := 0    
local cNomeDep  := ""
local cCpf      := ""
local cParent   := ""
local cMatOp    := ""
local cBuffer   := ""
local cTempstr  := ""
local aCabec    := {} 
default cArquivo:= ""

if File(cArquivo) 
	
	nHandle := FT_FUSE(cArquivo) 
	if nHandle <> -1
				
		FT_FGOTOP()  
		cBuffer := Alltrim(FT_FREADLN())
		
		While  (;
				 "NOME COMPLETO DO BENEFIC" $ fTrataStr(cBuffer) .or.;
				 "CPF" 						$ fTrataStr(cBuffer) .or.;
				 "MATRICULA" 				$ fTrataStr(cBuffer) .or.;
				 "PARENTESCO" 				$ fTrataStr(cBuffer) ;
				) ;
			    .and. !FT_FEOF()
			cBuffer := Alltrim(FT_FREADLN())
			if  (;
				 "NOME COMPLETO DO BENEFIC" $ fTrataStr(cBuffer) .or.;
				 "CPF" 						$ fTrataStr(cBuffer) .or.;
				 "MATRICULA" 				$ fTrataStr(cBuffer) .or.;
				 "PARENTESCO" 				$ fTrataStr(cBuffer) ;
				) ;

				cTempstr += cBuffer
				FT_FSKIP()
			endif				
		end				
		aCabec  := StrTokArr2(cTempstr, ';',.T.)	
		FT_FSKIP()		
		
		nPosTemp1  := aScan(aCabec,{|x| "NOME COMPLETO DO BENEFIC" $ fTrataStr(x) })
		nPosTemp2  := aScan(aCabec,{|x| fTrataStr(x) == "CPF"}) 
		nPosTemp3  := aScan(aCabec,{|x| fTrataStr(x) == "MATRICULA"})
		nPosTemp4  := aScan(aCabec,{|x| fTrataStr(x) == "PARENTESCO"}) 
		if nPosTemp4 == 0
			nPosTemp4  := aScan(aCabec,{|x| fTrataStr(x) == "GP"})
		endif
						
		if nPosTemp1 == 0 .or. nPosTemp2 == 0 .or. nPosTemp3 == 0 .or. nPosTemp4 == 0
			alert(cArquivo)
			FT_FUSE()
			return
		endif
													
		While !FT_FEOF()
			
			cBuffer := Alltrim(FT_FREADLN())						
			aLinha  := StrTokArr2(cBuffer, ';',.T.)	
			
			if len(aLinha) >= nPosTemp1 .and. len(aLinha) >= nPosTemp2 .and. len(aLinha) >= nPosTemp3 .and. len(aLinha) >= nPosTemp4
				cNomeDep  := fTrataStr(aLinha[nPosTemp1])
				cCpf      := strtran(strtran(fTrataStr(aLinha[nPosTemp2]),"-",""),".","")
				cMatOp    := fTrataStr(aLinha[nPosTemp3])
				cParent   := fTrataStr(aLinha[nPosTemp4])
				
				if ChkCPF2(cCpf)
				
					if ZZB->( DbSeek( xfilial("ZZB")+padr(cCpf,11)+padr(cMatOp,30) ) )
						ZZB->(Reclock("ZZB",.F.))
					else
						ZZB->(Reclock("ZZB",.T.))
					endif
			
					ZZB->ZZB_FILIAL := xFilial("ZZB")
					ZZB->ZZB_CPF    := cCpf     //11
					ZZB->ZZB_NOME   := cNomeDep //70
					ZZB->ZZB_MATOP  := cMatOp  //30
					ZZB->ZZB_PARENT := cParent //20
  
					ZZB->(MsUnlock())
				
				endif
			endif	
 								
			FT_FSKIP()
		End
	endif
endif
FT_FUSE()
return






/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± ∫Programa: Classe ARSexcel  								 																	   										Data:   09/04/2014  ±±
±± ∫Autor: Artur Antunes Rainha Da Silveira                                                                                                            										±±
±± ∫Obs: FunÁ„o de exemplo no final do arquivo																										    									±±
±± ∫Email: silveiraartur@gmail.com																										    												±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±	Classe para geraÁ„o de planilha Excel em formato XML ou convertido para XLSX				                  																			±±
±±  																																													    ±±
±±  Metodos:																																												±±
±±   																																														±±
±±  ------------------------------------------------------------------------------------------------------------																		    ±±
±±  New																																														±±
±±    																																														±±
±±  Sintaxe: ARSexcel():New(lJob) 																																				    		±±
±±   																																														±±
±±  DescriÁ„o: MÈtodo construtor da classe																																					±±
±±    																																														±±
±±  Parametros: 																																											±±
±±  _________________________________________________________________________________																										±±
±±  | Nome   | Tipo    | DescriÁ„o                         | Default  | ObrigatÛrio |																										±±
±±  |--------------------------------------------------------------------------------  																										±±
±±  | lJob   | Logico  | Define se a geraÁ„o sera via Job  | .F.      | N„o         |																										±±
±±  |________|_________|___________________________________|__________|_____________|																										±±
±±    																																														±±
±±  ------------------------------------------------------------------------------------------------------------																		    ±±
±±  AddPlanilha()																																										    ±±
±±    																																														±±
±±  Sintaxe: ARSexcel():AddPlanilha(cTitulo,aColunas) 																																		±±
±±   																																														±±
±±  DescriÁ„o: Adiciona uma Worksheet (Planilha)																																			±±
±±    																																														±±
±±  Parametros: 																																											±±
±±  _____________________________________________________________________________________________																							±±
±±  | Nome   | Tipo    | DescriÁ„o                         | Default              | ObrigatÛrio |																							±±
±±  |--------------------------------------------------------------------------------------------																							±±
±±  |cTitulo | Caracter| Titulo do Worksheet			   | "Plan" + seguencia   | N„o         |																							±±
±±  |________|_________|___________________________________|_____________________ |_____________|																							±±
±±  |aColunas| Array   | Array simples com o espaÁamento   | Array de 40 posiÁıes | N„o         |																							±±
±±	|		 |		   | das colunas	                   | com valor 50         |             |																							±±
±±  |________|_________|___________________________________|______________________|_____________|																							±±
±±																																															±±
±±  ------------------------------------------------------------------------------------------------------------																		    ±±
±±  AddLinha()																																											    ±±
±±    																																														±±
±±  Sintaxe: ARSexcel():AddLinha(nAltura) 																																					±±
±±   																																														±±
±±  DescriÁ„o: Adiciona uma Linha																																							±±
±±    																																														±±
±±  Parametros: 																								 																			±±
±±  _________________________________________________________________________________																										±±
±±  | Nome   | Tipo    | DescriÁ„o                         | Default  | ObrigatÛrio |																										±±
±±  |--------------------------------------------------------------------------------																										±±
±±  |nAltura | numerico| Altura da linha adicionada		   | 15		  | N„o         |																										±±
±±  |________|_________|___________________________________|________________________|																										±±
±±																																															±±
±±  ------------------------------------------------------------------------------------------------------------									    									±±
±±  AddCelula()																																	    										±±
±±    																																														±±
±±  Sintaxe: ARSexcel():AddCelula(qConteudo,nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla)	±±
±±   																																														±±
±±  DescriÁ„o: Adiciona uma celula 																				 																			±±
±±    																																														±±
±±  Parametros: 																																											±±
±±  _____________________________________________________________________________________________________________________________															±±
±±  | Nome         | Tipo     | DescriÁ„o                         						   | Default              | ObrigatÛrio |															±±
±±  |----------------------------------------------------------------------------------------------------------------------------															±±
±±  |qConteudo     | Qualquer | Conteudo da celula   		      						   | Vazio				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|_____________________ |_____________|															±±
±±  |nDecimal      | Numerico | Quantidade de decimais para       						   | 0					  | N„o         |															±±
±±	|		       |		  | conteudo numerico	              						   | 			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |cAlinhamento  | Caracter | Alinhamento do conteudo da celula:						   | "L"				  | N„o         |															±±
±±	|		       |		  | "R" = Right               	      						   | 			          |             |															±±
±±	|		       |		  | "L" = Left	    			      						   | 			          |             |															±±
±±	|		       |		  | "C" = Center		             						   |   			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |cFonte		   | Caracter | Tipo de fonte do conteudo		  						   | "Arial" 			  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |nFonTam	   | Numerico | Tamanho da fonte				  						   | 8					  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |cFonteCor	   | Caracter | Cor da fonte. Deve ser informado o codigo da cor em HTML   | "000000"	 		  | N„o         |															±±
±±	|		       |		  | Referencias disponiveis em:	     						   | 			          |             |															±±
±±	|		       |		  | http://www.mxstudio.com.br/Conteudos/Dreamweaver/Cores.htm | 			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lNegrito	   | Logico   | Informa se o conteudo sera exibido em Negrito			   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lItalico	   | Logico   | Informa se o conteudo sera exibido em Italico			   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |cInterCor	   | Caracter | Cor interior da Cecula. Deve ser informado o codigo da     | Vazio		 		  | N„o         |															±±
±±	|		       |		  | cor em HTML. Referencias disponiveis em:				   | 			          |             |															±±
±±	|		       |		  | http://www.mxstudio.com.br/Conteudos/Dreamweaver/Cores.htm | 			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lTopBor	   | Logico   | Informa se tera borda superior			  			       | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lLeftBor	   | Logico   | Informa se tera borda a esquerda						   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lBottomBor	   | Logico   | Informa se tera borda inferior							   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lRightBor	   | Logico   | Informa se tera borda a direita							   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lMescla 	   | Logico   | Informa se a celula sera mesclada 					       | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |nIniMescla    | Numerico | Informa posiÁ„o inicial da Mescla  						   | 0					  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |nFimMescla    | Numerico | Informa posiÁ„o final da Mescla  						   | 0					  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±																																															±±
±±  ------------------------------------------------------------------------------------------------------------									    									±±
±±  SaveXml()																																	    										±±
±±    																																														±±
±±  Sintaxe: ARSexcel():SaveXml(cDestino,cNomeArq,lConvXlsx)																																±±
±±   																																														±±
±±  DescriÁ„o: Gera arquivo																						 																			±±
±±    																																														±±
±±  Parametros: 																																											±±
±±  _____________________________________________________________________________________________________________________________															±±
±±  | Nome         | Tipo     | DescriÁ„o                         						   | Default              | ObrigatÛrio |															±±
±±  |----------------------------------------------------------------------------------------------------------------------------															±±
±±  |cDestino	   | Caracter | Diretorio para gravaÁ„o do arquivo 						   | Pasta de arquivos    | N„o         |															±±
±±	|		       |		  |                	      						   			   | temporarios          |             |															±±
±±  |______________|__________|____________________________________________________________|_____________________ |_____________|															±±
±±  |cNomeArq      | Caracter | Nome do arquivo sem extens„o       						   | Sequencial aleatorio | N„o         |															±±
±±	|		       |		  | conteudo numerico	              						   | 			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lConvXlsx	   | Logico   | Se for True, converte o arquivo Xml para o formato 		   | .F.				  | N„o         |															±±
±±	|		       |		  | Pasta de Trabalho Excel (.Xlsx). Para que o mesmo seja 	   | 			          |             |															±±
±±	|		       |		  | convertido, È necessario que o processo n„o seja em Job e  | 			          |             |															±±
±±	|		       |		  | a estaÁ„o do Client tenha o Excel instalado 		 	   |   			          |             |															±±
±±	|		       |		  | (vers„o 2007 ou superior)								   |   			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±																																															±±
±±																																															±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Class ARSexcel 

	Data cIniXML   
	Data cFimXML   
	Data cIniPlan  
	Data cFimPlan  
	Data cIniLin   
	Data cFimLin   
	Data lJob		
	Data aPlanilha 
	Data aLinha    
	Data aCelula    
	Data aStyle    

	Method New(lJob) Constructor
	Method AddPlanilha(cTitulo,aColuna,nLinCong) 
	Method AddLinha(nAltura) 
	Method AddCelula(qConteudo,nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla,cFormNum) 
	Method SaltaCelula(nSalta)
	Method SaveXml(cDestino,cNomeArq,lConvXlsx)

EndClass  
   
 

Method New(lJobAt) Class ARSexcel

local cDtXml := SubStr(DTOS(Date()),1,4) + "-" + SubStr(DTOS(Date()),5,2) + "-" + SubStr(DTOS(Date()),7,2)	  
Default lJobAt := .F.

	::cIniXML := '<?xml version="1.0"?>'+CRLF;
				+'<?mso-application progid="Excel.Sheet"?>'+CRLF;
				+'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+CRLF;
				+' xmlns:o="urn:schemas-microsoft-com:office:office"'+CRLF;
				+' xmlns:x="urn:schemas-microsoft-com:office:excel"'+CRLF;
				+' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+CRLF;
				+' xmlns:html="http://www.w3.org/TR/REC-html40">'+CRLF;
				+' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+CRLF;
				+'  <Author>'+AllTrim(UsrFullName(__cUserId))+'</Author>'+CRLF;
				+'  <LastAuthor>'+AllTrim(UsrFullName(__cUserId))+'</LastAuthor>'+CRLF;
				+'  <Created>'+cDtXml+'T'+Time()+'Z</Created>'+CRLF;
				+'  <LastSaved>'+cDtXml+'T'+Time()+'T'+Time()+'Z</LastSaved>'+CRLF;
				+'  <Company>Microsoft</Company>'+CRLF;
				+'  <Version>14.00</Version>'+CRLF;
				+' </DocumentProperties>'+CRLF;
				+' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">'+CRLF;
				+'  <AllowPNG/>'+CRLF;
				+' </OfficeDocumentSettings>'+CRLF;
				+' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF;
				+'  <WindowHeight>7995</WindowHeight>'+CRLF;
				+'  <WindowWidth>20115</WindowWidth>'+CRLF;
				+'  <WindowTopX>240</WindowTopX>'+CRLF;
				+'  <WindowTopY>150</WindowTopY>'+CRLF;
				+'  <ProtectStructure>False</ProtectStructure>'+CRLF;
				+'  <ProtectWindows>False</ProtectWindows>'+CRLF;
				+' </ExcelWorkbook>'+CRLF 

	::cFimXML := '</Workbook>'+CRLF 
	
	::lJob 		 := lJobAt
	::aLinha  	 := {}
	::aPlanilha  := {}
	::aStyle  	 := {}
	::aCelula 	 := {}	
	
Return

        

Method AddPlanilha(cTitulo,aColuna,nLinCong) Class ARSexcel
Local nx
Default aColuna  := {50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50}
Default nLinCong := 0

if !empty(::aCelula) 
    if empty(::cIniLin) .and. empty(::cFimLin) 
		::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="15">'+CRLF
		::cFimLin  := '   </Row>'+CRLF
    endif
	AADD(::aLinha,{ {::cIniLin,::cFimLin},::aCelula } ) 
	::aCelula := {}
	::cIniLin := ""
	::cFimLin := ""
endif

if !empty(::aLinha) 
	AADD(::aPlanilha,{ {::cIniPlan,::cFimPlan},::aLinha } ) 
	::aLinha := {}
endif

Default cTitulo := 'Plan'+cvaltochar(len(::aPlanilha)+1)
::cIniLin  := ''
::cFimLin  := ''

::cIniPlan  := ' <Worksheet ss:Name="'+cTitulo+'">'+CRLF;
   			  +'  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="12">'+CRLF   
   			  
for nx:= 1 to len(aColuna)
	::cIniPlan  +='   <Column ss:AutoFitWidth="0" ss:Width="'+cvaltochar(aColuna[nx])+'"/>'+CRLF
next nx	  
		   
::cFimPlan  := '  </Table>'+CRLF
::cFimPlan  += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
::cFimPlan  += '   <PageSetup>'+CRLF
::cFimPlan  += '    <Header x:Margin="0.31496062000000002"/>'+CRLF
::cFimPlan  += '    <Footer x:Margin="0.31496062000000002"/>'+CRLF
::cFimPlan  += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"'+CRLF
::cFimPlan  += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>'+CRLF
::cFimPlan  += '   </PageSetup>'+CRLF

if nLinCong > 0
   ::cFimPlan  += '   <Unsynced/>'+CRLF
   ::cFimPlan  += '   <Selected/>'+CRLF
   ::cFimPlan  += '   <FreezePanes/>'+CRLF
   ::cFimPlan  += '   <FrozenNoSplit/>'+CRLF
   ::cFimPlan  += '   <SplitHorizontal>'+Alltrim(Str(nLinCong))+'</SplitHorizontal>'+CRLF
   ::cFimPlan  += '   <TopRowBottomPane>'+Alltrim(Str(Len(aColuna)))+'</TopRowBottomPane>'+CRLF
   ::cFimPlan  += '   <ActivePane>2</ActivePane>'+CRLF
endif

::cFimPlan  += '   <ProtectObjects>False</ProtectObjects>'+CRLF
::cFimPlan  += '   <ProtectScenarios>False</ProtectScenarios>'+CRLF
::cFimPlan  += '  </WorksheetOptions>'+CRLF
::cFimPlan  += ' </Worksheet>'+CRLF

return 



Method AddLinha(nAltura) Class ARSexcel

Default nAltura := 15  

if !empty(::aCelula) .or. !empty(::cIniLin) 
    if empty(::cIniLin) .and. empty(::cFimLin) 
		::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="15">'+CRLF
		::cFimLin  := '   </Row>'+CRLF
    endif
	AADD(::aLinha,{ {::cIniLin,::cFimLin},::aCelula } ) 
	::cIniLin  := ''
	::cFimLin  := ''
	::aCelula := {}
endif

::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="'+cvaltochar(nAltura)+'">'+CRLF
::cFimLin  := '   </Row>'+CRLF

return
 
      

Method AddCelula(qConteudo,nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla,cFormNum,cAlinVert,lWrapText) Class ARSexcel 

local nStyle		:= 0 
local cStyle		:= ''  
local cType			:= ''  
local cCelula		:= ''
local nPosPlan		:= 0 
local nPosLin		:= 0 
Default	qConteudo	:= nil
Default nDecimal	:= 0 
Default cAlinhamento:= 'L' 
Default cFonte 		:= 'Arial'
Default nFonTam		:= 8
Default	cFonteCor	:= '000000'
Default lNegrito	:= .F.
Default lItalico	:= .F.
Default	cInterCor	:= ''
Default lTopBor		:= .F.
Default lLeftBor	:= .F.
Default lBottomBor	:= .F. 
Default lRightBor	:= .F.
Default lMescla		:= .F.
Default nIniMescla	:= 0
Default nFimMescla  := 0 
Default cFormNum    := ''
Default cAlinVert   := 'B' 
Default lWrapText   := .f.

Do case
	case upper(cAlinhamento) == 'R' 
		cAlinhamento := 'Right'
	case upper(cAlinhamento) == 'C' 
		cAlinhamento := 'Center'
    Otherwise
    	cAlinhamento := 'Left'
Endcase

Do case
	case upper(cAlinVert) == 'T' 
		cAlinVert := 'Top'
	case upper(cAlinVert) == 'C' 
		cAlinVert := 'Center'
    Otherwise
    	cAlinVert := 'Bottom'
Endcase

cType := valtype(qConteudo)
if cType = 'N'
	qConteudo := alltrim( StrTran( str( qConteudo ),",","." ) )   
endif 

cFonteCor := StrTran(cFonteCor,'#','')
cInterCor := StrTran(cInterCor,'#','') 

//Adiciona estiloc					
if (nStyle := ASCANX(::aStyle, {|x| cvaltochar(nDecimal) + cAlinhamento + cFonte + cvaltochar(nFonTam) + cFonteCor + cvaltochar(lNegrito) + cvaltochar(lItalico);
									+ cInterCor + cvaltochar(lTopBor) + cvaltochar(lLeftBor) + cvaltochar(lBottomBor) + cvaltochar(lRightBor);
									+ cvaltochar(lMescla) + cvaltochar(nIniMescla) + cvaltochar(nFimMescla) + cFormNum + cAlinVert + cvaltochar(lWrapText);
							    ==  cvaltochar(x[1]) + x[2] + x[3] + cvaltochar(x[4]) + x[5] + cvaltochar(x[6]) + cvaltochar(x[7]) ;
							        + x[8] + cvaltochar(x[9]) + cvaltochar(x[10]) + cvaltochar(x[11]) + cvaltochar(x[12]) + cvaltochar(x[13]);
							        + cvaltochar(x[14]) + cvaltochar(x[15]) + x[16] + x[17] + cvaltochar(x[18])   } ) ) == 0 
							    
    nStyle  := iif(len(::aStyle)>0,len(::aStyle)+1,1)
    cStyle	:= 	   '	<Style ss:ID="s'+strzero(nStyle,3)+'">'+CRLF
    
    cStyle	+=	   '     <Alignment ss:Horizontal="'+cAlinhamento+'" ss:Vertical="'+cAlinVert+'" '+ iif(lWrapText,'ss:WrapText="1" ','') +'/>'+CRLF
	
	if lTopBor .or. lLeftBor .or. lBottomBor .or. lRightBor
		cStyle	+= '     <Borders>'+CRLF
		if lBottomBor
			cStyle	+= '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
		endif
		if lLeftBor 
			cStyle	+= '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
		endif
		if lRightBor
			cStyle	+= '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
		endif
		if lTopBor	
			cStyle	+= '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
		endif
		cStyle	+= '     </Borders>'+CRLF
	endif	
    
	cStyle	+= 	   '     <Font ss:FontName="'+cFonte+'" x:Family="Swiss" ss:Size="'+cvaltochar(nFonTam)+'" ss:Color="#'+cFonteCor+'" '+iif(lNegrito,'ss:Bold="1"','')+' '+iif(lItalico,'ss:Italic="1"','')+' />'+CRLF
	if !empty(cInterCor) 
		cStyle	+= '     <Interior ss:Color="#'+cInterCor+'" ss:Pattern="Solid"/>'+CRLF
	endif
	
	Do case
		case cType == 'N'  
			cStyle	+= '     <NumberFormat ss:Format="#,##0'
			if nDecimal > 0 
				cStyle	+= '.'+strzero(0,nDecimal)  
			endif
			if !empty(cFormNum) .and. ValType(cFormNum) == 'C'    
				if upper(cFormNum) == 'P' 
			    	cStyle	+= '%'
			    endif	
			endif	
			cStyle	+= '"/>'+CRLF
   		case cType == 'D'  	
	        cStyle	+= '     <NumberFormat ss:Format="Short Date"/>'+CRLF  
   		case cType == 'C'  	
	        cStyle	+= '     <NumberFormat ss:Format="@"/>'+CRLF
	    Otherwise
	        cStyle	+= '     <NumberFormat/>'+CRLF
	Endcase
	
	cStyle	+= 	   '	</Style>'+CRLF 

	AADD(::aStyle,{nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla,cFormNum,cAlinVert,lWrapText,cStyle})
endif	

//adiciona celula
Do Case    
	case Empty(qConteudo)
		cCelula	+=	'    <Cell '+iif(lMescla,'ss:Index="'+Alltrim(str(nIniMescla))+'" ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"/>'+CRLF	
	Case cType == 'N' 
		cCelula	+=	'    <Cell '+iif(lMescla,'ss:Index="'+Alltrim(str(nIniMescla))+'" ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"><Data ss:Type="Number">'+qConteudo+'</Data></Cell>'+CRLF	
	Case cType == "D" 
		cCelula	+=	'    <Cell '+iif(lMescla,'ss:Index="'+Alltrim(str(nIniMescla))+'" ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"><Data ss:Type="DateTime">'+fXmlData(qConteudo)+'</Data></Cell>'+CRLF
	Otherwise
		cCelula	+=	'    <Cell '+iif(lMescla,'ss:Index="'+Alltrim(str(nIniMescla))+'" ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"><Data ss:Type="String">'+fTxtXML(qConteudo)+'</Data></Cell>'+CRLF								
End Case

AADD( ::aCelula, cCelula )
       	
return    
 


Method SaltaCelula(nSalta) Class ARSexcel 
local nr       := 0
Default nSalta := 1 

if ValType(nSalta) <> "N"
	nSalta := 1
endif

if nSalta > 0
	for nr:=1 to nSalta
		::AddCelula()
	next nr	
endif 
return



Method SaveXml(cDestino,cNomeArq,lConvXlsx) Class ARSexcel  

private lEnd		:= .F.
private cArqDest 	:= ''
Default cDestino	:= AllTrim(GetTempPath()) 
Default cNomeArq	:= DTOS(Date())+StrTran(Time(),":","")  
Default lConvXlsx	:= .F.
cNomeArq += ".xml" 

if !empty(::aCelula) 
    if empty(::cIniLin) .and. empty(::cFimLin) 
		::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="15">'+CRLF
		::cFimLin  := '   </Row>'+CRLF
    endif
	AADD(::aLinha,{ {::cIniLin,::cFimLin},::aCelula } ) 
	::aCelula := {}
	::cIniLin := ""
	::cFimLin := ""
endif

if !empty(::aLinha) 
	AADD(::aPlanilha,{ {::cIniPlan,::cFimPlan},::aLinha } ) 
	::aLinha := {}    
	::cIniPlan := ""
	::cFimPlan := ""
endif  

if ::lJob
	GeraXML(cDestino+cNomeArq,::aStyle,::aPlanilha,::cIniXML,::cFimXML,lEnd,.T.,lConvXlsx) 
   	if !file(cArqDest) .and. !file(cDestino+cNomeArq)
		Conout("Erro ao criar o arquvio. Favor verificar a configura?o de acesso ao diretorio selecionado.")   	
   	endif
else
    Processa({ |lEnd| GeraXML(cDestino+cNomeArq,::aStyle,::aPlanilha,::cIniXML,::cFimXML,@lEnd,.F.,lConvXlsx) },"Aguarde...","Montando Planilha",.T.)
   	if file(cArqDest)
		//If ApOleClient("MsExcel")

			ShellExecute("open",cNomeArq+".xml","",cDestino,1)
			/*oExcelApp := MsExcel():New() 
			oExcelApp:SetVisible(.T.)
			oExcelApp:WorkBooks:Open(cArqDest) 
			oExcelApp:Destroy() */
		//endif
	elseif file(cDestino+cNomeArq)
		//If ApOleClient("MsExcel")
			/*oExcelApp := MsExcel():New() 
			oExcelApp:SetVisible(.T.)
			oExcelApp:WorkBooks:Open(cDestino+cNomeArq) 
			oExcelApp:Destroy() */
		//else
			ShellExecute("open", Alltrim(cNomeArq), "", Alltrim(cDestino), 1)
		//endif
	else 
		MsgAlert("Erro ao criar o arquvio. Favor verificar a configura?o de acesso ao diretorio selecionado.","Atencao!")
	endif	
endif

return    



Static Function fXmlData(dDtInfo)
Local cNovo     := ""
DEFAULT dDtInfo := stod("")
if ValType(dDtInfo)=="D"
	cNovo := dtos(dDtInfo)
	cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7,2)+"T00:00:00.000"
endif
Return(cNovo)



//Tratamento para texto
Static Function fTxtXML(cString)
Local cByte     := ""
local ni        := 0
Local s1		:= "·ÈÌÛ˙" + "¡…Õ”⁄" + "‚ÍÓÙ˚" + "¬ Œ‘€" + "‰ÎÔˆ¸" + "ƒÀœ÷‹" + "‡ËÏÚ˘" + "¿»Ã“Ÿ"  + "„ı√’" + "Á«ø" + "™∫∞<>&*'" + '"'
Local s2		:= "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU"  + "aoAO" + "cCC" + "        " + " "
Local nPos   	:= 0
Local cMaiorMin := "&lt;"
Local cMenorMin := "&gt;"  
Local cMaiorMai := "&LT;"
Local cMenorMai := "&GT;"
Local cRet   	:= ""
local nByte 
default cString := "" 

If cMaiorMin $ cString .or. cMenorMin $ cString .or. cMaiorMai $ cString .or. cMenorMai $ cString 
	cString := strTran( cString, cMaiorMin, " " ) 
	cString := strTran( cString, cMenorMin, " " ) 
	cString := strTran( cString, cMaiorMai, " " ) 
	cString := strTran( cString, cMenorMai, " " )
EndIf

For ni := 1 To Len(cString)
	cByte := Substr(cString,ni,1)
 	nByte := ASC(cByte)
  	nPos  := At(cByte,s1)
   	If nPos > 0
    	cByte := Substr(s2,nPos,1)
    EndIf
    cRet += cByte
Next 
 
Return(AllTrim(cRet))



Static function GeraXML(cNomeArq,aStyle,aPlanilha,cIniXML,cFimXML,lEnd,lJob,lConvXlsx) 

local aAreaXml	 := GetArea() 
local nHandle    := fCreate(cNomeArq) 
local nTotItens	 := 0 
local nContItens := 0 
local cTempTxt	 := ""  
local nLimitCarc := 1000000
Local nCont, nv, nC,nL, nP
ProcRegua(0)

If nHandle == -1 
	if lJob
	    ConOut("Aten?o","Erro ao criar o arquvio " + cNomeArq + ". Favor verificar a configura?o do micro.")
	else 
		MsgAlert("Aten?o","Erro ao criar o arquvio " + cNomeArq + ". Favor verificar a configura?o do micro.","Atencao!")
	endif
	RestArea(aAreaXml)
	Return
EndIf 

//FWrite(nHandle,cIniXML)
cTempTxt += cIniXML 
cTempTxt += '<Styles>'+CRLF 
cTempTxt += '	<Style ss:ID="Default" ss:Name="Normal">'+CRLF  
cTempTxt += '	 <Alignment ss:Vertical="Bottom"/>'+CRLF
cTempTxt += '	 <Borders/>'+CRLF
cTempTxt += '	 <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
cTempTxt += '	 <Interior/>'+CRLF
cTempTxt += '	 <NumberFormat/>'+CRLF
cTempTxt += '	 <Protection/>'+CRLF
cTempTxt += '	</Style>'+CRLF
FWrite(nHandle,cTempTxt)
cTempTxt := ""

if !lJob //conta registros
	nTotItens := len(aStyle)
	for nCont:=1 to len(aPlanilha) 
		nTotItens += len(aPlanilha[nCont,2]) 
    next nCont
endif 
nTotItens++              
ProcRegua(nTotItens)
 
//Estilos
for nv:=1 to len(aStyle)
    if (len(cTempTxt)+len(aStyle[nv,19])) > nLimitCarc
      	FWrite(nHandle,cTempTxt)
      	cTempTxt := ""
    endif 
	cTempTxt += aStyle[nv,19]
	if !lJob
		nContItens++  	
		IncProc("Montando Planilha...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(99,2)) + "%")	
	endif      
next nv	
cTempTxt += '</Styles>'+CRLF
FWrite(nHandle,cTempTxt) 
cTempTxt := ""

//sheet
for nP:=1 to len(aPlanilha)

	if lEnd 
		Exit
	endif
	
	cTempTxt += aPlanilha[nP,1,1] //Inicio da planilha 
    
	for nL:=1 to len(aPlanilha[nP,2]) //adiciona linhas 
	
		if lEnd 
			Exit
		endif
		
        if (len(cTempTxt)+len(aPlanilha[nP,2,nL,1,1])) > nLimitCarc
            FWrite(nHandle,cTempTxt)
            cTempTxt := ""
        endif
        cTempTxt += aPlanilha[nP,2,nL,1,1] //Inicio da linha
        
		for nC:=1 to len(aPlanilha[nP,2,nL,2]) //adiciona celulas
			
  	        if (len(cTempTxt)+len(aPlanilha[nP,2,nL,2,nC])) > nLimitCarc
            	FWrite(nHandle,cTempTxt)
            	cTempTxt := ""
            endif 
			cTempTxt += aPlanilha[nP,2,nL,2,nC] 
			
		next nC
        
        if (len(cTempTxt)+len(aPlanilha[nP,2,nL,1,2])) > nLimitCarc
            FWrite(nHandle,cTempTxt)
            cTempTxt := ""
        endif  
        cTempTxt += aPlanilha[nP,2,nL,1,2] //Fim da linha

		if !lJob
			nContItens++  	
			IncProc("Montando Planilha...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(99,2)) + "%")	
		endif
    next nL

    if (len(cTempTxt)+len(aPlanilha[nP,1,2])) > nLimitCarc
        FWrite(nHandle,cTempTxt)
        cTempTxt := ""
    endif  
	cTempTxt += aPlanilha[nP,1,2] //Fim da planilha

	FWrite(nHandle,cTempTxt)
	cTempTxt := ""

next nP
FWrite(nHandle,cFimXML) 
fClose(nHandle) 

if lEnd .and. file(cNomeArq)
	if lJob
	    ConOut("Relatorio Cancelado pelo usuario")
	else 
		MsgAlert("Relatorio Cancelado pelo usuario","Atencao!")
	endif
	FErase(cNomeArq) 
endif   
      
if file(cNomeArq)
	if lConvXlsx      
		if lJob
			ConvertXlsx(cNomeArq,lJob)
		else
		   	Processa({ || ConvertXlsx(cNomeArq,lJob)},"Gerando arquivo, aguarde...","Planilha Excel") 
		endif		   	
	endif    
endif		

if !lJob
	nContItens++  	
	IncProc("Montando Planilha...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(100,3)) + "%")	
endif 

RestArea(aAreaXml)
return     



static Function ConvertXlsx(cArqOri,lJob)
Local nHandler 
Local cVbs := ''
Local cDrive := ''
Local cDir   := ''
Local cNome  := ''
Local cExt   := '' 
local cArqVbs := '' 
local lContinua := .F.    
if !lJob
	ProcRegua(0) 
endif	
if !empty(cArqOri) //.and. ApOleClient('MsExcel') 
	lContinua := .T.
	SplitPath(cArqOri,@cDrive,@cDir,@cNome,@cExt)
	cArqDest := cDrive+cDir+cNome+".xlsx"
	cArqVbs := AllTrim(GetTempPath())+cNome+".vbs"
endif
cVbs := 'Dim objXLApp, objXLWb '+CRLF
cVbs += 'Set objXLApp = CreateObject("Excel.Application") '+CRLF
cVbs += 'objXLApp.Visible = False '+CRLF
cVbs += 'Set objXLWb = objXLApp.Workbooks.Open("'+cArqOri+'") '+CRLF
cVbs += 'objXLWb.SaveAs "'+cArqDest+'", 51 '+CRLF
cVbs += 'objXLWb.Close (true) '+CRLF
cVbs += 'Set objXLWb = Nothing '+CRLF
cVbs += 'objXLApp.Quit '+CRLF
cVbs += 'Set objXLApp = Nothing '+CRLF
if lContinua
	nHandler := FCreate(cArqVbs)
	If nHandler <> -1 
		FWrite(nHandler, cVbs)
		FClose(nHandler)                                   
		if WaitRun('cscript.exe '+cArqVbs,0) == 0 
			if file(cArqDest)
				if file(cArqOri)
					FErase(cArqOri)
				endif
				if file(cArqVbs)
					FErase(cArqVbs)
				endif
			else
		    	lContinua := .F.
		    endif
		else
		   	lContinua := .F.
		endif
	else
	   	lContinua := .F.	  	 
	endif
endif 
if !lContinua
	if file(cArqDest)
		FErase(cArqDest)
	endif
	if file(cArqVbs)
		FErase(cArqVbs)
	endif
endif
Return              

