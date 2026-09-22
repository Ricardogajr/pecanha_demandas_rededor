#Include 'Protheus.ch'
#INCLUDE "TopConn.Ch"
#INCLUDE "FONT.CH"      
#INCLUDE "FILEIO.CH"

/*
{Protheus.doc} TEWBTYI1
Importação de Planilha Orçamentária.
@Author     Ramon Teodoro e Silva
@Since      12/02/2016     
@Version    P12.7
@Return
*/

User Function TEWBTYI1()

Local lRet 		:= .T.
Local nOpca		:= 0  
Local aObjects  := {}
Local aArea     := GetArea() 
Local _aCmpAK1	:= {} //Thais Paiva - Compatibilização P27

Private a_AK1     := {}
Private oDlg	
Private aCabAK1		:= {}
Private aSizeAut  	:= MsAdvSize()
Private oFont	 	:= TFont():New("Arial",,15,,.T.)
Private oGetAno
Private aBotoes 	:= {}
Private aGETS   	:= {}
Private aTELA   	:= {}

Private cGetCod := "" 
Private cGetRev := "" 
Private cGetAno	:= "" //Alltrim(Str((Year(Date())))) //Space(4)  

AAdd( aObjects, { 300, 030, .T., .F. } )
AAdd( aObjects, { 300, 070, .T., .T. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE "IMPORTAÇÃO PCO" From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

@ aPosObj[1][1]+5,aPosObj[1][2]+5 Say "Selecione uma planilha orçamentária" SIZE 200,100 FONT oFont COLOR CLR_HBLUE OF oDlg PIXEL
//@ aPosObj[1][1]+5,aPosObj[1][2]+65 MsGet oGetAno Var cGetAno Size 020,005 COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

@ aPosObj[2][1], aPosObj[2][2] TO aPosObj[2][3], aPosObj[2][4] LABEL "Planilhas Orçamentárias" PIXEL OF oDlg

*----------------------------------------------------------------*
*   Montagem do LISTBOX
*----------------------------------------------------------------*

dbSelectArea("AK1")
dbSetOrder(1)

cQuery1 := "SELECT AK1_CODIGO,AK1_VERSAO,AK1_VERREV, AK1_DESCRI, AK1_INIPER "	
cQuery1 += "FROM "+RetSqlName("AK1")+" AK1 "
cQuery1 += "WHERE AK1.AK1_FILIAL='" + xFilial("AK1") + "' AND "
cQuery1 +=       "AK1.D_E_L_E_T_ = ' ' "
cQuery1 += "ORDER BY AK1_FILIAL,AK1_CODIGO,AK1_VERSAO"

If Select("TRB1")>0
	DbSelectArea("TRB1")
	DbCloseArea()
	DbSelectArea("AK1")
EndIf

TCQUERY cQuery1 New Alias "TRB1"

DBSelectArea("TRB1")

While !EOF()
	
	aAdd( a_AK1, { TRB1->AK1_CODIGO, TRB1->AK1_VERSAO, TRB1->AK1_VERREV, TRB1->AK1_DESCRI, TRB1->AK1_INIPER })
	
	DbSelectArea("TRB1")
	Dbskip()
End

If Len(a_AK1) = 0
	aAdd( a_AK1, { "", "", "", "", "" })
EndIf

//   Montagem da aHeader                                          
nUsado := 0

//Início - Thais Paiva - Compatibilização P27
//DbSelectArea("SX3")
//DbSetOrder(1)
//DbSeek("AK1")
_aCmpAK1 := FWSX3Util():GetAllFields( "AK1" , .T. )
//While ( !Eof() .And. SX3->X3_ARQUIVO == "AK1" )
For _nK1 := 1 to Len(_aCmpAK1)
	//If ( cNivel >= SX3->X3_NIVEL ) .And. ;
	//	( Upper(Alltrim(SX3->X3_Campo)) == "AK1_CODIGO" .Or. Upper(Alltrim(SX3->X3_Campo)) == "AK1_VERSAO" .Or. ;
	//	Upper(Alltrim(SX3->X3_Campo)) == "AK1_VERREV" .Or. Upper(Alltrim(SX3->X3_Campo)) == "AK1_DESCRI" )
	If ( cNivel >= GetSx3Cache(_aCmpAK1[_nK1], 'X3_NIVEL') ) .And. ;
		( Upper(Alltrim(GetSx3Cache(_aCmpAK1[_nK1], 'X3_CAMPO'))) == "AK1_CODIGO" .Or. ;
		  Upper(Alltrim(GetSx3Cache(_aCmpAK1[_nK1], 'X3_CAMPO'))) == "AK1_VERSAO" .Or. ;
		  Upper(Alltrim(GetSx3Cache(_aCmpAK1[_nK1], 'X3_CAMPO'))) == "AK1_VERREV" .Or. ;
		  Upper(Alltrim(GetSx3Cache(_aCmpAK1[_nK1], 'X3_CAMPO'))) == "AK1_DESCRI" )
		
		nUsado++
		//Aadd(aCabAK1,{ TRIM(X3Titulo()),TRIM(SX3->X3_CAMPO) } )
		Aadd(aCabAK1,{ ALLTRIM(GetSx3Cache(_aCmpAK1[_nK1], 'X3_TITULO')),ALLTRIM(GetSx3Cache(_aCmpAK1[_nK1], 'X3_CAMPO')) } )
		
	EndIf
	//DbSelectArea("SX3")
	//DbSkip()
//End
Next _nK1
//Fim - Thais Paiva - Compatibilização P27

@ aPosObj[2][1]+10, aPosObj[2][2]+03 LISTBOX oLbx VAR cVar FIELDS HEADER aCabAK1[1][1],aCabAK1[2][1],aCabAK1[3][1],aCabAK1[4][1] ;
SIZE aPosObj[2][4]-09,aPosObj[2][3]-aPosObj[2][1]-13 OF oDlg PIXEL ON CHANGE U_MudaLin(oLbx:nAt)

oLbx:SetArray( a_AK1 )
oLbx:bLine := {|| {	a_AK1[oLbx:nAt,1],;
a_AK1[oLbx:nAt,2],;
a_AK1[oLbx:nAt,3],;
a_AK1[oLbx:nAt,4],;
a_AK1[oLbx:nAt,5]}}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ || IIF(  ( OBRIGATORIO(AGETS,ATELA)  ), (nOpca := 1, iif(U_F57IdArq(), oDlg:END(), nOpca := 0)), nOpca := 0)  }, { || oDlg:END() },,aBotoes)

DbSelectArea("TRB1")
DbCloseArea()

RestArea(aArea)                                                  
Return lRet

/*
{Protheus.doc} F57IdArq
Importa os dados do arquivo CSV para as tabelas relacionadas.
@Author     Ramon Teodoro e Silva
@Since      12/02/2016      
@Version    P12.7
@Return
*/

User Function F57IdArq

Local lRet 	:= .T.
Local nOpca	:= 0   
Local aArea := GetArea()

Private oDlg2	
Private cComboBx1   := "AK1, AK2 e AK3"
Private c_dirimp 	:= space(100) 

DEFINE MSDIALOG oDlg2 TITLE "Importação de Dados" FROM U_F57ResTela(000),U_F57ResTela(000) TO U_F57ResTela(100),U_F57ResTela(270) PIXEL
@ 010,009 Say   "Diretorio"       Size 045,008 PIXEL OF oDlg2  //033
@ 018,009 MSGET c_dirimp          Size 120,010 WHEN .F. PIXEL OF oDlg2 //041
@ 018,140 BUTTON "..."            Size 013,013 PIXEL OF oDlg2   Action(c_dirimp := cGetFile("*.csv|*.csv","Importacao de Dados",0, ,.T.,GETF_LOCALHARD))
@ 037,009 Button "OK"       Size U_F57ResTela(037),U_F57ResTela(012) PIXEL OF oDlg2 Action(nOpca := 1,oDlg2:End())
@ 037,060 Button "Cancelar" Size U_F57ResTela(037),U_F57ResTela(012) PIXEL OF oDlg2 Action(nOpca := 0, oDlg2:end())

ACTIVATE MSDIALOG oDlg2 CENTERED

If nOpca == 1
	If Empty(c_dirimp)
		MsgInfo("Nenhum arquivo CSV foi selecionado! Importação não realizada.")
		lRet := .F.
	Else
		Processa( { || F57ImpCsv() }, "Processando..." )
	EndIf
Else
	lRet := .F.
Endif
         
RestArea(aArea)     
Return lRet

/*
{Protheus.doc} F57ImpCsv
Importa os dados do arquivo CSV para as tabelas relacionadas.
@Author     Ramon Teodoro e Silva
@Since      12/02/2016      
@Version    P12.7
@Return
*/
Static Function F57ImpCsv()

Local cBuffer	:= ""
Local aInfo		:= {}
Local nXPos		:= ""
Local aTmpDados	:= {}
Local lImp 		:= .F.
Local cQuery	:= ""
Local lRet		:= .T.
Local nMes		:= 0
Local cDS 		:= " "     
Local aHeader   := {}

Local nIt       := 0
Local nCO       := 0
Local nCC       := 0
Local nClVl     := 0
Local nUniOr    := 0
Local nVal01    := 0 
Local nTot      := 0
Local nK2       := 0
Local nK3       := 0 
Local nAx       := 0  
Local nNC       := 0   
Local nTotRec   := 0
Local nLinAtu   := 0
Local nContL    := 0

Private aGrvAK3    := {}
Private aGrvAK2    := {}

Private cArquiv := c_dirimp
Private aDados 	:= {}
Private nDados	:= 0
Private aERRO   := {} 
Private cGetCO  := "" 
Private cGetCC  := "" 
Private cGetUn  := ""
Private cNivelAtu := ""

FT_FUSE(cArquiv)

FT_FGOTOP()

cBuffer  := FT_FREADLN()
nTotRec  := FT_FLASTREC()
nLinAtu := 0
ProcRegua(nTotRec)

Begin Transaction

aDados := {}
FT_FGOTOP()        

DbSelectArea("AK5")    
DbSelectArea("CTT")
DbSelectArea("CTH")
DbSelectArea("CTD")
DbSelectArea("AKF")

While !FT_FEOF() 	
	
	nLinAtu += 1
	nContL  += 1
	IncProc( "Importando Planilha. Registro " + AllTrim( Str( nLinAtu ) ) + " de " + AllTrim( Str( nTotRec ) ) )
		
	cBuffer := FT_FREADLN()
	cBuffer := NoAcento(cBuffer)
	aTmpDados := {}
	
	If Empty(cBuffer)
		Exit
	Endif
	
	nXPos := AT(";",cBuffer)
  	If !Empty(SubStr(cBuffer , 1, nXPos-1 )) 
		
		If IsDigit(SubStr(cBuffer , 1, nXPos-1 ))
			
			While nXPos <> 0
				aInfo := Alltrim(SubStr(cBuffer , 1, nXPos-1 ))                          
				aAdd( aTmpDados , aInfo )
				cBuffer:= SubStr(cBuffer , nXPos+1, Len(cBuffer)-nXPos)
				nXPos := AT(";",cBuffer)
			End
			
			If Len(cBuffer) > 0
				aInfo := Alltrim(SubStr(cBuffer , 1, Len(cBuffer) ))
				aAdd( aTmpDados , aInfo )
			EndIf
			
			aAdd( aDados, aTmpDados )
			nDados++
						
			lImp := .T. 
		Else
			
			While nXPos <> 0
				Aadd(aHeader, Alltrim(SubStr(cBuffer , 1, nXPos-1 )))
				cBuffer:= SubStr(cBuffer , nXPos+1, Len(cBuffer)-nXPos)
				nXPos := AT(";",cBuffer)
			End
			
			If Len(cBuffer) > 0
				Aadd(aHeader, Alltrim(SubStr(cBuffer , 1, Len(cBuffer))))
			EndIf
		   
		    For nAx := 1 to Len(aHeader)
		   
			   nCO         := IIF( Alltrim(aHeader[nAx]) == "AK3_CO", nAx, nCO) 
			   nCC         := IIF( Alltrim(aHeader[nAx]) == "AK2_CC", nAx, nCC) 
			   nUniOr      := IIF( Alltrim(aHeader[nAx]) == "AK2_UNIORC", nAx, nUniOr)
			   nClVl       := IIF( Alltrim(aHeader[nAx]) == "AK2_CLVLR", nAx, nClVl)
			   nVal01      := IIF( Upper(Alltrim(aHeader[nAx])) == "JAN", nAx, nVal01) 
			   nTot        := IIF( Upper(Alltrim(aHeader[nAx])) == "TOTAL", nAx, nTot)
		
			Next nAx
			
			lImp := .F. 
		EndIf
	Else
	  	lImp := .F. 
	EndIf
	
   	If lImp
   	 	                                         
   	 	cGetCO  := AllTrim(aDados[nDados][nCO]) 
	    cGetCC  := AllTrim(aDados[nDados][nCC])
		cGetUn  := AllTrim(aDados[nDados][nUniOr])
		
		AK5->(DbSetOrder(1))
		If !AK5->(DbSeek( xFilial( "AK5" ) + cGetCO ))
			cErro := "Conta Orçamentária não encontrada"
			If aScan(aERRO, {|x| alltrim(x[2]) == cGetCO .and. x[3] = cErro}) = 0
				aAdd( aERRO, { nLinAtu, cGetCO, cErro} )
			EndIf  ak5
			lImp := .f.
	   	Else  
			If !(AK5->AK5_CODIGO == cGetCo) 
				cErro := "Conta Orçamentária não encontrada"
				If aScan(aERRO, {|x| alltrim(x[2]) == cGetCO .and. x[3] = cErro}) = 0
					aAdd( aERRO, { nLinAtu, cGetCO, cErro} )
				EndIf  ak5
				lImp := .f.
			Else
				cDS :=	AK5->AK5_DESCRI
			EndIf
		EndIf       
		
	    CTT->(DbSetOrder(1))
		If !CTT->(DbSeek(xFilial("CTT")+cGetCC))
			cErro := "Centro de Custo não encontrado"
			If aScan(aERRO, {|x| alltrim(x[2]) == cGetCC .and. x[3] = cErro}) = 0
				aAdd( aERRO, {nLinAtu, cGetCC, cErro} )
			EndIf    
			lImp := .f.
		Else
			If !(CTT->CTT_CUSTO == cGetCC) 
				cErro := "Centro de Custo não encontrado"
				If aScan(aERRO, {|x| alltrim(x[2]) == cGetCC .and. x[3] = cErro}) = 0
					aAdd( aERRO, {nLinAtu, cGetCC, cErro} )
				EndIf    
				lImp := .f.
			EndIf
		EndIf
		
	  	AMF->(DbSetOrder(1))
		If !AMF->(DbSeek(xFilial("AMF")+cGetUn)) .And. !Empty(cGetUn) 
			cErro := "Unidade Orçamentária não encontrada"
			If aScan(aERRO, {|x| alltrim(x[2]) = cGetUn .and. x[3] = cErro}) = 0
				aAdd( aERRO, {nLinAtu, cGetUn, cErro} )
			EndIf   
			lImp := .f.
		Else
			If !(Alltrim(AMF->AMF_CODIGO) == cGetUn) 
				cErro := "Unidade Orçamentária não encontrada"
				If aScan(aERRO, {|x| alltrim(x[2]) = cGetUn .and. x[3] = cErro}) = 0
					aAdd( aERRO, {nLinAtu, cGetUn, cErro} )
				EndIf   
				lImp := .f.
			EndIf
		EndIf	
		
		If 	!lImp
			FT_FSKIP()
			Loop   
		EndIf	   
			
	   	cNivelAtu := ""
		
		DbSelectArea("AK3")
		AK3->(DbSetOrder(1)) 
		If !AK3->(DbSeek(xFilial("AK3") + PadR(cGetCod, TamSX3("AK3_ORCAME")[1]) + PadR(cGetRev, TamSX3("AK3_VERSAO")[1]) + PadR(cGetCO, TamSX3("AK3_CO")[1]) ))
			
			cNivelAtu := U_F57IdNivel(cGetCod, cGetRev,cGetCO)
			
			If AK5->AK5_TIPO = "1"	//Conta Orçamentária Sintetica
		
			   	If !Empty(cNivelAtu)
				  	DbSelectArea("AK3")
				
					Aadd(aGrvAK3, {cGetCod, cGetRev, cGetCO, IIF( AllTrim( AK5->AK5_TIPO ) == "", cGetCod, AK5->AK5_COSUP ),AK5->AK5_TIPO, cDS, cNivelAtu} )
					     
				Else
					cErro := "Nível não definido para a Conta Orçamentária"
					If aScan(aERRO, {|x| alltrim(x[2]) == alltrim(cGetCO) .and. x[3] = cErro}) = 0
						aAdd( aERRO, {nLinAtu, cGetCO, cErro} )
					EndIf
				EndIf 
			
			ElseIf AK5->AK5_TIPO = "2"  
			
				Aadd(aGrvAK3, {cGetCod, cGetRev, cGetCO, IIF( AllTrim( AK5->AK5_COSUP ) == "", cGetCod, AK5->AK5_COSUP ),AK5->AK5_TIPO, cDS, cNivelAtu})  
			
			//	U_F57IdCtaS(cGetCod, cGetRev, cGetCO)
			
			EndIf
		Else
			Aadd(aGrvAK3, {cGetCod, cGetRev, cGetCO, AK3->AK3_PAI,AK3->AK3_TIPO, AK3->AK3_DESCRI, AK3->AK3_NIVEL} )
		EndIf	
		
	    If aScan(aGrvAK3, {|x| alltrim(x[3]) == Alltrim(cGetCO) }) > 0 
	    
			nMes := 0
			For nNc := nVal01 To nTot-1 
				
				nMes++                         	
				If Abs(Val( StrTran( StrTran( aDados[nDados][nNc], ".", "" ), ",", "." ) )) > 0
					
					dPeriodo := StoD( cGetAno + StrZero( nMes, 02 ) + "01" )   
				
				    cQuery := "SELECT AK2_FILIAL, AK2_ORCAME, AK2_VERSAO, AK2_CO, AK2_PERIOD, AK2_CC, AK2_UNIORC "									    
					cQuery += " FROM "+RetSqlName("AK2")+" AK2 "					    
					cQuery += " WHERE AK2.AK2_FILIAL=  '" + xFilial("AK2") + "' "	
					cQuery += "  AND AK2.AK2_ORCAME = '" + Alltrim(cGetCod) + "' "   
					cQuery += "  AND AK2.AK2_VERSAO = '" + Alltrim(cGetRev) + "' "
					cQuery += "  AND AK2.AK2_CO     = '" + Alltrim(cGetCO) + "' "
				  	cQuery += "  AND AK2.AK2_PERIOD = '" + DtoS(dPeriodo) + "' "    
					cQuery += "  AND AK2.AK2_CC     = '" + Alltrim(cGetCC) + "' "	
					cQuery += "  AND AK2.AK2_UNIORC = '" + Alltrim(cGetUN) + "' "	
				  	cQuery += "  AND AK2.D_E_L_E_T_ = ' ' "
					
					If Select("TRB1AK2")>0
						DbSelectArea("TRB1AK2")
						TRB1AK2->(DbCloseArea())
					EndIf
					
					TCQUERY cQuery New Alias "TRB1AK2"
					
					If TRB1AK2->(Eof())
					/*	cErro := "Orçamento-Versão-Conta-Periodo-C.Custo-Unid.Orçamentária, já existe(m)" // - CC - Classe - Item Ctb, já existe"
						If aScan(aERRO, {|x| Alltrim(x[2]) == Alltrim(cGetCod +"-"+ cGetRev +"-"+ cGetCO +"-"+ DtoC(dPeriodo) +"-"+ cGetCC +"-"+ cGetUN) .and. x[3] = cErro}) = 0
							aAdd( aERRO, {nLinAtu, cGetCod +"-"+ cGetRev +"-"+ cGetCO +"-"+ DtoC(dPeriodo) +"-"+ cGetCC +"-"+ cGetUN, cErro} )
						EndIf
					Else*/
						
						If aScan(aGrvAK2, {|x| Alltrim(x[3] + DtoC(x[4]) + x[5] + x[6] ) == Alltrim(cGetCO + DtoC(dPeriodo) + cGetCC + cGetUn) }) == 0	 
										
							aAdd(aGrvAK2, {cGetCod,;                                        //1
										   cGetRev,;                                        //2
							               cGetCO,;                                         //3
									 	   dPeriodo,;                                       //4
										   cGetCC,;                                         //5
										   cGetUn,;                                         //6
										   Abs(Val( StrTran( StrTran( aDados[nDados][nNc], ".", "" ), ",", "." ) ))  })                         //8
						
						Else 
							cErro := "Orçamento-Versão-Conta-Periodo-C.Custo-Unid.Orçamentária, duplicado." //já existe(m)"
					  		If aScan(aERRO, {|x| alltrim(x[2]) == alltrim(cGetCod +"-"+ cGetRev +"-"+ cGetCO +"-"+ DtoC(dPeriodo) +"-"+ cGetCC +"-"+ cGetUn) .and. x[2] = cErro}) = 0
					   			aAdd( aERRO, {nLinAtu, cGetCod +"-"+ cGetRev +"-"+ cGetCO +"-"+ DtoC(dPeriodo) +"-"+ cGetCC +"-"+ cGetUn, cErro} )
					  		EndIf
						EndIf
						
					Endif
					
					TRB1AK2->(DbCloseArea())
				Endif
			Next nNc 
		Endif 
	EndIf
	lImp := .F.
	
	If nContL == 100 .Or. ( nContL < 100 .And. nContL == nTotRec )  
		
		nContL := 0
		
		DbSelectArea("AK3")  
		AK3->(DbSetOrder(1))
		
		ProcRegua(Len(aGrvAK3))
		
		For nK3 := 1 to Len(aGrvAK3)
		    
		    IncProc( "Gravando Contas. Registro " + AllTrim( Str( nK3 ) ) + " de " + AllTrim( Str( Len(aGrvAK3) ) ) )
		    
		 	If !AK3->(DbSeek(xFilial("AK3") + PadR(aGrvAK3[nK3][1], TamSX3("AK3_ORCAME")[1]) + PadR(aGrvAK3[nK3][2], TamSX3("AK3_VERSAO")[1]) + PadR(aGrvAK3[nK3][3], TamSX3("AK3_CO")[1])))
		
		 		RecLock("AK3",.T.)
							
				AK3->AK3_FILIAL := xFilial( "AK3" )
				AK3->AK3_ORCAME	:= aGrvAK3[nK3][1]
				AK3->AK3_VERSAO	:= aGrvAK3[nK3][2]
				AK3->AK3_CO		:= aGrvAK3[nK3][3]
				AK3->AK3_PAI	:= aGrvAK3[nK3][4]
				AK3->AK3_TIPO	:= aGrvAK3[nK3][5]
				AK3->AK3_DESCRI	:= aGrvAK3[nK3][6]
				AK3->AK3_NIVEL	:= aGrvAK3[nK3][7]
				
				AK3->( MsUnLOCK() )
						
			EndIf
			
		Next nK3
		
		aGrvAK3 := {}
		   
		DbSelectArea("AK2")  
		AK2->(DbSetOrder(1))
		
		If !Empty(aGrvAK2)
			
			ProcRegua(Len(aGrvAK2))
					
			PcoIniLan("000252")
				
			For nK2 := 1 to Len(aGrvAK2)
				 
				IncProc( "Gravando Orçamento. Registro " + AllTrim( Str( nK2 ) ) + " de " + AllTrim( Str( Len(aGrvAK2) ) ) )
			 	
			 	cQuery := "SELECT COUNT(AK2_ID) AS ID "						
				cQuery += "FROM "+RetSqlName("AK2")+" AK2 "					
				cQuery += "WHERE AK2.AK2_FILIAL='" + xFilial("AK2") + "' "	
				cQuery += "  AND AK2.AK2_ORCAME = '" + alltrim(aGrvAK2[nK2][1]) + "' "	
				cQuery += "  AND AK2.AK2_VERSAO = '" + alltrim(aGrvAK2[nK2][2]) + "' "		
				cQuery += "  AND AK2.AK2_CO     = '" + alltrim(aGrvAK2[nK2][3]) + "' "	
				cQuery += "  AND AK2.AK2_PERIOD = '" + DtoS(aGrvAK2[nK2][4]) + "' "
				cQuery += "  AND AK2.D_E_L_E_T_ = ' ' "
				
				If Select("TRB2AK2")>0
					DbSelectArea("TRB2AK2")
					TRB2AK2->(DbCloseArea())
				EndIf
				
				TCQUERY cQuery New Alias "TRB2AK2"
			 	
		 		RecLock("AK2",.T.)
							
				AK2->AK2_FILIAL := xFilial("AK2")
				AK2->AK2_ID 	:= StrZero(TRB2AK2->(ID)+1, TamSX3("AK2_ID")[1]) 
				AK2->AK2_ORCAME := aGrvAK2[nK2][1]
				AK2->AK2_VERSAO := aGrvAK2[nK2][2]
				AK2->AK2_CO 	:= aGrvAK2[nK2][3]
				AK2->AK2_PERIOD := aGrvAK2[nK2][4]
				AK2->AK2_CC 	:= aGrvAK2[nK2][5]
				AK2->AK2_CLASSE := aGrvAK2[nK2][1]
				AK2->AK2_UNIORC := aGrvAK2[nK2][6]
				AK2->AK2_VALOR  := aGrvAK2[nK2][7]
				AK2->AK2_MOEDA  := 1 
				AK2->AK2_DATAI  := aGrvAK2[nK2][4]
				AK2->AK2_DATAF  := LastDay(aGrvAK2[nK2][4])
			   	
				AK2->(MsUnLOCK())
				
				PcoDetLan("000252","01","TEWBTYI1",,,,.F.)
				
			Next nK2	 
			
			If Select("TRB2AK2")>0
				DbSelectArea("TRB2AK2")
				TRB2AK2->(DbCloseArea())
			EndIf
			
			PcoFinLan("000252")   
		
			aGrvAK2 := {}
		
		EndIf			
		
	EndIf

	FT_FSKIP()
End          

End Transaction

FT_FUSE()
c_dirimp := ""

If Len(aERRO) > 0
//	If Aviso("ATENÇÃO", "Foram encontrados Inconsistências na importação. Deseja gerar log?", {"Sim", "Nao"}, 1) = 1
		U_F57ImpRel() //Emite o relatório
		lRet := .F.
	//Endif
Else
	
	MsgInfo("Importação Finalizada com Sucesso...")
	
Endif

Return(lRet)

/*
{Protheus.doc} F57ImpRel
Geração de log de inconsistências.
@Author     Ramon Teodoro e Silva
@Since      12/02/2016      
@Version    P12.7
@Return
*/

User Function F57ImpRel()

Local Cabec1   := PadC("LINHA", 5) + "|" + PadC("IDENTIFICAÇÃO",50) + "|" + PadC("MOTIVO", 75)
Local cBorda   := Replicate("-", 130)
//Local cDirArq  := ""
Local cDirArq  := "C:\Temp\"  
Local cArquivo := "F57_" + StrTran(Alltrim(Time()),":", ".")+"_LOG.txt" 
Local nHdl     := 0   
Local nLin     := 80   
Local nX       := 0  
Local nY       := 0
Local lRet     := .t.

Private nLastKey   := 0

//cDirArq := cGetFile("","Diretorio para gravacao",1,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY )  

If nLastKey == 27
	Return
Endif

If !ExistDir(cDirArq)
	MakeDir(cDirArq)
EndIf   

nHdl := FCreate(cDirArq+cArquivo, FC_NORMAL)

FT_FUse(cArquivo)   

FT_FGoTop()    

For nY := 1 To Len(aERRO)
		
	If nLin > 65
		
		FWRITE(nHdl, CRLF + cBorda  )   
		FWRITE(nHdl, CRLF + "LOG DE INCONSISTENCIAS IMPORTAÇÃO DO ARQUIVO CSV"  )
		FWRITE(nHdl, CRLF + cBorda  )   
		
		For nX := 1 to 3
	   		FWRITE(nHdl, CRLF + "  "  )  
		Next nX
	                 
		FWRITE(nHdl, CRLF + cBorda  )
		FWRITE(nHdl, CRLF + Cabec1  )
		FWRITE(nHdl, CRLF + cBorda  )
		
		nLin := 9
	Endif
	
	FWRITE(nHdl, CRLF + Padc(aERRO[nY][1], 5) + "|" + Padc(aERRO[nY][2],50) +"|"+ PadC(aERRO[nY][3],75))
	
   	++nLin
	
Next nY
If nLastKey <> 27
	MsgInfo("O arquivo " +cArquivo+ " foi criado em " + cDirArq, "Aviso" )
Endif
       
FWRITE(nHdl, CRLF + "  "  )

FT_FUse()
FClose(nHdl)  

Return lRet


/*
{Protheus.doc} F57IdNivel
Identifica o nível da conta orçamentária.
@Author     Ramon Teodoro e Silva
@Since      12/02/2016      
@Version    P12.7
@Param	    cGetCod - Codigo do Orçamento
@Param	    cGetRev - Codigo da versão do Orçamento
@Param	    cGetCO  - Codigo da conta contábil/orçamentária
@Return
*/
User Function F57IdNivel(cGetCod, cGetRev,cGetCO)

Local cRet    := StrZero(1,TamSX3("AK3_NIVEL")[1])
Local cCo     := cGetCO
Local cPai    := ""  
Local aArea   := GetArea()  
Local aAK5A   := AK5->(GetArea())
Local nContN  := 0
Local cNivCt  := "" //Soma1(cRet)
Local cRetOld := ""
Local nPosCta := 0

dbSelectArea("AK5")
AK5->(DbSetOrder(1))

cRet    := Soma1(cRet)
cRetOld := cRet

If AK5->(DbSeek(xFilial("AK5")+cCo))
	cPai := AK5->AK5_COSUP
	
	Do While !Empty( cPai )
		cRet   := soma1(cRet)
		AK5->(DbSeek(xFilial("AK5")+cPai))
		cCo  := cPai
		cPai := AK5->AK5_COSUP
		
		nPosCta := aScan(aGrvAK3, {|x| alltrim(x[3]) == Alltrim(cCo) }) //== 0
		
		If nPosCta == 0
			
			If nContN == 0
				cNivCt := soma1(cRet)	
				cNivCt := StrZero( (Val(cRetOld) + Val(cNivCt)), TamSX3("AK3_NIVEL")[1])  
				nContN += 1
			Else
				cNivCt := StrZero( (Val(cNivCt) - nContN), TamSX3("AK3_NIVEL")[1])
			EndIf
			
			Aadd(aGrvAK3,{cGetCod, cGetRev, cCo, IIF( AllTrim(cPai) == "", cGetCod, cPai ), AK5->AK5_TIPO, AK5->AK5_DESCRI,cNivCt})  		
		
		Else
			//cRet := Soma1(aGrvAK3[nPosCta][7])
			cRet := StrZero( ((Val(cRet) + Val(aGrvAk3[nPosCta][7])) - Val(cRetOld)), TamSX3("AK3_NIVEL")[1]) 
			cPai := ""
		EndIf
		
		AK5->(DbSkip())
	End
	
Endif

RestArea(aArea)
RestArea(aAK5A)

Return(cRet)


/*
{Protheus.doc} F57IdCtaS
Identifica contas sintéticas para inclusão automática na estrutura da planilha.
@Author     Ramon Teodoro e Silva
@Since      12/02/2016      
@Version    P12.7
@Param	    cGetCod - Codigo do Orçamento
@Param	    cGetRev - Codigo da versão do Orçamento
@Param	    cGetCO  - Codigo da conta contábil/orçamentária
@Return
*/
User Function F57IdCtaS(cGetCod, cGetRev, cGetCO)

Local aAreaAK3 := AK3->(GetArea())
Local aAreaAK5 := AK5->(GetArea())
Local nCta     := 0
Local cCtaSint := ""
Local cNvlSint := ""
Local cTA:= " "
Local cDA

If AK5->(DbSeek(xFilial("AK5") + PadR(cGetCO, TamSX3("AK5_CODIGO")[1])))

	cCtaSint := AK5->AK5_COSUP

	While !AK5->(Eof()) .And. !Empty(cCtaSint)
		
		If AK5->(DbSeek(xFilial("AK5") + PadR(cCtaSint, TamSX3("AK5_CODIGO")[1])))
		
			ccDA     :=	AK5->AK5_DESCRI
			cCoSup   := AK5->AK5_COSUP
			cTA      := AK5->AK5_TIPO
			cNvlSint := U_F57IdNivel(cCtaSint)
		
			If aScan(aGrvAK3, {|x| alltrim(x[3]) == Alltrim(cCoSup) }) == 0
				Aadd(aGrvAK3,{cGetCod, cGetRev, cCtaSint, IIF( AllTrim(cCoSup) == "", cGetCod, cCoSup ), cTA,cDA, cNvlSint})  		
			EndIf
			
		EndIf
		
		cCtaSint := AK5->AK5_COSUP	
		AK5->(DbSkip())	
			
	End

EndIf

/*
If AK5->AK5_TIPO == "2"
	cDA := " "
	cTA:= "2"
	For nCta := 1 To Len(cGetCO)-1
		
		cCtaSint := Left(cGetCO,nCta)
		
		DbSelectArea("AK5")
		AK5->(DbSetOrder(1))
	
		If AK5->(DbSeek(xFilial("AK5") + PadR(cCtaSint, TamSX3("AK5_CODIGO")[1])))
		   
		    cDA      :=	AK5->AK5_DESCRI
			cCoSup   := AK5->AK5_COSUP
			cTA      := AK5->AK5_TIPO
			cNvlSint := U_F57IdNivel(cCtaSint)
		   
			If !Empty(cNvlSint)
		        
	    		DbSelectArea("AK3")
		  		AK3->(DbSetOrder(1))
			                                                 
		  		If !AK3->(DbSeek(xFilial("AK3") + PadR(cGetCod, TamSX3("AK3_ORCAME")[1]) + PadR(cGetRev, TamSX3("AK3_VERSAO")[1]) + PadR(cCtaSint, TamSX3("AK3_CO")[1]) ))
		       
					If aScan(aGrvAK3, {|x| alltrim(x[3]) == Alltrim(cCtaSint) }) == 0
				 		Aadd(aGrvAK3,{cGetCod, cGetRev, cCtaSint, IIF( AllTrim(cCoSup) == "", cGetCod, cCoSup ), cTA,cDA, cNvlSint})  		
			   		EndIf
																 		
				EndIf  
						
			EndIf
	
    	EndIf
		
	Next nCta
EndIf
*/

RestArea(aAreaAK5)
RestArea(aAreaAK3)

Return                  

/*
{Protheus.doc} F57ResTela
Mantem o layout independente da resolução da tela.
@Author     Ramon Teodoro e Silva
@Since      12/02/2016      
@Version    P12.7
@Param      nTam
@Return
*/
User Function F57ResTela(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480  
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf      

If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return NoRound(nTam)

/*
{Protheus.doc} MudaLin
Guarda o Orçamento,Ano e versão da planilha orçamentaria selecionada no ListBox
@Author     Ramon Teodoro e Silva
@Since      12/02/2016    
@Version    P12.7
@Param      
@Return
*/
User Function MudaLin(nPos)

cGetCod := Alltrim(a_AK1[nPos][1])
cGetAno := Substr(Alltrim(a_AK1[nPos][5]),1,4)
cGetRev := Alltrim(a_AK1[nPos][2])

Return

