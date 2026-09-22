#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"                              
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

//==========================================================================================
/*/
Rotina para geracao do arquivo para encontrar as diferencas na folha x liquido
@author     Jorge Paiva
@since      21/05/17
@param		
@version    P12
@return      
@project 
@client    RedeDor   
/*/                                 
// 21/05/17 - A.Shibao - Ajuste para selecionar multi-filiais e compatibilizado para v12.
//==========================================================================================
User Function DIFLIQ()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara Variavel ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   cDesc1   := "DIFERENCA DE LIQUIDOS "
Local   cDesc2   := "Sera impresso de acordo com os parametros solicitados pelo"
Local   cDesc3   := "usuario."
Local   cString  := "SRC"

Private nLastKey := 0
Private NomeProg := "DIFLIQ"
Private cbtxt    := SPACE(10)
Private Tamanho  := "P"
Private Titulo   := " Diferenca de Liquidos " 
Private Cabec1   := "Fl Matric  Nome                         Valor Somado   Valor Calculado  Diferenca"
Private Cabec2   := ""
Private WnRel    := "DIFLIQ"
Private nTipo    := 15
Private nOrdem   := 1
Private cbcont   := 0
Private Li       := 80
Private m_pag    := 1
Private nTit     := 0
Private aReturn  := {"Zebrado",1,"Administracao",1,2,1,"",1}
Private aRegs    := {}
Private cPerg    := "DIFLIQ"  
Private cShFiliais   := ""

aAdd(aRegs,{cPerg,"01","Filial        ?","Filial De   ?"  , "Filial De ?"   ,"mv_ch1","C"   ,99       ,0        ,0,"R"  ,""                    ,"mv_par01"," "   ,""      ,""      ,"RC_FILIAL"   ,""   ,"         "   ,""    		  ,""     		 ,"","",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","","XM0"	,"S" ,"",".RHFILDE. ",""})
aAdd(aRegs,{cPerg,"02","Roteiro       ?","Roteiro       ?","Roteiro       ?","mv_ch2","C"   ,1        ,0        ,0,"C"  ,""                    ,"mv_par02","Adto","Adto"  ,"Adto"  ,""   		  ,""   ,"Folha"       ,"Folha"       ,"Folha"       ,"","","131","131","131","","","132","132","132","","","","","","",""      ,""  ,"",""          ,""})  
aAdd(aRegs,{cPerg,"03","AnoMes XXXXYY ?","AnoMes XXXXYY ?","AnoMes XXXXYY ?","mv_ch3","C"   ,6        ,0        ,0,"C"  ,"naovazio()"          ,"mv_par03",""    ,""      ,""      ,""			  ,""   ,""            ,""            ,""            ,"","",""   ,""   ,""   ,"","",""   ,""   ,""   ,"","","","","","",""      ,""  ,"",""          ,""})  


ValidPerg(aRegs,cPerg)
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre tela de Impressao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

WnRel:=SetPrint(cString,WnRel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|lEnd| ImpRel(@lEnd,WnRel,cString)},titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PROCSA2  º Autor ³Cleyton Jr          º Data ³  16/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ASOEC                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IMPREL(lEnd,WnRel,cString)

Local cQuery   := ""
Local cQryAux  := ""

Local cFil     := ""
Local cCat     := ""

Local nTotFil1 := 0
Local nTotFil2 := 0
Local nTotCat  := 0
Local nTotEmp1 := 0
Local nTotEmp2 := 0
Local lImpFil  := .T.
Local lImpCat  := .T.
Local nTotFun1 := 0
Local nTotFun2 := 0
Local nTotFEm1 := 0
Local nTotFEm2 := 0 
Local cShFilAnt:= ""

Private ACODFOL:={} 
Private lRet   := .T.

// Carrega tabela de verbas
FP_CODFOL(@ACODFOL,SRA->RA_FILIAL)

CLIQADT	:=	ACODFOL[546,1] // liquido de adto
CLIQFOL	:=	ACODFOL[47,1]  // liquido de folha ( ferias + VA + Vr + Vt + pla +  )
CLIQ131	:=	ACODFOL[678,1] // liquido da 131    
CLIQ132	:=	ACODFOL[21,1]  // liquido da 132

If mv_par02 == 1
	CLIQXXX:= CLIQADT
	cShRot := "'ADI'" 
	cShPerR:= "'ADI'"  // variavel para verificar o periodo se esta aberto ou fechado
ElseIf mv_par02 == 2
	CLIQXXX:= CLIQFOL
	cShRot := "'FOL','FER','VTR','VTA','VRF','PLA','RES'"
	cShPerR:= "'FOL'" 	
ElseIf mv_par03 == 3
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

cShFil := IIf(Empty( mv_par01), "RC_FILIAL >= '"+SPACE(LEN(xfilial("SRC")))+"' AND RC_FILIAL <= '"+Replic("Z",LEN(xfilial("SRC")))+"'", mv_par01)

cQuery := "SELECT RC_FILIAL, RC_MAT, RV_TIPOCOD ,SUM(RC_VALOR) AS TOTFUN, RC_ROTEIR, RC_PERIODO "
cQuery += "FROM " + RetSqlName("SRC") + " SRC, "  + RetSqlName("SRA") + " SRA, "  + RetSqlName("SRV") + " SRV "
cQuery += "WHERE " + cShFil + " " 
cQuery += "AND RC_PD = RV_COD "
cQuery += "AND RC_ROTEIR IN  (" + cShRot  + ") "
cQuery += "AND RV_TIPOCOD = '1' "
cQuery += "AND SRC.D_E_L_E_T_ = ' ' "
cQuery += "AND SRV.D_E_L_E_T_ = ' ' " 
cQuery += "AND RA_SITFOLH <> 'T' "
cQuery += "GROUP BY RC_FILIAL,RC_MAT,RV_TIPOCOD,RC_ROTEIR,RC_PERIODO "
cQuery += "UNION "
cQuery += "SELECT RC_FILIAL, RC_MAT,RV_TIPOCOD,SUM(RC_VALOR) AS TOTFUN, RC_ROTEIR, RC_PERIODO "
cQuery += "FROM " + RetSqlName("SRC") + " SRC, "  + RetSqlName("SRA") + " SRA, "  + RetSqlName("SRV") + " SRV "
cQuery += "WHERE " + cShFil + " " 
cQuery += "AND RC_PD = RV_COD "
cQuery += "AND RC_ROTEIR IN  (" + cShRot  + ") "
cQuery += "AND RV_TIPOCOD = '2' "
cQuery += "AND SRC.D_E_L_E_T_ = ' ' "
cQuery += "AND SRV.D_E_L_E_T_ = ' ' "  
cQuery += "AND RA_SITFOLH <> 'T' "
cQuery += "GROUP BY RC_FILIAL,RC_MAT,RV_TIPOCOD,RC_ROTEIR,RC_PERIODO "
cQuery += "ORDER BY RC_FILIAL,RC_MAT,RV_TIPOCOD "

dbUseArea(.T.,"TopConn",TcGenQry(,,cQuery),"TRB",.T.,.T.)
aFunc := {}

dBSelectArea("TRB")
dBGoTop()

SetRegua(trb->(reccount()))

While ! Eof()

    If !TRB->RC_FILIAL $ fValidFil()
       DbSkip()
       Loop
    EndIf  
    
    cShFilAnt:= TRB->RC_FILIAL 
    
	// Valido se o periodo esta aberto da filial correspondente
	If TRB->RC_FILIAL <> cFilAnt
	
		DbSelectArea( "RCH" )
		DbSetOrder( RetOrdem("RCH","RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG") )
		DbSeek( TRB->RC_FILIAL + "00001" + cShPerR + cPeriodo + "01", .F. )
		
		If (cAliasRCH)->( Eof() )
			Alert("Periodo informado não cadastrado ou ja fechado.")
			lRet := .F.
			Break   
		EndIf
		
		If !Empty((cAliasRCH)->RCH_DTFECH)
			Alert("O período selecionado já está fechado.")			
			lRet := .F.
			Break
		EndIf
		
    Endif
    
	If lRet
	    If ( nPos := Ascan(aFunc,{ |X| x[1] = trb->rc_filial .and. x[2] = trb->rc_mat } )) > 0
	       If Trb->RV_TIPOCOD = "1"
	          aFunc[nPos,4] += trb->totfun
	       Else   
	          aFunc[nPos,4] -= trb->totfun 
	       EndIF
	    Else
	       aAdd(aFunc,{TRB->RC_FILIAL,TRB->RC_MAT,TRB->RV_TIPOCOD,TRB->TOTFUN})
	    EndIF
    Endif
    
   DbSkip()

EndDO             

TRB->(dbCloseArea())

SetRegua(Len(aFunc))  

For n := 1 to Len(aFunc)


	IncRegua()
	
	If Li > 55
  		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	EndIf
	nLiq := 0
	DbSelectArea("SRC")
	If DbSeek(aFunc[n,1]+aFunc[n,2]+CLIQXXX)
	   While aFunc[n,1]+aFunc[n,2]+CLIQXXX == SRC->RC_FILIAL+SRC->RC_MAT+SRC->RC_PD
	      nLiq += SRC->RC_VALOR
	      DbSkip()
	   EndDo   
	EndIf
	
	If AFunc[n,4] <> nLiq
	      @LI, 01 PSAY aFunc[n,1]+"-"+aFunc[n,2] +'-'+Posicione("SRA",1,aFunc[n,1]+aFunc[n,2],"RA_NOME") + Transform(AFunc[n,4], '@e 9,999,999.99') +  Transform(nLiq, '@e 9,999,999.99') + "  " + Transform(AFunc[n,4] - nLiq, '@e 9,999,999.99') 
	      li ++
	EndIF
	      
	
Next 

Set Device to Screen

If aReturn[5] == 1
	Set Printer To
	Commit
	OurSpool(WnRel)
EndIf

Ms_Flush()

Return


**************************
User Function xFilOpc3(mv_par01)
**************************

Local MvPar
Local MvParDef := ""
Local aItens   := {}
Local aArea    := GetArea()

MvPar := &(Alltrim(ReadVar()))       // Carrega Nome da Variavel do Get em Questao
MvRet := Alltrim(ReadVar())          // Iguala Nome da Variavel ao Nome variavel de Retorno

dbSelectArea("SM0")
//dbSetOrder(RetOrder("SM0","SM0_CODIGO+ SM0_CODFIL +SM0_FILIAL"))
dBGotop()
While !Eof() .And. SM0->M0_CODIGO == cEmpAnt
	
		aAdd(aItens, SM0->M0_FILIAL )
		MvParDef += alltrim(SM0->M0_CODFIL)
		
	("SM0")->(dbSkip())
End

//		    Retorno	    ,Titulo  ,  opcoes     , Strin Ret   ,lin  ,col  , Tipo Sel  ,tam chave , n. ele ret, Botao 
IF f_Opcoes  (@MvParDef, "Opcoes", aItens     , MvParDef     ,12   , 49 , .F.        ,  8       ,   999    , .T.  )  // "Opções"
	&MvRet := MvPar                                      // Devolve Resultado
EndIF

cShFiliais:= MvParDef

RestArea(aArea)                                  // Retorna Alias
Return MvParDef
                                                  
