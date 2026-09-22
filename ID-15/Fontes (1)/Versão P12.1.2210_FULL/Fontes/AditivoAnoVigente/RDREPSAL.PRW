#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"   
#include "PARMTYPE.CH"    
#INCLUDE "TOTVS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#include "topconn.ch"
#INCLUDE "RPTDEF.CH"
#Include 'RwMake.Ch'

#DEFINE cEol CHR(13)+CHR(10)

/*
 ativar parametro, existem 7 threds ativos, distribuidos 35000 registros entre os threads por execucao.
MV_XTPSALD    - preenchimento com varios tipos de saldo "1;2;3;4")
MV_XDIASAL    - dias para tolerancia dos calendários abertos em dias  60 preenchimento numerico 60
MV_XFILESL    - filiais que n�o ser�o consideradas no reprocessamento de saldo preenchimento "01010004|01310001|..."
MV_XFILSAL    - Processa o reprocessamento de saldo cont�bil por filial. preenchimento .T. / POR FILIAL
MV_XFOLLOG    - Pasta padr�o para o log da rotina , preenchimento \SIGADOC\LOG_REPROCESSAMENTO_SALDOS\
*/


User Function RDREPSAL()

 Local cValids := ""
 Local nForFilial    := 0
 Private cFilAtu   	:= ""
 Private cEmpAtu   	:= ""
 Private cEmpProc  	:= ""
 Private cFilProc  	:= "" 
 Private aRecnoSM0 	:= {}
 Private aProgs    	:= {}
 Private lSchedule 	:= IsBlind()
 Private _aFilias  	:= {}
 Private cDtini    	:= SUBS(DTOS(date()),1,6)+"01" 
 Private cDtFim    	:= SUBS(DTOS(date()),1,8)   

 //Private cEol      := chr(13)+chr(10)   
 Private nTotReg  	:= 0       
 Private _cPathRoot := "" //"\SIGADOC\LOG_REPROCESSAMENTO_SALDOS\"
 Private _cPath 	:= "" //"\SIGADOC\LOG_REPROCESSAMENTO_SALDOS\"+cDtFim+"\" 
 Private aArea0     	
 Private nCount := 0
 Private cAliasCTG := GetNextAlias()
 Private cAliasCT2 := GetNextAlias()
 //Private lRPC  
 //DEFAULT aParam := {"01","01010001"} // caso nao receba nenhum parametro
 //DEFAULT lRPC := MyIsBlind()

 //IF ( lRPC )

Private _cEmpConec := U_GetFilP()[1]
Private _cFilConec := U_GetFilP()[2]
Private oException
Private lInfinity  := .T.
Private nErro := 0
Private cOs 
Private aFilsProc := {}
Private cMVDiasSal := ""
Private cMV_FILESL := ""
Private nTotal := 1

Private cArqLog := ""
Private lBlocked := .F.
Private aAuxFil := {}
Private aCalBlq := {}
Private aCalMes := {}
Private aTodasFil :={}
Private aLogs     := {}
Private cHoraIni  := Time()
Private cHoraIniP := Time()
Private  cHoraFim
		
If	TCGetConn() < 0
    RpcSetType(3)
    //U_RpcSethtk(_cEmpConec, _cFilConec )
    RpcSetEnv(_cEmpConec,_cFilConec)
EndIf


_cPathRoot := Alltrim(SuperGetMV("MV_XFOLLOG",.F., "\LOG_REPROCESSAMENTO_SALDOS\"))
_cPath := _cPathRoot+cDtFim+"\" 

 Makedir(_cPathRoot)
 MakeDir(_cPath)

// #IFDEF TOP
 	SetTopType("A")
// #ENDIF 
 	
  aArea0 := fwGetArea()

  aAdd( aProgs, { "CTBA190" } )  
  aAdd( aProgs, { "RDREPSAL" } )  
  
  cMensagem := "Hora Inicio do Processamento :"+cHoraIni
  Aadd(aLogs, cMensagem) 
  //ADMGETFIL(lTodasFil,lSohFilEmp,cAlias,lSohFilUn,lHlp, lExibTela)
 
    cQry := " SELECT  CT2_FILIAL  "+cEol 
    cQry += " FROM "+ RetSqlName('CT2') + cEol
    cQry += " GROUP BY CT2_FILIAL "+cEol
 

    If Select(cAliasCT2) > 0 ; (cAliasCT2)->(DbCloseArea()) ; EndIf
    DbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry),cAliasCT2,.T.,.T.)

	cMV_FILESL :=  Alltrim(SuperGetMV("MV_XFILESL",.F., ""))
    While !(cAliasCT2)->(EOF())
        cFilCT2 := Alltrim((cAliasCT2)->CT2_FILIAL)
		If !(cFilCT2 $ alltrim(cMV_FILESL))
        	aAdd(aFilsProc,cFilCT2)
		EndIf 
		(cAliasCT2)->(dbSkip())
    EndDo 
  

//³ Calcula Tolerancia para data calendário aberto - inicialmente 60 dias|
 
  cMVDiasSal := SuperGetMV("MV_XDIASAL",.F., 60) // INICIAL 60 DIAS, VOU DIMINUIR PARA 0 para pegar o ultimo calend�rio(mais recente) aberto
  cDtIniTol  := SUBS(DTOS(date()),1,6)+"01"  //Tolerancia para Data Inicial 
 
  If cMVDiasSal > 0
  	cDtIniTol  := STOD(cDtIniTol)
  	cDtIniTol  := DaySub(cDtIniTol,cMVDiasSal)
  	cDtIniTol  := DTOS(cDtIniTol)
  ElseIf cMVDiasSal < 30
	  cDtIniTol := FirstDay(dDataBase)
	  cDtIniTol := cDtIniTol-1
	  cDtIniTol  := DTOS(cDtIniTol)
  EndIf 


cValids := SuperGetMV("MV_CTVBLOQ",.F.,"111")			/// Parametro para indicar quais ser�o as verifica��es de bloqueio efetuadas (DEFAULT TODAS CTO, CTG e CTP).


lValidCTO := ( Substr(cValids,1,1) == "1" ) /// 1� POSI��O VALIDACAO CTO (CtbMInUse(CTBXFUN))
lValidCTG := ( Substr(cValids,2,1) == "1" ) /// 2� POSI��O VALIDACAO CTG (VlDtCal(CTBA190))
lValidCTP := ( Substr(cValids,3,1) == "1" ) /// 3� POSI��O VALIDACAO CTP (CtbDtInUse(CTBXFUN))

/// Verifica Status de bloqueio no cadastro do calend�rio CTG (pela amarra��o das moedas)
	
	
cMVtpsaldo := Alltrim(SuperGetMV("MV_XTPSALD",.F., "1")) //preenchimento com varios tipos de saldo "1;2;3;4")
aTpSaldo  := Separa(cMVtpsaldo, ';', .T.)

lProcFil := SuperGetMV("MV_XFILSAL",.F., .T.) // processa por filial se verdadeiro

//³ Carrega array auxiliar de filiais        
For nForFilial := 1 to Len(aFilsProc)
		cFilAnt:=aFilsProc[nForFilial]
		// Adiciona filial no array auxiliar
        cQry := " SELECT  CTG_DTINI  "+cEol 
        cQry += " FROM "+ RetSqlName('CTG') + cEol
        cQry += " WHERE CTG_STATUS = '1' "+cEol // 1 = Aberto
        cQry += "    AND CTG_FILIAL = '"+cFilAnt+"'"+cEol 
		cQry += "    AND CTG_DTINI >= '"+cDtIniTol+"'"+cEol
		cQry += "    AND CTG_DTINI <= '"+cDtFim+"'"+cEol
		cQry += "    AND ROWNUM = 1 "+cEol
		cQry += " ORDER BY CTG_DTINI "+cEol
		
        If Select(cAliasCTG) > 0 ; (cAliasCTG)->(DbCloseArea()) ; EndIf
	    DbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry),cAliasCTG,.T.,.T.)

        If Select(cAliasCTG) > 0 
           cDtini:= (cAliasCTG)->CTG_DTINI
        EndIf 
		
		cStatBlq	:= SuperGetMV("MV_CTGBLOQ",.F.,"234")	/// INDICA OS STATUS DE CALENDARIO QUE N�O PERMITEM REPROCESSAR
		If Empty(cStatBlq)
			cStatBlq := "234"
		EndIf 
		
		dDtini := STOD(cDtini)
		dDtFim := STOD(cDtFim)
	
		dDataIni 	:= FirstDay(dDataBase) //Data Inicial dentro M�s
		dDataFim 	:= LastDay(dDataBase)  //Data Final dentro M�s

		//VlDtCal(dDtIni,dDtFim,nMoedas,cQualMoeda,"234", lShowMsg,cTpSaldo )
		If VlDtCal(dDtini,dDtFim,1,"01",cStatBlq,.F.,'1')	/// VALIDA O STATUS DO(S) CALEND�?RIOS PARA O PROCESSAMENTO
            aAdd(aAuxFil,cFilAnt)
			aAdd(aTodasFil,cFilAnt)
        ElseIf VlDtCal(dDataIni,dDataFim,1,"01",cStatBlq,.F.,'1') 
			aAdd(aCalMes,cFilAnt)
			aAdd(aTodasFil,cFilAnt)
            cMensagem := "Filial Processada, somente o m�s! calend�rio anterior bloqueado"
			Aadd(aLogs, cMensagem) 
			//U_GConout(cMensagem,nTotal, 0,cFilAnt)
		    //GeraConout(cMensagem, nTotal, nErro, cFilial)
		Else 
			aAdd(aCalBlq,cFilAnt)
			nErro++
			cMensagem := "Filial N�o Processada, Calend�rio Fechado, Filial : "+cFilAnt
           	Aadd(aLogs, cMensagem) 
        EndIf

		If lProcFil
			If Len(aCalMes) >0 
				U_RDReproc(aCalMes /*Array com Filiais*/,/*Data Inicio*/,/*Data Fim*/,aTpSaldo/*Tipo de Saldo*/,.T./*Processa M�s Corrente*/) //Filiais com calend�rio aberto meses anteriores
			Elseif Len(aAuxFil) >0 
				U_RDReproc(aAuxFil/*Array com Filiais*/,dDtini/*Data Inicio*/,dDtFim/*Data Fim*/,aTpSaldo/*Tipo de Saldo*/,.F./*Processa M�s Corrente*/) //Filiais com calend�rio aberto meses anteriores
			EndIf 
				aCalMes := {}
				aAuxFil := {}
		EndIf 

		nTotal ++
Next nForFilial

If !lProcFil 
	U_RDReproc(aTodasFil /*Array com Filiais*/,/*Data Inicio*/,/*Data Fim*/,aTpSaldo/*Tipo de Saldo*/,.T./*Processa M�s Corrente*/) //Filiais com calend�rio aberto meses anteriores
EndIf 

If Select(cAliasCT2) > 0 ; (cAliasCT2)->(DbCloseArea()) ; EndIf
If Select(cAliasCTG) > 0 ; (cAliasCTG)->(DbCloseArea()) ; EndIf

cHoraFim := Time()
cMensagem := "Hora Fim do Processamento :"+cHoraFim
Aadd(aLogs, cMensagem) 

U_GConout(cMensagem,nTotal, nErro,cFilAnt)
U_fGeraLog(aLogs,_cPath)
//RDZip(_cPath,_cPathRoot,dDtFim)

Return 

/*
    Programa    : RDCTBSC.prw
    Funcao      : RDzip
    Autor       : Thiago Góes 
    Data        : 29/03/2019
    Uso         : Criar arquivo compactado dos relatorios gerados, posteriormente apaga pasta criada
*/

Static Function RDZip (_cPath,_cPathRoot,cDtFim)

 Local aFiles   := {} // O array receberá os nomes dos arquivos e do diretório
 Local aSizes   := {} // O array receberá os tamanhos dos arquivos e do diretorio
 Local aArqCsv  := {}
 Local nX,nY
 Local cExtens 	:= ".CSV"
 Local cArqCsv  := " "
 Local cArqZip  := _cPathRoot+"\"+SUBS(DTOS(date()),1,8)+"_"+SUBSTR(TIME(), 1, 2) +"h"+SUBSTR(TIME(), 4, 2)+".zip"    
 
 ADir(_cPath+"*.CSV", aFiles, aSizes)
 // Exibe dados dos arquivos
 nCount := Len( aFiles )

 If nCount == 0 
	Return
 EndIf 
 
 For nY:= 1 to nCount
 	cArqCsv := _cPath + aFiles[nY]
 	AADD( aArqCsv, cArqCsv) 
 Next nY
 
 nret := FZip(cArqZip,aArqCsv)
 
 if nret!=0
   conout("N�o foi possível criar o arquivo zip")
 else
   conout("Arquivo zip criado com sucesso")
 endif             
 
 nCount := Len( aArqCsv )
 
 For nX := 1 to nCount
   Ferase( aArqCsv[nX] ) 
 Next nX

 DirRemove( _cPath )

Return         

/*
    Programa    : RDCTBSC.prw
    Funcao      : MyIsBlind
    Autor       : Thiago Góes 
    Data        : 29/03/2019  
    Uso         : Verificar Blind
*/
 Static Function MyIsBlind()
  Local oWnd    := GetWndDefault()  
   If  IsBlind() .or. (oWnd == NIL  .and.  Select("SM0") == 0 )
   		lRet := .T.
   EndIf
 Return(lRet)

/*/{Protheus.doc} RtGetEFPad
Informa empresa e filial padrÃƒÂ£o para conexao e execuÃƒÂ§ÃƒÂ£o de serviÃƒÂ§os agendados, casos em que uma unica empresa pode conectar e
serÃƒÂ¡ suficiente.
@author Thiago GÃƒÂ³es
@since 25/03/2020
@version 1.0
@return ${return}, ${return_description}
@Example 
Local _cEmpConec 	:= U_GetFilP()[1]
Local _cFilConec	:= U_GetFilP()[2]
@type function
/*/

User Function GetFilP()
Return {"01","01010001"}


User Function RDReproc(aAuxFil,dInicio,dFim,aTpSaldo,lMesCorr)
Local nForFilial := 0
Local nTipoSaldo := 0
Local cFilIni    := ""
Local cFilFim    := ""
Local aAreaAnt   := fwGetArea()
Local lRet       := .T.
DEFAULT dInicio 	:= FirstDay(dDataBase)
DEFAULT dFim 	:= LastDay(dDataBase)
//DEFAULT cFilDe		:= cFilAnt
//DEFAULT cFilAte		:= cFilAnt
//Local lReproc    := AllTrim(SuperGetMv('MV_A330190',.F.,"S")) == "S"

Default aTpSaldo := {"1"}  // Sempre processar saldo tipo 1 - Real
Default aAuxFil  := {}

If lMesCorr 
	If dDataBase == dInicio
		dFim:= dInicio
		dInicio:= dInicio-1
		dInicio:= FirstDay(dDataIni)
	EndIf 
EndIf 
		
//If lReproc
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena filiais processadas                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ASORT(aAuxFil,,,{ |x, y| x < y })
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for base compartilhada assume intervalo de filiais |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CT2")
	If Empty(xFilial("CT2"))
		// Reprocessamento contabil base compartilhada
		For nTipoSaldo:=1 to Len(aTpSaldo)
			//cHoraIni := Time()
			If CTBA190(.T.,dInicio,dFim,"  ","ZZ",aTpSaldo[nTipoSaldo],.F.,"  ")
				 cMensagem := "Recalculo de saldos, Finalizado com sucesso para todas as Filiais"
			EndIf
			nTotal ++
			//cHoraFim := Time()
		Next nTipoSaldo
       
        //U_GConout(cMensagem,nTotal, nErro,cFilAnt)
		Aadd(aLogs, cMensagem) 
	Else
		//³ Realiza o reprocessamento das filiais De/Ate |

		If Len(aAuxFil) == 1
			// Reprocessamento contabil apenas uma filial
			For nTipoSaldo:=1 to Len(aTpSaldo)
				//cHoraIni := Time()
				If CTBA190(.T.,dInicio,dFim,aAuxFil[1],aAuxFil[1],aTpSaldo[nTipoSaldo],.F.,"01")
					cMensagem := "Recalculo de saldos, Finalizado com sucesso, Para a Filial : "+aAuxFil[1]
					Aadd(aLogs, cMensagem)
				Else 	
					cMensagem := "Recalculo de saldos, n�o executado para a Filial : "+aAuxFil[1]
					Aadd(aLogs, cMensagem)
            	EndIf
				nTotal ++
				//cHoraFim := Time()
			Next nTipoSaldo
            
            //U_GConout(cMensagem,nTotal, nErro,cFilAnt)
			Aadd(aLogs, cMensagem) 
		Else
			// Reprocessamento contabil com varias filiais
			For nForFilial := 1 To Len(aAuxFil)
				If nForFilial == 1
					cFilIni := aAuxFil[nForFilial]
				Else
					If Soma1(aAuxFil[nForFilial-1]) # aAuxFil[nForFilial]
						For nTipoSaldo:=1 to Len(aTpSaldo)
							If CTBA190(.T.,dInicio,dFim,cFilIni,cFilFim,aTpSaldo[nTipoSaldo],.F.,"  ")
								cMensagem := "Recalculo de saldos, finalizado para as Filial de : "+cFilIni+ " At� Filial : "+cFilFim
								Aadd(aLogs, cMensagem)
							Else 
								cMensagem := "Recalculo de saldos, n�o executado para as Filial de : "+cFilIni+ " At� Filial : "+cFilFim
								Aadd(aLogs, cMensagem)
							EndIf 
						Next nTipoSaldo
						cFilIni := aAuxFil[nForFilial]
				    ElseIf Len(aAuxFil) == nForFilial
						For nTipoSaldo:=1 to Len(aTpSaldo)
						    If CTBA190(.T.,dInicio,dFim,cFilIni,aAuxFil[nForFilial],aTpSaldo[nTipoSaldo],.F.,"  ")
								cMensagem := "Recalculo de saldos, finalizado para as Filial de : "+cFilIni+ " At� Filial : "+cFilFim
								Aadd(aLogs, cMensagem)
							Else
								cMensagem := "Recalculo de saldos, n�o executado para as Filial de : "+cFilIni+ " At� Filial : "+cFilFim
								Aadd(aLogs, cMensagem)
							EndIf 
						Next nTipoSaldo
				    EndIf
			    EndIf 
				cFilFim := aAuxFil[nForFilial]
			Next nForFilial
		EndIf	
        cMensagem := "Recalculo de saldos, Finalizado com sucesso"
        nTotal ++
	EndIf
//EndIf
fwRestArea(aAreaAnt)
Return lRet


//User Function GConout(cMensagem,nTotal,nErro,cFilial)

User Function GConout(cMensagem,nTotal,nErro,cFil)

Local cMsg := ""
Local aInfo := {}
Local nPos := 0
Local _cEmpConec := U_GetFilP()[1]
Local _cFilConec := U_GetFilP()[2]

Default cMensagem := ""
Default nTotal := 0
Default nErro  := 0
	
	If	TCGetConn() < 0
		RpcSetType(3)
		RpcSetEnv(_cEmpConec,_cFilConec)
	EndIf

	cMsg := Replicate('=',128) 
	Conout(cMsg)
	
	If nTotal >0
		Conout("  Total de registros processados: "+OemToAnsi(cValtoChar(nTotal)))
	EndIf
	If nErro > 0 
		Conout("  Total de registros incorretos: "+OemToAnsi(cValtoChar(nErro)))
	EndIf
	
	cMsg := " "
	Conout(cMsg)
	cMsg := "  Dados Ambiente"
	Conout(cMsg)
	cMsg :=  "--------------------" 
	Conout(cMsg)
	cMsg := cEmpAnt + "/" + cFil 
	Conout("  Empresa / Filial...: " +OemToAnsi(cMsg))
	//cMsg := Capital( AllTrim( SM0->M0_NOMECOM ) ) 
    cMsg := Capital( AllTrim( FWSM0Util():GetSM0Data( cEmpAnt , cFil , { "M0_NOMECOM" } ))) //Retorna o M0_NOMECOM do grupo 01
	Conout("  Nome Empresa.......: " +OemToAnsi(cMsg))
	//cMsg :=  Capital( AllTrim( SM0->M0_FILIAL ) ) 
    cMsg := Capital( AllTrim( FWSM0Util():GetSM0Data( cEmpAnt , cFil , { "M0_FILIAL" } ))) //Retorna o M0_FILIAL do grupo 01
	Conout("  Nome Filial........: " +OemToAnsi(cMsg))
	cMsg :=  DtoC( dDataBase ) 
	Conout("  DataBase...........: " +OemToAnsi(cMsg))
	cMsg :=  DtoC( Date() )  + " / " + Time() 
	Conout("  Data / Hora Inicio.: " +OemToAnsi(cMsg))
	cMsg := GetEnvServer()  
	Conout("  Environment........: " +OemToAnsi(cMsg))
	cMsg :=  GetSrvProfString( "StartPath", "" ) 
	Conout("  StartPath..........: " +OemToAnsi(cMsg))
	cMsg :=  GetSrvProfString( "RootPath" , "" ) 
	Conout("  RootPath...........: " +OemToAnsi(cMsg))
	cMsg :=  GetVersao(.T.) 
	Conout("  Versão.............: " +OemToAnsi(cMsg))
	cMsg :=  __cUserId + " " +  cUserName 
	Conout("  Usuário TOTVS .....: " +OemToAnsi(cMsg))
	cMsg :=  GetComputerName() 
	Conout("  Computer Name......: " +OemToAnsi(cMsg))
	
	aInfo   := GetUserInfo()
	If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
		Conout(" " )
		cMsg := "  Dados Thread" 
		Conout(cMsg)
		cMsg := "  --------------------" 
		Conout(cMsg)
		cMsg :=   aInfo[nPos][1] 
		Conout("  Usuario da Rede....: "+OemToAnsi(cMsg))
		cMsg :=  aInfo[nPos][2] 
		Conout("  Estacao............: " +OemToAnsi(cMsg))
		cMsg :=  aInfo[nPos][5] 
		Conout("  Programa Inicial...: " +OemToAnsi(cMsg))
		cMsg :=  cMensagem 
		Conout("  Programa Executado...: " +OemToAnsi(cMsg))
		cMsg :=  aInfo[nPos][6] 
		Conout("  Environment........: " +OemToAnsi(cMsg))
		cMsg :=  AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) 
		Conout("  Conexao............: " +OemToAnsi(cMsg))
	EndIf
	
	cMsg := " "
	Conout(cMsg)
	cMsg := DTOC(Date())+" - "+Time()
	Conout("Fim da Rotina: "+OemToAnsi(cMsg))

Return

User Function fGeraLog(aLogs, cDiretorio)
Local nLog
Local cArqLog
Local cNomeArq := "log_"+DTOS(dDataBase)+"_"+Time()+".csv"

Default cDiretorio := "\_ALOGS\"


Makedir(cDiretorio)

cNomeArq := cDiretorio+cNomeArq

cArqLog := replace(STRTRAN(cNomeArq,".csv","")+"_"+DTOS(date())+".csv",":","")

If Len(aLOGs) > 0
    nHdlLog := FCREATE(cArqLog, 0)
    If nHdlLog >= 0
        For nLOG := 1 to  Len(aLOGs)
            FWRITE( nHdlLog,aLOGs[nLOG]+cEol)
        Next nLOG
    EndIf
    FCLOSE(nHdlLog)
EndIf

//fClose( nHdlLog )

//shellExecute( "Open", "C:\Windows\System32\notepad.exe", cArqLog, "C:\", 1 )
Return 
