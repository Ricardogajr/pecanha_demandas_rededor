#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"                              
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
//==========================================================================================
/*/
Relatorio para extrair aumentos salariais. 
@author     A.Shibao
@since      23/05/17
@param		
@version    P12
@return      
@project 
@client    
/*/                                 
//==========================================================================================
User Function DorRAumS()

Local oReport
Local aArea := GetArea()

Private cPerg     := Padr("DORRAUMS",10) 
Private cAliasQry := GetNextAlias() 
Private cQuery    := ""   
Private nRecTMP   := 0      
Private aTabelas := {"SRA","SR8","CTT","SRJ","SQ3","SR3","SR7"}

ValidPerg()
Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport :PrintDialog()	
RestArea( aArea )

Return

//==========================================================================================
// ReportDef                                                                   
//==========================================================================================
Static Function ReportDef()

Local oReport
Local oSection1	
Local oSection2
Local aOrdem    := {}  
/*
Local cAliAsSR7 := cAliasQry
Local cAliasSRA := cAliasQry  
Local cAliasSRJ := cAliasQry
Local cAliasCTT := cAliasQry
Local cAliasSQ3 := cAliasQry 
Local cAliasSX5 := cAliasQry
Local cAliAsSR3 := cAliasQry 
*/
Private cDesc   := " Relatório de aumentos salariais ocorridos dentro do periodo.Será impresso de acordo com os parâmetros informados pelo usuário. "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "DORRAUMS" TITLE "Aumentos Salariais" PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cDesc	
/*
Aadd( aOrdem, STR0004)	// "Matricula"
Aadd( aOrdem, STR0005)	// "Funcao"                 
Aadd( aOrdem, STR0006)	// "Centro de Custo"         
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: "Funcionario"
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
oSection1 := TRSection():New(oReport,"Funcionario",aTabelas/*,aOrdem,Campos do SX3*/,/*Campos do SIX*/)	//Funcionario	
oSection1:SetTotalInLine(.T.)  
oSection1:SetHeaderBreak(.F.)   

TRCell():New(oSection1,"R7_FILIAL"	,cAliasQry	,"Filial"   			   , PesqPict("SR7","R7_FILIAL") , TamSx3("R7_FILIAL")[1]+10 ,  )
TRCell():New(oSection1,"R7_MAT"		,cAliasQry	,"Matricula"			   , PesqPict("SR7","R7_MAT")	 , TamSx3("R7_MAT")[1]+10	 ,  )
TRCell():New(oSection1,"RA_NOME"	,cAliasQry	,"Nome"     			   , PesqPict("SRA","RA_NOME")	 , TamSx3("RA_NOME")[1]+50	 ,  )	
TRCell():New(oSection1,"RA_SALARIO"	,cAliasQry	,"Salario"  			   , PesqPict("SRA","RA_SALARIO"), TamSx3("RA_SALARIO")[1]+12,  )
TRCell():New(oSection1,"R7_CATFUNC" ,cAliasQry  ,"Categoria do Funcionario", PesqPict("SR7","R7_CATFUNC"), TamSx3("R7_CATFUNC")[1]+4 ,  )
TRCell():New(oSection1,"R7_FUNCAO"	,cAliasQry  ,"Cod Funcao"			   , PesqPict("SR7","R7_FUNCAO") , TamSx3("R7_FUNCAO")[1]+7 ,  )
TRCell():New(oSection1,"R7_DESCFUN"	,cAliasQry  ,"Desc Funcao"			   , PesqPict("SR7","R7_DESCFUN"), TamSx3("R7_DESCFUN")[1]+20,  )
TRCell():New(oSection1,"RA_CC"		,cAliasQry  ,"Cod CC."				   , PesqPict("SRA","RA_CC")	 , TamSx3("RA_CC")[1]+10	 ,  )
TRCell():New(oSection1,"Desc. CC"	,cAliasQry  ,"Desc. CC"				   ,,30)															//, PesqPict("CTT","CTT_DESC01"), TamSx3("CTT_DESC01")[1]+30,  )

TRCell():New(oSection1,"R7_DATA"	,cAliasQry	,"Data Alter. Salarial"    , PesqPict("SR7","R7_DATA")	 , TamSx3("R7_DATA")[1]+10	 ,  )
TRCell():New(oSection1,"R7_TIPO"	,cAliasQry  ,"Tp Alteracao Salarial"   , PesqPict("SR7","R7_TIPO")	 , TamSx3("R7_TIPO")[1]+5	 ,  )
TRCell():New(oSection1,fDescSX5(2)	,"SX5"	    ,""					  	   ,,20)															//Descricao do Tipo da Alteracao Salarial 
TRCell():New(oSection1,"Valor Atual",cAliasQry  ,"Valor Atual"			   ,,12)
TRCell():New(oSection1,"R7_CATFUNC" ,cAliasQry  ,"Categoria "			   , PesqPict("SR7","R7_CATFUNC"), TamSx3("R7_CATFUNC")[1]+4 ,  )
TRCell():New(oSection1,"R7_FUNCAO"  ,cAliasQry  ,"Cod Funcao"			   , PesqPict("SR7","R7_FUNCAO") , TamSx3("R7_FUNCAO")[1]+7  ,  )
TRCell():New(oSection1,"R7_DESCFUN"	,cAliasQry  ,"Desc Funcao"			   , PesqPict("SR7","R7_DESCFUN"), TamSx3("R7_DESCFUN")[1]+20,  )
TRCell():New(oSection1,"R7_CARGO"   ,cAliasQry  ,"Cod Cargo"			   , PesqPict("SR7","R7_CARGO")	 , TamSx3("R7_CARGO")[1]+7	 ,  )
TRCell():New(oSection1,"R7_DESCCAR" ,cAliasQry  ,"Desc. Cargo"			   , PesqPict("SR7","R7_DESCCAR"), TamSx3("R7_DESCCAR")[1]+20,  )
TRCell():New(oSection1,"Vlr Anterior",cAliasQry ,"Vlr Anterior"   		   ,,12)															//, PesqPict("SR3","R3_ANTEAUM"), TamSx3("R3_ANTEAUM")[1]+12,  )
         
//oSection1:Cell("RJ_DESC"):SetBlock( {|| DescFun( (cAliasQry)->R7_FUNCAO,(cAliasQry)->RA_FILIAL) } )
//oSection1:SetPageBreak(.T.)

Return oReport 

//==========================================================================================
// Inicializa ReportPrint                                                     
//==========================================================================================
Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)
Local nOrdem  	:= osection1:GetOrder()      
Local cCampo    := "%" + fDescSX5(2) + "%"   
Local lQuery    := .F. 
Local cOrder	:= "" 
Local cSitQuery	:= ""      

DORQRYAUM()

oSection1:Init()

dbSelectArea(cAliasQry)
dbGoTop()

If nRecTMP > 0
   While (cAliasQry)->(!Eof())
	
	  //-- Impressao do Relatorio
	  If oReport:Cancel()
		  Exit
	  EndIf

	  oReport:IncMeter()

	  oSection1:Cell("R7_FILIAL")  :SetValue((cAliasQry)->R7_FILIAL)
	  oSection1:Cell("R7_MAT")     :SetValue((cAliasQry)->R7_MAT)
	  oSection1:Cell("RA_NOME")    :SetValue((cAliasQry)->RA_NOME)
	  oSection1:Cell("RA_SALARIO") :SetValue((cAliasQry)->RA_SALARIO)	  
	  oSection1:Cell("R7_CATFUNC") :SetValue((cAliasQry)->R7_CATFUNC)	  	  
	  oSection1:Cell("R7_FUNCAO")  :SetValue((cAliasQry)->R7_FUNCAO)	  	  	  
	  oSection1:Cell("R7_DESCFUN") :SetValue((cAliasQry)->R7_DESCFUN)
	  oSection1:Cell("RA_CC")      :SetValue((cAliasQry)->RA_CC)	  
	  oSection1:Cell("Desc. CC")   :SetValue((cAliasQry)->CTT_DESC01)
	  oSection1:Cell("R7_DATA")    :SetValue((cAliasQry)->R7_DATA)
	  oSection1:Cell("R7_TIPO" )   :SetValue((cAliasQry)->R7_TIPO)	  
	  oSection1:Cell(fDescSX5(2))  :SetValue(Subst(FDesc("X41","41"+(cAliasQry)->R7_TIPO,fDescSX5(2)),1,15)) //ajustar	  
	  oSection1:Cell("Valor Atual"):SetValue(Posicione("SR3",1,(cAliasQry)->R7_FILIAL+(cAliasQry)->R7_MAT+DTOS((cAliasQry)->R7_DATA)+(cAliasQry)->R7_TIPO,"R3_VALOR"))      
  	  oSection1:Cell("R7_CATFUNC") :SetValue((cAliasQry)->R7_CATFUNC) 
  	  oSection1:Cell("R7_FUNCAO")  :SetValue((cAliasQry)->R7_FUNCAO) 
  	  oSection1:Cell("R7_DESCFUN") :SetValue((cAliasQry)->R7_DESCFUN)   	    	  
  	  oSection1:Cell("R7_CARGO")   :SetValue((cAliasQry)->R7_CARGO) 	                                                                  
  	  oSection1:Cell("R7_DESCCAR") :SetValue((cAliasQry)->R7_DESCCAR) 	
  	  oSection1:Cell("Vlr Anterior"):SetValue(Posicione("SR3",1,(cAliasQry)->R7_FILIAL+(cAliasQry)->R7_MAT+DTOS((cAliasQry)->R7_DATA)+(cAliasQry)->R7_TIPO,"R3_ANTEAUM"))
  	  
	  oSection1:PrintLine()
	  
	 (cAliasQry)->(DbSkip()) 
	
   EndDo

   MsgInfo("Relatório de Aumentos Salariais, Finalizado com Sucesso !!!"+Chr(13)+;
           "                  *** FIM DO PROCESSAMENTO ***                  ")

EndIf


//==========================================================================================
// Finaliza ReportPrint                                                        
//==========================================================================================
//oReport:ThinLine()
//oReport:IncMeter()
//oSection1:PrintLine()
oSection1:Finish()
//oSection1:PageBreak()

Return(Nil)


//==========================================================================================
// Gera Registros para Tabela Temporaria                                       
//==========================================================================================
Static Function DORQRYAUM()

Local cCrLf     := Chr(13)+Chr(10)
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

	cShFil := IIf(Empty( mv_par01), "R7_FILIAL  >= '"+SPACE(LEN(xfilial("SR7")))+"' AND R7_FILIAL <= '"+Replic("Z",LEN(xfilial("SR7")))+"'", mv_par01)
	cShMat := IIf(Empty( mv_par02), "R7_MAT     >= '"+SPACE(LEN(xfilial("SR7")))+"' AND R7_MAT    <= '"+Replic("Z",LEN(xfilial("SR7")))+"'", mv_par02)
	cShCC  := IIf(Empty( mv_par03), "RA_CC      >= '"+SPACE(LEN(xfilial("SR7")))+"' AND RA_CC     <= '"+Replic("Z",LEN(xfilial("SRA")))+"'", mv_par03)	
	cShAfas:= IIf(Empty( mv_par06), "R7_TIPO    >= '"+SPACE(LEN(xfilial("SR7")))+"' AND R7_TIPO   <= '"+Replic("Z",LEN(xfilial("SR7")))+"'", mv_par06)	
	 
	
    cOrder := "R7_FILIAL,R7_MAT,R7_DATA" 
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Situacao do Funcionario  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cSitQuery += "' ','A','F'"  
	
/*
	cQuery := ""                        
	cQuery += "	SELECT	RA_FILIAL,RA_MAT,RA_NOME,RA_SALARIO,RA_CATFUNC,RA_CODFUNC,RJ_DESC, " 				    +cCrLf
	cQuery += "	RA_CC,RA_CARGO,CTT_DESC01,R7_DATA,R7_FILIAL,R7_MAT,R7_TIPO,X5_DESCRI,R7_FUNCAO,R7_CATFUNC, " 	+cCrLf
	cQuery += "	R3_VALOR,R3_ANTEAUM,RJ_DESC,R7_CARGO,Q3_DESCSUM,R3_DATA "										+cCrLf
	cQuery += "	FROM 	"+RetSqlName("SRA")+" SRA "  															+cCrLf
	cQuery += "	LEFT JOIN "+RetSqlName("SRJ")+" SRJ "  															+cCrLf
	cQuery += "				ON RJ_FILIAL = '"+xFilial("SRJ")+ "' "  											+cCrLf
	cQuery += "				AND RJ_FUNCAO = RA_CODFUNC       "  												+cCrLf
	cQuery += "				AND SRJ.D_E_L_E_T_ <> '*' "			  												+cCrLf
	cQuery += "	LEFT JOIN "+RetSqlName("CTT")+" CTT "  															+cCrLf
	cQuery += "				ON CTT_FILIAL = '"+xFilial("CTT")+ "' "												+cCrLf
	cQuery += "				AND CTT_CUSTO = RA_CC "																+cCrLf
	cQuery += "				AND CTT.D_E_L_E_T_ <> '*' "			  												+cCrLf
	cQuery += "	LEFT JOIN "+RetSqlName("SR7")+" SR7 "	  														+cCrLf
	cQuery += "				ON R7_FILIAL = RA_FILIAL  "			  												+cCrLf
	cQuery += "				AND R7_MAT = RA_MAT       "			  												+cCrLf
	cQuery += "				AND SR7.D_E_L_E_T_ <> '*' "			  												+cCrLf
	cQuery += "	LEFT JOIN "+RetSqlName("SR3")+" SR3 "	  														+cCrLf
	cQuery += "				ON R3_FILIAL = RA_FILIAL  "			  												+cCrLf
	cQuery += "				AND R3_MAT = RA_MAT       "			  												+cCrLf
	cQuery += "				AND SR3.D_E_L_E_T_ <> '*' "			  												+cCrLf
	cQuery += "	LEFT JOIN "+RetSqlName("SQ3")+" SQ3 "	  														+cCrLf
	cQuery += "				ON Q3_FILIAL = '"+xFilial("SQ3")+ "' "												+cCrLf
	cQuery += "				AND Q3_CARGO = R7_CARGO   "			  												+cCrLf
	cQuery += "				AND Q3_CC = RA_CC         "			  												+cCrLf
	cQuery += "				AND SQ3.D_E_L_E_T_ <> '*' "			  												+cCrLf
	cQuery += "	LEFT JOIN "+RetSqlName("SX5")+" SX5   "			  												+cCrLf
	cQuery += "				ON X5_FILIAL = '"+xFilial("SX5")+ "' "												+cCrLf
	cQuery += "				AND X5_TABELA = '41'      "			  												+cCrLf
	cQuery += "				AND X5_CHAVE = R7_TIPO    "			  												+cCrLf
	cQuery += "				AND SX5.D_E_L_E_T_ <> '*' "			  												+cCrLf
	cQuery += "	WHERE SRA.D_E_L_E_T_ <> '*'  "  				 												+cCrLf
	cQuery += " AND " + cShFil + "  "														  		  			+cCrLf
	cQuery += " AND " + cShMat + "  "														  		  			+cCrLf
	cQuery += " AND " + cShCC + " "								  							  		  			+cCrLf
	cQuery += " AND RA_SITFOLH In ("+cSitQuery+")  "												  			+cCrLf
	cQuery += " AND RA_CATFUNC In ("+cCatQuery+")  "												  			+cCrLf
	cQuery += " AND " + cShAfas + "  "														  		  			+cCrLf	
	cQuery += "	AND   SR3.R3_DATA >= '"+dtos(mv_par07)+"' AND SR3.R3_DATA <= '"+dtos(mv_par08)+"' "				+cCrLf 													
	cQuery += "	AND   SR7.R7_DATA >= '"+dtos(mv_par07)+"' AND SR7.R7_DATA <= '"+dtos(mv_par08)+"' "				+cCrLf 																										
	cQuery += "	ORDER BY "+cOrder+" "        
	
*/		                                           
	cQuery := ""                        
	cQuery += "	SELECT	R7_FILIAL,R7_MAT,RA_NOME,RA_SALARIO,RA_CC, R7_CATFUNC,R7_FUNCAO,R7_DESCFUN,R7_CARGO, "  +cCrLf
	cQuery += "	R7_DESCCAR,R7_TIPO,R7_DATA,RA_SITFOLH,CTT_DESC01 "						   						+cCrLf
	cQuery += "	FROM "+RetSqlName("SR7")+" SR7 "															    +cCrLf
	cQuery += " INNER JOIN "+RetSqlName("SRA")+" SRA "  														+cCrLf
	cQuery += "				ON R7_FILIAL = RA_FILIAL  "			  												+cCrLf
	cQuery += "				AND R7_MAT = RA_MAT       "			  												+cCrLf
	cQuery += "				AND SR7.D_E_L_E_T_ <> '*' "			  												+cCrLf
	cQuery += " LEFT OUTER JOIN "+RetSqlName("CTT")+" CTT "  													+cCrLf
	cQuery += "				ON CTT_CUSTO = RA_CC      "			  												+cCrLf
	cQuery += "				AND CTT.D_E_L_E_T_ <> '*' "			  												+cCrLf
	cQuery += "	WHERE SRA.D_E_L_E_T_ <> '*'  "  				 												+cCrLf
	cQuery += " AND " + cShFil + "  "														  		  			+cCrLf
	cQuery += " AND " + cShMat + "  "														  		  			+cCrLf
	cQuery += " AND " + cShCC + " "								  							  		  			+cCrLf
	cQuery += " AND RA_SITFOLH In ("+cSitQuery+")  "												  			+cCrLf
	cQuery += " AND R7_CATFUNC In ("+cCatQuery+")  "												  			+cCrLf
	cQuery += " AND " + cShAfas + "  "														  		  			+cCrLf	
	cQuery += "	AND   SR7.R7_DATA >= '"+dtos(mv_par07)+"' AND SR7.R7_DATA <= '"+dtos(mv_par08)+"' "				+cCrLf 																										
	cQuery += "	ORDER BY "+cOrder+" "        
		         				

	If Select(cAliasQry) > 0
	   DbSelectArea(cAliasQry)
	  (cAliasQry)->(DbCloseArea())  
	Endif

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	TcSetField((cAliasQry),"R7_DATA","D",8,0)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
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

cPerg    := Padr("DORRAUMS",10) 

/*          Grupo/Ordem  /Pergunta                                                         /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid       /Var01     /Def01               /Defspa1/Defeng1/Cnt01/Var02/Def02             /Defesp2/Defeng2/Cnt02/Var03/Def03/Defspa3  /defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3   /PYME/grpsxg  /HELP /PICTURE*/
Aadd(aRegs,{cPerg, "01"  ,"Filial           ?","Filial De       ?"  , "Filial De       ?"   ,"MV_CH1","C" ,99     ,0      ,0     ,"R",""          ,"mv_par01","              "   ,""     ,""     ,"RA_FILIAL"   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0"	,"S" ,""     ,".RHFILDE. ",""})
Aadd(aRegs,{cPerg, "02"  ,"Matricula        ?","Matricula De    ?"  , "Matricula De    ?"   ,"MV_CH2","C" ,99     ,0      ,0     ,"R",""          ,"mv_par02","              "   ,""     ,""     ,"RA_MAT"      ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA"	,"S" ,""     ,".RHMATD.  ",""})
Aadd(aRegs,{cPerg, "03"  ,"Centro de Custo  ?","Centro de Custo ?"  , "Centro de Custo  ?"  ,"MV_CH3","C" ,99     ,0      ,0     ,"R",""          ,"mv_par03","              "   ,""     ,""     ,"RA_CC"       ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"CTT"	,"S" ,""     ,".RHCCUSTO.",""})
Aadd(aRegs,{cPerg, "04"  ,"Situacao         ?","Situacao        ?"  , "Situacao        ?"   ,"MV_CH4","C" ,05     ,0      ,0     ,"G","fSituacao" ,"mv_par04","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,".RHSITUA. ",""})
Aadd(aRegs,{cPerg, "05"  ,"Categoria        ?","Categoria       ?"  , "Categoria       ?"   ,"MV_CH5","C" ,15     ,0      ,0     ,"G","fCategoria","mv_par05","              "   ,""     ,""     ,""   			,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   	,"S" ,""     ,".RHCATEG. ",""})
Aadd(aRegs,{cPerg, "06"  ,"Tipo Aumento    ?","Tipo Aumento    ?"   , "Tipo Aumento    ?"   ,"MV_CH6","C" ,03     ,0      ,0     ,"R",""          ,"mv_par06","              "   ,""     ,""     ,"R7_TIPO"     ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"41"    ,"S" ,""     ,"",""})
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