#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"                              
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
//==========================================================================================
/*/
Relatorio para extrair todos ferias ativas entre datas
@author     A.Shibao
@since      23/05/17
@param		
@version    P12
@return      
@project 
@client    
/*/                                 
//==========================================================================================
User Function DORRFERI()

Local oReport 

Private cPerg    := Padr("DORRFERI",10) 
Private nRecTMP  := 0
Private cAliasTmp:= "TMP"
Private cQuery   := ""
Private aOrdem   := {}
Private aTabelas := {"SRA","SRF"} //,"SRV","TMP"}

ValidPerg()
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
Private cTitulo := " ** Relação de programações de férias ativas no período ** "
Private cDesc   := " Relatório de programações de férias ativas no período.Será impresso de acordo com os parâmetros informados pelo usuário. "

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
DEFINE REPORT oReport NAME "DORRFERI" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| ReportPrint(oReport)} DESCRIPTION cDesc	

oReport:SetLandscape()
oReport:SetTotalInLine(.F.)     
oReport:nDevice		:=	4   // ja traz setado a opcao planilha.

oSection1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem)

TRCell():New( oSection1, "RA_FILIAL"	, cAliasTmp, "Filial"			, PesqPict("SRA","RA_FILIAL")	, TamSx3("RA_FILIAL")[1]+8	,  )
TRCell():New( oSection1, "RA_MAT"		, cAliasTmp, "Matrícula"		, PesqPict("SRA","RA_MAT")		, TamSx3("RA_MAT")[1]+06	,  )
TRCell():New( oSection1, "RA_NOME"		, cAliasTmp, "Colaborador"		, PesqPict("SRA","RA_NOME")		, TamSx3("RA_NOME")[1]+15	,  )
TRCell():New( oSection1, "RA_SITFOLH"	, cAliasTmp, "Situacao"		    , PesqPict("SRA","RA_SITFOLH")  , TamSx3("RA_SITFOLH")[1]+5 ,  )
TRCell():New( oSection1, "RA_CC"		, cAliasTmp, "Cod. C. Custo"    , PesqPict("SRA","RA_CC")		, TamSx3("RA_CC")[1]+11		,  )
TRCell():New( oSection1, "CTT_DESC01"   , cAliasTmp, "Desc. C.Custo"    , PesqPict("CTT","CTT_DESC01")	, TamSx3("CTT_DESC01")[1]+05,  )
TRCell():New( oSection1, "RF_DATABAS"   , cAliasTmp, "Ini. Per. Aquisi ", PesqPict("SRF","RF_DATABAS")	, TamSx3("RF_DATABAS")[1]+10,  )
TRCell():New( oSection1, "RF_DATAFIM"	, cAliasTmp, "Fim. Per. Aquisi ", PesqPict("SRF","RF_DATAFIM")	, TamSx3("RF_DATAFIM")[1]+10,  )
TRCell():New( oSection1, "RF_DFERVAT"   , cAliasTmp, "F. Venc. Dias"    , PesqPict("SRF","RF_DFERVAT")	, TamSx3("RF_DFERVAT")[1]+03,  )
TRCell():New( oSection1, "RF_DFERAAT"   , cAliasTmp, "F. Prop. Dias"    , PesqPict("SRF","RF_DFERAAT")	, TamSx3("RF_DFERAAT")[1]+03,  )
TRCell():New( oSection1, "Dt Lim Ideal" , cAliasTmp, "Dt Lim Ideal"     , PesqPict("SRF","RF_DATABAS")	, TamSx3("RF_DATABAS")[1]+10,  )
TRCell():New( oSection1, "Dt Lim Maximo", cAliasTmp, "Dt Lim Maximo"    , PesqPict("SRF","RF_DATABAS")	, TamSx3("RF_DATABAS")[1]+10,  )
TRCell():New( oSection1, "RF_DATAINI"   , cAliasTmp, "F. Programada"    , PesqPict("SRF","RF_DATAINI")	, TamSx3("RF_DATAINI")[1]+10,  )
TRCell():New( oSection1, "RF_DFEPRO1"   , cAliasTmp, "D. Programados"   , PesqPict("SRF","RF_DFEPRO1")	, TamSx3("RF_DFEPRO1")[1]+03,  )                                             
TRCell():New( oSection1, "RF_DATINI2"   , cAliasTmp, "F. Progr 2    "   , PesqPict("SRF","RF_DATINI2")	, TamSx3("RF_DATINI2")[1]+10,  )
TRCell():New( oSection1, "RF_DFEPRO2"   , cAliasTmp, "D. Progra2    "   , PesqPict("SRF","RF_DFEPRO2")	, TamSx3("RF_DFEPRO2")[1]+03,  )
TRCell():New( oSection1, "RF_DATINI3"   , cAliasTmp, "F. Progr 3    "   , PesqPict("SRF","RF_DATINI3")	, TamSx3("RF_DATINI3")[1]+10,  )
TRCell():New( oSection1, "RF_DFEPRO3"   , cAliasTmp, "D. Progra3    "   , PesqPict("SRF","RF_DFEPRO3")	, TamSx3("RF_DFEPRO3")[1]+03,  )
TRCell():New( oSection1, "RF_DFERANT"   , cAliasTmp, "D. Pagos       "  , PesqPict("SRF","RF_DFERANT")	, TamSx3("RF_DFERANT")[1]+03,  )
TRCell():New( oSection1, "RF_DVENPEN"   , cAliasTmp, "D. Pendentes   "  , PesqPict("SRF","RF_DVENPEN")	, TamSx3("RF_DVENPEN")[1]+03,  )
TRCell():New( oSection1, "RF_DFALVAT"   , cAliasTmp, "Falta Vencidas  " , PesqPict("SRF","RF_DFALVAT")	, TamSx3("RF_DFALVAT")[1]+03,  )
TRCell():New( oSection1, "RF_DFALAAT"   , cAliasTmp, "Falta Proporc.  " , PesqPict("SRF","RF_DFALAAT")	, TamSx3("RF_DFALAAT")[1]+03,  )

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

If oreport:nDevice <> 4 
	MsgAlert("Relatório disponível apenas em planilha")
	oReport:CancelPrint()
	Return( Nil )
EndIf 

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
	  
	  cDtLim:= cDtMax := ""
	  	
	  cDtLim:= dtoc((cAliasTmp)->RF_DATABAS + 366)
  	  cDtMax:= dtoc((cAliasTmp)->RF_DATABAS + 684)
	  
	  oSection1:Cell("RA_FILIAL")  :SetValue((cAliasTmp)->RA_FILIAL)
	  oSection1:Cell("RA_MAT")     :SetValue((cAliasTmp)->RA_MAT)
	  oSection1:Cell("RA_NOME")    :SetValue((cAliasTmp)->RA_NOME)
	  oSection1:Cell("RA_SITFOLH") :SetValue(Iif((cAliasTmp)->RA_SITFOLH == " ", "Ativo",Iif((cAliasTmp)->RA_SITFOLH == "A","Afastado",Iif((cAliasTmp)->RA_SITFOLH == "F","Férias","Demitido" ))))
	  oSection1:Cell("RA_CC")      :SetValue((cAliasTmp)->RA_CC)
	  oSection1:Cell("CTT_DESC01") :SetValue((cAliasTmp)->CTT_DESC01)
	  oSection1:Cell("RF_DATABAS") :SetValue((cAliasTmp)->RF_DATABAS)  //"Ini. Per. Aquisi "
	  oSection1:Cell("RF_DATAFIM") :SetValue((cAliasTmp)->RF_DATAFIM)  //"Fim. Per. Aquisi "    
  	  oSection1:Cell("RF_DFERVAT") :SetValue((cAliasTmp)->RF_DFERVAT)      
  	  oSection1:Cell("RF_DFERAAT") :SetValue((cAliasTmp)->RF_DFERAAT) 
  	  oSection1:Cell("Dt Lim Ideal") :SetValue(cDtLim)                   // Limite  	    	  
  	  oSection1:Cell("Dt Lim Maximo"):SetValue(cDtMax)                   // Limite max  	  
  	  oSection1:Cell("RF_DATAINI") :SetValue((cAliasTmp)->RF_DATAINI) 
  	  oSection1:Cell("RF_DFEPRO1") :SetValue((cAliasTmp)->RF_DFEPRO1)
  	  oSection1:Cell("RF_DATINI2") :SetValue((cAliasTmp)->RF_DATINI2)
  	  oSection1:Cell("RF_DFEPRO2") :SetValue((cAliasTmp)->RF_DFEPRO2)
  	  oSection1:Cell("RF_DATINI3") :SetValue((cAliasTmp)->RF_DATINI3)
  	  oSection1:Cell("RF_DFEPRO3") :SetValue((cAliasTmp)->RF_DFEPRO3)
  	  oSection1:Cell("RF_DFERANT") :SetValue((cAliasTmp)->RF_DFERANT)
  	  oSection1:Cell("RF_DVENPEN") :SetValue((cAliasTmp)->RF_DVENPEN)
  	  oSection1:Cell("RF_DFALVAT") :SetValue((cAliasTmp)->RF_DFALVAT)
  	  oSection1:Cell("RF_DFALAAT") :SetValue((cAliasTmp)->RF_DFALAAT)

	  oSection1:PrintLine()
	  
      aTotal[2]++	
      
	 (cAliasTmp)->(DbSkip()) 
	
   EndDo

   MsgInfo("Relatório de programações de férias no periodo, Finalizado com Sucesso !!!"+Chr(13)+;
           "                            *** FIM DO PROCESSAMENTO ***                  ")

EndIf


//==========================================================================================
// Finaliza ReportPrint                                                        
//==========================================================================================
xMens := "Gerados: "+Alltrim(Str(aTotal[2],10))

oSection1:Cell("RA_FILIAL")  :SetValue("")
oSection1:Cell("RA_MAT")     :SetValue("")
oSection1:Cell("RA_NOME")    :SetValue("Total "+xMens)
oSection1:Cell("RA_SITFOLH") :SetValue("")
oSection1:Cell("RA_CC")      :SetValue("")
oSection1:Cell("CTT_DESC01") :SetValue("")
oSection1:Cell("RF_DATABAS") :SetValue("")
oSection1:Cell("RF_DATAFIM") :SetValue("")
oSection1:Cell("RF_DFERVAT") :SetValue("")
oSection1:Cell("RF_DFERAAT") :SetValue("")
oSection1:Cell("Dt Lim Ideal") :SetValue("")
oSection1:Cell("Dt Lim Maximo") :SetValue("")
oSection1:Cell("RF_DATAINI") :SetValue("")
oSection1:Cell("RF_DFEPRO1") :SetValue("") 
oSection1:Cell("RF_DATINI2") :SetValue("") 
oSection1:Cell("RF_DFEPRO2") :SetValue("") 
oSection1:Cell("RF_DATINI3") :SetValue("") 
oSection1:Cell("RF_DFEPRO3") :SetValue("") 
oSection1:Cell("RF_DFERANT") :SetValue("") 
oSection1:Cell("RF_DVENPEN") :SetValue("") 
oSection1:Cell("RF_DFALVAT") :SetValue("") 
oSection1:Cell("RF_DFALAAT") :SetValue("") 

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
Local cShFil    := cShMat	:= cShCC := ""

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

	cShFil := IIf(Empty( mv_par01), "RA_FILIAL >= '"+SPACE(LEN(xfilial("SRA")))+"' AND RA_FILIAL <= '"+Replic("Z",LEN(xfilial("SRA")))+"'", mv_par01)
	cShMat := IIf(Empty( mv_par02), "RA_MAT    >= '"+SPACE(LEN(xfilial("SRA")))+"' AND RA_MAT    <= '"+Replic("Z",LEN(xfilial("SRA")))+"'", mv_par02)
	cShCC  := IIf(Empty( mv_par03), "RA_CC     >= '"+SPACE(LEN(xfilial("SRA")))+"' AND RA_CC     <= '"+Replic("Z",LEN(xfilial("SRA")))+"'", mv_par03)	
	cShTpF := Iif(Empty( mv_par06) .or. MV_PAR06 == 4 , "'1','2','3','4'", "'"+CVALTOCHAR(MV_PAR06)+"'")
	
	cQuery := ""
	cQuery += "SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_SITFOLH, CTT_DESC01, "				   	  +cCrLf
	cQuery += " RF_DATABAS, RF_DATAFIM, RF_DFERVAT, RF_DFERAAT, RF_DATABAS, RF_DATAINI, RF_DFEPRO1, " +cCrLf	
	cQuery += " RF_DATINI2, RF_DFEPRO2, RF_DATINI3, RF_DFEPRO3, RF_DFERANT, RF_DVENPEN, RF_DFALVAT, " +cCrLf		
	cQuery += " RF_DFALAAT, RF_STATUS  FROM "+RetSqlName("SRA")+" SRA "                  		      +cCrLf
	cQuery += " INNER JOIN "+RetSqlName("SRF")+" SRF On "											  +cCrLf
	cQuery += "  RA_FILIAL  = RF_FILIAL And "														  +cCrLf 
	cQuery += "  RA_MAT     = RF_MAT    And SRF.D_E_L_E_T_ <> '*' "                                   +cCrLf 
	cQuery += " LEFT OUTER JOIN "+RetSqlName("CTT")+" CTT On "                                        +cCrLf
	cQuery += "  RA_CC = CTT_CUSTO And CTT.D_E_L_E_T_ <> '*' "                                        +cCrLf
	cQuery += "  WHERE SRA.D_E_L_E_T_ <> '*' And "													  +cCrLf 
	cQuery += "  " + cShFil + " And "														  		  +cCrLf
	cQuery += "  " + cShMat + " And "														  		  +cCrLf
	cQuery += "  " + cShCC + " And "														  		  +cCrLf
	cQuery += "  RA_SITFOLH In ("+cSitQuery+") And "												  +cCrLf
	cQuery += "  RA_CATFUNC In ("+cCatQuery+") And "												  +cCrLf
	cQuery += "  RF_STATUS  In (" + cShTpF +") And "									      +cCrLf
	cQuery += "   ( RF_DATAINI >= '"+dtos(mv_par07)+"' And RF_DATAINI<= '"+dtos(mv_par08)+"'  OR "   +cCrLf
	cQuery += "      RF_DATINI2 >= '"+dtos(mv_par07)+"' And RF_DATINI2 <= '"+dtos(mv_par08)+"'  OR "  +cCrLf	
	cQuery += "       RF_DATINI3 >= '"+dtos(mv_par07)+"' And RF_DATINI3 <= '"+dtos(mv_par08)+"'  ) "  +cCrLf		
	cQuery += "ORDER BY RA_FILIAL,RA_MAT,RF_DATAINI  " 
	

ChangeQuery(cQuery)

If Select(cAliasTmp) > 0
   DbSelectArea(cAliasTmp)
  (cAliasTmp)->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTmp, .F., .T.)
TcSetField((cAliasTmp),"RF_DATAINI","D",8,0)
TcSetField((cAliasTmp),"RF_DATAFIM","D",8,0)
TcSetField((cAliasTmp),"RF_DATABAS","D",8,0)
TcSetField((cAliasTmp),"RF_DATINI2","D",8,0)
TcSetField((cAliasTmp),"RF_DATINI3","D",8,0)

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

Count To nRecTMP

Return    


//==========================================================================================
// AJUSTASX1                                                                  
//==========================================================================================
Static Function ValidPerg()

Local i,j    := 0
Local aPergs := {}
Local aRegs  := {}

dbSelectArea("SX1")
dbSetOrder(1)       

cPerg:= Padr("DORRFERI",10) 

/*          Grupo/Ordem  /Pergunta                                                         /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid       /Var01     /Def01               /Defspa1/Defeng1/Cnt01/Var02/Def02             /Defesp2/Defeng2/Cnt02/Var03/Def03/Defspa3  /defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3   /PYME/grpsxg  /HELP /PICTURE*/
Aadd(aRegs,{cPerg, "01"  ,"Filial           ?","Filial De       ?"  , "Filial De       ?"   ,"MV_CH1","C" ,99     ,0      ,0     ,"R",""          ,"mv_par01","              "   ,""     ,""     ,"RA_FILIAL"   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0"	,"S" ,""     ,".RHFILDE. ",""})
Aadd(aRegs,{cPerg, "02"  ,"Matricula        ?","Matricula De    ?"  , "Matricula De    ?"   ,"MV_CH2","C" ,99     ,0      ,0     ,"R",""          ,"mv_par02","              "   ,""     ,""     ,"RA_MAT"      ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA"	,"S" ,""     ,".RHMATD.  ",""})
Aadd(aRegs,{cPerg, "03"  ,"Centro de Custo  ?","Centro de Custo ?"  , "Centro de Custo  ?"  ,"MV_CH3","C" ,99     ,0      ,0     ,"R",""          ,"mv_par03","              "   ,""     ,""     ,"RA_CC"       ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"CTT"	,"S" ,""     ,".RHCCUSTO.",""})
Aadd(aRegs,{cPerg, "04"  ,"Situacao         ?","Situacao        ?"  , "Situacao        ?"   ,"MV_CH4","C" ,05     ,0      ,0     ,"G","fSituacao" ,"mv_par04","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,".RHSITUA. ",""})
Aadd(aRegs,{cPerg, "05"  ,"Categoria        ?","Categoria       ?"  , "Categoria       ?"   ,"MV_CH5","C" ,15     ,0      ,0     ,"G","fCategoria","mv_par05","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,".RHCATEG. ",""})
Aadd(aRegs,{cPerg, "06"  ,"Periodo          ?","Periodo          ?" , "Periodo          ?"  ,"MV_CH6","N" ,01     ,0      ,0     ,"C",""          ,"mv_par06","1-Ativo       "   ,"1-Ativo       "     ,"1-Ativo       "     ,""  ,""   ,"2-Prescrito"   ,"2-Prescrito"     ,"2-Prescrito"     ,""   ,""   ,"3-Pago"     ,"3-Pago"     ,"3-Pago"     ,""   ,""   ,"4-Todos"   ,"4-Todos"     ,"4-Todos"     ,""   ,""   ,""   ,""     ,""     ,""   ,"" ,"S" ,""     ,"",""})
Aadd(aRegs,{cPerg, "07"  ,"Data Inicio      ?","Data Inicio      ?" , "Data Inicio      ?"  ,"MV_CH7","D" ,08     ,0      ,0     ,"G",""          ,"mv_par07","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,"",""})
Aadd(aRegs,{cPerg, "08"  ,"Data Final       ?","Data Final       ?" , "Data Final       ?"  ,"MV_CH8","D" ,08     ,0      ,0     ,"G",""          ,"mv_par08","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,"",""})

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