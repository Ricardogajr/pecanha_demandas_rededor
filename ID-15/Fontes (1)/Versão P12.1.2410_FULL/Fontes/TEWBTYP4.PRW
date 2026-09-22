#Include 'Protheus.ch'
#Include 'TopConn.Ch'
#include "fwmvcdef.ch"

/*
{Protheus.doc} TEWBTYP4
Geração de arquivo cnab automático. 
@Author     Ramon Teodoro e Silva
@Since      26/10/2020     
@Version    P12.27
@Return
*/
User Function TEWBTYP4
              
Local lRet     := .T.
Local aArea    := GetArea()
Local aSays    := {}
Local cFile    := ""

Private oDlgTela 
Private oTexto
Private cTexto   := ""
Private cLogName := ""

If !DtMovFin(,,"1")
	Return
Endif	

Pergunte("TEWBTYP4",.F.)
nOpca := 0

Aadd(aSays, "Esta rotina gera os arquivo de comunicação bancária CNAB de forma automática.")		    
Aadd(aSays, "Com os dados de entrada informados nos parâmetros, o sistema irá selecionar os bancos,")
Aadd(aSays, "borderôs e títulos para cada filial, montando um arquivo por vez de forma automática.")	   

DEFINE MSDIALOG oDlgTela TITLE "Cnab Automático" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL
//@ 227, 001 GROUP oGroup1 TO 246, 246 OF oDlgTela COLOR 0, 16777215 PIXEL
@ 002, 002 GROUP oGroup1 TO 030,246 OF oDlgTela COLOR 0, 16777215 PIXEL
@ 004, 008 SAY oSay01 PROMPT aSays[1]	 	 SIZE 230, 012 OF oDlgTela COLORS 0, 16777215 PIXEL
@ 012, 008 SAY oSay02 PROMPT aSays[2]	 	 SIZE 230, 012 OF oDlgTela COLORS 0, 16777215 PIXEL
@ 020, 008 SAY oSay03 PROMPT aSays[3]	 	 SIZE 230, 012 OF oDlgTela COLORS 0, 16777215 PIXEL
@ 034, 002 GET oTexto VAR cTexto OF oDlgTela MULTILINE SIZE 246, 190 COLORS 0, 16777215 HSCROLL PIXEL READONLY
@ 228, 002 GROUP oGroup1 TO 246, 246 OF oDlgTela COLOR 0, 16777215 PIXEL
@ 232, 083 BUTTON oButton1 PROMPT "Executar" SIZE 037, 012 OF oDlgTela ACTION CnabGAuto() PIXEL
@ 232, 123 BUTTON oButton1 PROMPT "Parâmetros" SIZE 037, 012 OF oDlgTela ACTION Pergunte("TEWBTYP4",.T. )  PIXEL
@ 232, 163 BUTTON oButton1 PROMPT "Salvar Log" SIZE 037, 012 OF oDlgTela ACTION (cFile:=cGetFile( cLogName,"Salvar Log",,'C:\',.T.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY),.F.,.F.),If(cFile="",.t.,MemoWrite(cFile,cTexto))) PIXEL 
@ 232, 203 BUTTON oButton2 PROMPT "Sair" SIZE 037, 012 OF oDlgTela ACTION oDlgTela:End() PIXEL    
ACTIVATE MSDIALOG oDlgTela CENTERED

RestArea(aArea)
Return lRet

/*
{Protheus.doc} CnabGAuto
Geração de arquivo cnab automático. 
@Author     Ramon Teodoro e Silva
@Since      26/10/2020     
@Version    P12.27
@Return
*/
Static Function CnabGAuto()
    
Local lRet    := .T.
//Local aArea   := GetArea()
Local cQuery  := ""
Local aSBcos  := {}
Local nT      := 0
Local aSelFil := {}
Local cBorDe  := mv_par01
Local cBorAte := mv_par02
Local cCodBco := mv_par03
Local cArqCfg := mv_par04
//Local cDirArq := mv_par05
Local nModelo := mv_par05
Local nSelFil := mv_par10

Private nHdlBco :=0,nHdlSaida:=0,nSeq:=0,cBanco,cAgencia,nSomaValor := 0
Private nSomaCGC:=0,nSomaData:=0
Private xConteudo
Private nTotCnab2  := 0 // Contador de Lay-out nao deletar
Private nLinha     := 0 // Contador de LINHAS, nao deletar
Private nSomaVlLote:= 0
Private nQtdTotTit := 0
Private nQtdTitLote:= 0
Private nQtdLinLote:= 0
Private nTotLinArq := 0
Private nLotCnab2  := 1		//Contador de lotes do CNAB2

Private mv_par01
Private mv_par02
Private mv_par03
Private mv_par04
Private mv_par05
Private mv_par06
Private mv_par07
Private mv_par08
Private mv_par09
Private mv_par10
Private mv_par11
Private mv_par12
Private mv_par13
Private mv_par14

If nSelFil == 1
	aSelFil := AdmGetFil(.T.,.F.,"SE2")
Else
	aSelFil := {cFilAnt}
Endif

cTexto += "==========================================================================="+Chr(13)+Chr(10)
cTexto += TIME()+" <=== Processamento inciado" +Chr(13)+Chr(10)
cTexto += "==========================================================================="+Chr(13)+Chr(10)
oTexto:Refresh()   
oTexto:GoEnd() 
oDlgTela:Refresh()

//Seleção das filiais e bancos a serem considerados, dentro do intervalo de borderôs
cQuery := "SELECT DISTINCT SEA.EA_FILIAL, SEA.EA_PORTADO, SEA.EA_AGEDEP, SEA.EA_NUMCON, SEE.EE_SUBCTA FROM " + RetSqlName("SEA") + " SEA"
cQuery += " INNER JOIN " + RetSqlName("SEE") + " SEE ON"
cQuery += " SEA.EA_PORTADO = SEE.EE_CODIGO AND "
cQuery += " SEA.EA_AGEDEP = SEE.EE_AGENCIA AND "
cQuery += " SEA.EA_NUMCON = SEE.EE_CONTA AND "
cQuery += " SEE.D_E_L_E_T_ = ''"
If nSelFil == 1
	cQuery += " WHERE SEA.EA_FILIAL " + GetRngFil( aSelFil, "SEA", .T., "" ) + " AND "
Else 
	cQuery += " WHERE "
EndIf
cQuery += " SEA.EA_PORTADO = '" + cCodBco + "' AND"
cQuery += " SEA.EA_NUMBOR >= '" + cBorDe + "' AND SEA.EA_NUMBOR <= '" + cBorAte + "' AND "
cQuery += " SEE.EE_PERMPG ='1' AND SEA.D_E_L_E_T_ = ''"  
cQuery += " ORDER BY SEA.EA_FILIAL , SEA.EA_PORTADO"
cQuery := ChangeQuery(cQuery)
cAliasBcos := GetNextAlias() 
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBcos,.F.,.T.)

cTexto += "Filiais e bancos selecionados: "+Chr(13)+Chr(10)
oTexto:Refresh()   
oTexto:GoEnd() 
oDlgTela:Refresh() 

While !(cAliasBcos)->(Eof())
	cTexto += (cAliasBcos)->EA_FILIAL + " - Banco: " + (cAliasBcos)->EA_PORTADO + "  Ag: " + (cAliasBcos)->EA_AGEDEP + "  CC: " + (cAliasBcos)->EA_NUMCON + Chr(13)+Chr(10)
	Aadd(aSBcos, { (cAliasBcos)->EA_FILIAL, (cAliasBcos)->EA_PORTADO, (cAliasBcos)->EA_AGEDEP, (cAliasBcos)->EA_NUMCON, (cAliasBcos)->EE_SUBCTA })
	(cAliasBcos)->(DbSkip())
End

If Empty(aSBcos)
	cTexto += " Não existem bancos configurados para os borderôs e filiais parâmetrizadas "
EndIf

oTexto:Refresh()   
oTexto:GoEnd() 
oDlgTela:Refresh() 

(cAliasBcos)->(DbCloseArea())

For nT := 1 to Len(aSBcos)

	//Intervalo de borderôs por filial e banco+agencia+conta
	cQuery := "SELECT  MIN(EA_NUMBOR) AS BORMIN, MAX(EA_NUMBOR) AS BORMAX FROM " + RetSqlName("SEA") 
	If nSelFil == 1
		cQuery += " WHERE EA_FILIAL " + GetRngFil( aSelFil, "SEA", .T., "" ) + " AND "
	Else 
		cQuery += " WHERE "
	EndIf
	cQuery += " EA_NUMBOR >= '" + cBorDe + "' AND EA_NUMBOR <= '" + cBorAte + "' AND "
	cQuery += " EA_PORTADO = '" + aSBcos[nT][2] + "' AND "
	cQuery += " EA_AGEDEP = '" + aSBcos[nT][3] + "' AND "
	cQuery += " EA_NUMCON = '" + aSBcos[nT][4] + "' AND D_E_L_E_T_ = ' '  
	cQuery := ChangeQuery(cQuery)
	cAliasTmp := GetNextAlias() 
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)

	If (cAliasTmp)->(Eof())
		(cAliasTmp)->(DbCloseArea())
		Return	
	EndIf

	cFilAnt := aSBcos[nT][1]

	OpenSM0(FwCodEmp()+cFilAnt, .T.)

	cTexto += "==========================================================================="+Chr(13)+Chr(10)
	cTexto += "Preparando arquivo para a filial " + cFilant + Chr(13)+Chr(10)
	cTexto += "Borderô do nº " + (cAliasTmp)->BORMIN + " ao " + (cAliasTmp)->BORMAX + Chr(13)+Chr(10)
	oTexto:Refresh()   
	oTexto:GoEnd() 
	oDlgTela:Refresh() 

	cArqName := Soma1(Pad(MVGetCus("FS_XNUMARQ"),6),6)
	
	While !MayIUseCode( "PZC_ARQUIV"+FwFilial("SX6")+cArqName)  //verifica se esta na memoria, sendo usado
		cArqName := Soma1(cArqName)										// busca o proximo numero disponivel 
	End
	
	cDirArq := Alltrim(MVSGetCus( "FS_XDIRARQ" ,cFilant))
	
	mv_par01 := (cAliasTmp)->BORMIN
	mv_par02 := (cAliasTmp)->BORMAX	
	mv_par03 := cArqCfg
	//mv_par04 := IIf( SubStr(cDirArq, Len(cDirArq), 1) == "/", cDirArq, cDirArq+"/") + cArqName //cDirArq
	If At("\", cDirArq) > 0
		mv_par04 := IIf( SubStr(cDirArq, Len(cDirArq), 1) == "\", cDirArq, cDirArq+"\") + cArqName
	ElseIf At("/", cDirArq) > 0
		mv_par04 := IIf( SubStr(cDirArq, Len(cDirArq), 1) == "/", cDirArq, cDirArq+"/") + cArqName
	EndIf
	mv_par05 := aSBcos[nT][2]
	mv_par06 := aSBcos[nT][3]
	mv_par07 := aSBcos[nT][4]
	mv_par08 := aSBcos[nT][5] 
	mv_par09 := nModelo 
	mv_par10 := 2 
    mv_par11 := ''  
	mv_par12 := '' 
	mv_par13 := 0 
	mv_par14 := 2 
					
	If !File(cDirArq)
		MsgAlert("Diretório para filial :" + cFilAnt + " não existe ou está vazio, verifique o parâmetro FS_XDIRARQ", "Diretório não existe")
		cTexto += "ALERTA: Diretório para filial :" + cFilAnt + " não existe ou está vazio, verifique o parâmetro FS_XDIRARQ" +Chr(13)+Chr(10)
		oTexto:Refresh()   
		oTexto:GoEnd() 
		oDlgTela:Refresh()
	Else

		cTexto += "==========================================================================="+Chr(13)+Chr(10)
		cTexto += TIME()+" <=== Iniciando a geração do arquivo CNAB" +Chr(13)+Chr(10)
		oTexto:Refresh()   
		oTexto:GoEnd() 
		oDlgTela:Refresh()

		Fa420Ger("SE2")

		cTexto += "==========================================================================="+Chr(13)+Chr(10)
		cTexto += TIME()+" <=== Arquivo '" + cArqName + "' gerado com sucesso para empresa " + cFilAnt + Chr(13)+Chr(10)
		oTexto:Refresh()   
		oTexto:GoEnd() 
		oDlgTela:Refresh()

		_cMvNumArq := MVGetCus("FS_XNUMARQ")
		If _cMvNumArq < cArqName
			PutMv("FS_XNUMARQ",cArqName)
		EndIf
	EndIf

Next nT

cTexto += "==========================================================================="+Chr(13)+Chr(10)
cTexto += TIME()+" <=== Fim do processo "  + Chr(13)+Chr(10)
cTexto += "==========================================================================="+Chr(13)+Chr(10)
oTexto:Refresh()   
oTexto:GoEnd() 
oDlgTela:Refresh()

cLogName := "LOG_CNABAUTO-"+dtos(dDATABASE)+"-"+REPLACE(TIME(),":","-")+".TXT" 

//RestArea(aArea)
Return lRet 
Static Function MVSGetCus(cParam1, cParam2)
Return SuperGetMv(cParam1, .F. , .F.,cParam2)

Static Function MVGetCus(cParam1)
Return GetMv(cParam1)
