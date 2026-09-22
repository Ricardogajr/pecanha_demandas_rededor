#Include 'PROTHEUS.CH'

/*/{Protheus.doc} F0702501
MÃ©todo que insere ou altera o registro.
@type 		function
@author 	robson.william
@since 		16/02/2017
@version 	1.0
@param 		oProduto, objeto, Objeto com os campos e valores
@project	MAN000007423041_EF_025
@return 	cRetorno, Mensagem de sucesso ou erro

/*/
User Function F0702501(oProduto)
	Local nX	
	Local bBlock
	Local nOperac	:= 3
	Local cRetorno	:= ""//"ERRO|"
	Local aCpsRot	:= {}
	Local cFilInt	:= ""	
	Local cFilAtu	:= ""
	Local cCodProd	:= ""
    Local cCodMDM   := ""
	Local lErroProc	:= .F.
	Local cIdInt 	:= U_GetIntegID()
	Local nRegLog	:= 0
	Local aRetDesc  := {}
	Local lPermt    := .T.
	Local aRet      := {}
 
	Private cErrorL 		:= ""
	Private lAutoErrNoFile 	:= .T.
	Private lMsErroAuto 	:= .F.
 
	cFilInt := oProduto:cFilReg

	Begin Transaction
		nRegLog := U_F07LOG01(cIdInt,{oProduto})
	End Transaction

	If ! U_F07ChkFil(oProduto:cFILREG)
    	cRetorno:= "ERRO| Filial Invalida  "
		U_F07LOG02(nRegLog,cRetorno,.f.,"SB1",1,'')
		Return cRetorno
	EndIf

//	cFilInt := oProduto:cFilReg

	If !(cFilInt == cFilAnt)
		cFilAtu := cFilAnt
		cFilAnt := cFilInt
	EndIf

	//Tratamento dos campos de Data
	If !Empty(oProduto:cXVALANV)
		If Empty(Ctod(oProduto:cXVALANV))
			cRetorno:= "ERRO|DATA INVÁLIDA NA PROPRIEDADE cXVALANV"
			U_F07LOG02(nRegLog,cRetorno,.f.,"SB1",1,xFilial('SB1') + '|' + oProduto:cCod)
			Return cRetorno
		Endif
	Endif
	
	If !Empty(oProduto:cXDESCLO)
		aRetDesc := U_F1206102(oProduto:cXDESCLO)
		If aRetDesc[1][1]
			oProduto:cXDESCLO := aRetDesc[1][2]
		Else
			cRetorno:= "ERRO|JÁ EXISTE A DESCRIÇÂO DA PROPRIEDADE cXDESCLO NO CADASTRO DE PRODUTO (código: " + oProduto:cCod + ")"	
			U_F07LOG02(nRegLog,cRetorno,.f.,"SB1",1,xFilial('SB1') + '|' + oProduto:cCod)
			Return cRetorno
		EndIf
	EndIf

	//Tratamento do CÃ³digo do Produto
	cCodProd := oProduto:cCod
    cCodMDM  := oProduto:cXMDMCOD

    SB1->(DbSetOrder(1))
    If ! Empty(cCodProd) .and. SB1->(DbSeek(xFilial("SB1") + cCodProd))
        nOperac := 4
        AAdd(aCpsRot,{"B1_COD"     	,cCodProd				,Nil})
    Else
        SB1->(DBOrderNickName("EF0702501"))
        If ! Empty(cCodMDM) .and. SB1->(DbSeek(xFilial("SB1") + cCodMDM))
            nOperac := 4
            cCodProd := SB1->B1_COD
            AAdd(aCpsRot,{"B1_COD"     	,cCodProd				,Nil})
        Else
            nOperac := 3
        EndIf
    EndIf
    

    SB1->(DbSetOrder(1))

	//PreparaÃ§Ã£o do array da rotina automÃ¡tica
	AAdd(aCpsRot,{"B1_DESC"    	,Upper(oProduto:cDesc)	,Nil})
	AAdd(aCpsRot,{"B1_GRUPO" 	,oProduto:cGRUPO		,Nil})
	AAdd(aCpsRot,{"B1_LOCPAD"  	,oProduto:cLocPad		,Nil}) 
	AAdd(aCpsRot,{"B1_UM"      	,oProduto:cUM			,Nil})
	AAdd(aCpsRot,{"B1_SEGUM"    ,oProduto:cSEGUM		,Nil}) 
	AAdd(aCpsRot,{"B1_CONV"    	,Val(oProduto:cCONV)	,Nil}) 
	AAdd(aCpsRot,{"B1_TIPCONV"  ,oProduto:cTIPCONV		,Nil}) 
	AAdd(aCpsRot,{"B1_SITPROD" 	,oProduto:cSITPROD 		,Nil})
	AAdd(aCpsRot,{"B1_CONTA" 	,oProduto:cCONTA 		,Nil})
	AAdd(aCpsRot,{"B1_XMATSER" 	,oProduto:cXMATSER		,Nil})
	AAdd(aCpsRot,{"B1_POSIPI" 	,oProduto:cNCM 			,Nil})
	AAdd(aCpsRot,{"B1_XBRASIN" 	,oProduto:cXBRASIN 		,Nil})
	AAdd(aCpsRot,{"B1_XANVISA" 	,oProduto:cXANVISA 		,Nil})
	AAdd(aCpsRot,{"B1_XREFER" 	,oProduto:cXREFER 		,Nil})
	AAdd(aCpsRot,{"B1_XPARTNU" 	,oProduto:cXPARTNU		,Nil})
	AAdd(aCpsRot,{"B1_XESTOQ" 	,oProduto:cXESTOQ 		,Nil})
	AAdd(aCpsRot,{"B1_XBLOQ" 	,oProduto:cXBLOQ  		,Nil})
	AAdd(aCpsRot,{"B1_XFATURA"	,oProduto:cXFATURA		,Nil})
	AAdd(aCpsRot,{"B1_XTERUM" 	,oProduto:cXTERUM 		,Nil})
	AAdd(aCpsRot,{"B1_XCODFAB" 	,oProduto:cXCODFAB		,Nil})
	AAdd(aCpsRot,{"B1_XSIMPRO" 	,oProduto:cXSIMPRO		,Nil})
	AAdd(aCpsRot,{"B1_XTUSS" 	,oProduto:cXTUSS  		,Nil})
	AAdd(aCpsRot,{"B1_XID" 		,cIdInt    				,Nil})				
	AAdd(aCpsRot,{"B1_XTCONV2" 	,oProduto:cXTCONV2		,Nil})
	AAdd(aCpsRot,{"B1_XDESMED" 	,oProduto:cXDESCLI		,Nil})
	AAdd(aCpsRot,{"B1_XDES" 	,oProduto:cXDESCLO		,Nil})				
	AAdd(aCpsRot,{"B1_XGRPPRO" 	,oProduto:cXGRPPRO		,Nil})
	AAdd(aCpsRot,{"B1_XSUBGRP" 	,oProduto:cXSUBGRP		,Nil})
	AAdd(aCpsRot,{"B1_XP12FRO" 	,oProduto:cXP12FRO		,Nil})
	AAdd(aCpsRot,{"B1_XFROP12" 	,oProduto:cXFROP12		,Nil})
	AAdd(aCpsRot,{"B1_XCOMP" 	,Val(oProduto:cXCOMP)	,Nil})
	AAdd(aCpsRot,{"B1_XVALANV" 	,Ctod(oProduto:cXVALANV),Nil})
	AAdd(aCpsRot,{"B1_XCONV2" 	,Val(oProduto:cXCONV2) 	,Nil})
	AAdd(aCpsRot,{"B1_XCONSUM" 	,Val(oProduto:cXCONSUM)	,Nil})
	AAdd(aCpsRot,{"B1_TIPO"    	,oProduto:cTipo			,Nil}) 		
	AAdd(aCpsRot,{"B1_XATUAL"  	,oProduto:cXATUAL		,Nil}) 			
    If ! Empty(cCodMDM)
        AAdd(aCpsRot,{"B1_XMDM"     	,cCodMDM				,Nil})
    EndIf
    
	bBlock  := ErrorBlock({|e|ChkErr(e)})

	Begin Transaction				  
		U_F07PADR(aCpsRot)
		If nOperac == 4
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1") + cCodProd))
		EndIf

		// ID 1283 - Retirada a gravação da SB1 em caso de operação de alteração
		// ID 1443 - Rujany Guedes ( o Numero da operação estava errado 
//		IF nOperac <> 3 
		IF nOperac <> 4 
			MSExecAuto({|x,y| Mata010(x,y)},aCpsRot,nOperac)
		Endif

		If lMsErroAuto
			DisarmTransaction()
			Break
		Else
			If nOperac == 3
				cCodProd := SB1->B1_COD
			EndIF
            P17->(DbSetOrder(1))
            If P17->(DbSeek(xFilial('P17') + cCodProd + cFilInt))
                P17->(RecLock('P17', .F.))
                    If ! Empty(oProduto:cP17FATUR)
                    	lPermt := F1206402(cFilInt, "P17_FATUR", .T.)
                    	If lPermt
                        	P17->P17_FATUR  := oProduto:cP17FATUR
                        EndIf
                    EndIf
                    If ! Empty(oProduto:cP17ATUAL)
                     	lPermt := F1206402(cFilInt, "P17_ATUAL", .T.)
                    	If lPermt
                        	P17->P17_ATUAL  := oProduto:cP17ATUAL
                        EndIf
                    EndIf
                    If ! Empty(oProduto:cP17BLOQ)
                    	lPermt := F1206402(cFilInt, "P17_BLOQ", .T.)
                    	If lPermt
                        	P17->P17_BLOQ   := oProduto:cP17BLOQ
                        EndIf
                    EndIf
                    If ! Empty(oProduto:cP17ESTOQ)
                     	lPermt := F1206402(cFilInt, "P17_ESTOQ", .T.)
                    	If lPermt
                        	P17->P17_ESTOQ  := oProduto:cP17ESTOQ
                        EndIf	
                    EndIf
                P17->(MsUnlock())
				aRet := U_F1206403(cFilInt, cCodProd,.T.)
                If !(aRet[1])
                	cRetorno := "ERRO P17|FILIAL INFORMADA NÃO É UMA MATRIZ OU PRODUTO NÃO ENCONTRADO"	
                EndIf
				
				aRet := {}
            EndIf
        cRetorno += "OK|" + SB1->B1_COD
		EndIf
		If Empty(cCodProd)
			cCodProd := SB1->B1_COD
		Endif
		U_F07LOG02(nRegLog,cRetorno,.t.,"SB1",1,xFilial('SB1') + '|' + cCodProd)

	End Transaction
	ErrorBlock(bBlock)

	If lMsErroAuto
		cRetorno := "ERRO|EXECUCAO DA ROTINA AUTOMATICA" + CRLF
		aLog := GetAutoGRLog()
		For nX := 1 To Len(aLog)
			cRetorno += aLog[nX] + CRLF
		Next nX
		U_F07LOG02(nRegLog,cRetorno,.F.,"SB1",1,xFilial('SB1') + '|' + cCodProd)
	Endif

	If !Empty(cErrorL)
		cRetorno := "ERRO|ERRO ROTINA INTERNA" + CRLF + cErrorL
		U_F07LOG02(nRegLog,cRetorno,.F.,"SB1",1,xFilial('SB1') + '|' + cCodProd)
	EndIf

	aCpsRot := ASize(aCpsRot, 0)
	aCpsRot := Nil


	If !(cFilAtu == cFilAnt)
		cFilAnt := cFilAtu	
	EndIf

Return cRetorno

/*/{Protheus.doc} ChkErr
FunÃ§Ã£o para tratamento de erros 
@type function
@author anieli.rodrigues
@since 03/02/2017
@version 12.7
@param oErroArq, object, Dados do erro capturado
@project MAN0000007423041_EF_033
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
	cErrorL +="Transação Aberta Desarmada"
	DisarmTransaction()
EndIf
Break

Return

/*/{Protheus.doc} ChkErr
FunÃ§Ã£o para tratamento de erros 
@type function
@author alex.sandro
@since 03/02/2017
@version 12.7
@param oErroArq, object, Dados do erro capturado
@project MAN0000007423041_EF_033
/*/
Static Function PegaLog()
Local aLog      := GetAutoGRLog()
Local nY
Local lcampos   := .f.
Local cLinha    := '' 
Local cRet      := ''
For nY := 1 To Len(aLog)
    If Empty(aLog[nY])
        Loop
    EndIf
    cLinha := aLog[nY] + CRLF
    If ':=' $ cLinha
        lcampos:= .t.
    EndIf
	If lcampos
        If "Invalido" $ cLinha
            cRet += cLinha
        EndIf
    Else
        cRet += cLinha
    EndIF
Next nY
Return cRet + CRLF