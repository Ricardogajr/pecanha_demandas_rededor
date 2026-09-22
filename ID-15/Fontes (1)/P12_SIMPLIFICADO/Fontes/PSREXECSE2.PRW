#include "PROTHEUS.CH"
#include "TCBROWSE.CH"
#include "fileio.ch"
#Include "TopConn.ch"
#INCLUDE "TRYEXCEPTION.CH"

#DEFINE C_CRLF     	CHR(13) + CHR(10)
#DEFINE N_BUF_SIZE 	1024

#DEFINE C_KEYLOG	"SE2_EXAUTO"

#DEFINE F_NAME	1
#DEFINE F_SIZE	2
#DEFINE F_DATE	3
#DEFINE F_TIME	4
#DEFINE F_ATT	5

#DEFINE N_PacketRecords 150

#DEFINE C_ROTINA "FINA050"

#DEFINE GLB_LOG_FILE   "cLogFile"
#DEFINE GLB_TAB_ALIAS  "cTabAlias"
#DEFINE GLB_REG_TOT    "Tot"+STRTRAN(SerialNumber('C:'),'-') //Quantidade total de registros.
#DEFINE GLB_REG_ERR    "Err"+STRTRAN(SerialNumber('C:'),'-') //Quantidade de registros com erros.
#DEFINE GLB_SUSPEND    "Suspend"+STRTRAN(SerialNumber('C:'),'-') //Se "1", processamento interrompido.
#DEFINE GLB_QZ3_RECNO  "QZ3Recno"+STRTRAN(SerialNumber('C:'),'-') //Recno da SZ2 atual/corrente...
#DEFINE GLB_E2_XMIGLT  "E2_XMIGLT"+STRTRAN(SerialNumber('C:'),'-') //Lote da carga

#xtranslate bSetGet(<uVar>)       =>  {|u| If(PCount() == 0, <uVar>,<uVar> := u)}

User Function RExecSE2(cAlias,cDirImp)
	Local aArea        := GetArea()
	Local cTabAlias    := TabAlias(UPPER(AllTrim(QZ1->QZ1_DESTIN)))
	Local cTempPath   := StaticCall(RDILIB02,GetTmpMigra)
	Local cSqlLdr 	   := StaticCall(RDILIB02,GetCnxLdr)
	Private cNomeArq  := cTabAlias + DToS(DDatabase) + STRTRAN(TIME(),":","")
	Private cArqCTL   := cTempPath + cNomeArq + ".ctl"
	Private cArqBAT   := cTempPath + cNomeArq + ".bat"
	Private cFileData := cDirImp
	Private nHdlCTL   := 0
	Private nHdlBAT   := 0
	Private cTempTab  := ""
	Private cSequence := ""
	Private aCpos	  := {}
	Private cStatLog  := "OK"
	Private cPathTXT  := Left(cFileData,RAT("\",cFileData))
	Private nNumLote    := GetMV('FS_RDI002')
	Private lIsFile   := .T.
	Private CUSERNAME 		:= "INTNF"

	Private cCodProc    := AllTrim(QZ1->QZ1_CODIGO)
	//Private cSourcePath := Left(AllTrim(QZ1->QZ1_DIRIMP),RAT("\",AllTrim(QZ1->QZ1_DIRIMP)))
	Private cSourcePath := cDirImp
	//Private aFiles      := StaticCall(IMPTAB,fDirectory,cSourcePath,TabAlias()+"*.TXT",.T.)
	Private aFiles      := {}
	Private oProcess    := Nil
	Private cSeparator  := ";"
	Private cFileName   := ""
	Private aUnique     := GetUnique(TabAlias())
	Private cTabDesc    := FWX2Nome( TabAlias() )


	If  UPPER(Right(cFileData,4)) == ".TXT"
		aFiles := fDirectory(cPathTXT,RetFileName(cFileData)+".TXT") //Directory(cPathTXT)
	ElseIf StaticCall(RDILIB02,fExistDir,cPathTXT)
		aFiles := fDirectory(cPathTXT,Upper(Alltrim(cTabAlias))+"*.TXT")
		lIsFile := .F.
	Else
		MsgStop("Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar...","Pasta Não Encontrada"+Chr(13)+cPathTXT)
	EndIf


/*

	If ! StaticCall(RDILIB02,fMkWrkDir,cTempPath)
		return .F.
	EndIf
	
	If Empty(cSqlLdr)
	   return .F.
	Endif
	
	If  UPPER(Right(cFileData,4)) == ".TXT"
        aArqsTXT := fDirectory(cPathTXT,RetFileName(cFileData)+".TXT") //Directory(cPathTXT)
	ElseIf StaticCall(RDILIB02,fExistDir,cPathTXT)
        aArqsTXT := fDirectory(cPathTXT,Upper(Alltrim(cAliTab))+"*.TXT")
        lIsFile := .F.
	Else
        MsgStop("Sr. Usuário: "+Upper(Alltrim(cUserName))+Chr(13)+" Favor Verificar...","Pasta Não Encontrada"+Chr(13)+cPathTXT)
	EndIf
    
	If Empty(aArqsTXT)
        MsgStop("Não há arquivos para serem processados! Verifique.")
        Return .F.
	Endif
   */

	If Empty(aFiles)
		MsgStop("Não há arquivos para serem processados! Verifique.")
		Return .F.
	Endif

	Reset()

	oProcess := MsNewProcess():New( { | lEnd | lRet := Process(@oProcess,@lEnd) },;
		"Dados da Origem", "Aguarde, preparando os dados...", .F. )
	oProcess:Activate()

	Reset()

	RestArea(aArea)

return .T.

	***********************
Static Function Reset()
	***********************
	ClearGlbValue(GLB_LOG_FILE)
	ClearGlbValue(GLB_TAB_ALIAS)
	ClearGlbValue(GLB_REG_TOT)
	ClearGlbValue(GLB_REG_ERR)
	ClearGlbValue(GLB_SUSPEND)
	ClearGlbValue(GLB_QZ3_RECNO)
	ClearGlbValue(GLB_E2_XMIGLT)
return .T.


	**************************************
Static Function Process(oProcess,lEnd)
	**************************************
	Local nX, nY      := 0
	Local cCodFil     := ""
	Local aHeader     := {}
	Local aRows       := {}
	Local aFiliais    := {}
	Local aStruct     := {}
	Local nHandle     := 0
	Local bOpen       := {|| nHandle := OpenFile(cFileName,@cSeparator,@aHeader,@aStruct) }
	Local nGerLinha   := 0 //Total de Linhas dos arquivos TXT's - no caso de haver mais de um arquivo p/lote.
	Local nTotLinha   := 0 //Total de Linhas do arquivo TXT
	Local nRecInvalid := 0 //Linhas rejeitadas durante a leitura do TXT
	Local nGerSave    := 0
	Local nTotSave    := 0 //Total de linhas salvas/processadas com sucesso.
	Local oProcess1   := nil
	Local aAreaQZ3    := QZ3->(GetArea())
	Local cXMigLt     := ""

	PutMv("FS_RDI002",++nNumLote)

	cXMigLt := DToS(Date()) + " " + Time() + " " + Strzero(nNumLote,10)
	SetGlb(GLB_E2_XMIGLT,cXMigLt)

	Aeval(aFiles,{|x| ASize(x,Len(x)+1) })

	oProcess:SetRegua1(Len(aFiles))

	For nX := 1 To Len(aFiles)

		ProcessMessages()

		If lEnd
			MsgStop("Processamento interrompido pelo usuário!")
			Exit
		Endif

		nTotLinha := aFiles[nX,7]
		nTotSave  := 0
		cFileName := aFiles[nX,6]

		oProcess:IncRegua1('Processando arquivo "'+cValToChar(nX)+"/"+cValToChar(Len(aFiles))+'"...')

		AddLogInf( Replicate("*",100))
		AddLogInf( 'Processando o arquivo "{1}"...' , {aFiles[nX,F_NAME]})
		AddLogInf( Replicate("*",100))

       /* Obtém os dados do arquivo */
		aHeader := {}
		aStruct := {}

		MsgRun('Obtendo informações do arquivo...',"Aguarde...",bOpen)

		If ( nHandle == -1 )
			Loop
		Endif

		aFiles[nX,8] := TabAlias()+"-"+FWTimeStamp(3,dDatabase,Time())+FWTimeStamp(4,dDatabase,Time())

		RecLock("QZ3",.t.)
		QZ3->QZ3_UKEY    := aFiles[nX,8]
		QZ3->QZ3_NUMLOT := Strzero(nNumLote,10)
		QZ3->QZ3_CODPRC  := QZ1->QZ1_CODIGO
		QZ3->QZ3_CODTAB  := TabAlias()
		QZ3->QZ3_DATAIN := dDataBase
		QZ3->QZ3_HORAIN := time()
		QZ3->QZ3_FRONT   := Upper(Subs(Alltrim(aFiles[nX,1]),At("_",Alltrim(aFiles[nX,1]))+1,At("_",Subs(Alltrim(aFiles[nX,1]),At("_",Alltrim(aFiles[nX,1]))+1))-1))
		QZ3->QZ3_ARQUIV := Upper(Alltrim(aFiles[nX,1]))
		QZ3->QZ3_DATATX := aFiles[nX,3]
		QZ3->QZ3_HORATX := aFiles[nX,4]
		QZ3->QZ3_CODUSE := Alltrim(cUserName)
		QZ3->QZ3_AMBIEN := Alltrim(GetEnvServer())
		QZ3->QZ3_TIMSTA := FWTimeStamp(2,Date(),Time())
		QZ3->QZ3_VALIDA  := "S"
		QZ3->QZ3_MAXREC  := StaticCall( IMPTAB,GetMaxRecno,TabAlias() )
		QZ3->QZ3_URI     := GetLogURI()

		If ( QZ3->(FieldPos("QZ3_XMIGLT")) > 0 )
			QZ3->QZ3_XMIGLT := cXMigLt
		Endif

		QZ3->(MsUnLock())

		SetGlb(GLB_QZ3_RECNO,QZ3->(Recno()))

		AddLogInf( 'Nome qualificado			{1}', {aFiles[nX,6]})
		AddLogInf( 'Data						{1}', {aFiles[nX,F_DATE]})
		AddLogInf( 'Hora						{1}', {aFiles[nX,F_TIME]})
		AddLogInf( 'Tamanho em bytes			{1}', {aFiles[nX,F_SIZE]})
		AddLogInf( 'Quantidade de registros	{1}', {nTotLinha})
		AddLogInf( Replicate("=",100))

		aRows  := ReadData(oProcess,lEnd,nHandle,aHeader,aStruct,aFiliais,nTotLinha)

		If Empty(aRows)
			RecLock("QZ3",.f.)
			QZ3->QZ3_TOTLIN := nTotLinha
			QZ3->QZ3_TOTGRA := 0
			QZ3->QZ3_DATAFI := Date()
			QZ3->QZ3_HORAFI := Time()
			QZ3->QZ3_STATLO := "LOG"
			QZ3->(MsUnLock())

			Loop
		Endif

		nRecInvalid := nTotLinha - Len(aRows)

		aSort( aFiliais,,, { |x,y| x[1] < y[1] } )
		aSort( aRows   ,,, { |x,y| x[1,2] < y[1,2] } )

		oProcess1 := MsNewProcess():New( { | lEnd | Gravar(@oProcess1,@lEnd,aFiliais,aRows) },;
			FWX2Nome( TabAlias() ), "Aguarde, gravando...", .F. )
		oProcess1:Activate()

		nTotLinha := Len(aRows)

		nTotSave := nTotLinha - ( nRecInvalid + GetNum(GLB_REG_ERR) )

		RecLock("QZ3",.f.)
		QZ3->QZ3_TOTLIN := nTotLinha
		QZ3->QZ3_TOTGRA := nTotSave
		QZ3->QZ3_DATAFI := Date()
		QZ3->QZ3_HORAFI := Time()
		QZ3->QZ3_STATLO := If(nTotLinha == nTotSave,"OK","LOG")
		QZ3->(MsUnLock())

		nGerLinha += nTotLinha
		nGerSave  += nTotSave
	Next nX

	RestArea(aAreaQZ3)

return nil

	****************************************************
Static Function Gravar(oProcess,lEnd,aFiliais,aRows)
	****************************************************
	Local nR        := 0
	Local nPack     := N_PacketRecords
	Local aPack     := {}
	Local nTotFil   := Len(aFiliais)
	Local nTotReg   := Len(aRows)
	Local nLenTot   := Len( cValToChar( nTotReg ) )
	Local cCodFil   := ""
	Local cNewFil   := ""
	Local bExec     := {|| ChangeEmp(cCodFil,aPack) }

	oProcess:SetRegua1(nTotFil)
	oProcess:SetRegua2(nTotReg)

	SetGlb(GLB_REG_ERR,0)

	For nR := 1 To nTotReg

		oProcess:IncRegua2( 'Empacotando o registro "'+StrZero(nR-1,nLenTot)+"/"+cValToChar(nTotReg)+'"...' )

		//cNewFil := MGSM0DP1("",aRows[nR][1,2])
		cNewFil := aRows[nR][1,2]
		If cCodFil <> cNewFil
			If ! Empty(aPack)
				MsgRun('Executando FINA050 para Filial "{1}"...',"Aguarde...", bExec )
				aPack := {}
			Endif
			cCodFil := cNewFil
			oProcess:IncRegua1( FWFilialName(,cCodFil,1) )
		ElseIf ! Empty(aPack) .And. ( Mod(Len(aPack),nPack) == 0 )
			MsgRun('Executando a rotina automática FINA050...',"Aguarde...", bExec )
			aPack := {}
		Endif

		Aadd(aPack,aRows[nR])

	Next nR

	If ! Empty(aPack)
		MsgRun('Executando a rotina automática FINA050...',"Aguarde...", bExec )
	Endif

return nil

	*****************************************
Static Function ChangeEmp( cFil, aDados )
	*****************************************
	Local lRpcSet   := !( cFil == cFilAnt )
	Local lRet      := .F.
	Local cInterNet := __cInterNet
	Local lPYME     := __lPYME
	Local oWnd      := If(Type("oMainWnd")=="O",oMainWnd,nil)
	Local lSuspend  := .F.

	If lRpcSet
		oMainWnd    := Nil
		__cInterNet := Nil
		__lPYME     := .F.
	Endif

	If !( lRpcSet )
		lRet := U_RDIExecA(cEmpAnt,cFil,lRpcSet,aDados,aUnique,lSuspend,cCodProc)
	else
		lRet := StartJob("U_RDIExecA" ,GetEnvServer(),.T.,cEmpAnt,cFil,lRpcSet,aDados,aUnique,lSuspend,cCodProc)
	endif

	If lRpcSet
		oMainWnd    := oWnd
		__cInterNet := cInterNet
		__lPYME     := lPYME
	Endif

Return( lRet )

	***********************************************************************
User function RDIExecA(cEmp,cFil,lRpcSet,aDados,aKey,lSuspend,cCodProc)
	***********************************************************************
	Local lRet        := .T.
	Local nX          := 0
	Local nCount      := 0
	Local aLog        := {}
	Local aFormulas   := {}
	Local nPosNum     := 0
	Local bErrorBlock := ErrorBlock( {|e|lErros := .T., ExAutError(GetKey(aKey,aRow),e:Description) } )
	Local nErros      := 0
	Local lErros      := .F.
	Local bSuspend    := {|| lSuspend  }
	Local nDados      := Len(aDados)
	Local nRecnoQZ3   := GetNum(GLB_QZ3_RECNO)
	Local cKey        := ""
	Local nKey        := 0
	Local cXMigLt     := GetGlbValue(GLB_E2_XMIGLT)
	Local aRow        := {}

	Private lMsHelpAuto    := .T.
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Public ___XMIGLT       := nil
	Public __dDataEmis1 := SToD("")
	
	Default lRpcSet := .F.

	If lRpcSet
		BEGIN SEQUENCE
			RpcSetType( 3 )
			RpcSetEnv( cEmp, cFil )
		END SEQUENCE
	Endif

	ErrorBlock(bErrorBlock)

	// If (cEmp != cEmpAnt) .OR. (cFil != cFilAnt)
	//    AddLogErr('Não foi possível carregar o ambiente da empresa "{1} - {2}".',{cEmpAnt,cFil,FWFilialName(cEmpAnt,cFil,2)})
	//    Inc(GLB_REG_ERR,nDados)
	//    return .F.
	// Endif

	AddLogInf(Replicate("=",100),nil)
	AddLogInf('Processando  "{3}" registro(s), Empresa "{1} - {2}".',{cFil,FWFilialName(,cFil,2),Len(aDados)})
	AddLogInf(Replicate("=",100),nil)

	If ( QZ3->(Recno()) != nRecnoQZ3 )
		QZ3->(DbGoTo(nRecnoQZ3))
	Endif

	For nX := 1 To nDados

		If Eval(bSuspend)
			Exit
		Endif

		aRow := aDados[nX]

		If ! SetQZ2(aFormulas,aRow,cCodProc)
			nPosNum := AScan(aRow,{|x| x[1] == "E2_NUM"})
			AddLogErr('Erro ao aplicar as fórmulas ao documento "{1}", filial "{2}"!',{aRow[nPosNum,2],cFilAnt})
			AddLogErr(Replicate("-",100),nil)

			LogQZ4(cFilAnt,{FmtStr('Erro ao aplicar as fórmulas ao documento "{1}", filial "{2}"!',{aRow[nPosNum,2],cFilAnt})},GetKey(aKey,aRow))

			lErros := .T.
			nErros++
			Loop
		Endif

		aRow := FWVetByDic( aRow, TabAlias(), .F., 1 )
		//Situação do título no TXT (ANTES de qualquer ajuste)
		lPending := IsOpen(aRow)
		//
		aSaveRow := AClone(aRow) //aRow SEM AJUSTES.

		nPosNum := AScan(aRow,{|x| x[1] == "E2_NUM"})

		aSaveFlds := OpenTit(aRow)
		cNatSImp    := SuperGetMV("MV_RDI020",.T.,"20100699") //Natureza de títulos Sem Impostos.
		cNatCImp    := SuperGetMV("MV_RDI021",.T.,"20100697") //Natureza de títulos Com Impostos.
		cTpXServ    := SuperGetMV("MV_RDI022",.T.,"100000002") //Código do "Tipo Serviço" (E2_XTPSERV) para títulos com ISS (E2_ISS > 0)

		//If lPending
		If lPending .And. ( GetVRow("@TOTIMPOSTOS",aRow) > 0 )

			SetVRow("E2_NATUREZ",cNatCImp,aRow)

			//Para títulos com ISS, define o código do tipo do serviço (E2_XTPSERV)
			If Empty(GetVRow("E2_XTPSERV",aRow))
				SetVRow("E2_XTPSERV",cTpXServ,aRow)
			Endif
			//

		Else
			SetVRow("E2_NATUREZ",cNatSImp,aRow) //Títulos liquidados NÃO DEVEM gerar TX's
		Endif
		//Endif

		RemoveFlds(aRow)

		___XMIGLT       := cXMigLt
		dDataEmis1 := aRow[aScan(aRow,{|x| AllTrim(x[1]) == "E2_EMIS1"})][2]
		__dDataEmis1 	:= if(Empty(dDataEmis1),Nil,dDataEmis1)
		lMsErroAuto := .F.

		cUserBkp := CUSERNAME
		CUSERNAME := "Integrador"
		
        nPosFor := aScan(aRow,{|r| r[1] == "E2_FORNECE"})
		nPosLoj := aScan(aRow,{|r| r[1] == "E2_LOJA"})

		lAtualizou := .F.
		aAreaSA2 := GetArea()
		DbSelectArea("SA2")
		if DbSeek(xFilial("SA2")+PadR(aRow[nPosFor][2], TamSx3("E2_FORNECE")[01])+PadR(aRow[nPosLoj][2], TamSx3("E2_LOJA")[01]))
			nRecForn := SA2->(Recno())
			if SA2->A2_MSBLQL == "1"
				lAtualizou := .T.
				Reclock("SA2", .F.)
				SA2->A2_MSBLQL := "2"
				SA2->(MsUnlock())
			endif
		endif
		RestArea(aAreaSA2)
		MSExecAuto({|x,y,z| Fina050(x,y,z)},aRow,,3) //3=Inclusão, 4=Alteração, 5=Exclusão

		if lAtualizou
			aAreaSA2 := GetArea()
			SA2->(DbGoTo(nRecForn))
			Reclock("SA2", .F.)
			SA2->A2_MSBLQL := "1"
			SA2->(MsUnlock())
			lAtualizou := .F.
		   RestArea(aAreaSA2)
		endif

		CUSERNAME := cUserBkp

		___XMIGLT       := Nil


		If lMsErroAuto
			AddLogErr(Replicate("-",100),nil)
			AddLogErr('Erro ao incluir o documento "{1}", filial "{2}"!',{aRow[nPosNum,2],cFilAnt})
			aLog := GetAutoGRLog()
			AddLogsErr(aLog)

			LogQZ4(cFilAnt,aLog,GetKey(aKey,aRow))

			lErros := .T.
			nErros++
		else
			If lPending
				aSaveFlds := GetAfter(aSaveRow)
				UpdateTX(aSaveRow)
			Endif

			UpdFlds(aSaveFlds)
		Endif

		ProcessMessages()

	Next nX

	Inc(GLB_REG_ERR,nErros)

	If lRpcSet
		RpcClearEnv()
	Endif

Return lRet

	******************************************
Static Function ExAutError(cKey,cMsgError)
	******************************************
	Local cMsg := FmtStr("Erro durante o processamento do registro {1}:{2}",{cKey,CRLF + cMsgError})
	AddLogErr(Replicate("@",100),nil)
	AddLogErr(cMsg              ,nil)
	AddLogErr(Replicate("@",100),nil)
Return nil

	**************************************
Static function GetKey(aKey,aRow,cSep)
	**************************************
	Local cRet := ""
	Local nX   := 0
	Local nLen := 0
	Local nPos := 0

	Default aKey := {}
	Default aRow := {}
	Default cSep := "|"

	nLen := Len(aKey)

	For nX := 1 To nLen
		nPos := AScan(aRow,{|r| r[1] == aKey[nX]})
		If nPos > 0
			cRet += aRow[nPos,2] + If(nX < nLen,cSep,"")
		Endif
	Next

Return cRet

	********************************************************************************
Static function ReadData(oProcess,lEnd,nHandle,aHeader,aStruct,aFiliais,nQtdReg)
	********************************************************************************
	Local aRet      := {}
	Local aField    := {}
	Local aRow      := {}
	Local nX, nY    := 0
	Local nRowNum    := 0
	Local cRow      := ""
	Local xData     := nil
	Local cFilCod   := ""
	Local nPosLot   := 0
	Local cXMigLt   := GetGlbValue(GLB_E2_XMIGLT)
	//Filiais para De-Para
	Local nFilial   := AScan(aHeader,{|x| x == "E2_FILIAL"})

	If Empty(aHeader)
		fMsgStop('Não foi possível obter o cabeçalho do arquivo! Verifique.',nil,.T.)
		return {}
	Endif

	oProcess:SetRegua2( nQtdReg )

	While (GetRow(nHandle,@cRow) > 0) .And. !lEnd

		aData := Separa(cRow,cSeparator,.T.)

		If (Len(aData) != Len(aStruct))
			AddLogErr(Replicate("*",100))
			AddLogErr('Os dados do registro "{1}" diverge do cabeçalho (Dados: {2}/Cabeçalho:{3}).',{nRowNum+1,Len(aData),Len(aStruct)})
			AddLogErr(Replicate("*",100))
			nRowNum++
			Loop
		Endif

		nRowNum++

		oProcess:IncRegua2( StrTran(StrTran('Lendo o registro {1}/{2}',"{1}",cValToChar(nRowNum)),"{2}",cValToChar(nQtdReg)) )
		ProcessMessages()

		aRow := {}
		For nX := 1 To Len(aStruct)

			xData := aData[nX]

			If Empty(xData)
				Do Case
				Case aStruct[nX,2] == "N"
					xData := 0
				Case aStruct[nX,2] == "D"
					xData := CToD("")
				Case aStruct[nX,2] == "L"
					xData := .F.
				Otherwise
					xData := CriaVar(aStruct[nX,1])
				EndCase
			Else
				Do Case
				Case aStruct[nX,2] == "N"
					//xData := Val(xData)
					xData := val(Replace(xData, ',', '.'))
				Case aStruct[nX,2] == "D"
					xData := ctoD(xData)
//                    xData := xData
				Case aStruct[nX,2] == "L"
					xData := ('T' $ Upper(xData))
				Case aStruct[nX,2] == "C"
					xData := PadR(xData,aStruct[nX,3])
				EndCase
			Endif

			Aadd(aRow,{aStruct[nX,1],xData,nil})

		Next nX

		nPosLot := AScan(aRow,{|f| f[1] == "E2_XMIGLT"})
		If ( nPosLot == 0 )
			Aadd(aRow,{"E2_XMIGLT",If(Empty(cXMigLt),"ERRO", cXMigLt),nil})
		ElseIf Empty(AllTrim(aRow[nPosLot,2]))
			aRow[nPosLot,2] := cXMigLt
		Endif

		Aadd(aRet,aRow)

		//Grava o código da empresa/filial em aFiliais
		cFilCod := MGSM0DP1("",aRet[Len(aRet),nFilial][2])
		nPosEmp := AScan(aFiliais,{|e| e[1] == cFilCod})
		If ( nPosEmp == 0 )
			Aadd(aFiliais,{cFilCod,nQtdReg}) //{Filial,Total Registros}
		Endif
		//FIM: Grava o código da empresa/filial em aFiliais.

	Enddo

	FClose(nHandle)

Return aRet


	**********************************************************
Static Function OpenFile(cFile,cSeparator,aHeader,aStruct)
	**********************************************************
	Local nRet := 0

	nRet := FOpen(cFile,FO_READ + FO_SHARED)
	If ( nRet == -1 )
		MSgInfo("Não foi possivel abrir o arquivo"+CRLF+cFile+CRLF+"ERRO:"+CRLF+FERROR())
		return nRet
	Endif

	aHeader := GetHeader(nRet,@aStruct)

return nRet

	******************************************
Static Function GetHeader(nHandle,aStruct)
	******************************************
	Local aRet    := {}
	Local nX      := 0
	Local nBuffer := N_BUF_SIZE
	Local cEOL    := C_CRLF
	Local nLenEOL := Len(cEOL)
	Local cRow    := ""
	Local cRead   := Space(nBuffer)
	Local nReturn := 0
	Local nPosEol := 0
	Local nX      := 0
	Local aField  := {}

	fSeek(nHandle,0,0) // Posiciona no início do arquivo

	While (FRead(nHandle,@cRead,nBuffer) > 0) .OR. (At(cEOL,cRow) != 0)
		cRow += cRead
		cRead := Space(nBuffer)

		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			nReturn := (Len(Substr(cRow,nPosEol + nLenEOL,Len(cRow) - nPosEol + nLenEOL)) * -1)
			fSeek(nHandle, nReturn, FS_RELATIVE) //retorna a quantidade de bytes excedentes à CRLF.
			cRow := ExCRLF(Substr(cRow,1,nPosEol),cEOL)
			Exit
		Endif
	EndDo

	cSeparator := ";"
	Do Case
	Case ( CHR(165) $ cRow )
		cSeparator := CHR(165) //¥
	Case ( CHR(167) $ cRow )
		cSeparator := CHR(167) //§
	EndCase

	aRet := StrTokArr(StrTran(cRow,chr(32),""),cSeparator)

	If Empty(aRet)
		fMsgStop('O arquivo está vazio! Verifique')
		Return {}
	Endif

	AEval(aRet,{|f| f := AllTrim(f)})

	For nX := 1 To Len(aUnique)
		If ( AScan(aRet,{|f| AllTrim(f) == aUnique[nX]}) == 0)
			AddLogErr('-')
			AddLogErr('O campo "{1}" não foi encontrado no dicionário! Verifique.',{aUnique[nX]})
			AddLogErr('-')
			Return {}
		Endif
	Next nX

	If ( Len(aRet) == Len(aUnique) )
		fMsgStop('O arquivo não possue dados para a atualização! Verifique.')
		Return {}
	Endif

	//Verifica os campos no dicionário da empresa corrente.
	For nX := 1 To Len(aRet)
		aField := TamSx3(aRet[nX])
		If Empty(aField)
			fMsgStop('O campo "{1}" não existe no dicionário! Verifique.',{aRet[nX]})
			return {}
		Endif
		Aadd(aStruct,{aRet[nX],aField[3],aField[1],aField[2]})
	Next nX


Return aRet

	************************************
Static Function GetRow(nHandle,cRow)
	************************************
	Local nBuffer := N_BUF_SIZE
	Local cEOL    := C_CRLF
	Local nLenEOL := Len(cEOL)
	Local nRet    := 0
	Local cRead   := Space(nBuffer)
	Local nReturn := 0
	Local nPosEol := 0

	cRow := ""

	While ((nRet += FRead(nHandle,@cRead,nBuffer)) > 0)
		cRow += cRead
		cRead := Space(nBuffer)
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			cNewRow := Left(cRow,nPosEol - 1)
			nSkip   := Len(cRow) - (nLenEOL + Len(cNewRow))
			fSeek(nHandle,(nSkip * -1),FS_RELATIVE) //Volta o ponteiro para o início da próxima linha
			cRow    :=  cNewRow
			Exit
		Endif
	EndDo

Return nRet

	***************************
Static Function ExCRLF(c,b)
	***************************
	Local cRet := c
	Local nX   := 1

	Default b := CRLF

	For nX := 1 To Len(b)
		cRet := StrTran(cRet,Substr(b,nX,1))
	Next nX

Return cRet

	*********************************
Static Function GetLastRec(cFile)
	*********************************
	Local nRet    := 0
	Local nHandle := 0
	Local nBuffer := N_BUF_SIZE
	Local cEOL    := C_CRLF
	Local nLenEOL := Len(cEOL)
	Local cRow    := ""
	Local cNewRow := ""
	Local cRead   := Space(nBuffer)
	Local nPosEol := 0
	Local nSkip   := 0

	nHandle := FOpen(cFile,FO_READ + FO_SHARED)
	If ( nHandle == -1 )
		MSgInfo("Não foi possivel abrir o arquivo "+CRLF+CRLF+cFile)
		return 0
	Endif

	//nBufTot := FSeek(nHandle,0,2) // Lê o tamanho do arquivo em Bytes (
	fSeek(nHandle,0,0) // Posiciona no início do arquivo

	While (FRead(nHandle,@cRead,nBuffer) > 0)
		cRow += cRead
		cRead := Space(nBuffer)
		nPosEol := At(cEOL,cRow)
		If (nPosEol != 0)
			nRet++
			cNewRow := Left(cRow,nPosEol - 1)
			nSkip   := Len(cRow) - (nLenEOL + Len(cNewRow))
			fSeek(nHandle,(nSkip * -1),FS_RELATIVE) //Volta o ponteiro para o início da próxima linha
			cRow    :=  ""
		Endif
	EndDo

	If nRet > 0
		nRet-- //Retira da contagem a linha do cabeçalho.
	Endif

	FClose(nHandle)

Return nRet

/////////////////////////////////////////////////////////////////////////
//--Rotinas de Log.
/////////////////////////////////////////////////////////////////////////
/**
 * Retorna o nome do arquivo de Log, conforme a chave (cKeyLog)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @return caracter
*/ 
/**
 * Retorna o nome do arquivo de Log, conforme a chave (cKeyLog)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @return caracter
*/ 
	***********************************
Static Function GetFileLog(cKeyLog)
	***********************************
	Local cDirLog  := GetPathLog()
	Local cSufixo  := "9"
	Local bLogFile := {|| cSufixo := Soma1(cSufixo), cDirLog + cKeyLog + "_" + DtoS(Date()) + "_" + cSufixo + ".txt" }
	Local cGlbVar  := GetGlbValue(GLB_LOG_FILE)
	Local cRet     := cGlbVar

	If ( cGlbVar == "" )
		cRet := Eval(bLogFile)
		While File(cRet)
			cRet := Eval(bLogFile)
		EndDo
		PutGlbValue(GLB_LOG_FILE,cRet)
	Else
		cRet := cGlbVar
	Endif

return cRet

/**
 * Grava log
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG: INF = Informação, WAR = Alerta, ERR = Erro
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
	*********************************************
Static Function AddLog(cTypeLog,cMsg,aParams)
	*********************************************
	Local cFileLog  := GetFileLog(C_KEYLOG)
	Local cDirLog   := GetPathLog()
	Local cMessage  := OemToAnsi(cMsg)

	Default aParams := {}

	If !ExistDir ( cDirLog )
		If !FWMakeDir(cDirLog,.F.)
			ConOut( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
			return nil
		Endif
	Endif

	For nX := 1 To Len(aParams)
		cMessage := StrTran(cMessage,"{"+cValToChar(nX)+"}",cValToChar(aParams[nX]))
	Next nX

	cMessage := cTypeLog + '-' + DtoS(Date()) + ' ' + Time() + '-' + cMessage + CRLF

	If File(cFileLog)
		nHandle := fOpen(cFileLog,FO_READWRITE)
	Else
		nHandle := fCreate(cFileLog,FC_NORMAL)
	Endif

	If nHandle = -1
		MsgStop("Erro ao criar arquivo - ferror " + Str(FError()))
		Return nil
	Endif

	fSeek(nHandle, 0, FS_END)

	fWrite(nHandle,cMessage)

	fClose(nHandle)
return nil

/**
 * Grava log de erro (ERR)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG.
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
	***************************************
Static Function AddLogErr(cMsg,aParams)
	***************************************
	AddLog("ERR",cMsg,aParams)
return nil

/**
 * Grava log de erro (ERR)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG.
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
	****************************************
Static Function AddLogsErr(aMsg,aParams)
	****************************************
	Local nX := 0

	AddLog("ERR",Replicate('-',100),Nil)
	For nX := 1 To Len(aMsg)
		AddLog("ERR",aMsg[nX],aParams)
	Next
	AddLog("ERR",Replicate('-',100),Nil)

return nil


/**
 * Grava log de erro (INF)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG.
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
	***************************************
Static Function AddLogInf(cMsg,aParams)
	***************************************
	AddLog("INF",cMsg,aParams)
return nil

/**
 * Grava log de erro (WAR)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @param caracter Indentificador do LOG.
 * @param caracter Mensagem a ser gravada no LOG.
 * @param array Parâmetros para mensagem. 
 * @return nil
*/ 
	***************************************
Static Function AddLogWar(cMsg,aParams)
	***************************************
	AddLog("WAR",cMsg,aParams)
return nil


/**
 * Retorna o nome do arquivo de Log, conforme a chave (cKeyLog)
 *
 * @author Roberto Amâncio Teixeira
 * @date 27/06/2017
 * 
 * @return caracter
*/
	****************************
Static Function GetPathLog()
	****************************
return "\SIGADOC\KITMIGRACAO\LOGS\"

	*********************************************
Static Function fMsgError(cMsg,aParams,lBack)
	*********************************************

	If lBack
		AddLogErr(cMsg,aParams)
	Else
		fMsgStop(cMsg,aParams)
	Endif

Return nil

	********************************************
Static Function fMsgStop(cMsg,aParams,lBack)
	********************************************
	Local cMessage := OemToAnsi(cMsg)
	Local nX       := 0

	Default aParams := {}
	Default lBack   := .F.

	For nX := 1 To Len(aParams)
		cMessage := StrTran(cMessage,"{"+cValToChar(nX)+"}",cValToChar(aParams[nX]))
	Next nX

	AddLogErr(cMessage)

	If !lBack
		MsgStop(cMessage)
	Endif
Return nil

//--FIM: Rotinas de Log.   

	************************************
Static Function GetUnique(cTabAlias)
	************************************
	Local aRet      := {}
	Local cAlias    := GetNextAlias()
	Local cTable    := RetSqlName(cTabAlias)
	Local cQuery    := ""
	Local aEx       := {"R_E_C_D_E_L_","R_E_C_N_O_","D_E_L_E_T_"}

	If Empty(cTable)
		return {}
	Endif

	cQuery += "SELECT c.column_name                                                                             " + CRLF
	cQuery += "  FROM sys.all_indexes i, sys.all_ind_columns c                                                  " + CRLF
	cQuery += " WHERE i.table_name  = '"+cTable+"'                                                              " + CRLF
	cQuery += "   AND i.uniqueness  = 'UNIQUE'                                                                  " + CRLF
	cQuery += "   AND i.index_name  = c.index_name                                                              " + CRLF
	cQuery += "   AND i.table_owner = c.table_owner                                                             " + CRLF
	cQuery += "   AND i.table_name  = c.table_name                                                              " + CRLF
	cQuery += "   AND i.owner       = c.index_owner                                                             " + CRLF
	cQuery += "   AND c.index_name IN (SELECT index_name FROM sys.all_ind_columns WHERE column_position = 2)    " + CRLF
	cQuery += "ORDER BY c.column_position                                                                       "

	TCQUERY cQuery NEW ALIAS (cAlias)

	While (cAlias)->(!Eof())
		If ( AScan(aEx, {| f | f == AllTrim((cAlias)->column_name) }) == 0 )
			Aadd(aRet,AllTrim((cAlias)->column_name))
		Endif
		(cAlias)->(DbSkip(1))
	EndDo

	If (Select(cAlias) > 0)
		(cAlias)->(DbCloseArea())
	Endif

Return aRet


	*****************************************
Static function LogQZ4(cCodFil,aLog,cKey)
	*****************************************
	Local nSeq    := GetSeqQZ4(QZ3->QZ3_UKEY)
	Local cMsg    := StrTran(StrTran(AllTrim(aLog[1]),CHR(13)),CHR(10))
	Local bGetMsg := {|x| cMsg += If( ("ERRO" $ Upper(x)) .OR. ("INVALIDO" $ Upper(x)),StrTran(StrTran(AllTrim(x),CHR(13)),CHR(10)) + CRLF,"") }

	AEval(aLog,bGetMsg)

	DbSelectArea("QZ4")
	RecLock("QZ4",.T.)
	QZ4->QZ4_FILIAL  := xFilial("QZ4") //cCodFil
	QZ4->QZ4_UKEY    := TabAlias()+"-"+FWTimeStamp(3,Date(),Time())+FWTimeStamp(4,Date(),Time())+Alltrim(Str(nSeq))
	QZ4->QZ4_NUMLOTE := QZ3->QZ3_NUMLOT
	QZ4->QZ4_DATALOG := dDataBase
	QZ4->QZ4_CODTAB  := TabAlias()
	QZ4->QZ4_NUMLINH := 0
	QZ4->QZ4_SEQLOG  := nSeq
	QZ4->QZ4_CODCPO  := C_ROTINA
	QZ4->QZ4_DESCPO  := "Rotina automática "+C_ROTINA
	QZ4->QZ4_CONTEUD := "BK -> "+cKey
	QZ4->QZ4_VALID   := ""
	QZ4->QZ4_UKEYP   := QZ3->QZ3_UKEY
	QZ4->QZ4_CODLOG  := "AUTO"
	QZ4->QZ4_DESCLOG := StrTran(StrTran(AllTrim(aLog[1]),CHR(13)),CHR(10))
	QZ4->QZ4_TIMSTAM := FWTimeStamp(2,Date(),Time())

	QZ4->(MsUnLock())

Return nil

	*********************************
Static Function GetSeqQZ4(cUKEYP)
	*********************************
	Local nRet      := 1
	Local cQuery    := "SELECT MAX(QZ4_SEQLOG) SEQLOG FROM "+RetSqlName("QZ4")+" WHERE QZ4_UKEYP='"+cUKEYP+"' AND D_E_L_E_T_=' ' "
	Local cAliasTmp := GetNextAlias()

	TCQUERY cQuery NEW ALIAS (cAliasTmp)

	If (cAliasTmp)->(!Eof()) .And. (cAliasTmp)->SEQLOG > 0
		nRet := (cAliasTmp)->SEQLOG + 1
	Endif

	If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif

		return nRet

		***********************************************
Static Function SetQZ2(aFormulas,aReg,cCodProc)
	***********************************************
	Local lRet      := .T.
	Local cQuery    := ""
	Local cAliasTmp := GetNextAlias()
	Local nPos      := 0
	Local cFormula  := ""
	Local xValue    := nil

	If LoadVars(aReg) .And. .Not. Empty(aFormulas)
		lRet := ApplyFormulas(aFormulas,aReg)
		return lRet
	Endif

	cQuery += "SELECT QZ2.QZ2_CPOORI, QZ2.QZ2_CPODES      " + CRLF
	cQuery += "FROM "+RetSqlName("QZ2")+" QZ2             " + CRLF
	cQuery += "WHERE QZ2.QZ2_CODEXT = '"+cCodProc+"'      " + CRLF
	cQuery += "AND QZ2.QZ2_CPODES <> QZ2.QZ2_CPOORI       " + CRLF
	cQuery += "AND QZ2.D_E_L_E_T_=' '                     " + CRLF
	cQuery += "ORDER BY QZ2.QZ2_SEQ                       " + CRLF

	TCQUERY cQuery NEW ALIAS (cAliasTmp)

   /*
	If (cAliasTmp)->(!Eof())
		If ! LoadVars(aReg) //Carrega aReg nas variáveis MEMVAR (M->NOM_VARIÁVEL)
			If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif
         Return .F.
			Endif
		Endif
   */

		While (cAliasTmp)->(!Eof())

			nPos := AScan(aReg,{|x| x[1] == AllTrim((cAliasTmp)->QZ2_CPODES)})
			If ( nPos == 0 )
				(cAliasTmp)->(DbSkip(1))
				Loop
			Endif

			Aadd(aFormulas,{AllTrim((cAliasTmp)->QZ2_CPODES),AllTrim((cAliasTmp)->QZ2_CPOORI)})

			(cAliasTmp)->(DbSkip(1))
		EndDo

		If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif

			If ! Empty(aFormulas)
				lRet := ApplyFormulas(aFormulas,aReg)
			Endif

			Return lRet

			*********************************************
Static Function ApplyFormulas(aFormulas,aReg)
	*********************************************
	Local lRet      := .T.
	Local lSuccess  := .T.
	Local nLenForm  := Len(aFormulas)
	Local nPos      := 0
	Local nX        := 0
	Local xValue    := nil

	For nX := 1 To nLenForm
		nPos := AScan(aReg,{|x| x[1] == aFormulas[nX,1]})
		If ( nPos == 0 )
			Loop
		Endif

		lSuccess := ExFormula(aFormulas[nX,1],aFormulas[nX,2], @xValue)

		If lSuccess
			aReg[nPos,2] := xValue
		Else
			lRet := .F. //Aplica todas as fórmulas ao registro, mas o invalida se uma delas falhar...
		Endif
	Next nX

Return lRet

	***************************************************
Static Function ExFormula( cTarget, cForm, xValue )
	***************************************************
	Local lRet   := .F.
	Local cField := AllTrim(cTarget)
	Local aField := TamSx3(cField)

	TRYEXCEPTION

		xValue := &cForm

		If ( lRet := ( ValType(xValue) == aField[3] ) )
			If ( ValType(xValue) == "C" )
				xValue := PadR(xValue,aField[1])
			Endif
		Else
			AddLogErr(Replicate('-',100))
			AddLogErr('Campo destino "{1}" aguarda um valor do tipo "{2}".'+CRLF+'O tipo retornado pela fórmula é "{3}".', {cField,aField[3],ValType(xValue)})
			AddLogErr(Replicate('-',100))
		Endif

	CATCHEXCEPTION USING oException
		IF ( ValType( oException ) == "O" )
			AddLogErr(Replicate('-',100))
			AddLogErr('Campo destino "{1}", erro ao compilar a fórmula:'+CRLF+'-> {2}'+CRLF+'-> {3}', {cField,chr(9)+cForm,chr(9)+oException:DESCRIPTION})
			AddLogErr(Replicate('-',100))
			oException := nil
		EndIF
	ENDEXCEPTION

Return lRet

	******************************
Static Function LoadVars(aReg)
	******************************
	Local nPos      := 0
	Local lRet      := .T.
	Local cField    := ""
	Local xValor    := nil
	Local nX        := 0
	Local aAreaSx3  := SX3->(GetArea())
	Local cAlias    := TabAlias()

	SX3->(DbSetOrder(1))
	If ! SX3->(MsSeek(cAlias))
		SX3->(RestArea(aAreaSx3))
		return .F.
	Endif

	While ( SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias)

		If (SX3->X3_CONTEXT == "V")
			SX3->(DbSkip(1))
			Loop
		Endif

		cField := AllTrim(SX3->X3_CAMPO)

		nPos := AScan(aReg,{|x| x[1] == cField})

		If ( nPos == 0 )
			xValue := CriaVar(cField)
		Else
			xValue := aReg[nPos,2]
		Endif

		If Type("M->"+cField)=='U'
			_SetOwnerPrvt(cField,xValue)
		Else
			&("M->"+cField) := xValue
		EndIf

		SX3->(DbSkip(1))
	EndDo

	SX3->(RestArea(aAreaSx3))

Return lRet


	********************************
Static Function TabAlias(cAlias)
	********************************
	Local cRet     := cAlias

	Default cAlias := ""

	If Empty(cAlias)
		cRet := GetGlbValue(GLB_TAB_ALIAS)
	Else
		PutGlbValue(GLB_TAB_ALIAS,cRet)
	Endif

Return cRet

	*********************************
Static Function Inc(cGlbKey,nInc)
	*********************************
	Local cValue := 	AllTrim(GetGlbValue(cGlbKey))
	Local nRet   := 0

	Default nInc   := 1

	If cValue == ""
		nRet := nInc
	Else
		nRet := GetDtoVal(cValue) + nInc
	Endif

	SetGlb(cGlbKey,cValToChar(nRet))

return nRet

	**************************************
Static Function SetGlb(cGlbKey,xValue)
	**************************************
	PutGlbValue(cGlbKey,cValToChar(xValue))
Return nil

	*******************************
Static Function GetNum(cGlbKey)
	*******************************
	Local cValue := GetGlbValue(cGlbKey)
	Local nRet   := 0

	If cValue != ""
		nRet := GetDtoVal(cValue)
	Endif

Return nRet

	***************************
Static Function GetLogURI()
	***************************
	Local cRet      := "file:{1}{2}"
	Local cIp       := StrTran( Alltrim(SuperGetMV('FS_RDI004',,'')),"\","/")
	Local cFileLog  := StrTran( GetFileLog(C_KEYLOG) ,"\","/")

	cRet := FmtStr(cRet,{ cIp, cFileLog })
Return cRet

	**********************************
Static Function FmtStr(cCmd,aArgs)
	**********************************
	Local nX   := 0
	Local cRet := cCmd
	For nX := 1 To Len(aArgs)
		cRet := StrTran(cRet,"{"+cValToChar(nX)+"}",cValToChar(aArgs[nX]))
	Next nX
Return cRet

	**************************************
Static Function GetForn(cCodigo,cLoja)
	**************************************
	Local cRet      := ""
	Local cQuery    := "SELECT GetDeParaForn('"+cCodigo+"','"+cLoja+"') CODIGO FROM DUAL"
	Local cAliasTmp := GetNextAlias()

	TCQUERY cQuery NEW ALIAS (cAliasTmp)

	If (cAliasTmp)->(!Eof()) //.And. .Not. ( "?_" $ (cAliasTmp)->CODIGO )
		cRet := AllTrim( (cAliasTmp)->CODIGO )
	Endif

	If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif

		Return cRet

		*********************************
Static Function GetTitPai(cValue)
	*********************************
	Local cRet  := AllTrim(cValue)
	Local cForn := ""

	If Empty(cRet) .OR. ( Len(cRet) < 24 )
		Return cRet
	Endif

	cForn := GetForn(Substr(cRet,17,6),Substr(cRet,23,2))

	If ( "?_" $ cForn ) .OR. Empty(cForn )
		UserException(FmtStr('Erro durante o De-Para de fornecedor! Código "{1}".', {cForn}))
	Endif

	cForn := cForn + "01" //Concatena o código do fornecedor com a loja.

	cRet := Stuff(cRet,17,Len(cForn))

Return cRet



//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} $MGSM0DP1
De Para de Filial
@type function
@author Cris
@since 11/04/2017
@version 1.0
@param cEmpDe, character, (Empresa de Origem)
@param cFilDe, character, (Filial de Origem)
@return ${return}, ${return_description}
/*///---------------------------------------------------------------------------------------------------------------------------
Static Function MGSM0DP1(cEmpDe,cFilDe)

	Local aArea			:= GetArea()
	Local aAreaSZX		:= SZX->(GetArea())
	Local cFilPara		:= ''
	Local cArqImp		:= ''
	Local cEmpFlAx		:= ''

	//Caso o arquivo possua o codigo da empresa no nome do arquivo e não concatenada com a filial
	if cEmpDe == 'A'

		SplitPath(QZ1->QZ1_DIRIMP,,,@cArqImp)
		cEmpDe	:= Substring(cArqImp,5,2)
		cEmpFlAx	:= cEmpDe+cFilDe

	Else

		cEmpFlAx	:= Alltrim(cEmpDe)+cFilDe

	EndIf

	//Caso a funçao seja configurada para um arquivo compartilhado, os parametros virão em branco.
	if !Empty(cEmpFlAx)

		dbSelectArea('SZX')
		SZX->(dbSetOrder(1))//SZX_EMPFIL (P10)
		if SZX->(dbSeek(cEmpFlAx))

			cFilPara	:= SZX->ZX_FILIALP

		EndIf

	EndIF

	RestArea(aArea)
	RestArea(aAreaSZX)

Return cFilPara



	**********************************************
Static Function fDirectory(cPath,cMask,lCount)
	**********************************************
	Local aRet   := Directory(cPath + cMask)
	Local bExec  := {|| Aeval(aRet,{|x| ASize(x,Len(x)+2), x[Len(x)-1] := cPath + AllTrim(x[1]), x[Len(x)] := If(lCount,(GetLastRec( x[Len(x)-1] )-1),0) }) }

	Default lCount := .T.

	MsgRun('Obtendo informações do(s) arquivo(s)...',"Aguarde...",bExec)

Return aRet

	***********************************
Static Function GetOrigem(cCpoDest)
	***********************************
	Local cAlias := GetNextAlias()
	Local cRet   := ""
	Local cQuery := "SELECT TRIM(QZ2.QZ2_CPOORI) ORIGEM FROM "+RetSqlName("QZ2")+;
		" QZ2 WHERE ROWNUM=1 AND QZ2.QZ2_CODEXT='"+QZ1->QZ1_CODIGO+"' AND QZ2.QZ2_CPODES='{1}' AND QZ2.D_E_L_E_T_=' ' AND QZ2.QZ2_CPODES<>QZ2.QZ2_CPOORI"

	cQuery := StrTran(cQuery,"{1}",cCpoDest)

	TCQUERY cQuery NEW ALIAS (cAlias)
	If (cAlias)->(!Eof())
		cRet := AllTrim((cAlias)->ORIGEM)
	Endif

	If Select(cAlias) > 0   ; (cAlias)->(DbCloseArea()) ; Endif
		Return cRet

		*************************************
Static Function CountReg(nIdx,aFiles)
	*************************************
	Local nRet := 0

	Default nIdx := 0

	If (nIdx > 0)
		nRet := aFiles[nIdx,Len(aFiles[nIdx])]
	Else
		AEval(aFiles,{|x| nRet += x[Len(x)]})
	Endif

Return nRet



	************************************
Static Function fFileNoEx(cFileName)
	************************************
	Local cRet    := cFileName
	Local nPosIni := RAT("\",cRet)+1
	Local nPosFin := (RAT(".",cRet) - nPosIni)

	nPosIni := If(nPosIni == 0,1        ,nPosIni)
	nPosFin := If(nPosFin == 0,Len(cRet),nPosFin)

	cRet := Substr(cRet,nPosIni,nPosFin)

return cRet


	************************************
Static Function FilePath(cFileName)
	************************************
	Local cRet    := cFileName
	Local nPosFin := RAT("\",cRet)

	cRet := Substr(cRet,1,nPosFin)

return cRet

	************************************
Static Function GetNextRecno(cAlias)
	************************************
	Local cTable    := RetSqlName(cAlias)
	Local nRet      := 1
	Local cQuery    := "SELECT MAX(R_E_C_N_O_)+1 RECNO FROM "+cTable
	Local cAliasTmp := GetNextAlias()

	TCQUERY cQuery NEW ALIAS (cAliasTmp)

	If (cAliasTmp)->(!Eof())
		nRet := (cAliasTmp)->RECNO
	Endif

	If nRet == 0
		nRet := 1
	endif

	If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif

		return nRet

		************************************
Static Function Before_Exec(cDestin)
	************************************
	Local lRet      := .T.
	Local cFunction := "U_RDIBEx"+AllTrim(cDestin)

	If FindFunction(cFunction)
		lRet := &(cFunction+'()')
	Endif

return lRet

	***********************************
Static Function After_Exec(cDestin)
	***********************************
	Local lRet      := .T.
	Local cFunction := "U_RDIAEx"+AllTrim(cDestin)

	If FindFunction(cFunction)
		lRet := &(cFunction+'()')
	Endif

return lRet


	***********************************
Static Function GetMaxRecno(cAlias)
	***********************************
	Local cTable    := RetSqlName(cAlias)
	Local nRet      := 1
	Local cQuery    := "SELECT MAX(R_E_C_N_O_) RECNO FROM "+cTable
	Local cAliasTmp := GetNextAlias()

	If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif

		TCQUERY cQuery NEW ALIAS (cAliasTmp)

		If (cAliasTmp)->(!Eof())
			nRet := (cAliasTmp)->RECNO
		Endif

		If Select(cAliasTmp) > 0   ; (cAliasTmp)->(DbCloseArea()) ; Endif

			return nRet

			*****************************
Static Function OpenTit(aRow)
	*****************************
	Local aRet       := {}
	Local aFixed     := {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA","E2_BAIXA","E2_SALDO",;
		"E2_VALOR","E2_VLCRUZ","E2_IRRF","E2_PIS","E2_ISS","E2_INSS","E2_CSLL","E2_COFINS","E2_NATUREZ","E2_ACRESC","E2_DECRESC"}
	Local aSet       := {}
	Local aSetRow    := {}
	Local aRemove    := {"E2_BAIXA","E2_VALLIQ"}
	Local nPos       := 0
	Local nX         := 0

	If IsOpen(aRow)
		Return {}
	Endif

	aSet       := {{"E2_SALDO",GetVRow("E2_VALOR",aRow)},{"E2_IRRF",0},{"E2_PIS",0},{"E2_ISS",0},{"E2_INSS",0},{"E2_CSLL",0},{"E2_COFINS",0}}
	aSetRow    := {{"E2_VALOR",GetVRow("@VLRLIQUIDO",aRow)},{"E2_VLCRUZ",GetVRow("@VLRLIQUIDO",aRow)}} //Manipula valores de aFixced

	//--Salvando os valores originais
	For nX := 1 To Len(aFixed)
		nPos := AScan(aRow,{|r| AllTrim(r[1]) == aFixed[nX]})
		If ( nPos > 0 )
			Aadd(aRet,{aRow[nPos,1],aRow[nPos,2],aRow[nPos,3]})
		Endif
	Next nX

	//--Manipula os valores salvos em aFixed
	For nX := 1 To Len(aSetRow)
		nPos := AScan(aRet,{|r| AllTrim(r[1]) == aSetRow[nX,1]})
		If ( nPos > 0 )
			aRet[nPos,2] := aSetRow[nX,2]
		Endif
	Next nX

	//--Atribuindo novos valores para MsExecAuto
	For nX := 1 To Len(aSet)
		nPos := AScan(aRow,{|r| AllTrim(r[1]) == aSet[nX,1]})
		If ( nPos > 0 )
			aRow[nPos,2] := aSet[nX,2]
		Endif
	Next nX

	//--Remove os campos, tornando o título "aberto"
	For nX := 1 To Len(aRemove)
		nPos := AScan(aRow,{|r| AllTrim(r[1]) == aRemove[nX]})
		If ( nPos > 0 )
			ADel(aRow,nPos)
			ASize(aRow,Len(aRow)-1)
		Endif
	Next nX

Return aRet

	****************************
Static Function IsOpen(aRow)
	****************************
	Local lRet    := .F.
	Local nPosDta := AScan(aRow,{|r| AllTrim(r[1]) == "E2_BAIXA"})
	Local nPosSld := AScan(aRow,{|r| AllTrim(r[1]) == "E2_SALDO"})
	Local lTemSld := ( nPosSld > 0 .And. !Empty(aRow[nPosSld,2]) )
	Local lTemBxa := ( nPosDta > 0 .And.  Empty(aRow[nPosDta,2]) )

	lRet :=  lTemSld

	If ! lRet
		lRet :=  lTemBxa
	Endif

Return lRet

	************************************
Static Function GetVRow(cField,aRow)
	************************************
	Local nPos   := 0
	Local nX     := 0
	Local xRet
	Local aPFunc := {}

	Aadd(aPFunc,{"@VLRBRUTO","E2_IRRF"})
	Aadd(aPFunc,{"@VLRBRUTO","E2_PIS"})
	Aadd(aPFunc,{"@VLRBRUTO","E2_ISS"})
	Aadd(aPFunc,{"@VLRBRUTO","E2_INSS"})
	Aadd(aPFunc,{"@VLRBRUTO","E2_CSLL"})
	Aadd(aPFunc,{"@VLRBRUTO","E2_COFINS"})

	Aadd(aPFunc,{"@VLRLIQUIDO","E2_IRRF"})
	Aadd(aPFunc,{"@VLRLIQUIDO","E2_PIS"})
	Aadd(aPFunc,{"@VLRLIQUIDO","E2_ISS"})
	Aadd(aPFunc,{"@VLRLIQUIDO","E2_INSS"})
	Aadd(aPFunc,{"@VLRLIQUIDO","E2_CSLL"})
	Aadd(aPFunc,{"@VLRLIQUIDO","E2_COFINS"})

	Aadd(aPFunc,{"@TOTIMPOSTOS","E2_IRRF"})
	Aadd(aPFunc,{"@TOTIMPOSTOS","E2_PIS"})
	Aadd(aPFunc,{"@TOTIMPOSTOS","E2_ISS"})
	Aadd(aPFunc,{"@TOTIMPOSTOS","E2_INSS"})
	Aadd(aPFunc,{"@TOTIMPOSTOS","E2_CSLL"})
	Aadd(aPFunc,{"@TOTIMPOSTOS","E2_COFINS"})

	Do Case
	Case ( cField == "@VLRBRUTO" )
		xRet := 0
		For nX := 1 To Len(aPFunc)
			If ( cField != aPFunc[nX,1] )
				Loop
			Endif
			xRet += aRow[AScan(aRow,{|r| AllTrim(r[1]) == aPFunc[nX,2]}),2]
		Next nX
		xRet := aRow[AScan(aRow,{|r| AllTrim(r[1]) == "E2_VALOR"}),2] + xRet
	Case ( cField == "@VLRLIQUIDO" )
		xRet := 0
		For nX := 1 To Len(aPFunc)
			If ( cField != aPFunc[nX,1] )
				Loop
			Endif
			xRet += aRow[AScan(aRow,{|r| AllTrim(r[1]) == aPFunc[nX,2]}),2]
		Next nX
		xRet := aRow[AScan(aRow,{|r| AllTrim(r[1]) == "E2_VALOR"}),2] - xRet
	Case ( cField == "@TOTIMPOSTOS" )
		xRet := 0
		For nX := 1 To Len(aPFunc)
			If ( cField != aPFunc[nX,1] )
				Loop
			Endif
			xRet += aRow[AScan(aRow,{|r| AllTrim(r[1]) == aPFunc[nX,2]}),2]
		Next nX
	Otherwise
		nPos := AScan(aRow,{|r| AllTrim(r[1]) == cField})
		If nPos > 0
			xRet := aRow[nPos,2]
		Else
			xRet := CriaVar(cField,.T.)
		Endif
	EndCase

Return xRet

	*******************************************
Static Function SetVRow(cField,xValue,aRow)
	*******************************************
	Local nPos   := AScan(aRow,{|r| AllTrim(r[1]) == cField})

	If ( nPos > 0 )
		aRow[nPos,2] := xValue
	Else
		Aadd(aRow,{cField,xValue,nil})
		nPos := Len(aRow)
	Endif

Return nPos

	********************************
Static Function RemoveFlds(aRow)
	********************************
	Local nPos    := 0
	Local nX      := 0
	Local aTmp    := AClone(aRow)

	//AEval(aTmp,{|r| If(!X3Obrigat(r[1]),DelVRow(r[1],aRow),)})
	AEval(aTmp,{|r| If(!IsObrigat(r[1]),DelVRow(r[1],aRow),)})

Return
	*********************************
Static Function IsObrigat(cField)
	*********************************
/*
   Local aObrigat := {"E2_NUM","E2_XSERIE","E2_TIPO","E2_FORNECE","E2_LOJA","E2_NATUREZ","E2_EMISSAO","E2_VENCTO","E2_VENCREA","E2_VALOR",;
         "E2_CCD","E2_ITEMD","E2_CLVLDB","E2_VLCRUZ","E2_VENCORI","E2_PRETINS","E2_VRETINS","E2_DIACTB","E2_NODIA","E2_PARCELA",;
         "E2_PREFIXO","E2_PORTADO","E2_HIST","E2_OK","E2_NUMBCO","E2_INDICE","E2_BAIXA","E2_EMIS1","E2_LA",;
         "E2_LOTE","E2_MOTIVO","E2_MOVIMEN","E2_OP","E2_DESCONT","E2_MULTA","E2_JUROS","E2_CORREC","E2_VALJUR","E2_PORCJUR","E2_MOEDA","E2_NUMBOR",;
         "E2_FATPREF","E2_PARCIR","E2_ARQRAT","E2_FATURA","E2_PROJETO","E2_IDENTEE","E2_FLUXO","E2_PARCISS","E2_CLASCON","E2_RATEIO","E2_DTVARIA",;
         "E2_PARCINS","E2_VARURV","E2_DTFATUR","E2_TITORIG","E2_IMPCHEQ","E2_OCORREN","E2_ORIGEM","E2_ORDPAGO",;
         "E2_FLAGFAT","E2_NUMLIQ","E2_BCOCHQ","E2_AGECHQ","E2_CTACHQ","E2_DATALIB","E2_APROVA","E2_TIPOFAT","E2_ANOBASE","E2_NUMTIT","E2_MESBASE"}
*/

	Local aObrigat := {"E2_FILIAL","E2_NUM","E2_XSERIE","E2_TIPO","E2_FORNECE","E2_LOJA","E2_NATUREZ","E2_EMISSAO","E2_VENCTO","E2_VENCREA","E2_VALOR",;
		/*"E2_CCD"*/"E2_CCUSTO","E2_ITEMD","E2_CLVLDB","E2_VLCRUZ","E2_EMIS1","E2_VENCORI","E2_PRETINS","E2_VRETINS","E2_DIACTB","E2_NODIA","E2_PARCELA",;
		"E2_HIST","E2_PREFIXO","E2_XTPSERV"}

Return ( AScan(aObrigat,{|o| o == cField}) > 0 )

	************************************
Static Function DelVRow(cField,aRow)
	************************************
	Local nPos   := AScan(aRow,{|r| AllTrim(r[1]) == cField})

	If ( nPos > 0 )
		ADel(aRow,nPos)
		ASize(aRow,Len(aRow)-1)
	Endif

Return nPos

	******************************
Static Function UpdFlds(aFlds)
	******************************
	Local lRet    := .F.
	Local aUnique := {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"}
	Local cSet    := ""
	Local cKey    := ""
	Local cCmd    := "UPDATE "+RetSqlName("SE2")+" SET {1} WHERE D_E_L_E_T_=' ' {2}"
	Local cCmdSld := "UPDATE "+RetSqlName("SE2")+" SET E2_VALLIQ = E2_SALDO WHERE D_E_L_E_T_=' ' {2}"
	Local nX      := 0
	Local nKey    := 0
	Local nSet    := 0

	If Empty(aFlds)
		Return .T.
	Endif

	For nX := 1 To Len(aFlds)

		nKey := AScan(aUnique,{|f| AllTrim(f) == AllTrim(aFlds[nX,1]) })
		If ( nKey > 0 ) //.And. ( AScan({"E2_VALOR","E2_VLCRUZ"},{|f| AllTrim(f) == AllTrim(aFlds[nX,1]) }) == 0 )
			cKey := cKey +  " AND "+aFlds[nKey,1]+"=" + QuotedStr(aFlds[nKey,2]) + CRLF
		Else
			cSet := cSet + aFlds[nX,1]+"=" + QuotedStr(aFlds[nX,2]) + "," + CRLF
		Endif

	Next nX

	cSet := Left(cSet,RAT(",",cSet)-1)

	cCmd := StrTran(cCmd,"{1}",cSet)
	cCmd := StrTran(cCmd,"{2}",cKey)

	cCmdSld := StrTran(cCmdSld,"{2}",cKey)

	lRet := (TCSQLExec(cCmd) >= 0)
	If ! lRet
		Aviso("Erro ao executar o comando(1):" ,cCmd+CRLF+TCSQLError(),{"Fechar"},3)
		lRet := .F.
	Else
		lRet := (TCSQLExec(cCmdSld) >= 0)
		If ! lRet
			Aviso("Erro ao executar o comando(2):" ,cCmdSld+CRLF+TCSQLError(),{"Fechar"},3)
			lRet := .F.
		Endif
	Endif

Return lRet

	*********************************
Static Function QuotedStr(xValue)
	*********************************
	Local cRet  := cValToChar(xValue)
	Local cType := ValType(xValue)

	If ( cType == "D" )
		cRet := DToS(xValue)
	Endif

	If ( cType $ "C|D" )
		cRet := "'" + cRet + "'"
	Endif

Return cRet

	******************************
Static Function UpdateTX(aRow)
	******************************
	Local lRet      := .T.
	Local nValor    := 0
	//Local cTitPai   := Space(TamSx3("E2_PREFIXO")[1])
	//Local aTitPai   := {"E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"}
	Local cTitPai   := ""
	Local aTitPai   := {"E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"}
	Local cField    := ""
	Local cAlias    := GetNextAlias()
	Local cQuery    := ""
	Local cDelete   := "DELETE FROM "+RetSqlName("SE2")+" WHERE E2_TITPAI='{1}' AND D_E_L_E_T_=' ' AND E2_VALOR=0"
	Local cCmd      := ""
	Local cTCmd     := "UPDATE "+RetSqlName("SE2")+" SET E2_VALOR = {1}, E2_SALDO={1} "+CRLF+;
		"WHERE D_E_L_E_T_=' '  "+CRLF+;
		"AND E2_FILIAL='{2}'   "+CRLF+;
		"AND E2_PREFIXO='{3}'  "+CRLF+;
		"AND E2_NUM='{4}'      "+CRLF+;
		"AND E2_PARCELA='{5}'  "+CRLF+;
		"AND E2_TIPO='{6}'     "+CRLF+;
		"AND E2_FORNECE='{7}'  "+CRLF+;
		"AND E2_LOJA='{8}'     "+CRLF+;
		"AND E2_NATUREZ='{9}'  "

	AEval(aTitPai,{|t| cField := t, cTitPai += PadR( AllTrim(aRow[AScan(aRow,{|r| AllTrim(r[1]) == cField }),2]) , TamSx3(cField)[1]) })
	cTitPai := PadR(cTitPai,TamSx3("E2_TITPAI")[1])

	cQuery += "SELECT SE2.E2_FILIAL, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO,   " + CRLF
	cQuery += "       SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_NATUREZ, SE2.E2_VALOR                 " + CRLF
	cQuery += "FROM "+RetSqlName("SE2")+" SE2                                                   " + CRLF
	cQuery += "WHERE SE2.E2_TITPAI = '"+cTitPai+"'                                              " + CRLF
	cQuery += "AND SE2.D_E_L_E_T_=' '                                                           " + CRLF

	TCQUERY cQuery NEW ALIAS (cAlias)

	While (cAlias)->(!Eof())

		Do Case
		Case AllTrim((cAlias)->E2_NATUREZ) == "IRF"
			nValor := aRow[AScan(aRow,{|r| AllTrim(r[1]) == "E2_IRRF"}),2]
		Case AllTrim((cAlias)->E2_NATUREZ) == "PIS"
			nValor := aRow[AScan(aRow,{|r| AllTrim(r[1]) == "E2_PIS"}),2]
		Case AllTrim((cAlias)->E2_NATUREZ) == "COFINS"
			nValor := aRow[AScan(aRow,{|r| AllTrim(r[1]) == "E2_COFINS"}),2]
		Case AllTrim((cAlias)->E2_NATUREZ) == "CSLL"
			nValor := aRow[AScan(aRow,{|r| AllTrim(r[1]) == "E2_CSLL"}),2]
		Case AllTrim((cAlias)->E2_NATUREZ) == "ISS"
			nValor := aRow[AScan(aRow,{|r| AllTrim(r[1]) == "E2_ISS"}),2]
		Case AllTrim((cAlias)->E2_NATUREZ) == "INSS"
			nValor := aRow[AScan(aRow,{|r| AllTrim(r[1]) == "E2_INSS"}),2]

		EndCase

		cCmd := FmtStr(cTCmd,{ nValor, (cAlias)->E2_FILIAL, (cAlias)->E2_PREFIXO, (cAlias)->E2_NUM, ;
			(cAlias)->E2_PARCELA, (cAlias)->E2_TIPO, (cAlias)->E2_FORNECE, (cAlias)->E2_LOJA, (cAlias)->E2_NATUREZ })

		lRet := (TCSQLExec(cCmd) >= 0)
		If ! lRet
			Aviso("Erro ao executar o comando:" ,cCmd+CRLF+TCSQLError(),{"Fechar"},3)
			lRet := .F.
		Endif

		(cAlias)->(DbSkip(1))
	EndDo

	If (Select(cAlias) > 0)
		(cAlias)->(DbCloseArea())
	Endif

	If lRet

		cDelete := FmtStr(cDelete,{cTitPai})

		lRet := (TCSQLExec(cDelete) >= 0)
		If ! lRet
			Aviso("Erro ao deletar:" ,cDelete+CRLF+TCSQLError(),{"Fechar"},3)
			lRet := .F.
		Endif
	Endif

Return lRet


******************************
Static Function GetAfter(aRow)
******************************
   Local aRet       := {}
   Local aFixed     := {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA","E2_VALOR","E2_XTPSERV",;
                        "E2_VLCRUZ","E2_NATUREZ","E2_IRRF","E2_PIS","E2_ISS","E2_INSS","E2_CSLL","E2_COFINS","E2_ACRESC","E2_DECRESC"}
   Local aSet       := { {"E2_VALOR" ,GetVRow("@VLRLIQUIDO",aRow)} ,;
                         {"E2_VLCRUZ",GetVRow("@VLRLIQUIDO",aRow)} ,;
                         {"E2_SALDO" ,GetVRow("@VLRLIQUIDO",aRow)} ,; 
                         {"E2_NATUREZ","20100699"                } }
                         
   Local nPos       := 0
   Local nX         := 0
   
   //--Salvando os valores originais
   For nX := 1 To Len(aFixed)
       nPos := AScan(aRow,{|r| AllTrim(r[1]) == aFixed[nX]})
       If ( nPos > 0 )
          Aadd(aRet,{aRow[nPos,1],aRow[nPos,2],aRow[nPos,3]})
       Endif 
   Next nX
   
   //--Atribuindo novos valores
   For nX := 1 To Len(aSet)
       nPos := AScan(aRet,{|r| AllTrim(r[1]) == aSet[nX,1]})
       If ( nPos > 0 )
          aRet[nPos,2] := aSet[nX,2]
       Else
          Aadd(aRet,{aSet[nX,1],aSet[nX,2],nil})
       Endif 
   Next nX  
   
   ASize(aFixed,0)
   ASize(aSet,0)

Return aRet
