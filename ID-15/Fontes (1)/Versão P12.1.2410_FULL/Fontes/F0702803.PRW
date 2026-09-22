#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F0702803
Função para integração de alteração de título
@type User function
@author anieli.rodrigues
@since 20/03/2017
@version 12.7
@param oComp, object, Dados da alteração a ser realizada
@project MAN0000007423041_EF_028
/*/

User Function F0702803(oComp)

    Local aLog			:= {}
	Local aTitulo       := {}
	Local bBlock 		:= ErrorBlock({|e|ChkErr(e)})
	Local cFilComp	    := ""
	Local cIndKey		:= ""
	Local cPipe			:= "|"
	Local cRet			:= "ERRO|"
	Local lRet			:= .T.
	Local nRegLog		:= 0
	Local nTamNum		:= TamSX3("E1_NUM")[1]
	Local nTamParc	    := TamSX3("E1_PARCELA")[1]
	Local nTamPref  	:= TamSX3("E1_PREFIXO")[1] 
	Local nTamTipo	    := TamSX3("E1_TIPO")[1] 
	Local nY			:= 0

	Private cErrorL			:= ""
	Private cXID			:= U_GetIntegID()
	Private lAutoErrNoFile 	:= .T.
	Private lMsErroAuto 	:= .F.
	
	Begin Sequence 

		Begin Transaction 
        	nRegLog := U_F07LOG01(cXID,{oComp})
        End Transaction 
	
		cFilComp := Alltrim(oComp:cFilReg)
	
		If Empty(cFilComp) .Or. !ExistCpo("SM0",cEmpAnt + cFilComp)
			lRet := .F.
			cRet += "PARAMETRO OBRIGATORIO INVALIDO: CFILREG"
		Else 
			cFilAnt := cFilComp
		EndIf

        If Empty(oComp:CACRESC) .And. Empty(oComp:CDECRESC)
            lRet := .F. 
            cRet += "PARAMETROS OBRIGATORIO INVALIDO: CACRESC E CDECRESC"
        EndIf 

        If lRet  

            SE1->(DbSetOrder(1)) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_PARCELA, E1_TIPO
			If !SE1->(DbSeek(xFilial("SE1") + Padr(oComp:CPREFIXO,nTamPref) + Padr(oComp:CNUM,nTamNum) + Padr(oComp:CPARCELA,nTamParc) + Padr(oComp:CTIPO,nTamTipo)))
				cRet += "TITULO NAO LOCALIZADO"	
				lRet := .F. 
			EndIf 
				
			If lRet 
				cIndKey:= xFilial("SE1") + cPipe + Padr(oComp:CPREFIXO,nTamPref) + cPipe + Padr(oComp:CNUM,nTamNum) + cPipe + Padr(oComp:CPARCELA,nTamParc) + cPipe + Padr(oComp:CTIPO,nTamTipo)
                AAdd(aTitulo,{"E1_PREFIXO"   ,Padr(oComp:CPREFIXO,nTamPref)  ,NIL})
                AAdd(aTitulo,{"E1_NUM"       ,Padr(oComp:CNUM,nTamNum)       ,NIL})
                AAdd(aTitulo,{"E1_TIPO"      ,Padr(oComp:CTIPO,nTamTipo)     ,NIL})
                AAdd(aTitulo,{"E1_PARCELA"   ,Padr(oComp:CPARCELA,nTamParc)  ,NIL})
                            
                If !Empty(oComp:CACRESC)
                    AAdd(aTitulo,{"E1_ACRESC"   ,Val(oComp:CACRESC) ,NIL})
                EndIf 

                If !Empty(oComp:CACRESC)
                    AAdd(aTitulo,{"E1_DECRESC"   ,Val(oComp:CDECRESC) ,NIL})
                EndIf 
                
                MsExecAuto({|x,y|FINA040(x,y)},aTitulo,4)

                If lMsErroAuto
				    cRet += "INCONSISTENCIA DE ROTINA AUTOMATICA | " + CRLF
				    aLog := GetAutoGRLog()
				    For nY := 1 To Len(aLog)
    					cRet += aLog[nY] + CRLF
	    			Next nY
                Else 
					cRet := "OK"
				EndIf 
            EndIf
        EndIf 
    End Sequence 

    ErrorBlock(bBlock)

	If !Empty(cErrorL)
		lRet := .F. 
		cRet += "ERRO DE PROGRAMACAO | " + CRLF + cErrorL
	EndIf 

	U_F07Log02(nRegLog, cRet, lRet,"SE1",1,cIndKey)

Return cRet

/*/{Protheus.doc} ChkErr
Função para tratamento de erros 
@type function
@author anieli.rodrigues
@since 20/03/2017
@version 12.7
@param oErroArq, object, Dados do erro capturado
@project MAN0000007423041_EF_028
/*/

Static Function ChkErr(oErroArq)

	Local nI:= 0
	
	If oErroArq:GenCode > 0
		cErrorL := '(' + Alltrim(Str(oErroArq:GenCode)) + ') : ' + AllTrim(oErroArq:Description) + CRLF
	EndIf  
	
	nI := 2
	
	While (!Empty(ProcName(ni)))
		cErrorL += Trim(ProcName(ni)) + "(" + Alltrim(Str(ProcLine(ni))) + ") " + CRLF
		ni ++
	End                
	If Intransact()
		cErrorL +="Transacao aberta desarmada"
	 	DisarmTransaction()
	EndIf
	Break
Return
    
            
            