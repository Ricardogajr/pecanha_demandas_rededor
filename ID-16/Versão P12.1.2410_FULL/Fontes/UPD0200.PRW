#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
///////////////////////////////////////////////////
// CARGA NA TABELA RHH PROTHEUS 12 VIA PLANILHA. //
///////////////////////////////////////////////////
***********************
User Function UPD0200()
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

    Define MsDialog oDlg Title "UPD0200 - Selecionar Arquivo para Carga" From 08,15 To 19,120 Of GetWndDefault()
      
    @ 18,16  Say 	"Diretorio:" 	Size 050,10 Of oDlg Pixel
    @ 18,40  MsGet 	cArquivo 		Size 230,08 Of oDlg Pixel
    @ 18,275 Button "..." 			Size 010,10 Action Eval({|| cArquivo:=u_SelectFile() }) Of oDlg Pixel
    @ 18,310 Button "OK"            Size 040,20 Action Eval({|| If(u_ValidaDir(cArquivo), (lOk:=.T.,oDlg:End()) ,)}) Of oDlg Pixel
    @ 18,355 Button "CANCEL"        Size 040,20 Action Eval({|| lOk:=.F.,oDlg:End() }) Of oDlg Pixel
    Activate MsDialog oDlg //Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

    If lOk
       MsgRun("Lendo Planilha ","Aguarde...",{|| LerArq(aDados) })   
       MsgRun("Processando Planilha ","Aguarde...",{|| ImportDad(aDados) })   
       MsgStop( "Fim da Rotina", "UPD0200" )
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
	Local aAreaSRA    := SRA->(GetArea())

	ProcRegua(LEN(ADADOS))

	//////////////////////////////////////////////////////////
	// COLUNA A = MATRICULA                   RA_MAT	    //1
	// COLUNA B = DEPARTAMENTO                RA_DEPTO	    //2
	//////////////////////////////////////////////////////////

	For i:=1 to Len(aDados)
        nproce++
	    /////ternal(1,'*** Processando Linha = '+strzero(nproce,9,0)+" de "+strzero(nLidos,9,0))
	    if len(aDados[i,1]) > 0
           c_Mat    := PADL(aDados[i,1],TamSX3("RA_MAT")[1],"0")
		   n1       := TamSX3("RA_MAT")[1]
           c_Mat    := Strzero(Val(c_mat),N1,0)
           c_Depto  := PADL(aDados[i,2],TamSX3("RA_DEPTO")[1],"0")
		   n1       := TamSX3("RA_DEPTO")[1]
		   c_Depto  := strzero(val(c_depto),N1,0)
           c_linha  := strzero(i,8,0)

		   cQry :=      "SELECT R_E_C_N_O_ AS REGISTRO"
		   cQry += CRLF+"  FROM "+RetSqlName("SRA")
		   cQry += CRLF+" WHERE RA_MAT = '"+c_Mat+"'"
           cQry += CRLF+"   AND D_E_L_E_T_  <> '*'"   
		   cQry := changequery(cQry) 
		   TCQUERY cQry ALIAS "cTMP" NEW
           If cTMP->(REGISTRO)> 0  
              SRA->( dbGoTo( cTMP->(REGISTRO) ) )					   
              RecLock("SRA",.F.)
              SRA->RA_DEPTO  := c_Depto
              msunlock()
		      AADD(aRetorno,{c_Mat,"Sim","Linha="+c_linha+" - Atualizada com Sucesso"})
	   	   Else
			  AADD(aRetorno,{c_Mat,"Nao","Linha="+c_linha+" - Matricula Nao Encontrada"})
		   EndIf
	       cTMP->(DbCloseArea()) 
		Endif
	Next i

	If !Empty(aRetorno)
		Aviso('Processamento Realizado!',"Verifique o log da importação \SPOOL\UPD0200.CSV", {'OK'}, 1)
        Geralog(aRetorno)
	EndIf
	
	RestArea(aAreaSRA)

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
	// COLUNA A = MATRICULA                   RA_MAT	    //1
	// COLUNA B = DEPARTAMENTO                RA_DEPTO	    //2
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
	    ////ternal(1,'*** Lendo Linha = '+strzero(nLidos,9,0)+" de "+strzero(nQtdLinhas,9,0))
		FT_FSKIP()

	EndDo

Return 

Static Function Geralog(aRetorno)
Local oExcel                                            
Local cTempPath:=GetTempPath()
Local cDirUsr  := __RELDIR
Local cDirSrv  := '\SPOOL\'
Local cArq     := 'UPD0200.CSV'
Local nI
CARQ4  := cDirSrv+cArq

nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo UPD0200.CSV")
endif                        
cMsg := "UPD0200 LOG DE PROCESSO"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
cMsg := "MATRICULA;DESCRICAO ERRO"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
For nI := 1 to Len(aRetorno)       
    cMsg = ""
    cMsg = aRetorno[nI][1]+";"+aRetorno[nI][3]+";"+CRLF
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

