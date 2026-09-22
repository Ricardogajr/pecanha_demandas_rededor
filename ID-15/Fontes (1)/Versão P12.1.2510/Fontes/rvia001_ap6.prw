#INCLUDE "RVia001_AP6.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RVIA001   ºAutor  ³ Willy 		     º Data ³  09/06/02   º±±
±±º          ³          ºAtualiz³ Itamar Oliveira    º      ³  07/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de Viagens                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RVia001()

Local aOrd
Local cDesc1
Local cDesc2
Local cDesc3
Local cTamanho
Local limite
Private _cAlias
Private cProgram
Private cTitulo
Private cPerg
Private lDic
Private lCompres
Private lFim
Private wnrel
Private nTamanho 
Private nLastKey	:= 0

ChkTemplate("CDV")

cProgram:= 'RVia001'// nome do relatório
_cAlias := 'LHP'    // alias do arquivo
cPerg   := 'VIA001' // grupo de perguntas
cTitulo := STR0001 //'Viagens Realizadas por Período e por Colaborador'
cDesc1  := STR0002 //'Este relatório irá emitir uma relação de viagens realizadas pelos Colaboradores'
cDesc2  := STR0003 //'com quebra por Colaborador e Totalização por Colaborador / Período.'
cDesc3  := STR0004 //'Os dados do formato acima serão filtrados conforme os parâmetros especificados.'
lDic    := .F.  // não utiliza dicionário
aOrd    := {STR0005} //" Por Colaborador    "
lCompres:= .F.
Tamanho := 'G'
limite  := 220
Private aReturn := { "Zebrado", 1,"Administração", 1, 2, 1, "",1 }
lFim    := .F.

Pergunte(cPerg, .F. )

wnrel := SetPrint(_cAlias, cProgram, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, lDic, aOrd , lCompres, Tamanho )

If nLastKey = 27
	Return
Endif

SetDefault( aReturn, _cAlias)

If nLastKey == 27
	Return
EndIf

RptStatus({|lFim| Imprime(@lFim, _cAlias, cTitulo, cProgram, Tamanho )}, cTitulo )

Return
*--------------------------------------------------------------------------------------------------------------------

*--------------------------------------------------------------------------------------------------------------------
Static Function Imprime( lFim, _cAlias, cTitulo, cProgram, Tamanho)
*--------------------------------------------------------------------------------------------------------------------
Local _nValPrev:= 0, _nValReal:= 0, _nDiaP:= 0, _nDiaR:= 0/*_nDiaPN:=0*/,_nVlTHosp:= 0,_nVlTPass:= 0
Local _nValPrvD:= 0, _nValRlD:= 0
Local _nTValPrev:= 0,_nTValReal:= 0,_nTDiaP:= 0,_nTDiaR:= 0,_nTDiaPN:= 0,_nTVlTHosp:= 0,_nTVlTPass:= 0
Local _nTValPrvD := 0, _nTValRlD := 0,_nDespR := 0,_nDespD := 0

Local cbTxt   := Space(10) , cbCont  := 0 , _cFuncAnt, _nFirst ,_lCabec
Local cCabec2:= STR0006 //'Código  Emissao     Saida - Retorno  Local                           Cliente                                  Previsto-R$ Realizado-R$ Previsto-US$ Realizado-US$  DP  DR  C.Custo  Nao Fat. Fat.Cli.   D.Hotel   Passagem'
Local cCabec1:= STR0007 //'DP = Dias de Viagem Prevista  -  DR = Dias de Viagem Realizada -  PN = Quantidade de Pernoite.'
li      := 80
m_pag   := 1

dbSelectArea(_cAlias)
dbSetOrder(3)
If AllTrim(Mv_Par01) != "" .Or. AllTrim(Mv_Par02) != ""
	MsSeek(xFilial('LHP') + Mv_Par01, .T.)
Else                             
	DbGoTop()	
EndIf

_cFuncAnt:= LHP->LHP_Func
_nFirst:= 0
_lCabec:= .F.

SetRegua( RecCount() )
While !Eof() .And. LHP->LHP_Filial == xFilial('LHP') 

	If !Empty(aReturn[7])
		Set Filter To &(aReturn[7])
	EndIf

 	//Colaborador
 	If AllTrim(Mv_Par01) != "" .Or. AllTrim(Mv_Par02) != ""
		If LHP->LHP_Func < Mv_Par01 .Or. LHP->LHP_Func > Mv_Par02
			LHP->(DbSkip())
			Loop
		EndIf
	EndIf
	
	//Data
	If AllTrim(DTOS(Mv_Par03)) != "" .Or. AllTrim(DTOS(Mv_Par04)) != ""
		If LHP->LHP_Saida  < Mv_Par03 .Or. LHP->LHP_Saida  > Mv_Par04
			LHP->(dbSkip())
			Loop
		EndIf
	EndIf

	//Cliente
	If AllTrim(Mv_Par06) != "" .Or. AllTrim(Mv_Par07) != ""
		If LHP->LHP_EmpCli < Mv_Par06 .Or. LHP->LHP_EmpCli > Mv_Par07  
			LHP->(dbSkip())
			Loop
		EndIf
	EndIf
	
	//C.Custo
	If AllTrim(Mv_Par08) != "" .Or. AllTrim(Mv_Par09) != ""
		If LHP->LHP_CC < Mv_Par08 .Or. LHP->LHP_CC > Mv_Par09
			LHP->(dbSkip())
			Loop
		EndIf
	EndIf

	//Cidade
	If AllTrim(Mv_Par10) != "" .Or. AllTrim(Mv_Par11) != ""
		If LHP->LHP_CODMUN < Mv_Par10 .Or. LHP->LHP_CODMUN > Mv_Par11 
			LHP->(dbSkip())
			Loop
		EndIf
	EndIf

	//Viagem Avulsa
	If Mv_Par12 == 2 .And. LHP->LHP_Flag == 'B'
		LHP->(dbSkip())
		Loop
	EndIf
	
	//Viagem Nacional
	If Mv_Par13 == 1 .And. LHP->LHP_Einter 
		LHP->(dbSkip())
		Loop
	EndIf

	//Viagem Internacional
	If Mv_Par13 == 2 .And. ! LHP_Einter 
		LHP->(dbSkip())
		Loop
	EndIf
	
	If lFim
		@ Prow()+1,001 PSay STR0008 //'Cancelado pelo Operador!'
		Exit
	EndIf
	
	If Li > 52
		Cabec(cTitulo, cCabec1, cCabec2, cProgram, Tamanho, 15 )  // cabeçalho
		Li:= 8
	EndIf
	_nFirst++
	_lCabec:= .F.
	
	//Posiciona na tabela de despesas
	DbSelectArea('LHR')
	DbSetOrder(1)
	MsSeek(xFilial('LHR') + LHP->LHP_Codigo)
	While !EOF() .And. xFilial('LHR') == LHR->LHR_FILIAL .And. LHP->LHP_CODIGO == LHR->LHR_CODIGO
		If LHR->LHR_MOEDA == 1
			_nDespR += LHR->LHR_VLRTOT
		Else
			_nDespD += LHR->LHR_VLRTOT
		EndIf
		LHR->(DbSkip())
	EndDo

	If _cFuncAnt <> LHP->LHP_Func .And. _nFirst > 1
		@Li,000			PSay STR0009 //'Totais do Colaborador no Período...'
		@Li,109			PSay _nValPrev Picture '@E 9,999,999.99'
		@Li,PCol()+1	PSay _nValReal Picture '@E 9,999,999.99'
		@Li,PCol()+1	PSay _nValPrvD Picture '@E 9,999,999.99'
		@Li,PCol()+2	PSay _nValRlD Picture '@E 9,999,999.99'
		
		@Li,PCol()+1  PSay Transform(_nDiaP ,'@E 999')
		@Li,PCol()+1  PSay Transform(_nDiaR ,'@E 999')
		@Li,PCol()+26 PSay _nVlTHosp Picture '@E 9,999,999.99'
		@Li,PCol()    PSay _nVlTPass Picture '@E 9,999,999.99'
		
		@Li+=3,000    PSay __PrtThinLine()
		
		//Total Geral do Periodo
		_nTValPrev 	+= _nValPrev 
		_nTValReal 	+= _nValReal
		_nTValPrvD	+= _nValPrvD
		_nTValRlD	+= _nValRlD
		_nTDiaP 	+= _nDiaP
		_nTDiaR    	+= _nDiaR
		_nTVlTHosp 	+= _nVlTHosp
		_nTVlTPass 	+= _nVlTPass
	
		_nValPrev	:= 0 
		_nValReal	:= 0 
		_nValPrvD	:= 0
		_nValRlD	:= 0
		_nDiaP   	:= 0 
		_nDiaR		:= 0
		_nVlTHosp	:= 0 
		_nVlTPass 	:= 0

		If Li > 52
			Cabec( cTitulo, cCabec1, cCabec2, cProgram, Tamanho, 15 )  // cabeçalho
			Li:= 8
		EndIf
		_cFuncAnt:= LHP->LHP_Func
		_lCabec:= .T.
	EndIf
	
	If (_cFuncAnt == LHP->LHP_Func .And. _nFirst == 1) .Or. _lCabec
		@Li+=2,000 PSay AllTrim(LHP->LHP_Func) + " - " + SubStr(LHP->LHP_NFunc,1,40)
		Li++
		If Li > 52
			Cabec( cTitulo, cCabec1, cCabec2, cProgram, Tamanho, 15 )  // cabeçalho
			Li:= 8
		EndIf
	EndIf
	
	If Mv_Par05 == 1  // Analitico
		@Li,000      PSay LHP->LHP_Codigo
		@Li,PCol()+2 PSay LHP->LHP_Emiss
		@Li,PCol()+2 PSay LHP->LHP_Saida
		@Li,PCol()+2 PSay LHP->LHP_Chegad
		@Li,PCol()+1 PSay SubStr(LHP->LHP_Local,1,30)
		dbSelectArea('SA1')
		dbSetOrder(1)
		If MsSeek(xFilial('SA1') + LHP->LHP_EmpCli)
			@Li,PCol()+2 PSay SubStr(SA1->A1_Nome,1,40)
		Else
			@Li,PCol()+2 PSay STR0010 //'Cliente não Localizado..................'
		EndIf
/*		dbSelectArea('LHQ')
		dbSetOrder(1)
		MsSeek(xFilial('LHQ') + LHP->LHP_Codigo)*/
		@Li,110   PSay LHP->LHP_ValorR Picture '@E 9,999,999.99'
		@Li,PCol()+1 PSay _nDespR Picture '@E 9,999,999.99'
		@Li,PCol()+1 PSay LHP->LHP_ValorU Picture '@E 9,999,999.99'
		@Li,PCol()+2 PSay _nDespD Picture '@E 9,999,999.99'

		@Li,PCol()+1 PSay Transform(LHP->LHP_Chegad - LHP->LHP_Saida  + 1,'@E 999')
		@Li,PCol()+1 PSay Transform(LHQ->LHQ_DtCheg - LHQ->LHQ_DtSaid + 1,'@E 999')
		@Li,PCol()+4 PSay SubStr(LHP->LHP_CC,1,5)
		@Li,PCol()+4 PSay LHP->LHP_FatMic Picture '999%'
		@Li,PCol()+5 PSay LHP->LHP_FatCli Picture '999%'
		@Li,PCol()   PSay LHP->LHP_VlHosp Picture '@E 9,999,999.99'
		@Li,PCol()   PSay LHP->LHP_VlPass Picture '@E 9,999,999.99'
		Li++
		If Li > 52
			Cabec( cTitulo, cCabec1, cCabec2, cProgram, Tamanho, 15 )  // cabeçalho
			Li:= 8
		EndIf
	EndIf

	//Total por Colaborador
	_nValPrev  	+= LHP->LHP_ValorR
	_nValReal  	+= _nDespR
	_nValPrvD	+= LHP->LHP_ValorU
 	_nValRlD	+= _nDespD

	_nDiaP	   += ( LHP->LHP_Chegad - LHP->LHP_Saida + 1)
	_nDiaR	   += ( LHQ->LHQ_DtCheg - LHQ->LHQ_DtSaid + 1)
	_nVlTHosp  += LHP->LHP_VlHosp 
	_nVlTPass  += LHP->LHP_VlPass
	
	_nDespR := 0
	_nDespD := 0
	
	dbSelectArea(_cAlias)
	dbSetOrder(3)
	IncRegua()
	dbSkip()
EndDo
@Li,000			PSay STR0009 //'Totais do Colaborador no Período...'
@Li,109			PSay _nValPrev Picture '@E 9,999,999.99'
@Li,PCol()+1	PSay _nValReal Picture '@E 9,999,999.99'
@Li,PCol()+1	PSay _nValPrvD Picture '@E 9,999,999.99'
@Li,PCol()+2	PSay _nValRlD Picture '@E 9,999,999.99'

@Li,PCol()+1  PSay Transform(_nDiaP ,'@E 999')
@Li,PCol()+1  PSay Transform(_nDiaR ,'@E 999')
@Li,PCol()+26 PSay _nVlTHosp Picture '@E 9,999,999.99'
@Li,PCol()    PSay _nVlTPass Picture '@E 9,999,999.99'
@++Li,000     PSay __PrtThinLine()

//Total Geral do Periodo
_nTValPrev 	+= _nValPrev 
_nTValReal 	+= _nValReal
_nTValPrvD	+= _nValPrvD
_nTValRlD	+= _nValRlD
_nTDiaP 	+= _nDiaP
_nTDiaR    	+= _nDiaR 
_nTVlTHosp 	+= _nVlTHosp
_nTVlTPass 	+= _nVlTPass

@Li+=3,000		PSay STR0011 //'Total Geral do Período.............'
@Li,109		 	PSay _nTValPrev Picture '@E 9,999,999.99'
@Li,PCol()+1	PSay _nTValReal Picture '@E 9,999,999.99'
@Li,PCol()+1	PSay _nTValPrvD Picture '@E 9,999,999.99'
@Li,PCol()+2	PSay _nTValRlD Picture '@E 9,999,999.99'

@Li   ,PCol()+1  PSay Transform(_nTDiaP ,'@E 999')
@Li   ,PCol()+1  PSay Transform(_nTDiaR ,'@E 999')
@Li   ,PCol()+26 PSay _nTVlTHosp Picture '@E 9,999,999.99'
@Li   ,PCol()    PSay _nTVlTPass Picture '@E 9,999,999.99'
@++Li ,000		  PSay __PrtThinLine()

IF Li != 80
	Li++
	@++Li,000 PSay Repl("*",220)
	Roda(cbcont,cbtxt,Tamanho)
EndIf

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	OurSpool( wnrel )
Endif

MS_FLUSH()

Return
