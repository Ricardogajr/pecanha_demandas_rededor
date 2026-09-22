#INCLUDE "AE_DV002_AP6.ch"
#include "PROTHEUS.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AE_DV002  ºAutor  ³Willy / Armando     º Data ³  09/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatório de Despesas, com viagem e Outros.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP6                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AE_DV002()
Local _aArea
Local ni			:= 0
Private _nQuem
Private aMemos 	:= {{"LHQ_CODOBS","LHQ_OBSMEM"}}
Private _nReembolso
Private _nDevolucao
Private _nTotGasto
Private _nRdia
Private _nUmdia
Private _lAvulso	:= .F.

Private _nAdiant 	:= 0
Private _nAdtUS 	:= 0
Private _nGastoR 	:= 0
Private _nGastoD 	:= 0
Private _nReembR 	:= 0
Private _nReembD 	:= 0
Private _nReembNr := 0
Private _nDifReal 	:= 0
Private _nDifDolar	:= 0
Private _nCPMF 	:= 0
Private cSolicita	:= ""
Private cAprov01	:= ""
Private cAprov02	:= ""  
Private cPict		:= "@E 999,999,999.99"

ChkTemplate("CDV")

If LHQ->LHQ_Flag == 'D'
	RecLock('LHQ', .F.)
	LHQ->LHQ_Flag := 'L'
	LHQ->LHQ_Impres:= LHQ->LHQ_Impres + 1
	MsUnLock('LHQ')
EndIF

dbSelectArea("LHP")
LHP->(dbSetOrder(1))
If !LHP->(dbSeek(xFilial("LHP") + LHQ->LHQ_CODIGO))
	MsgInfo(OemToAnsi(STR0001)) //"Nenhuma solicitaçãoo de viagem associada pode ser encontrada, impressão cancelada!"
	Return Nil
Endif

If LHP->LHP_FLAG == "B" .AND. LHP->LHP_FLAG1 == "B"
	_lAvulso:= .T.
Else
	If Empty(LHQ->LHQ_Saida)
		_lAvulso := .T. // Relatório de Despesas Avulso
	Endif
Endif

If LHP->LHP_Flag1 == 'K' //Solicitacao cancelada
	MsgInfo(STR0002) //"Esta solicitação está cancelada e não pode ser reimpressa."
	Return          
EndIf

If _lAvulso
	Pergunte( "DV002" , .T. )
Else
	Pergunte( "DV002" , .F. )
	MV_PAR01 := 1	// (1-(NÃO) Default)
EndIf
//-------------------------------------------------------------------------
// MV_PAR01 - Imprime Aprovadores ?		1-(NÃO)  2-(SIM) 
// MV_PAR02 - Quantidade de aprovadores ? 1-(1 APROVADOR) 2-(2 Aprovadores)
//-------------------------------------------------------------------------

cSolicita := Posicione("LHT",1,xFilial("LHT")+LHP->LHP_FUNC,"LHT_CODMAT+LHT_NOME")
If !Empty(cSolicita)
	cSolicita := Upper(AllTrim(cSolicita))
	cSolicita := Substr(cSolicita,1,ni := TamSX3("LHT_CODMAT")[1]) + " - " + Substr(cSolicita,ni + 1,Len(cSolicita))
Endif
If !_lAvulso .OR. !Empty(LHP->LHP_SUPIMD)
	cAprov01 := Posicione("LHT",1,xFilial("LHT")+LHP->LHP_SUPIMD,"LHT_CODMAT+LHT_NOME")
	If !Empty(cAprov01)
		cAprov01 := Upper(AllTrim(cAprov01))
		cAprov01 := Substr(cAprov01,1,ni := TamSX3("LHT_CODMAT")[1]) + " - " + Substr(cAprov01,ni + 1,Len(cAprov01))
	Endif    
Endif
If !_lAvulso .OR. !Empty(LHP->LHP_DGRAR)
	cAprov02 := Posicione("LHT",1,xFilial("LHT")+LHP->LHP_DGRAR,"LHT_CODMAT+LHT_NOME")
	If !Empty(cAprov02)
		cAprov02 := Upper(AllTrim(cAprov02))
		cAprov02 := Substr(cAprov02,1,ni := TamSX3("LHT_CODMAT")[1]) + " - " + Substr(cAprov02,ni + 1,Len(cAprov02))
	Endif
Endif

_nAdiant := LHP->LHP_ValorR
_nAdtUS := LHP->LHP_ValorU
_nGastoR := LHQ->LHQ_ValNR + LHQ->LHQ_ValRb
_nGastoD := LHQ->LHQ_ValNRD + LHQ->LHQ_ValRbD
_nReembR := LHQ->LHQ_ValRb
_nReembD := LHQ->LHQ_ValRbD
_nReembNr := _nAdiant - _nReembR
_nCPMF	 := LHQ->LHQ_CPMF
_nDifReal := _nAdiant - _nReembR - _nCPMF
_nDifDolar:= _nAdtUS - _nReembD

_nQuem := IIf(LHP->LHP_EINTER == .T., "2", "1")
_nRdia:= Val(LHP->LHP_Rdia)
_nUmdia:= Val(LHP->LHP_Umdia)

SetPrvt('oPrint')
oPrint := TMSPrinter():New(STR0003) //'Relatório de Despesas'

// nome          Li  Co  Fro   N  ? ? ?   I    U
oFontCN10  := TFont():New("Courier New", 10, 10, .F., .F., , , , .F., .F.)
oFontCN10N := TFont():New("Courier New", 10, 10, .F., .T., , , , .F., .F.)
oFontCN11N := TFont():New("Courier New", 11, 11, .F., .T., , , , .F., .F.)
oFontCN12  := TFont():New("Courier New", 12, 12, .F., .F., , , , .F., .F.)
oFontCN12N := TFont():New("Courier New", 12, 12, .F., .T., , , , .F., .F.)

// nome     Li  Co  Fro   N  ? ? ?   I    U
oFont10  := TFont():New("Tahoma", 10, 10, .F., .F., , , , .F., .F.)
oFont10N := TFont():New("Tahoma", 10, 10, .F., .T., , , , .F., .F.)
oFont12  := TFont():New("Tahoma", 12, 12, .F., .F., , , , .F., .F.)
oFont12N := TFont():New("Tahoma", 12, 12, .F., .T., , , , .F., .F.)
oFont14  := TFont():New("Tahoma", 14, 14, .F., .F., , , , .F., .F.)
oFont14N := TFont():New("Tahoma", 14, 14, .F., .T., , , , .F., .F.)
oFont26N := TFont():New("Tahoma", 26, 26, .F., .T., , , , .F., .F.)

oPrint:SetPortrait()

MsgRun(STR0004,"",{|| CursorWait(), MontaRel(oPrint),CursorArrow()}) //'Gerando Visualização, Aguarde...'

oPrint:Preview()  // Visualiza antes de imprimir

Return

*--------------------------------------------------------------------------------------
Static Function MontaRel(oPrint)
*--------------------------------------------------------------------------------------
SetPrvt('_lZera')
_lZera := .T.

CabecREL(oPrint) //Imprime Cabeçalho e Grade

ItemREL(oPrint) //Imprime os Itens

RodapeREL(oPrint,_lZera) // Imprime Rodape

Return
*--------------------------------------------------------------------------------------


*--------------------------------------------------------------------------------------
Static Function CabecREL(oPrint)
*--------------------------------------------------------------------------------------

oPrint:SayBitmap(100, 100, "\SIGAADV\LGRL00.BMP", 530, 120)

oPrint:Say(100, 650, STR0005, oFont26N) //"Relatório de Despesas"

oPrint:Box( 125, 2000, 210, 2300 )
oPrint:Say(135, 2050, LHQ->LHQ_Codigo, oFont14N) //Codigo da Despesa

oPrint:Line( 250, 100, 250, 2500 )
                    
DbSelectArea('SA1')
DbSetOrder(1)
MsSeek(xFilial('SA1') + LHP->LHP_Empcli)

oPrint:Say(300, 100, STR0006, oFont14N) //'Empresa'
oPrint:Say(300, 0450, SA1->A1_Cod + ' - ' + SubStr(SA1->A1_Nome,1,30) , oFont14) //Cliente

oPrint:Say(0300, 1650, STR0007, oFont14N)	//Centro de Custo //'C. Custo'
oPrint:Say(0300, 1870, AllTrim(LHP->LHP_CC), oFont14)

oPrint:Say(0375, 0100, STR0008, oFont14N) //'Colaborador'
oPrint:Say(0375, 0450, cSolicita, oFont14)

If !_lAvulso .or. (MV_PAR01 == 2)
	oPrint:Say(0450, 0100, STR0009, oFont14N) //'Aprovador I     '
	oPrint:Say(0450, 0450, If(Empty(cAprov01), Replicate("_", 090), cAprov01), oFont14) 

	If		!_lAvulso .or. ((MV_PAR01 == 2) .and. (MV_PAR02 == 2))
		oPrint:Say(0525, 0100, STR0010, oFont14N) //'Aprovador II'
		oPrint:Say(0525, 0450, If(Empty(cAprov02), Replicate("_", 090), cAprov02), oFont14)
	ElseIf !_lAvulso .or. ((MV_PAR01 == 2) .and. (MV_PAR02 == 1) .and. !Empty(cAprov02))
		oPrint:Say(0525, 0100, STR0010, oFont14N) //'Aprovador II'
		oPrint:Say(0525, 0450, If(Empty(cAprov02), Replicate("_", 090), cAprov02), oFont14)
	Else
		oPrint:Line( 0525, 100, 0525, 2500 )
	EndIf
Else 
	oPrint:Say(0450, 0100, STR0009, oFont14N) //'Aprovador I     '
	If Empty(cAprov01)
		oPrint:Say(0450, 0450, STR0011, oFont14) //"DESPESA AVULSA - SEM APROVAÇÃO"
	Else 
		oPrint:Say(0450, 0450, cAprov01, oFont14)
	Endif
	
	oPrint:Say(0525, 0100, STR0010, oFont14N) //'Aprovador II'
	If Empty(cAprov02)
		oPrint:Say(0525, 0450, STR0011, oFont14) //"DESPESA AVULSA - SEM APROVAÇÃO"
	Else 
		oPrint:Say(0525, 0450, cAprov02, oFont14)
	Endif
Endif

oPrint:Say(0600, 0100, STR0012, oFont14N) //'Fatura Cliente'
oPrint:Say(0600, 0450, Transform(LHP->LHP_FatCli, '@E 999') + ' %', oFont14)

oPrint:Say(0600, 0950, STR0013, oFont14N) //'Não Faturar'
oPrint:Say(0600, 1300, AllTrim(Transform(LHP->LHP_FatMic, '@E 999')) + ' %', oFont14)

oPrint:Say(0700, 0100, STR0014, oFont12N) //'Período e Horário da Viagem'
oPrint:Box( 0750, 0100, 0850, 2500 )
If !_lAvulso
	oPrint:Say(0780, 0130, STR0015, oFont12N) //'Solicitado'
	oPrint:Say(0780, 0380, DtoC(LHQ->LHQ_Saida),  oFont12)
	oPrint:Say(0780, 0580, LHQ->LHQ_HoraId, oFont12)
	oPrint:Say(0780, 0700, STR0016, oFont12N) //'à'
	oPrint:Say(0780, 0770, DtoC(LHQ->LHQ_Chegad), oFont12)
	oPrint:Say(0780, 0970, LHQ->LHQ_HoraVt, oFont12)
	
	oPrint:Say(0780, 1280, STR0017, oFont12N) //'Realizado'
	oPrint:Say(0780, 1550, DtoC(LHQ->LHQ_DtSaid),  oFont12)
	oPrint:Say(0780, 1750, LHQ->LHQ_HorSai, oFont12)
	oPrint:Say(0780, 1870, STR0016, oFont12N) //'à'
	oPrint:Say(0780, 1940, DtoC(LHQ->LHQ_DtCheg), oFont12)
	oPrint:Say(0780, 2140, LHQ->LHQ_HorChg, oFont12)
Else 
	oPrint:Say(0780, 0130, STR0017, oFont12N) //'Realizado'
	oPrint:Say(0780, 0380, DtoC(LHQ->LHQ_DtSaid),  oFont12)
	oPrint:Say(0780, 0610, LHQ->LHQ_HorSai, oFont12)
	oPrint:Say(0780, 0750, STR0016, oFont12N) //'à'
	oPrint:Say(0780, 0820, DtoC(LHQ->LHQ_DtCheg), oFont12)
	oPrint:Say(0780, 1050, LHQ->LHQ_HorChg, oFont12)
Endif
oPrint:Line( 0900, 0100, 0900, 2500 )
oPrint:Line( 0970, 0100, 0970, 2500 )

oPrint:Line( 0900, 0100, 2020, 0100 )
oPrint:Line( 0900, 2500, 2020, 2500 )

oPrint:Say(0910, 0120, STR0018, oFontCN11N) //'It'
oPrint:Line( 0900, 0200, 2020, 0200 )

oPrint:Say(0910, 0220, STR0019, oFontCN11N) //'Data'
oPrint:Line( 0900, 0460, 2020, 0460 )

oPrint:Say(0910, 0480, STR0020, oFontCN11N) //'Código'
oPrint:Line( 0900, 0640, 2020, 0640 )

oPrint:Say(0910, 0660, STR0021, oFontCN11N) //'Descrição'
oPrint:Line( 0900, 1900, 2020, 1900 )

oPrint:Say(0910, 1940, STR0022, oFontCN11N) //'Qtd'
oPrint:Line( 0900, 2040, 2020, 2040 )

oPrint:Say(0910, 2060, STR0023, oFontCN11N) //'Valor'

Return(oPrint)
*--------------------------------------------------------------------------------------


*--------------------------------------------------------------------------------------
Static Function ItemREL(oPrint)
*--------------------------------------------------------------------------------------
Local _cMoeda := ""

SetPrvt('_nLinha, _nValrBN, _nValrRS, _cCodAE3,_dData,_cAE3')
_nLinha := 985
_nValrBN := 0
_nValrRS := 0

DbSelectArea('LHR')
DbSetOrder(1)
If MsSeek(xFilial('LHR') + LHQ->LHQ_Codigo)
	Do While !Eof() .And.;
		LHR->LHR_Filial == LHQ->LHQ_Filial .And.;
		LHR->LHR_Codigo == LHQ->LHQ_Codigo
		
		If cPaisLoc == "BRA"
			_cMoeda := Iif(LHR->LHR_MOEDA == 2, "US$", "R$")
		Else
			_cMoeda := GetMv("MV_SIMB" + AllTrim(Str(LHR->LHR_MOEDA)))
		EndIf
		_cCodAE3:= LHR->LHR_Codigo
		oPrint:Say(_nLinha, 0120, LHR->LHR_Item, oFontCN10)
		_dData := SubStr(DtoS(LHR->LHR_Data),7,2) + '/' +;
		SubStr(DtoS(LHR->LHR_Data),5,2) + '/' +;
		SubStr(DtoS(LHR->LHR_Data),1,4)
		oPrint:Say(_nLinha, 0220, _dData, oFontCN10)
		oPrint:Say(_nLinha, 0480, LHR->LHR_CodDes, oFontCN10)
		oPrint:Say(_nLinha, 0660, LHR->LHR_Descr, oFontCN10)
		oPrint:Say(_nLinha, 1950, Transform(LHR->LHR_Qtdade,PesqPict("LHR","LHR_Qtdade")), oFontCN10)
		oPrint:Say(_nLinha, 2050, _cMoeda + Transform(LHR->LHR_VlrTot, cPict), oFontCN10)
		
		_nLinha+=45
		If _lAvulso
			_nValrRS+= LHR->LHR_VlrTot
		EndIf

		If LasU_Of('LHR->LHR_DATA','B')
			oPrint:Line( _nLinha, 0100, _nLinha, 2500 )
			IIF(_nValrBN >= _nRdia,_nValrBN:=_nRdia,_nValrBN)
			IIF(LHQ->LHQ_ValNR == _nUmdia,_nValrBN:=_nUmdia,_nValrBN)
			oPrint:Line( _nLinha, 0640, _nLinha, 2500 )
			_nValrBN:= 0
			_nValrRS:= 0
		EndIf
		If _nLinha > 2060
			If _nLinha > 2650
				_nLinha:= 985
				_cAE3 := GetArea() // Salva Area
				oPrint:EndPage() // Finaliza a página
				oPrint:StartPage() // Inicia uma nova página
				CabecREL(oPrint) //Imprime Cabeçalho e Grade
				RestArea(_cAE3)  // Restaura Area
			Else
				oPrint:Line( 2020, 0100, 2800, 0100 )
				oPrint:Line( 2020, 0200, 2800, 0200 )
				oPrint:Line( 2020, 0460, 2800, 0460 )
				oPrint:Line( 2020, 0640, 2800, 0640 )
				oPrint:Line( 2020, 1900, 2800, 1900 )
				oPrint:Line( 2020, 2040, 2800, 2040 )
				oPrint:Line( 2020, 2500, 2800, 2500 )
				oPrint:Line( 2800, 0100, 2800, 2500 )
				oPrint:Say(3000, 1100, STR0024, oFont12N) //'Continua =>'
			EndIf
		Endif
		DbSkip()
		If _cCodAE3 <> LHR->LHR_Codigo .and. _nLinha > 2060
			_nLinha:= 985
			_cAE3 := GetArea() // Salva Area
			oPrint:EndPage() // Finaliza a página
			oPrint:StartPage() // Inicia uma nova página
			CabecREL(oPrint) //Imprime Cabeçalho e Grade
			RestArea(_cAE3)  // Restaura Area
		EndIf
	EndDo
EndIf

Return(oPrint)
*--------------------------------------------------------------------------------------


*--------------------------------------------------------------------------------------
Static Function RodapeREL(oPrint,_lZera)
*--------------------------------------------------------------------------------------

Static nTamNome		:= 30

oPrint:Line( 2020, 0100, 2020, 2500 )

//RESUMO EM REAIS
oPrint:Box( 2050, 0100, 2220, 2500 )

If cPaisLoc == "BRA"
	oPrint:Say(2060, 0115, STR0025 + GetMv("MV_SIMB1"), oFont12N) //'Resumo em R$'
	oPrint:Line( 2120, 0100, 2120, 2500 )
Else
	oPrint:Say(2060, 0115, STR0025 + GetMv("MV_SIMB1"), oFont12N) //'Resumo em R$'
	oPrint:Line( 2120, 0100, 2120, 2500 )
EndIf

oPrint:Say(2150, 0115, STR0026, oFontCN10) //'Adiantamento: '
oPrint:Say(2150, 0455, AllTrim(Transform(_nAdiant, cPict)), oFontCN10N)

oPrint:Say(2150, 0680, STR0027, oFontCN10) //'Gastos: '
oPrint:Say(2150, 0840, AllTrim(Transform(_nGastoR, cPict)), oFontCN10N)

oPrint:Say(2150, 1170, STR0028, oFontCN10) //'Reembolsável: '
oPrint:Say(2150, 1465, AllTrim(Transform(_nReembR, cPict)), oFontCN10N)

If GetMv('MV_INICPMF')
	oPrint:Say(2150, 1530, STR0029, oFontCN10) //'CPMF: '
	oPrint:Say(2150, 1650, AllTrim(Transform(_nCPMF, '@E 99.99')), oFontCN10N)
EndIf            

oPrint:Say(2150, 1800, STR0030, oFontCN10) //'Diferença: '
oPrint:Say(2150, 2070, AllTrim(Transform(_nDifReal, cPict)), oFontCN10N)

//MENSAGEM EM REAIS
If cPaisLoc == "BRA"
	If _nDifReal < 0
		_cMens := STR0031 + GetMv("MV_SIMB1") + AllTrim(Transform(Abs(_nDifReal), cPict)) //'O colaborador deve Receber R$ '
	ElseIf _nDifReal > 0
		_cMens := STR0032 + GetMv("MV_SIMB1") + AllTrim(Transform(Abs(_nReembNr), cPict)) //'O colaborador deve Devolver R$ '
	Else
		_cMens := STR0033 + GetMv("MV_MOEDA1") + " (" + GetMv("MV_SIMB1") + ")"
	EndIf
Else
	If _nDifReal < 0
		_cMens := STR0031 + GetMv("MV_SIMB1") + " " + AllTrim(Transform(Abs(_nDifReal), cPict)) //'O colaborador deve Receber  '
	ElseIf _nDifReal > 0
		_cMens := STR0032 + GetMv("MV_SIMB1") + " " + AllTrim(Transform(Abs(_nReembR), cPict)) //'O colaborador deve Devolver  '
	Else
		_cMens := STR0033 + GetMv("MV_MOEDA1") + " (" + GetMv("MV_SIMB1") + ")" //'Não será necessário realizar acertos na moeda .'
	EndIf
EndIf

oPrint:Say(2240, 0115, _cMens, oFont12N)

//RESUMO EM DOLARES
oPrint:Box(2350, 0100, 2520, 2500 )

If cPaisLoc == "BRA"
	oPrint:Say(2360, 0115, STR0034 + GetMv("MV_SIMB2"), oFont12N) //'Resumo em US$'
	oPrint:Line(2420, 0100, 2420, 2500 )
Else
	oPrint:Say(2360, 0115, STR0034 + GetMv("MV_SIMB2"), oFont12N) //'Resumo em R$'
	oPrint:Line(2420, 0100, 2420, 2500 )
EndIf
	
oPrint:Say(2450, 0115, STR0026, oFontCN10) //'Adiantamento: '
oPrint:Say(2450, 0455, AllTrim(Transform(_nAdtUS, cPict)), oFontCN10N)

oPrint:Say(2450, 0680, STR0027, oFontCN10) //'Gastos: '
oPrint:Say(2450, 0840, AllTrim(Transform(_nGastoD, cPict)), oFontCN10N)

oPrint:Say(2450, 1170, STR0028, oFontCN10) //'Reembolsável: '
oPrint:Say(2450, 1465, AllTrim(Transform(_nReembD, cPict)), oFontCN10N)

oPrint:Say(2450, 1800, STR0030, oFontCN10) //'Diferença: '
oPrint:Say(2450, 2070, AllTrim(Transform(_nDifDolar, cPict)), oFontCN10N)

//MENSAGEM EM DOLARES
If cPaisLoc == "BRA"
	If _nDifDolar < 0
		_cMens := STR0035 + GetMv("MV_SIMB2") + AllTrim(Transform(Abs(_nDifDolar), cPict)) //'O colaborador deve Receber US$ '
	ElseIf _nDifDolar > 0
		_cMens := STR0036 + GetMv("MV_SIMB2") + AllTrim(Transform(Abs(_nDifDolar), cPict)) //'O colaborador deve Devolver US$ '
	Else
		_cMens := STR0037 + GetMv("MV_MOEDA2") + " (" + GetMv("MV_SIMB2") + ")"//'Não será necessário realizar acertos na moeda Dólar (US$).'
	EndIf
Else
	If _nDifDolar < 0
		_cMens := STR0035 + GetMv("MV_SIMB2") + " " + AllTrim(Transform(Abs(_nDifDolar), cPict)) //'O colaborador deve Receber '
	ElseIf _nDifDolar > 0
		_cMens := STR0036 + GetMv("MV_SIMB2") + " " + AllTrim(Transform(Abs(_nDifDolar), cPict)) //'O colaborador deve Devolver '
	Else
		_cMens := STR0037 + GetMv("MV_MOEDA2") + " (" + GetMv("MV_SIMB2") + ")"//'Não será necessário realizar acertos na moeda '
	EndIf
EndIf

oPrint:Say(2540, 0115, _cMens, oFont12N)

//LOCAL PARA ASSINATURA DO APROVADOR + SOLICITANTE
If !_lAvulso .or. (MV_PAR01 == 2)
	oPrint:Line(3000,0100, 3000, 0700 )
	oPrint:Say(3000,0100, STR0038, oFont10) //'Aprovador 1'
	oPrint:Say(3050,0100, IIf(!Empty(cAprov01),Substr(cAprov01,At("-",cAprov01)+2,nTamNome),""), oFont10)
	
	If !_lAvulso .or. ((MV_PAR01 == 2) .and. (MV_PAR02 == 2))
		oPrint:Line(3000,0850, 3000, 1450 )
		oPrint:Say(3000,0850, STR0039, oFont10) //'Aprovador 2'
		oPrint:Say(3050,0850, IIf(!Empty(cAprov02),Substr(cAprov02,At("-",cAprov02)+2,nTamNome),""), oFont10)
	EndIf
	
	oPrint:Line(3000,1600, 3000, 2200 )
	oPrint:Say(3000,1600, STR0040, oFont10) //'Solicitante'
	oPrint:Say(3050,1600, IIf(!Empty(cSolicita),Substr(cSolicita,At("-",cSolicita)+2,nTamNome),""), oFont10)
Else
	oPrint:Line(3000,0100, 3000, 0700 )
	oPrint:Say(3000,0100, STR0040, oFont10) //'Solicitante'
	oPrint:Say(3050,0100, IIf(!Empty(cSolicita),Substr(cSolicita,At("-",cSolicita)+2,nTamNome),""), oFont10)
Endif

Return(oPrint)

*--------------------------------------------------------------------------------------
Static Function LasU_Of(_cNomeL, _cTipoL)
*--------------------------------------------------------------------------------------
SetPrvt('_vChaveL, _lFlag')

If _cTipoL == 'B' // Base de dados
	_vChaveL := &_cNomeL
	_lFlag := .F.
	DbSkip()
	If eof()
		_lFlag := .T.
	Else
		If &_cNomeL <> _vChaveL
			_lFlag := .T.
		EndIf
	EndIf
	DbSkip(-1)
EndIf

Return(_lFlag)
