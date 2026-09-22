#include "totvs.ch"
#xtranslate NToS([<n,...>])=>LTrim(Str([<n>]))
#DEFINE __cCRLF Chr(13)+Chr(10)

//--------------------------------------------------------------------------------------------------------------
    /*/
Programa:GENERICFUNC.PRW
Funcao:CRIALOG
Data:12/09/2015 (v1)
Data:18/07/2016 (v2)
Autor: (v1) Sato
Autor: (v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
Descricao:Rotina para criar o arquivo de log de erros
    /*/
//--------------------------------------------------------------------------------------------------------------
User function CRIARLOG(aLog, cArq, nQbrLin)

	Local cFile := "LOG_"+cArq+"_"+Day2Str(Date())+"_"+Month2Str(Date())+"_"+Year2Str(Date())+StrTran(Time(),":","_")+".CSV"
	Local cBuffer
	Local X
	Local nH
//	Local cPath := UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\IMPORTAR\"
	//Local cPath := "C:\M&A\LOG\"	//Siqueira
	Local cPath := GetMV("MV_XDIRFOR")+ "\LOG\"


	Local nCont := 1

	U_fCriaDirMA(cPath)

	nH:=fCreate(cPath+cFile)
	If (nH==-1)
		MsgStop("Falha ao criar arquivo - erro "+NToS(fError()))
		Return
	Endif

	cBuffer:="DATA DA IMPORTACAO : "
	cBuffer+=Day2Str(Date())
	cBuffer+="/"
	cBuffer+=Month2Str(Date())
	cBuffer+="/"
	cBuffer+=Year2Str(Date())
	cBuffer+=__cCRLF
	fWrite(nH,cBuffer)

	cBuffer:=Replicate("-",60) + __cCRLF
	fWrite(nH,cBuffer)

	For X:=1 To LEN(aLog)
		cBuffer:=PADR(aLog[X][1],10)+" : "+aLog[X][2]+__cCRLF
		fWrite(nH,cBuffer)
		If nCont = nQbrLin
			cBuffer:="------------------------------------------------------------" + __cCRLF
			fWrite(nH,cBuffer)
			nCont := 0
		EndIf
		nCont++
	Next X

	fClose(nH)

Return

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:GeraExcel
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para exportacao de dados para o Excel
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function GeraExcel(aErros, cArq)

	Local oExcel

	Local cTempPath:=GetTempPath()
	Local cTempFile
	Local cSourceFile

	Local cDriver
	Local cDir
	Local cFile
	Local cExt

	Local cArq
	Local nMod
	Local nArq
	Local cPath
	Local nPerc
	Local nErros
	Local nAtual
	Local nTimeIni

	Local X
	Local T

	Local lOProcess:=((Type("oProcess")=="O").and.(.not.(oProcess:lEnd)))
	Local nRet := 0


	cArq  := "ERROR_"+cArq+"_"+Day2Str(Date())+"_"+Month2Str(Date())+"_"+Year2Str(Date())+StrTran(Time(),":","_")+".CSV"

//	cPath := UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\ERROR\"
	//cPath := "C:\M&A\ERROR\"
	cPath := GetMV("MV_XDIRFOR")+ "\ERROR\"
	U_fCriaDirMA(cPath)
	cSourceFile:=cPath+cArq
	nArq  := fCreate(cSourceFile)

	If nArq==-1
		MsgAlert("Nao conseguiu criar o arquivo!")
		Return
	EndIf

	nErros:=LEN(aErros)
	if lOProcess
		nPerc:=if(nErros<100,10,100)
		oProcess:SetRegua1( nErros )
		oProcess:SetRegua2( int(nErros/nPerc) )
	endif

	nAtual:=0
	T:=NToS(nErros)

	For X:=1 TO nErros
		if lOProcess
			oProcess:IncRegua1("Gerando Arquivo de Error : " + NTos(x)+"/"+T )
		endif
		FWrite(nArq,aErros[X]+__cCRLF)
		if lOProcess
			nAtual++
			nMod:=(nAtual%nPerc)
			If (nMod==1)
				nTimeIni:=Seconds()
			elseif(nMod==0)
				oProcess:IncRegua2( "Tempo Estimado - (" + U_EstTime(nErros,nAtual,(nAtual-nPerc),nTimeIni) + ")" )
			endIf
		endif
	Next X

	fClose(nArq)

	// If .not.(ApOleClient("MSExcel"))
	// 	MsgAlert("Microsoft Excel no instalado!")
	// 	Return
	// Else
	// 	MsgAlert("Arquivo Excel, gerado ! ["+cPath+"]")
	// EndIf

/*	
	SplitPath(cSourceFile,@cDriver,@cDir,@cFile,@cExt)
	cTempFile:=cTempPath+cFile+cExt
	if __CopyFile(cPath+cArq,cTempFile)
		oExcel:=MSExcel():New()
		oExcel:WorkBooks:Open(cTempFile)
		oExcel:SetVisible(.T.)
		oExcel:Destroy()
	endif
*/

Return

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:SelectFile
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para selecao de arquivos CSV para importacao
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function SelectFile()

	Local cMaskDir := "Arquivos .CSV (*.CSV) |*.CSV|"
	Local cTitTela := "Arquivo para Importação"
	Local lInfoOpen := .T.
	Local lDirServidor := .T.
	Local lKeepCase:=.T.
	Local cOldFile := cArquivo

//	cArquivo := cGetFile(cMaskDir,cTitTela,NIL,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor,lKeepCase)
	cArquivo := cGetFile(cMaskDir,cTitTela,NIL,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor,lKeepCase)

	If !File(cArquivo)
		MsgStop("Arquivo Não Existe!")
		cArquivo := cOldFile
		Return .F.
	EndIf

Return cArquivo

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:ValidaDir
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para validacao do diretorio do arquivos CSV a ser importado
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function ValidaDir(cArquivo)
	Local lRet := .T.

	If Empty(cArquivo)
		MsgStop("Selecione um arquivo","Atenção")
		lRet := .F.
	ElseIf !File(cArquivo)
		MsgStop("Selecione um arquivo válido!","Atenção")
		lRet := .F.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:EstTime
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para criaar a barra de progresso com tempo estimado
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function EstTime(nTotal,nAtual,nIni,nTimeIni,nTimeZero)

	Local cRet:=""

	Local nMod

	Local nHora
	Local nMinutos
	Local nSegundos

	If (nAtual-nIni)>0
		nSegundos:=((nTotal-nAtual)*(Seconds()-nTimeIni)/(nAtual-nIni))
	Else
		nSegundos:=0
	EndIf

	nHora:=Int(nSegundos/(60*60))
	nSegundos:=Mod(nSegundos,(60*60))
	nMinutos:=Int(nSegundos/(60))
	nSegundos:=Mod(nSegundos,(60))

	If (nTotal>0)
		nMod:=if(nTotal<100,10,100)
		cRet:=Str(((nAtual/nTotal)*nMod),3)+" % - "
	Else
		cRet:=Str(100,3)+" % - "
	EndIf

	cRet+=""+If(nHora>0,Str(nHora,3,0)+" Horas, ","")+If(nMinutos>0,Str(nMinutos,3,0)+" Min. e ","")+If(nSegundos>0,Str(nSegundos,3,0)+" Seg. ","")

Return(cRet)

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:DESCVLD
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para pegar a descrição da validacao dos dicionario de dados das tabelas a serem importadas.
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function DESCVLD(cValid, cArqTemp)

	Local aValidacao := {}

	aadd(aValidacao,{"CT1","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela CT1 - Plano de Contas"})
	aadd(aValidacao,{"CTT","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela CTT - Centro de Custos"})
	aadd(aValidacao,{"SA1","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SA1 - Clientes"})
	aadd(aValidacao,{"SA2","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SA2 - Fornecedores"})
	aadd(aValidacao,{"SB1","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SB1 - Produtos"})
	aadd(aValidacao,{"SED","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SED - Naturezas"})
	aadd(aValidacao,{"SRB","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRB - Dependentes"})
	aadd(aValidacao,{"CT2","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela CT2 - Lançamentos Contábeis"})
	aadd(aValidacao,{"RCE","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela RCE - Sindicatos"})
	aadd(aValidacao,{"RHK","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela RHK - Planos Ativos do Titular"})
	aadd(aValidacao,{"RHL","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela RHL - Planos Ativos Dependentes"})
	aadd(aValidacao,{"RHM","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela RHM - Plano Ativo Agregados"})
	aadd(aValidacao,{"RHN","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela RHN - Historico Modificacoes Planos"})
	aadd(aValidacao,{"RHO","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela RHO - Co-Participacao e Reembolso"})
	aadd(aValidacao,{"RHP","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela RHP - Hist. CO-Partic. e Reembolso"})
	aadd(aValidacao,{"RHR","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela RHR - Calculo do Plano de Saude"})
	aadd(aValidacao,{"RHS","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela RHS - Hist. Calc. Plano Saúde/Plano Odontológico"})
	aadd(aValidacao,{"SE2","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SE2 - Contas a Pagar"})
	aadd(aValidacao,{"SE5","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SE5 - Movimentos Bancários"})
	aadd(aValidacao,{"SPA","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SPA - Regra de Apontamento"})
	aadd(aValidacao,{"SQ3","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SQ3 - Cargos"})
	aadd(aValidacao,{"SR0","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SR0 - Vinculo meios de Transporte/funcionários"})
	aadd(aValidacao,{"SR3","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SR3 - Historico Valores Salariais"})
	aadd(aValidacao,{"SR6","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SR6 - Turnos de Trabalho"})
	aadd(aValidacao,{"SR7","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SR7 - Historico Alterações Salariais"})
	aadd(aValidacao,{"SR8","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SR8 - Afastamentos"})
	aadd(aValidacao,{"SRA","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRA - Cadastro de Funcionários"})
	aadd(aValidacao,{"SRD","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRD - Acumulados"})
	aadd(aValidacao,{"SRF","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRF - Programação de Ferias"})
	aadd(aValidacao,{"SRG","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRG - Rescisões"})
	aadd(aValidacao,{"SRH","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRH - Férias"})
	aadd(aValidacao,{"SRJ","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRJ - Funções"})
	aadd(aValidacao,{"SRN","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRN - Meios de Transportes"})
	aadd(aValidacao,{"SRQ","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRQ - Beneficiário"})
	aadd(aValidacao,{"SRR","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRR - Itens de Férias e Rescisão"})
	aadd(aValidacao,{"SZ8","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SZ8 - Benefícios"})
	aadd(aValidacao,{"SRV","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRV - Verbas"})
	aadd(aValidacao,{"SRE","Você está tentando executar a rotina de importação da tabela "+cArqTemp+" utilizando o template da tabela SRE - Transferência"})

//Return(aValidacao[aScan(aValidacao,{|x| x[1] == cValid})][2])
Return

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:VldChave
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para gravar os dados na tabela.
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function VldChave(cAlias, aCampos, aDados)

	Local aChave  := {}

	Local cChave  := ""
	Local cIndice := "1"
	Local cIndexK := ""
	Local cFFilial:=(PrefixoCpo(cAlias)+"_FILIAL")
	Local cX3Field:=""
	Local cX2Unico:=AllTrim(GetSX2Unico(cAlias))

	Local dData   := STOD("  /  /  ")

	Local Z
	Local nAT
	Local nOrder
	Local nNumCpo := 0

	Local lData   := .F.
	Local lRet    := .T.
	Local lX2Unico:=.F.

	lX2Unico:=.Not.(Empty(cX2Unico))
	if lX2Unico
		nOrder:=RetOrder(cAlias,cX2Unico)
		cIndice:=NToS(RetOrder(cAlias,cX2Unico))
		lX2Unico:=lX2Unico.and.(.not.(cIndice=="1"))
	endif

	If .not.(lX2Unico)
		If cAlias $ "SE5|SR3"
			cIndice := "2"
		EndIf
		// PROCURA O PRIMEIRO INDICE DAS TABELAS NA TABELA SIX
		SIX->(dbSetOrder(1))
		If SIX->(dbSeek(cAlias+cIndice))
			cIndexK:=AllTrim(SIX->CHAVE)
		EndIf
	Else
		cIndexK:=cX2Unico
	EndIf

	aChave := StrToKArr(cIndexK,"+")

	For Z:=1 To LEN(aChave)
		cX3Field:=Upper(aChave[Z])
		if ("DTOS"$cX3Field)
			cX3Field:=StrTran(cX3Field,"DTOS","")
		endif
		if ("STR"$cX3Field)
			cX3Field:=StrTran(cX3Field,"STR","")
			if (","$cX3Field)
				nAT:=AT(",",cX3Field)
				cX3Field:=SubStr(cX3Field,1,AT(",",--nAT))
			endif
		endif
		if ("("$cX3Field)
			cX3Field:=StrTran(cX3Field,"(","")
		endif
		if (")"$cX3Field)
			cX3Field:=StrTran(cX3Field,")","")
		endif
		cX3Field:=AllTrim(cX3Field)
		If (cFFilial==cX3Field)
			cChave+=xFilial(cAlias)
		Else
			nNumCpo:=aScan(aCampos,{|x|Upper(AllTrim(x))==ALLTRIM(cX3Field)})
			if (nNumCpo==0)
				Loop
			endif
			lData:=(GetSX3Cache(cX3Field,"X3_TIPO")=="D")
			If lData
				If ("/"$aDados[nNumCpo])
					dData:=CTOD(aDados[nNumCpo])
				Else
					dData:=IIf(EMPTY(aDados[nNumCpo]),CTOD("  /  /    "),STOD(aDados[nNumCpo]))
				EndIf
				cChave+=DTOS(dData)
			Else
				cChave+=IIF(EMPTY(aDados[nNumCpo]),SPACE(TAMSX3(aChave[Z])[1]),aDados[nNumCpo])
			EndIf
		EndIf
	Next Z

	nOrder:=RetOrder(cAlias,cIndexK)
	(cAlias)->(dbSetOrder(nOrder))
	lRet:=.not.((cAlias)->(dbSeek(cChave,.F.)))

Return lRet

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:GRVDADOS
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para gravar os dados na tabela.
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function XRVDADOS(cAlias,aCampos,aDados,nPosFil)
	Local cFielD
	Local nField
	Local xField
	Local nFields:=Len(aCampos)
	BEGIN TRANSACTION
		(cAlias)->(Reclock(cAlias,.T.))
		If (nPosFil==0)
			cField:=(PrefixoCpo(cAlias)+"_FILIAL")
			(cAlias)->(&cField):=xFilial(cAlias)
		endif
		For nField:=1 To nFields
			cField:=aCampos[nField]
			If (nField==nPosFil)
				xField:=xFilial(cAlias)
				aDados[nField]:=xField
			else
				xField:=aDados[nField]
			endif
			(cAlias)->(&cField):=xField
		Next nField
		(cAlias)->(Msunlock())
	END TRANSACTION
Return

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:CONFCPO
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para buscar os dados de configuração do campo.
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function CONFCPO(cCpo,nW)
	local lFound:=.not.(GetSx3Cache(cCpo,"X3_CAMPO")==NIL)
	nTamanho:= 0
	if lFound
		//Início - Thais Paiva - Compatibilização P27
		//SX3->(dbSetOrder(2))
		//If SX3->(MsSeek(cCpo,.F.))
		cCampo    := Alltrim(GetSx3Cache(cCpo,"X3_CAMPO"))//ALLTRIM(SX3->X3_CAMPO)
		lObrigat  := GetSx3Cache(cCpo,"X3_OBRIGAT")//X3OBRIGAT(SX3->X3_CAMPO)
		cTipo     := GetSx3Cache(cCpo,"X3_TIPO")//SX3->X3_TIPO
		If cTipo == 'D'
			nTamanho:= GetSx3Cache(cCpo,"X3_TAMANHO")+2//SX3->X3_TAMANHO+2
		Else
			nTamanho:= GetSx3Cache(cCpo,"X3_TAMANHO")//SX3->X3_TAMANHO
			nDecimal:= GetSx3Cache(cCpo,"X3_DECIMAL") //SX3->X3_DECIMAL
		EndIf
		//cValida:=SX3->(IIf(!Empty(X3_VALID), STRTRAN(STRTRAN(UPPER(ALLTRIM(X3_VALID)), "M->"+ALLTRIM(cCampo), "aDados["+NTos(nW)+"]"), "()", "(&(aDados["+NTos(nW)+"]))"),""))
		cValida:= SX3->(IIf(!Empty(GetSx3Cache(cCpo,"X3_VALID")), STRTRAN(STRTRAN(UPPER(ALLTRIM(GetSx3Cache(cCpo,"X3_VALID"))), "M->"+ALLTRIM(cCampo), "aDados["+NTos(nW)+"]"), "()", "(&(aDados["+NTos(nW)+"]))"),""))
		//aValida:=SX3->(StrToKArr(STRTRAN(STRTRAN(STRTRAN(STRTRAN(UPPER(X3_VALID), ".AND.", "#"), ".OR.", "#"), "M->"+ALLTRIM(cCampo), "aDados["+NTos(nW)+"]"), "()", "(&(aDados["+NTos(nW)+"]))"),"#"))
		aValida:= SX3->(StrToKArr(STRTRAN(STRTRAN(STRTRAN(STRTRAN(UPPER(GetSx3Cache(cCpo,"X3_VALID")), ".AND.", "#"), ".OR.", "#"), "M->"+ALLTRIM(cCampo), "aDados["+NTos(nW)+"]"), "()", "(&(aDados["+NTos(nW)+"]))"),"#"))
		//EndIf
		//Fim - Thais Paiva - Compatibilização P27
	else
		nTamanho:=0
		nDecimal:=0
		cValida:=".F."
		aValida:={}
	endif
Return

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:VLDTAMCPO
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para validar se o conteudo vindo do template é maior do que o tamanho do campo do Protheus.
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function VLDTAMCPO(cTipo, cConteudo, nTamanho, nDecimal)
	Local lRet := .F.
	If cTipo == 'N' .AND. AT(",", cConteudo) > 0
		If AT(",", cConteudo)-1 > (nTamanho - (nDecimal+1))
			lRet := .T.
		Else
			lRet := LEN(SUBSTR(cConteudo, AT(",", cConteudo)+1, LEN(cConteudo))) > nDecimal
		EndIf
	Else
		lRet := LEN(cConteudo) > nTamanho
	EndIf
Return lRet

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:VLDTEMPLATE
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para validar se o template a ser utilizado é compativel com o template da rotina executada.
    /*/
//--------------------------------------------------------------------------------------------------------------
//User Function VLDTEMPLATE(cCampo, cTabela, cPref)
User Function VERTEMPL(cCampo, cTabela, cPref)

	Local lRet := .F.

	If SUBSTR(cCampo, 1, AT("_", cCampo)-1)<>cPref
		cDescVld := ""
		If LEN(SUBSTR(cCampo, 1, AT("_", cCampo)-1)) == 2
			cDescVld := "S"+SUBSTR(cCampo, 1, AT("_", cCampo)-1)
		Else
			//cDescVld := SUBSTR(cCampo, 1, AT("_", cCampo)-1)
			cDescVld := cCampo
		Endif
		cMens := u_DESCVLD(cDescVld, cTabela)
		MsgAlert(cMens)
		lRet := .T.
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:CriaArray
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Função para criar strutura para as tabelas temporarias.
    /*/
//--------------------------------------------------------------------------------------------------------------
User Function CriaArray(tabela)

	Local nX
	Local aStru := {}
	Local aFields := {"NOUSER"}
	Local aAlterFields := {}

	Aadd(aStru, {'RB_FILIAL','C',2,0})

	// Get fields from tabela
	aEval(ApBuildHeader(tabela, Nil), {|x| Aadd(aFields, x[2])})
	aAlterFields := aClone(aFields)

	// Define field properties
	//Início - Thais Paiva - Compatibilização P27
	//dbSelectArea("SX3")
	//SX3->(dbSetOrder(2))
	For nX := 1 to Len(aFields)
		//If SX3->(dbSeek(aFields[nX]))
		If GetSx3Cache(aFields[nX],"X3_CAMPO") <> NIL
			//If SX3->X3_BROWSE == "S"
			//Aadd(aStru, {SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			Aadd(aStru, {GetSx3Cache(aFields[nX],"X3_CAMPO"),GetSx3Cache(aFields[nX],"X3_TIPO"),GetSx3Cache(aFields[nX],"X3_TAMANHO"),GetSx3Cache(aFields[nX],"X3_DECIMAL")})
			//Endif
			//Fim - Thais Paiva - Compatibilização P27
		Endif
	Next nX

	Aadd(aStru, {'RB_XIMPORT','C',1,0})

Return aStru

//--------------------------------------------------------------------------------------------------------------
    /*/
	Programa:GENERICFUNC.PRW
	Funcao:GeraTxt
	Autor: (v1) Sato
	Data:12/09/2015
	(v2) Marinaldo de Jesus (marinaldo.jesus@totvspartners.com.br)
	Data:18/07/2016
	Descricao:Rotina para criar o arquivo de log de erros.
    /*/
//--------------------------------------------------------------------------------------------------------------
User function GeraTxt(aErros,cArq)

	Local cFile := "ERROR_"+cArq+"_"+Day2Str(Date())+"_"+Month2Str(Date())+"_"+Year2Str(Date())+"_"+SUBSTR(Time(), 1, 2)+"_"+SUBSTR(Time(), 4, 2)+"_"+SUBSTR(Time(), 7, 2)+".TXT"
	Local nH
//	Local cPath := GETMV("MV_PATH")
//	Local cPath := UPPER(GetSrvProfString("ROOTPATH",""))+"\M&A\ERROR\"		// Siqueira
	//Local cPath := "C:\M&A\ERROR\"		// Siqueira
	Local cPath := GetMV("MV_XDIRFOR")+ "\ERROR\"
	Local lOProcess:=((Type("oProcess")=="O").and.(.not.(oProcess:lEnd)))


	Local nMod
	Local nPerc
	Local nErros:=LEN(aErros)
	Local nAtual:=0
	Local nTimeIni:=0

	Local X
	Local T
		
	U_fCriaDirMA(cPath)
	
	if lOProcess
		nPerc:=if(nError<100,10,100)
		oProcess1:SetRegua1( nErros )
		oProcess:SetRegua2( int(nErros/nPerc) )
	endif

	nH := fCreate(cPath+cFile)
	If  nH == -1
		MsgStop("Falha ao criar arquivo - erro "+NTos(fError()))
		Return
	Endif

	T:=NToS(nErros)

	For X:=1 To nErros
		if lOProcess
			oProcess:IncRegua1("Gerando Arquivo de Log : " + NTos(x)+"/"+T)
		endif
		fWrite(nH,aErros[X]+__cCRLF)
		if lOProcess
			nAtual++
			nMod:=(nAtual%nPerc)
			If (nMod==1)
				nTimeIni:=Seconds()
			elseif (nMod==0)
				oProcess:IncRegua2( "Tempo Estimado - (" + U_EstTime(nErros,nAtual,(nAtual-nPerc),nTimeIni) + ")" )
			endif
		endif
	Next X

	fClose(nH)

Return

User function fCriaDirMA(cPath)
Local Nx := 0 
	aPathDir := StrTokArr(cPath, "\")
	cDirAux := ""
	for nX := 01 To Len(aPathDir)
		cDirAux += aPathDir[nX] + "\"
		if !ExistDir( cDirAux )
			nRet :=  MakeDir( cDirAux )
			if nRet != 0
				alert( "Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
				Return
			endif
		endif
	next
return
