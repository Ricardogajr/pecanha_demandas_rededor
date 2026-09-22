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
Local _nM0 := 0
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
Local _aInfoEmp := {}
Local aCampos1 := {"M0_CODIGO","M0_CODFIL","M0_CGC","M0_CNAE","M0_DTRE","M0_NATJUR","M0_NOMECOM","M0_TPINSC","M0_FPAS"}
Local aCampos2 := {"M0_CODIGO","M0_CODFIL","M0_CGC","M0_CNAE","M0_DTRE","M0_NATJUR","M0_NOMECOM","M0_TPINSC","M0_FPAS","M0_ENDCOB","M0_COMPCOB","M0_BAIRCOB","M0_CIDCOB","M0_ESTCOB","M0_CEPCOB","M0_FILIAL"}
Local _aAllFil := FWLoadSM0( .T. , .F. )
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

TAM1 := 60 - LEN(ALLTRIM(FWSM0Util():GetSM0Data(,,{"M0_NOMECOM"})[1][2]))
//DBSELECTAREA( "SM0" )
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
       //DBSELECTAREA( "SM0" )
       //DBGOTOP()
	For _nM0 := 1 to Len(_aAllFil) //WHILE !EOF()
		_aInfoEmp := FWSM0Util():GetSM0Data(_aAllFil[_nM0][1],_aAllFil[_nM0][2],aCampos1) 
		CLINHA := _aInfoEmp[1][2]+";"+_aInfoEmp[2][2]+";"+_aInfoEmp[3][2]+";"+_aInfoEmp[4][2]+";"+DTOS(_aInfoEmp[5][2])+";"+_aInfoEmp[6][2]+";"+_aInfoEmp[7][2]+";"+STRZERO(_aInfoEmp[8][2],1,0)+";"+_aInfoEmp[9][2]
		FWrite(nHandle4,CLINHA+CRLF,132)
		_aInfoEmp := {}//SM0->(DBSKIP()) 
	Next _nM0 //END
	Fclose (nHandle4)                     

	//DBSELECTAREA( "SM0" )
	//DBGOTOP()
	For _nM0 := 1 to Len(_aAllFil) //WHILE !EOF()

		DbSelectArea("ZM0") 
		DbSetOrder(1)

		cFilAnt := xFilial("ZM0")
		_aInfoEmp := FWSM0Util():GetSM0Data(_aAllFil[_nM0][1],_aAllFil[_nM0][2],aCampos2) 
		cCodigo := _aInfoEmp[1][2]
		cCodFil := _aInfoEmp[2][2]
		If DbSeek(cFilial+cCodigo+cCodFil)
		  RecLock("ZM0",.F.)
		Else
		  RecLock("ZM0",.T.)
		  ZM0->ZM0_FILIAL  := cFilAnt
		  ZM0->ZM0_CODIGO  := cCodigo				  
		  ZM0->ZM0_CODFIL  := cCodFil
		Endif
		ZM0->ZM0_CGC    := _aInfoEmp[3][2]
		ZM0->ZM0_CNAE   := _aInfoEmp[4][2]
		ZM0->ZM0_DTRE   := _aInfoEmp[5][2]
		ZM0->ZM0_NATJUR := _aInfoEmp[6][2]
		ZM0->ZM0_NOMECO := _aInfoEmp[7][2]
		ZM0->ZM0_TPINSC := _aInfoEmp[8][2]
		ZM0->ZM0_FPAS   := _aInfoEmp[9][2]
		ZM0->ZM0_ENDCOB := _aInfoEmp[10][2]
		ZM0->ZM0_COMPCO := _aInfoEmp[11][2]
		ZM0->ZM0_BAIRCO := _aInfoEmp[12][2]
		ZM0->ZM0_CIDCOB := _aInfoEmp[13][2]
		ZM0->ZM0_ESTCOB := _aInfoEmp[14][2]
		ZM0->ZM0_CEPCOB := _aInfoEmp[15][2] 
		ZM0->ZM0_FILNOM := _aInfoEmp[16][2]		   
		ZM0->(MsUnlock())

		cMsg += "Carga Feita "+cCodigo+"/"+cCodFil+" "+CRLF

		FWrite(nHandle3,"GRAVANDO NA ZM0 "+cCodigo+"-"+cCodFil+CRLF,80)

		//DBSELECTAREA( "SM0" )
		_aInfoEmp := {} //SM0->(DBSKIP()) 
	Next _nM0 //END

	FWrite(nHandle3,"FIM DA CARGA NA ZM0 "+CRLF,80)
	Fclose (nHandle3)                     

	//DBSELECTAREA( "SM0" )
	//DBGOTOP()
	For _nM0 := 1 to Len(_aAllFil) //WHILE !EOF()
		_aInfoEmp := FWSM0Util():GetSM0Data(_aAllFil[_nM0][1],_aAllFil[_nM0][2],aCampos1) 
		CLINHA := _aInfoEmp[1][2]+";"+_aInfoEmp[2][2]+";"+_aInfoEmp[3][2]+";"+_aInfoEmp[4][2]+";"+DTOS(_aInfoEmp[5][2])+";"+_aInfoEmp[6][2]+";"+_aInfoEmp[7][2]+";"+STRZERO(_aInfoEmp[8][2],1,0)+";"+_aInfoEmp[9][2]
		FWrite(nHandle5,CLINHA+CRLF,132)
		//SM0->(DBSKIP()) 
	Next _nM0 //END
	Fclose (nHandle5)                     
	  
End Sequence    

If lSchedule
   RESET ENVIRONMENT 
Endif

Return 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
