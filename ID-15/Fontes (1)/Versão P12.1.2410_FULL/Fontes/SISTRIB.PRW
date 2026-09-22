/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³SISTRIB³ Autor ³ Fernando Lopez                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta layout de tributo de acordo com o modelo de PG		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA300													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#Include "Rwmake.ch" 
#Include "Protheus.ch"      
User Function Sistrib()
Local cRetorno := ""  
Local cStr := "" 
/*
Variavel criada para atender a determinacao da receita, onde o CNPJ a ser apresentado na Gui de comprovante de pagamento é o CNPJ da Matriz.
Para que funcione é necessário criar o parâmetro "MV_CNPJMAT" | "C", no mesmo deve ser informado o CNPJ da Matriz. O prâmetro deve ser criado 
por empresa, como se fosse um CNPJ centralizado. 29/10/2012 - Nelson Motta 
*/
//Local cCNPJ := SM0->M0_CGC
Local cCNPJ := IIF(!(Empty(GetMV("MV_XCNPJMA"))),GetMV("MV_XCNPJMA"),SubStr(SM0->M0_CGC,1,14))           

If AllTrim(SEA->EA_MODELO) == "17"	// GPS
	cRetorno := "01"
	cRetorno += If (Empty(SE2->E2_RETINS),"2631",SubStr(SE2->E2_RETINS,1,4))
	cRetorno += SubStr(Dtos(SE2->E2_XCOMPET),5,2) + SubStr(Dtos(SE2->E2_XCOMPET),1,4)
	//cRetorno += SubStr(SM0->M0_CGC,1,14) - Nelson Motta 04/03/2013
	//cRetorno += If (SE2->E2_CODRET $ "2631|    ", SubStr(SA2->A2_CGC,1,14),SubStr(SM0->M0_CGC,1,14)) - ALTERADO 02/01/14 - Tratamento correto do CGC pro GPS
	If Alltrim(SE2->E2_PREFIXO) == "AGI" 
		cRetorno += If (SE2->E2_RETINS $ "2631|    ", If(EMPTY(SE2->E2_TITPAI),SubStr(SE2->E2_CNPJRET,1,14),POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(SE2->E2_TITPAI,17,6)+SUBSTR(SE2->E2_TITPAI,23,2),"A2_CGC")),SubStr(SM0->M0_CGC,1,14))	//Tratar pelo campo E2_TITPAI para as GPS de Fornecedores //
	Else
		If Alltrim(SE2->E2_TIPO) == "FT" .And. Empty(SE2->E2_TITPAI) .And. Empty(SA2->A2_CGC)
			cRetorno += If (SE2->E2_RETINS $ "2631|    ", U_RetCNPJUni(),SubStr(SM0->M0_CGC,1,14))	//Tratar pelo campo E2_TITPAI para as GPS de Fornecedores // 
		ElseIf !Empty(SE2->E2_XCNPJJU) 
			cRetorno += Alltrim(SE2->E2_XCNPJJU)
		Else
			cRetorno += If (SE2->E2_RETINS $ "2631|    ", If(EMPTY(SE2->E2_TITPAI),SubStr(SA2->A2_CGC,1,14),POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(SE2->E2_TITPAI,17,6)+SUBSTR(SE2->E2_TITPAI,23,2),"A2_CGC")),SubStr(SM0->M0_CGC,1,14))	//Tratar pelo campo E2_TITPAI para as GPS de Fornecedores //
		EndIf	
	EndIf

	cRetorno += StrZero((SE2->E2_SALDO - If (SE2->E2_PREFIXO='GPE',SE2->E2_XTERCEI,0))*100,14)
	cRetorno += If (SE2->E2_PREFIXO='GPE',StrZero(SE2->E2_XTERCEI*100,14),StrZero(0,14)) //valor de outras entidades
	cRetorno += StrZero((SE2->E2_MULTA + SE2->E2_JUROS)*100,14)                   //atualização monetaria/multa e juros
    cRetorno += StrZero((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS)*100,14) //StrZero(SE2->E2_SALDO*100,14)   //valor arrecadado
	cRetorno += GravaData(SE2->E2_VENCREA, .F.,5)
	cRetorno += Space(58)
	//cRetorno += SubStr(Upper(AllTrim(SM0->M0_NOMECOM)),1,30) -  Nelson Motta 04/03/2013
	cRetorno += If (SE2->E2_RETINS $ "2631|    ",SubStr(Upper(AllTrim(SA2->A2_NOME)),1,30),SubStr(Upper(AllTrim(SM0->M0_NOMECOM)),1,30))
	
ElseIf AllTrim(SEA->EA_MODELO) == "16"	// DARF
	cRetorno := "02"
	cRetorno += SubStr(SE2->E2_CODRET,1,4)
	cRetorno += "2" 
	If !Empty(SE2->E2_XCNPJJU)
		cRetorno += Alltrim(SE2->E2_XCNPJJU)
	Else
		cRetorno += Substr(cCNPJ,1,14) 
	EndIf
	cRetorno += GravaData(SE2->E2_XCOMPET, .F., 5) //"30" + SubStr(Dtos(SE2->E2_XCOMPET),5,2) + SubStr(Dtos(SE2->E2_XCOMPET),1,4)
	cRetorno += IIF(!Empty(SE2->E2_XDARFRF), Replicate("0",17-Len(Alltrim(SE2->E2_XDARFRF))) + Alltrim(SE2->E2_XDARFRF), Replicate("0", 17))
	cRetorno += StrZero(SE2->E2_SALDO*100,14)
	cRetorno += StrZero(SE2->E2_MULTA*100,14) 
	cRetorno += StrZero(SE2->E2_JUROS*100,14)  
	//cRetorno += StrZero(SE2->E2_ACRESC*100,14) // tratamento de juros e multa em 14/02/2013
	//cRetorno += StrZero(0,14)
	//cRetorno += StrZero(SE2->E2_SALDO*100,14)// antes do tratamento de juros/multa
    cRetorno += StrZero((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS)*100,14) // tratamento de juros e multa  em 14/12/2013
	cRetorno += GravaData(SE2->E2_VENCREA, .F.,5)
	cRetorno += GravaData(SE2->E2_VENCREA, .F.,5)
	cRetorno += Space(30)
	cRetorno += SubStr(Upper(AllTrim(SM0->M0_NOMECOM)),1,30)

ElseIf AllTrim(SEA->EA_MODELO) == "18"	// DARF SIMPLES 
	cRetorno := "03"
	cRetorno += SubStr(SE2->E2_CODRET,1,4)
	cRetorno += "2"
	cRetorno += SubStr(SM0->M0_CGC,1,14)
	cRetorno += GravaData(SE2->E2_XCOMPET, .F., 5) //"30" + SubStr(Dtos(SE2->E2_XCOMPET),5,2) + SubStr(Dtos(SE2->E2_XCOMPET),1,4)
	cRetorno += StrZero(SE2->E2_SALDO*100,9)
	cRetorno += StrZero(0,4)
	cRetorno += Space(04)
	cRetorno += StrZero(Int(SE2->E2_VALOR * 100),14)
	cRetorno += StrZero(Int(SE2->E2_MULTA * 100),14)
	cRetorno += StrZero(Int(SE2->E2_JUROS * 100),14)
	cRetorno += StrZero(Int(SE2->E2_SALDO * 100),14)
	cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
	cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
	cRetorno += Space(30)
	cRetorno += SubStr(Upper(AllTrim(SM0->M0_NOMECOM)),1,30)

ElseIf AllTrim(SEA->EA_MODELO) == "21"	// DARF
	cRetorno := "04"
	cRetorno += If (Empty(SE2->E2_CODRET),"0000",SubStr(SE2->E2_CODRET,1,4))
	cRetorno += "2"
	cRetorno += SubStr(SM0->M0_CGC,1,14)
	cRetorno += SubStr(SM0->M0_INSC,1,08)	
	cRetorno += Space(17)
	cRetorno += StrZero(SE2->E2_SALDO*100,9)
	cRetorno += StrZero(0,14)
	cRetorno += StrZero(0,14)
	cRetorno += StrZero(0,14)
	cRetorno += StrZero(SE2->E2_SALDO*100,9)
	cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
	cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
	cRetorno += GravaData(SE2->E2_XCOMPET, .F., 5) //"30" + SubStr(Dtos(SE2->E2_XCOMPET),5,2) + SubStr(Dtos(SE2->E2_XCOMPET),1,4)
	cRetorno += Space(10)
	cRetorno += SubStr(Upper(AllTrim(SM0->M0_NOMECOM)),1,30)  
	
ElseIf AllTrim(SEA->EA_MODELO) == "22"	// GARE itau
	
	cRetorno := "05"
	cRetorno += If (Empty(SE2->E2_CODRET),"0000",SubStr(SE2->E2_CODRET,1,4))
	cRetorno += "2"
	cRetorno += IIF(Empty(SE2->E2_XCNPJJU), Alltrim(SE2->E2_XCNPJJU), SubStr(SM0->M0_CGC,1,14))
	cRetorno += IIF(!Empty(Alltrim(SE2->E2_XIESTAD)), SE2->E2_XIESTAD, SubStr(SM0->M0_INSC,1,12))	
	cRetorno += StrZero(0,13)
	cRetorno += SubStr(Dtos(SE2->E2_XCOMPET),5,2) + SubStr(Dtos(SE2->E2_XCOMPET),1,4)
	cRetorno += StrZero(0,13)
	cRetorno += StrZero(SE2->E2_SALDO*100,14)
	cRetorno += StrZero(Int(SE2->E2_JUROS * 100),14)
	cRetorno += StrZero(Int(SE2->E2_MULTA * 100),14)
	cRetorno += StrZero((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS)*100,14) // tratamento de juros e multa  em 14/12/2013
	cRetorno += GravaData(SE2->E2_VENCREA, .F.,5)
	cRetorno += GravaData(SE2->E2_VENCREA, .F.,5)
	cRetorno += Space(11)
	cRetorno += SubStr(Upper(AllTrim(SM0->M0_NOMECOM)),1,30) 

ElseIf AllTrim(SEA->EA_MODELO) $ "25|27" //IPVA, DPVAT itau

	cRetorno := IIF(SEA->EA_MODELO == "25", "07", "08") // 07-IPVA,  08-DPVAT
	cRetorno += Space(4)
	cRetorno += "2"                                     // 1-CPF, 2-CNPJ
	cRetorno += SubStr(SM0->M0_CGC,1,14)                // CPF/CNPJ
	cRetorno += SubStr(Dtos(SE2->E2_XCOMPET),1,4)       // Ano base
	cRetorno += IIF(!Empty(SE2->E2_XRENAV) .And. Len(Alltrim(Str(Val(SE2->E2_XRENAV)))) == 9, StrZero(Val(SE2->E2_XRENAV),9), Replicate("0",9))
	cRetorno += SE2->E2_XUFVEIC           // UF
	cRetorno += SE2->E2_XMUNICV //Space(5)                                        // Cod. município
	cRetorno += SE2->E2_XPLACA
	cRetorno += IIF(SEA->EA_MODELO == "25", U_RetOpPag() , "0")                                    // Opção de pagamento
	cRetorno += StrZero(SE2->E2_SALDO*100,14)            // valor do IPVA/DPVAT
	cRetorno += IIF(SEA->EA_MODELO == "25", StrZero(SE2->E2_DECRESC*100,14), Replicate("0", 14))          // valor do desconto
	cRetorno += IIF(SEA->EA_MODELO == "25", StrZero(SE2->(E2_SALDO+E2_MULTA+E2_JUROS+E2_ACRESC-E2_DECRESC)*100,14) ,StrZero((SE2->E2_SALDO)*100,14))          // valor do pagamento	                                                                                                                           
	cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)        // data de vencimento
	cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)        // data de pagamento
	cRetorno += Space(29)
	cRetorno += IIF(!Empty(SE2->E2_XRENAV) .And. Len(Alltrim(Str(Val(SE2->E2_XRENAV)))) > 9, StrZero(Val(SE2->E2_XRENAV),12), Replicate("0",12))
	cRetorno += SubStr(Upper(AllTrim(SM0->M0_NOMECOM)),1,30)  //nome do contribuinte  
/*
*********************************************************************************************************************	  
	//Tratamento do ISS // Luane Totvs
	*********************************************************************************************************************
	
	
   ElseIf AllTrim(SEA->EA_MODELO) == "91"	// ISS
	cRetorno := "04"
	cRetorno += If (Empty(SE2->E2_CODRET),"0000",SubStr(SE2->E2_CODRET,1,4))
	cRetorno += "2"
	cRetorno += SubStr(SM0->M0_CGC,1,14)
	cRetorno += SubStr(SM0->M0_INSC,1,08)	
	cRetorno += Space(17)
	cRetorno += StrZero(SE2->E2_SALDO*100,9)
	cRetorno += StrZero(0,14)
	cRetorno += StrZero(0,14)
	cRetorno += StrZero(0,14)
	cRetorno += StrZero(SE2->E2_SALDO*100,9)
	cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
	cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
	cRetorno += "30" + SubStr(Dtos(SE2->E2_XCOMPET),5,2) + SubStr(Dtos(SE2->E2_XCOMPET),1,4)
	cRetorno += Space(10)
	cRetorno += SubStr(Upper(AllTrim(SM0->M0_NOMECOM)),1,30)     
	

/*
*********************************************************************************************************************
Nelson Motta da Silva - Zeus Consultoria - 04/10/12
Acrescentado a modalidade de pagamento de FGTS
*********************************************************************************************************************
*/	
ElseIf AllTrim(SEA->EA_MODELO) == "35"	// FGTS
    cStr := LTRIM(RTRIM(SE2->E2_CODBAR))
    cStr := IF (LEN(cStr) == 48,SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)+"    ",SubStr(SE2->E2_CODBAR,1,48)) 
    cRetorno := "11"
	cRetorno += If (Empty(SE2->E2_CODRET),"0515",SubStr(SE2->E2_CODRET,1,4))
	cRetorno += "1"
	If !Empty(SE2->E2_XCNPJJU) //para filais com cpnj baixado
		cRetorno += Alltrim(SE2->E2_XCNPJJU)
	Else
		cRetorno += SubStr(SM0->M0_CGC,1,14)
	EndIf 
    cRetorno += SubStr(cStr,1,48)
	cRetorno += Substr(cStr,28,16)
	cRetorno += StrZero(0,9)
	cRetorno += StrZero(0,2)
	cRetorno += SubStr(SM0->M0_NOMECOM,1,30)
	cRetorno += GravaData(SE2->E2_VENCREA, .F.,5)
	cRetorno += StrZero((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS)*100,14) //StrZero(SE2->E2_SALDO*100,14)
	cRetorno += Space(30)
	
EndIf

Return(cRetorno) 


/*
{Protheus.doc} RetCNPJUni
Função para retornar o cnpj do fornecedor dos títulos que compõe uma fatura com fornecedor "União" 
@Author     Ramon Teodoro e Silva
@Since      01/10/2020     
@Version    P12.27
@Return
*/
User Function RetCNPJUni

Local cRet  := ""
Local aArea := GetArea()

cQuery := "SELECT E2_TITPAI FROM " + RetSqlName("SE2") 
cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "'"
cQuery += " AND E2_FATURA = '" + SE2->E2_NUM + "' AND D_E_L_E_T_ = ''"  

cQuery := ChangeQuery(cQuery)
cAliasTmp := GetNextAlias() 
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)

cRet := Posicione("SA2",1,xFilial("SA2")+Substr((cAliasTmp)->E2_TITPAI ,17,6)+SubStr((cAliasTmp)->E2_TITPAI ,23,2),"A2_CGC")

RestArea(aArea)

Return cRet

/*/{Protheus.doc} RetOpPag
Função para retornar a opção de pagamento de IPVA
@author Ramon Teodoro
@since 16/07/2020
@version 1.0
@return Array

@type function
/*/

User Function RetOpPag

Local cRet   := ""
Local aArea  := GetArea()
Local cQuery := "" 
Local cTabTp := GetNextAlias()
Local nCnt   := 2

If !Empty(SE2->E2_PARCELA)

	cQuery := "SELECT E2_NUM, E2_PARCELA, E2_VENCREA FROM " + RetSqlName("SE2")
	cQuery += "WHERE E2_FILIAL = '" + xFilial("SE2") + "' AND "
	cQuery += "E2_PREFIXO = '" +  SE2->E2_PREFIXO + "' AND "
	cQuery += "E2_NUM = '" + SE2->E2_NUM + "' AND "
	cQuery += "E2_TIPO = '" + SE2->E2_TIPO + "' AND "
	cQuery += "E2_FORNECE = '" + SE2->E2_FORNECE + "' AND E2_LOJA = '" + SE2->E2_LOJA + "' AND "
	cQuery += "E2_DESDOBR = 'S' AND E2_BAIXA = ''"
	cQuery += "ORDER BY E2_PARCELA"

	cQuery := ChangeQuery(cQuery)

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cTabTp)

//	TcQuery cQuery Alias (cTabTp) New

	While !(cTabTp)->(Eof())
		nCnt += 1
		If (cTabTp)->E2_VENCREA == DtoS(SE2->E2_VENCREA)
			cRet := Str(nCnt)
		EndIf
		(cTabTp)->(DbSkip())
	End
	(cTabTp)->(DbCloseArea())

Else

	If SE2->E2_DECRESC .Or. SE2->E2_DESCONT > 0
		cRet := "1" //parcela única com desconto
	Else
		cRet := "2" //parcela única sem desconto
	EndIf

EndIf

RestArea(aArea)
Return Alltrim(cRet)
