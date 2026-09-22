#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
///////////////////////////////////////////////////
// CARGA NA TABELA SRB PROTHEUS 12 VIA PLANILHA. //
///////////////////////////////////////////////////
***********************
User Function UPD0257()
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

    Define MsDialog oDlg Title "UPD0257 - Selecionar Arquivo para Carga" From 08,15 To 19,120 Of GetWndDefault()
      
    @ 18,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
    @ 18,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
    @ 18,275 Button "..." 			Size 010,10 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel
    @ 18,310 Button "OK"            Size 040,20 Action Eval({|| If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,)}) Of oDlg Pixel
    @ 18,355 Button "CANCEL"        Size 040,20 Action Eval({|| lOk:=.F.,oDlg:End() }) Of oDlg Pixel
    Activate MsDialog oDlg //Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

    If lOk
       MsAguarde({|lEnd| LerArq(aDados)},"Aguarde...","Lendo Planilha",.T.)
       MsAguarde({|lEnd| ImportDad(aDados)},"Aguarde...","Processando Planilha",.T.)
       MsgStop( "Fim da Rotina", "UPD0257" )
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
  		   c_RB_MAT    := PADL(aDados[i,5],TamSX3("RB_MAT")[1],"0")
           c_RB_NOME   := aDados[i,6]
           c_RB_CIC    := aDados[i,7]
		   D_RB_DTNASC := aDados[i,8]

           if !ChkCPF(c_rb_cic)
		       AADD(aRetorno,{c_RB_MAT,C_RB_NOME,C_RB_CIC,D_RB_DTNASC,"Dependente com CPF Invalido"})
		   else
			   cQry :=      "SELECT R_E_C_N_O_ AS REGISTRO"
			   cQry += CRLF+"  FROM "+RetSqlName("SRB")
			   cQry += CRLF+" WHERE RB_MAT  = '"+c_RB_MAT+"'"
			   cQry += CRLF+"   AND RB_NOME = '"+c_RB_NOME+"'"
               cQry += CRLF+"   AND D_E_L_E_T_  <> '*'"   
			   cQry := changequery(cQry) 
			   TCQUERY cQry ALIAS "cTMP" NEW
               If cTMP->(REGISTRO)> 0  
                  SRB->( dbGoTo( cTMP->(REGISTRO) ) )					   
                  RecLock("SRB",.F.)
				  IF !EMPTY(C_RB_CIC)
                     SRB->RB_CIC      := c_RB_CIC
				  ENDIF
				  IF !EMPTY(D_RB_DTNASC)
				     SRB->RB_DTNASC   := CTOD(D_RB_DTNASC)
				  ENDIF
				  msunlock()
			      AADD(aRetorno,{c_RB_MAT,C_RB_NOME,C_RB_CIC,D_RB_DTNASC,"Dependente Atualizado com Sucesso"})
		   	   Else
			      AADD(aRetorno,{c_RB_MAT,C_RB_NOME,C_RB_CIC,D_RB_DTNASC,"Dependente Nao Foi Atualizado"})
			   EndIf
	           cTMP->(DbCloseArea()) 
		   endif
		Endif
	Next i

	If !Empty(aRetorno)
		Aviso('Processamento Realizado!',"Verifique o log da importação \SPOOL\UPD0257.CSV", {'OK'}, 1)
        Geralog(aRetorno)
	EndIf
	
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
	////////////////////////////
	// COLUNAS DO ARQUIVO CSV //
	//////////////////////////////////////////////////////////
    // COLUNA E = MATRICULA              RB_MAT             //5
	// COLUNA F = NOME DEPENDENTE        RB_NOME    	    //6
	// COLUNA G = CPF DEPENDENTE         RA_CIC             //7
	// COLUNA H = DATA NASCIMENTO        RA_DTNASC          //8
	//////////////////////////////////////////////////////////
    //////////////////////
	// pular cabecalhos //
	//////////////////////
	cLinha := FT_FREADLN()
	aCampos := Separa(cLinha,";",.T.)
	FT_FSKIP()
    nI := 0
	While !FT_FEOF()

		cLinha := FT_FREADLN()
		If !(EMPTY(STRTRAN(cLinha, ";", "")))
		   AAdd(aDados,Separa(cLinha,";",.T.))
		Else
			EXIT
		EndIf
        nI++            
        nLidos++		
	    FWMonitorMsg('*** Lendo Linha = '+strzero(nLidos,9,0)+" de "+strzero(nQtdLinhas,9,0))
  	    cMsg := '*** Lendo Linha = '+strzero(nLidos,9,0)+" de "+strzero(nQtdLinhas,9,0)
        MsProcTxt(cMsg)	
        ProcessMessage()
        FT_FSKIP()

	EndDo

Return 

Static Function Geralog(aRetorno)
Local oExcel                                            
Local cTempPath:=GetTempPath()
Local cDirUsr  := __RELDIR
Local cDirSrv  := '\SPOOL\'
Local cArq     := 'UPD0257.CSV'

CARQ4  := cDirSrv+cArq

nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo UPD0256.CSV")
endif                        
cMsg := "UPD0257 LOG DE PROCESSO"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
cMsg := "MATRICULA;NOME DEPENDENTE;CPF DEPENDENTE;DATA NASCIMENTO;STATUS"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
For nI := 1 to Len(aRetorno)       
    cMsg = ""
    cMsg = aRetorno[nI][1]+";"+aRetorno[nI][2]+";"+aRetorno[nI][3]+";"+aRetorno[nI][4]+";"+aRetorno[nI][5]+";"+CRLF
    FWrite(nHandle4,cMsg,Len(cMsg))    
Next
fclose (nHandle4)    

//CpyS2T(cDirSrv+cArq, cTempPath)
//
//oExcel:=MSExcel():New()
//oExcel:WorkBooks:Open(cTempPath+carq)
//oExcel:SetVisible(.T.)
//oExcel:Destroy()

Return
