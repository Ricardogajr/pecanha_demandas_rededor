#include "rwmake.ch"     
#include "topconn.ch"
#Define CRLF CHR(13)+CHR(10)
//==========================================================================================
/*/
Rotina para geracao do relatorio de evolução de verbas
@author     A.Shibao
@since      15/05/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/                                 
//==========================================================================================
User Function DorEvoVrb()

Local nOpca 		:= 0
Local aRegs			:={}
Local aSays         :={ } 
Local aButtons      :={ } //<== arrays locais de preferencia
	
Private cPerg       := Padr("DOREVOVRB",10) 
Private lAbortPrint := .F.
Private cFilSRA     := "" 
Private lArq		:= .T. 
Private lLeSrc  	:= .F.

Private cAliasTmp1	:= "TM1"
Private cAliasTmp2	:= "TM2"
Private cAliasTmp3	:= "TM3"
Private cAliasTmp4  := "TM4"
Private cAliasTmp5  := "TM5"
Private cAliasTmp6  := "TM6"
Private cAliasTmp7  := "TM7"

Private cperiodo    := ""
Private cperiodo1   := ""
Private cperiodo2   := ""
Private cperiodo3   := ""
Private cperiodo4   := ""
Private cperiodo5   := ""
Private cperiodo6   := ""  
Private nShValor    := 0 

Private nVariaca1   := 0
Private nVariaca2   := 0
Private nVariaca3   := 0
Private nVariaca4   := 0
Private nVariaca5   := 0
Private nVariaca6   := 0
                                
Private nShToTPr2  := 0 
Private nShToTPr3  := 0 
Private nShToTPr4  := 0 
Private nShToTPr5  := 0 
Private nShToTPr6  := 0 
Private nShToTPr7  := 0 
Private nShToTPFi  := 0 
	   	    
Private nShToTDe2  := 0	   	    
Private nShToTDe3  := 0	   	    
Private nShToTDe4  := 0
Private nShToTDe5  := 0   	   	    
Private nShToTDe6  := 0	   	    
Private nShToTDe7  := 0
Private nShToTDFi  := 0
	   	    
cCadastro := OemToAnsi("Geracao de Arquivos") 

//ValidPerg()
VerPerg1()

Pergunte(cPerg,.F.)  

AADD(aSays,OemToAnsi("Geracao de Planilha para Evolução da Verba !!!" ) ) 
	
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
		
FormBatch( cCadastro, aSays, aButtons )
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
If nOpca == 1
	Processa({|lEnd| GeraArq__(),"Geracao"})
Endif	


If Select(cAliasTmp1) > 0
   DbSelectArea(cAliasTmp1)
  (cAliasTmp1)->(DbCloseArea())  
Endif

If Select(cAliasTmp2) > 0
   DbSelectArea(cAliasTmp2)
  (cAliasTmp3)->(DbCloseArea())  
Endif

If Select(cAliasTmp3) > 0
   DbSelectArea(cAliasTmp3)
  (cAliasTmp3)->(DbCloseArea())  
Endif    

If Select(cAliasTmp4) > 0
   DbSelectArea(cAliasTmp3)
  (cAliasTmp3)->(DbCloseArea())  
Endif

If Select(cAliasTmp5) > 0
   DbSelectArea(cAliasTmp3)
  (cAliasTmp3)->(DbCloseArea())  
Endif      

If Select(cAliasTmp6) > 0
   DbSelectArea(cAliasTmp6)
  (cAliasTmp6)->(DbCloseArea())  
Endif              

Return Nil


//==========================================================================================
/*/
Rotina para gerar o arquivo
@author     A.Shibao
@since      15/05/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/                                 
//==========================================================================================
Static Function GeraArq__()

LOCAL cQuery
LOCAL NRET
LOCAL CLINHA
LOCAL cTipCC_   	:= "" 
Local aPerAtual     := {} 
Local cMesAtual	    := ""

Private cTitulo1  	:= "Selecione o arquivo"
Private cExtens		:= "Arquivo CSV | *.csv"
Private aVerba     	:= {} 
Private cFiliais   	:= MV_PAR01
Private cVerbas    	:= MV_PAR02  
Private aFinal      := {}
Private cFileOpen   := ""

// abre tela para gravacao do arquivo.
cFileOpen := cGetFile(cExtens,cTitulo1,2,,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.)

//transforma os pergunte range filial em query
MakeSqlExpr(cPerg) 

// Carregando o array com as Verbas     
fVrb(@aVerba)                           

//Ordenação das verbas
aSort(aVerba,,,{ |X,Y| X[1]+X[2] < Y[1]+Y[2] })  

//cperiodo1 := If( Empty(fOpenPer(@cperiodo)) , fLastPer(@cperiodo), fOpenPer(@cperiodo) )    
cperiodo1:= fOpenPer(@cperiodo) 

// verifica se tem periodo em aberto caso contrario pega o ultimo fechado.
If Empty(cperiodo1)
	cperiodo1:= fLastPer(@cperiodo) 
Else
	//cperiodo1:= fOpenPer(@cperiodo)  
	lLeSrc   := .T.
Endif

If Empty(cperiodo1) .or. len(cperiodo1) <> 6
	MsgAlert("Filial não selecionada")
	Return( Nil )
Endif

// pega os periodo anteriores ao cperiodo1
cperiodo := cperiodo1
cperiodo2:=	Anomes(fShbMesAno( @cperiodo ))
cperiodo := cperiodo2
cperiodo3:=	Anomes(fShbMesAno( @cperiodo ))
cperiodo := cperiodo3
cperiodo4:= Anomes(fShbMesAno( @cperiodo ))
cperiodo := cperiodo4
cperiodo5:= Anomes(fShbMesAno( @cperiodo ))
cperiodo := cperiodo5
cperiodo6:= Anomes(fShbMesAno( @cperiodo ))

ProcRegua(len( aVerba ))

For nSh:=1 to len( aVerba ) 
		
		IncProc( "Selecionando periodos e verbas : "+StrZero(nSh,4)+" de "+StrZero(len( aVerba ),4))		
		
		aAdd(aFinal,{aVerba[nSh,1] + " - " + aVerba[nSh,2] ,;   // Verbas + Descrição
					   Iif( lLeSrc, fShOpnVrb(@cperiodo1,@aVerba[nSh,1]), fShAcmVrb(@cperiodo1,@aVerba[nSh,1]) ), ;   // Mes 01
					   	fShAcmVrb(@cperiodo2,@aVerba[nSh,1]), ;   // Mes 02
					   	 fShAcmVrb(@cperiodo3,@aVerba[nSh,1]), ;   // Mes 03
					   	  fShAcmVrb(@cperiodo4,@aVerba[nSh,1]), ;   // Mes 04
					   	   fShAcmVrb(@cperiodo5,@aVerba[nSh,1]), ;   // Mes 05
					   	    fShAcmVrb(@cperiodo6,@aVerba[nSh,1]), ;   // Mes 06
					   	                          aVerba[nSh,3]})      // Tipo da verba p/ totalizadores
Next nSh
      

If len(aFinal) > 0 
	
		fGrava()

Endif
	
Return()

//==========================================================================================
/*/
Rotina para filtrar as verbas que serão usadas no relatorio
@author     A.Shibao
@since      15/05/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/                                 
//==========================================================================================
Static Function fVrb(aVerba)

Local cQuery_ := ""               

	cVerbas := IIf(Empty( mv_par02), "RV_TIPOCOD IN ('1','2')", mv_par02)
	//cVerbas := "%" + cVerbas + "%"

	cQuery_ := " SELECT RV_COD, RV_DESC, RV_TIPOCOD FROM "+ RetSqlName("SRV") + " SRV "
	cQuery_ += "   WHERE "  + cVerbas + ""
	cQuery_ += "   AND SRV.D_E_L_E_T_ <> '*'"
	cQuery_ += "  ORDER BY RV_COD"

ChangeQuery(cQuery_)

If Select(cAliasTmp1) > 0
   DbSelectArea(cAliasTmp1)
  (cAliasTmp1)->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery_),cAliasTmp1, .F., .T.)

ProcRegua((cAliasTmp1)->(RecCount()))

While (cAliasTmp1)->(!Eof())

	IncProc( "Selecionando as verbas : " + (cAliasTmp1)->RV_COD ) 
	
	aAdd(aVerba,{(cAliasTmp1)->RV_COD, (cAliasTmp1)->RV_DESC, (cAliasTmp1)->RV_TIPOCOD }) 

 	(cAliasTmp1)->(dbSkip())
 	 
EndDo

Return

//==========================================================================================
/*/
Rotina para gerar o arquivo .csv
@author     A.Shibao
@since      15/05/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/                                 
//==========================================================================================
Static Function fGrava()   

Local cCont 	:= " " 
Local nVariacao := 0    
Local nRet		:= 1

/*
If At(".",Alltrim(cPathArq)) > 0 
	cPathArq := Substr(cPathArq,1,At(".",Alltrim(cPathArq))) + "CSV"
Else
	cPathArq := AllTrim(cPathArq) + ".CSV"
EndIF
*/                  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o arquivo TXT já existe no Caminho Selecionado |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
If File(cFileOpen)
	nRet:= Aviso("Atencao","Arquivo ja existe, continua ?",{"SIM","NAO"})
EndIf
	
If nRet = 2   // 1 = SIM 2 = NAO
	Return Nil
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o Arquivo TXT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle	:= FCREATE(cFileOpen)

IF Ferror() # 0 .AND. nHandle = -1
	cMsg := "Erro de abertura, codigo DOS:" + STR(FERROR(),2) 
	Aviso( "Atencao", cMsg, { "OK" } ) 
    Return
EndIF 


	cCabec := "Filial; Verba - Descrição ; Tipo ;"  
	cCabec += MesExtenso(stod(cperiodo1 + "01")) + "/" + cvaltochar(year(stod((cperiodo1 + "01") ))) + ";"  
	cCabec += MesExtenso(stod(cperiodo2 + "01")) + "/" + cvaltochar(year(stod((cperiodo2 + "01") ))) + ";"  
	cCabec += MesExtenso(stod(cperiodo3 + "01")) + "/" + cvaltochar(year(stod((cperiodo3 + "01") ))) + ";"  
	cCabec += MesExtenso(stod(cperiodo4 + "01")) + "/" + cvaltochar(year(stod((cperiodo4 + "01") ))) + ";"  
	cCabec += MesExtenso(stod(cperiodo5 + "01")) + "/" + cvaltochar(year(stod((cperiodo5 + "01") ))) + ";"  
	cCabec += MesExtenso(stod(cperiodo6 + "01")) + "/" + cvaltochar(year(stod((cperiodo6 + "01") ))) + ";"  
/*	cCabec += "Variação - " +  MesExtenso(stod(cperiodo1 + "01")) + "/" + cvaltochar(year(stod((cperiodo1 + "01") ))) + "-" +  MesExtenso(stod(cperiodo2 + "01")) + "/" + cvaltochar(year(stod((cperiodo2 + "01") ))) + ";"                                                                                                         
	cCabec += "Variação - " +  MesExtenso(stod(cperiodo2 + "01")) + "/" + cvaltochar(year(stod((cperiodo2 + "01") ))) + "-" +  MesExtenso(stod(cperiodo3 + "01")) + "/" + cvaltochar(year(stod((cperiodo3 + "01") ))) + ";"
	cCabec += "Variação - " +  MesExtenso(stod(cperiodo3 + "01")) + "/" + cvaltochar(year(stod((cperiodo3 + "01") ))) + "-" +  MesExtenso(stod(cperiodo4 + "01")) + "/" + cvaltochar(year(stod((cperiodo4 + "01") ))) + ";"
	cCabec += "Variação - " +  MesExtenso(stod(cperiodo4 + "01")) + "/" + cvaltochar(year(stod((cperiodo4 + "01") ))) + "-" +  MesExtenso(stod(cperiodo5 + "01")) + "/" + cvaltochar(year(stod((cperiodo5 + "01") ))) + ";"
	cCabec += "Variação - " +  MesExtenso(stod(cperiodo5 + "01")) + "/" + cvaltochar(year(stod((cperiodo5 + "01") ))) + "-" +  MesExtenso(stod(cperiodo6 + "01")) + "/" + cvaltochar(year(stod((cperiodo6 + "01") ))) + ";"
*/ 	cCabec += CRLF
    //cCabec += "Variação - " +  MesExtenso(stod(cperiodo6 + "01")) + "/" + cvaltochar(year(stod((cperiodo6 + "01") ))) + ";"
	
	fWrite(nHandle,cCabec)       
	
	ProcRegua(Len(aFinal))

	For ny := 1 to Len(aFinal)
	
		IncProc( "Gerando os registros : " + aFinal[ny,1] + " - " + StrZero(ny,4) + " de " +  StrZero(Len(aFinal),4))	   
		
		// calcula a variacao de um mes para outro
		nVariaca1 := 0 
		nVariaca2 := 0 
		nVariaca3 := 0 
		nVariaca4 := 0 
		nVariaca5 := 0 
		nVariaca6 := 0 				
	
	/*	nVariaca1 := (((aFinal[ny,2] - aFinal[ny,3])) / aFinal[ny,2]) * -100
		nVariaca2 := (((aFinal[ny,3] - aFinal[ny,4])) / aFinal[ny,3]) * -100
		nVariaca3 := (((aFinal[ny,4] - aFinal[ny,5])) / aFinal[ny,4]) * -100	
		nVariaca4 := (((aFinal[ny,5] - aFinal[ny,6])) / aFinal[ny,5]) * -100
		nVariaca5 := (((aFinal[ny,6] - aFinal[ny,7])) / aFinal[ny,6]) * -100 
		nVariaca6 := (aFinal[ny,5] - aFinal[ny,4]) 
	*/	
		// imprimir somente meses que possuem valor.			
	    If aFinal[ny,2] > 0 .or. aFinal[ny,3] > 0 .or. aFinal[ny,4] > 0 .or. aFinal[ny,5] > 0 .or. aFinal[ny,6] > 0 .or. aFinal[ny,7] > 0 
	    
		    cCont := FWFilialName(cEmpAnt,cFilAnt)             			+ ";" // Descricao Filial
		    cCont += aFinal[ny,1]							   			+ ";" // Verba + Descricao
		    cCont += Iif(aFinal[ny,8] == "1", "Proventos","Descontos")	+ ";" // Tipo da Verba
			cCont += Transform(aFinal[ny,2],'@E 999,999,999.99') 		+ ";" // Mes 01	    
			cCont += Transform(aFinal[ny,3],'@E 999,999,999.99') 		+ ";" // Mes 02	    
			cCont += Transform(aFinal[ny,4],'@E 999,999,999.99') 		+ ";" // Mes 03	    
			cCont += Transform(aFinal[ny,5],'@E 999,999,999.99') 		+ ";" // Mes 04	    	
			cCont += Transform(aFinal[ny,6],'@E 999,999,999.99') 		+ ";" // Mes 05
			cCont += Transform(aFinal[ny,7],'@E 999,999,999.99') 		+ ";" // Mes 06	    		    	
		/*  cCont += Transform(nVariaca1  ,'@E 9,999,999.99') 			+ ";" // Variacao 01	    
		    cCont += Transform(nVariaca2  ,'@E 9,999,999.99') 			+ ";" // Variacao 02
		    cCont += Transform(nVariaca3  ,'@E 9,999,999.99') 			+ ";" // Variacao 03
		    cCont += Transform(nVariaca4  ,'@E 9,999,999.99') 			+ ";" // Variacao 04		
		    cCont += Transform(nVariaca5  ,'@E 9,999,999.99') 			+ ";" // Variacao 05   */ 
		  	cCont += CRLF
		   	                     
		   	//Totalizadores
		   	If aFinal[ny,8] == "1"
	
		   	    nShToTPr2 += aFinal[ny,2]	   	    
		   	    nShToTPr3 += aFinal[ny,3]	   	    
	   	   	    nShToTPr4 += aFinal[ny,4]
		   	    nShToTPr5 += aFinal[ny,5]   	   	    
		   	    nShToTPr6 += aFinal[ny,6]	   	    
		   	    nShToTPr7 += aFinal[ny,7]
		   	    
		   	Else 
		   	
		   	    nShToTDe2 += aFinal[ny,2]	   	    
		   	    nShToTDe3 += aFinal[ny,3]	   	    
	   	   	    nShToTDe4 += aFinal[ny,4]
		   	    nShToTDe5 += aFinal[ny,5]   	   	    
		   	    nShToTDe6 += aFinal[ny,6]	   	    
		   	    nShToTDe7 += aFinal[ny,7]
		   	    
		   	Endif 
		   	
		   	fWrite(nHandle,cCont)
	   	
	   	Endif
	   	
	Next            
	

	If nShToTPr2 + nShToTPr3 + nShToTPr4 + nShToTPr5 + nShToTPr6 + nShToTPr7 > 0
	
		cCont := "" + CRLF 
	    
	    // imprime o total de proventos 
		cCont := ""						                 	+ ";" // Descricao Filial
	    cCont += "Total de proventos por mês "			 	+ ";" // Verba + Descricao
		cCont += ""						                 	+ ";" // branco	    
		cCont += Transform(nShToTPr2 ,'@E 999,999,999.99') + ";" // Mes 01	    
		cCont += Transform(nShToTPr3 ,'@E 999,999,999.99') + ";" // Mes 02	    
		cCont += Transform(nShToTPr4 ,'@E 999,999,999.99') + ";" // Mes 03	    
		cCont += Transform(nShToTPr5 ,'@E 999,999,999.99') + ";" // Mes 04	    	
		cCont += Transform(nShToTPr6 ,'@E 999,999,999.99') + ";" // Mes 05
		cCont += Transform(nShToTPr7 ,'@E 999,999,999.99') + ";" // Mes 06	    		    	
	 
	  	cCont += CRLF 
         
	   	fWrite(nHandle,cCont)   
	   	
		cCont := "" + CRLF 
	    
	    // imprime o total de descontos
		cCont := ""						                + ";" // Descricao Filial
	    cCont += "Total de descontos por mês "			+ ";" // Verba + Descricao
		cCont += ""						                + ";" // branco	    
		cCont += Transform(nShToTDe2,'@E 999,999,999.99') + ";" // Mes 01	    
		cCont += Transform(nShToTDe3,'@E 999,999,999.99') + ";" // Mes 02	    
		cCont += Transform(nShToTDe4,'@E 999,999,999.99') + ";" // Mes 03	    
		cCont += Transform(nShToTDe5,'@E 999,999,999.99') + ";" // Mes 04	    	
		cCont += Transform(nShToTDe6,'@E 999,999,999.99') + ";" // Mes 05
		cCont += Transform(nShToTDe7,'@E 999,999,999.99') + ";" // Mes 06	    		    	
	 
	  	cCont += CRLF 
         
	   	fWrite(nHandle,cCont) 	   	 
	   	
	  	cCont := "" + CRLF 
	  	cCont := "" + CRLF 
	 /* 	
	  	// imprime o total dos proventos GERAL
   	    nShToTPFi :=	nShToTPr2  + nShToTPr3 + nShToTPr4 + nShToTPr5 +  nShToTPr6 + nShToTPr7	    	   	    
	  	cCont 	  := " " + ";" + "Total Proventos -> " + ";"
		cCont     += Transform(nShToTPFi,'@E 9,999,999.99') + ";" 
	  	cCont     += CRLF 	            
	  	fWrite(nHandle,cCont)	  	
	  	
	  	// imprime o total dos descontos GERAL
   	    nShToTDFi :=	nShToTDe2  + nShToTDe3 + nShToTDe4 + nShToTDe5 +  nShToTDe6 + nShToTDe7	   		  	
	  	cCont 	  := " " + ";" + "Total Descontos -> " + ";"		
		cCont 	  += Transform(nShToTDFi,'@E 9,999,999.99') + ";" 
	  	cCont 	  += CRLF 	            
	  	fWrite(nHandle,cCont)  
	 */ 	
	Endif
	
Fclose(nHandle) 

If lArq
	msgAlert("Arquivo Gerado no Diretorio " + cFileOpen) 
EndIf

Return                                                           


//==========================================================================================
/*/
Funcao para criacao das perguntas tipo Range
@author     A.Shibao
@since      03/06/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function VerPerg1()

Local j
Local i
Local aHelp		:= {}
Local aHelpE	:= {}
Local aHelpI	:= {}
Local cHelp		:= ""

//---------------------------------
//Seleciona Tabela
//---------------------------------
dbSelectArea("SX1")
dbSetOrder(1) 

aRegs :={}
cPerg := Padr("DOREVOVRB",10) 

aHelp := {	"Selecione as verbas que serão       ",;
"utilizadas para filtro de dados.Caso em branco  ",;
"serão consideradas todas (proventos e descontos)" }
aHelpE := {	"Selecione as verbas que serão       ",;
"utilizadas para filtro de dados.Caso em branco  ",;
"serão consideradas todas (proventos e descontos)" }
aHelpI := {	"Selecione as verbas que serão       ",;
"utilizadas para filtro de dados.Caso em branco  ",;
"serão consideradas todas (proventos e descontos)" }
cHelp := ".XDOREVO."
                   
/*          Grupo/Ordem  /Pergunta                                           /Variavel/Tipo  /Tamanho /Decimal /Presel/GSC/Valid       /Var01     /Def01 /Defspa1 /Defeng1 /Cnt01         /Var02/Def02         /Defesp2       /Defeng2       /Cnt02	/Var03	/Def03/Defspa3  /defeng3/Cnt03	/Var04	/Def04/Defspa4	/Defeng4/Cnt04/Var05/Def05/Defspa5/Defeng5/Cnt05/F3   /PYME/grpsxg  /HELP /PICTURE*/
aAdd(aRegs,{cPerg,"01","Filial        ?","Filial De   ?"  , "Filial De ?"   ,"mv_ch1","C"   ,8        ,0        ,0    ,"C",""          ,"mv_par01"," "   ,""      ,""      ,""            ,""   ,"         "   ,""    		  ,""     		 ,""	,""		,""   ,""   	,""   	,""		,""		,""   ,""   	,""     ,""	  ,""   ,""   ,""     ,""     ,""   ,"XM0","S" ,"",".RHFILDE. ",""})
aAdd(aRegs,{cPerg,"02","Verbas        ?","Verbas        ?","Verbas        ?","mv_ch2","C"   ,99       ,0        ,0    ,"R",""          ,"mv_par02",""    ,""      ,""      ,"RV_COD"	  ,""   ,"         "   ,""    		  ,""     		 ,""	,""		,""   ,""   	,""   	,""		,""		,""   ,""   	,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRV","S" ,"","","","",chelp})

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

Return  

//==========================================================================================
/*/
Busca o ultimo periodo fechado
@author     A.Shibao
@since      03/06/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fLastPer(cperiodo1)

Local cQuery_L  := ""

	cQuery_L := " SELECT RCH_PER FROM "+ RetSqlName("RCH") + " "
	cQuery_L += "   WHERE RCH_PER = ( SELECT MAX(RCH_PER) FROM " + RetSqlName("RCH") + " "
	cQuery_L += "   					WHERE RCH_FILIAL = '" + alltrim(cFiliais) + "'  "
	cQuery_L += "  						AND RCH_ROTEIR = 'FOL' AND RCH_PERSEL = '2'
	cQuery_L += "                       AND D_E_L_E_T_ <>'*'  )	

ChangeQuery(cQuery_L)

If Select(cAliasTmp4) > 0
   DbSelectArea(cAliasTmp4)
  (cAliasTmp4)->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery_L),cAliasTmp4, .F., .T.)
                                                                   
While (cAliasTmp4)->(!Eof())
	
    If !Empty((cAliasTmp4)->RCH_PER)
		cperiodo1   := (cAliasTmp4)->RCH_PER
	Endif	

	(cAliasTmp4)->(dbSkip()) 	                                
	
EndDo

Return(cperiodo1)

//==========================================================================================
/*/
Busca o ultimo periodo aberto
@author     A.Shibao
@since      03/06/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fOpenPer(cperiodo1)

Local cQuery_O  := ""

	cQuery_O := " SELECT RCH_PER FROM "+ RetSqlName("RCH") + " "
	cQuery_O += "   WHERE RCH_FILIAL = '" + alltrim(cFiliais) + "'  "
	cQuery_O += "	AND RCH_ROTEIR = 'FOL' AND RCH_PERSEL = '1' "
	cQuery_O += "   AND D_E_L_E_T_ <> '*' "

ChangeQuery(cQuery_O)

If Select(cAliasTmp5) > 0
   DbSelectArea(cAliasTmp5)
  (cAliasTmp5)->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery_O),cAliasTmp5, .F., .T.)
                                                                   
While (cAliasTmp5)->(!Eof())

	If !Empty((cAliasTmp5)->RCH_PER)
		cperiodo1   := (cAliasTmp5)->RCH_PER
	Endif	

 	(cAliasTmp5)->(dbSkip()) 
		                                
EndDo

Return(cperiodo1)

//==========================================================================================
/*/
/  Funcao para subtrair mes ano 
@author     A.Shibao
@since      28/11/2016
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//========================================================================================== 
Static Function fShbMesAno( xData )             

 Local nMes, nAno, uRet
 Local lData := If( ValType(xData)=="D",.T.,.F. )

 nMes := If( lData,Month( xData ),Val(Right( xData,2 )) )
 nAno := If( lData,Year( xData ),Val(Left( xData,4 )) )

 fShub1Mes( @nMes, @nAno )

 xData := StrZero(nAno,4) + StrZero(nMes,2)
 dtSIni  := ctod("01/"+StrZero(nMes,2)+"/"+StrZero(nAno,4))//substrMesAno(xData)
 dtSFim    := ctod(strzero(f_UltDia(dtSIni),2)+"/"+Strzero(Month(dtSIni),2)+"/"+right(str(Year(dtSIni)),2)) 

 
Return( dtSIni, dtSFim )	

//==========================================================================================
/*/
/  Funcao para subtrair mes  
@author     A.Shibao
@since      28/11/2016
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//========================================================================================== 
Static Function fShub1Mes( nMes, nAno )   


 nMes--
 If nMes == 0
    nMes := 12
    nAno--
 EndIf
 
Return   

//==========================================================================================
/*/
Busca o ultimo periodo aberto
@author     A.Shibao
@since      03/06/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fShAcmVrb(cperiodo,cVerba)

Local cQuery_Z  := ""
                      
	nShValor := 0 
	
	cQuery_Z := " SELECT SUM(RD_VALOR) AS VALOR FROM "+ RetSqlName("SRD") + " "
	cQuery_Z += "   WHERE RD_FILIAL = '" + (cFiliais) + "'  "
	cQuery_Z += "	AND RD_DATARQ =   '" + cperiodo + "'  "
	cQuery_Z += "	AND RD_PD  IN    ('" + cVerba + "') "	
	cQuery_Z += "   AND D_E_L_E_T_ <> '*' "

ChangeQuery(cQuery_Z)

If Select(cAliasTmp6) > 0
   DbSelectArea(cAliasTmp6)
  (cAliasTmp6)->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery_Z),cAliasTmp6, .F., .T.)
                                                                   
While (cAliasTmp6)->(!Eof()) 
	
	If (cAliasTmp6)->VALOR > 0
		nShValor   := (cAliasTmp6)->VALOR
    Endif
    
 	(cAliasTmp6)->(dbSkip()) 
		                                
EndDo

Return(nShValor)        

//==========================================================================================
/*/
Busca o periodo aberto
@author     A.Shibao
@since      03/06/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/
//==========================================================================================
Static Function fShOpnVrb(cperiodo,cVerba)

Local cQuery_y  := ""
                      
	nShValor := 0 
	
	cQuery_y := " SELECT SUM(RC_VALOR) AS VALOR FROM "+ RetSqlName("SRC") + " "
	cQuery_y += "   WHERE RC_FILIAL = '" + (cFiliais) + "'  "
	cQuery_y += "	AND RC_PERIODO =   '" + cperiodo + "'  "
	cQuery_y += "	AND RC_PD  IN    ('" + cVerba + "') "	
	cQuery_y += "   AND D_E_L_E_T_ <> '*' "

ChangeQuery(cQuery_y)

If Select(cAliasTmp7) > 0
   DbSelectArea(cAliasTmp7)
  (cAliasTmp7)->(DbCloseArea())  
Endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery_y),cAliasTmp7, .F., .T.)
                                                                   
While (cAliasTmp7)->(!Eof())

	If (cAliasTmp7)->VALOR > 0
		nShValor   := (cAliasTmp7)->VALOR
	Endif	

 	(cAliasTmp7)->(dbSkip()) 
		                                
EndDo

Return(nShValor)