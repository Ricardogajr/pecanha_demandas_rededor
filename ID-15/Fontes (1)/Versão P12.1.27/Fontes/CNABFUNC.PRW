#Include "Rwmake.ch" 
#Include "Protheus.ch"  

/*
{Protheus.doc} CNABFUNC
Funções auxiliares para geração de CNAB 
@Author     Ramon Teodoro e Silva
@Since      17/12/2020     
*/

/*
{Protheus.doc} RetCNPJGPS
Retorna o CNPJ para o bloco N-GPS 
@Author     Ramon Teodoro e Silva
@Since      17/12/2020     
@Version    P12.27
@Return
*/
User Function RetCNPJGPS()

Local cRet := ""

If Alltrim(SE2->E2_PREFIXO) == "AGI" 
    cRet += If (SE2->E2_RETINS $ "2631|    ", If(EMPTY(SE2->E2_TITPAI),SubStr(SE2->E2_CNPJRET,1,14),POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(SE2->E2_TITPAI,17,6)+SUBSTR(SE2->E2_TITPAI,23,2),"A2_CGC")),SubStr(SM0->M0_CGC,1,14))	//Tratar pelo campo E2_TITPAI para as GPS de Fornecedores //
Else
    If Alltrim(SE2->E2_TIPO) == "FT" .And. Empty(SE2->E2_TITPAI) .And. Empty(SA2->A2_CGC)
		cRet += If (SE2->E2_RETINS $ "2631|    ", U_RetCNPJUni(),SubStr(SM0->M0_CGC,1,14))	//Tratar pelo campo E2_TITPAI para as GPS de Fornecedores // 
	ElseIf !Empty(SE2->E2_XCNPJJU) 
		cRet += Alltrim(SE2->E2_XCNPJJU)
	Else
		cRet += If (SE2->E2_RETINS $ "2631|    ", If(EMPTY(SE2->E2_TITPAI),SubStr(SA2->A2_CGC,1,14),POSICIONE("SA2",1,XFILIAL("SA2")+SUBSTR(SE2->E2_TITPAI,17,6)+SUBSTR(SE2->E2_TITPAI,23,2),"A2_CGC")),SubStr(SM0->M0_CGC,1,14))	//Tratar pelo campo E2_TITPAI para as GPS de Fornecedores //
	EndIf	
EndIf

Return cRet

/*
{Protheus.doc} CNPJDarf
Retorna o CNPJ para o bloco N-DARF 
@Author     Ramon Teodoro e Silva
@Since      17/12/2020     
@Version    P12.27
@Return
*/
User Function CNPJDarf()

Local cRet  := ""
Local cCNPJ := IIF(!(Empty(GetMV("MV_XCNPJMA"))),GetMV("MV_XCNPJMA"),SubStr(SM0->M0_CGC,1,14))

If !Empty(SE2->E2_XCNPJJU)
	cRet += Alltrim(SE2->E2_XCNPJJU)
Else
	cRet += Substr(cCNPJ,1,14)
EndIf

Return cRet

/*
{Protheus.doc} AlertDVAGE
Alerta para o campo DV Agencia no cadastro de banco
@Author     Ramon Teodoro e Silva
@Since      03/02/2021     
@Version    P12.27
@Return
*/
User Function AlertDVAGE()  

Local aArea := GetArea()
Local lRet  := .T.

MsgAlert( "Caso a agência tenha dígito verificador, é necessario informá-lo separadamente no campo 'DV Agen CNAB'." , "Atenção!")

RestArea(aArea)

Return lRet

/*
{Protheus.doc} CnabTrib
Bloco de código de detalhamento de tributos do segmento N, comum aos bancos BB, Santander, Bradesco e Caixa 
@Author     Ramon Teodoro e Silva
@Since      23/07/2020     
@Version    P12.27
@Return
*/
User Function CnabTrib()

Local cRetorno  := ""

If AllTrim(SEA->EA_MODELO) == "22"	// GARE  
	
	cRetorno := If (Empty(SE2->E2_CODRET),"0000",SubStr(SE2->E2_CODRET,1,4)) + Space(02)
	cRetorno += "01"
	cRetorno += IIF(Empty(SE2->E2_XCNPJJU), Alltrim(SE2->E2_XCNPJJU), SubStr(SM0->M0_CGC,1,14))
	cRetorno += "22"
	cRetorno += GravaData(SE2->E2_VENCREA,.F.,5)
	cRetorno += IIF(!Empty(Alltrim(SE2->E2_XIESTAD)), SE2->E2_XIESTAD, SubStr(SM0->M0_INSC,1,12))	
	cRetorno += StrZero(0,13)
	cRetorno += SubStr(Dtos(SE2->E2_XCOMPET),5,2) + SubStr(Dtos(SE2->E2_XCOMPET),1,4)
	cRetorno += StrZero(0,13)
	cRetorno += StrZero((SE2->E2_SALDO*100),15)
	cRetorno += StrZero(Int(SE2->E2_JUROS * 100),14)
	cRetorno += StrZero(Int(SE2->E2_MULTA * 100),14)
	cRetorno += Space(1)

ElseIf AllTrim(SEA->EA_MODELO) $ "25|26|27" //IPVA, licenciamento, DPVAT 

	cRetorno := If (Empty(SE2->E2_CODRET),"0000",SubStr(SE2->E2_CODRET,1,4)) + Space(02)
	cRetorno += "02" 
	cRetorno += SUBSTR(SM0->M0_CGC,1,14)
	cRetorno += Alltrim(SEA->EA_MODELO)
	cRetorno += SubStr(Dtos(SE2->E2_XCOMPET),1,4)       // Ano base
	cRetorno += IIF(!Empty(SE2->E2_XRENAV) .And. Len(Alltrim(Str(Val(SE2->E2_XRENAV)))) == 9, StrZero(Val(SE2->E2_XRENAV),9), Replicate("0",9))
	//cRetorno += IIF(!Empty(SE2->E2_XRENAV) .And. Len(Alltrim(SE2->E2_XRENAV)) == 9, SE2->E2_XRENAV, Replicate("0",9))
	cRetorno += SE2->E2_XUFVEIC           // UF
	cRetorno += SE2->E2_XMUNICV //Space(5)                                        // Cod. município
	cRetorno += SE2->E2_XPLACA                                      // Placa do veículo
	cRetorno += IIF(SEA->EA_MODELO == "25", U_RetOpPag(), "0")                                     // Opção de pagamento
	If AllTrim(SEA->EA_MODELO) == "26"
		cRetorno += SE2->E2_XRTCRLV
	EndIf
	cRetorno += IIF(!Empty(SE2->E2_XRENAV) .And. Len(Alltrim(Str(Val(SE2->E2_XRENAV)))) > 9, StrZero(Val(SE2->E2_XRENAV),12), Replicate("0",12))               // Cod. Renavam 12 digitos 
	cRetorno += IIF(AllTrim(SEA->EA_MODELO) == "26", Space(54), Space(55))

EndIf


Return cRetorno
