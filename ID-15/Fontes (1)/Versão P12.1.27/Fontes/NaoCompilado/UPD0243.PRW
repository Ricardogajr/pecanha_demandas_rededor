#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "fileio.ch"

///////////////////////////////////////////////////
// CARGA NA TABELA SA2 PROTHEUS 12 VIA PLANILHA. //
///////////////////////////////////////////////////
***********************
User Function UPD0243()
***********************

	Local cLinha 	 := ""
	Local lRet		 := .T.
	Local lPrim 	 := .F.
	Local cText 	 := OemToAnsi("Selecione o Arquivo de Importação:")
	Private aDados 	 := {}
	Private aCampos  := {}
	Private aAntes   := {}
    Private cArquivo := Space(150)
    Private lOk      :=.F.
	Private nLidos  := 0
	Private nProce  := 0
	Private Cabec1  := " "

    Define MsDialog oDlg Title "UPD0243 - Selecionar Arquivo para Carga" From 08,15 To 19,120 Of GetWndDefault()
      
    @ 18,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
    @ 18,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
    @ 18,275 Button "..." 			Size 010,10 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel
    @ 18,310 Button "OK"            Size 040,20 Action Eval({|| If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,)}) Of oDlg Pixel
    @ 18,355 Button "CANCEL"        Size 040,20 Action Eval({|| lOk:=.F.,oDlg:End() }) Of oDlg Pixel
    Activate MsDialog oDlg //Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

    If lOk
       MsAguarde({|lEnd| LerArq(aDados)},"Aguarde...","Lendo Planilha ",.T.)
       MsAguarde({|lEnd| ImportDad(aDados)},"Aguarde...","Processando Planilha ",.T.)
       MsgStop( "Fim da Rotina", "UPD0243" )
    Endif
	FT_FUSE()

Return

*********************************
Static Function ImportDad(aDados)
*********************************

	Local i 		  := 0
	Local j 		  := 0
	Local lRet		  := .T.
	Local aRetorno	  :={}
	Local lOk         := .T.
	Local aAreaSA2    := SA2->(GetArea())

    CNOME4 := "SA2ANT"+"_"+ TIME() + ".CSV"
    CNOME4 := StrTran( CNOME4, ":", "_" )
    cpath  := "\SPOOL\"
    CARQ4  := CPATH+CNOME4
    aFiles1 := Directory(cpath+"SA2ANT"+"*.CSV", "D") 
    ni:=0
    For ni := 1 to len(aFiles1)
        FERASE(cpath+aFiles1[ni][1])
    Next 
    nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
	CMSG := "A2_CGC;A2_NOME;A2_END;A2_NR_END;A2_ENDCOMP;A2_BAIRRO;A2_MUN;A2_EST;A2_CEP;A2_COD_MUN;A2_IBGE;A2_PAIS;A2_CODPAIS;A2_MSBLQL"+CRLF
    FWrite(nHandle4,cMsg,Len(cMsg))    

    CNOME5 := "SA2DEP"+"_"+ TIME() + ".CSV"
    CNOME5 := StrTran( CNOME5, ":", "_" )
    cpath  := "\SPOOL\"
    CARQ5  := CPATH+CNOME5
    aFiles2 := Directory(cpath+"SRADEP"+"*.CSV", "D") 
    ni:=0
    For ni := 1 to len(aFiles2)
        FERASE(cpath+aFiles2[ni][1])
    Next 
    nHandle5 := Fcreate(cArq5,0)		// cria o arquivo

	CMSG := "A2_CGC;A2_NOME;A2_END;A2_NR_END;A2_ENDCOMP;A2_BAIRRO;A2_MUN;A2_EST;A2_CEP;A2_COD_MUN;A2_IBGE;A2_PAIS;A2_CODPAIS;A2_MSBLQL"+CRLF
    FWrite(nHandle5,cMsg,Len(cMsg))    

	ProcRegua(LEN(ADADOS))

	For ix = 1 to len(acampos)
       if Alltrim(acampos[ix]) == "A2_CGC"
	      nCGC := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_NOME"
	      nNOME := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_END"	
	      nEND := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_NR_END"	
	      nNR_END := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_ENDCOMP" 	
	      nENDCOMP := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_BAIRRO"	
	      nBAIRRO := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_MUN"	
	      nMUN := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_EST"	
	      nEST := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_CEP"	
	      nCEP := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_COD_MUN"
	      nCOD_MUN := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_IBGE"
	      nIBGE := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_PAIS"
	      nPAIS := ix
	   endif
       if Alltrim(acampos[ix]) == "A2_CODPAIS"
	      nCODPAIS := ix
	   endif
    next
	
	For i:=1 to Len(aDados)
        nproce++
	    cmsg := '*** Processando Linha = '+strzero(nproce,9,0)+" de "+strzero(nLidos,9,0)
        MsProcTxt(cMsg)	
	    if len(aDados[i,nCGC]) > 0
	       cQry := "SELECT R_E_C_N_O_ AS NUMREG"
		   cQry += CRLF+"  FROM "+RetSqlName("SA2")
		   cQry += CRLF+" WHERE A2_CGC = '"+adados[i,nCGC]+"'"
           cQry += CRLF+"   AND D_E_L_E_T_  <> '*'"   
           cQry += CRLF+"   AND A2_MSBLQL <> '1'"   
		   cQry := changequery(cQry) 
		   TCQUERY cQry ALIAS "cTMP" NEW
           dbSelectArea("cTMP")    
		   if ctmp->numreg > 0
              SA2->( dbGoTo( cTMP->(NUMREG) ) )					   

	          CMSG := SA2->A2_CGC+";"+SA2->A2_NOME+";"+SA2->A2_END+";"+;
					  SA2->A2_NR_END+";"+SA2->A2_ENDCOMP+";"+SA2->A2_BAIRRO+";"+;
					  SA2->A2_MUN+";"+SA2->A2_EST+";"+SA2->A2_CEP+";"+SA2->A2_COD_MUN+";"+;
					  SA2->A2_IBGE+";"+SA2->A2_PAIS+";"+SA2->A2_CODPAIS+";"+SA2->A2_MSBLQL+CRLF
		  	  
              FWrite(nHandle4,cMsg,Len(cMsg))    
			  
			  Reclock( "SA2" , .F. )
               
			  If !Empty(aDados[i,nNOME])
                  Replace A2_NOME With aDados[i,nNOME]
		      endif
			  If !Empty(aDados[i,nEND]) 
                  Replace A2_END With aDados[i,nEND]
		      endif
			  If !Empty(aDados[i,nNR_END]) 
                  Replace A2_NR_END With aDados[i,nNR_END]
		      endif
			  If !Empty(aDados[i,nENDCOMP])
                  Replace A2_ENDCOMP With aDados[i,nENDCOMP]
		      endif
			  If !Empty(aDados[i,nBAIRRO]) 
                  Replace A2_BAIRRO With aDados[i,nBAIRRO]
		      endif
			  If !Empty(aDados[i,nMUN]) 
                  Replace A2_MUN With aDados[i,nMUN]
		      endif
			  If !Empty(aDados[i,nEST]) 
                  Replace A2_EST With aDados[i,nEST]
		      endif
			  If !Empty(aDados[i,nCEP]) 
                  Replace A2_CEP With aDados[i,nCEP]
		      endif
			  If !Empty(aDados[i,nCOD_MUN]) 
                  Replace A2_COD_MUN With aDados[i,nCOD_MUN]
		      endif
			  If !Empty(aDados[i,nIBGE]) 
                  Replace A2_IBGE With aDados[i,nIBGE]
		      endif
			  If !Empty(aDados[i,nPAIS]) 
                  Replace A2_PAIS With aDados[i,nPAIS]
		      endif
			  If !Empty(aDados[i,nCODPAIS]) 
                  Replace A2_CODPAIS With aDados[i,nCODPAIS]
		      endif

	          CMSG := SA2->A2_CGC+";"+SA2->A2_NOME+";"+SA2->A2_END+";"+;
					  SA2->A2_NR_END+";"+SA2->A2_ENDCOMP+";"+SA2->A2_BAIRRO+";"+;
					  SA2->A2_MUN+";"+SA2->A2_EST+";"+SA2->A2_CEP+";"+SA2->A2_COD_MUN+";"+;
					  SA2->A2_IBGE+";"+SA2->A2_PAIS+";"+SA2->A2_CODPAIS+";"+SA2->A2_MSBLQL+CRLF

              FWrite(nHandle5,cMsg,Len(cMsg))    
		      SA2->(Msunlock())      
			  AADD(aRetorno,{adados[i,nCGC],adados[i,nNOME]," Registro Foi Atualizado"})
		   endif                       
		   ctmp->(dbclosearea())
		EndIf
		
	Next i
    fclose (nHandle4)    
	fclose (nHandle5)    

	If !Empty(aRetorno)
		Aviso('Processamento Realizado!',"Verifique o log da importação", {'OK'}, 1)
        Geralog(aRetorno,cArquivo)
	EndIf
	
	RestArea(aAreaSA2)

Return

******************************
Static Function LerArq(aDados)
******************************

	Local cLinha 	:= ""
	Local lPrim 	:= .F.
    Local nLinTit   := 1  // Total de linhas do Cabeçalho
	
	FT_FUSE(cArquivo)
	ProcRegua(FT_FLASTREC()) 
	nQtdLinhas := FT_FLASTREC()
	FT_FGOTOP()

    //////////////////////
	// pular cabecalhos //
	//////////////////////

    While nLinTit > 0 .AND. !Ft_FEof()

      cLinha := FT_FREADLN()
      If LEN(cLinha) == 1023
         FT_FSKIP()
         cConLinha := FT_FREADLN()
         While LEN(cConLinha) == 1023
           cLinha += cConLinha
           FT_FSKIP()
           cConLinha := FT_FREADLN()
         EndDo
         cLinha += cConLinha
      EndIf
      
      If nLinTit == 1
         aCampos := SEPARA(UPPER(cLinha),";",.T.)
      EndIf
      cLinha := ""
      Ft_FSkip()
      nLinTit--
    EndDo

    nI := 0
	While !FT_FEOF()

        cLinha := FT_FREADLN()
  	    If LEN(cLinha) == 1023
	       FT_FSKIP()
		   cConLinha := FT_FREADLN()
		   While LEN(cConLinha) == 1023
		       cLinha += cConLinha
			   FT_FSKIP()
			   cConLinha := FT_FREADLN()
		   EndDo
		   cLinha += cConLinha
	    EndIf

		If !(EMPTY(STRTRAN(cLinha, ";", "")))
		   AAdd(aDados,Separa(cLinha,";",.T.))
		Else
			EXIT
		EndIf
        nI++            
        nLidos++		
	    cMsg := '*** Lendo Linha = '+strzero(nLidos,9,0)+" de "+strzero(nQtdLinhas,9,0)
        MsProcTxt(cMsg)	
		FT_FSKIP()
	EndDo
Return 

*********************************
Static Function Geralog(aRetorno)
*********************************
Local oExcel                                            
Local cTempPath:=GetTempPath()
Local cDirUsr  := __RELDIR
Local cDirSrv  := '\SPOOL\'
Local cArq     := 'UPD0243.CSV'
CARQ4  := cDirSrv+cArq
nHandle6 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo LOGEMPRE")
endif                        
cMsg := "UPD0243 LOG DE ATIVIDADE"+CRLF
FWrite(nHandle6,cMsg,Len(cMsg))    
cMsg := "CGC;Razao Social;Status"+CRLF
FWrite(nHandle6,cMsg,Len(cMsg))    

For nI := 1 to Len(aRetorno)       
    cMsg = ""
    cMsg = aRetorno[nI][1]+";"+aRetorno[nI][2]+";"+aRetorno[nI][3]+";"+CRLF
    FWrite(nHandle6,cMsg,Len(cMsg))    
Next
fclose (nHandle6)    

//CpyS2T(cDirSrv+cArq, cTempPath)
//
//oExcel:=MSExcel():New()
//oExcel:WorkBooks:Open(cTempPath+carq)
//oExcel:SetVisible(.T.)
//oExcel:Destroy()

Return
