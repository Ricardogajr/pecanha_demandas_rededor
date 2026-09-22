#include "rwmake.ch"       
#INCLUDE "PROTHEUS.CH"    

#Define CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} DORTICKET

description - Rotina desenvolvida para atender as necessidades de realização de Pedidos de Compras de VA - Vale Alimentação e VR - Vale Refeição da emrepsa Ticket

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description
/*/
User Function DORTICKET()
                                  
//Local oDlg
Local oRadio
Local nOpca := 1
Local cPerg	:= ''

// Declaracao de variaveis private

SetPrvt("lEnd,lContinua,lAbortPrint,lImpLis,nHdl,nLin0,nQtdFun,cCivi")
SetPrvt("cGva,cCodCon,cNomeCon,cNomeArq,cShowFil,cShowMat,cPerRef,cTipo,cEmp,cDtEntr,cDtEmis,cValRef,cMat")
SetPrvt("cDatN,cDatA,cNomeF,cPis,cCic,cLin,dPerRef,dDtEnt,nDafas,nValBen,nValBenT,nValRef,nSeq,lImpLis,aInfoE")
SetPrvt("aCamp,cGvr,cNumPed,cCcAnt,nPerDes,cValAnt,cCCAnt,oDlg")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeArq    := '' 
lEnd        := .F.
lContinua   := .T.
lAbortPrint := .F.
lImpLis     := .F.
nHdl        := 0 
nLin0       := 0
//cPerg		:= ''

Private nTpTicket := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela para selecionar qual beneficio quer gerar          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
While nOpca == 1 

	DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE OemToAnsi("Geração de Arquivo Texto Ticket") PIXEL
	
	@ 10,17 Say OemToAnsi("Qual benefício você deseja gerar ?") SIZE 150,7 OF oDlg PIXEL
	
	@ 27,07 TO 72, 140 OF oDlg  PIXEL
	
	@ 35,10 Radio 	oRadio VAR nTpTicket;
				ITEMS "Vale Alimentação",;	
					  "Vale Refeição";
				3D SIZE 100,10 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)

	If nOpca == 1
		If nTpTicket == 1			// vA
			cPerg := 'VATICKET'
		ElseIf nTpTicket == 2		// vR
			cPerg := 'VRTICKET'
		EndIf
		
		If !Pergunte(cPerg, .T. )
			Return
		EndIf 

		cNomeArq := mv_par10  

		cCodCon	:= ConVAVR()   	// Codigo Contrato

		If !Empty(cCodCon)
			If File(cNomeArq)
				If (nAviso := Aviso('AVISO','Deseja substituir o ' + AllTrim(cNomeArq) + ' existente ?', {'Sim','Nao','Cancela'})) == 1
					If fErase(cNomeArq) < 0
						MsgAlert('Ocorreram problemas na tentativa de deletar o arquivo '+AllTrim(cNomeArq)+'.')
						Exit
					EndIf		
				ElseIf nAviso == 2
						Pergunte(cPerg,.T.)							
					Loop
				Else
					Return
				EndIf		
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria o arquivo texto                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	     
			nHdl := fCreate(cNomeArq)

			If nHdl == -1
				MsgAlert('O arquivo '+AllTrim(cNomeArq)+' nao pode ser criado! Verifique os parametros.','Atencao!')
				EXIT
				Return
			Endif
				
			//Carrega Dados da Filial
			fLocalInfo()

			// Inicializa processamento
			Processa({|lEnd| RunCont()}, 'Processando...')
	
			If nHdl > 0 .and. nOpca # 0
				If fClose(nHdl)
					If nLin0 > 0 .And. lContinua
						Aviso('AVISO','Gerado o arquivo ' + AllTrim(cNomeArq) + '...',{'OK'})
						nOpca := 2
					Else
						If fErase(cNomeArq) == 0
							If lContinua
								Aviso('AVISO','Nao existem registros a serem gravados. A geraco do arquivo ' + AllTrim(cNomeArq) + ' foi abortada ...',{'OK'})
							EndIf	
						Else
						//	MsgAlert('Ocorreram problemas na tentativa de deletar o arquivo '+AllTrim(cNomeArq)+'.')
						EndIf	
					EndIf	
				Else
				//	MsgAlert('Ocorreram problemas no fechamento do arquivo '+AllTrim(cNomeArq)+'.')
				EndIf
			EndIf
		EndIf
	EndIf          
EndDo
	
Return


/*/{Protheus.doc} RunCont

description - Função utilizada para fazer o processamento dos dados e montagem do arquivo

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description
/*/
Static Function RunCont()

Local nTotVal  := 0
Local nTotReg  := 1
Local nContReg := 1

lNotFound	 := .F.
cQuery    	 := ''                 

//Verifica se houve alteração de cadastro na tabela S011
dbSelectArea("RCC")
dbSetOrder(RetOrder("RCC","RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"))
dbSeek(xFilial("RCC")+"S011")
While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC")+"S011"
	
	If nTpTicket == 1 
		cBenef := "89" 
		If Substr(RCC->RCC_CONTEU,1,2) == cBenef
			lNotFound:= .T.
		Endif
	Else 
		cBenef := "90"	 
		If Substr(RCC->RCC_CONTEU,1,2) == cBenef
			lNotFound:= .T.
		Endif
	Endif	
	
	("RCC")->(dbSkip())
End      

If !(lNotFound)
    If nTpTicket == 1 
		Alert("O cadastrdo do VA na tabela S011 foi alterado, favor ajusta para o codigo 89 ! ")
	Else
		Alert("O cadastrdo do VR na tabela S011 foi alterado, favor ajusta para o codigo 90 ! ")
	Endif	
	Return
Endif	

// Busca os registros na SR0
MsAguarde( {|| fMtaQuery()}, "Processando...", "Selecao de Registros" )

dbSelectArea( "RDOR001" )
dbGoTop()
Do While !Eof()
	dbSkip()
	If !Eof()
		nTotReg ++
	EndIf
EndDo

dbSelectArea( "RDOR001" )
dbGoTop()

ProcRegua( nTotReg )      

nSeq := 0

While !RDOR001->(Eof()) .And. lContinua 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	IncProc( "Processando: "+StrZero(nContReg,6)+" de "+StrZero(nTotReg,6))
	
	nContReg++ 
	
	If lAbortPrint .Or. lEnd
		If Aviso('ATENCAO','Deseja abandonar a Geracao do arquivo ' + AllTrim(AllTrim(cNomeArq)) + ' ?',{'Sim','Nao'}) == 1
			lContinua := .F.
			Exit
		EndIf	
	Endif

	//incializa linha
	If nLin0 == 0
		nLin0 += 1
	Endif
	
	
	If nSeq == 0
		// REGISTRO HEADER DO ARQUIVO TRE (VR) / TAE (VA)
		HeadArq()
		nSeq += 1
		// REGISTRO HEADER DO PEDIDO TRE (VR) / TAE (VA)
		HeadPed()
		nSeq += 1
		// REGISTRO DE UNIDADES DE ENTREGA TRE (VR) / TAE (VA)
		UnidEnt()
		nSeq += 1
	Endif
	
	RegFunc()

	nSeq += 1

	nTotVal += RDOR001->R0_VALCAL

	RDOR001->(dbSkip())
  	
EndDo          

TrlPed(nTotReg, nTotVal)

TrlArq(nTotReg)

Return



/*/{Protheus.doc} fGravaReg

description - Função utilizada para agravação do Log de erros na geração das linhas do arquvio.

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description
/*/
Static Function fGravaReg()

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	If !MsgYesNo('Ocorreu um erro na gravacao do arquivo '+AllTrim(cNomeArq)+'.   Continua?','Atencao!')
		lContinua := .F.
		Return
	Endif
Endif

Return



/*/{Protheus.doc} fLocalInfo

description - Função utilizada para buscar os dados da empresa que serão utilizados no Header do arquivo.

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description
/*/
Static Function fLocalInfo()
                                     
aInfoE := {}

nSM0Recno := SM0->(Recno())

SM0->(dbSeek(cEmpAnt + mv_par01,.T.))

Aadd(aInfoE,SM0->M0_NOME)
Aadd(aInfoE,SM0->M0_NOMECOM)
Aadd(aInfoE,SM0->M0_ENDENT)
Aadd(aInfoE,SM0->M0_CIDENT)
Aadd(aInfoE,SM0->M0_ESTENT)
Aadd(aInfoE,SM0->M0_CEPENT)
Aadd(aInfoE,SM0->M0_BAIRENT)
Aadd(aInfoE,SM0->M0_COMPENT)
Aadd(aInfoE,SM0->M0_CGC)
Aadd(aInfoE,SM0->M0_FILIAL)

SM0->(dbGoto(nSM0Recno))

Return



/*/{Protheus.doc} fMtaQuery

description - Função utilizada para montagem da query que deverá trazer todos os funcionários com direitos ao beneficio VR/VA.

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description
/*/
Static Function fMtaQuery()

Local cQuery    := ""

//Verifica Tabela Aberta
If Select("RDOR001") > 0
	DbSelectArea("RDOR001")
	DbCloseArea("RDOR001")
Endif

cQuery := "SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_NOME, RA_CC, RA_SITFOLH, RA_NASC, RA_ADMISSA, "
cQuery += "RA_PIS, RA_ESTCIVI, RA_SEXO, RA_RG, RA_RGORG, RA_RGUF, RA_ENDEREC, RA_COMPLEM, "
cQuery += "RA_NUMENDE, RA_CEP, RA_MUNICIP, RA_BAIRRO, RA_ESTADO, RA_MAE, RA_DDDFONE, RA_TELEFON, "
cQuery += "R0_CODIGO, R0_DIASPRO, R0_QDIAINF, R0_QDIACAL, R0_VALCAL, R0_VLRVALE, R0_VLRFUNC, R0_VLREMP "
cQuery += "FROM "+ RetSqlName("SRA") + " SRA "
cQuery += "INNER JOIN "+ RetSqlName("SR0") + " SR0 ON R0_FILIAL = RA_FILIAL AND R0_MAT = RA_MAT "

cQuery += "WHERE "
cQuery += "RA_FILIAL = '"  + mv_par01 + "' AND " 
cQuery += "RA_CC     >= '"  + mv_par02  + "'  AND RA_CC     <= '" + mv_par03  + "' AND "
cQuery += "RA_MAT    >= '"  + mv_par04 + "'  AND RA_MAT    <= '" + mv_par05 + "' AND "

If nTpTicket == 1
	cQuery += "R0_TPVALE   = '2'     AND "
Else
	cQuery += "R0_TPVALE   = '1'     AND "
Endif	

cQuery += "R0_VALCAL   > 0     AND "
cQuery += "R0_DIASPRO  <> '99' AND "
cQuery += "RA_DEMISSA  = ' '   AND "
cQuery += "SRA.D_E_L_E_T_ <> '*' AND "
cQuery += "SR0.D_E_L_E_T_ <> '*' "

cQuery += "ORDER BY RA_CC, RA_MAT " 

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"RDOR001")

Return 


/*/{Protheus.doc} ConVAVR

description - Função responsável por buscar o numero do contrato do beneficio VR/VA.

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description - Retorna o numero do contrato caso ele estaja cdastrado no sistema.
/*/
Static Function ConVAVR()

Local aArea     := GetArea()
Local aContrato := {}
Local nPosCtr   := 0
Local nIndice   := 0
Local cTipo     := ''
Local cRet      := ''

fCarrTab( @aContrato,"U108", Nil )
 
If (nPosCtr	:=	Ascan(aContrato,{|x| x[1] == "U108" .And. alltrim(x[2]) == alltrim(mv_par01) }) ) > 0   
	If nTpTicket == 1
		nIndice := 5
		cTipo   := 'VA'
	Else
		nIndice := 6
		cTipo   := 'VR'
	Endif
	If Empty(aContrato[nPosCtr,nIndice]) 
		Alert("Nao existe codigo de contrato para "+cTipo+" da filial - "+alltrim(mv_par01)+" - na tabela especifica U108, favor verificar")
	Else
		cRet := aContrato[nPosCtr,nIndice]
	Endif
Else
   	Alert("Nao existe registros na tabela na tabela especifica U108, favor verificar")
Endif	

RestArea(aArea)       
Return(cRet)


/*/{Protheus.doc} TpLogra

description - Função responsável por retornar o tipo do logradouro conforme exigencia do manual do fornecedor.

@type function
@version  
@author adriano.sato
@since 26/11/2021
@param cTpLog, character, param_description
@return variant, return_description - Retorna o tipo do logradouro
/*/
Static Function TpLogra(cTpLog as Character)

Local aTipoLog 	as Array
Local nPosLog 	as Numeric
Local cRet 		as Character

aTipoLog := {}
nPosLog  := 0
cRet	 := ""

aadd(aTipoLog,{"ACESSO","AC"})
aadd(aTipoLog,{"CORREDOR","COR"})
aadd(aTipoLog,{"LARGO","LG"})
aadd(aTipoLog,{"RETIRO","RER"})
aadd(aTipoLog,{"ADRO","AD"})
aadd(aTipoLog,{"CORREGO","CRG"})
aadd(aTipoLog,{"LOTEAMENTO","LOT"})
aadd(aTipoLog,{"RETORNO","RTN"})
aadd(aTipoLog,{"ALAMEDA","AL"})
aadd(aTipoLog,{"DESCIDA","DSC"})
aadd(aTipoLog,{"MARINA","MNA"})
aadd(aTipoLog,{"RODOVIA","ROD"})
aadd(aTipoLog,{"ALTO","AT"})
aadd(aTipoLog,{"DESVIO","DSV"})
aadd(aTipoLog,{"MONTE","MTE"})
aadd(aTipoLog,{"ROTULA","ROT"})
aadd(aTipoLog,{"AREA","A"})
aadd(aTipoLog,{"DISTRITO","DT"})
aadd(aTipoLog,{"MORRO","MRO"})
aadd(aTipoLog,{"RUA","R"})
aadd(aTipoLog,{"ARTERIA","ART"})
aadd(aTipoLog,{"ELEVADO","EVD"})
aadd(aTipoLog,{"PARADA","PDA"})
aadd(aTipoLog,{"SERVIDAO","SRV"})
aadd(aTipoLog,{"ATALHO","ATL"})
aadd(aTipoLog,{"ESCADA","ESC"})
aadd(aTipoLog,{"PARADOURO","PDO"})
aadd(aTipoLog,{"SETOR","ST"})
aadd(aTipoLog,{"AVENIDA","AV"})
aadd(aTipoLog,{"ESPLANADA","ESP"})
aadd(aTipoLog,{"PARALELA","PAR"})
aadd(aTipoLog,{"SITIO","SIT"})
aadd(aTipoLog,{"BAIXA","BX"})
aadd(aTipoLog,{"ESTACAO","ETA"})
aadd(aTipoLog,{"PARQUE","PRQ"})
aadd(aTipoLog,{"SUBIDA","SUB"})
aadd(aTipoLog,{"BALAO","BLO"})
aadd(aTipoLog,{"ESTADIO","ETD"})
aadd(aTipoLog,{"PASSAGEM","PSG"})
aadd(aTipoLog,{"TERMINAL","TER"})
aadd(aTipoLog,{"BALNEARIO","BAL"})
aadd(aTipoLog,{"ESTRADA","EST"})
aadd(aTipoLog,{"PASSARELA","PSA"})
aadd(aTipoLog,{"TRAVESSA","TV"})
aadd(aTipoLog,{"BECO","BC"})
aadd(aTipoLog,{"FAVELA","FAV"})
aadd(aTipoLog,{"PASSEIO","PAS"})
aadd(aTipoLog,{"TRECHO","TR"})
aadd(aTipoLog,{"BELVEDERE","BELV"})
aadd(aTipoLog,{"FAZENDA","FAZ"})
aadd(aTipoLog,{"PATIO","PAT"})
aadd(aTipoLog,{"TREVO","TRV"})
aadd(aTipoLog,{"BLOCO","BL"})
aadd(aTipoLog,{"FEIRA","FRA"})
aadd(aTipoLog,{"PONTE","PTE"})
aadd(aTipoLog,{"TRINCHEIRA","TCH"})
aadd(aTipoLog,{"BOSQUE","BSQ"})
aadd(aTipoLog,{"FERROVIA","FER"})
aadd(aTipoLog,{"PORTO","PTO"})
aadd(aTipoLog,{"UNIDADE","UNID"})
aadd(aTipoLog,{"BOULEVARD","BVD"})
aadd(aTipoLog,{"FONTE","FNT"})
aadd(aTipoLog,{"PRACA","PC"})
aadd(aTipoLog,{"VALE","VLE"})
aadd(aTipoLog,{"CAIS","C"})
aadd(aTipoLog,{"FORTE","FTE"})
aadd(aTipoLog,{"PRAIA","PR"})
aadd(aTipoLog,{"VEREDA","VER"})
aadd(aTipoLog,{"CAMINHO","CAM"})
aadd(aTipoLog,{"GALERIA","GAL"})
aadd(aTipoLog,{"PROLONGAMENTO","PRL"})
aadd(aTipoLog,{"VIA","V"})
aadd(aTipoLog,{"CAMPO","CPO"})
aadd(aTipoLog,{"GRANJA","GJA"})
aadd(aTipoLog,{"QUADRA","Q"})
aadd(aTipoLog,{"VIADUTO","VD"})
aadd(aTipoLog,{"CHAPADAO","CHAP"})
aadd(aTipoLog,{"ILHA","IA"})
aadd(aTipoLog,{"QUINTA","QTA"})
aadd(aTipoLog,{"VIELA","VLA"})
aadd(aTipoLog,{"CIRCULAR","CIRC"})
aadd(aTipoLog,{"JARDIM","JD"})
aadd(aTipoLog,{"QUINTAS","QTAS"})
aadd(aTipoLog,{"VILA","VL"})
aadd(aTipoLog,{"COLONIA","COL"})
aadd(aTipoLog,{"JARDINETE","JDE"})
aadd(aTipoLog,{"RAMAL","RAM"})
aadd(aTipoLog,{"ZIGUE-ZAGUE","ZIG"})
aadd(aTipoLog,{"CONDOMINIO","COND"})
aadd(aTipoLog,{"LADEIRA","LD"})
aadd(aTipoLog,{"RECANTO","REC"})
aadd(aTipoLog,{"CONJUNTO","CJ"})
aadd(aTipoLog,{"LAGOA","LGA"})
aadd(aTipoLog,{"RETA","RET"})

nPosLog := aScan(aTipoLog,{|x| x[1] == cTpLog})
If nPosLog > 0
	cRet := aTipoLog[nPosLog][2]
Else
	cRet := cTpLog
EndIf

Return(PadR( cRet,4 ))



/*/{Protheus.doc} HeadArq

description - Função responsável pela criação do Header do arquivo.

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description
/*/
Static Function HeadArq()

Local cTipo 	as Character
Local cUsuario 	as Character
Local cResev01	as Character
Local cDataGer	as Character
Local cHoraGer	as Character
Local cResev02	as Character
Local cResev03	as Character

cTipo 		:= 'LSUP5'
// UsrFullName – Retorna o nome do completo do usuario
// Sinxtaxe: UsrFullName(cUserID)
// UsrRetName – Retorna o nome do usuario
// Sintaxe: UsrRetName(cUserID)
// RetCodUsr – Retorna o codigo do Usuario Corrente
// Sintaxe: RetCodUsr()
cUsuario 	:= substr(UsrFullName(RetCodUsr()),1,8)
cResev01	:= SPACE(11)
cDataGer	:= strzero(year(date()),4)+strzero(month(date()),2)+strzero(day(date()),2)
cHoraGer	:= strtran(TIME(),":",".")
cResev02	:= "LAYOUT-16/06/2014"
cResev03	:= SPACE(107)

cLin := cTipo + cUsuario + cResev01  + cDataGer + cHoraGer + cResev02 + cResev03 + CRLF 

fGravaReg()

Return


/*/{Protheus.doc} HeadPed

description - Função responsável pelo Header do Pedido.

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description
/*/
Static Function HeadPed()

Local cTpoProd 	as Character
Local cProduto 	as Character
Local cFixo		as Character
Local cTipoReg	as Character
Local cCodClie	as Character
Local cNomeEmp	as Character
Local cResev04	as Character
Local cDataPed	as Character
Local cDataLib	as Character
Local cResev05	as Character
Local cMesRef	as Character
Local cResev06	as Character
Local cLayout	as Character
Local cTpCarta	as Character
Local cResev07	as Character
Local cOrigem	as Character
Local cSeq 		as Character

cTpoProd 	:= 'T'
cProduto 	:= IIf(nTpTicket == 1, 'A', 'R') 		// A = Alimentação R = Restaurante
cFixo		:= '02'
cTipoReg	:= '0'
cCodClie	:= Left( cCodCon, 10 )
cNomeEmp	:= substr(aInfoe[2],1,24)
cResev04	:= SPACE(6)
cDataPed	:= strzero(year(date()),4)+strzero(month(date()),2)+strzero(day(date()),2)
cDataLib	:= strzero(year(date()),4)+strzero(month(date()),2)+strzero(day(date()),2)
cResev05	:= SPACE(17)
cMesRef		:= '09'
cResev06	:= SPACE(19)
cLayout		:= '04'
cTpCarta	:= IIf(nTpTicket == 1, '33', '34') 		// 33 para TAE - 34 para TRE
cResev07	:= SPACE(48)
cOrigem		:= 'SUP   '
cSeq 		:= StrZero(nSeq,6)

cLin := cTpoProd + cProduto + cFixo + cTipoReg + cProduto + cCodClie + cNomeEmp + cResev04 + cDataPed
cLin += cDataLib + cResev05 + cMesRef + cResev06 + cLayout + cTpCarta + cResev07 + cOrigem + cSeq + CRLF 

fGravaReg()

Return


/*/{Protheus.doc} UnidEnt

description - Função responsável pelas informações da unidade.

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description
/*/
Static Function UnidEnt()

Local aDadosEmp as Array

Local cTpoProd 	as Character
Local cProduto 	as Character
Local cFixo		as Character
Local cTipoReg	as Character
Local cNomeUni  as Character
Local cTipLogr  as Character
Local cLogrado  as Character
Local cNumero   as Character
Local cComplem  as Character
Local cMunicip  as Character
Local cBairro   as Character
Local cCep      as Character
Local cEstado   as Character
Local cInterlo  as Character
Local cCompCep	as Character
Local cResev08	as Character
Local cSeq 		as Character

aDadosEmp 	:= GetAdvFVal("RGC", { "RGC_FILIAL", "RGC_DESLOC", "RGC_CPFCGC", "RGC_NMRESP", "RGC_ENDER", "RGC_NUMERO", "RGC_COMPLE", "RGC_BAIRRO", "RGC_MUNIC", "RGC_ESTADO", "RGC_CODPOS" }, mv_par01, 1, { "", "", "", "", "", "", "", "", "", "", "" })

cTpoProd 	:= 'T'
cProduto 	:= IIf(nTpTicket == 1, 'A', 'R') 		// A = Alimentação R = Restaurante
cFixo		:= '02'
cTipoReg	:= '2'
cNomeUni  	:= substr(aInfoe[2],1,26)
cTipLogr 	:= TpLogra( ALLTRIM(PadR( Left( aInfoe[3], AT( ' ', aInfoe[3] ) ), 4 ) ) )
cLogrado  	:= substr(aInfoe[3],AT( ' ', aInfoe[3])+1,30)
cNumero   	:= PadR( aDadosEmp[6],6 )
cComplem  	:= substr(aInfoe[8],1,10)
cMunicip  	:= substr(aInfoe[4],1,25)
cBairro   	:= substr(aInfoe[7],1,15)
cCep      	:= Left( aInfoe[6], 5) 
cEstado   	:= aInfoe[5]
cInterlo  	:= Left( aDadosEmp[4], 20 )
cCompCep	:= Right( aInfoe[6], 3) 
cResev08	:= SPACE(7)
cSeq 		:= StrZero(nSeq,6)

cLin := cTpoProd + cProduto + cFixo + cTipoReg + cNomeUni + cTipLogr + cLogrado + cNumero + cComplem
cLin += cMunicip + cBairro + cCep + cEstado + cInterlo + cCompCep + cResev08 + cSeq + CRLF 

fGravaReg()

Return


/*/{Protheus.doc} RegFunc

description - Função responsável pelas informações dos funcionários

@type function
@version  
@author adriano.sato
@since 26/11/2021
@return variant, return_description
/*/
Static Function RegFunc()

Local cTpoProd 	:= 'T'
Local cProduto 	:= IIf(nTpTicket == 1, 'A', 'R') 		// A = Alimentação R = Restaurante
Local cFixo		:= '02'
Local cTipoReg	:= '3'
Local cDepto    := strzero( val(RDOR001->RA_CC), 26 )
Local cID       := strzero( val(RDOR001->RA_MAT), 12 )
Local cDatNasc  := AllTrim(strzero(val(substr(RDOR001->RA_NASC,7,2)),2)) + AllTrim(strzero(val(substr(RDOR001->RA_NASC,5,2)),2)) + AllTrim(strzero(val(substr(RDOR001->RA_NASC,1,4)),4))
Local cResev09	:= SPACE(18)
Local cNomeUni  := substr(aInfoe[10],1,26)
Local cFixo2    := '00101'
Local cValor    := StrZero(RDOR001->R0_VALCAL * 100, 9)
Local cFixo3    := '3'
Local cNomeFun  := RDOR001->RA_NOME
Local cResev10	:= SPACE(06)
Local cCpf      := Iif(Empty(RDOR001->RA_CIC),Replic("0",11),strzero(val(RDOR001->RA_CIC),11))
Local cSeq 		:= StrZero(nSeq,6)

cLin := cTpoProd + cProduto + cFixo + cTipoReg + cDepto + cID + cDatNasc + cResev09 + cNomeUni
cLin += cFixo2 + cValor + cProduto + cFixo3 + cNomeFun + cResev10 + cCpf + cSeq + CRLF 

fGravaReg()

Return


/*/{Protheus.doc} TrlPed

description - Função responsável pelo Trailer do Pedido

@type function
@version  
@author adriano.sato
@since 26/11/2021
@param nTotReg, numeric, param_description - Total de registro do arquivo
@param nTotVal, numeric, param_description - Valor total do beneficio 
@return variant, return_description
/*/
Static Function TrlPed(nTotReg as Numeric, nTotVal as Numeric)

/* 
		Campo 					Início 	Fim Tama 	Tipo 	Conteúdo
Tipo de Produto / Seqüência 	001 	001 001 	X 		Fixo “T”
Produto 						002 	002 001 	X 		A = Alimentação / R = Restaurante
Fixo 							003 	004 002 	X 		Fixo “02”
Tipo de Registro 				005 	005 001 	X 		“9”
Total de Funcionários 			006 	013 008 	9 		Quantidade de registros tipo 3 (Funcionários)
Valor Total 					014 	027 014 	9 		Somatória do valor do pedido, com 2 casas decimais
Reservado 						028 	158 131 	X 		Preencher com espaços
Seqüência 						159 	164 006 	9 		Número seqüencial para cada linha do arquivo. 
															Formato “999999”, dar continuidade ao registro anterior
*/

Local cTpoProd 	:= 'T'
Local cProduto 	:= IIf(nTpTicket == 1, 'A', 'R') 		// A = Alimentação R = Restaurante
Local cFixo		:= '02'
Local cTipoReg	:= '9'
Local cTotFunc	:= StrZero(nTotReg,8)
Local cValorTot	:= StrZero(nTotVal * 100, 14)
Local cResev01	:= SPACE(131)
Local cSeq 		:= StrZero(nSeq,6)

cLin := cTpoProd + cProduto + cFixo + cTipoReg + cTotFunc + cValorTot + cResev01 + cSeq + CRLF 

fGravaReg()

Return


/*/{Protheus.doc} TrlArq

description - Função responsável pelo Trailer do Arquivo.

@type function
@version  
@author adriano.sato
@since 26/11/2021
@param nTotReg, numeric, param_description - Total de registro do arquivo
@return variant, return_description
/*/
Static Function TrlArq(nTotReg as Numeric)

/* 
		Campo 					Início 	Fim Tama 	Tipo 	Conteúdo
Tipo de registro 				001 	005 005 	X 		"LSUP9"
Quantidade de Header 			006 	013 008 	9 		Somatório total dos registros Header’s do arquivo de 
															pedidos, formato “99999999”
Quantidade de Trailler 			014 	021 008 	9 		Somatório total dos registros Trailler’s do arquivo de pedidos.
															ormato “99999999”
Quantidade de registros dentro 
do arquivo						022 	029 008 	9 		Somatório total dos registros do arquivo de pedidos, formato 
															“99999999”, exceto header’s e trailler’s
Espaço Reservado 				030 	306 277 	X 		brancos
*/

Local cTpoReg 	:= 'LSUP9'
Local cQtdHead 	:= StrZero(nTotReg,8)
Local cQtdTrl	:= StrZero(nTotReg,8)
Local cQtdReg	:= StrZero(nTotReg+1,8)
Local cResev04	:= SPACE(108)


cLin := cTpoReg + cQtdHead + cQtdTrl + cQtdReg + cResev04 + CRLF 

fGravaReg()

Return

