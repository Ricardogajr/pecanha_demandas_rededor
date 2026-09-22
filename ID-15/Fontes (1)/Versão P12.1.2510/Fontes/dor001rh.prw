#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | DOR001RH | AUTOR | Edsonho ®                 | DATA |28/03/2017 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - Valores de Verbas IGUAL a ZEROS                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

User Function DOR001RH()

Local oReport
Private cPerg    := Padr("DOR_RH001",10) 
Private nRecTMP  := 0
Private cAliasTmp:= "TMP"
Private cQuery   := ""
Private aOrdem   := {}
Private aTabelas := {"SRA","SRC","SRV","TMP"}
Public cMesAnoFol:=  "201605"

//ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
EndIf 

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
Private cTitulo := "Colaboradores Com Valores de Verbas Menor Igual a Zeros"
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
//oReport:SayBitmap ( 360, 30 ,"C:\A\REDEDOR.BMP", 1800, 1200)
oReport:= TReport():New("DOR001RH", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cTitulo )
oReport:SetPortrait()
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem)

TRCell():New( oSection1, "RA_FILIAL"	, cAliasTmp, "Filial"			, PesqPict("SRA","RA_FILIAL")	, TamSx3("RA_FILIAL")[1]+10						,  )
TRCell():New( oSection1, "RA_MAT"		, cAliasTmp, "Matrícula"		, PesqPict("SRA","RA_MAT")		, TamSx3("RA_MAT")[1]+05							,  )
TRCell():New( oSection1, "RA_NOME"		, cAliasTmp, "Colaborador"		, PesqPict("SRA","RA_NOME")		, TamSx3("RA_NOME")[1]+15						,  )
TRCell():New( oSection1, "RC_DATA"		, cAliasTmp, "Data"				, PesqPict("SRC","RC_DATA")		, TamSx3("RC_DATA")[1]+05						,  )
TRCell():New( oSection1, "RC_PD"		, cAliasTmp, "Verba"				, PesqPict("SRC","RC_PD")		, TamSx3("RC_PD")[1]+05							,  )
TRCell():New( oSection1, "RV_DESC"		, cAliasTmp, "Descrição Verba"	, PesqPict("SRV","RV_DESC")		, TamSx3("RV_DESC")[1]+15						,  )
TRCell():New( oSection1, "RC_VALOR"	, cAliasTmp, "Valor"				, PesqPict("SRC","RC_VALOR")	, TamSx3("RC_VALOR")[1]+50						,  )

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

DOR001RH1()

oSection1:Init()

dbSelectArea(cAliasTmp)
dbGoTop()

If nRecTMP > 0
   While (cAliasTmp)->(!Eof())
	
	  //-- Impressao do Relatorio
	  If oReport:Cancel()
		  Exit
	  EndIf

	  oSection1:Cell("RA_FILIAL"):SetValue((cAliasTmp)->RA_FILIAL)
	  oSection1:Cell("RA_MAT")   :SetValue((cAliasTmp)->RA_MAT)
	  oSection1:Cell("RA_NOME")  :SetValue((cAliasTmp)->RA_NOME)
	  oSection1:Cell("RC_DATA")  :SetValue((cAliasTmp)->RC_DATA)
	  oSection1:Cell("RC_PD")    :SetValue((cAliasTmp)->RC_PD)
	  oSection1:Cell("RV_DESC")  :SetValue((cAliasTmp)->RV_DESC)
	  oSection1:Cell("RC_VALOR") :SetValue((cAliasTmp)->RC_VALOR)

	  oSection1:PrintLine()
     aTotal[2]++	
	 (cAliasTmp)->(DbSkip()) 
	
   EndDo

   MsgInfo("Relatório de Verbas com Valor ZERO, Finalizado com Sucesso !!!"+Chr(13)+;
           "Foram Identificado(s): "+Alltrim(Str(nRecTMP))+" Verba(s)"+Chr(13)+;
           "Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Conferir..","*** FIM DO PROCESSAMENTO ***")

EndIf
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Finaliza ReportPrint                                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
xMens := "Gerados: "+Alltrim(Str(aTotal[2],10))

oSection1:Cell("RA_FILIAL"):SetValue("")
oSection1:Cell("RA_MAT")   :SetValue("")
oSection1:Cell("RA_NOME")  :SetValue("Total "+xMens)
oSection1:Cell("RC_DATA")  :SetValue("")
oSection1:Cell("RC_PD")    :SetValue("")
oSection1:Cell("RV_DESC")  :SetValue("")
oSection1:Cell("RC_VALOR") :SetValue("")

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
Static Function DOR001RH1()

Local x := 0
Local cCrLf := Chr(13)+Chr(10)
Local cSitQuery := ""
Local cSituacao := StrTran(MV_Par05,"*","")
Local cCatQuery := ""
Local cCategoria:= StrTran(MV_Par06,"*","")

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
cQuery += " SRA.RA_FILIAL,"+cCrLf
cQuery += " SRA.RA_MAT,"+cCrLf
cQuery += " SRA.RA_NOME,"+cCrLf
cQuery += " SRC.RC_DATA,"+cCrLf
cQuery += " SRC.RC_PD,"+cCrLf
cQuery += " SRV.RV_DESC,"+cCrLf
cQuery += " SRC.RC_VALOR"+cCrLf
cQuery += " From "+RetSqlName("SRA")+" SRA "+cCrLf
cQuery += " Inner Join "+RetSqlName("SRC")+" SRC On "+cCrLf
cQuery += "  SRA.RA_FILIAL  = SRC.RC_FILIAL And "+cCrLf 
cQuery += "  SRA.RA_MAT     = SRC.RC_MAT And SRC.D_E_L_E_T_   = ' '  "+cCrLf 
cQuery += " Left Outer Join "+RetSqlName("SRV")+" SRV On "+cCrLf
cQuery += "  SRV.RV_COD = SRC.RC_PD And SRV.D_E_L_E_T_   = ' '  "+cCrLf
cQuery += " Where SRA.D_E_L_E_T_   = ' '  And "+cCrLf
cQuery += "  SRA.RA_MAT Between '"+MV_Par03+"' And '"+MV_Par04+"' And "+cCrLf
cQuery += "  SRA.RA_SITFOLH In ("+cSitQuery+") And "+cCrLf
cQuery += "  SRA.RA_CATFUNC In ("+cCatQuery+") And "+cCrLf
cQuery += "  SRC.RC_PERIODO = '" + cMesAnoFol + "' And "+cCrLf
cQuery += "  SRC.RC_VALOR = 0 "+cCrLf
cQuery += "Order By SRA.RA_FILIAL,SRA.RA_MAT,SRC.RC_PD"

//MemoWrite("C:\TOTVS_Projects\Projetos\PROTHEUS_LOCAL\PROTHEUS12\Query\DOR001RH.SQL",cQuery)

ChangeQuery(cQuery)

If Select(cAliasTmp) > 0
   DbSelectArea(cAliasTmp)
  (cAliasTmp)->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTmp, .F., .T.)
TcSetField((cAliasTmp),"RC_DATA","D",8,0)

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
////cPerg:= cPerg + (Space( Len(SX1->X1_GRUPO)  - Len(cPerg) ) ) - Thais Paiva - Compatibilização P27
//
///*          Grupo/Ordem  /Pergunta                                                         /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid       /Var01     /Def01               /Defspa1/Defeng1/Cnt01/Var02/Def02             /Defesp2/Defeng2/Cnt02/Var03/Def03/Defspa3  /defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3   /PYME/grpsxg  /HELP /PICTURE*/
//Aadd(aRegs,{cPerg, "01"  ,"Filial De        ?","Filial De       ?"  , "Filial De       ?"   ,"MV_CH0","C" ,08     ,0      ,0     ,"G",""          ,"mv_par01","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0","S" ,""     ,".RHFILDE. ",""})
//Aadd(aRegs,{cPerg, "02"  ,"Filial Ate       ?","Filial Ate      ?"  , "Filial Ate      ?"   ,"MV_CH0","C" ,08     ,0      ,0     ,"G",""          ,"mv_par02","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0","S" ,""     ,".RHFILATE.",""})
//Aadd(aRegs,{cPerg, "03"  ,"Matricula De     ?","Matricula De    ?"  , "Matricula De    ?"   ,"MV_CH0","C" ,06     ,0      ,0     ,"G",""          ,"mv_par03","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA","S" ,""     ,".RHMATD.  ",""})
//Aadd(aRegs,{cPerg, "04"  ,"Matricula Ate    ?","Matricula Ate   ?"  , "Matricula Ate   ?"   ,"MV_CH0","C" ,06     ,0      ,0     ,"G",""          ,"mv_par04","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA","S" ,""     ,".RHMATA.  ",""})
//Aadd(aRegs,{cPerg, "05"  ,"Situacao         ?","Situacao        ?"  , "Situacao        ?"   ,"MV_CH0","C" ,05     ,0      ,0     ,"G","fSituacao" ,"mv_par05","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,".RHSITUA. ",""})
//Aadd(aRegs,{cPerg, "06"  ,"Categoria        ?","Categoria       ?"  , "Categoria       ?"   ,"MV_CH0","C" ,15     ,0      ,0     ,"G","fCategoria","mv_par06","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,""     ,".RHCATEG. ",""})
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