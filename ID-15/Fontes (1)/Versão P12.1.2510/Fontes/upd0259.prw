#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
///////////////////////////////////////////////////
// CARGA CAMPO RA_XMATSOC VIA PLANILHA.          //
///////////////////////////////////////////////////
***********************
User Function UPD0259()
***********************

	Local cLinha 	 := ""
	Local lRet		 := .T.
	Local lPrim 	 := .F.
	Local cText 	 := OemToAnsi("Selecione o Arquivo de Importação:")
	Private aDados 	 := {}
    Private cArquivo := Space(150)
    Private lOk      :=.F.
	Private nLidos  := 0
	Private nProce  := 0
	Private aEmpresas := {}
	
    DBSELECTAREA( "SM0" )
    DBGOTOP() 
    WHILE !EOF()
      Aadd(aEmpresas,{M0_CODIGO,M0_CODFIL}) 
      DBSKIP()                                                       
    END

    Define MsDialog oDlg Title "UPD0259 - Selecionar Arquivo para Carga" From 08,15 To 19,120 Of GetWndDefault()
      
    @ 18,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
    @ 18,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
    @ 18,275 Button "..." 			Size 010,10 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel
    @ 18,310 Button "OK"            Size 040,20 Action Eval({|| If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,)}) Of oDlg Pixel
    @ 18,355 Button "CANCEL"        Size 040,20 Action Eval({|| lOk:=.F.,oDlg:End() }) Of oDlg Pixel
    Activate MsDialog oDlg //Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

    If lOk
       MsAguarde({|lEnd| LerArq(aDados)},"Aguarde...","Lendo Planilha",.T.)
       MsAguarde({|lEnd| ImportDad(aDados)},"Aguarde...","Processando Planilha",.T.) 
       MsgStop( "Fim da Rotina", "UPD0259" )
    Endif
	FT_FUSE()

Return

*********************************
Static Function ImportDad(aDados)
*********************************

	Local i 		  := 0
	Local j 		  := 0
	Local lRet		  := .T.
	Local lOk         := .T.

	Local cDirUsr  := __RELDIR
	Local cDirSrv  := '\SPOOL\'
	Local cArq     := 'UPD0259.CSV'

	CARQ4  := cDirSrv+cArq

	nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
	If Ferror() != 0
		Conout("houve erro na criação do arquivo UPD0259.CSV")
	endif                        
	cMsg := "UPD0259 LOG DE PROCESSO"+CRLF
	FWrite(nHandle4,cMsg,Len(cMsg))    
	cMsg := "FILIAL;MATRICULA;NOME;CPF;STATUS"+CRLF

	FWrite(nHandle4,cMsg,Len(cMsg))    

	ProcRegua(LEN(ADADOS))
	////////////////////////////
	// COLUNAS DO ARQUIVO CSV //
	//////////////////////////////////////////////////////////
    // COLUNA E = MATRICULA              RB_MAT             //5
	// COLUNA F = NOME DEPENDENTE        RB_NOME    	    //6
	// COLUNA G = CPF DEPENDENTE         RA_CIC             //7
	// COLUNA H = DATA NASCIMENTO        RA_DTNASC          //8
	//////////////////////////////////////////////////////////

	For i:=1 to Len(aDados)
        nproce++
	    FWMonitorMsg('*** Processando Linha = '+strzero(nproce,9,0)+" de "+strzero(nLidos,9,0))
  	    cMsg := '*** Processando Linha = '+strzero(nproce,9,0)+" de "+strzero(nLidos,9,0)
        MsProcTxt(cMsg)	
        ProcessMessage()
	    if len(aDados[i,1]) > 0
	       // filial //
		       c_filial := aDados[i,1] 
 	  	   // Matricula //
		       c_mat    := aDados[i,3] 
		   // Matricula Esocial //
		       c_matsoc := aDados[i,4] 
           // CPF //
		       c_cpf := aDados[i,7] 
           // nome funcionario
               c_nome := aDados[i,6]   
    
               c_grupo := '01'
               For i2 := 1 to Len(aEmpresas)
                   if alltrim(aEmpresas[i2,2])==alltrim(c_filial)
                      c_grupo := aEmpresas[i2,1]
                   endif
               Next i2
			   cQry := "SELECT R_E_C_N_O_ AS REGISTRO"
			   cQry += CRLF+"  FROM "+"SRA"+c_grupo+'0'
			   cQry += CRLF+" WHERE RA_MAT    = '"+c_MAT+"'"
			   cQry += CRLF+"   AND RA_FILIAL = '"+c_FILIAL+"'"
               cQry += CRLF+"   AND D_E_L_E_T_  <> '*'"   
			   cQry := changequery(cQry) 
			   TCQUERY cQry ALIAS "cTMP" NEW
               If cTMP->(REGISTRO)> 0  
                  cQry2 := "UPDATE "+"SRA"+c_grupo+'0'+" "+CRLF
                  cQry2 += " SET RA_XMATSOC = '"+C_MATSOC+"' "+CRLF
                  cQry2 += " WHERE RA_MAT    = '"+c_MAT+"' "+CRLF
                  cQry2 += "   AND RA_FILIAL = '"+c_FILIAL+"'"
                  cQry2 += "   AND D_E_L_E_T_  <> '*'"   
                  If (TCSQLExec(cQry2) < 0)
                     cMsg = ""
                     cMsg = C_FILIAL+";"+C_MAT+";"+C_NOME+";"+C_CPF+";"+"ERRO NA QUERY: " + chr(10) + TCSQLError()+";"+CRLF
                     FWrite(nHandle4,cMsg,Len(cMsg))    
                  else
                     cMsg = ""
                     cMsg = C_FILIAL+";"+C_MAT+";"+C_NOME+";"+C_CPF+";"+"Funcionario Atualizado com Sucesso"+";"+CRLF
                     FWrite(nHandle4,cMsg,Len(cMsg))    
			      endif
		   	   Else
                  cMsg = ""
                  cMsg = C_FILIAL+";"+C_MAT+";"+C_NOME+";"+C_CPF+";"+"Funcionario Nao Foi Atualizado"+";"+CRLF
                  FWrite(nHandle4,cMsg,Len(cMsg))    
			   EndIf
	           cTMP->(DbCloseArea()) 
		Endif
	Next i
    
    cQry2 := "COMMIT "+CRLF
    If (TCSQLExec(cQry2) < 0)
         cMsg = ""
         cMsg = "99999999"+";"+"999999"+";"+"XXXXXXXXXX"+";"+"99999999999"+";"+"ERRO COMMIT: " + chr(10) + TCSQLError()+";"+CRLF
         FWrite(nHandle4,cMsg,Len(cMsg))    
    ENDIF
    
   fclose (nHandle4)    

    Aviso('Processamento Realizado!',"Verifique o log da importação \SPOOL\UPD0259.CSV", {'OK'}, 1)
	
Return

******************************
Static Function LerArq(aDados)
******************************

	Local cLinha 	:= ""
	Local lPrim 	:= .F.
	Local aCampos	:= {}
	
	FT_FUSE(cArquivo)
	ProcRegua(FT_FLASTREC())
	nQtdLinhas := FT_FLASTREC()
	FT_FGOTOP()
    //////////////////////
	// pular cabecalhos //
	//////////////////////
	cLinha := FT_FREADLN()
	
	aCampos := Separa(cLinha,";",.T.)
	FT_FSKIP()
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
	
	    // filial //
		aDados[nI,1] := PADL(aDados[nI,1],TamSX3("RA_FILIAL")[1],"0")
		// Matricula //
		aDados[nI,3] := STRTRAN(aDados[nI,3], '"', '')
		// Matricula Esocial //
		aDados[nI,4] := STRTRAN(aDados[nI,4], '"', '')
        // CPF //
		aDados[nI,7] := STRTRAN(aDados[nI,7], '"', '')
		
        nLidos++		
	    FWMonitorMsg('*** Lendo Linha = '+strzero(nLidos,9,0)+" de "+strzero(nQtdLinhas,9,0))
  	    cMsg := '*** Lendo Linha = '+strzero(nLidos,9,0)+" de "+strzero(nQtdLinhas,9,0)
        MsProcTxt(cMsg)	
        ProcessMessage()
        FT_FSKIP()

	EndDo

Return 

