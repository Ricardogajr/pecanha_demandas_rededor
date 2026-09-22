#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#include 'DIRECTRY.CH'

#DEFINE cEol CHR(13)+CHR(10)                                  

//////////////////////////////////////////////////////////////
// VARIAVEIS DE AMBIENTE PARA SEREM CRIADOS                 //
//////////////////////////////////////////////////////////////
// DOR_MAILRL  = "dbarros.luandre@rededor.com.br"           //
// DOR_RELSERV = "hybrid.rededor.com.br:587" ou             //
//               "RDEXC01.rededor.corp:587                  //
// DOR_RELACNT = "portal.esocial@rededor.com.br"            //
// DOR_RELPSW  = "Rededor@2017#"                            //
// DOR_RELFROM = "portal.esocial@rededor.com.br"            //
//                                                          //
//////////////////////////////////////////////////////////////

////////////////////////
User Function CARGAZM0()
////////////////////////

Local lResult := .T.
Local cError  := ""
Local lRpcSet := ""
Local lOpen   := .F. 
Local lRet    := .F.
Local lResulConn := .T.
Local lResulSend := .T.
Local lResult    := .T.
Local lRelauth   := .T. 
Local cError     := ""
Local lRpcSet    := ""
Local lOpen      := .F. 
Local lRet       := .F.
Local CPATH      := "\SPOOL\"

//Private _cRotNam:= "CARGAZM0" 
//Private cServer  := " " //Trim(GetMV("DOR_RELSER"))                      
//Private cUser    := " " //Trim(GetMV("DOR_RELCNT"))                      
//Private cPass    := " " //Trim(GetMV("DOR_RELPSW"))                      
//Private cFrom    := " " //Trim(GetMV("DOR_RELFRO"))                      

//Private cEmail   := cUser
//Private cDe      := cUser
//Private cCc      := ""
//Private cBcc     := ""
//Private cPara    := "roberto.costa64@gmail.com" //Trim(GetMV("DOR_MAILRLF"))                     
//Private cAssunto := "CARGA TABELA ZM0"                             
//Private cAnexo   := ""
//Private cMsg     := " "

Private _cRotNam := "CARGAZM0" 
Private cMsg     := ""
Private aEmpresa := {}
Public cQry      := ''        

//////////////////////////////////////////////////
//      EXCLUINDO RELATORIOS CRIADOS            //
//////////////////////////////////////////////////
aFiles3 := Directory(cpath+"LOGZM0*.txt", "D")
ni:=0
For ni := 1 to len(aFiles3)
    FERASE(cpath+aFiles3[ni][1])
Next 
aFiles4 := Directory(cpath+"SM0ANT*.CSV", "D")
ni:=0
For ni := 1 to len(aFiles4)
    FERASE(cpath+aFiles4[ni][1])
Next 
aFiles5 := Directory(cpath+"SM0DEP*.CSV", "D")
ni:=0
For ni := 1 to len(aFiles5)
    FERASE(cpath+aFiles5[ni][1])
Next 

//////////////////////////////////////////////////

lSchedule := Type("oMainWnd") == "U" 
If lSchedule
   PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01010001" 
Endif

// LOG ERROS //

CNOME3 := "LOGZM0_"+ TIME() + ".TXT"
CNOME3  := StrTran( CNOME3, ":", "_" )
CARQ3  := CPATH+CNOME3 
cAnexo := CARQ3
nHandle3 := Fcreate(cArq3,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo LOG")
endif

CNOME4 := "SM0ANT_"+ TIME() + ".CSV"
CNOME4  := StrTran( CNOME4, ":", "_" )
CARQ4  := CPATH+CNOME4
cAnexo := CARQ4
nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo SM0ANT")
endif
CLINHA := ""
CLINHA := "M0_CODIGO;"+"M0_CODFIL;"+"M0_CGC;"+"M0_CNAE;"+"M0_DTRE;"+"M0_NATJUR;"+"M0_NOMECOM;"+"M0_TPINSC;"+"M0_FPAS"
FWrite(nHandle4,CLINHA+CRLF,132)

CNOME5 := "SM0DEP_"+ TIME() + ".CSV"
CNOME5  := StrTran( CNOME5, ":", "_" )
CARQ5  := CPATH+CNOME5
cAnexo := CARQ5
nHandle5 := Fcreate(cArq5,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo SM0DEP")
endif
CLINHA := ""
CLINHA := "M0_CODIGO"+"M0_CODFIL"+"M0_CGC"+"M0_CNAE"+"M0_DTRE"+"M0_NATJUR"+"M0_NOMECOM"+"M0_TPINSC"+"M0_FPAS"
FWrite(nHandle5,CLINHA+CRLF,132)

TAM1 := 60 - LEN(ALLTRIM(SM0->M0_NOMECOM))
DBSELECTAREA( "SM0" )
cMsg := " "+CRLF       
cMsg += "***********************************************************************************************************************"+CRLF
cMsg += ALLTRIM(SM0->M0_NOMECOM)+SPACE(TAM1)+"                                    Folha..:          1"+CRLF
cMsg += "SIGA /CARGAZM0                         LOG DA ROTINA CARGAZM0                                                     "+CRLF
cMsg += "Hora...: "+TIME()+" - Empresa: "+ALLTRIM(SM0->M0_CODIGO)+" / Filial: "+SM0->M0_CODFIL+"                                          Emissão: "+DTOC(DDATABASE)+"  "+CRLF
cMsg += "***********************************************************************************************************************"+CRLF
FWrite(nHandle3,cMSG,Len(cMSG))
FWrite(nHandle3,"INICIANDO CARGA ZM0"+CRLF,80)
cMsg += ""+CRLF
cMsg += ""+CRLF

Begin Sequence
       DBSELECTAREA( "SM0" )
       DBGOTOP()
       WHILE !EOF()
           CLINHA := SM0->M0_CODIGO+";"+SM0->M0_CODFIL+";"+SM0->M0_CGC+";"+SM0->M0_CNAE+";"+DTOS(SM0->M0_DTRE)+";"+SM0->M0_NATJUR+";"+SM0->M0_NOMECOM+";"+STRZERO(SM0->M0_TPINSC,1,0)+";"+SM0->M0_FPAS
           FWrite(nHandle4,CLINHA+CRLF,132)
		   SM0->(DBSKIP()) 
       END
       Fclose (nHandle4)                     

       DBSELECTAREA( "SM0" )
       DBGOTOP()
       WHILE !EOF()

	       DbSelectArea("ZM0") 
           DbSetOrder(1)
   
	       cFilial := xFilial("ZM0")
		   cCodigo := SM0->M0_CODIGO
           cCodFil := SM0->M0_CODFIL
		   If DbSeek(cFilial+cCodigo+cCodFil)
              RecLock("ZM0",.F.)
           Else
              RecLock("ZM0",.T.)
              ZM0->ZM0_FILIAL  := cFilial
              ZM0->ZM0_CODIGO  := cCodigo				  
              ZM0->ZM0_CODFIL  := cCodFil
		   Endif
           ZM0->ZM0_CGC    := SM0->M0_CGC 
           ZM0->ZM0_CNAE   := SM0->M0_CNAE 
           ZM0->ZM0_DTRE   := SM0->M0_DTRE 
           ZM0->ZM0_NATJUR := SM0->M0_NATJUR 
           ZM0->ZM0_NOMECO := SM0->M0_NOMECOM
           ZM0->ZM0_TPINSC := SM0->M0_TPINSC 
           ZM0->ZM0_FPAS   := SM0->M0_FPAS 
           ZM0->ZM0_ENDCOB := SM0->M0_ENDCOB  
           ZM0->ZM0_COMPCO := SM0->M0_COMPCOB    
           ZM0->ZM0_BAIRCO := SM0->M0_BAIRCOB  
           ZM0->ZM0_CIDCOB := SM0->M0_CIDCOB   
           ZM0->ZM0_ESTCOB := SM0->M0_ESTCOB    
           ZM0->ZM0_CEPCOB := SM0->M0_CEPCOB   
           ZM0->ZM0_FILNOM := SM0->M0_FILIAL		   
           ZM0->(MsUnlock())

		   cMsg += "Carga Feita "+cCodigo+"/"+cCodFil+" "+CRLF
		   
           FWrite(nHandle3,"GRAVANDO NA ZM0 "+cCodigo+"-"+cCodFil+CRLF,80)
           
		   DBSELECTAREA( "SM0" )
		   SM0->(DBSKIP()) 
       END
	   
       FWrite(nHandle3,"FIM DA CARGA NA ZM0 "+CRLF,80)
       Fclose (nHandle3)                     

       DBSELECTAREA( "SM0" )
       DBGOTOP()
       WHILE !EOF()
           CLINHA := SM0->M0_CODIGO+";"+SM0->M0_CODFIL+";"+SM0->M0_CGC+";"+SM0->M0_CNAE+";"+DTOS(SM0->M0_DTRE)+";"+SM0->M0_NATJUR+";"+SM0->M0_NOMECOM+";"+STRZERO(SM0->M0_TPINSC,1,0)+";"+SM0->M0_FPAS
           FWrite(nHandle5,CLINHA+CRLF,132)
		   SM0->(DBSKIP()) 
       END
       Fclose (nHandle5)                     
	  
End Sequence    

If lSchedule
   RESET ENVIRONMENT 
Endif

Return 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
