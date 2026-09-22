#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#include 'DIRECTRY.CH'
#DEFINE cEol CHR(13)+CHR(10)                                  

//////////////////////////////////////////////////////////////                                                              
// VARIAVEIS DE AMBIENTE PARA SEREM CRIADOS                 //
//////////////////////////////////////////////////////////////
// DOR_MAILRL  = "cleide.fernandes@rededor.com.br"          //
// DOR_RELSERV = "hybrid.rededor.com.br:587"                //
// DOR_RELACNT = "portal.esocial@rededor.com.br"            //
// DOR_RELPSW  = "Rededor@2017#"                            //
// ROD_RELFROM = "portal.esocial@rededor.com.br"            //
//////////////////////////////////////////////////////////////            

////////////////////////
User Function AVISORET()
////////////////////////

Local lResulConn := .T.
Local lResulSend := .T.
Local lResult    := .T.
Local lRelauth   := .T. //GetMv("MV_RELAUTH")
Local cError     := ""
Local lRpcSet    := ""
//LOCAL AAREA		:= GETAREA()
Local lOpen     := .F. 
Local lRet      := .F.
Local CPATH     := ""
Local RELDIR    := "" //AllTrim(GetMV("MV_RELT"))  //GetSrvProfString('RootPath', '')

Private _cRotNam:= "AVISORET" 


Private cServer  := "" //Trim(GetMV("DOR_RELSER"))                               // Ex: mail.XXXXX.com.br
Private cUser    := "" //Trim(GetMV("DOR_RELCNT"))                               // Ex: workflow@XXXXX.com.br
Private cPass    := "" //Trim(GetMV("DOR_RELPSW"))                                // Ex: XXXXX
Private cFrom    := "" //Trim(GetMV("DOR_RELFRO"))                               // Campo FROM no e-mail.


/*
Private cServer  := Trim(GetMV("MV_RELSERV"))                               // Ex: mail.XXXXX.com.br
Private cUser    := Trim(GetMV("MV_RELACNT"))                               // Ex: workflow@XXXXX.com.br
Private cPass    := Trim(GetMV("MV_RELAPSW"))                                // Ex: XXXXX
Private cFrom    := Trim(GetMV("MV_RELACNT"))                               // Campo FROM no e-mail.
*/

Private cEmail   := cUser
Private cDe      := cUser
Private cCc      := ""
Private cBcc     := ""
Private cAssunto := "CONFIRMACAO RETORNO DE AFASTAMENTO "            // Titulo do e-mail.
Private cAnexo   := ""
Private cMsg     := ""
Private aEmpresa :={}
Public cQry      := ''        

lSchedule := Type("oMainWnd") == "U"  

If lSchedule
   CPATH     := "\SPOOL\" 
ELSE
   CPATH     := AllTrim(GetMV("MV_RELT")) 
ENDIF
 

//////////////////////////////////////////////////
//      EXCLUINDO RELATORIOS CRIADOS            //
//////////////////////////////////////////////////
aFiles1 := Directory(cpath+"RELAFAST*.*", "D")
aFiles2 := Directory(cpath+"FIMAFAST*.*", "D")
aFiles3 := Directory(cpath+"LOGAFAST*.*", "D")
aFiles4 := Directory(cpath+"LOGEMPRE*.*", "D") 
aFiles5 := Directory(cpath+"LOGERROS*.*", "D") 

ni:=0
For ni := 1 to len(aFiles1)
    FERASE(cpath+aFiles1[ni][1])
Next 

ni:=0
For ni := 1 to len(aFiles2)
    FERASE(cpath+aFiles2[ni][1])
Next

ni:=0
For ni := 1 to len(aFiles3)
    FERASE(cpath+aFiles3[ni][1])
Next 

ni:=0
For ni := 1 to len(aFiles4)
    FERASE(cpath+aFiles4[ni][1])
Next

ni:=0
For ni := 1 to len(aFiles5)
    FERASE(cpath+aFiles5[ni][1])
Next


//aEval(aFiles1, { |aFile| FERASE(aFile[F_NAME]) })  
//aEval(aFiles2, { |aFile| FERASE(aFile[F_NAME]) })  
//aEval(aFiles3, { |aFile| FERASE(aFile[F_NAME]) })  
//aEval(aFiles4, { |aFile| FERASE(aFile[F_NAME]) })  
//////////////////////////////////////////////////

// LISTA EMPRESAS //
CNOME4 := "LOGEMPRE_" + TIME() + ".TXT"
CNOME4  := StrTran( CNOME4, ":", "_" )
CARQ4  := CPATH+CNOME4
nHandle4 := Fcreate(cArq4,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo LOGEMPRE")
endif
lSchedule := Type("oMainWnd") == "U" //
ConOut(IIF(lSchedule,"RODANDO VIA SCHEDULE", "RODANDO VIA INTERFACE"))
ConOut(Time()+"|"+_cRotNam+" - Iniciando rotina AvisoRet...")   
If lSchedule
   PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01010001" 
Endif
cMsg := " "+CRLF
cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF
cMsg += "   "+ALLTRIM(SM0->M0_FILIAL)+"                                                                                                                                                                                  Folha..:      1       "+CRLF
cMsg += "   SIGA /AVISORET                                                                                     LISTA DE EMPRESAS SMO                                                                                               "+CRLF
cMsg += "   Hora...: "+TIME()+" - Empresa: "+ALLTRIM(SM0->M0_CODIGO)+" / Filial: "+ALLTRIM(SM0->M0_CODFIL)+"                                                                                                                             Emissão: "+DTOC(DDATABASE)+"  "+CRLF
cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF
FWrite(nHandle4,cMSG,Len(cMSG))
aEmpresa :={}
Begin Sequence
	If lSchedule
           DBSELECTAREA( "SM0" )
           DBGOTOP() 
           NI:=0  
           if len(aempresas) = 0
           WHILE !EOF()
                 Aadd(aEmpresas,{M0_CODIGO,M0_CODFIL,M0_FILIAL}) 
                 //IF ZA1->( DBSEEK(SM0->M0_CODFIL) )
                 //   cEmail = " "
                 //Else
                    cEmail = " Sem Email para Aviso " 
                 //Endif
                 cMsg := "EMPRESA/FILIAL LIDA SM0 = "+ALLTRIM(SM0->M0_CODIGO)+" / "+ALLTRIM(SM0->M0_CODFIL)+" - "+ SM0->M0_FILIAL + cEmail + CRLF
		         FWMonitorMsg( cMsg ) 
                 FWrite(nHandle4,cMSG,Len(cMSG)) 
                 NI++
	             DBSKIP()
           END  
           endif
           Fclose (nHandle4)  
           IF NI=0
              FERASE(carq4)
           ENDIF                  
//           RESTAREA( AAREA )  
           For nx = 1 to Len(aEmpresas)
    		   cEmp := aEmpresas[nx][1]
               cFil := aEmpresas[nx][2]                     
               cNom := aEmpresas[nx][3]
			   ConOut(Time()+"|"+_cRotNam+" - Processando a EMPRESA: "+cEmp+" | FILIAL: "+cFil+"...")  
			   FWMonitorMsg('*** processando filial'+cFil+' ***')
               lRet := U_AvisoEmp(Alltrim(cEmp),cFil,cNom)
 			   ConOut(Time()+"|"+_cRotNam+" - Final Processo da EMPRESA: "+cEmp+" | FILIAL: "+cFil+"...")
          Next                                         
    Else
        DBSELECTAREA( "SM0" )
        DBGOTOP()             
        ni:=0  
        if len(aempresas)=0
        WHILE !EOF()
	          Aadd(aEmpresas,{M0_CODIGO,M0_CODFIL,M0_FILIAL}) 
              //IF ZA1->( DBSEEK(SM0->M0_CODFIL) )
              //   cEmail = " "
              //Else
                 cEmail = " Sem Email para Aviso " 
              //Endif
              cMsg := "EMPRESA/FILIAL LIDA SM0 = "+ALLTRIM(SM0->M0_CODIGO)+" / "+ALLTRIM(SM0->M0_CODFIL)+" - "+ SM0->M0_FILIAL + cEmail + CRLF
              FWMonitorMsg( cMsg ) 
              FWrite(nHandle4,cMSG,Len(cMSG)) 
              ni++
	          DBSKIP()                                                       
	    END 
	    endif
        Fclose (nHandle4)     
        IF NI=0   
           FERASE(carq4)
        ENDIF
  //      RESTAREA( AAREA )            
        For nx = 1 to Len(aEmpresas)
            cEmp := aEmpresas[nx][1]
            cFil := aEmpresas[nx][2]
            cNom := aEmpresas[nx][3]
            lRet := U_AvisoEmp(Alltrim(cEmp),cFil,cNom)
        Next                                         
	    MsgStop( "Fim da Rotina", "AVISORET" )
    Endif    
End Sequence    
ConOut(Time()+"|"+_cRotNam+" - Final da Rotina AvisoRet !")

If lSchedule
   RESET ENVIRONMENT 
Endif

Return
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function AvisoEmp(cEmp,cFil,cNom)

Local lResulConn := .T.
Local lResulSend := .T.
Local lResult    := .T.
Local lRelauth   := .T. //GetMv("MV_RELAUTH")
Local cError     := ""
Local lRpcSet    := ""
Local TemRet1 := 0
Local TemRet2 := 0  
Local nTempoEspera := 2000  // espera de 2 segundos        
Local nTentativas  := 0
Local LimiteTenta  := 3
Local CPATH     := ""

Private cPara := " "  

//Private cPara    := "roberto.costa64@gmail.com"                    // Trim(GetMV("MAILRL"))                                   // MAILREVL --> E-mail que recebera a msg.

////
lSchedule := Type("oMainWnd") == "U" 
If lSchedule
   CPATH     := "\SPOOL\" 
ELSE
   CPATH     := AllTrim(GetMV("MV_RELT"))
ENDIF

// LOG ERROS //
//CNOME5 := "LOGERROS_"+ Alltrim(cFil) + "_" + TIME() + ".TXT"
//CNOME5  := StrTran( CNOME5, ":", "_" )
//CARQ5  := CPATH+CNOME5
//nHandle5 := Fcreate(cArq5,0)		// cria o arquivo
//If Ferror() != 0
//   Conout("houve erro na criação do arquivo LOG")
//endif
//
//cMsg := " "+CRLF
//cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF
//cMsg += ""+ALLTRIM(cNom)+"                                                                                                                                                                                  Folha..:      1       "+CRLF
//cMsg += "SIGA /AVISORET                                                                                     LOG DA ROTINA AVISORET                                                                                              "+CRLF
//cMsg += "Hora...: "+TIME()+" - Empresa: "+ALLTRIM(cEmp)+" / Filial: "+ALLTRIM(cFil)+"                                                                                                                             Emissão: "+DTOC(DDATABASE)+"  "+CRLF
//cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF
//FWrite(nHandle5,cMSG,Len(cMSG))


////////////////////////////////////////////////////////////////////////////////

/*
DBSELECTAREA( "ZA1" )
ZA1->( DBGOTOP() )
TemEmail := 0
WHILE ZA1->( !EOF() )
    IF Alltrim(ZA1->(ZA1_FILIAL)) = Alltrim(cFil)
       TemEmail += 1
       If TemEmail == 1
          cPara += Alltrim(ZA1->(ZA1_EMAIL))
       Else                                 
          cPara += "," + Alltrim(ZA1->(ZA1_EMAIL))
       Endif
    ENDIF
	ZA1->( DBSKIP() )
END  

IF TemEmail = 0
   Return .T.
Endif
*/

DHOJE  := dtos(DDATABASE)
DDATA1 := dtos(DDATABASE + 1)
DDATA2 := dtos(DDATABASE + 8)
CPATH     := ""
lSchedule := Type("oMainWnd") == "U" 
If lSchedule
   CPATH     := "\SPOOL\" 
ELSE
   CPATH     := AllTrim(GetMV("MV_RELT"))
ENDIF

//CPATH  := GetSrvProfString('Startpath', '')
CNOME  := "RELAFAST_"+ Alltrim(cFil) + "_" + TIME() + ".##r"   
CNOME  := StrTran( CNOME, ":", "_" )
CARQ   := CPATH+CNOME                         
// LOG ERROS //
CNOME3 := "LOGAFAST_"+ Alltrim(cFil) + "_" + TIME() + ".TXT"
CNOME3  := StrTran( CNOME3, ":", "_" )
CARQ3  := CPATH+CNOME3
nXHandle3 := 0
nHandle3 := Fcreate(cArq3,0)		// cria o arquivo
If Ferror() != 0
   Conout("houve erro na criação do arquivo LOG")
endif

cMsg := " "+CRLF
cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF
cMsg += "   "+ALLTRIM(cNom)+"                                                                                                                                                                                  Folha..:      1       "+CRLF
cMsg += "   SIGA /AVISORET                                                                                     LOG DA ROTINA AVISORET                                                                                              "+CRLF
cMsg += "   Hora...: "+TIME()+" - Empresa: "+ALLTRIM(cEmp)+" / Filial: "+ALLTRIM(cFil)+"                                                                                                                             Emissão: "+DTOC(DDATABASE)+"  "+CRLF
cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF
FWrite(nHandle3,cMSG,Len(cMSG))

////////////////////////////////////////////////////////////
cAlias  := GetNextAlias()
If Select(cAlias) > 0
 (cAlias)->(dbCloseArea())
EndIf
cQry := "SELECT DISTINCT SR8.R8_FILIAL AS FILIAL, SR8.R8_MAT AS MATRICULA, SRA.RA_NOMECMP AS NOME, SR8.R8_TIPOAFA AS TIPOAFA, RCM.RCM_DESCRI AS DESCAFA, SR8.R8_DATAINI AS DATAINI, SR8.R8_DATAFIM AS DATAFIM "
cQry += "FROM SR8010 SR8, SRA010 SRA, RCM010 RCM "
cQry += "WHERE SR8.R8_TIPOAFA IN('006','019','020')  "
cQry += "    AND SR8.R8_FILIAL = '"+ALLTRIM(cFil)+"' "
cQry += "    AND SR8.R8_DATAFIM BETWEEN '" + ddata1 + "' AND '" + ddata2 + "' "
cQry += "    AND SRA.RA_FILIAL=SR8.R8_FILIAL "
cQry += "    AND SRA.RA_MAT=SR8.R8_MAT "
cQry += "    AND RCM.RCM_TIPO=SR8.R8_TIPOAFA "
cQry += "    AND SR8.R_E_C_D_E_L_ = 0 "
cQry += "    AND SRA.R_E_C_D_E_L_ = 0 "
cQry += "    AND RCM.R_E_C_D_E_L_ = 0 "
cQry += " ORDER BY R8_FILIAL, R8_DATAFIM "

cQry := ChangeQuery(cQry) 
TCQUERY cQry NEW ALIAS (cAlias)             
//(Alias)->(dbSelectArea())

If (cAlias)->(!EOF())
	
    cMsg := " "+CRLF
    cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF
    cMsg += "   "+ALLTRIM(cNom)+"                                                                                                                                                                                  Folha..:      1       "+CRLF
    cMsg += "   SIGA /AVISORET                                                                     RELAÇÃO DE COLABORADORES AFASTADOS COM RETORNO DENTRO DE 7 DIAS                                                                     "+CRLF
    cMsg += "   Hora...: "+TIME()+" - Empresa: "+ALLTRIM(cEmp)+" / Filial: "+ALLTRIM(cFil)+"                                                                                                                             Emissão: "+DTOC(DDATABASE)+"  "+CRLF
    cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF
    cMsg += "==========================================================================================================================================================================================================="+CRLF
    cMsg += "         |           |                                                                        |                                                                                   |  DATA      |   DATA  "+CRLF
    cMsg += "FILIAL   | MATRICULA | NOME DO FUNCIONARIO                                                    | MOTIVO DO AFASTAMENTO                                                             |  INICIO    |   FINAL "+CRLF
    cMsg += "==========================================================================================================================================================================================================="+CRLF
    
    NI:=0
	Do While (cAlias)->(!EOF())
		  
		TemRet1 += 1  
		cMsg1 := (cAlias)->(FILIAL) + " | "  
		cMsg2 := (cAlias)->(MATRICULA) + "    | " 
		cMsg3 := (cAlias)->(NOME) + " | "
		cMsg4 := (cAlias)->(TIPOAFA) + " | "
		cMsg5 := (cAlias)->(DESCAFA) + " | "
		cMsg6 := dtoc(stod((cAlias)->(DATAINI))) + "   | "
		cMsg7 := dtoc(stod((cAlias)->(DATAFIM)))
		
		cMsg += cMsg1 + cMsg2 + cMsg3 + cMsg4 + cMsg5 + cMsg6 + cMsg7 + CRLF 
        FWMonitorMsg( cMsg ) 
		NI++ 
		(cAlias)->(DBSKIP())
		
	EndDo   
                
    nHandle := Fcreate(cArq,0)		// cria o arquivo
	If Ferror() != 0
       FWrite(nHandle3,"houve erro na criação do arquivo"+cArq+CRLF,80)
       nXHandle3++
    endif
    FWrite(nHandle,cMSG,Len(cMSG))
    Fclose (nHandle) 
    IF NI=0 
       FERASE(carq)
    ENDIF                   
Endif

(cAlias)->(DBCLOSEAREA())     

///////////////////////////////////////////////////////////////////////
// ATUALIZANDO R8_DTFIMRE DATA REAL DO RETORNO PARA FINS DO E-SOCIAL //
///////////////////////////////////////////////////////////////////////
Public cQry     := ''
cAlias  := GetNextAlias()

DHOJE  := dtos(DDATABASE)
DDATA1 := dtos(DDATABASE + 1)
DDATA2 := dtos(DDATABASE + 7)
CPATH     := ""
lSchedule := Type("oMainWnd") == "U" 
If lSchedule
   CPATH     := "\SPOOL\" 
ELSE
   CPATH     := AllTrim(GetMV("MV_RELT"))
ENDIF

//CPATH  := GetSrvProfString('Startpath', '')
CNOME2 := "FIMAFAST_" + Alltrim(cFil) + "_" + TIME() + ".##r" 
CNOME2 := StrTran( CNOME2, ":", "_" )
CARQ2  := CPATH+CNOME2                         

If Select(cAlias) > 0
  (cAlias)->(dbCloseArea())
EndIf

cQry := "SELECT DISTINCT SR8.R_E_C_N_O_ NUMREG "
cQry += "FROM SR8010 SR8 "
cQry += "WHERE (SR8.R8_FILIAL = '"+ALLTRIM(cFil)+"') "
cQry += "  AND (SR8.R8_DATAFIM <= '" + DHOJE + "') "
cQry += "  AND (sr8.r8_datafim<>sr8.r8_dtfimre)"
cQry += "  AND (SR8.R_E_C_D_E_L_ = 0) "

cQry := ChangeQuery(cQry)
TCQUERY cQry NEW ALIAS (cAlias) 
//TCQUERY cQry ALIAS NEW
//(cAlias)->(dbSelectArea())

If (cAlias)->(!EOF())
	Do While (cAlias)->(!EOF())
		TemRet2 += 1  
		nRecno := (cAlias)->(NUMREG)  
        SR8->(Dbgoto(nRecno))
        Reclock("SR8",.F.)
        SR8->R8_DTFIMRE	:= SR8->R8_DATAFIM		
	    SR8->(MsUnLock())
		(cAlias)->(DBSKIP())
	EndDo      
Endif      

If TemRet1 = 0 .And. TemRet2 > 0
   CANEXO := CARQ2
Endif

If TemRet1 > 0 .And. TemRet2 > 0
   CANEXO := CARQ
   CANEXO += ","+CARQ2
Endif

If TemRet1 > 0 .And. TemRet2 = 0
   CANEXO := CARQ
Endif

(cAlias)->(DBCLOSEAREA())    
 
/////////////////////////
// CONFIRMAÇÃO RETORNO //
/////////////////////////
If TemRet2 > 0 
    
   cAlias  := GetNextAlias()

   If Select(cAlias) > 0
	  (cAlias)->(dbCloseArea())
   EndIf

   cQry := "SELECT DISTINCT SR8.R8_FILIAL AS FILIAL, SR8.R8_MAT AS MATRICULA, SRA.RA_NOMECMP AS NOME, SR8.R8_TIPOAFA AS TIPOAFA, RCM.RCM_DESCRI AS DESCAFA, SR8.R8_DATAINI AS DATAINI, SR8.R8_DATAFIM AS DATAFIM "
   cQry += "FROM SR8010 SR8, SRA010 SRA, RCM010 RCM "
   cQry += "WHERE SR8.R8_TIPOAFA IN('006','019','020')  "
   cQry += "    AND SR8.R8_DTFIMRE = '" + DHOJE + "' "
   cQry += "    AND SR8.R8_FILIAL = '"+ALLTRIM(cFil)+"' "
   cQry += "    AND SRA.RA_FILIAL=SR8.R8_FILIAL "
   cQry += "    AND SRA.RA_MAT=SR8.R8_MAT "
   cQry += "    AND RCM.RCM_TIPO=SR8.R8_TIPOAFA "
   cQry += "    AND SR8.R_E_C_D_E_L_ = 0 "
   cQry += "    AND SRA.R_E_C_D_E_L_ = 0 "
   cQry += "    AND RCM.R_E_C_D_E_L_ = 0 "
   cQry += " ORDER BY R8_FILIAL, R8_MAT "     
   cQry := ChangeQuery(cQry)
   TCQUERY cQry NEW ALIAS (cAlias)    
   //(cAlias)->(dbSelectArea())
   If (cAlias)->(!EOF())
	
      cMsg := " "+CRLF
      cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF
      cMsg += "   "+ALLTRIM(cNom)+"                                                                                                                                                                                  Folha..:      1       "+CRLF
      cMsg += "   SIGA /AVISORET                                                                     RELAÇÃO DE COLABORADORES AFASTADOS COM RETORNO CONFIRMADO                                                                           "+CRLF
      cMsg += "   Hora...: "+TIME()+" - Empresa: "+ALLTRIM(cEmp)+" / Filial: "+ALLTRIM(cFil)+"                                                                                                                             Emissão: "+DTOC(DDATABASE)+"  "+CRLF
      cMsg += "***********************************************************************************************************************************************************************************************************************"+CRLF    
      cMsg += "==========================================================================================================================================================================================================="+CRLF
      cMsg += "         |           |                                                                        |                                                                                   |  DATA      |   DATA  "+CRLF
      cMsg += "FILIAL   | MATRICULA | NOME DO FUNCIONARIO                                                    | MOTIVO DO AFASTAMENTO                                                             |  INICIO    |   FINAL "+CRLF
      cMsg += "==========================================================================================================================================================================================================="+CRLF
      
      NI:=0
      
	  Do While (cAlias)->(!EOF())
		  
	     cMsg1 := (cAlias)->(FILIAL) + " | "  
		 cMsg2 := (cAlias)->(MATRICULA) + "    | " 
		 cMsg3 := (cAlias)->(NOME) + " | "
		 cMsg4 := (cAlias)->(TIPOAFA) + " | "
		 cMsg5 := (cAlias)->(DESCAFA) + " | "
		 cMsg6 := dtoc(stod((cAlias)->(DATAINI))) + "   | "
		 cMsg7 := dtoc(stod((cAlias)->(DATAFIM)))
		
		 cMsg += cMsg1 + cMsg2 + cMsg3 + cMsg4 + cMsg5 + cMsg6 + cMsg7 + CRLF 
         FWMonitorMsg( cMsg ) 
		 NI++
		 (cAlias)->(DBSKIP())
		
	  EndDo                   
      nHandle := Fcreate(cArq2,0)		// cria o arquivo
      If Ferror() != 0
         FWrite(nHandle3,"houve erro na criação do arquivo "+cArq2+CRLF,80)
         nXHandle3++
      endif
      FWrite(nHandle,cMSG,Len(cMSG))
      Fclose (nHandle)   
      IF NI=0
         FERASE(CARQ2)
      ENDIF                 
   Endif

   (cAlias)->(DBCLOSEAREA())     
Endif

/*
If TemRet1 > 0 .Or. TemRet2 > 0
   ptinternal(1,"ENVIANDO E-MAIL "+cAnexo) 

   cMsg := "Favor verificar a data fim dos afastamentos listados no relatorio em anexo; o retorno dos colaboradores se aproxima.                                                                     "+CRLF
   cMsg += "Caso, o afastamento se postergue, atualize o campo “DATA FINAL” na rotina Atestados Médicos.                                                                                             "+CRLF
   cMsg += "Também em Anexo, Relação do(s) Colaboradores com Confirmação do Retorno de Afastamento.                                                                                                  "+CRLF
	
   //CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn
   lResulConn := MailSmtpOn( cServer, cEmail, cPass)
   If !lResulConn
      //GET MAIL ERROR cError
      cError := MailGetErr()
      FWrite(nHandle3,"Falha na Conexao com o Servidor "+alltrim(cServer)+CRLF,80)
      Return(.F.)
   Endif
	
// Sintaxe: SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
// Todos os e-mail terão: De, Para, Assunto e Mensagem, porém precisa analisar se tem: Com Cópia e/ou Anexo     
	
   If lRelauth 
      /////////////////////////////////////////////////////////
      // Tempo de espera para proxima autenticação do e-mail //
      /////////////////////////////////////////////////////////
      nTentativas := 0 
      llResult := .F.
      While nTentativas < LimiteTenta
            nTentativas += 1   
            Sleep( nTempoEspera )                                 
            lResult := MailAuth(Alltrim(cEmail), Alltrim(cPass))  
            If lResult
               Exit
            Endif
      EndDo   
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
	//Se nao conseguiu fazer a Autenticacao usando oE-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail //
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      If !lResult
         nA := At("@",cEmail)
	     cUser := If(nA>0,Subs(cEmail,1,nA-1),cEmail)   
         nTentativas := 0 
         llResult := .F.
         While nTentativas < LimiteTenta
            nTentativas += 1
            Sleep( nTempoEspera )                                 
            lResult := MailAuth(Alltrim(cUser), Alltrim(cPass))
            If lResult
               Exit
 	        Endif
         End
      Endif
   Endif
   	
   If lResult
      nTentativas := 0 
      lResulSend  := .F.
      While nTentativas < LimiteTenta
            nTentativas += 1
            Sleep( nTempoEspera )                                 
            lResulSend := MailSend(cDe,{cPara},{cCc},{cBcc},cAssunto,cMsg,{cAnexo},.T.)
            If lResultSend
               Exit
            Endif
      EndDo
      
      If !lResulSend
		//GET MAIL ERROR cError   
         cError := MailGetErr()
         FWrite(nHandle3,"Falha no envio do e-mail erro="+cError+CRLF,80)
      Endif
   Else
      FWrite(nHandle3,"Falha na autenticação do e-mail "+cPara+CRLF,80)
	  lResulSend := .F.
   Endif        
	
//DISCONNECT SMTP SERVER

   MailSmtpOff()
   IF lResulSend
      FWrite(nHandle3,"Envio Realizado com Sucesso"+CRLF,80)
   Else
      FWrite(nHandle3,"Falha no Envio "+CRLF,80)
   ENDIF
Else
   FWrite(nHandle3,"Sem Dados a Imprimir "+CRLF,80)
Endif   
*/

Fclose (nHandle3)
IF nXHandle3 = 0
   FERASE(CARQ3)
ENDIF                

Return .T.
