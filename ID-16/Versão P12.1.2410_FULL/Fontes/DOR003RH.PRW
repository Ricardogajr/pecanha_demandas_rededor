#INCLUDE "PROTHEUS.CH"
#Include 'COLORS.CH'
#Include "MSOLE.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | DOR003RH | AUTOR | Edsonho ®                 | DATA |29/03/2017 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - Gera Informativo de Retenção de INSS                   |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
User Function DOR003RH()

Local nContaReg   := 0
Local cMatricula  := ""
Local cRoteiro    := ""
Local cCodFol     := ""   

Private cPerg     := Padr("DOR_RH003",10) 
Private nRecTMP   := 0
Private cAliasTmp := "TMP"
Private cQuery    := ""
Private aTabelas  := {"SRA","SRD","TMP"}
Private cFolder   := ""
Private cLocaPath := "C:\"
Private cPeriodo  := ""
Private aCarta    := {}    
Private cTipoRot  := ""

rg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
EndIf 

cPeriodo := Substr(MV_Par08,5,2)+"/"+Substr(MV_Par08,1,4)

DOR003RH1()

cFolder := cGetFile( "*.DOC", 'Selecione a Pasta para Gravar as Carta(s)',, cLocaPath, .T., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY, .F.)

If nRecTMP > 0
   //+-------------------------------------------------------------------------+//
   //| Muda o cursos para espera, chama a rotina de impressao e volta o cursor |//
   //+-------------------------------------------------------------------------+//
   dbSelectArea(cAliasTmp)
   dbGoTop()
   
   ProcRegua(nRecTMP)

   CursorWait()
    
   While (cAliasTmp)->(!Eof()) 

       aCarta    := {}       
       cMatricula:= (cAliasTmp)->RA_MAT
       cRoteiro  := ""
       cCodFol   := ""
       nContaReg := 0       
 
       While cMatricula == (cAliasTmp)->RA_MAT .And. (cAliasTmp)->(!Eof()) 

         cRoteiro := (cAliasTmp)->RD_ROTEIR
         cCodFol  := (cAliasTmp)->RV_CODFOL

         If cCodFol $ "0013|0019"
            nContaReg++
            aAdd(aCarta,{;
                (cAliasTmp)->RA_MAT,;
                (cAliasTmp)->RA_NOME,;
                 Padl(Alltrim((cAliasTmp)->RA_NUMCP),10,"0")+"/"+Padl(Alltrim((cAliasTmp)->RA_SERCP),10,"0"),;
                (cAliasTmp)->RV_CODFOL,;
                (cAliasTmp)->RD_VALOR,;
                0.00,;
                (cAliasTmp)->RD_ROTEIR})

            While cMatricula == (cAliasTmp)->RA_MAT    .And. ;
                  cRoteiro   == (cAliasTmp)->RD_ROTEIR .And. ;
                  (cAliasTmp)->(!Eof()) 

                  If cCodFol = "0013" .And. (cAliasTmp)->RV_CODFOL $ "0064|0065"  
                     aCarta[1][6] := (aCarta[1][6]+(cAliasTmp)->RD_VALOR)
                  Else
                     If cCodFol = "0019" .And. (cAliasTmp)->RV_CODFOL = "0070"  
                        aCarta[1][6] := (cAliasTmp)->RD_VALOR
                     EndIf
                  EndIf
                 (cAliasTmp)->(DbSkip())
            EndDo
         Else
            (cAliasTmp)->(DbSkip())
         EndIf
       EndDo

       MsgRun("Gerando Carta(s) Retenção INSS... Aguarde...","Gerando Carta(s) Word", {|| DOR003RH2()})

   EndDo

   CursorArrow()

   MsgInfo("Geração da(s) Carta(s) de Retenção de INSS, Finalizado com Sucesso !!!"+Chr(13)+;
           "Foram Gerado(s): "+Alltrim(Str(nContaReg))+" Carta(s) Word."+Chr(13)+;
           "Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Conferir..","*** FIM DO PROCESSAMENTO ***")
Else
   Alert("Não Existem Registros para Geração das Cartas, Retenção de INSS !!!"+Chr(13)+;
           "Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar..","*** FIM DO PROCESSAMENTO ***")
EndIf

If Select(cAliasTmp) > 0
   DbSelectArea(cAliasTmp)
  (cAliasTmp)->(DbCloseArea())  
Endif

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Executa as macros do Word                                                   |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function DOR003RH2()

Local hWord      := Nil
Local aArqDot    := {"RetINSS.dot"}
//Local cDirDocs   := MsDocPath()
Local cBarra     := If(issrvunix(), "/", "\")   
Local cPath 		:= GETTEMPPATH()
//Local cRootPath  := GetSrvProfString("RootPath","")  //    "C:\TOTVS_Projects\Diversos\P12\protheus_data"
//Local cPathEst   := GetSrvProfString("StartPath","")+"DOTS\"   // "\system\"
Local cPathEst   := GetSrvProfString("StartPath","")+"dots/"   // "\system\"
//Local cPathEst   := "C:\TOTVS_Projects\Diversos\P12\protheus_data\"+GetSrvProfString("StartPath","")+"DOTS\"
//Local cPathEst   := "C:\Temp\dots\"
Local nTotLin    := 0
Local nTotal     := 0
Local cArqSaida  := ""
Local cArqWord   := ""          
Private cFuncion := ""
Private cCTPS    := ""
Private cDtaCompl:= ""




//+-------------------------------------------------+
//| Regrava o arquivo .DOT na estacao do usuario    |
//+-------------------------------------------------+

//If File(StrTran(cPathEst+aArqDot[1],"\\","\"))
//	Ferase(StrTran(cPathEst+aArqDot[1],"\\","\"))
//EndIf

//+-------------------------------------------------+
//| Copia do Server para o Remote                   |
//+-------------------------------------------------+

cArqWord := cPathEst+aArqDot[1]
                
CpyS2T(cArqWord,cPath, .T.)
cArqWord	:= cPath+aArqDot[1]
	
//+-------------------------------------------------+
//| Cria o link com o WORD                          |
//+-------------------------------------------------+
hWord := OLE_CreateLink()
If hWord == "-1"
	Aviso("Inconsistência","Impossível estabelecer comunicação com o Microsoft Word.",{"Sair"},,"Atenção:")
	OLE_CloseFile( hWord )
	OLE_CloseLink( hWord )
	Return
Endif

OLE_NewFile(hWord,cArqWord)
If cNivel > 8
	OLE_SetProperty(hWord, oleWdVisible, .T.)
Else
	OLE_SetProperty(hWord, oleWdVisible, .F.)
EndIf

cDtaCompl := Alltrim(SM0->M0_CIDCOB)+", "+StrZero(Day(dDataBase),2)+" de "+MesExtenso(dDataBase)+" de "+StrZero(Year(dDataBase),4)+"."
cCTPS     := Padl(Alltrim((cAliasTmp)->RA_NUMCP),10,"0")+"/"+Padl(Alltrim((cAliasTmp)->RA_SERCP),10,"0")
If MV_Par07 == 1
   cTipoRot := "Folha de Pagto."
ElseIf MV_Par07 == 2
   cTipoRot := "13° Salário"
EndIf

//+----------------------------------------------------+
//| Preenchimento das variaveis estáticas do documento |
//+----------------------------------------------------+
OLE_SetDocumentVar( hWord, "AP5_cDtaCompl" ,cDtaCompl)
OLE_SetDocumentVar( hWord, "AP5_cRazaoEmp" ,SM0->M0_NOMECOM)
OLE_SetDocumentVar( hWord, "AP5_RA_MAT"    ,aCarta[1][1])
OLE_SetDocumentVar( hWord, "AP5_RA_NOME"   ,aCarta[1][2])
OLE_SetDocumentVar( hWord, "AP5_cCTPS"     ,aCarta[1][3])
OLE_SetDocumentVar( hWord, "AP5_cPeriodo"  ,cPeriodo)
OLE_SetDocumentVar( hWord, "AP5_VLRBASE"   ,Alltrim(Transform(aCarta[1][5],'@E 999,999,999.99')))
OLE_SetDocumentVar( hWord, "AP5_VLRRETEN"  ,Alltrim(Transform(aCarta[1][6],'@E 999,999,999.99')))
OLE_SetDocumentVar( hWord, "AP5_cRoteiro"  ,cTipoRot)

//+-------------------------------------------------------+
//| Atualiza os campos, imprime e fecha o link com o Word |
//+-------------------------------------------------------+
OLE_UpdateFields(hWord)

cArqSaida:= cFolder+"COLABORADOR-" + Alltrim(aCarta[1][1]) +"-" + Alltrim(aCarta[1][2]) +"-"+IIf(MV_Par07 == 1,"FOLHA","2P13S")+".DOC"

If File(cArqSaida)
	Ferase(cArqSaida)
EndIf

OLE_SaveAsFile( hWord, cArqSaida )
OLE_CloseFile( hWord )
OLE_CloseLink( hWord )

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Gera Registros para Tabela Temporaria                                       |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function DOR003RH1()

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
cQuery += " SRA.RA_MAT,"+cCrLf
cQuery += " SRV.RV_CODFOL,"+cCrLf
cQuery += " SRV.RV_COD,"+cCrLf
cQuery += " SRV.RV_DESC,"+cCrLf
cQuery += " SRD.RD_ROTEIR,"+cCrLf
cQuery += " SRD.RD_VALOR,"+cCrLf
cQuery += " SRA.RA_FILIAL,"+cCrLf
cQuery += " SRA.RA_NOME,"+cCrLf
cQuery += " SRA.RA_NUMCP,"+cCrLf
cQuery += " SRA.RA_SERCP"+cCrLf
cQuery += " From "+RetSqlName("SRV")+" SRV "+cCrLf
cQuery += " Inner Join "+RetSqlName("SRD")+" SRD On "+cCrLf
cQuery += "  SRD.RD_PD = SRV.RV_COD And SRD.D_E_L_E_T_ = ' '  "+cCrLf 
cQuery += " Inner Join "+RetSqlName("SRA")+" SRA On "+cCrLf
cQuery += "  SRA.RA_FILIAL  = SRD.RD_FILIAL And "+cCrLf 
cQuery += "  SRA.RA_MAT     = SRD.RD_MAT And SRA.D_E_L_E_T_ = ' '  "+cCrLf 
cQuery += " Where SRV.D_E_L_E_T_ = ' '  And "+cCrLf
If MV_Par07 == 1
   cTipoRot := "Folha de Pagto."
   cQuery += "  SRV.RV_CODFOL In ('0013','0064','0065') And "+cCrLf
ElseIf MV_Par07 == 2
   cTipoRot := "2ªParc.13°"
   cQuery += "  SRV.RV_CODFOL In ('0019','0070') And "+cCrLf
EndIf
cQuery += "  SRA.RA_MAT Between '"+MV_Par03+"' And '"+MV_Par04+"' And "+cCrLf
cQuery += "  SRA.RA_SITFOLH In ("+cSitQuery+") And "+cCrLf
cQuery += "  SRA.RA_CATFUNC In ("+cCatQuery+") And "+cCrLf
cQuery += "  SRD.RD_PERIODO = '"+MV_Par08+"' "+cCrLf
cQuery += "Order By SRA.RA_MAT,SRD.RD_ROTEIR,SRV.RV_CODFOL"

//MemoWrite("C:\TOTVS_Projects\Projetos\PROTHEUS_LOCAL\PROTHEUS12\Query\DOR003RH.SQL",cQuery)

ChangeQuery(cQuery)

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
//Aadd(aRegs,{cPerg, "01"  ,"Filial De          ?","Filial De          ?"  , "Filial De          ?"   ,"MV_CH0","C" ,08     ,0      ,0     ,"G",""                                                   ,"mv_par01","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0","S" ,"" ,".RHFILDE. ",""})
//Aadd(aRegs,{cPerg, "02"  ,"Filial Ate         ?","Filial Ate         ?"  , "Filial Ate         ?"   ,"MV_CH0","C" ,08     ,0      ,0     ,"G",""                                                   ,"mv_par02","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"XM0","S" ,"" ,".RHFILATE.",""})
//Aadd(aRegs,{cPerg, "03"  ,"Matricula De       ?","Matricula De       ?"  , "Matricula De       ?"   ,"MV_CH0","C" ,06     ,0      ,0     ,"G",""                                                   ,"mv_par03","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA","S" ,"" ,".RHMATD.  ",""})
//Aadd(aRegs,{cPerg, "04"  ,"Matricula Ate      ?","Matricula Ate      ?"  , "Matricula Ate      ?"   ,"MV_CH0","C" ,06     ,0      ,0     ,"G",""                                                   ,"mv_par04","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRA","S" ,"" ,".RHMATA.  ",""})
//Aadd(aRegs,{cPerg, "05"  ,"Situacao           ?","Situacao           ?"  , "Situacao           ?"   ,"MV_CH0","C" ,05     ,0      ,0     ,"G","fSituacao"                                          ,"mv_par05","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,"" ,".RHSITUA. ",""})
//Aadd(aRegs,{cPerg, "06"  ,"Categoria          ?","Categoria          ?"  , "Categoria          ?"   ,"MV_CH0","C" ,15     ,0      ,0     ,"G","fCategoria"                                         ,"mv_par06","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,"S" ,"" ,".RHCATEG. ",""})
////Aadd(aRegs,{cPerg, "07"  ,"Roteiro de Calculo ?","Roteiro de Calculo ?"  , "Roteiro de Calculo ?"   ,"MV_CH0","C" ,03     ,0      ,0     ,"G","Gpr040Roteiro()"                                    ,"mv_par07","                  "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SRY","S" ,"" ,".RHROT.   ",""})
//Aadd(aRegs,{cPerg, "07"  ,"Roteiro de Calculo ?","Roteiro de Calculo ?"  , "Roteiro de Calculo ?"   ,"MV_CH0","N" ,01     ,0      ,0     ,"N","               "                                    ,"mv_par07","Folha de Pagto."   ,""     ,""     ,""   ,""   ,"2ªParc.13°"   ,""     ,""     ,""   ,""   ,"",""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""})
//Aadd(aRegs,{cPerg, "08"  ,"Periodo            ?","Periodo            ?"  , "Periodo            ?"   ,"MV_CH0","C" ,06     ,0      ,0     ,"G",""                                                   ,"mv_par08","              "   ,""     ,""     ,""   ,""   ,"             "   ,""     ,""     ,""   ,""   ,""     ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"RCH","S" ,"" ,"",""})
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
//
////040718

//0013 -> 0064+0065 FOL
//0019 -> 0070 (Décimo Terceiro 2.Parcela [132]

/*

mv_par08
"201704"
mv_par07
"FOL"


RD_ROTEIR  = "FOL"  (Folha de Pagamento)
RD_PERIODO = "201704" 

IDCalculo     Verbas
RV_CODFOL  RV_COD/RD_PD   RD_VALOR
  0013         928        5.189,82 Base
  0064         500          264,41 Retenção
  0065         503          304,47    "
===============================================================================
RD_ROTEIR  = "132"  (Décimo Terceiro 2.Parcela)
RD_PERIODO = "201704" 

IDCalculo     Verbas
RV_CODFOL  RV_COD/RD_PD   RD_VALOR
  0019         834        3.670,69 Base
  0070         502          403,77 Retenção

...............................................................................
RD_ROTEIR  = "FOL"  (Folha de Pagamento) ==> "132"  (Décimo Terceiro 2.Parcela)
RD_PERIODO = "201704" 

IDCalculo     Verbas
RV_CODFOL  RV_COD/RD_PD   RD_VALOR
  0019         834        1.519,13 Base
  0070         502          167,11 Retenção

*/