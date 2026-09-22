#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"                              
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
                                                    
/*==========================================================================================
/ Relatorio para extrair diferenca existente na folha x liquido movimento aberto
@author     A.Shibao
@since      23/05/17
@param		
@version    P12
@return      
@project 
@client    
27/11/17 - A.Shibao - Ajuste para nao trazer os funcionarios transferidos .                       
//==========================================================================================*/
User Function DIFLIQ2()

Local oReport 

Private cPerg    := Padr("DIFLIQ2",10) 
Private nRecTMP  := 0
Private cAliasTmp:= "TMP"
Private cQuery   := ""
Private aOrdem   := {}
Private aTabelas := {"SRC","SRV","SRA"} 
Private aFunc    := {}                 
Private  cCrLf   := Chr(13)+Chr(10) 
Private CLIQADT	 := ""
Private CLIQFOL  := ""
Private CLIQ131  := ""
Private CLIQ132  := ""  
Private CLIQXXX  := ""

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
Private cTitulo := " ** Relação de diferença de líquidos no período ** "
Private cDesc   := " Relatório de diferença de líquidos no período.Será impresso de acordo com os parâmetros informados pelo usuário. "

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
DEFINE REPORT oReport NAME "DIFLIQ2" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| ReportPrint(oReport)} DESCRIPTION cDesc	

oReport:SetPortrait()
oReport:SetTotalInLine(.F.)     
oReport:nDevice		:=	4   // ja traz setado a opcao planilha.

oSection1 := TRSection():New(oReport,"Seção 1",aTabelas,aOrdem)

TRCell():New( oSection1, "RA_FILIAL"	, cAliasTmp, "Filial"			, PesqPict("SRA","RA_FILIAL")	, TamSx3("RA_FILIAL")[1]+8	,  )
TRCell():New( oSection1, "RA_MAT"		, cAliasTmp, "Matrícula"		, PesqPict("SRA","RA_MAT")		, TamSx3("RA_MAT")[1]+06	,  )
TRCell():New( oSection1, "RA_NOME"		, cAliasTmp, "Colaborador"		, PesqPict("SRA","RA_NOME")		, TamSx3("RA_NOME")[1]+40	,  )
TRCell():New( oSection1, "VALOR SOMADO"	, cAliasTmp, "Valor Somado"	    , PesqPict("SRC","RC_VALOR")    , TamSx3("RC_VALOR")[1]+12  ,  )
TRCell():New( oSection1, "VALOR CALCUL"	, cAliasTmp, "Valor Calculado"  , PesqPict("SRC","RC_VALOR")    , TamSx3("RC_VALOR")[1]+12  ,  )
TRCell():New( oSection1, "DIFERENCA"	, cAliasTmp, "Diferenca"	    , PesqPict("SRC","RC_VALOR")    , TamSx3("RC_VALOR")[1]+12  ,  )


oSection1:SetPageBreak(.T.)                                                                                                                                                          


Return(oReport)


//==========================================================================================
// Inicializa ReportPrint                                                     
//==========================================================================================
Static Function ReportPrint(oReport)

Local oSection1	:= oReport:Section(1)
Local cStartPath:= GetSrvProfString("Startpath","")
Local aTotal	:= {"Total",0,0}
Local xMens     := ""   

Local cShFil    := cShMat	:= cShRot := ""
Local cAliasQry	:= ""
Local cCrLf 	:= Chr(13)+Chr(10)

Private ACODFOL :={} 
Private lRet    := .T.

// Carrega tabela de verbas
FP_CODFOL(@ACODFOL,SRA->RA_FILIAL)

CLIQADT	:=	ACODFOL[546,1] // liquido de adto
CLIQFOL	:=	ACODFOL[47,1]  // liquido de folha ( ferias + VA + Vr + Vt + pla +  )
CLIQ131	:=	ACODFOL[678,1] // liquido da 131    
CLIQ132	:=	ACODFOL[21,1]  // liquido da 132

cPeriodo:= mv_par04

If mv_par02 == 1
	CLIQXXX:= CLIQADT
	cShRot := "'ADI'" 
	cShPerR:= "'ADI'"  // variavel para verificar o periodo se esta aberto ou fechado
ElseIf mv_par02 == 2
	CLIQXXX:= CLIQFOL
	cShRot := "'FOL','FER','VTR','VTA','VRF','PLA','RES'"
	cShPerR:= "'FOL'" 	
ElseIf mv_par02 == 3
	CLIQXXX:= CLIQ131                                    
	cShRot := "'131'" 
	cShPerR:= "'131'" 		
Else
	CLIQXXX:= CLIQ132
	cShRot := "'132'" 
	cShPerR:= "'132'" 			
Endif	            

//transforma os pergunte range filial em query
MakeSqlExpr(cPerg)    

BEGIN REPORT QUERY oSection1

	
	cShFil := IIf(Empty( mv_par01), "RA_FILIAL >= '"+SPACE(LEN(xfilial("SRA")))+"' AND RA_FILIAL <= '"+Replic("Z",LEN(xfilial("SRA")))+"'", mv_par01)
	cShFil := "%" + cShFil + "%"
	
	cShRot := " IN (" + cShRot + ") "
	cShRot := "%" + cShRot + "%"   
	
	BeginSql alias cAliasTmp

		SELECT RA_FILIAL, RA_MAT, RA_NOME, 
				(SELECT SUM(RC_VALOR) FROM  %table:SRC% SRC
					WHERE %exp:cShFil% 
					AND SRC.%notDel%
					AND RC_MAT = RA_MAT
					AND RC_ROTEIR %exp:cShRot%  
					AND RC_PERIODO || RC_SEMANA IN (SELECT RCH_PER || RCH_NUMPAG 
      											    FROM %table:RCH% RCH  
                                           			WHERE  RCH.%notDel% 
                                           			AND RCH_PERSEL = '1' 
                                           			AND RCH_FILIAL = RC_FILIAL 
                                           			AND RCH_PROCES = RC_PROCES 
                                           			AND RCH_ROTEIR = RC_ROTEIR
                     							  )
					AND RC_PD IN ( SELECT RV_COD 
				 					FROM %table:SRV% SRV 
				                	WHERE SRV.%notDel% 
									AND RC_PD IN (SELECT RV_COD FROM%table:SRV% SRV
											   		WHERE SRV.%notDel%					
													AND RV_TIPOCOD IN ('1') 
									             )
					             )
				) AS PROVENTOS,
				(SELECT SUM(RC_VALOR) FROM  %table:SRC% SRC
					WHERE %exp:cShFil% 
					AND SRC.%notDel%
					AND RC_MAT = RA_MAT
					AND RC_ROTEIR %exp:cShRot%  
					AND RC_PERIODO || RC_SEMANA IN (SELECT RCH_PER || RCH_NUMPAG 
      											    FROM %table:RCH% RCH  
                                           			WHERE  RCH.%notDel% 
                                           			AND RCH_PERSEL = '1' 
                                           			AND RCH_FILIAL = RC_FILIAL 
                                           			AND RCH_PROCES = RC_PROCES 
                                           			AND RCH_ROTEIR = RC_ROTEIR
                     							  )
					AND RC_PD IN ( SELECT RV_COD 
				 					FROM %table:SRV% SRV 
				                	WHERE SRV.%notDel% 
									AND RC_PD IN (SELECT RV_COD FROM%table:SRV% SRV
											   		WHERE SRV.%notDel%					
													AND RV_TIPOCOD IN ('2') 
									             )
					             )
				)  AS DESCONTOS,
				(SELECT SUM(RC_VALOR) FROM  %table:SRC% SRC
					WHERE %exp:cShFil% 
					AND SRC.%notDel%
					AND RC_MAT = RA_MAT
					AND RC_ROTEIR %exp:cShRot% 
					AND RC_PERIODO || RC_SEMANA IN (SELECT RCH_PER || RCH_NUMPAG 
      											    FROM %table:RCH% RCH  
                                           			WHERE  RCH.%notDel% 
                                           			AND RCH_PERSEL = '1' 
                                           			AND RCH_FILIAL = RC_FILIAL 
                                           			AND RCH_PROCES = RC_PROCES 
                                           			AND RCH_ROTEIR = RC_ROTEIR
                     							  )
					AND RC_PD = %exp:CLIQXXX% 
				) AS LIQUIDO											
																							
		FROM %table:SRA% SRA
		WHERE SRA.%notDel%      
		AND %exp:cShFil% 
		AND RA_AFASFGT NOT IN ('N1','N2')	// Nao traz quem foi transferidos.	
		ORDER BY RA_FILIAL,RA_MAT
	
	EndSql
	
END REPORT QUERY oSection1 //PARAM mv_par01

oSection1:EndQuery() 

//Utiliza a query do Pai 
oSection1:SetParentQuery(.T.) 

dbSelectArea(cAliasTmp)
(cAliasTmp)->( dbGoTop() )  

//-- Incializa impressao   
oSection1:Init()       
                        
While  !(cAliasTmp)->( EOF() )  

	oReport:IncMeter( 1 )   

    cShFilAnt:= (cAliasTmp)->RA_FILIAL 
    
	If ((cAliasTmp)->PROVENTOS - (cAliasTmp)->DESCONTOS) <> (cAliasTmp)->LIQUIDO 
	  	     
	  oSection1:Cell("RA_FILIAL")    :SetValue((cAliasTmp)->RA_FILIAL)
	  oSection1:Cell("RA_MAT")       :SetValue((cAliasTmp)->RA_MAT)
	  oSection1:Cell("RA_NOME")    	 :SetValue((cAliasTmp)->RA_NOME)
  	  oSection1:Cell("VALOR SOMADO") :SetValue((cAliasTmp)->PROVENTOS - (cAliasTmp)->DESCONTOS)                   
  	  oSection1:Cell("VALOR CALCUL") :SetValue((cAliasTmp)->LIQUIDO)                   
  	  oSection1:Cell("DIFERENCA")    :SetValue(((cAliasTmp)->PROVENTOS - (cAliasTmp)->DESCONTOS) - (cAliasTmp)->LIQUIDO)                   
    
	  oSection1:PrintLine()
	  
      aTotal[2]++	
		  	  
	Endif
    
   (cAliasTmp)->( DbSkip() )

EndDO             

(cAliasTmp)->(dbCloseArea())   

MsgInfo("Relatório de diferença de líquidos no período, Finalizado com Sucesso !!!"+Chr(13)+;
           "                            *** FIM DO PROCESSAMENTO ***                  ")

//==========================================================================================
// Finaliza ReportPrint                                                        
//==========================================================================================
xMens := "Gerados: "+Alltrim(Str(aTotal[2],10))

oSection1:Cell("RA_FILIAL")    :SetValue("")
oSection1:Cell("RA_MAT")       :SetValue("")
oSection1:Cell("RA_NOME")      :SetValue("Total "+xMens)
oSection1:Cell("VALOR SOMADO") :SetValue("")
oSection1:Cell("VALOR CALCUL") :SetValue("")
oSection1:Cell("DIFERENCA")    :SetValue("")

oReport:ThinLine()
oReport:IncMeter()
oSection1:PrintLine()
oSection1:Finish()
oSection1:PageBreak()

Return(Nil)


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
//cPerg    := Padr("DIFLIQ2",10) 
//
///*          Grupo/Ordem  /Pergunta                                                         /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid       /Var01     /Def01               /Defspa1/Defeng1/Cnt01/Var02/Def02             /Defesp2/Defeng2/Cnt02/Var03/Def03/Defspa3  /defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3   /PYME/grpsxg  /HELP /PICTURE*/
//aAdd(aRegs,{cPerg,"01","Filial        ?","Filial De   ?"  , "Filial De ?"   ,"mv_ch1","C"   ,99       ,0        ,0,"R"  ,""                    ,"mv_par01"," "   ,""      ,""      ,"RA_FILIAL"   ,""   ,"         "   ,""    		  ,""     		 ,"","",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","XM0"	,"S" ,"",".RHFILDE. ",""})
//aAdd(aRegs,{cPerg,"02","Roteiro       ?","Roteiro       ?","Roteiro       ?","mv_ch2","C"   ,1        ,0        ,0,"C"  ,""                    ,"mv_par02","Adto","Adto"  ,"Adto"  ,""   		  ,""   ,"Folha"       ,"Folha"       ,"Folha"       ,"","","131","131","131","","","132","132","132","","","","","","",""      ,""  ,"",""          ,""})  
////aAdd(aRegs,{cPerg,"03","AnoMes XXXXYY ?","AnoMes XXXXYY ?","AnoMes XXXXYY ?","mv_ch3","C"   ,6        ,0        ,0,"C"  ,"naovazio()"          ,"mv_par03",""    ,""      ,""      ,""			  ,""   ,""            ,""            ,""            ,"","",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","",""      ,""  ,"",""          ,""})
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