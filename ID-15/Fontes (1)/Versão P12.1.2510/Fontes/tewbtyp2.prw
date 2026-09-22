#Include 'Protheus.ch'
#Include 'TopConn.Ch'
#include "fwmvcdef.ch"

/*
{Protheus.doc} TEWBTYP2
Geração de arquivo sispag automático. 
@Author     Ramon Teodoro e Silva
@Since      06/10/2017     
@Version    P12.7
@Return
*/
User Function TEWBTYP2

Local oBrowse //incluido por thiago goes
Local lRet     := .T.
Local aArea    := GetArea()
Local cTitulo := "Sispag Automatico"
Local aSeek			:= {}

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

//Private cString := "PZC" não usadao
Private cAlias 	  := "PZC"
Private cAliasCMP := "PZC"
Private aRotina   := MenuDef()
 
AAdd(aSeek, {"Arquivo"   	, {{"", "C", TamSX3("PZC_ARQUIV")[1] , 0, "Arquivo"   , , }}, 1, .T.})	
//AAdd(aSeek, {"Nome"			, {{"", "C", TamSX3("RA_NOME")[1], 0, "Nome"		, , }}, 2, .T.})


DbSelectArea("PZC")
DbSetOrder(1) 
//Início - Thais Paiva - Compatibilização P27

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1))
(cAlias)->(dbGotop())

oBrowse:= FWmBrowse():New()
oBrowse:SetAlias( 'PZC' )
oBrowse:SetDescription( cTitulo )
oBrowse:SetMenuDef("TEWBTYP2")
oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse

//0=Nao Informado (NF RESUMIDA);1=Uso autorizado;2=Uso denegado;3=NF-e Cancelada; '' Desconhecido
//PZC_FILIAL, PZC_ARQUIV ,PZC_PORTAD, PZC_AGEPOR, PZC_CONPOR, PZC_AGEPOR, PZC_DTARQ
//oBrowse:AddLegend( "PZG->PZG_STSSFZ == '0' ", "GRAY"  , "Nao Informado" )
//oBrowse:AddLegend( "PZG->PZG_STSSFZ == '1' ", "GREEN" , "Uso Autorizado")
//oBrowse:AddLegend( "PZG->PZG_STSSFZ == '2' ", "YELLOW", "Uso Denegado"  )
//oBrowse:AddLegend( "PZG->PZG_STSSFZ == '3' ", "RED"   , "Doc. Cancelado")
//oBrowse:AddLegend( "Empty(PZG->PZG_STSSFZ) ", "XCLOSE", "Desconhecido")

oBrowse:SetOnlyFields( {   'PZC_FILIAL', ;
									'PZC_ARQUIV', ;
									'PZC_PORTAD', ;
									'PZC_AGEPOR', ;
									'PZC_CONPOR', ;
									'PZC_DTARQ' } )
								
oBrowse:Activate()

RestArea(aArea)
Return lRet

/*
{Protheus.doc} SisAut
Geração de arquivo sispag automático. 
@Author     Ramon Teodoro e Silva
@Since      06/10/2017     
@Version    P12.7
@Return
*/
User Function SisAut(aBorderos,aFil)

Local lPanelFin := IsPanelFin()
Local aSays		:= {}
Local aButtons	:= {}
Local nOpca 	:= 0
Local cOldFil	:= cFilAnt
Local aSelFil   := {}
Local lRet      := .T.
Local _aCmpPZC	:= {} //Thais Paiva - Compatibilização P27
Local _nZc      := 0

Local aStruPZC := {}
Local aBrowse  := {}
                       
cFilAnt := Fa300FilLog()

If cFilAnt <> cOldFil
	SM0->(DbSeek(cEmpAnt+cFilAnt))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro    										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin(,,"1")
	Return
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenho da tela WINDOWS         			 						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("TEWBTYP2",.F.)
nOpca := 0
AADD (aSays, "Esta opção gera o Arquivo de Comunicação Bancária SisPag")		      // "   Esta op‡„o gera o Arquivo de  Comunica‡„o Banc ria  SisPag" 
AADD (aSays, "para o  Borderô de Pagamentos. Dever  ser  informado o  Nº do")		  // "para o  Border“ de Pagamentos. Dever  ser  informado o  N§ do" 
AADD (aSays, "Borderô que se quer enviar, o Nome do Arquivo de Configuração")		  // "Border“ que se quer enviar, o Nome do Arquivo de Configura‡„o" 
AADD (aSays, "(CNAB SisPag) e o Nome do Arquivo a ser Gerado." )	          	      // "(CNAB SisPag) e o Nome do Arquivo a ser Gerado." 

If lPanelFin  //Chamado pelo Painel Financeiro			
	aButtonTxt := {}				
	AADD(aButtonTxt,{"Sispag Aut.","Sispag Aut.2", {||Pergunte("TEWBTYP2",.T. )}}) // Parametros						
	FaMyFormBatch(aSays,aButtonTxt,{||nOpca:= 1},{||nOpca:= 0})	
Else
	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|| Pergunte("TEWBTYP2",.T. ) } } )
	FormBatch( "Sispag Aut.", aSays, aButtons )
Endif	

If nOpca == 1

	If mv_par04 == 1  
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return 
		EndIf	
	Else
		aSelFil := { cFilAnt }	 
	EndIf
		
	MsgRun("Verificando borderôs.","",{|| CursorWait(),U_GeraArqS(aSelFil, mv_par01, mv_par02, mv_par03, mv_par04),"Geração automática de Sispag",CursorArrow()}) 

Else
	
	//Início - Thais Paiva - Compatibilização P27
	_aCmpPZC := FWSX3Util():GetAllFields( "PZC" , .F. )
	If Len(_aCmpPZC) > 0
		For _nZc := 1 to Len(_aCmpPZC)
			If GetSx3Cache(_aCmpPZC[_nZc], 'X3_BROWSE') == "S" 
				//aadd(aStruPZC,{ SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL })
				//aadd(aBrowse,{X3TITULO(),SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE})
				aadd(aStruPZC,{ GetSx3Cache(_aCmpPZC[_nZc], 'X3_CAMPO'), GetSx3Cache(_aCmpPZC[_nZc], 'X3_TIPO'), ;
								GetSx3Cache(_aCmpPZC[_nZc], 'X3_TAMANHO'), GetSx3Cache(_aCmpPZC[_nZc], 'X3_DECIMAL') })

				aadd(aBrowse,{GetSx3Cache(_aCmpPZC[_nZc], 'X3_TITULO'), GetSx3Cache(_aCmpPZC[_nZc], 'X3_CAMPO'), ;
							  GetSx3Cache(_aCmpPZC[_nZc], 'X3_TIPO'), GetSx3Cache(_aCmpPZC[_nZc], 'X3_TAMANHO'), ;
							  GetSx3Cache(_aCmpPZC[_nZc], 'X3_DECIMAL'), GetSx3Cache(_aCmpPZC[_nZc], 'X3_PICTURE')})
			EndIf
		//End
		Next _nZc
	//Fim - Thais Paiva - Compatibilização P27
	EndIf
	
Endif

If cFilAnt <> cOldFil
	SM0->(DbSeek(cEmpAnt+cOldFil))
EndIf

cFilAnt := cOldFil

Return lRet


/*
{Protheus.doc} GeraArqS
Monta o arquivo Sispag com base nos dados informados pelos parâmetros 
@Author     Ramon Teodoro e Silva
@Since      06/10/2017     
@Version    P12.7
@Return
*/

User Function GeraArqS(aSelFil, cBorIni, cBorFim, cArqCfg, nSelFil)

Local lRet      := .T.
Local aArea     := GetArea()
Local cQuery    := ""
Local cAliasTmp := "" 
Local cFilCor   := ""
Local cBord01   := ""
Local cBord02   := ""
Local _cMvNumArq	:= "" //Thais Paiva - Compatibilização P27

Private mv_par01 := ""
Private mv_par02 := ""
Private mv_par03 := cArqCfg
Private mv_par04 := "" 
Private xConteudo


cQuery := "SELECT SEA.*, SE2.E2_VALOR FROM " + RetSqlName("SEA") + " SEA "
cQuery += "INNER JOIN " + RetSqlName("SE2") + " SE2 ON " 

cQuery += " SEA.EA_NUMBOR = SE2.E2_NUMBOR "
cQuery += " AND SEA.EA_NUM = SE2.E2_NUM " 
cQuery += " AND SEA.EA_PARCELA = SE2.E2_PARCELA " 
cQuery += " AND SEA.EA_TIPO = SE2.E2_TIPO "
cQuery += " AND SEA.EA_FORNECE = SE2.E2_FORNECE "
cQuery += " AND SEA.EA_LOJA = SE2.E2_LOJA AND SE2.D_E_L_E_T_ = ' ' " 

If nSelFil == 1
	cQuery += " WHERE SEA.EA_FILIAL " + GetRngFil( aSelFil, "SEA", .T., "" ) + " AND "
Else 
	cQuery += " WHERE "
EndIf
cQuery += " SEA.EA_NUMBOR >= '" + cBorIni + "' AND SEA.EA_NUMBOR <= '" + cBorFim + "' AND "
cQuery += " SEA.EA_PORTADO = '341' AND SEA.D_E_L_E_T_ = ''"  
cQuery += " ORDER BY SEA.EA_FILIAL , SEA.EA_NUMBOR"
cQuery := ChangeQuery(cQuery)
cAliasTmp := GetNextAlias() 
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)

cFilCor := (cAliasTmp)->EA_FILIAL 
cBord01 := (cAliasTmp)->EA_NUMBOR

While !(cAliasTmp)->(Eof())

	If cFilCor <> (cAliasTmp)->EA_FILIAL 
	
		mv_par01 := cBord01
		mv_par02 := cBord02	
		cFilAnt  := cFilCor
		SM0->(DbSeek(cEmpAnt+cFilAnt))
		cArqName := Soma1(Pad(MVGetCus("FS_XNUMARQ"),6),6)
		//While !MayIUseCode( "PZC_ARQUIV"+SX6->X6_FIL+cArqName)  //verifica se esta na memoria, sendo usado Thais Paiva - Compatibilização P27
		While !MayIUseCode( "PZC_ARQUIV"+FwFilial("SX6")+cArqName)  //verifica se esta na memoria, sendo usado
			cArqName := Soma1(cArqName)										// busca o proximo numero disponivel 
		End
		
		cDir     := Alltrim(MVSGetCus( "FS_XDIRSIS" ,cFilant))
		//mv_par04 := IIf( SubStr(cDir, Len(cDir), 1) == "\", cDir, cDir+"\") + cArqName

		If At("\", cDir) > 0
			mv_par04 := IIf( SubStr(cDir, Len(cDir), 1) == "\", cDir, cDir+"\") + cArqName
		ElseIf At("/", cDir) > 0
			mv_par04 := IIf( SubStr(cDir, Len(cDir), 1) == "/", cDir, cDir+"/") + cArqName
		EndIf

		If !File(cDir)
			MsgAlert("Diretório para filial :" + cFilAnt + " não existe ou está vazio, verifique o parâmetro FS_XDIRSIS", "Diretório não existe")
		Else
			SisPagGer()
			U_GravaPZC(cFilCor, mv_par01, mv_par02, cArqName)
			
			//Início - Thais Paiva - Compatibilização P27
			//DbSelectArea("SX6")
			_cMvNumArq := MVGetCus("FS_XNUMARQ")
			//If SX6->X6_CONTEUD < cArqName
			If _cMvNumArq < cArqName
				//RecLock("SX6",.F.)
				//SX6->X6_CONTEUD := cArqName
				//msUnlock()
				PutMv("FS_XNUMARQ",cArqName)
				
			//Fim - Thais Paiva - Compatibilização P27
			EndIf
			
		EndIf
		
		cBord01 := (cAliasTmp)->EA_NUMBOR		
		cFilCor := (cAliasTmp)->EA_FILIAL 
					
	Else
	
		cFilCor := (cAliasTmp)->EA_FILIAL 
	
	EndIf
	
	cBord02 := (cAliasTmp)->EA_NUMBOR

	(cAliasTmp)->(DbSkip())
	
	If (cAliasTmp)->(Eof())
			
		mv_par01 := cBord01
		mv_par02 := cBord02	
		cFilAnt  := cFilCor
		SM0->(DbSeek(cEmpAnt+cFilAnt))
		cArqName := Soma1(Pad(MVGetCus("FS_XNUMARQ"),6),6)
		//While !MayIUseCode( "PZC_ARQUIV"+SX6->X6_FIL+cArqName)  //verifica se esta na memoria, sendo usado Thais Paiva - Compatibilização P27
		While !MayIUseCode( "PZC_ARQUIV"+FwFilial("SX6")+cArqName)  
			cArqName := Soma1(cArqName)										// busca o proximo numero disponivel 
		End
		
		cDir     := Alltrim(MVSGetCus( "FS_XDIRSIS" ,cFilant ))
		
		If At("\", cDir) > 0 
			mv_par04 := IIf( SubStr(cDir, Len(cDir), 1) == "\", cDir, cDir+"\") + cArqName
		ElseIf At("/", cDir) > 0
			mv_par04 := IIf( SubStr(cDir, Len(cDir), 1) == "/", cDir, cDir+"/") + cArqName
		EndIf

		If !File(cDir)
			MsgAlert("Diretório para filial :" + cFilAnt + " não existe ou está vazio, verifique o parâmetro FS_XDIRSIS", "Diretório não existe")
		Else
			SisPagGer()
			U_GravaPZC(cFilCor, mv_par01, mv_par02, cArqName)
			
			//Início - Thais Paiva - Compatibilização P27
			//DbSelectArea("SX6")
			_cMvNumArq := MVGetCus("FS_XNUMARQ")
			//If SX6->X6_CONTEUD < cArqName
			If _cMvNumArq < cArqName
				//RecLock("SX6",.F.)
				//SX6->X6_CONTEUD := cArqName
				//msUnlock()
				PutMv("FS_XNUMARQ",cArqName)
			//Fim - Thais Paiva - Compatibilização P27
			EndIf
			
		EndIf
			
	EndIf

End

Msginfo("Processo Finalizado", "Sispag Automatico", 1, .T.)

RestArea(aArea)
Return lRet



/*
{Protheus.doc} GravaPZC
Gravação do histórico de borderôs enviados na tabela PZC 
@Author     Ramon Teodoro e Silva
@Since      06/10/2017      
@Version    P12.7
@Return
*/
User Function GravaPZC(cFilSEA, cBorIni, cBorFim, cArqSis)

Local lRet   := .t.
Local aArea  := GetArea()
Local cFilAtu := " "
Local cBorAtu := " "

DbSelectArea("SEA")
DbSetOrder(1)
DbSelectArea("SE2")
DbSetOrder(1)
DbSelectArea("PZC")
DbSetOrder(1)

If SEA->(DbSeek(cFilSEA+cBorIni))	

	While !SEA->(Eof()) .And. SEA->EA_NUMBOR >= cBorIni .And. SEA->EA_NUMBOR <= cBorFim
		
		cFIlAtu  := SEA->EA_FILIAL
		cBorAtu  := SEA->EA_NUMBOR	
		
		If SE2->(DbSeek(SEA->(EA_FILIAL+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA)))
			
			If !Empty(SE2->E2_IDCNAB) 
			
				If PZC->(DbSeek(SEA->(EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA)))
					RecLock("PZC", .F.)
				Else
					RecLock("PZC", .T.)
				EndIf	
				
				PZC->PZC_FILIAL := SEA->EA_FILIAL
				PZC->PZC_NUMBOR := SEA->EA_NUMBOR
				PZC->PZC_DTBORD := SEA->EA_DATABOR
				PZC->PZC_PREFIX := SEA->EA_PREFIXO
				PZC->PZC_NUMTIT := SEA->EA_NUM
				PZC->PZC_PARCEL := SEA->EA_PARCELA
				PZC->PZC_TIPO   := SEA->EA_TIPO 
				PZC->PZC_FORNEC := SEA->EA_FORNECE
				PZC->PZC_LOJA   := SEA->EA_LOJA
				PZC->PZC_VLTIT  := SE2->E2_VALOR
				PZC->PZC_PORTAD := SEA->EA_PORTADO 
				PZC->PZC_AGEPOR := SEA->EA_AGEDEP
				PZC->PZC_CONPOR := SEA->EA_NUMCON
				PZC->PZC_MODELO := SEA->EA_MODELO
				PZC->PZC_TIPPAG := SEA->EA_TIPOPAG
				PZC->PZC_DTARQ  := Date()
				PZC->PZC_ARQUIV := cArqSis
										
				MsUnlock()

			EndIf

		EndIf

		SEA->(DbSkip())
	End
	
EndIf

RestArea(aArea)
Return lRet


/*
{Protheus.doc} VisArq
Gravação do histórico de borderôs enviados na tabela PZC 
@Author     Ramon Teodoro e Silva
@Since      06/10/2017      
@Version    P12.7
@Return
*/
User Function VisArq(cAlias, nReg, nOpc)

Local lRet  := .T.
Local aArea := GetArea()
Local nUsado    := 0
Local nCntFor   := 0
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Local lNopc1    := .F.
Local lNopc2    := .F.

Local oArquivo
Local oDtArq
Local oPortado
Local oAgencia
Local oConta
local oValArq

Local cArquivo := ""
Local cDtArq   := ""
Local cPortado := ""
Local cAgencia := ""
Local cConta   := ""
Local nValArq  := 0

Local nV     := 0
Local nPosVl := 0
Local _aCmpPZC := {} //Thais Paiva - Compatibilização P27
Local _nZc     := 0

Private aHeader := {}
Private aCols   := {}

Private oDlPZC   
Private oDlg

DbSelectArea("PZC")
DbSetOrder(3)

RegToMemory( "PZC", lNopc1, lNopc2 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aHeader := {}
//Início - Thais Paiva - Compatibilização P27
//DbSelectArea("SX3")
//DbSetOrder(1)
//DbSeek("PZC",.T.)

_aCmpPZC := FWSX3Util():GetAllFields( "PZC" , .T. )

nUsado := 0
For _nZc := 1 to Len(_aCmpPZC)
	If ( cNivel >= GetSx3Cache(_aCmpPZC[_nZc], 'X3_NIVEL') )
		If !(ALLTRIM(GetSx3Cache(_aCmpPZC[_nZc], 'X3_CAMPO')) $ "PZC_ARQUIV|PZC_DTARQ|PZC_PORTAD|PZC_AGEPOR|PZC_CONPOR")
			AADD(aHeader,{ AllTrim(GetSx3Cache(_aCmpPZC[_nZc], 'X3_TITULO')),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_CAMPO'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_PICTURE'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_TAMANHO'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_DECIMAL'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_VALID'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_USADO'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_TIPO'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_F3'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_CONTEXT'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_CBOX'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_RELACAO'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_WHEN'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_VISUAL'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_VLDUSER'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_PICTVAR'),;
			GetSx3Cache(_aCmpPZC[_nZc], 'X3_OBRIGAT')})
			nUsado++
		Endif
	Endif
	//SX3->(DbSkip())
//End
Next _nZc

*----------------------------------------------------------------+
*   Montagem do aCols                                              |
*----------------------------------------------------------------+
cArquivo := Alltrim(PZC->PZC_ARQUIV) 
cDtArq   := Alltrim(DtoC(PZC->PZC_DTARQ))
cPortado := Alltrim(PZC->PZC_PORTAD)
cAgencia := Alltrim(PZC->PZC_AGEPOR)
cConta   := Alltrim(PZC->PZC_CONPOR)
cFilPZC  := Alltrim(PZC->PZC_FILIAL)

BeginSql alias "PZCTMP"

%noparser%
//SELECT PZC_FILIAL, PZC_ARQUIV, PZC_PORTAD, PZC_AGEPOR, PZC_CONPOR, PZC_DTARQ, PZC_PREFIX, PZC_NUMTIT, PZC_PARCEL, PZC_TIPO, PZC_FORNEC, PZC_LOJA, PZC_NUMBOR, PZC_DTBORD, PZC_MODELO, PZC_TIPPAG
SELECT PZC_FILIAL, PZC_PREFIX, PZC_NUMTIT, PZC_PARCEL, PZC_TIPO, PZC_FORNEC, PZC_LOJA, PZC_PORTAD, PZC_AGEPOR, PZC_CONPOR, PZC_MODELO, PZC_TIPPAG, PZC_ARQUIV, PZC_DTARQ, PZC_NUMBOR, PZC_DTBORD, PZC_VLTIT
FROM %table:PZC% PZC
WHERE 	PZC_FILIAL = %exp:cFilPZC% AND PZC_ARQUIV = %exp:cArquivo% AND %notDel%

EndSql

While (!PZCTMP->(Eof()))
	aadd(aCols,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			If aHeader[nCntFor][8] == "D"
				aCols[Len(aCols)][nCntFor] := StoD(FieldGet(FieldPos(aHeader[nCntFor][2])))
			Else
				aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
			EndIf			
		Else
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
	Next nCntFor
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	PZCTMP->(DbSkip())
End

If Select("PZCTMP")>0
	DbSelectArea("PZCTMP")
	DbCloseArea()
EndIf

//

aObjects := {}
AAdd( aObjects, { 315,  30, .T., .T. } )
AAdd( aObjects, { 100,  70, .T., .T. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

nPosVl := Ascan(aHeader,{|x|Alltrim(x[2])=="PZC_VLTIT"})

For nV := 1 to Len(aCols)

	nValArq += aCols[nV][nPosVl]

Next nV

DEFINE MSDIALOG oDlg TITLE "Borderôs Enviados"  FROM 0,0 TO 420, 870 OF oMainWnd PIXEL
			
@ 36,010 SAY "Arquivo:"           SIZE 050,07  OF oDlg PIXEL	 
@ 35,032 MSGET oArquivo  VAR cArquivo     SIZE 030,04  OF oDlg PIXEL HASBUTTON When .F.

@ 36,070 SAY "Dt. Arquivo:"           SIZE 050,07  OF oDlg PIXEL	 
@ 35,100 MSGET oDtArq  VAR cDtArq     SIZE 035,04  OF oDlg PIXEL HASBUTTON When .F.

@ 36,150 SAY "Portador:"           SIZE 050 ,07  OF oDlg PIXEL	 
@ 35,174 MSGET oPortado  VAR cPortado     SIZE 015,04  OF oDlg PIXEL HASBUTTON When .F.

@ 36,205 SAY "Agência:"           SIZE 050,07  OF oDlg PIXEL	 
@ 35,228 MSGET oAgencia  VAR cAgencia     SIZE 020,04  OF oDlg PIXEL HASBUTTON When .F.

@ 36,262 SAY "Conta:"           SIZE 050,07  OF oDlg PIXEL	 
@ 35,280 MSGET oConta  VAR cConta     SIZE 030,04  OF oDlg PIXEL HASBUTTON When .F.

@ 36,330 SAY "Valor:"           SIZE 050,07  OF oDlg PIXEL	 
@ 35,347 MSGET oValArq  VAR nValArq     SIZE 050,04  OF oDlg PIXEL HASBUTTON When .F. Picture "@E 999,999,999.99"

oDlPZC := MsNewGetDados():New(50,0,200,437/*362*/,  ,,,,,,9999,,,,oDlg,aHeader,aCols) 

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpc:=1,oDlg:End()}, {|| nOpc:=0,oDlg:End() },,)
		
RestArea(aArea)
Return lRet


/*
{Protheus.doc} MenuDef()
Criação do Menu de atendimento de solicitações
@Author     Thiago Góes
@Since      21/10/2020
@Version    P12.1.27
@Return		aRotina, opção de menu
*/
Static Function MenuDef()
	
	//Private cCadastro := "Borderôs Enviados"
	Private aRotina := {{"Pesquisar" 	 ,"AxPesqui",0,1,,.F.} ,;
						{"Visualizar"    ,"U_VisArq",0,2} ,;
						{"Gerar Arquivo" ,"U_SisAut",0,3}}

Return aRotina
Static Function MVSGetCus(cParam1, cParam2)
Return SuperGetMv(cParam1, .F. , .F.,cParam2)

Static Function MVGetCus(cParam1)
Return GetMv(cParam1)
