#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"                              
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
//==========================================================================================
/*/
Relatorio para extrair todos afastamento incluidos entre data.  
@author     A.Shibao
@since      23/05/17
@param		
@version    P12
@return      
@project 
@client    
/*/                                 
//==========================================================================================
User Function DORRAFAS()

Local oReport 

Private cPerg    := Padr("DORRAFAS",10) 
Private nRecTMP  := 0
Private cAliasTmp:= "TMP"
Private cQuery   := ""
Private aOrdem   := {}
Private aTabelas := {"SRA","SR8"} //,"SRV","TMP"}

//ValidPerg()
Pergunte(cPerg,.F.)
//==========================================================================================
// Interface de Impressão                                                    
//==========================================================================================
oReport:= ReportDef(cPerg)
oReport:PrintDialog()

If Select(cAliasTmp) > 0
   DbSelectArea(cAliasTmp)
  (cAliasTmp)->(DbCloseArea())  
Endif

Return

//==========================================================================================
// ReportDef                                                                   
//==========================================================================================
Static Function ReportDef(cPerg)
Local oCell
Local oBreak
Private oReport
Private cTitulo := " ** Relação de Afastamentos Ocorridos no Período ** "
Private cDesc   := " Relatório de afastamentos ocorrido dentro do periodo.Será impresso de acordo com os parâmetros informados pelo usuário. "

//==========================================================================================
//| Criacao do componente de impressao                                          
//| TReport():New                                                               
//| ExpC1 : Nome do relatorio                                                   
//| ExpC2 : Titulo                                                              
//| ExpC3 : Pergunte                                                            
//| ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao      
//| ExpC5 : Descricao                                                           
//==========================================================================================
//oReport:SayBitmap ( 360, 30 ,"C:\A\REDEDOR.BMP", 1800, 1200)
//oReport:= TReport():New("DORRAFAS", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cTitulo )
DEFINE REPORT oReport NAME "DORRAFAS" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| ReportPrint(oReport)} DESCRIPTION cDesc	

oReport:SetPortrait()
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem)

TRCell():New( oSection1, "RA_FILIAL"	, cAliasTmp, "Filial"			, PesqPict("SRA","RA_FILIAL")	, TamSx3("RA_FILIAL")[1]+10	,  )
TRCell():New( oSection1, "RA_MAT"		, cAliasTmp, "Matrícula"		, PesqPict("SRA","RA_MAT")		, TamSx3("RA_MAT")[1]+05	,  )
TRCell():New( oSection1, "RA_NOME"		, cAliasTmp, "Colaborador"		, PesqPict("SRA","RA_NOME")		, TamSx3("RA_NOME")[1]+15	,  )
TRCell():New( oSection1, "RA_CC"		, cAliasTmp, "Cod. C. Custo"    , PesqPict("SRA","RA_CC")		, TamSx3("RA_CC")[1]+11		,  )
TRCell():New( oSection1, "CTT_DESC01"   , cAliasTmp, "Desc. C.Custo"    , PesqPict("CTT","CTT_DESC01")	, TamSx3("CTT_DESC01")[1]+30,  )
TRCell():New( oSection1, "R8_TIPOAFA"   , cAliasTmp, "Tp Afastamento"   , PesqPict("SR8","R8_TIPOAFA")	, TamSx3("R8_TIPOAFA")[1]+4	,  )
//TRCell():New( oSection1, fDescSX5(2)  , cAliasTmp, "Desc. Afast"      ,                               , 20                        ,  )
TRCell():New( oSection1, "DESCAFAST"    , cAliasTmp, "Desc. Afast"      ,                               , 20                        ,  )
TRCell():New( oSection1, "R8_DATAINI"	, cAliasTmp, "Data Inicio"  	, PesqPict("SR8","R8_DATAINI")	, TamSx3("R8_DATAINI")[1]+10,  )
TRCell():New( oSection1, "R8_DATAFIM"   , cAliasTmp, "Data Fim"  	    , PesqPict("SR8","R8_DATAFIM")	, TamSx3("R8_DATAFIM")[1]+10,  )

oSection1:SetPageBreak(.T.)

Return(oReport)


//==========================================================================================
// Inicializa ReportPrint                                                     
//==========================================================================================
Static Function ReportPrint(oReport)
Local oSection1	:= oReport:Section(1)
Local cStartPath	:= GetSrvProfString("Startpath","")
Local aTotal	    := {"Total",0,0}
Local xMens := ""

DORRAFAS1() 

oSection1:Init()

dbSelectArea(cAliasTmp)
dbGoTop()

If nRecTMP > 0
   While (cAliasTmp)->(!Eof())
	
	  //-- Impressao do Relatorio
	  If oReport:Cancel()
		  Exit
	  EndIf

	  oReport:IncMeter()
	  	
	  oSection1:Cell("RA_FILIAL")  :SetValue((cAliasTmp)->RA_FILIAL)
	  oSection1:Cell("RA_MAT")     :SetValue((cAliasTmp)->RA_MAT)
	  oSection1:Cell("RA_NOME")    :SetValue((cAliasTmp)->RA_NOME)
	  oSection1:Cell("RA_CC")      :SetValue((cAliasTmp)->RA_CC)
	  oSection1:Cell("CTT_DESC01") :SetValue((cAliasTmp)->CTT_DESC01)
	  oSection1:Cell("R8_TIPOAFA" ):SetValue((cAliasTmp)->R8_TIPOAFA)
//	  oSection1:Cell(fDescSX5(2))  :SetValue((cAliasTmp)->X5_DESCRI)	  
	  oSection1:Cell("DESCAFAST")  :SetValue(Posicione("RCM",1,xFilial("RCM")+(cAliasTmp)->R8_TIPOAFA,"RCM_DESCRI"))	  
	  oSection1:Cell("R8_DATAINI") :SetValue((cAliasTmp)->R8_DATAINI)      
  	  oSection1:Cell("R8_DATAFIM") :SetValue((cAliasTmp)->R8_DATAFIM)      
	  
	  oSection1:PrintLine()
	  
      aTotal[2]++	
      
	 (cAliasTmp)->(DbSkip()) 
	
   EndDo

   MsgInfo("Relatório de afastamento por periodo, Finalizado com Sucesso !!!"+Chr(13)+;
           "                  *** FIM DO PROCESSAMENTO ***                  ")

EndIf


//==========================================================================================
// Finaliza ReportPrint                                                        
//==========================================================================================
xMens := "Gerados: "+Alltrim(Str(aTotal[2],10))

oSection1:Cell("RA_FILIAL") :SetValue("")
oSection1:Cell("RA_MAT")    :SetValue("")
oSection1:Cell("RA_NOME")   :SetValue("Total "+xMens)
oSection1:Cell("RA_CC")     :SetValue("")
oSection1:Cell("CTT_DESC01"):SetValue("")
oSection1:Cell("R8_TIPOAFA"):SetValue("")
oSection1:Cell("R8_DATAINI"):SetValue("")
oSection1:Cell("R8_DATAFIM"):SetValue("")

oReport:ThinLine()
oReport:IncMeter()
oSection1:PrintLine()
oSection1:Finish()
oSection1:PageBreak()

Return(Nil)


//==========================================================================================
// Gera Registros para Tabela Temporaria                                       
//==========================================================================================
Static Function DORRAFAS1()

Local x := 0
Local cCrLf := Chr(13)+Chr(10)
Local cSitQuery := ""
Local cSituacao := StrTran(MV_Par04,"*","")
Local cCatQuery := ""
Local cCategoria:= StrTran(MV_Par05,"*","")
Local cShFil    := cShMat	:= cShCC :=  cShAfas:= ""

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
                                                   
//transforma os pergunte range em query
MakeSqlExpr(cPerg)   

	cShFil := IIf(Empty( mv_par01), "RA_FILIAL  >= '"+SPACE(LEN(xfilial("SRA")))+"' AND RA_FILIAL <= '"+Replic("Z",LEN(xfilial("SRA")))+"'", mv_par01)
	cShMat := IIf(Empty( mv_par02), "RA_MAT     >= '"+SPACE(LEN(xfilial("SRA")))+"' AND RA_MAT    <= '"+Replic("Z",LEN(xfilial("SRA")))+"'", mv_par02)
	cShCC  := IIf(Empty( mv_par03), "RA_CC      >= '"+SPACE(LEN(xfilial("SRA")))+"' AND RA_CC     <= '"+Replic("Z",LEN(xfilial("SRA")))+"'", mv_par03)	
	cShAfas:= IIf(Empty( mv_par06), "R8_TIPOAFA >= '"+SPACE(LEN(xfilial("SR8")))+"' AND R8_TIPOAFA<= '"+Replic("Z",LEN(xfilial("SRA")))+"'", mv_par06)	
	
	cQuery := ""
	cQuery += "SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, R8_DATAINI, R8_DATAFIM, R8_TIPO, X5_DESCRI, " +cCrLf
	cQuery += " R8_TIPOAFA, CTT_DESC01 FROM "+RetSqlName("SRA")+" SRA "                               +cCrLf
	cQuery += " INNER JOIN "+RetSqlName("SR8")+" SR8 On "											  +cCrLf
	cQuery += "  RA_FILIAL  = R8_FILIAL And "														  +cCrLf 
	cQuery += "  RA_MAT     = R8_MAT    And SR8.D_E_L_E_T_ = ' '  "                                   +cCrLf 
	cQuery += " LEFT OUTER JOIN "+RetSqlName("CTT")+ " CTT On "                                       +cCrLf
	cQuery += "  RA_CC = CTT_CUSTO And CTT.D_E_L_E_T_ = ' '  "                                        +cCrLf
	cQuery += " LEFT OUTER JOIN "+RetSqlName("SX5")+ " SX5 On "                                       +cCrLf
	cQuery += "  X5_FILIAL = '"   +xFilial("SX5")+ "' AND "                                           +cCrLf
	cQuery += "  X5_TABELA = '30'  AND "                                                              +cCrLf
	cQuery += "  X5_CHAVE = R8_TIPO AND "                                                             +cCrLf
	cQuery += "  SX5.D_E_L_E_T_ = ' '  "                                                              +cCrLf
	cQuery += "  WHERE SRA.D_E_L_E_T_ = ' '  And "													  +cCrLf 
	cQuery += "  " + cShFil + " And "														  		  +cCrLf
	cQuery += "  " + cShMat + " And "														  		  +cCrLf
	cQuery += "  " + cShCC + " And "														  		  +cCrLf
	cQuery += "  RA_SITFOLH In ("+cSitQuery+") And "												  +cCrLf
	cQuery += "  RA_CATFUNC In ("+cCatQuery+") And "												  +cCrLf
	cQuery += "  " + cShAfas + " And "														  		  +cCrLf
	cQuery += "  R8_DATAINI >= '"+dtos(mv_par07)+"' And R8_DATAINI <= '"+dtos(mv_par08)+"'  "		  +cCrLf																			  +cCrLf
	cQuery += "ORDER BY RA_FILIAL,RA_MAT,R8_DATAINI  " 
	
ChangeQuery(cQuery)

If Select(cAliasTmp) > 0
   DbSelectArea(cAliasTmp)
  (cAliasTmp)->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTmp, .F., .T.)
TcSetField((cAliasTmp),"R8_DATAINI","D",8,0)
TcSetField((cAliasTmp),"R8_DATAFIM","D",8,0)

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

Count To nRecTMP

Return    


//==========================================================================================
// AJUSTASX1                                                                  
//==========================================================================================
//Static Function ValidPerg()
//
//Local i,j    := 0
//Local aPergs := {}
//Local aRegs  := {}
//
//dbSelectArea("SX1")
//dbSetOrder(1)       
//
//cPerg:= Padr("DORRAFAS",10) 
//
///*          Grupo/Ordem  /Pergunta                                                         /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid       /Var01     /Def01               /Defspa1/Defeng1/Cnt01/Var02/Def02             /Defesp2/Defeng2/Cnt02/Var03/Def03/Defspa3  /defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3   /PYME/grpsxg  /HELP /PICTURE*/
//Aadd(aRegs,{cPerg, "01"  ,"Filial           ?","Filial De       ?"  , "Filial De       ?"   ,"MV_CH1","C" ,99     ,0      ,0     ,"R",""          ,"mv_par01","              "   ,""     ,""     ,"RA_FILIAL"   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0"	,"S" ,""     ,".RHFILDE. ",""})
//Aadd(aRegs,{cPerg, "02"  ,"Matricula        ?","Matricula De    ?"  , "Matricula De    ?"   ,"MV_CH2","C" ,99     ,0      ,0     ,"R",""          ,"mv_par02","              "   ,""     ,""     ,"RA_MAT"      ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA"	,"S" ,""     ,".RHMATD.  ",""})
//Aadd(aRegs,{cPerg, "03"  ,"Centro de Custo  ?","Centro de Custo ?"  , "Centro de Custo  ?"  ,"MV_CH3","C" ,99     ,0      ,0     ,"R",""          ,"mv_par03","              "   ,""     ,""     ,"RA_CC"       ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"CTT"	,"S" ,""     ,".RHCCUSTO.",""})
//Aadd(aRegs,{cPerg, "04"  ,"Situacao         ?","Situacao        ?"  , "Situacao        ?"   ,"MV_CH4","C" ,05     ,0      ,0     ,"G","fSituacao" ,"mv_par04","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,".RHSITUA. ",""})
//Aadd(aRegs,{cPerg, "05"  ,"Categoria        ?","Categoria       ?"  , "Categoria       ?"   ,"MV_CH5","C" ,15     ,0      ,0     ,"G","fCategoria","mv_par05","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,".RHCATEG. ",""})
//Aadd(aRegs,{cPerg, "06"  ,"Tipo Afastamento ?","Tipo Afastamento ?" , "Tipo Afastamento ?"  ,"MV_CH6","C" ,03     ,0      ,0     ,"R",""          ,"mv_par06","              "   ,""     ,""     ,"R8_TIPOAFA"  ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"RCMBRA" ,"S" ,""     ,"",""})
//Aadd(aRegs,{cPerg, "07"  ,"Data Inicio      ?","Data Inicio      ?" , "Data Inicio      ?"  ,"MV_CH7","D" ,08     ,0      ,0     ,"G",""          ,"mv_par07","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,"",""})
//Aadd(aRegs,{cPerg, "08"  ,"Data Final       ?","Data Final       ?" , "Data Final       ?"  ,"MV_CH8","D" ,08     ,0      ,0     ,"G",""          ,"mv_par08","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,"",""})
//
//For i := 1 to Len(aRegs)
//	If !dbSeek(cPerg+aRegs[i,2])
//		RecLock("SX1",.T.)
//		For j:=1 to FCount()
//			If j <= Len(aRegs[i])
//				FieldPut(j,aRegs[i,j])
//			Endif                                                                                              
//		Next j
//		MsUnlock()
//	Endif
//Next i
//
//Return .t.