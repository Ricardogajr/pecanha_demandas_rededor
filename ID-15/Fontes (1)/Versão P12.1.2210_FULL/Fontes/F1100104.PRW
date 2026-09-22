#Include "totvs.ch"

/*/
{Protheus.doc} F1100104
Relatório de Log Atestados Médicos
@type function
@author  Nairan Alves Silva
@since   01/08/2017
@version P12.1.7
@menu    F11100101
@project MAN0000007423045_EF_003
/*/

User Function F1100104()
	
	Local aPergs 		:= {}
	Local oReport		:= Nil
	
	Private cPerg  := "FSW1100401"
	Private aAnswers:= {}
	
	ValidPerg(cPerg)

	Pergunte(cPerg)
	
	oReport := ReportDef(cPerg)
	
	Criatab()
	
	oReport:PrintDialog()
	
Return

/*/
{Protheus.doc} ReportDef
@type function
@author  anieli.rodrigues
@since   10/05/2017
@version P11.5
@menu
@project T09025000010101_EF_017
/*/

Static Function ReportDef(cPerg)
	
	Local oReport
	Local oSection1
	Local oCell
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New("F1100104", "Log de Afastamentos", cPerg, {|oReport| ReportPrint(oReport)}, "Este relatório lista os logs dos atestados conforme filtro selecionado")
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	
	oSection1 := TRSection():New(oReport, "Afastamento" ,{"F1100104"})
	
	TRCell():New(oSection1, "PAG_TPMAN" 	,"F1100104", "Tp Manutençao"/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1, "PAG_DTMAN" 	,"F1100104", "Dt Manutençao")
	TRCell():New(oSection1, "PAG_HRMAN" 	,"F1100104", "Hr Manutençao")
	TRCell():New(oSection1, "PAG_NUSER" 	,"F1100104", "Código do Usuario")
	TRCell():New(oSection1, "PAG_NOMEUSR" 	,"F1100104", "Nome do Usuario")
	TRCell():New(oSection1, "PAG_FILIAL" 	,"F1100104", "Filial")
	TRCell():New(oSection1, "PAG_CC"  		,"F1100104", "Centro Custo")
	TRCell():New(oSection1, "PAG_DESCCC" 	,"F1100104", "Desc C.Custo")
	TRCell():New(oSection1, "PAG_MAT" 		,"F1100104", "Cod.Matric")
	TRCell():New(oSection1, "PAG_NOME"   	,"F1100104", "Nome Func.")
	TRCell():New(oSection1, "PAG_ADMISS"	,"F1100104", "Dt. Admissao")
	TRCell():New(oSection1, "PAG_SITFOL"	,"F1100104", "Sit. Folha")
	TRCell():New(oSection1, "PAG_CATFUN" 	,"F1100104", "Cat. Funcion")
	TRCell():New(oSection1, "PAG_CDAFAS" 	,"F1100104", "Cod Ausencia")
	TRCell():New(oSection1, "PAG_TPDESC"   	,"F1100104", "Desc. Ausenc")
	TRCell():New(oSection1, "PAG_SEQAFA"	,"F1100104", "Sequencia")
	TRCell():New(oSection1, "PAG_DTAFAS"	,"F1100104", "Data Afast.")
	TRCell():New(oSection1, "PAG_DTRETO"	,"F1100104", "Dt Fim Afast")
	
Return(oReport)

//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
/*
{Protheus.doc} ReportPrint
@type function
@author  anieli.rodrigues
@since   10/05/2017
@version P11.5
@menu
@project T09025000010101_EF_017
/*/
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Static Function ReportPrint(oReport)
	Local cQuery		:= ""
	Local oSection1 	:= oReport:Section(1)

	If oreport:nDevice <> 4 
		MsgAlert("Relatório disponível apenas em planilha")
		oReport:CancelPrint()
		Return( Nil )
	EndIf 

	cAliasPAG := "F1100104"
	
	If Select(cAliasPAG) > 0
		Dbselectarea("F1100104")
		DbClosearea()
	EndIf

	//transforma os pergunte range em query
	MakeSqlExpr(cPerg)   

	cQuery := " SELECT PAG_TPMAN, PAG_DTMAN, PAG_HRMAN, PAG_NUSER, PAG_FILIAL, PAG_CC, PAG_DESCCC, PAG_MAT, PAG_NOME, PAG_ADMISS, PAG_SITFOL, PAG_CATFUN, PAG_CDAFAS, PAG_TPDESC, PAG_SEQAFA, PAG_DTAFAS, PAG_DTRETO "
	cQuery += " FROM "+RetSqlName("PAG")+" PAG "
	cQuery += " WHERE "
	If !Empty(MV_PAR01)
		cQuery += " "+MV_PAR01+" AND "
	EndIf
	If !Empty(MV_PAR02)
		cQuery += " "+MV_PAR02+" AND "
	EndIf
	cQuery += " (INSTR('"+(MV_PAR03)+"',PAG_SITFOL) > 0) "
	cQuery += " AND (INSTR('"+(MV_PAR04)+"',PAG_CATFUN) > 0) "
	cQuery += " AND PAG_DTMAN BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "
	cQuery += " AND PAG.D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasPAG)
	
	TCSetField(cAliasPAG, "PAG_ADMISS" , "D", 8, 0)
	TCSetField(cAliasPAG, "PAG_DTMAN" , "D", 8, 0)
	TCSetField(cAliasPAG, "PAG_DTAFAS", "D", 8, 0)
	TCSetField(cAliasPAG, "PAG_DTRETO", "D", 8, 0)

	oSection1:Init()
	
	While !oReport:Cancel() .And. !(cAliasPAG)->(EoF())
		
		oReport:IncMeter()
		oSection1:Cell("PAG_NOMEUSR"):SetValue(UsrRetName( (cAliasPAG)->PAG_NUSER ))		
		oSection1:PrintLine()
		(cAliasPAG)->(DbSkip())
	End
	
	oSection1:Finish()
	(cAliasPAG)->(DbCloseArea())
	
Return Nil



Static Function ValidPerg(cPerg)

Local i,j    := 0
Local aPergs := {}
Local aRegs  := {}

dbSelectArea("SX1")
dbSetOrder(1)       

/*          Grupo/Ordem  /Pergunta                                                         /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid       /Var01     /Def01               /Defspa1/Defeng1/Cnt01/Var02/Def02             /Defesp2/Defeng2/Cnt02/Var03/Def03/Defspa3  /defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3   /PYME/grpsxg  /HELP /PICTURE*/
Aadd(aRegs,{cPerg, "01"  ,"Filial           ?","Filial De       ?"  , "Filial De       ?"   ,"MV_CH1","C" ,99     ,0      ,0     ,"R",""          ,"mv_par01","              "   ,""     ,""     ,"PAG_FILIAL"   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0"	,"S" ,""     ," ",""})
Aadd(aRegs,{cPerg, "02"  ,"Tipo Afastamento ?","Tipo Afastamento?"  , "Tipo Afastamento?"   ,"MV_CH2","C" ,99     ,0      ,0     ,"R",""          ,"mv_par02","              "   ,""     ,""     ,"PAG_CDAFAS"  ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"RCMMDT","S" ,""     ,"  ",""})
Aadd(aRegs,{cPerg, "03"  ,"Situacao         ?","Situacao        ?"  , "Situacao        ?"   ,"MV_CH4","C" ,05     ,0      ,0     ,"G","fSituacao" ,"mv_par04","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"","S" ,""     ,"",""})
Aadd(aRegs,{cPerg, "04"  ,"Categoria        ?","Categoria       ?"  , "Categoria       ?"   ,"MV_CH5","C" ,15     ,0      ,0     ,"G","fCategoria","mv_par05","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ," ",""})
Aadd(aRegs,{cPerg, "05"  ,"Data Inicio      ?","Data Inicio      ?" , "Data Inicio      ?"  ,"MV_CH7","D" ,08     ,0      ,0     ,"G",""          ,"mv_par07","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,"",""})
Aadd(aRegs,{cPerg, "06"  ,"Data Final       ?","Data Final       ?" , "Data Final       ?"  ,"MV_CH8","D" ,08     ,0      ,0     ,"G",""          ,"mv_par08","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,"",""})

For i := 1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif                                                                                              
		Next j
		MsUnlock()
	Endif
Next i

Return .t.

Static Function Criatab()

// Forca a criacão da tabela temporária para validação da session do relatorio
Local cQuery:= ""
Local MV_PAR05:= CTOD("//")
Local MV_PAR06:= CTOD("//")
Local cAliasPAG := "F1100104"
	
	If Select(cAliasPAG) > 0
		Dbselectarea("F1100104")
		DbClosearea()
	EndIf

	//transforma os pergunte range em query
	MakeSqlExpr(cPerg)   

	cQuery := " SELECT PAG_TPMAN, PAG_DTMAN, PAG_HRMAN, PAG_NUSER, PAG_FILIAL, PAG_CC, PAG_DESCCC, PAG_MAT, PAG_NOME, PAG_ADMISS, PAG_SITFOL, PAG_CATFUN, PAG_CDAFAS, PAG_TPDESC, PAG_SEQAFA, PAG_DTAFAS, PAG_DTRETO "
	cQuery += " FROM "+RetSqlName("PAG")+" PAG "
	cQuery += " WHERE "
	If !Empty(MV_PAR01)
		cQuery += " "+MV_PAR01+" AND "
	EndIf
	If !Empty(MV_PAR02)
		cQuery += " "+MV_PAR02+" AND "
	EndIf
	cQuery += " (INSTR('"+(MV_PAR03)+"',PAG_SITFOL) > 0) "
	cQuery += " AND (INSTR('"+(MV_PAR04)+"',PAG_CATFUN) > 0) "
	cQuery += " AND PAG_DTMAN BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "
	cQuery += " AND PAG.D_E_L_E_T_ = ' ' "
	dbUseArea(.T., "TOPCONN", TcGenQry(, ,cQuery), cAliasPAG)
	
	TCSetField(cAliasPAG, "PAG_ADMISS" , "D", 8, 0)
	TCSetField(cAliasPAG, "PAG_DTMAN" , "D", 8, 0)
	TCSetField(cAliasPAG, "PAG_DTAFAS", "D", 8, 0)
	TCSetField(cAliasPAG, "PAG_DTRETO", "D", 8, 0)

Return