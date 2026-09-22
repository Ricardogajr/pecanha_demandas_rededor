#Include 'Protheus.ch'
#INCLUDE "TopConn.Ch"
#INCLUDE "FONT.CH"      
#INCLUDE "FILEIO.CH"   
#Include "TCBrowse.ch"

/*
{Protheus.doc} TEWBTYI2
Importação de Planilha de Lnaçamentos Contábeis do Protheus 12.
@Author     Ramon Teodoro e Silva
@Since      26/10/2016     
@Version    P12.7
@Return
*/       

User Function TEWBTYI2
             
Local lRet 	:= .T.
Local nOpca	:= 0   

Private oDlg	
Private cDirOri := Space(100) 

DEFINE MSDIALOG oDlg TITLE "Importação de Dados" FROM 0, 0 TO 128, 345 PIXEL
@ 010,009 Say   "Diretorio"       Size 045,008 PIXEL OF oDlg   
@ 018,009 MSGET cDirOri           Size 120,010 WHEN .F. PIXEL OF oDlg  
@ 018,140 BUTTON "..."            Size 013,013 PIXEL OF oDlg   Action(cDirOri := cGetFile("*.csv|*.csv","Importacao de Dados",0, ,.T.,GETF_LOCALHARD))
@ 037,009 Button "OK"       Size 47, 15 PIXEL OF oDlg Action(nOpca := 1,oDlg:End())
@ 037,060 Button "Cancelar" Size 47, 15 PIXEL OF oDlg Action(nOpca := 0, oDlg:end())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	If Empty(cDirOri)
		MsgInfo("Nenhum arquivo CSV foi selecionado! Importação não realizada.")
		lRet := .F.
	Else
		Processa( { || U_ImpCT212() }, "Processando..." )
	EndIf
Else
	lRet := .F.
Endif
         
Return lRet

/*
{Protheus.doc} ImpCT212
Importação de Planilha de Lnaçamentos Contábeis do Protheus 12.
@Author     Ramon Teodoro e Silva
@Since      26/10/2016     
@Version    P12.7
@Return
*/       

User Function ImpCT212

Local aArea      := GetArea() 
Local aAreaSM0   := SM0->(GetArea())
Local aAreaCT2   := CT2->(GetArea())    
Local cBuffer	 := ""
Local aInfo		 := {}
Local nXPos		 := ""
Local aTmpDados	 := {}
Local lGrv   	 := .F.
Local cQuery	 := ""
Local lRet		 := .T.
Local aHeader    := {}
Local cEmpFil    := ""  
Local aEmpFil    := {}
Local cNomeCampo := ""
Local nTotRec    := 0
Local nContL     := 0   
Local nG         := 0   
Local nP         := 0
Local aEstru     := {}  
Local nPosCCC    := 0
Local nPosCCD    := 0

Private cArquiv  := cDirOri
Private aDados 	 := {}

FT_FUSE(cArquiv)

FT_FGOTOP()

cBuffer  := FT_FREADLN()
nTotRec  := FT_FLASTREC()
ProcRegua(nTotRec)

Begin Transaction

FT_FGOTOP()        

While !FT_FEOF() 	
	
	nContL  += 1
	IncProc( "Importando Lançamentos Contábeis: " + AllTrim( Str( nContL ) ) + " de " + AllTrim( Str( nTotRec ) ) )
		
	cBuffer := FT_FREADLN()
	cBuffer := NoAcento(cBuffer)
	aTmpDados := {}
	
	If Empty(cBuffer)
		Exit
	Endif
	
	nXPos := AT(";",cBuffer)
  	If !Empty(SubStr(cBuffer , 1, nXPos-1 )) 
		
		If Alltrim(SubStr( SubStr(cBuffer , 1, nXPos-1), 1, 3)) <> "CT2"
			
			While nXPos <> 0
				aInfo := Alltrim(SubStr(cBuffer , 1, nXPos-1 ))                          
				aAdd( aTmpDados , aInfo )
				cBuffer := SubStr(cBuffer , nXPos+1, Len(cBuffer)-nXPos)
				nXPos := AT(";",cBuffer)
			End
			
			If Len(cBuffer) > 0 .Or. (Len(aHeader) - Len(aTmpDados) == 1)
				aInfo := Alltrim(SubStr(cBuffer , 1, Len(cBuffer) ))
				aAdd( aTmpDados , aInfo )
			EndIf
			
			aAdd( aDados, aTmpDados )
							
			lGrv := .T. 
		Else
			
			While nXPos <> 0
				Aadd(aHeader, Alltrim(SubStr(cBuffer , 1, nXPos-1 )))
				cBuffer := SubStr(cBuffer , nXPos+1, Len(cBuffer)-nXPos)
				nXPos   := AT(";",cBuffer)
			End
			
			If Len(cBuffer) > 0
				Aadd(aHeader, Alltrim(SubStr(cBuffer , 1, Len(cBuffer))))
			EndIf
		   
		  	lGrv := .F. 
		EndIf
	Else
	  	lGrv := .F. 
	EndIf
	
   	FT_FSKIP()
End          

End Transaction

FT_FUSE()

If lGrv

	cEmpFil := ""
	
	nPCC := aScan(aHeader,{|x| AllTrim(x)== "CT2_CCC"})        
	nPCD := aScan(aHeader,{|x| AllTrim(x)== "CT2_CCD"})        	
	
	//Início - Thais Paiva - Compatibilização P27
	//cArquivo := CriaTrab(,.F.)  
	aEstru := CT2->(DbStruct())
	//Aadd(aEstru,{ "CT2_EMP", "C", 2, 0 })
	//DbCreate(cArquivo,aEstru) 
	//DbUseArea( .T.,,cArquivo,"TRB",.F.,.F.)
	oTempTable := FWTemporaryTable():New( "TRB" )
	oTemptable:SetFields( aEstru )
	oTempTable:AddIndex( '01' , { "CT2_EMP","CT2_FILIAL" } )
	oTempTable:Create()
	//Fim - Thais Paiva - Compatibilização P27
   	IndRegua("TRB",cArquivo,"CT2_EMP+CT2_FILIAL")  
	TRB->(DbSetOrder(1))      
	
	For nG := 1 to Len(aDados)
	    
	    IncProc( "Montando estrutura para gravação..." )
	    
		RecLock("TRB",.T.) 
	
		For nI := 1 To Len(aEstru)  
			   
			nP := aScan(aHeader,{|x| AllTrim(x)== Alltrim(aEstru[nI][1])}) 
			
			If nP > 0
			
				If aEstru[nI][2] == "C" 
					If Alltrim(aEstru[nI][1]) == "CT2_FILIAL"
						&("TRB->" + aEstru[nI][1]) := SubStr(aDados[nG][nP], 3, 2)  
					ElseIf Alltrim(aEstru[nI][1]) == "CT2_CCD" .And. !Empty(aDados[nG][nPCD])
				   		&("TRB->" + aEstru[nI][1]) := SubStr(aDados[nG][nPCD], 1, 2) 
					ElseIf Alltrim(aEstru[nI][1]) == "CT2_CCC" .And. !Empty(aDados[nG][nPCC])
				   		&("TRB->" + aEstru[nI][1]) := SubStr(aDados[nG][nPCC], 1, 2)
		   			ElseIf Alltrim(aEstru[nI][1]) == "CT2_ITEMD" .And. !Empty(aDados[nG][nPCD])
				   		&("TRB->" + aEstru[nI][1]) := SubStr(aDados[nG][nPCD], 3, 2) 
					ElseIf Alltrim(aEstru[nI][1]) == "CT2_ITEMC" .And. !Empty(aDados[nG][nPCC])
				   		&("TRB->" + aEstru[nI][1]) := SubStr(aDados[nG][nPCC], 3, 2)
		   			ElseIf Alltrim(aEstru[nI][1]) == "CT2_CLVLDB" .And. !Empty(aDados[nG][nPCD])
				   		&("TRB->" + aEstru[nI][1]) := SubStr(aDados[nG][nPCD], 5, 2) 
					ElseIf Alltrim(aEstru[nI][1]) == "CT2_CLVLCR" .And. !Empty(aDados[nG][nPCC])
				   		&("TRB->" + aEstru[nI][1]) := SubStr(aDados[nG][nPCC], 5, 2)
					Else 
						&("TRB->" + aEstru[nI][1]) := aDados[nG][nP]
					EndIf 
					
				ElseIf aEstru[nI][2] == "D"
			   		&("TRB->" + aEstru[nI][1]) := StoD(aDados[nG][nP])
				ElseIf aEstru[nI][2] == "N"
			  		&("TRB->" + aEstru[nI][1]) := Val( StrTran(StrTran(aDados[nG][nP], ".", "" ), ",", "."))
				EndIf
			  			
			Else
			
				If  Alltrim(aEstru[nI][1]) == "CT2_EMP"
					&("TRB->" + aEstru[nI][1]) := SubStr(aDados[nG][1], 1, 2)  
				EndIf
			
			EndIf
		
		Next nI
	
		TRB->(MsUnLock())
		
	Next nG	  
	
	DbSelectArea("TRB")
	TRB->(DbSetOrder(1))  
	TRB->(DbGoTop())
	
	While !TRB->(Eof())  
		
		If cEmpFil <> TRB->CT2_EMP   
		   
			cEmpFil  := TRB->CT2_EMP  
			cNomeEmp := Alltrim(Posicione("SM0", 1, cEmpFil+TRB->CT2_FILIAL, "M0_NOME")) + " - " + Alltrim(Posicione("SM0", 1, cEmpFil+TRB->CT2_FILIAL, "M0_FILIAL"))
			 
			Aadd(aEmpFil, {cEmpFil, cNomeEmp, .f.})
			
			EmpOpenFile("CT2","CT2",1,.T.,cEmpFil,"E") 
			    
			DbSelectArea("CT2")
			DbSetOrder(1)  
		
		EndIf
		
		IncProc( "Gravando dados: " + Alltrim(cEmpFil) + "-" + Alltrim(cNomeEmp) )
		
	 	While !CT2->(Eof())
	 	
	 		If CT2->(DbSeek(TRB->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD)))
	 	 		TRB->CT2_DOC := StrZero( Val(CT2->CT2_DOC)+1, TamSX3("CT2_DOC")[1] ) //PADR( Alltrim(Str(Val(CT2->CT2_DOC)+1)),TamSX3("CT2_DOC")[1] )
	 	    Else
	 	    	Exit
	 	    EndIf
	 	
	 		CT2->(DbSkip())
	 	End
	 	
	 	RecLock("CT2",.T.) 
	 	
	  /*	If CT2->(DbSeek(TRB->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD)))
		
			TRB->CT2_DOC := PADR( Alltrim(Str(Val(CT2->CT2_DOC))),TamSX3("CT2_DOC")[1] ) //Str( Val(CT2->CT2_DOC)+1, TamSX3("CT2_DOC")[1])
			
			If !CT2->(DbSeek(TRB->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD)))
		   		RecLock("CT2",.T.) 
		 	EndIf
		 	
	 	Else
	 	   	RecLock("CT2",.T.) 
		EndIf */                
		
		For nI := 1 To CT2->(FCount())  
		  	    
			cNomeCampo := CT2->(FieldName(nI))
			   		
			CT2->(FieldPut(nI, &("TRB->" + cNomeCampo) ))
   			 
		Next nI
		
		CT2->(MsUnLock())
		
		TRB->(DbSkip())
	End 
	
	EmpOpenFile("CT2","CT2",1,.F.,cEmpFil,"E")   
			
 	U_EmpResum(aEmpFil)
	
	TRB->(DbCloseArea())  
	oTempTable:Delete() //Thais Paiva - 04/12/2020
   
Else

	MsgInfo("Não foi possível realizar a importação, verifique os dados do arquivo")  
		
EndIf

RestArea(aArea)
RestArea(aAreaCT2)   
RestArea(aAreaSM0)

Return lRet
              

/*
{Protheus.doc} EmpResum
Resumo das empresas e filiais onde os dados foram gravados
@Author     Ramon Teodoro e Silva
@Since      26/10/2016     
@Version    P12.7
@Return
*/    

User Function EmpResum(aEmpFil)

Local lRet     := .T.  
Local aHeadEmp := {}
Local oEmp    
Local nEmp := Len(aEmpFil)

Local oSize1	:= Nil
Local oSize		:= Nil
Local oDlg		:= Nil
Local oDlEmp	:= Nil

Aadd(aHeadEmp,{ "Empresa", "M0_EMP",  "@!", 2,  0, "", "", "C", ,"","","", })
Aadd(aHeadEmp,{ "Nome"   , "M0_NOME", "@!", 15, 0, "", "", "C", ,"","","", })

oSize1 := FWDefSize():New(.T.)
oSize1:lLateral := .F.
oSize1:lProp	:= .T. 
oSize1:Process()

DEFINE MSDIALOG oDlg TITLE "Empresas Atualizadas"  From 0, 0 to 250, 450 OF oMainWnd PIXEL //FROM 500,700 TO 700, 812 OF oMainWnd PIXEL
//DEFINE MSDIALOG oDlg TITLE "Empresas e Filiais Atualizadas"  From 0, 0 to oSize1:aWindSize[3]/2,oSize1:aWindSize[4]/2 OF oMainWnd PIXEL //FROM 500,700 TO 700, 812 OF oMainWnd PIXEL
		
@ 25,008 SAY "Total de Empresas Atualizadas"      SIZE 100,07  OF oDlg PIXEL	 
@ 25,090 MSGET oEmp  VAR nEmp         SIZE 020,05  OF oDlg PIXEL HASBUTTON When .F. Picture "@E 999"

oDlEmp := MsNewGetDados():New(40,008,115,220,,,,,,,9999,,,,oDlg,aHeadEmp,aEmpFil)   

//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpc:=1,oDlg:End()}, {|| nOpc:=0,oDlg:End() },,)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},,,,,,,.F.,.F.)	


Return lRet




