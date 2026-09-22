#include "protheus.ch"
#INCLUDE "TopConn.Ch"
#INCLUDE "FONT.CH"      
#INCLUDE "FILEIO.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RDOR013B บAutor  ณWellington Tonieto  บ Data ณ  17/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFluxo de caixa por Natureza (Realizado) - Diario            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RDOR013B()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 130
Private tamanho      := "M"
Private nomeprog     := "RDOR013B"
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := Padr("RDOR13B",10)
Private cbtxt        := Space(10)
Private m_pag        := 01
Private wnrel        := "RDOR013B"
Private aSx1         := {}
Private _aStruct     := {}
Private cString      := "SE2"
Private _cInd2       := CriaTrab(Nil, .F.)
Private  cCab2       := "NATUREZA     FORNECEDOR                          DOCUMENTO       C.CUSTO     REALIZADO       PREVISTO       ATRASADO "
Private nBancos      := 0
Private nEmprestimo  := 0
Private nAplicacao   := 0
Private _cArq
Private cLinha
Private nHandle
Private cFilePath
Private _cPathRl := SuperGetMv("MV_XEXCELL",,"C:\TOTVS_REL\")

Processa({|| LISTARMN() },"Processando...")

RETURN

STATIC FUNCTION ACERTAMN(_cNFisc)

// 11/05/2010 - acerto percentuais dos titulos de multnaturezas na SEV

// ACERTAR Multinatureza
DBSELECTAREA("SEV")
DBSETORDER(1)
DBSELECTAREA("SE2")
DBSETORDER(1)
ProcRegua(RECCOUNT())  // 02/06/2008 - Noronha
DBGOTOP()
DBSEEK(XFILIAL("SE2")+_cNFisc)
DO WHILE !EOF() .AND. SE2->E2_PREFIXO+SE2->E2_NUM = _cNFisc

	IncProc()

//   IF SE2->E2_VENCTO < CTOD("31/12/08")
//   	DBSKIP()
//   	LOOP
//   ENDIF
	CCHAVE := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
   CPREF  := SE2->E2_PREFIXO
   CNUM   := SE2->E2_NUM
	CFORN  := SE2->E2_FORNECE+SE2->E2_LOJA   
	CPARC  := SE2->E2_PARCELA
	NVAL   := SE2->E2_VALOR
	nTotPc := 0
	DBSELECTAREA("SEV")
   DBSEEK(XFILIAL("SEV")+CPREF+CNUM)
   IF FOUND()     
	   nValMN := 0     
	   nRegMN := RECNO()
		DO WHILE !EOF() .AND. CPREF = SEV->EV_PREFIXO .AND. CNUM = SEV->EV_NUM //+SEV->EV_PARCELA+SEV->EV_TIPO+SEV->EV_CLIFOR+SEV->EV_LOJA
	      If SEV->EV_PARCELA = CPARC .and. SEV->EV_CLIFOR+SEV->EV_LOJA = CFORN
	         nValMN := nValMN + SEV->EV_VALOR 
	         nTotPc += SEV->EV_PERC
	      Endif
         DBSKIP()
      ENDDO   
		IF nValMN > 0
			nAjustMN :=	NVAL - nValMN
			If ABS(nAjustMN) <> 0
				DbSelectArea("SEV")
				dbgoto(nRegMN)
			   Do While !EOF() .and. CPREF = SEV->EV_PREFIXO .AND. CNUM = SEV->EV_NUM
		   	   If SEV->EV_PARCELA = CPARC .and. SEV->EV_CLIFOR+SEV->EV_LOJA = CFORN
		      	   Exit
			      Endif
			      dbskip()
	   		Enddo

				IncProc(cchave+" " +str(nAjustMN))

				Reclock("SEV",.F.)
				SEV->EV_VALOR	+= nAjustMN
				SEV->EV_PERC	:= SEV->EV_VALOR/NVAL
				SEV->EV_SITUACA:= "X"
	      	Msunlock()
// 01/06/2010 - Noronha
	      ElseIf nTotPc <> 1.0000000
				DbSelectArea("SEV")
				dbgoto(nRegMN)
				nTotPc2 := 0
				Do While !EOF() .AND. CPREF = SEV->EV_PREFIXO .AND. CNUM = SEV->EV_NUM 
			      If SEV->EV_PARCELA = CPARC .and. SEV->EV_CLIFOR+SEV->EV_LOJA = CFORN
						Reclock("SEV",.F.)
						SEV->EV_PERC    := SEV->EV_VALOR/NVAL
						SEV->EV_SITUACA := "P"
			      	Msunlock()
			      	nTotPc2 += SEV->EV_PERC
			      Endif
		         Dbskip()
		      Enddo 
//	
			ENDIF
      Endif
   ENDIF
	DbSelectArea("SE2")
	DBSKIP()
ENDDO
RETURN
//

STATIC FUNCTION LISTARMN

Local cDesc1         := "Fluxo de caixa Analitico por Natureza (Realizado)"
Local cDesc2         := ""
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := "Fluxo de caixa Analitico por Natureza (Realizado)"
Local nLin           := 80

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}
Private oTempTable //Thais Paiva - 11552136

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a Tela de parametros do relatorio ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Aadd(aSx1,{"GRUPO","ORDEM","PERGUNT"               ,"VARIAVL","TIPO","TAMANHO","DECIMAL","GSC","VALID","VAR01"   ,"F3","DEF01"  ,"DEF02" ,"DEF03" ,"DEF04"  ,"DEF05"})
Aadd(aSx1,{cPerg  ,"01"   ,"Periodo De              ?","mv_ch1" ,"D"   ,08       ,0        ,"G"  ,""     ,"mv_par01",""   ,""      ,""      ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"02"   ,"Periodo Ate             ?","mv_ch2" ,"D"   ,08       ,0        ,"G"  ,""     ,"mv_par02",""   ,""      ,""      ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"03"   ,"Natureza De             ?","mv_ch3" ,"C"   ,10       ,0        ,"G"  ,""     ,"mv_par03","SED",""      ,""      ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"04"   ,"Natureza Ate            ?","mv_ch4" ,"C"   ,10       ,0        ,"G"  ,""     ,"mv_par04","SED",""      ,""      ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"05"   ,"Compoe Saldo retroativo ?","mv_ch5" ,"C"   ,01       ,0        ,"C"  ,""     ,"mv_par05",""   ,"Nao","Sim" ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"06"   ,"Considera Provisorios   ?","mv_ch6" ,"C"   ,01       ,0        ,"C"  ,""     ,"mv_par06",""   ,"Sim","Nao" ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"07"   ,"Considera banco         ?","mv_ch7" ,"C"   ,01       ,0        ,"C"  ,""     ,"mv_par07",""   ,"Nao","Sim" ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"08"   ,"Banco                   ?","mv_ch8" ,"C"   ,03       ,0        ,"G"  ,""     ,"mv_par08","SA6","","" ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"09"   ,"Agencia                 ?","mv_ch9" ,"C"   ,07       ,0        ,"G"  ,""     ,"mv_par09",""   ,"","" ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"10"   ,"Conta Corrente          ?","mv_cha" ,"C"   ,10       ,0        ,"G"  ,""     ,"mv_par10",""   ,"","" ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"11"   ,"Gera em Excell          ?","mv_chb" ,"C"   ,01       ,0        ,"C"  ,""     ,"mv_par11",""   ,"Nao","Sim" ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"12"   ,"Considera data          ?","mv_chc" ,"C"   ,01       ,0        ,"C"  ,""     ,"mv_par12",""   ,"Baixa","Disponivel" ,""      ,""       ,""     })
Aadd(aSx1,{cPerg  ,"13"   ,"Filial de               ?","mv_chD" ,"C"   ,08       ,0        ,"G"  ,""     ,"mv_par13","SM0",""     ,"" ,""       ,""       ,""     })
Aadd(aSx1,{cPerg  ,"14"   ,"Filial Ate              ?","mv_chE" ,"C"   ,08       ,0        ,"G"  ,""     ,"mv_par14","SM0",""     ,"" ,""       ,""       ,""     })
Aadd(aSx1,{cPerg  ,"15"   ,"Multiplas Naturezas     ?","mv_chF" ,"C"   ,01       ,0        ,"C"  ,""     ,"mv_par15","   ","Sim"  ,"Nao" ,""       ,""       ,""     })


//fCriaSX1(cPerg,aSX1) Thais Paiva - Compatibiliza็ใo P27

If !Pergunte(cPerg,.T.)
	Return
Endif

_dDataDe     := MV_PAR01
_dDataAte    := MV_PAR02
_cNatDe      := MV_PAR03
_cNatAte     := MV_PAR04
_nCompSaldo  := MV_PAR05
_nProv       := MV_PAR06
_nFtBanco    := MV_PAR07
_cBanco      := MV_PAR08
_cAgencia    := Substr(MV_PAR09,1,5)
_cConta      := MV_PAR10
_GrExcell    := MV_PAR11
_dDataMov    := MV_PAR12
_cFilDe      := MV_PAR13
_cFilAte     := MV_PAR14
_cBsMultNat  := MV_PAR15 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea("SE2")
dbSetOrder(1)

DbSelectArea("SE1")
DbSetOrder(1)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Processa( {|| MontaRel() }, "Em Processamento..." )
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

oTempTable:Delete() //Thais Paiva - 11552136

IF Select("TRB1")>0
	DbSelectArea("TRB1")
	DbCloseArea()
ENDIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMONTAREL  บAutor  ณWellington Tonieto  บ Data ณ  16/09/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera arquivos de Trabalho com os Titulos Pagos e Nao Pagos  บฑฑ
ฑฑบ          ณdo Ctas a Pagar.                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณASOEC                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*************************
Static Function MontaRel()
*************************

Private  cRecPagAnt := FormatIn( MVPAGANT, "/" )
Private  _nDay      := (_dDataAte - _dDataDe) + 1  // 18/06/2010 - Noronha


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Crio tabela temporaria para acumular valores ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(_aStruct, {"FL_MOVE"          , "C", 02, 0})
AADD(_aStruct, {"PREFIXO"          , "C", 03, 0})
AADD(_aStruct, {"NUMERO "          , "C", 09, 0})
AADD(_aStruct, {"PARCELA"          , "C", 01, 0})
AADD(_aStruct, {"TIPO   "          , "C", 03, 0})
AADD(_aStruct, {"CLIFOR "          , "C", 06, 0})
AADD(_aStruct, {"NOME   "          , "C", 30, 0})
AADD(_aStruct, {"LOJA   "          , "C", 02, 0})
AADD(_aStruct, {"DATAMV "          , "D", 08, 0})
AADD(_aStruct, {"NATUREZA"         , "C", 10, 0})
AADD(_aStruct, {"DESCRI "          , "C", 40, 0})
AADD(_aStruct, {"VL_PREV"          , "N", 16, 2})
AADD(_aStruct, {"VL_ATRZ"          , "N", 16, 2})
AADD(_aStruct, {"VL_REAL"          , "N", 16, 2})
AADD(_aStruct, {"TP"               , "C", 01, 0})
AADD(_aStruct, {"TPDOC"            , "C", 03, 0})
AADD(_aStruct, {"CCUSTO"           , "C", 09, 0})

// Cria o arquivo com a estrutura da consulta
//Inํcio - Thais Paiva - Compatibiliza็ใo P27
//_cArq := CriaTrab(_aStruct,.T.)
_cArq := GetNextAlias() //Thais Paiva - 10041495
oTempTable := FWTemporaryTable():New( "TRB1" )

IF Select("TRB1") > 0
	DbSelectArea("TRB1")
	DbCloseArea()
ENDIF

//dbUseArea(.T.,__LocalDriver,_cArq, "TRB1",.T.)
//IndRegua ("TRB1",_cArq,"FL_MOVE+PREFIXO+NUMERO+PARCELA+TIPO",,,OemToAnsi("Selecionando Registros..."))
//IndRegua ("TRB1",_cArq,"FL_MOVE+TPDOC+DTOS(DATAMV)+NATUREZA+PREFIXO+NUMERO+PARCELA+TIPO+CLIFOR+LOJA",,,OemToAnsi("Selecionando Registros..."))
oTemptable:SetFields( _aStruct )
//oTempTable:AddIndex( '01' , { "FL_MOVE" , "TPDOC" , "DTOS(DATAMV)" , "NATUREZA" , "PREFIXO" , "NUMERO" , "PARCELA" , "TIPO" , "CLIFOR" , "LOJA"} ) Thais Paiva - 10041495
oTempTable:AddIndex( '01' , { "FL_MOVE" , "TPDOC" , "DATAMV" , "NATUREZA" , "PREFIXO" , "NUMERO" , "PARCELA" , "TIPO" , "CLIFOR" , "LOJA"} ) 
oTempTable:Create()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a Disponibilidade Financeira                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SM0")
dbSetOrder(1)
dbSeek(cEmpAnt+_cFilDe,.T.)

cSavFil  := cFilAnt
aAreaSM0 := SM0->(GetArea())

While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. SM0->M0_CODFIL <= _cFilAte
	cFilAnt := SM0->M0_CODFIL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se existe Operacao Financeira a ser resgatada no dia ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea("SEH")
If !Empty(xFilial("SEH")) .Or. (Empty(xFilial("SEH")))
	dbSetOrder(2)
	dbSeek(_cFilDe+"A",.T.)
	While ( !Eof() .And. ( SEH->EH_FILIAL >= _cFilDe  .And. SEH->EH_FILIAL <= _cFilAte ).And. SEH->EH_STATUS == "A" )
		aCalc := Fa171Calc(dDataBase+_nDay)
		If ( SEH->EH_APLEMP == "EMP" )
			nEmprestimo += xMoeda(aCalc[2,1],1,1)
		Else
			nAplicacao += xMoeda(aCalc[1],1,1)
		EndIf
		dbSelectArea("SEH")
		dbSkip()
	EndDo
	dbSelectArea("SEH")
	dbSetOrder(1)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica disponibilidade banc ria                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

IF _nFtBanco == 2 // Considerar Banco Informado nos parametros
   DbSelectArea("SA6")
   DbSetOrder(1)
   If DbSeeK(_cFilDe +_cBanco+_cAgencia+_cConta)
   	If SA6->A6_FLUXCAI <> "N"
   	  While !eof() .And. ( SA6->(A6_COD+A6_AGENCIA+A6_NUMCON) == _cBanco+_cAgencia+_cConta ) .And. ;
   	                     (  SA6->A6_FILIAL >= _cFilDe .And. SA6->A6_FILIAL <= _cFilAte )
   	                     
   			nBancos += RecSalBco(SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON,(dataValida(_dDataDe) -1))
			   dbSelectArea("SA6")
			   dbSkip()
		  Enddo
	   Endif
   Endif
Else		
	If !Empty(xFilial("SA6")) .Or. (Empty(xFilial("SA6")))
		dbSelectArea("SA6")
		dbSeek(_cFilDe)
		While ! Eof() .And. SA6->A6_FILIAL == xFilial("SA6") 
			If SA6->A6_FLUXCAI <> "N"
				nBancos += RecSalBco(SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON,(dataValida(_dDataDe) -1))
			EndIf
			dbSelectArea("SA6")
			dbSkip()
		Enddo
	Endif
Endif

dbSelectArea("SM0")
dbSkip()
EndDo

cFilAnt := cSavFil
SM0->(RestArea(aAreaSM0))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ CRIA ARQUIVOS COM OS DADOS DO RELATORIO       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

MsgRun("Aguarde... Calculando recebimentos previstos...","RDOR013B",{|| fMontaTrb("SE1")})
MsgRun("Aguarde... Calculando pagamentos previstos...  ","RDOR013B",{|| fMontaTrb("SE2")})
MsgRun("Aguarde... Calculando realizados...            ","RDOR013B",{|| fMontaReal()})     // REALIZADO

If _GrExcell == 2

	//IF Empty(_cPathRl)
	//   _cPathRl := "C:\TOTVS_REL\"
	//Endif
	
	cFilePath := _cPathRl+_cArq+".CSV"
	
	If !lIsdir (_cPathRl)
	    MakeDir(_cPathRl)
	EndIf
	
	nHandle := FCreate(cFilePath, FC_NORMAL)
	
	If nHandle == -1
		MSGINFO("Arquivo nao pode ser criado. Erro #" + AllTrim(Str(FError())))
		Return
	EndIf

    cLinha := "FILIAL;PREFIXO;NUMERO;PARCELA;TIPO;CLI/FOR;NOME;LOJA;DATA;NATUREZA;DESCRICAO;PREVISTO;ATRASADO;REALIZADO;TIPO;DOC;C.CUSTO"
    FWrite(nHandle, cLinha+CRLF)

Endif

//oTempTable:Delete() //Thais Paiva - 04/12/2020 - Thais Paiva - 11552136

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRDOR012   บAutor  ณMicrosiga           บ Data ณ  09/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

******************************
Static Function fMontaTrb(cAlias)
******************************

Local cQuery    := " "
Local cTpMov    := If(cAlias == "SE1","E","S")
Local dDataTrab ,;
nX		    	    ,;
aSaldo          ,;
cTipo      := If(Upper(cAlias)=="SE1", MVRECANT+"/"+MV_CRNEG, MVPAGANT+"/"+MV_CPNEG),;
cCampo     := Right(cAlias,2),;
lMvMultNat := &("MV_MULNAT"+If(cAlias == "SE1","R","P"))
cAliasTmp  := "_TN"

cQuery := "SELECT "  //SubStr(cQuery,3,Len(cQuery)-1)
cQuery += cAlias + "." + cCampo + "_FILIAL,"
cQuery += cAlias + "." + cCampo + "_PREFIXO,"
cQuery += cAlias + "." + cCampo + "_NUM,"
cQuery += cAlias + "." + cCampo + "_PARCELA,"
cQuery += cAlias + "." + cCampo + "_TIPO,"

If cAlias == "SE1"
	cQuery += cAlias + "." + cCampo + "_CLIENTE,"
Else
	cQuery += cAlias + "." + cCampo + "_FORNECE,"
Endif

cQuery += cAlias + "." + cCampo + "_LOJA,"
cQuery += cAlias + "." + cCampo + "_VENCREA,"
cQuery += cAlias + "." + cCampo + "_MULTNAT,"
cQuery += cAlias + "." + cCampo + "_NATUREZ,"
cQuery += cAlias + "." + cCampo + "_TXMOEDA,"
cQuery += cAlias + "." + cCampo + "_MOEDA  ,"
cQuery += cAlias + "." + cCampo + "_VALOR  ,"
cQuery += cAlias + "." + cCampo + "_SALDO  ,"
cQuery += cAlias + "." + cCampo + "_BAIXA  ,"
cQuery += cAlias + "." + cCampo + "_SDACRES,"
cQuery += cAlias + "." + cCampo + "_SDDECRE,"
cQuery += cAlias + "." + cCampo + "_FILORIG,"
cQuery += cAlias + "." + cCampo + If(Upper(cAlias)=="SE1","_CCC","_CCD")+","

If cAlias == "SE1"
   cQuery += cAlias + "." + cCampo + "_NOMCLI,"
Else
   cQuery += cAlias + "." + cCampo + "_NOMFOR,"
ENdif

cQuery += " CASE "
cQuery += " WHEN "   + cAlias + "." + cCampo + "_VENCREA <  '" + dTos(dDataBase) + "' AND "
cQuery +=        "(" + cAlias + "." + cCampo + "_BAIXA   >  '" + dTos(dDataBase) + "' OR  "
cQuery +=            + cAlias + "." + cCampo + "_BAIXA   = ' ' ) THEN 'A' ELSE             "
cQuery +="CASE WHEN "+ cAlias + "." + cCampo + "_VENCREA >  '" + dTos(dDataBase) + "' AND "
cQuery +=              cAlias + "." + cCampo + "_SALDO   > 0 THEN  'R' END END TP_STATUS   "
cQuery +=         ",R_E_C_N_O_ RECNO "
cQuery += "FROM "+RetSqlName(cAlias)+ " "+ cAlias + " "
cQuery += "WHERE "
cQuery += cAlias + "." + cCampo + "_FILIAL BETWEEN  '" + _cFilDe + "' AND '" + _cFilAte + "' AND "
cQuery += "("+cAlias + "." + cCampo + "_MULTNAT = '1' OR ("
cQuery += cAlias + "." + cCampo + "_NATUREZ BETWEEN '"+_cNatDe+"' AND '"+_cNatAte+"' AND "
cQuery += cAlias + "." + cCampo + "_NATUREZ <>      '"+Space(Len((cAlias)->&(cCampo+"_NATUREZ")))+"')) AND "
cQuery += cAlias + "." + cCampo + "_EMISSAO <=      '"+Dtos(dDataBase)+"' AND "
//cQuery += cAlias + "." + cCampo + "_VENCREA <= '"+Dtos(dUltData)+"' AND "
cQuery += cAlias + "." + cCampo + "_VENCREA BETWEEN '" + dTos(_dDataDe) + "' And  '" + dTos(_dDataAte) + "' AND "
cQuery += cAlias + "." + cCampo + "_TIPO  NOT IN "     + FormatIn(MV_CRNEG+"/"+MVRECANT+"/"+MVABATIM,"/")+ "  AND "

If cAlias == "SE1"
	cQuery += cAlias + "." + cCampo + "_SITUACA NOT IN ('2','7') AND "
Endif

If ( _nCompSaldo == 1 )
	cQuery += cAlias + "." + cCampo + "_SALDO <> 0 AND "
EndIf

If _nProv  == 2
	cQuery += cAlias + "." + cCampo + "_TIPO <> 'PR' AND "
Endif

/*
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNao considerar titulos gerados a partir de uma FATURA para ณ
//ณnao duplicar a demonstra็ใo.                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
*/
cQuery += "NOT (" + cAlias + "." + cCampo + "_FATURA <> ' ' AND " + cAlias + "." + cCampo + "_FATURA <> 'NOTFAT' AND " + cAlias + "." + cCampo  + "_DTFATUR <= '" + DTOS(dDataBase) + "') AND "
cQuery += cAlias + "." + cCampo + "_FLUXO <> 'N' AND "
cQuery += cAlias + ".D_E_L_E_T_=' ' "

cQuery := ChangeQuery(cQuery)
//MemoWrite("c:\query.txt",cQuery)
MemoWrite("c:\fMontaTrb_13B_"+cAlias+".txt",cQuery)

IF Select(cAliasTmp)>0
	DbSelectArea(cAliasTmp)
	DbCloseArea()
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .T.)

DbSelectArea(cAliasTmp)
DbGoTop()

Do While ( !Eof() )
	
	//FILTRAR TITULOS 'PR' BAIXADOS PELO PROGRAMA DE IMPORTACAO WPD.
	If (cAliasTmp)->&(cCampo+"_TIPO") == 'PR ' .And. (cAliasTmp)->&(cCampo+"_BAIXA") <> ' '
		If !(_nCompSaldo == 2 .And. sTod((cAliasTmp)->&(cCampo+"_BAIXA")) < dDataBase)
			DbSkip()
			Loop
		Endif
	Endif
	
	IF (cAliasTmp)->&(cCampo+"_SALDO") > (cAliasTmp)->&(cCampo+"_VALOR")//CORRIGIR ERRO NAS IMPORTACOES , DEPOIS DE AJUSTADO
		DbSkip()                                                           // ESTE TESTE PODERA SER RETIRADO PARA GANHAR PERFORMACE.
 		Loop
	Endif
	
	If _cBsMultNat == 1 // Considera Multiplas Naturezas
		If lMvMultnat .And. (cAliasTmp)->&(cCampo+"_MULTNAT") == "1"
		   If !PesqNatSev(cAliasTmp,cCampo, _cNatDe, _cNatAte)
				DbSkip()
				Loop
			Endif	
		Endif
   Endif
		
	(cAlias)->(DbGoto((cAliasTmp)->RECNO))

	aSaldo := SdoTitNat((cAliasTmp)->&(cCampo+"_PREFIXO"),;
							  (cAliasTmp)->&(cCampo+"_NUM")    ,;
							  (cAliasTmp)->&(cCampo+"_PARCELA"),;
							  (cAliasTmp)->&(cCampo+"_TIPO")   ,;
							  (cAliasTmp)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE")),;
							  (cAliasTmp)->&(cCampo+"_LOJA"),  ,;
					 		  If(cAlias=="SE1","R","P")        ,;
							  cAliasTmp                        ,;
							  1                                ,;
							  _nCompSaldo == 2)
			
			
	  For nX := 1 To Len(aSaldo)
			
			 If  Abs(aSaldo[nX][2]) > 0.0001 .And.;
			     aSaldo[nX][1] >= _cNatDe    .And.;
			     aSaldo[nX][1] <= _cNatAte
				
			   DbSelectArea("TRB1")
				TRB1->(RecLock("TRB1",.T.))
				TRB1->TP       :=  cTpMov
				TRB1->FL_MOVE  := (cAliasTmp)->&(cCampo+"_FILIAL")
				TRB1->PREFIXO  := (cAliasTmp)->&(cCampo+"_PREFIXO")
				TRB1->NUMERO   := (cAliasTmp)->&(cCampo+"_NUM")
				TRB1->PARCELA  := (cAliasTmp)->&(cCampo+"_PARCELA")
				TRB1->TIPO     := (cAliasTmp)->&(cCampo+"_TIPO")
				TRB1->CLIFOR   := (cAliasTmp)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))
				TRB1->NOME     := (cAliasTmp)->&(cCampo+If(Upper(cAlias)=="SE1","_NOMCLI" ,"_NOMFOR" ))
				TRB1->LOJA     := (cAliasTmp)->&(cCampo+"_LOJA")
				TRB1->NATUREZA := aSaldo[nX][1]//(cAliasTmp)->&(cCampo+"_NATUREZA")//aSaldo[nX][1]
				TRB1->DESCRI   := Posicione("SED",1,xFilial("SED")+aSaldo[nX][1],"ED_DESCRIC")
				TRB1->DATAMV   := Stod((cAliasTmp)->&(cCampo+"_VENCREA"))
			  *TRB1->CCUSTO   := (cAliasTmp)->&(cCampo+If(Upper(cAlias)=="SE1","_CCC","_CCD"))
			   TRB1->CCUSTO   := If(Upper(cAlias)=="SE1",Alltrim(SE1->E1_CCC)+Alltrim(SE1->E1_ITEMC)+Alltrim(SE1->E1_CLVLCR),Alltrim(SE2->E2_CCD)+Alltrim(SE2->E2_ITEMD)+Alltrim(SE2->E2_CLVLDB))
				If (cAliasTmp)->TP_STATUS == "A" 
					TRB1->VL_ATRZ := aSaldo[nX][2] //nSaldoTit //aSaldo[nX][4]	
				Else
					TRB1->VL_PREV := aSaldo[nX][2] //nSaldoTit//aSaldo[nX][4]
				EndIf
		
				MsUnlock()
			Endif
	  Next
	
	dbSelectArea(cAliasTmp)
	dbSkip()
Enddo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRDOR012   บAutor  ณMicrosiga           บ Data ณ  09/18/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

*************************
Static Function fMontaReal()
*************************

Local cQuery    := " "
Local I         := 0

If _dDataMov == 1 //DATA DA BAIXA
   cChave := "E5_FILIAL+E5_TIPODOC+E5_DATA+E5_NATUREZ+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO"
Else
   cChave := "E5_FILIAL+E5_TIPODOC+E5_DTDISPO+E5_NATUREZ+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO"
Endif

cQuery += " SELECT * "
cQuery += " FROM " + retsqlname("SE5") + " "
cQuery += " WHERE D_E_L_E_T_ = ' ' "
cQuery += " AND E5_FILIAL BETWEEN '" + _cFilDe + "' And '" + _cFilAte + "'"

If _dDataMov == 1 // BAIXA
    cQuery += "       AND E5_DATA BETWEEN '" + DtoS(_dDataDe)  + "' AND '" + DtoS(_dDataAte) + "'"
    cQuery += "       AND E5_DATA      <= '" + DTOS(dDataBase) + "'"
    _cOrder:= " E5_NATUREZ,E5_DATA"
Else
    cQuery += "       AND E5_DTDISPO BETWEEN '" + DtoS(_dDataDe)  + "' AND '" + DtoS(_dDataAte) + "'"
    cQuery += "       AND E5_DTDISPO      <= '" + DTOS(dDataBase) + "'"
    _cOrder:= " E5_NATUREZ,E5_DTDISPO"
Endif
    
cQuery += "       AND E5_NATUREZ BETWEEN '" + _cNatDe        + "' AND '" + _cNatAte         + "'"
cQuery += "		   AND E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL','CH') "
//Comentado por Rafael Lima - 23/03/10 (O usuแrio rguerra solicitou que aparecesse os estornos no relat๓rio).
//cQuery += "       AND E5_SITUACA NOT IN ('C','E','X')" 
//cQuery += "       AND E5_RECONC = ' '"      // Comentado em 19/07/2010 - Noronha - Conforme email Rodrigo
cQuery += "       AND E5_SITUACA NOT IN ('X')"
cQuery += "       AND E5_SITUACA NOT IN ('C')" // Cancelamentos nใo devem entrar no relat๓rio. (Sergio, em 28/07/2010)
cQuery += "       AND E5_NUMCHEQ NOT LIKE '%*'  "

If _nFtBanco == 2 //FILTRA POR BANCO
   cQuery += " AND E5_BANCO =  '" + _cBanco + "' AND E5_AGENCIA = '" + _cAgencia + "' AND E5_CONTA = '" + _cConta + "'"
Endif

cQuery += "ORDER BY " + _cOrder

cquery := Changequery(cquery)
//MemoWrite("c:\querySE5.txt",cQuery)
MemoWrite("c:\fMontaReal_13B.txt",cQuery)

IF Select("QRY")>0
	DbSelectArea("QRY")
	DbCloseArea()
ENDIF

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "QRY" , .F., .T.)

DbSelectArea("QRY")
DbGoTop()

While !eof()
	
	_cMultNat   := " "
	_xNatureza  := QRY->E5_NATUREZ

	If !Empty(QRY->E5_MOTBX)
		If !MovBcoBx(QRY->E5_MOTBX)
			QRY->( dbSkip() )
			Loop
		EndIf
	Endif
	
	/*
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se existe baixas estornadas           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If U_fCancSE5(QRY->E5_FILIAL,QRY->E5_PREFIXO,QRY->E5_NUMERO,QRY->E5_PARCELA,QRY->E5_TIPO,;
	              QRY->E5_CLIFOR,QRY->E5_LOJA,QRY->E5_SEQ,QRY->E5_NUMCHEQ,QRY->E5_BANCO,QRY->E5_AGENCIA,QRY->E5_CONTA)
		DbSelectArea("QRY")
		dbskip()
		loop
	EndIf
	*/
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se o banco compoe o fluxo de caixa    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If SA6->(dbSeek(QRY->E5_FILIAL+QRY->E5_BANCO+QRY->E5_AGENCIA+QRY->E5_CONTA))
		If SA6->A6_FLUXCAI == "N"
			QRY->( dbSkip() )
			Loop
		Endif
	Endif

   // Sergio, em 28/07/2010
   // Nใo considerar baixas por aglutina็ao de tํtulos para PIS, COFINS, CSLL e IRF
   If ( QRY->E5_NATUREZ = "PIS"  .OR. QRY->E5_NATUREZ = "COFINS" .OR. QRY->E5_NATUREZ = "CSLL" .OR. QRY->E5_NATUREZ = "IRF" ) .AND. (QRY->E5_TIPODOC = "BA")
		QRY->( dbSkip() )
		Loop
   EndIf
	
	If !Empty(QRY->E5_NUMERO)
		If QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1"
			If SE1->( dbSeek(QRY->E5_FILIAL+QRY->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)) )
				_cMultNat   := SE1->E1_MULTNAT
				_xNatureza  := SE1->E1_NATUREZ  
				If SE1->E1_FLUXO == "N"
					QRY->( dbSkip() )
					Loop
				Endif
			Endif
		Else
			dbSelectArea("SE2")
			If SE2->( dbSeek(QRY->E5_FILIAL+QRY->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR) ))
				_cMultNat   := SE2->E2_MULTNAT
				_xNatureza  := SE2->E2_NATUREZ  
				If SE2->E2_FLUXO == "N"
					QRY->( dbSkip() )
					Loop
				Endif
			Endif
		Endif
	Endif

      // 01/06/2010 - Noronha
//		Processa({|| ACERTAMN(QRY->E5_PREFIXO+QRY->E5_NUMERO) },"Processando...")
      //
	  
	   lGravou   := .F.
	   nVlTotNat := 0
	   
	 //|------------------------------------------------------------------------------------------------------|
	 //|Trata para que os titulos de estono saiam juntos com os titulos de origem , porem com sinal invertido.|
	 //|------------------------------------------------------------------------------------------------------|

	 	/* alterado em 09/04/2008 ( Incluido )
	 	 INICIO */
	 	
	 	If QRY->E5_TIPODOC $ ("ES|EC")
	    	IF QRY->E5_RECPAG == "R"
	      		 cTpMov := "S"
		    Else   
		       cTpMov := "E" 
		    Endif
		    nEstorno :=  -1
		Else
		   IF QRY->E5_RECPAG == "R"
		       cTpMov := "E"
		   Else   
		        cTpMov   := "S" 
		   Endif
		   nEstorno  := 1
		Endif           
	   
	   //FIM
	   
	   /* alterado em 09/04/2008 ( Comentado )
	   INICIO 
	   cTpMov    := iF(QRY->E5_RECPAG == "R","E","S")
	   nEstorno  := IIf(QRY->E5_TIPODOC $ ("ES|EC"),-1,1)
       FIM */ 	
	   DbSelectArea("TRB1")
	   If QRY->E5_TIPODOC = 'CH'
          fGravaTit(QRY->E5_FILIAL,QRY->E5_NUMCHEQ,cTpMov,QRY->E5_BANCO,QRY->E5_AGENCIA,QRY->E5_CONTA,cChave)
       Else
          If _cMultNat == "1"  .And. _cBsMultNat == 1
      	       aVetMultNat := GrvMultNat(QRY->E5_FILIAL  ,;
      	                                 QRY->E5_PREFIXO ,;
      	                                 QRY->E5_NUMERO  ,;
      	                                 QRY->E5_PARCELA ,;
	      	                              QRY->E5_TIPO    ,;
   	   	                              QRY->E5_CLIFOR  ,;
      		                              QRY->E5_LOJA    ,;
      		                              QRY->E5_RECPAG)
      	         	   
      	     nConta := 0
      	   	 For I := 1 To Len(aVetMultNat)
      	   		lGravou := .T.
      	   		RecLock("TRB1",.T.)
  				nConta++
  				TRB1->FL_MOVE  := aVetMultNat[I][01]
				TRB1->PREFIXO  := aVetMultNat[I][02]
				TRB1->NUMERO   := aVetMultNat[I][03]
				TRB1->PARCELA  := aVetMultNat[I][04]
				TRB1->TIPO     := aVetMultNat[I][05]
				TRB1->CLIFOR   := aVetMultNat[I][06]
				TRB1->NOME     := Substr(QRY->E5_BENEF,1,25)
				TRB1->LOJA     := aVetMultNat[I][07]
				TRB1->NATUREZA := aVetMultNat[I][08]
			   *TRB1->CCUSTO   := If(!Empty(QRY->E5_NUMERO),If(QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1" , SE1->E1_CCC , SE2->E2_CCD),"")
				TRB1->CCUSTO   := If(!Empty(QRY->E5_NUMERO),If(QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1" , Alltrim(SE1->E1_CCC)+Alltrim(SE1->E1_ITEMC)+Alltrim(SE1->E1_CLVLCR),Alltrim(SE2->E2_CCD)+Alltrim(SE2->E2_ITEMD)+Alltrim(SE2->E2_CLVLDB)),"")
				//TRATAR REGISTRO COM PROBLEMAS NA IMPORTACAO 
				If Round((QRY->E5_VALOR),2) == Round(aVetMultNat[I][09],2)
				   TRB1->VL_REAL  := aVetMultNat[I][09] * nEstorno 
  	            Else
                  TRB1->VL_REAL  := Round(QRY->E5_VALOR * aVetMultNat[I][10],2) * nEstorno 
  	            Endif
				
				//TRB1->VL_REAL  := Round(QRY->E5_VALOR * aVetMultNat[I][10],2)  * nEstorno
  	            TRB1->DESCRI   := Posicione("SED",1,xFilial("SED")+aVetMultNat[I][8],"ED_DESCRIC")
				TRB1->DATAMV   := IIf(_dDataMov == 1 ,Stod(QRY->E5_DATA),Stod(QRY->E5_DTDISPO))
				TRB1->TPDOC    := QRY->E5_TIPODOC
				TRB1->TP       := cTpMov
				MsUnlock()
           
                nVlTotNat      += Round(QRY->E5_VALOR * aVetMultNat[I][10],2)     
            
      	   	Next
         Endif
      		
      		If  lGravou
	   	       If nVlTotNat <> QRY->E5_VALOR
   		          //Alert("Erro no somatorio das multiplas naturezas. Filial" + QRY->E5_FILIAL + "- Tํtulo: " + QRY->E5_NUMERO )
   		          //Aviso("Aten็ใo - QRY","Erro no somatorio das multiplas naturezas. Filial" + QRY->E5_FILIAL + "- Tํtulo: " + QRY->E5_NUMERO + "Parcela: "+QRY->E5_PARCELA,{"OK"})
    		          //If nConta == 1
    		          //   RecLock("TRB1",.F.)
    		          //   TRB1->VL_REAL  := QRY->E5_VALOR * nEstorno 
    		          //   MsUnlock()
    		          // Endif
    		          // 18/06/2010 - Noronha
						 Processa({|| ACERTAMN(QRY->E5_PREFIXO+QRY->E5_NUMERO) },"Processando...")
				       //
    		       Endif
    		   Endif  
      		
      		If !lGravou	
      			DbSelectArea("TRB1")
      			If !DbSeek(QRY->(E5_FILIAL+E5_TIPODOC+E5_DATA+E5_NATUREZ+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_CLIFOR)) 
    	  	   		RecLock("TRB1",.T.)
		  				TRB1->TP       :=  cTpMov
						TRB1->FL_MOVE  := QRY->E5_FILIAL
						TRB1->PREFIXO  := QRY->E5_PREFIXO
						TRB1->NUMERO   := QRY->E5_NUMERO
						TRB1->PARCELA  := QRY->E5_PARCELA
						TRB1->TIPO     := QRY->E5_TIPO
						TRB1->CLIFOR   := QRY->E5_CLIFOR
						TRB1->NOME     := Substr(QRY->E5_BENEF,1,25)
						TRB1->LOJA     := QRY->E5_LOJA
						TRB1->NATUREZA := _xNatureza
						TRB1->DESCRI   := Posicione("SED",1,xFilial("SED")+QRY->E5_NATUREZA,"ED_DESCRIC")
						TRB1->DATAMV   := IIf(_dDataMov == 1 ,Stod(QRY->E5_DATA),Stod(QRY->E5_DTDISPO))
						TRB1->TPDOC    := QRY->E5_TIPODOC
						TRB1->VL_REAL  := QRY->E5_VALOR * nEstorno 
					  *TRB1->CCUSTO   := If(!Empty(QRY->E5_NUMERO),If(QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1" , SE1->E1_CCC , SE2->E2_CCD),"")
						TRB1->CCUSTO   := If(!Empty(QRY->E5_NUMERO),If(QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1" , Alltrim(SE1->E1_CCC)+Alltrim(SE1->E1_ITEMC)+Alltrim(SE1->E1_CLVLCR),Alltrim(SE2->E2_CCD)+Alltrim(SE2->E2_ITEMD)+Alltrim(SE2->E2_CLVLDB)),"")
		  	      	MsUnlock()
		   		Else
	         		RecLock("TRB1",.F.)
		      		If TRB1->VL_REAL > 0	
		   	   		    TRB1->VL_REAL    += QRY->E5_VALOR * nEstorno
                  Else
 				   		TRB1->VL_REAL    := QRY->E5_VALOR * nEstorno
            		Endif
            		MsUnlock()
   				Endif
            Endif
	Endif
	
	DbSelectArea("QRY")
	DbSkip()
Enddo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  01/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

dbSelectArea("TRB1")

SetRegua(RecCount())
dbGoTop()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao do cabecalho do relatorio. . .                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

cCab := "| Periodo " +  Transform(_dDataDe,"@e") + " Ate " + Transform(_dDataAte,"@e")
cCab += " | Data de Referencia : " + Transform(dDataBase,"@e") + " (*)"

fImpRel("|",cCab,Titulo,nLin)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gera relatorio em excell...                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If _GrExcell == 2
   
	CpyS2T( "\SYSTEM\"+_cArq+".CSV" , _cPathRl, .T. )
	
	lGrExcell := .T.
//	If ! ApOleClient( 'MsExcel' )
//		MsgStop( 'MsExcel nao instalado! ')
//		lGrExcell := .F.
//	EndIf
//	
	If lGrExcell

		ShellExecute("open",_cArq+".CSV","", _cPathRl,1)
		
	   /*oExcelApp := MsExcel():New()
	   oExcelApp:WorkBooks:Open( _cPathRl+_cArq+".CSV") // Abre uma planilha
	   oExcelApp:SetVisible(.T.)*/
   Endif

Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Apaga arquivos tempor rios  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectarea("TRB1")
TRB1->( dbCloseArea() )
FErase("TRB1"+OrdBagExt())
FErase("TRB1"+GetDBExtension())

dbSelectArea("SE1")
If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()
Return Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณMicrosiga           บ Data ณ  09/17/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
**********************************************
Static Function fImpRel(Cabec1,Cabec2,Titulo,nLin)
**********************************************

Local _cTpMov := " "
Local nTotPrevPg := 0
Local nTotRealPg := 0
Local nTotAtrzPg := 0
Local nTotPrevRc := 0
Local nTotRealRc := 0
Local nTotAtrzRc := 0

nLin := 80

If nLin > 70 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
	Cabec(Titulo,"","",NomeProg,Tamanho,nTipo)
	nLin := 06
	//@ nLin, 000 PSAY __PrtFatLine()
	//nLin++
	 @nLin,  001 PSAY __PrtLeft (Cabec2)
	 nLin++
	 @ nLin, 000 PSAY __PrtFatLine()
	 nLin ++
    @ nLin,001 PSAY cCab2
    nLin++
    @ nLin, 000 PSAY __PrtFatLine()
	 nLin ++
Endif

@ nLin,000 Psay " >>> E M P R E S T I M O S .......: " + Transform(nEmprestimo,PesqPict("SE2","E2_VALOR"))
nLin++
@ nLin,000 Psay " >>> A P L I C A C O E S .........: " + Transform(nAplicacao,PesqPict("SE2","E2_VALOR"))
nLin++
@ nLin,000 Psay " >>> S A L D O   A N T E R I O R .: " + Transform(nbancos,PesqPict("SE2","E2_VALOR"))
nLin += 2
@ nLin, 000 PSAY __PrtFatLine()
nLin+= 2

IndRegua ( "TRB1",_cInd2,"DTOS(DATAMV)+NATUREZA+CLIFOR",,,OemToAnsi("Selecionando Registros..."))

DbSelectArea("TRB1")
DbGoTop()

While !eof()

 _cTpMov  := TRB1->TP //PAGAR OU RECEBER
 If Substr(TRB1->NATUREZA,1,1) == "1" //ENTRADAS //_cTpMov == "E"
		@ nLin, 50 PSAY " >>>  E N T R A D A S  NO  P E R I D O   <<<  "
		nLin++
	Else
		@ nLin, 50 PSAY " >>>  S A I D A S    NO  P E R I O D O     <<<  "
		nLin++
	Endif
	
//While  !Eof() .And. TRB1->TP == _cTpMov
	
	If nLin > 70 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,"","",NomeProg,Tamanho,nTipo)
		nLin := 06
		//@ nLin,000 PSAY __PrtFatLine()
		//nLin++
		 @nLin,001  PSAY __PrtLeft(Cabec2)
		 nLin++
		 @ nLin,000 PSAY __PrtFatLine()
		 nLin +=2
	    @ nLin,001 PSAY cCab2
       nLin++
	    @ nLin, 000 PSAY __PrtFatLine()
	    nLin ++
	Endif
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	nVlTotPrev := 0
	nVlTotReal := 0
	nVlTotAtrz := 0
	
	_dDataMv   := TRB1->DATAMV
	While _dDataMv == TRB1->DATAMV .And. TRB1->TP == _cTpMov
		
		@ nLin,000 PSAY __PrtFatLine()
		nLin ++
		@nLin,000 PSAY subs(TRB1->NATUREZA,1,10) + " - " +  Subs(TRB1->DESCRI,1,40)
		nLin++
		@ nLin,000 PSAY __PrtFatLine()
		nLin ++
		
		nVlTotDiaR := 0
		nVlTotDiaP := 0
		nVlTotDiaA := 0
		
		@nLin,000 PSAY Transform(_dDataMv,"@e")
		nLin ++
		
		nCol := 12//15
		
		_cNat     := TRB1->NATUREZA
		While !eof() .And. _cNat  ==  TRB1->NATUREZA .And. _dDataMv == TRB1->DATAMV .And. _cNat ==  TRB1->NATUREZA //.And. TRB1->TP == _cTpMov
			
			If _GrExcell == 2
			    cLinha := " "
			    cLinha += TRB1->FL_MOVE  + ";"
  	          cLinha += TRB1->PREFIXO  + ";"
			  	 cLinha += TRB1->NUMERO   + ";"
			    cLinha += TRB1->PARCELA  + ";"
			    cLinha += TRB1->TIPO     + ";"
			    cLinha += TRB1->CLIFOR   + ";"    
			    cLinha += TRB1->NOME     + ";"
			    cLinha += TRB1->LOJA     + ";"
			    cLinha += Dtos(TRB1->DATAMV) + ";" 
			    cLinha += TRB1->NATUREZA + ";"
			    cLinha += TRB1->DESCRI   + ";"
			    cLinha += TransForm(TRB1->VL_PREV,"@e 999,999,999.99")  + ";"
			    cLinha += Transform(TRB1->VL_ATRZ,"@e 999,999,999.99")  + ";"
			    cLinha += Transform(TRB1->VL_REAL,"@e 999,999,999.99")  + ";"
			    cLinha += TRB1->TP       + ";"
			    cLinha += TRB1->TPDOC    + ";"    
			    cLinha += TRB1->CCUSTO   + ";"    
			    FWrite(nHandle, cLinha+CRLF)
         Endif

			@nLin,nCol PSAY TRB1->CLIFOR +" "+  TRB1->NOME
			@nLin,nCol + 35  PSAY TRB1->(FL_MOVE+" "+PREFIXO+" "+ NUMERO+" "+ PARCELA+" "+CCUSTO)
			@nLin,nCol + 55  PSAY TransForm(TRB1->VL_REAL,PesqPict("SE2","E2_VALOR"))
			@nLin,nCol + 70  PSAY TransForm(TRB1->VL_PREV,PesqPict("SE2","E2_VALOR"))
			@nLin,nCol + 85  PSAY TransForm(TRB1->VL_ATRZ,PesqPict("SE2","E2_VALOR"))
			
			nLin++
			nVlTotDiaR += TRB1->VL_REAL
			nVlTotDiaP += TRB1->VL_PREV
			nVlTotDiaA += TRB1->VL_ATRZ
			
			If nLin > 70 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,"","",NomeProg,Tamanho,nTipo)
				nLin := 06
				//@ nLin, 000 PSAY __PrtFatLine()
				//nLin++
				@nLin,001 PSAY __PrtLeft(Cabec2)
				nLin++
				@ nLin, 000 PSAY __PrtFatLine()
				nLin ++
            @ nLin,001 PSAY cCab2
            nLin++
				@nLin,000 PSAY Transform(_dDataMv,"@e")
				nLin ++
			   @ nLin, 000 PSAY __PrtFatLine()
            nLin ++ 
			Endif
						
			DbSelectArea("TRB1")
			DbSkip()
		Enddo
		
		nVlTotReal += nVlTotDiaR
		nVlTotPrev += nVlTotDiaP
		nVlTotAtrz += nVlTotDiaA
		
		nLin ++
		@ nLin, nCol + 35 PSAY " S U B T O T A L = "
		@ nLin, nCol + 55 PSAY TransForm(nVlTotDiaR,PesqPict("SE2","E2_VALOR"))
		@ nLin, nCol + 70 PSAY TransForm(nVlTotDiaP,PesqPict("SE2","E2_VALOR"))
		@ nLin, nCol + 85 PSAY TransForm(nVlTotDiaA,PesqPict("SE2","E2_VALOR"))
		
		nLin += 2
		
		If nLin > 70 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,"","",NomeProg,Tamanho,nTipo)
			nLin := 06
			@nLin,001 PSAY __PrtLeft(Cabec2)
			nLin++
			@ nLin, 000 PSAY __PrtFatLine()
			nLin ++
	      @ nLin,001 PSAY cCab2
         nLin++
		   @ nLin, 000 PSAY __PrtFatLine()
	      nLin ++
		Endif
	Enddo
	nLin++
	@ nLin,000 PSAY __PrtFatLine()
	nLin ++
	
	@ nLin, nCol + 35 PSAY " TOTAL DO DIA  = "
	@ nLin, nCol + 55 PSAY TransForm(nVlTotReal,PesqPict("SE2","E2_VALOR"))
	@ nLin, nCol + 70 PSAY TransForm(nVlTotPrev,PesqPict("SE2","E2_VALOR"))
	@ nLin, nCol + 85 PSAY TransForm(nVlTotAtrz,PesqPict("SE2","E2_VALOR"))
	
	nLin++
	@ nLin,000 PSAY __PrtFatLine()
	nLin ++
	
	IF _cTpMov == "S"     //SAIDAS
		nTotPrevPg += nVlTotPrev
		nTotRealPg += nVlTotReal
		nTotAtrzPg += nVlTotAtrz
	ElseIf _cTpMov == "E" //ENTRADAS
		nTotPrevRc += nVlTotPrev
		nTotRealRc += nVlTotReal
		nTotAtrzRc += nVlTotAtrz
	Endif
//Enddo
Enddo
nLin += 1

If nLin > 40
   nLin := 80
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao do cabecalho do relatorio. . .                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nLin > 35 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
	Cabec(Titulo,"","",NomeProg,Tamanho,nTipo)
	nLin := 06
	//@ nLin, 000 PSAY __PrtFatLine()
	//nLin++
	@nLin,001 PSAY __PrtLeft(Cabec2)
	nLin++
	@ nLin, 000 PSAY __PrtFatLine()
	nLin ++
   @ nLin,001 PSAY cCab2
   nLin++
   @ nLin, 000 PSAY __PrtFatLine()
	nLin ++
Endif

@nLin,000 PSAY __PrtFatLine()
nLin++
@nLin,000 PSAY __PrtLeft(">>> T O T A L  G E R A L  ")
nLin ++
@ nLin, 000 PSAY __PrtFatLine()
nLin += 2

@nLin,001 PSAY __PrtLeft(">>> R E C E B I M E N T O S <<< ")
nLin+=2
@ nLin, 025 PSAY " R E A L I Z A D O =  "  + Transform(nTotRealRc,PesqPict("SE2","E2_VALOR"))
nLin++
@ nLin, 025 PSAY " P R E V I S T O   =  "  + Transform(nTotPrevRc,PesqPict("SE2","E2_VALOR"))
nLin++
@ nLin, 025 PSAY " A T R A S A D O   =  "  + Transform(nTotAtrzRc,PesqPict("SE2","E2_VALOR"))
nLin += 2

@nLin,001 PSAY __PrtLeft(">>> P A G A M E N T O S <<< ")
nLin+=2

@ nLin, 025 PSAY " R E A L I Z A D O =  "  + Transform(nTotRealPg,PesqPict("SE2","E2_VALOR"))
nLin++
@ nLin, 025 PSAY " P R E V I S T O   =  "  + Transform(nTotPrevPg,PesqPict("SE2","E2_VALOR"))
nLin++
@ nLin, 025 PSAY " A T R A S A D O   =  "  + Transform(nTotAtrzPg,PesqPict("SE2","E2_VALOR"))
nLin +=2


@nLin,001 PSAY __PrtLeft(">>> R E S U L T A D O  D O  P E R I O D O <<<")
nLin+= 2

@ nLin, 025 PSAY " R E A L I Z A D O =  "  + Transform(Round(nTotRealRc - nTotRealPg,2),PesqPict("SE2","E2_VALOR"))
nLin++
@ nLin, 025 PSAY " P R E V I S T O   =  "  + Transform(Round(nTotPrevRc - nTotPrevPg,2),PesqPict("SE2","E2_VALOR"))
nLin++
@ nLin, 025 PSAY " A T R A S A D O   =  "  + Transform(Round(nTotAtrzRc - nTotAtrzPg,2),PesqPict("SE2","E2_VALOR"))

nlin += 1 
@ nLin, 000 PSAY __PrtFatLine()
nLin += 1

@nLin,001 PSAY __PrtLeft(">>> S A L D O  A T U A L  <<<")
nLin+= 1

@ nLin, 025 PSAY "           ------->   "  + Transform(Round(nBancos + (nTotRealRc - nTotRealPg),2),PesqPict("SE2","E2_VALOR"))
nLin++
@ nLin, 000 PSAY __PrtFatLine()
nLin += 2

FClose(nHandle)

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ fCriaSX1     ณAutor ณ                      ณDataณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria arquivos de perguntas do SX1                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
**************************
/*Inํcio - Thais Paiva - Compatibiliza็ใo P27
Static Function fCriaSx1()
**************************
Local X1 := 0
Local Z  := 0
SX1->(DbSetOrder(1))

If !SX1->(DbSeek(cPerg+aSx1[Len(aSx1),2]))
	SX1->(DbSeek(cPerg))
	While SX1->(!Eof()) .And. Alltrim(SX1->X1_GRUPO) == cPerg
		SX1->(Reclock("SX1",.F.,.F.))
		SX1->(DbDelete())
		SX1->(MsunLock())
		SX1->(DbSkip())
	End
	For X1:=2 To Len(aSX1)
		SX1->(RecLock("SX1",.T.))
		For Z:=1 To Len(aSX1[1])
			cCampo := "X1_"+aSX1[1,Z]
			SX1->(FieldPut(FieldPos(cCampo),aSx1[X1,Z] ))
		Next
		SX1->(MsunLock())
	Next
Endif

Return
Fim - Thais Paiva - Compatibiliza็ใo P27*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTemBxCanc ณ Autor ณ Andreia Santos        ณ Data ณ 09/12/98 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
User Function fCancSE5(_cXFilial,_cXPref,_cXNum,_cXParc,_cXTipo,_cXClifor,_cXLoja,_cXSeq,_cXCheq,_cXBco,_cXAge,_cXConta)

LOCAL aArea    := GetArea()
LOCAL aAreaSE5 := SE5->(GetArea())
LOCAL lRet 	   := .F.
LOCAL cQuery   := ""
LOCAL cAlias   := ""

//dbSelectArea("SE5")
//dbSetOrder( 7 )
//If dbSeek(cChave)
   cQuery := "SELECT Count(*) ESTORNO FROM "+RetSqlName("SE5")+" WHERE "
   cQuery +=      " E5_FILIAL    ='"+_cXFilial+"' AND "
   cQuery += 		" E5_PREFIXO   ='"+_cXPref  +"' AND "
	cQuery += 		" E5_NUMERO    ='"+_cXNum   +"' AND "
	cQuery += 		" E5_PARCELA   ='"+_cXParc  +"' AND "
	cQuery += 		" E5_TIPO      ='"+_cXTipo  +"' AND "
	cQuery += 		" E5_CLIFOR    ='"+_cXClifor+"' AND "
	cQuery += 		" E5_LOJA      ='"+_cXLoja  +"' AND "
	cQuery += 		" E5_SEQ       ='"+_cXSeq   +"' AND "
	cQuery +=    	" E5_NUMCHEQ   ='"+_cXCheq  +"' AND "
	cQuery += 		" E5_BANCO     ='"+_cXBco   +"' AND "
	cQuery +=      " E5_AGENCIA   ='"+_cXAge   +"' AND "
   cQuery += 	   " E5_CONTA    ='"+_cXConta +"' AND "
	cQuery += 		" E5_TIPODOC  IN ('ES','EC') AND "
	cQuery += 		" E5_DATA    <= '"+DTOS(dDataBase)+"' AND "
	cQuery += 		" D_E_L_E_T_ <>'*'"
	cQuery := ChangeQuery(cQuery)
	cAlias := ("__TMP5")
	
	If Select(cAlias) > 0
	  	dbselectarea(cAlias)
	   dbclosearea()
   Endif 
		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		
	If ( (cAlias)->(ESTORNO) > 0 )
		lRet := .T.
	EndIf
//Endif
*///Comentado por Rafael - A Chamada da mesma encontra-se comentada
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRDOR013   บAutor  ณMicrosiga           บ Data ณ  10/20/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fGravaTit(cFilAtu,cNumCheque,cTpMov,xBanco,xAgencia,xConta)
Local cSql      := " "
Local aArea     := GetArea()
Local I         := 0  

cSql := " SELECT * FROM " + RetSqlName("SE5") 
cSql += " WHERE D_E_L_E_T_ = ' ' AND "
cSql += " E5_FILIAL    = '" + cFilAtu    + "' AND "
cSql += " E5_NUMCHEQ   = '" + cNumCheque + "' AND "
cSql += " E5_BANCO     = '" + xBanco     + "' AND "
cSql += " E5_AGENCIA   = '" + xAgencia   + "' AND "
cSql += " E5_CONTA     = '" + xConta     + "' AND "
//cSql += " E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL','ES','EC') AND " //,'CH') AND " - retirado porque pagamento nใo 
cSql += " E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL','ES','EC','CH') AND "  
cSql += " E5_SITUACA NOT IN ('C','E','X') AND "                                                      // aparecia, so o estorno - Ana - 30/10/2009

cSql += " E5_NUMCHEQ NOT LIKE '%*' "
cSql += " ORDER BY E5_FILIAL,E5_NUMERO "

cSql := ChangeQuery(cSql)
MemoWrite("c:\fGravaTit_13B.txt",cSql)

IF Select("QRY2") > 0
	DbSelectArea("QRY2")
	DbCloseArea()
ENDIF

dbUseArea(.T., "TOPCONN", TCGenQry(,,cSql), "QRY2" , .F., .T.)

DbSelectArea("QRY2")
DbGoTop()

While !eof()

    	     lGravou   := .F.
    	     nVlTotNat := 0

           // Sergio, em 30/07/2010
           // Nใo considerar baixas por aglutina็ao de tํtulos para PIS, COFINS, CSLL e IRF
           If ( QRY2->E5_NATUREZ = "PIS"  .OR. QRY2->E5_NATUREZ = "COFINS" .OR. QRY2->E5_NATUREZ = "CSLL" .OR. QRY2->E5_NATUREZ = "IRF" ) .AND. (QRY2->E5_TIPODOC = "BA")
              QRY2->( DbSkip() )
              Loop
           EndIf

    	     If !Empty(QRY->E5_NUMERO)
		        If QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1"
			        If SE1->( dbSeek(QRY->E5_FILIAL+QRY->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)) )
			           //_cMultNat   := SE1->E1_MULTNAT
			           //_xNatureza  := SE1->E1_NATUREZ  
			           /*
			           If SE1->E1_FLUXO == "N"
			               QRY->( dbSkip() )
					         Loop
				        Endif
				        */
			        Endif
		        Else
			        dbSelectArea("SE2")
			        If SE2->( dbSeek(QRY->E5_FILIAL+QRY->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR) ))
				        //_cMultNat   := SE2->E2_MULTNAT
				        //_xNatureza  := SE2->E2_NATUREZ  
				        /*
				        If SE2->E2_FLUXO == "N"
					        QRY->( dbSkip() )
					        Loop
				        Endif
				        */
			        Endif
		        Endif
           Endif
    	     
    	     If _cBsMultNat == 1
    	     
    	     		aVetMultNat := GrvMultNat(QRY2->E5_FILIAL,;
      	                                 QRY2->E5_PREFIXO,;
      	                                 QRY2->E5_NUMERO, ;
      	                             		QRY2->E5_PARCELA,;
	      	                              QRY2->E5_TIPO,;
   	   	                              QRY2->E5_CLIFOR,;
      		                              QRY2->E5_LOJA,;
      		                              QRY2->E5_RECPAG)
      	         	   
      	   	nConta := 0
      	   	For I := 1 To Len(aVetMultNat)
      	   		lGravou := .T.
      	   		RecLock("TRB1",.T.)
		  				nConta ++
		  				TRB1->FL_MOVE  := aVetMultNat[I][01]
						TRB1->PREFIXO  := aVetMultNat[I][02]
						TRB1->NUMERO   := aVetMultNat[I][03]
						TRB1->PARCELA  := aVetMultNat[I][04]
						TRB1->TIPO     := aVetMultNat[I][05]
						TRB1->CLIFOR   := aVetMultNat[I][06]
						TRB1->NOME     := Substr(QRY2->E5_BENEF,1,25)
						TRB1->LOJA     := aVetMultNat[I][07]
						TRB1->NATUREZA := aVetMultNat[I][08]
                 *TRB1->CCUSTO   := If(!Empty(QRY->E5_NUMERO),If(QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1" , SE1->E1_CCC , SE2->E2_CCD),"")						
                  TRB1->CCUSTO   := If(!Empty(QRY->E5_NUMERO),If(QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1" , Alltrim(SE1->E1_CCC)+Alltrim(SE1->E1_ITEMC)+Alltrim(SE1->E1_CLVLCR),Alltrim(SE2->E2_CCD)+Alltrim(SE2->E2_ITEMD)+Alltrim(SE2->E2_CLVLDB)),"")						
						//TRATAR REGISTRO COM PROBLEMAS NA IMPORTACAO 
						IF Round((QRY2->E5_VALOR),2) == Round(aVetMultNat[I][09],2)
						   TRB1->VL_REAL  := aVetMultNat[I][09] 
		  	         Else
		  	            TRB1->VL_REAL  := Round(QRY2->E5_VALOR * aVetMultNat[I][10],2) 
		  	         Endif
		  	         
		  	         TRB1->DESCRI   := Posicione("SED",1,xFilial("SED")+aVetMultNat[I][8],"ED_DESCRIC")
						TRB1->DATAMV   := IIf(_dDataMov == 1 ,Stod(QRY2->E5_DATA),Stod(QRY2->E5_DTDISPO))
						TRB1->TPDOC    := QRY2->E5_TIPODOC
						TRB1->TP       := cTpMov
						nVlTotNat      += Round(QRY2->E5_VALOR * aVetMultNat[I][10],2) 
						MsUnlock()
    	        Next
   	     
   	     Endif
   	     
   	     If  lGravou
   	         If nVlTotNat <> QRY2->E5_VALOR
   	            //Alert("Erro no somatorio das multiplas naturezas. Filial" + QRY2->E5_FILIAL + "- Tํtulo: " + QRY2->E5_NUMERO )
   		         // Aviso("Aten็ใo - QRY2","Erro no somatorio das multiplas naturezas. Filial" + QRY2->E5_FILIAL + "- Tํtulo: " + QRY2->E5_NUMERO + "Parcela: "+QRY2->E5_PARCELA,{"OK"})
    	            //If nConta == 1
    	            //   RecLock("TRB1",.F.)
    	            //   TRB1->VL_REAL  :=  QRY2->E5_VALOR 
    	            //   MsUnlock()
    	            //Endif
   		         // 18/06/2010 - Noronha
						Processa({|| ACERTAMN(QRY2->E5_PREFIXO+QRY2->E5_NUMERO) },"Processando...")
				      //
    	        Endif
    	     Endif     
    	
    	     If !lGravou
    	     	   If !TRB1->(MsSeek(("QRY2")->&(cChave)))
       	     		RecLock("TRB1",.T.)
		            TRB1->TP       :=  cTpMov
		            TRB1->FL_MOVE  := QRY2->E5_FILIAL
					   TRB1->PREFIXO  := QRY2->E5_PREFIXO
					   TRB1->NUMERO   := QRY2->E5_NUMERO
					   TRB1->PARCELA  := QRY2->E5_PARCELA
					   TRB1->TIPO     := QRY2->E5_TIPO
				   	TRB1->CLIFOR   := QRY2->E5_CLIFOR
					   TRB1->NOME     := Substr(QRY2->E5_BENEF,1,25)
					   TRB1->LOJA     := QRY2->E5_LOJA
					   TRB1->NATUREZA := QRY2->E5_NATUREZA
					   TRB1->DESCRI   := Posicione("SED",1,xFilial("SED")+QRY2->E5_NATUREZA,"ED_DESCRIC")
					   TRB1->DATAMV   := IIf(_dDataMov == 1 ,Stod(QRY2->E5_DATA),Stod(QRY2->E5_DTDISPO))
					   TRB1->TPDOC    := QRY2->E5_TIPODOC
					   TRB1->VL_REAL  := QRY2->E5_VALOR 
					  *TRB1->CCUSTO   := If(!Empty(QRY->E5_NUMERO),If(QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1" , SE1->E1_CCC , SE2->E2_CCD),"")
					   TRB1->CCUSTO   := If(!Empty(QRY->E5_NUMERO),If(QRY->E5_RECPAG == "R" .And. Substr(QRY->E5_NATUREZA,1,1) == "1" , Alltrim(SE1->E1_CCC)+Alltrim(SE1->E1_ITEMC)+Alltrim(SE1->E1_CLVLCR),Alltrim(SE2->E2_CCD)+Alltrim(SE2->E2_ITEMD)+Alltrim(SE2->E2_CLVLDB)),"")
				  		 MsUnlock()
				   Else
	   				RecLock("TRB1",.F.)
	   				TRB1->TPDOC    := QRY2->E5_TIPODOC
	   				TRB1->VL_REAL  := QRY2->E5_VALOR 
			   		MsUnlock()
	   			Endif
			  Endif  
	
	DbSelectArea("QRY2")
	DbSkip()

Enddo

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRDOR013   บAutor  ณMicrosiga           บ Data ณ  11/05/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GrvMultNat(_xFilial,_xPrefixo,_xNum,_xParcela,_xTipo,_xClifor,_xLoja,_xRecPag)

Local aArea := GetArea()
Local cQuery  := " "
Local aVetSEV := {}

cQuery := " SELECT EV_FILIAL,EV_PREFIXO,EV_NUM,EV_PARCELA,EV_TIPO,EV_CLIFOR,EV_LOJA,EV_NATUREZ,EV_VALOR,EV_PERC,EV_RECPAG"                                                                                     
cQuery += "FROM " + RetSqlName("SEV") 
cQuery += " WHERE D_E_L_E_T_ = ' ' AND "
cQuery += " EV_NATUREZ BETWEEN '" + _cNatDe + "' AND '" + _cNatAte + "' AND "
cQuery += " EV_FILIAL   = '"+ _xFilial + "' AND" 
cQuery += " EV_PREFIXO  = '"+ _xPrefixo+ "' AND" 
cQuery += " EV_NUM      = '"+ _xNum    + "' AND" 
cQuery += " EV_PARCELA  = '"+ _xParcela+ "' AND" 
cQuery += " EV_TIPO     = '"+ _xTipo   + "' AND" 
cQuery += " EV_CLIFOR   = '"+ _xClifor + "' AND" 
cQuery += " EV_LOJA     = '"+ _xLoja   + "' "
//cQuery += " EV_RECPAG   = '"+ _xRecPag + "'"
cQuery := ChangeQuery(cQuery)
	
If Select("TSEV") > 0
  	dbselectarea("TSEV")
   dbclosearea()
Endif 
		
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSEV",.T.,.T.)

While !eof()
   aAdd(aVetSEV,{EV_FILIAL,EV_PREFIXO,EV_NUM,EV_PARCELA,EV_TIPO,EV_CLIFOR,EV_LOJA,EV_NATUREZ,EV_VALOR,EV_PERC,EV_RECPAG })
   DbSkip()
Enddo
RestArea(aArea)

Return aVetSev  
