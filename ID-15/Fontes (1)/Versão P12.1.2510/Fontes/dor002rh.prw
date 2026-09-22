#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | DOR002RH | AUTOR | Edsonho ®                 | DATA |28/03/2017 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - Filtra CPF/PIS e Conta Corrente em DUPLICIDADE         |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

User Function DOR002RH()

Local oReport
Private cPerg   := Padr("DOR_RH002",10) 
Private nRecTMP := 0
Private cAliasTmp  := "TMP"
Private cQuery  := ""
Private aOrdem  := {}
Private aTabelas:= {"SRA","TMP"}
Private cTitulo := "Relatório de Duplicidade de "
Private aTitulo := {}

//ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
EndIf 

aAdd(aTitulo,{1,"CPF"})
aAdd(aTitulo,{2,"PIS"})
aAdd(aTitulo,{3,"Banco,Agencia e Conta Bancária"})
aAdd(aTitulo,{4,"CPF,PIS e Conta Bancária"})

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Interface de Impressão                                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
oReport:= ReportDef(cPerg)
oReport:PrintDialog()

If Select(cAliasTmp) > 0
   DbSelectArea(cAliasTmp)
  (cAliasTmp)->(DbCloseArea())  
Endif

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| ReportDef                                                                   |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function ReportDef(cPerg)
Local oCell
Local oBreak
Private oReport

cTitulo += aTitulo[MV_Par05,2]

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Criacao do componente de impressao                                          |//
//+-----------------------------------------------------------------------------+//
//| TReport():New                                                               |//
//| ExpC1 : Nome do relatorio                                                   |//
//| ExpC2 : Titulo                                                              |//
//| ExpC3 : Pergunte                                                            |//
//| ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao      |//
//| ExpC5 : Descricao                                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
oReport:= TReport():New("DOR002RH", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cTitulo )
oReport:SetPortrait()
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem)

TRCell():New( oSection1, "RA_FILIAL"	, cAliasTmp, "Filial"			, PesqPict("SRA","RA_FILIAL")	, TamSx3("RA_FILIAL")[1]+10				,  )
TRCell():New( oSection1, "RA_MAT"		, cAliasTmp, "Matrícula"		, PesqPict("SRA","RA_MAT")		, TamSx3("RA_MAT")[1]+05					,  )
TRCell():New( oSection1, "RA_NOME"		, cAliasTmp, "Colaborador"		, PesqPict("SRA","RA_NOME")		, TamSx3("RA_NOME")[1]+15				,  )
TRCell():New( oSection1, "RA_CIC"		, cAliasTmp, "CPF"				, PesqPict("SRA","RA_CIC")		, TamSx3("RA_CIC")[1]+10					,  )
TRCell():New( oSection1, "RA_PIS"		, cAliasTmp, "PIS"				, PesqPict("SRA","RA_PIS")		, TamSx3("RA_PIS")[1]+10					,  )
TRCell():New( oSection1, "RA_BCDEPSA"	, cAliasTmp, "Banco/Agência"	, PesqPict("SRA","RA_BCDEPSA")	, TamSx3("RA_BCDEPSA")[1]+10			,  )
TRCell():New( oSection1, "RA_CTDEPSA"	, cAliasTmp, "Conta Bancária"	, PesqPict("SRA","RA_CTDEPSA")	, TamSx3("RA_CTDEPSA")[1]+10			,  )

/*
If MV_Par05 == 1
   TRCell():New( oSection1, "RA_CIC"	, cAliasTmp, "CPF"				, PesqPict("SRA","RA_CIC")	, TamSx3("RA_CIC")[1]+10						,  )
ElseIf MV_Par05 == 2
   TRCell():New( oSection1, "RA_PIS"	, cAliasTmp, "PIS"				, PesqPict("SRA","RA_PIS")	, TamSx3("RA_PIS")[1]+10						,  )
ElseIf MV_Par05 == 3
   TRCell():New( oSection1, "RA_BCDEPSA", cAliasTmp, "Banco/Agência"	, PesqPict("SRA","RA_BCDEPSA")	, TamSx3("RA_BCDEPSA")[1]+10			,  )
   TRCell():New( oSection1, "RA_CTDEPSA", cAliasTmp, "Conta Bancária"	, PesqPict("SRA","RA_CTDEPSA")	, TamSx3("RA_CTDEPSA")[1]+10			,  )
EndIf
TRCell():New( oSection1, "RA_FILIAL"	, cAliasTmp, "Filial"			, PesqPict("SRA","RA_FILIAL")	, TamSx3("RA_FILIAL")[1]+10				,  )
TRCell():New( oSection1, "RA_MAT"		, cAliasTmp, "Matrícula"		, PesqPict("SRA","RA_MAT")		, TamSx3("RA_MAT")[1]+05					,  )
TRCell():New( oSection1, "RA_NOME"		, cAliasTmp, "Colaborador"		, PesqPict("SRA","RA_NOME")		, TamSx3("RA_NOME")[1]+100				,  )
*/

oSection1:SetPageBreak(.T.)

Return(oReport)
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Inicializa ReportPrint                                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function ReportPrint(oReport)
Local oSection1	:= oReport:Section(1)
Local cStartPath	:= GetSrvProfString("Startpath","")
Local aTotal	    := {"Total",0,0}
Local xMens := ""

DOR002RH1()

oSection1:Init()

dbSelectArea(cAliasTmp)
dbGoTop()

If nRecTMP > 0
   While (cAliasTmp)->(!Eof())
	
	  //-- Impressao do Relatorio
	  If oReport:Cancel()
		  Exit
	  EndIf

	  oSection1:Cell("RA_FILIAL") :SetValue((cAliasTmp)->RA_FILIAL)
	  oSection1:Cell("RA_MAT")    :SetValue((cAliasTmp)->RA_MAT)
	  oSection1:Cell("RA_NOME")   :SetValue((cAliasTmp)->RA_NOME)
	  oSection1:Cell("RA_CIC")    :SetValue((cAliasTmp)->RA_CIC)
	  oSection1:Cell("RA_PIS")    :SetValue((cAliasTmp)->RA_PIS)
	  oSection1:Cell("RA_BCDEPSA"):SetValue((cAliasTmp)->RA_BCDEPSA)
	  oSection1:Cell("RA_CTDEPSA"):SetValue((cAliasTmp)->RA_CTDEPSA)

/*
	  If MV_Par05 == 1
	  	 oSection1:Cell("RA_CIC"):SetValue((cAliasTmp)->RA_CIC)
	  ElseIf MV_Par05 == 2
	  	 oSection1:Cell("RA_PIS"):SetValue((cAliasTmp)->RA_PIS)
	  ElseIf MV_Par05 == 3
	  	 oSection1:Cell("RA_BCDEPSA"):SetValue((cAliasTmp)->RA_BCDEPSA)
	  	 oSection1:Cell("RA_CTDEPSA"):SetValue((cAliasTmp)->RA_CTDEPSA)
	  EndIf
*/

	  oSection1:PrintLine()
     aTotal[2]++	
	 (cAliasTmp)->(DbSkip()) 
	
   EndDo

   MsgInfo("Relatório de Duplicidades, Finalizado com Sucesso !!!"+Chr(13)+;
           "Foram Gerado(s): "+Alltrim(Str(nRecTMP))+" Duplicidades"+Chr(13)+;
           "Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Conferir..","*** FIM DO PROCESSAMENTO ***")

EndIf
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Finaliza ReportPrint                                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
xMens := "Gerados: "+Alltrim(Str(aTotal[2],10))

oSection1:Cell("RA_FILIAL") :SetValue("")
oSection1:Cell("RA_MAT")    :SetValue("")
oSection1:Cell("RA_NOME")   :SetValue("Total "+xMens)
oSection1:Cell("RA_CIC")    :SetValue("")
oSection1:Cell("RA_PIS")    :SetValue("")
oSection1:Cell("RA_BCDEPSA"):SetValue("")
oSection1:Cell("RA_CTDEPSA"):SetValue("")

/*
If MV_Par05 == 1
   oSection1:Cell("RA_CIC"):SetValue("")
ElseIf MV_Par05 == 2
   oSection1:Cell("RA_PIS"):SetValue("")
ElseIf MV_Par05 == 3
   oSection1:Cell("RA_BCDEPSA"):SetValue("")
   oSection1:Cell("RA_CTDEPSA"):SetValue("")
EndIf
*/

oReport:ThinLine()
oReport:IncMeter()
oSection1:PrintLine()
oSection1:Finish()
oSection1:PageBreak()

Return(Nil)
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Gera Registros para Tabela Temporaria                                       |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function DOR002RH1()

Local x := 0
Local cCrLf := Chr(13)+Chr(10)
Local cSitQuery := ""
Local cSituacao := StrTran(MV_Par03,"*","")
Local cCatQuery := ""
Local cCategoria:= StrTran(MV_Par04,"*","")

For x := 1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,x,1)+"'"
	If (x+1) <= Len(cSituacao)
		cSitQuery += ","
	EndIf
Next x

x := 0
For x := 1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,x,1)+"'"
	If (x+1) <= Len(cCategoria)
		cCatQuery += "," 
	Endif
Next x

cQuery := ""
cQuery += "Select "+cCrLf

/*
If MV_Par05 == 1
   cQuery += " SRA.RA_CIC,"+cCrLf
ElseIf MV_Par05 == 2
   cQuery += " SRA.RA_PIS,"+cCrLf
ElseIf MV_Par05 == 3
   cQuery += " SRA.RA_BCDEPSA,SRA.RA_CTDEPSA,"+cCrLf
EndIf
*/

cQuery += " SRA.RA_FILIAL,"+cCrLf
cQuery += " SRA.RA_MAT,"+cCrLf
cQuery += " SRA.RA_NOME,"+cCrLf
cQuery += " SRA.RA_CIC,"+cCrLf
cQuery += " SRA.RA_PIS,"+cCrLf
cQuery += " SRA.RA_BCDEPSA,SRA.RA_CTDEPSA"+cCrLf
cQuery += " From "+RetSqlName("SRA")+" SRA "+cCrLf
cQuery += " Where SRA.D_E_L_E_T_   = ' '  And "+cCrLf
cQuery += "  SRA.RA_FILIAL Between '"+MV_Par01+"' And '"+MV_Par02+"' And "+cCrLf
cQuery += "  SRA.RA_SITFOLH In ("+cSitQuery+") And "+cCrLf
cQuery += "  SRA.RA_CATFUNC In ("+cCatQuery+") And "+cCrLf

If MV_Par05 == 1
   cQuery += "  SRA.RA_CIC IN ("+cCrLf
   cQuery += "  Select RA.RA_CIC"+cCrLf
ElseIf MV_Par05 == 2
   cQuery += "  SRA.RA_PIS IN ("+cCrLf
   cQuery += "  Select RA.RA_PIS"+cCrLf
ElseIf MV_Par05 == 3
   cQuery += "  Concat(SRA.RA_BCDEPSA,SRA.RA_CTDEPSA) IN ("+cCrLf
   cQuery += "  Select Concat(RA.RA_BCDEPSA,RA.RA_CTDEPSA)"+cCrLf
EndIf

cQuery += "   From "+RetSqlName("SRA")+" RA "+cCrLf 
cQuery += "   Where RA.D_E_L_E_T_   = ' '  And"+cCrLf
cQuery += "    RA.RA_FILIAL Between '"+MV_Par01+"' And '"+MV_Par02+"' And "+cCrLf
cQuery += "    RA.RA_SITFOLH In ("+cSitQuery+") And "+cCrLf
cQuery += "    RA.RA_CATFUNC In ("+cCatQuery+") "+cCrLf

If MV_Par05 == 1
   cQuery += "    Group By RA.RA_CIC HAVING COUNT(*) > 1) "+cCrLf
   cQuery += "Order By SRA.RA_CIC,SRA.RA_FILIAL,SRA.RA_MAT"
ElseIf MV_Par05 == 2
   cQuery += "    Group By RA.RA_PIS HAVING COUNT(*) > 1) "+cCrLf
   cQuery += "Order By SRA.RA_PIS,SRA.RA_FILIAL,SRA.RA_MAT"
ElseIf MV_Par05 == 3
   cQuery += "    Group By Concat(RA.RA_BCDEPSA,RA.RA_CTDEPSA) HAVING COUNT(*) > 1) "+cCrLf
   cQuery += "Order By SRA.RA_BCDEPSA,SRA.RA_CTDEPSA,SRA.RA_FILIAL,SRA.RA_MAT"
EndIf

//MemoWrite("C:\TOTVS_Projects\Projetos\PROTHEUS_LOCAL\PROTHEUS12\Query\DOR002RH.SQL",cQuery)

cQuery	:= ChangeQuery(cQuery)

If Select(cAliasTmp) > 0
   DbSelectArea(cAliasTmp)
  (cAliasTmp)->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTmp, .F., .T.)

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

Count To nRecTMP

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| AJUSTASX1                                                                   |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
//Static Function ValidPerg()
//
//Local i,j    := 0
//Local aPergs := {}
//Local aRegs  := {}
//
//dbSelectArea("SX1")
//dbSetOrder(1)       
//
////cPerg:= cPerg + (Space( Len(SX1->X1_GRUPO)  - Len(cPerg) ) ) Thais Paiva - Compatibilização P27
//
///*          Grupo/Ordem  /Pergunta                                                         /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid       /Var01     /Def01               /Defspa1/Defeng1/Cnt01/Var02/Def02             /Defesp2/Defeng2/Cnt02/Var03/Def03/Defspa3  /defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3   /PYME/grpsxg  /HELP /PICTURE*/
//Aadd(aRegs,{cPerg, "01"  ,"Filial De        ?","Filial De       ?"   , "Filial De       ?"   ,"MV_CH0","C" ,08     ,0      ,0     ,"G",""          ,"mv_par01","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""         ,""     ,""     ,""   ,""        ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0","S" ,""     ,".RHFILDE. ",""})
//Aadd(aRegs,{cPerg, "02"  ,"Filial Ate       ?","Filial Ate      ?"   , "Filial Ate      ?"   ,"MV_CH0","C" ,08     ,0      ,0     ,"G",""          ,"mv_par02","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""         ,""     ,""     ,""   ,""        ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0","S" ,""     ,".RHFILATE.",""})
//Aadd(aRegs,{cPerg, "03"  ,"Situacao         ?","Situacao        ?"   , "Situacao        ?"   ,"MV_CH0","C" ,05     ,0      ,0     ,"G","fSituacao" ,"mv_par03","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""         ,""     ,""     ,""   ,""        ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,".RHSITUA. ",""})
//Aadd(aRegs,{cPerg, "04"  ,"Categoria        ?","Categoria       ?"   , "Categoria       ?"   ,"MV_CH0","C" ,15     ,0      ,0     ,"G","fCategoria","mv_par04","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""         ,""     ,""     ,""   ,""        ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,".RHCATEG. ",""})
//Aadd(aRegs,{cPerg, "05"  ,"Tipo Duplicidade ?","Tipo Duplicidade ?"  , "Tipo Duplicidade ?"  ,"MV_CH0","N" ,01     ,0      ,0     ,"N","          ","mv_par05","CPF           "   ,""     ,""     ,""   ,""   ,"PIS          "   ,""     ,""     ,""   ,""   ,"Bco/Conta",""     ,""     ,""   ,"Todas"   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""})
//
//For i := 1 to Len(aRegs)
//	If !dbSeek(cPerg+aRegs[i,2])
//		RecLock("SX1",.T.)
//		For j:=1 to FCount()
//			If j <= Len(aRegs[i])
//				FieldPut(j,aRegs[i,j])
//			Endif                                                                                              o
//		Next j
//		MsUnlock()
//	Endif
//Next i
//
//Return .t.