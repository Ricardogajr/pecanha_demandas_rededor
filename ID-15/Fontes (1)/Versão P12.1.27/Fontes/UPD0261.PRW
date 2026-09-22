#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
///////////////////////////////////////////////////
// CORRECAO TABELA RAZ ANALISANDO SRD            //
///////////////////////////////////////////////////
***********************
User Function UPD0261()
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

    MsAguarde({|lEnd| ImportDad()},"Aguarde...","Processando....",.T.)
    MsgStop( "Fim da Rotina", "UPD0261" )

Return

***************************
Static Function ImportDad()
***************************

	Local i 		  := 0
	Local j 		  := 0
	Local lRet		  := .T.
	Local aRetorno	  :={}
	Local lOk         := .T.
    Local cQry        := " "
    
    cQry := "SELECT R_E_C_N_O_ AS REGISTRO1 FROM "+RETSQLNAME("RAW")
    cQry += " WHERE D_E_L_E_T_ <> '*'"
    cQry += "  AND RAW_FOLMES >= '201804' " 
    cQry += " ORDER BY RAW_FILIAL" 
    cQry := changequery(cQry)
    TCQUERY cQry ALIAS "TRAW" NEW
    TRAW->(DBGOTOP())  
    WHILE TRAW->(!Eof())
       If TRAW->(REGISTRO1)> 0  
          dbSelectArea( "RAW" )   
          dbGoTo(TRAW->(REGISTRO1))
   	      cMsg := '*** Processando = '+RAW->RAW_FILIAL+" "+RAW->RAW_MAT
          MsProcTxt(cMsg)	
          ProcessMessage()
          CFIL   := RAW->RAW_FILIAL
   		  CMAT   := RAW->RAW_MAT         
   		  cfolmes := RAW->RAW_FOLMES
          nValor := BuscaSRD(cFil,cMat,CFOLMES) 
          IF NVALOR = 0
	         RecLock( "RAW" , .F. )
             RAW->(dbDelete())
			 RAW->(MsUnlock())                                         
		     AADD(aRetorno,{CFIL,cMat,CFOLMES,"Nao","Registro da RAW Sera Excluido"})
		  ELSE
			  AADD(aRetorno,{CFIL,cMat,CFOLMES,"Sim","Registro da RAW Sera Mantido"})
		  ENDIF
	   ENDIF
   	   TRAW->(DBSKIP())
    END      
    TRAW->(DBCLOSEAREA())
	If !Empty(aRetorno)
		Aviso('Processamento Realizado!',"Verifique o log da importação \SPOOL\UPD0261.CSV", {'OK'}, 1)
        Geralog(aRetorno)
	EndIf
	
Return

Static Function Geralog(aRetorno)
Local oExcel                                            
Local cTempPath:=GetTempPath()
Local cDirUsr  := __RELDIR
Local cDirSrv  := '\SPOOL\'
Local cArq     := 'UPD0261.CSV'

CARQ4  := cDirSrv+cArq

nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo UPD0261.CSV")
endif                        
cMsg := "UPD0261 LOG DE PROCESSO"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
cMsg := "FILIAL;MATRICULA;FOLHA;DESCRICAO ERRO"+CRLF
FWrite(nHandle4,cMsg,Len(cMsg))    
For nI := 1 to Len(aRetorno)       
    cMsg = ""
    cMsg = aRetorno[nI][1]+";"+aRetorno[nI][2]+";"+aRetorno[nI][3]+";"+aRetorno[nI][5]+";"+CRLF
    FWrite(nHandle4,cMsg,Len(cMsg))    
Next
fclose (nHandle4)    

Return

*****************************************************
Static Function BuscaSRD(cFil,cMat,cfolmes)
*****************************************************
Local cQry3 := "" 
Local nVal1 := 0
                 
IF CFOLMES = '201813'
   cQry3 := "SELECT SUM(SRD.RD_VALOR) AS VALOR1 FROM "+RETSQLNAME("SRD")+" SRD "
   cQry3 += "WHERE SRD.D_E_L_E_T_ = ''"
   cQry3 += "  AND SRD.RD_FILIAL = '" + cFil + "' " 
   cQry3 += "  AND SRD.RD_MAT = '" + cMat + "' " 
   cQry3 += "  AND SRD.RD_PD IN('A87','B31') " 
   cQry3 += "  AND SRD.RD_DATARQ = '201812'"
   cQry3 += "  AND SRD.RD_ROTEIR = '132'"
ELSE
   cQry3 := "SELECT SUM(SRD.RD_VALOR) AS VALOR1 FROM "+RETSQLNAME("SRD")+" SRD "
   cQry3 += "WHERE SRD.D_E_L_E_T_ = ''"
   cQry3 += "  AND SRD.RD_FILIAL = '" + cFil + "' " 
   cQry3 += "  AND SRD.RD_MAT = '" + cMat + "' " 
   cQry3 += "  AND SRD.RD_PD IN('A88','B30') " 
   cQry3 += "  AND SRD.RD_DATARQ = '"+cfolmes+"' " 
ENDIF
cQry3 := changequery(cQry3)
TCQUERY cQry3 ALIAS "TRGB" NEW
TRGB->(DBGOTOP())  
IF !TRGB->( EOF() )
   nVal1 := TRGB->(VALOR1)
ENDIF     
TRGB->(DBCLOSEAREA())
Return (nVal1)
