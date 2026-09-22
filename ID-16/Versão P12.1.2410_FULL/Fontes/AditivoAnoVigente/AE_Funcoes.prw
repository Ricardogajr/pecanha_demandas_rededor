#INCLUDE "AE_Funcoes.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Ap5Mail.ch"
 
/*-----------------------------------------------------------------------------+
* Programa  * MontaEml  º Business Inteligence         * Data ³  12/02/2003    *
*------------------------------------------------------------------------------*
* Autores: Luciana / Willy                                                     *
* Objetivo  * Montagem dos E-mails de envio, retorno, rejeição e liberação     *
*           * da Solicitação de Viagem				                           *
*----------------------------------------------------------------------------- */

User Function AEMontaEml(_cRotina, _nRecno,_cNomeDest,_cCodDest, _cStatus ,_cOpcao,oProcess,cPasta,cArqHtm)

Local _aNome     := {}
Local _aAprov    := {}
Local _aAprovF   := {}
Local _nValorU                                                      
Local lNoAdto    := .F.
Local cDirWF     := iif(IsSrvUnix(),"/workflow/modelo/","\workflow\modelo\")
Local cLinkWF  := "http://"
Local lNoShow  := .F.

Default cPasta		:= ""
Default cArqHTM	:= "" 

cLinkWF += alltrim( GetMV( "MV_WFBRWSR" ) )  //obtendo o endereço do servidor HTTP  (localhost/wf)
cLinkWF += STRTRAN(cPasta, "\", "/") + cArqHTM

//Permite inclusão de solicitação sem adiantamento
If ExistBlock("AE_NOADTO")
	lNoAdto :=	ExecBlock("AE_NOADTO",.F.,.F.)    
EndIf               

ChkTemplate("CDV")

If oProcess == Nil
	oProcess := TWFProcess():New( "CDVSOL", STR0001 ) //"Solicitacao de Viagem"
Endif

DbSelectArea("LHP")
LHP->(dbSetOrder(1))
LHP->(dbGoTo(_nRecno))
_nValorU:= LHP->LHP_VALORU + LHP->LHP_VAdiM2

//Identificação do HTML a ser utilizado no envio
Do Case
	Case _cRotina == "H1"  .AND. FILE(cDirWF+"aewf001.htm") //Envio com aprovação  
		oProcess:NewTask( STR0001, cDirWF+"aewf001.htm") //"Solicitacao de Viagem"
		oHtml    := oProcess:oHTML
		RecLock("LHP")
		LHP->LHP_WFID := oProcess:fProcessID + oProcess:fTaskID
		MsUnlock()
	Case _cRotina == "H2" .AND. FILE(cDirWF+"aewf001a.htm") //Retorno sem aprovação para Solicitação Aprovadas/Reprovadas
		oProcess:NewTask( STR0001, cDirWF+"aewf001a.htm") //"Solicitacao de Viagem"
		oHtml    := oProcess:oHTML
	Case _cRotina == "H3"  .AND. FILE(cDirWF+"aewf001.htm") //Time-out com aprovacao para o Aprovador II
		If _cOpcao == "SC"
			oProcess:NewTask(STR0002, cDirWF+"aewf001.htm") //"Solicitacao de Viagem - Aprovador II"
		Else
			oProcess:NewTask(STR0003, cDirWF+"aewf001.htm") //"Solicitacao de Viagem - Depto Viagem 1 Aprovador"
		Endif
		oHtml    := oProcess:oHTML
	Case _cRotina == "H4" .AND. FILE(cDirWF+"aewf001a.htm") //Time-out final sem aprovacao para o Colaborador da S.Viagem
		oProcess:NewTask( STR0004, cDirWF+"aewf001a.htm") //"Solicitacao de Viagem não Respondida"
		oHtml    := oProcess:oHTML
	Case _cRotina == "H5" .AND. FILE(cDirWF+"aewf001b.htm") //Liberacao do Financeiro/Agencia de viagem
		If LHP->LHP_PASSAG == .T. .AND. LHP->LHP_HOSPED == .T. .Or. lNoAdto
			//E-mail com input dos campos de Passagem / Hospedagem
			oProcess:NewTask( STR0005, cDirWF+"aewf001b.htm") //"Solicitacao de Viagem - Financeiro"
		ElseIf LHP->LHP_PASSAG == .T. .AND. FILE(cDirWF+"aewf001d.htm")
			//E-mail com input dos campos de Passagem
			oProcess:NewTask( STR0005, cDirWF+"aewf001d.htm") //"Solicitacao de Viagem - Financeiro"
		ElseIf LHP->LHP_HOSPED == .T. .AND. FILE(cDirWF+"aewf001d.htm")
			//E-mail com input dos campos de  Hospedagem
			oProcess:NewTask( STR0005, cDirWF+"aewf001c.htm") //"Solicitacao de Viagem - Financeiro"
		EndIf

		If oProcess:oHTML <> NIL	
			oHtml    := oProcess:oHTML
		Else
			U_AEMailFin(_nRecNo,"ADI") // Envia e-mail simples, sem os campos de hosp/pass
			lNoShow := .T.				
		EndIf
EndCase
If oProcess:oHTML <> NIL

	oHtml:ValByName( "LHP_RECNO" , _nRecno )       //Numero da Solicitação da Viagem
	oHtml:ValByName( "LHP_CC"    , LHP->LHP_CC )   //Centro de Custo
	oHtml:ValByName( "LHP_QUEM"  , Substr(LHP->LHP_Quem,4,36) ) //Solicitado por
	If _cOpcao <> "SCA"
		oHtml:ValByName( "APROVADOR" , _cCodDest ) //Aprovador
	Endif
	oHtml:ValByName( "STATUS"    , _cStatus )      //Status
	
	DbSelectArea("LHT")
	DbSetOrder(1)
	MsSeek( xFilial("LHT") + LHP->LHP_FUNC )
	oHtml:ValByName( "LHP_FUNC" , LHT->LHT_CODMAT + "-" +LHT->LHT_NOME   )//Nome do Colaborador
	
	DbSelectArea("LHT")
	DbSetOrder(1)
	MsSeek( xFilial("LHT") + LHP->LHP_SUPIMD )
	oHtml:ValByName( "LHP_SUPIMD" , LHT->LHT_CODMAT+"-" +LHT->LHT_NOME )//Nome do Aprovador I
	
	DbSelectArea("LHT")
	DbSetOrder(1)
	MsSeek( xFilial("LHT") + LHP->LHP_DGRAR )
	oHtml:ValByName( "LHP_DGRAR" , LHT->LHT_CODMAT+"-" +LHT->LHT_NOME   )//Nome do Aprovador II
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	MsSeek( xFilial("SA1") + LHP->LHP_EMPCLI )
	oHtml:ValByName( "LHP_EMPCLI" , SA1->A1_COD+"-" +SA1->A1_NOME )//Nome da Empresa
	
	oHtml:ValByName( "LHP_LOCAL"  , LHP->LHP_LOCAL   )  //Local da Viagem
	oHtml:ValByName( "LHP_SISTEM" , LHP->LHP_SISTEM  )  //Sistema Adotado
	
	oHtml:ValByName( "LHP_SAIDA"  , LHP->LHP_SAIDA   )  //Data da Saida
	oHtml:ValByName( "LHP_CHEGAD" , LHP->LHP_CHEGAD  )  //Data do Retorno
	
	//Motivo da Viagem
	_cOBSMot	:= ""
	DbSelectArea("SYP")
	DbSetOrder(1)
	If MsSeek(xFilial("SYP")+LHP->LHP_CODMOT)
		_cOBSMot := MSMM(LHP->LHP_CODMOT,,,,3)
	EndIf
	
	oHtml:ValByName( "LHP_CODMOT"  , _cOBSMot  )        //Motivo da Viagem
	oHtml:ValByName( "LHP_VOOIDA"  , LHP->LHP_VOOIDA )  //Voo de Ida
	oHtml:ValByName( "LHP_HORAID"  , LHP->LHP_HORAID )  //Horario de Ida
	oHtml:ValByName( "LHP_AIRIDA"  , LHP->LHP_AIRIDA )  //CIA de Ida
	
	oHtml:ValByName( "LHP_VOOVTA"  , LHP->LHP_VOOVTA )  //Voo de Volta
	oHtml:ValByName( "LHP_HORAVT"  , LHP->LHP_HORAVT )  //Horario de Volta
	oHtml:ValByName( "LHP_AIRVTA"  , LHP->LHP_AIRVTA )  //CIA de Volta
	
	If _cOpcao == "SCA"
		oHtml:ValByName( "LHP_CODIGO", _cProcesso ) //Codigo da Solicitação
		odefs:= oProcess:oHtml:oFieldDefs
		If LHP->LHP_PASSAG == .T.  //Passagem
			odefs:Caption("LHP_VOOIDA",STR0006)   //Mensagem de erro //"Preencher Campo Voo Ida"
			odefs:FieldType("LHP_VOOIDA","C")                       //Tipo do campo
			
			odefs:Caption("LHP_HORAID",STR0007)//Mensagem de erro //"Preencher Campo Hora Volta"
			odefs:FieldType("LHP_HORAID","C")                       //Tipo do campo
			
			odefs:Caption("LHP_AIRIDA",STR0008) //Mensagem de erro //"Preencher Campo CIA Volta"
			odefs:FieldType("LHP_AIRIDA","C")                       //Tipo do campo
			
			odefs:Caption("LHP_VOOVTA",STR0009) //Mensagem de erro //"Preencher Campo Voo Volta"
			odefs:FieldType("LHP_VOOVTA","C")                       //Tipo do campo
			
			odefs:Caption("LHP_HORAVT",STR0007)//Mensagem de erro //"Preencher Campo Hora Volta"
			odefs:FieldType("LHP_HORAVT","C")                       //Tipo do campo
			
			odefs:Caption("LHP_AIRVTA",STR0008) //Mensagem de erro //"Preencher Campo CIA Volta"
			odefs:FieldType("LHP_AIRVTA","C")                       //Tipo do campo
			
			odefs:Caption("LHP_HPASS",STR0010) //Mensagem de erro //"Preencher Campo Observação da Passagem"
			odefs:FieldType("LHP_HPASS","C")   //Tipo do campo
			
			oHtml:ValByName( "LHP_VLPASS"   , LHP->LHP_VLPASS )   //Valor Passagem
			odefs:Caption("LHP_VLPASS",STR0011) //Mensagem de erro //"Preencher Campo Valor da Passagem"
			odefs:FieldType("LHP_VLPASS","N")   //Tipo do campo
			odefs:FieldDec("LHP_VLPASS",2)      //Decimais
		EndIf
		
		If LHP->LHP_HOSPED == .T.  //Hospedagem
			odefs:Caption("LHP_HHOSP",STR0012) //Mensagem de erro //"Preencher Campo Observação da Hospedagem"
			odefs:FieldType("LHP_HHOSP","C")   //Tipo do campo
			
			oHtml:ValByName( "LHP_VLHOSP"   , LHP->LHP_VLHOSP )   //Valor Hospedagem
			odefs:Caption("LHP_VLHOSP",STR0013) //Mensagem de erro //"Preencher Campo Valor da Hospedagem"
			odefs:FieldType("LHP_VLHOSP","N")   //Tipo do campo
			odefs:FieldDec("LHP_VLHOSP",2)      //Decimais
		Endif
	Endif
	
	If !ExistBlock("AE_MOTVIAG")
		oHtml:ValByName( "LHP_FATCLI"  , TRANSFORM( LHP->LHP_FATCLI,'@E 999' ) )  //% Cliente 
		oHtml:ValByName( "LHP_FATFRA"  , TRANSFORM( LHP->LHP_FATFRA,'@E 999' ) )  //% Franquia
		oHtml:ValByName( "LHP_FATMIC"  , TRANSFORM( LHP->LHP_FATMIC,'@E 999' ) )  //% Microsiga
	EndIf
	
	oHtml:ValByName( "LHP_ADIANT"  , IIF(LHP->LHP_ADIANT=.T.,STR0014,STR0015) )  //Flag Adiantamento //"[SIM]"###"[NÃO]"
	oHtml:ValByName( "LHP_PASSAG"  , IIF(LHP->LHP_PASSAG=.T.,STR0014,STR0015) )  //Flag Passagem //"[SIM]"###"[NÃO]"
	oHtml:ValByName( "LHP_HOSPED"  , IIF(LHP->LHP_HOSPED=.T.,STR0014,STR0015) )  //Flag Hospedagem //"[SIM]"###"[NÃO]"
	
	//Se existir esse ponto de entrada alimento HTML (Tratamento CAIXARS)
	If ExistBlock("AE_MOTVIAG")
		oHtml:ValByName( "LHP_ALVEIC"  , IIF(LHP->LHP_ALVEIC=.T.,STR0014,STR0015) )  //Flag Aloc.Veic. //"[SIM]"###"[NÃO]"
	EndIf
	
	oHtml:ValByName( "LHP_HPASS"   , LHP->LHP_HPASS  )  //Observacao Passagem
	oHtml:ValByName( "LHP_HHOSP"   , LHP->LHP_HHOSP )   //Observacao Hospedagem
	
	//Observacoes Gerais
	_cOBSGer	:= ""
	DbSelectArea("SYP")
	DbSetOrder(1)
	If MsSeek(xFilial("SYP")+LHP->LHP_CODOBS)
		_cOBSGer := MSMM(LHP->LHP_CODOBS,,,,3)
	EndIf
	oHtml:ValByName( "LHP_CODOBS"  , _cOBSGer )  //Observacoes Gerais
	
	oHtml:ValByName( "LHP_VALORR"  , TRANSFORM( LHP->LHP_VALORR,'@E 999,999.99' ) ) //Valor R$
	oHtml:ValByName( "LHP_VALORU"  , TRANSFORM( _nValorU,'999,999.99' ) ) //Valor US$
	
	oHtml:ValByName( "LHP_CONTA"   , LHP->LHP_CONTA )  //Conta Corrente
	oHtml:ValByName( "LHP_AGENCI"  , LHP->LHP_AGENCI ) //Agencia
	oHtml:ValByName( "LHP_BANCO"   , LHP->LHP_BANCO )  //Banco
	
	oHtml:ValByName( "LHP_EMISS"   , LHP->LHP_EMISS )  //Data de Emissao
	oHtml:ValByName( "LHP_HRSOLP"  , LHP->LHP_HRSOLP ) //HORA DO ENVIO PARA APROVACAO/REPROVACA0 FASE 1
	
	If _cOpcao <> "SCA"
		If _cOpcao == "SC"// Rotina de Solicitação de Viagem
			//Verifica se o campo tem como conteudo SIGA1258 por exemplo, e fica 001258
			_anome	:= U_AEBuscaEML(IIF(UPPER(SUBSTR(LHP->LHP_SOLPOR,1,4))=="SIGA",;
			"00" + SUBSTR(LHP->LHP_SOLPOR,5,4), AllTrim(LHP->LHP_SOLPOR) )) //Solic. Sol Viagem
	
			_aAprov := U_AEBuscaEML(LHP->LHP_APROV)
		Else              // Rotina de Solicitação de Viagem para Depto de viagens
			_anome	:= U_AEBuscaEML(IIF(UPPER(SUBSTR(LHP->LHP_SOLFIN,1,4))=="SIGA",;
			"00" + SUBSTR(LHP->LHP_SOLFIN,5,4), AllTrim(LHP->LHP_SOLFIN) )) //Solic. Sol Viagem
			_aAprov  := U_AEBuscaEML(LHP->LHP_APROV)
			
			_aAprovf := U_AEBuscaEML(LHP->LHP_APROVF)
			
		Endif
		oHtml:ValByName( "LHP_HRAPV1"  , LHP->LHP_HRAPV1 ) //HORA DA APROVACAO/REPROVACA0 FASE 1
		oHtml:ValByName( "LHP_HRAPV2"  , LHP->LHP_HRAPV2 ) //HORA DA APROVACAO/REPROVACA0 FASE 2
		oHtml:ValByName( "LHP_SOLPOR"  , _anome[2] ) //Solicitado por
		//Verifica aprovador da etapa anterior ou da etapa corrente
		If _cOpcao == "SC"
			If SUBSTR(_cSubject,1,31) == STR0016 //"Solicitação de Viagem Reprovada"
				oHtml:ValByName( "LHP_APROV"   ,  IIF(empty(_aAprov[2]), "", STR0017 + _aAprov[2] + STR0018)) //Reprovacao 1Etapa - Sol. Viagem //"Solicitação de Viagem - Reprovada por "###"  às"
			Else
				oHtml:ValByName( "LHP_APROV"   ,  IIF(empty(_aAprov[2]), "", STR0019 + _aAprov[2] + STR0018)) //Aprovacao 1Etapa - Sol. Viagem //"Solicitação de Viagem - Aprovada por "###"  às"
			EndIf
		Else
			If SUBSTR(_cSubject,1,31) == STR0016 //"Solicitação de Viagem Reprovada"
				oHtml:ValByName( "LHP_APROV"   ,  IIF(empty(_aAprov[2]),  "", STR0019 + _aAprov[2] + STR0018)) //Aprovacao 1Etapa - Sol. Viagem //"Solicitação de Viagem - Aprovada por "###"  às"
				oHtml:ValByName( "LHP_APROVF"  ,  IIF(EMPTY(_aAprovf[2]), "", STR0020 + _aAprovf[2] + STR0021)) //Reprovacao 1Etapa - Sol. Viagem //"Depto de Viagem - Financeiro - Reprovado por "###" às"
			Else
				oHtml:ValByName( "LHP_APROV"   ,  IIF(empty(_aAprov[2]),  "", STR0019 + _aAprov[2] + STR0018)) //Aprovacao 1Etapa - Sol. Viagem //"Solicitação de Viagem - Aprovada por "###"  às"
				oHtml:ValByName( "LHP_APROVF"  ,  IIF(EMPTY(_aAprovf[2]), "", STR0022 + _aAprovf[2] + STR0018)) //Aprovacao 1Etapa - Sol. Viagem //"Depto de Viagem - Financeiro - Aprovado por "###"  às"
			EndIf
		EndIf
	ElseIf _cOpcao == "SCA"
		_anome:= U_AEBuscaEML(IIF(UPPER(SUBSTR(LHP->LHP_SOLPOR,1,4))=="SIGA",;
		"00" + SUBSTR(LHP->LHP_SOLPOR,5,4), AllTrim(LHP->LHP_SOLPOR) )) //Solic. Sol Viagem
		oHtml:ValByName( "LHP_SOLPOR"  , _anome[2] ) //Solicitado por
	EndIf
	oHtml:ValByName( "LHP_OPCAO"  , _cOpcao )

	If _cRotina <> "H2" .And. _cRotina <> "H4"
		oHtml:ValByName( "LINK_WF"    , cLinkWF )
	EndIf
	
	//Ponto de Entrada para que possa ser enviado itens a mais nos HTML's
	If ExistBlock("CamposHTML")
		oHtml := ExecBlock("CamposHTML", .F., .F.,{ oHtml })
	EndIf

Else
	If !lNoShow
		 MsgAlert(STR0023 , STR0024) //"Arquivo HTML não localizado em cDirWF+"'. "###"Atenção! "
	EndIf
	 Return 
Endif       

Return oProcess

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BuscaEml ³ Autor ³ Business Ingelligence ³ Data ³ 01.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Buscar Email no Cadastro de Usuarios de Viagem.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Modulo SIGAWF                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AEBuscaEml(_cCodDest)

chktemplate("CDV")

If AllTrim(_cCodDest) == STR0025 //"Administrador"
	_cNomDest := STR0025 //"Administrador"
ElseIf !Empty(_cCodDest) .And. SubStr(AllTrim(_cCodDest),1,1) <> "0"
	DbSelectArea("LHT")
	DbSetOrder(4)
	MsSeek(xFilial("LHT") + _cCodDest)
	_cCodDest := LHT->LHT_EMAIL //E-mail do usuario
	_cNomDest := LHT->LHT_NOME  //Nome do usuario
	DbSetOrder(1)
Else
	DbSelectArea("LHT")
	DbSetOrder(1)
	//Se usuario for Administrador , buscar o Colaborador (LHP_FUNC).
	MsSeek( xFilial("LHT") + IIF(AllTrim(_cCodDest)==STR0025,LHP->LHP_FUNC,_cCodDest)) //"Administrador"
	_cCodDest := LHT->LHT_EMAIL //E-mail do usuario
	_cNomDest := LHT->LHT_NOME  //Nome do usuario
Endif

// Se e-mail estiver vazio buscar parametro MV_MAILT
_cCodDest := AllTrim(IIf(Empty(_cCodDest),GETMV(ALLTRIM("MV_WFMAILT")),_cCodDest))

Return {_cCodDest,_cNomDest}

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Calchora ³ Autor ³ Business Intelligence ³ Data ³ 10.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o horario de Time-out, considerando hora util      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Uso       ³ Modulo SIGAWF                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AEcalchora(_hTempo)

chktemplate("CDV")

_a := {}
_hNovoTempo := "00:00"

_nTempMin := Val(left(_hTempo,2)) * 60 + Val(right(_hTempo,2))
_nTempMin := _nTempMin

_nHoras	  := Int (_nTempMin / 60)
_nMinutos := Int (_nTempMin - (_nHoras * 60) )

_nHorasf  := Val(left(_hnovotempo,2)) + _nHoras
_nMinutosf:= Val(right(_hnovotempo,2)) + _nMinutos

While _nMinutosf >= 60
	_nMinutosf -= 60
	_nHorasf += 1
Enddo

_hnovotempo := StrZero(_nHorasf,2)+':'+ StrZero(_nMinutosf,2)

aadd(_a,_hnovotempo)

Return  _a

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DefDest  ³ Autor ³ Business Intelligence ³ Data ³ 12.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Define o destinatário do e-mail                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Modulo SIGAWF                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AEDefDest(_nRecno, _cAprovacao,_nOpcao,_cTipo,_cOpcao)
Local _nDiasVia := 0
Local _cCodMun

ChkTemplate("CDV")

DbSelectArea("LHP")
DbSetOrder(1)
DbGoTo(_nRecno)
_nDiasVia:= LHP->LHP_Chegad - LHP->LHP_Saida
_cCodMun := LHP->LHP_CODMUN

If _cOpcao == "SC" //Verifica destinatario da 1º Fase - Envio da Solicitação de Viagem
	If _cTipo = "SUP"      // Aprovador I
		DbSelectArea("LHT")
 		DbSetOrder(1)
		MsSeek( xFilial("LHT") + LHP->LHP_SUPIMD ) 
	ElseIf _cTipo = "GAR" //Aprovador II 
		//Quando ocorre TIMEOUT na primeira aprovacao, o 2nd aprovador eh definido aqui
		DbSelectArea("LHT")
		DbSetOrder(1)
		MsSeek( xFilial("LHT") + GETMV("MV_WFANAC1") )
	ElseIf _cTipo = "FUNC" //COLABORADOR /SOLICITANTE
		DbSelectArea("LHT")
		DbSetOrder(4)
		MsSeek(xFilial("LHT") + LHP->LHP_SOLPOR)
		DbSetOrder(1)
	EndIf
Else	//Verifica destinatario da 2º Fase - Envio ao Depto de Viagem
	If _cTipo = "SUP"      // Autorizador 1
		//O Segundo aprovador eh definido aqui
		DbSelectArea("LHT")
		DbSetOrder(1)
		MsSeek( xFilial("LHT") + LHP->LHP_DGRAR) //Aprovador Depto Financeiro Informado na solicitacao da viagem
	ElseIf _cTipo = "GAR" // Autorizador 2
		//TIMEOUT DA 2NDA SOLICITACAO
		DbSelectArea("LHT")
		DbSetOrder(1)
		MsSeek( xFilial("LHT") + GETMV("MV_WFANAC2")) //2 Aprovador Nacional Depto Financeiro
	ElseIf _cTipo = "FUNC" //COLABORADOR /SOLICITANTE
		//SE O TIME OUT DA 2NDA SOLICITACAO NAO FOR RESPONDIDO, PASSA POR AQUI O ENVIO DO CANCELAMENTO
		DbSelectArea("LHT")
		DbSetOrder(4)
		MsSeek(xFilial("LHT") + LHP->LHP_SOLFIN)
		DbSetOrder(1)
	EndIf
EndIf

//Se e-mail for vazio, envia para o parametro WFMAILT do Workflow
_cMailDest:= IIF(Empty(LHT->LHT_EMAIL), GETMV(ALLTRIM("MV_WFMAILT")),LHT->LHT_EMAIL)
_cCoddest := IIF(Empty(LHT->LHT_CODMAT), "000000",LHT->LHT_CODMAT)

//Ponto de entrada para customizar o destinatario do e-mail
If ExistBlock("AE_DEFDEST")
	ExecBlock("AE_DEFDEST",.F.,.F.,{_cOpcao,_cTipo})
EndIf

Return { _cmaildest,_cTipo,_cCoddest }

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Console  ³ Autor ³ Business Intelligence ³ Data ³ 12.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o arquivo de log - CONOUT.LOG                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Modulo SIGAWF                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AEConsole(_ctxt)
Local cDirWF     := iif(IsSrvUnix(),"/workflow/","\workflow\")

chktemplate("CDV")

If _ctxt == NIL
	_ctxt := 'nulo'
Endif
nHdl2:= FOPEN(cDirWF+"conout.log",2)
IIF(nHdl2 > 0,,nHdl2:=MSFCREATE(cDirWF+"conout.log",0))
fseek(nHdl2,0,2)
_cLogBody := ''
_cLogBody += DTOC(ddatabase) +" @ "+ time() +" "+ _cTxt + CRLF
Fwrite(nHdl2,_cLogBody,len(_cLogBody))
FCLOSE(nHdl2)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o ³ ConsisteData ³ Autor ³ Business Ingelligence ³ Data ³ 01.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÁÄÄÂÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o horario de Time-out, considerando hora util       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Modulo SIGAWF                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AEConsisteData(periodo)
Local saldo := 0

chktemplate("CDV")

Nowdata := ddatabase
periodo := Val(Left(periodo,2)) + Val(Substr(periodo,4,2))/60
nowhora := Val(Left(Time(),2)) + Val(Substr(Time(),4,2))/60

pi := Val(Left(GetMV("MV_WFHINI"),2)) + Val(Right(GetMV("MV_WFHINI"),2))/60
pf := Val(Left(GetMV("MV_WFHFIM"),2)) + Val(Right(GetMV("MV_WFHFIM"),2))/60

horasuteis := pf - pi
horasinuteis :=   24 - (pf - pi)

_dDay   :=  DataValida(nowdata, .T.)
While _dDay  <>  nowdata
	nowdata := nowdata + 1
	_dDay   :=  DataValida(nowdata, .T.)
	If nowhora > pi
		saldo := saldo + (( 24 - nowhora ) + pi)
	ElseIf nowhora < pi
		saldo := saldo + (pi - nowhora) + 24
	Else
		saldo := saldo + 24
	Endif
	nowhora := pi
Enddo

If nowhora <= Pf
	If nowhora < pi
		Saldo   := saldo + (pi - nowhora)
		nowhora := pi
	Endif
Else
	saldo   := saldo + (24 - nowhora) + pi
	nowhora := pi
	nowdata := nowdata + 1
	_dDay   := nowdata
	nowdata := DataValida(nowdata, .T.)
	If _dDay  <>  nowdata
		saldo := saldo + ( 24 * (nowdata-_dDay))
	Endif
Endif

horafinal := nowhora + periodo

If horafinal <= pf
	saldo   := saldo + periodo
Else
	saldo   := saldo + (pf - nowhora)
	periodo := periodo - (pf -nowhora)
	saldo   := saldo + horasinuteis
	nowdata := nowdata + 1
	_dDay   :=  nowdata
	nowdata := DataValida(nowdata, .T.)
	If _dDay  <>  nowdata
		saldo    := saldo + ( 24 * (nowdata - _dDay) )
	Endif
	
	While periodo > horasuteis
		saldo    := saldo + 24
		nowdata  := nowdata + 1
		_dDay   :=  nowdata
		nowdata := DataValida(nowdata, .T.)
		If _dDay  <>  nowdata
			saldo    := saldo + ( 24 * ( nowdata-_dDay))
		Endif
		periodo := periodo - horasuteis
	Enddo
	saldo := saldo + periodo
Endif

_nDias    := Int(saldo  /24)
_nHoras   := mod(int(saldo),24)

_nsaldo   := int(saldo)
If _nSaldo > saldo
	_nSaldo := _nSaldo - 1
Endif

_nMinutos := Round((saldo-int(saldo))*60,0)

Return {_nDias, _nHoras, _nMinutos}

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MailConf ³ Autor ³ Business Intelligence ³ Data ³ 21.02.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail de resposta da Solicitação de Viagem          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Modulo SIGAWF                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AEMailConf(_nRecNo,_cstatus,_ctipo,_copcao,oProcess)
Local _nDiasVia := 0

chktemplate("CDV")

DbSelectArea("LHP")
DbSetOrder(1)
DbGoTo(_nRecno)
_nDiasVia := LHP->LHP_Chegad - LHP->LHP_Saida

DbSelectArea("LHT")
DbSetOrder(1)
If _cOpcao == "SC" // 1º Fase
	If _cTipo == "SUP" //Aprovador I
		MsSeek( xFilial("LHT") + LHP->LHP_SUPIMD )
		_csubject:=  STR0026 //"Solicitação de Viagem enviada para o Aprovador Suplente. Tempo para retorno da resposta ultrapassado"
		_cmailto := IIF(Empty(LHT->LHT_EMAIL), GETMV(ALLTRIM("MV_WFMAILT")),LHT->LHT_EMAIL)
	ElseIf _cTipo == "GAR"  //Aprovador II
		MsSeek( xFilial("LHT") +  GETMV("MV_WFANAC1") )
		_csubject:=  STR0027 //"Solicitação de Viagem enviada para o Solicitante. Tempo para retorno da resposta ultrapassado"
		_cmailto := IIF(Empty(LHT->LHT_EMAIL), GETMV(ALLTRIM("MV_WFMAILT")),LHT->LHT_EMAIL)
	EndIf
Else // 2º Fase
	If _cTipo = "SUP"      // Autorizador 1
		//O Segundo aprovador eh definido aqui
		DbSelectArea("LHT")
		DbSetOrder(1)
		MsSeek( xFilial("LHT") + LHP->LHP_DGRAR) //Aprovador Depto Financeiro Informado na solicitacao da viagem
	ElseIf _cTipo = "GAR" // Autorizador 2
		//TIMEOUT DA 2NDA SOLICITACAO
		DbSelectArea("LHT")
		DbSetOrder(1)
		MsSeek( xFilial("LHT") + GETMV("MV_WFANAC2")) //2 Aprovador Nacional Depto Financeiro
	ElseIf _cTipo = "FUNC" //COLABORADOR /SOLICITANTE
		//SE O TIME OUT DA 2NDA SOLICITACAO NAO FOR RESPONDIDO, PASSA POR AQUI O ENVIO DO CANCELAMENTO
		DbSelectArea("LHT")
		DbSetOrder(4)
		MsSeek(xFilial("LHT") + LHP->LHP_SOLFIN)
		DbSetOrder(1)
	EndIf

	If _cTipo == "SUP"      //Autorizador I
		MsSeek( xFilial("LHT") + LHP->LHP_DGRAR) //Aprovador Depto Financeiro Informado na solicitacao da viagem
		_csubject:=  STR0028 //"Solicitação de Viagem enviada para o Aprovador Suplente. Tempo para retorno da resposta ultrapassado."
		_cmailto := IIF(Empty(LHT->LHT_EMAIL), GETMV(ALLTRIM("MV_WFMAILT")),LHT->LHT_EMAIL)
	ElseIf _cTipo == "GAR"  //Autorizador II
		MsSeek( xFilial("LHT") + GETMV("MV_WFANAC2"))
		_csubject:=  STR0027 //"Solicitação de Viagem enviada para o Solicitante. Tempo para retorno da resposta ultrapassado"
		_cmailto := IIF(Empty(LHT->LHT_EMAIL), GETMV(ALLTRIM("MV_WFMAILT")),LHT->LHT_EMAIL)
	EndIf
EndIf

oProcess  := U_AEMontaEml("H2",_nRecNo,_aDest[1],,_cstatus,_cOpcao,oProcess)

oProcess:lTimeOut := .F.
oProcess:bTimeOut := {}
oProcess:bReturn  := ""

oProcess:cSubject := _csubject
oProcess:cTo      := _cMailTo
oProcess:Start()

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MailFin  ³ Autor ³ Business Intelligence ³ Data ³ 24.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail informativo para o Colaborador e o Solicitante³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Modulo SIGAWF                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AEMailFin(_nRecNo,_cTipo)
Local _nValorU
Local ni             
Local cErro			:= ""
Local lOK			:= .F.
Local lAutentica	:= .T.
Local aEmailConfig	:= {} 
Local aEmailParam	:= {{"MV_WFSMTP"	,STR0029},; //"Servidor"
						{"MV_WFACC"		,STR0030},; //"Conta autenticação"
						{"MV_WFPASSW"	,STR0031},; //"Senha autenticação"
						{"MV_WFMAIL"	,STR0032},; //"Conta envio"
						{"MV_WFMAILT"	,STR0033},; //"Conta padrão"
						{"MV_RELAUTH"	,STR0034}} //"Serv.SMTP exige autenticação"
Local lAE_MSGVIAJ := ExistBlock("AE_MSGVIAJ")
Local cRetMsg		:= ""

ChkTemplate("CDV")
For ni := 1 to Len(aEmailParam)
	aAdd(aEmailConfig,SuperGetMV(aEmailParam[ni][1],.F.,Nil))
	If Empty(aEmailConfig[ni]) .AND. ValType(aEmailConfig[ni]) # "L"
		cErro += "- " + aEmailParam[ni][1] + " (" + OemToAnsi(aEmailParam[ni][2]) + ")" + CRLF
	Else                      
		If ValType(aEmailConfig[ni]) == "C"
			aEmailConfig[ni] := AllTrim(aEmailConfig[ni])
		Endif
	Endif
Next ni
If Len(cErro) > 0
	Alert(STR0035 + CRLF + cErro) //"Erro no envio da mensagem. Os seguinte(s) parâmetros precisam ser configurados :"
	Return Nil
Endif

dbSelectArea("LHP")
LHP->(dbSetOrder(1))
LHP->(dbGoTo(_nRecno))
_cSolPor1 := (IIf(Upper(Substr(LHP->LHP_SOLPOR,1,4)) == "SIGA","00" + SUBSTR(LHP->LHP_SOLPOR,5,4), AllTrim(LHP->LHP_SOLPOR) ))
_nValorU:= LHP->LHP_VALORU + LHP->LHP_VAdiM2

If _cTipo <> "ADI" //E-mail completo
	_cMsg:= "<font face='Arial' color='#0099CC'> " + STR0036 + LHP->LHP_CODIGO + "<BR>" + ; //"Solicitação de Viagem - "
	STR0037 + LHP->LHP_LOCAL + CRLF + "<BR></FONT>" + ; //"Local: "
	"<BR>" + ;
	"<font face='Arial' color='#000000'> " + STR0038 + LHP->LHP_NFunc + CRLF + "<BR>" + ; //"Colaborador: "
	STR0039 + LHP->LHP_VOOIDA + CRLF + "<BR>" + ; //"Voo Ida......: "
	STR0040 + DTOC(LHP->LHP_SAIDA) + CRLF + "<BR>" + ; //"Data Ida.....: "
	STR0041 + LHP->LHP_HORAID + CRLF + "<BR>" + ; //"Horário Ida..: "
	STR0042 + LHP->LHP_AIRIDA + CRLF + "<BR>" + ; //"Cia Ida......: "
	STR0043 + LHP->LHP_VOOVTA + CRLF + "<BR>" + ; //"Voo Volta....: "
	STR0044 + DTOC(LHP->LHP_CHEGAD) + CRLF + "<BR>" + ; //"Data Volta...: "
	STR0045 + LHP->LHP_HORAVT + CRLF + "<BR>" + ; //"Horário Volta: "
	STR0046 + LHP->LHP_AIRVTA + CRLF + "<BR>" + ; //"Cia Volta....: "
	STR0047 + LHP->LHP_HPASS + CRLF + "<BR>" + ; //"Observação da Passagem..: "
	STR0048 + LHP->LHP_HHOSP + CRLF + "<BR>" + ; //"Observação da Hospedagem: "
	STR0049 + TRANSFORM((LHP->LHP_VALORR),'@E 999,999.99' ) + CRLF + "<BR>" + ; //"Adiantamentos.:  R$ "
	STR0050 + TRANSFORM((_nValorU),'999,999.99' ) + CRLF + "<BR>" + ; //".......................+ US$ "
	"_____________________________________________" + CRLF + "</FONT>
Else            //E-mail simples
	_cMsg := STR0051 + LHP->LHP_CODIGO + " para " + LHP->LHP_LOCAL //"Confirmação da Solicitação de Viagem nº "
Endif
_cSubject := STR0052 //"Informativo: Confirmação da Solicitação de Viagem."

//Busca e-mail do Colaborador(Func), se estiver vazio busca Parametro WFMAILT
dbSelectArea("LHT")
LHT->(dbSetOrder(1))
LHT->(MsSeek(xFilial("LHT") + AllTrim(LHP->LHP_FUNC)))
_cMail := IIf(Empty(LHT->LHT_EMAIL), aEmailConfig[5],LHT->LHT_EMAIL)

//Busca e-mail do Solicitante , se estiver vazio busca Parametro WFMAILT
If SubStr(AllTrim(_cSolPor1),1,1) <> "0"
	dbSelectArea("LHT")
	LHT->(dbSetOrder(4))
	LHT->(MsSeek(xFilial("LHT") + LHP->LHP_SOLPOR))
	_cMailCC := IIF(Empty(LHT->LHT_EMAIL), aEmailConfig[5],LHT->LHT_EMAIL)
	LHT->(dbSetOrder(1))
Else
	dbSelectArea("LHT")
	LHT->(dbSetOrder(1))
	LHT->(MsSeek(xFilial("LHT") + _cSolPor1))
	_cMailCC := IIF(Empty(LHT->LHT_EMAIL), aEmailConfig[5],LHT->LHT_EMAIL)
EndIf

_MailServer := aEmailConfig[1]
_MailS := ""
For ni := 1 to Len(_MailServer)
	If Subst(_MailServer,ni,1) <> ":"
		_MailS := _MailS + Subst(_MailServer,ni,1)
	Else
		Exit
	Endif
Next ni

If lAE_MSGVIAJ
	cRetMsg := ExecBlock("AE_MSGVIAJ",.F.,.F.,{_cMsg})
	If ValType(cRetMsg) == "C"
		_cMsg := cRetMsg
	EndIf
Endif

CONNECT SMTP SERVER _MailS Account aEmailConfig[2] PASSWORD aEmailConfig[3] TIMEOUT 200 RESULT lOk
If lOk 
	//Se o servidor SMTP exige autenticacao
	If aEmailConfig[6]
		lAutentica := MailAuth(aEmailConfig[2],aEmailConfig[3])
	Endif
	If lAutentica          
		SEND MAIL FROM aEmailConfig[4] ;
			TO _cMail ;
			CC _cMailCC ;
			SUBJECT _cSubject ;
			BODY _cMsg ;
			FORMAT TEXT ;
			RESULT lOk
		
		If !lOk                      
			GET MAIL ERROR cErro
			Alert(STR0053 + CRLF + cErro)	//"Erro no envio da mensagem."
		Endif
	Else
		Alert(STR0054)	//"Erro no envio da mensagem. Não foi possível autenticar o servidor SMTP"
	Endif
	DISCONNECT SMTP SERVER
Else
	GET MAIL ERROR cErro
	Alert(STR0055 + CRLF + cErro) //"Erro no envio da mensagem. Não foi possível estabelecer conexão com o servidor :"
Endif

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MlPrest  ³ Autor ³ B. I. ³                 Data ³ 01.04.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail informativo do Processo de Prest. de Contas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Modulo SIGAWF                                              ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AEMlPrest(_cCodigo)

Local _aFunc	:={}
Local ni             
Local cErro			:= ""
Local lOK			:= .F.
Local lAutentica	:= .T.
Local aEmailConfig	:= {} 
Local aEmailParam	:= {{"MV_WFSMTP"	,STR0029},;
						{"MV_WFACC"		,STR0030},;
						{"MV_WFPASSW"	,STR0031},;
						{"MV_WFMAIL"	,STR0032},;
						{"MV_WFMAILT"	,STR0033},;
						{"MV_RELAUTH"	,STR0034}}

ChkTemplate("CDV")
For ni := 1 to Len(aEmailParam)
	aAdd(aEmailConfig,SuperGetMV(aEmailParam[ni][1],.F.,Nil))
	If Empty(aEmailConfig[ni]) .AND. ValType(aEmailConfig[ni]) # "L"
		cErro += "- " + aEmailParam[ni][1] + " (" + OemToAnsi(aEmailParam[ni][2]) + ")" + CRLF
	Else                      
		If ValType(aEmailConfig[ni]) == "C"
			aEmailConfig[ni] := AllTrim(aEmailConfig[ni])
		Endif
	Endif
Next ni
If Len(cErro) > 0
	Alert(STR0035 + CRLF + cErro) //"Erro no envio da mensagem. Os seguinte(s) parâmetros precisam ser configurados :"
	Return Nil
Endif
dbSelectArea("LHP")
LHP->(dbSetOrder(1))
LHP->(MsSeek(xFilial("LHP") + _cCodigo))

_aFunc	:= U_AEBuscaEML(LHP->LHP_FUNC)

//U_AEconsole("<--------FUNCAO PRESTACAO DE CONTAS ------------>")
_cMsg:= "<font face='Arial' color='#000000'> " + STR0056 + LHP->LHP_CODIGO + CRLF + ; //"Prestação de Conta nº "
STR0057 + _aFunc[2] + STR0058 +  CRLF + "</FONT><BR><BR>" + ; //" do Colaborador " " em atraso. "
"<font face='Arial' color='#FF0000'><B>" + STR0059 + "</B></FONT>" //"O Sistema está bloqueado para novas solicitações."

_cSubject := STR0060 //"Relatório de Prestação de Contas em Atraso"

//Busca e-mail do Colaborador - LHP_FUNC
dbSelectArea("LHT")
LHT->(dbSetOrder(1))
LHT->(MsSeek( xFilial("LHT") + ALLTRIM(LHP->LHP_FUNC)))
_cMlCola  := IIF(Empty(LHT->LHT_EMAIL), aEmailConfig[5], LHT->LHT_EMAIL)

//Busca e-mail do Solicitante, se usuario for igual ao Colaborador , busca Aprovador
//LHP_SOLPOR ou LHP_APROV
_cSolPor1 := (IIF(UPPER(SUBSTR(LHP->LHP_SOLPOR,1,4))=="SIGA","00" + SUBSTR(LHP->LHP_SOLPOR,5,4), AllTrim(LHP->LHP_SOLPOR) ))
dbSelectArea("LHT")
LHT->(dbSetOrder(1))
LHT->(MsSeek( xFilial("LHT") + IIF(AllTrim(LHP->LHP_FUNC)== _cSolPor1,AllTrim(LHP->LHP_APROV), _cSolPor1)))
_cMlSoli  := IIF(Empty(LHT->LHT_EMAIL), aEmailConfig[5],LHT->LHT_EMAIL)

_MailServer := aEmailConfig[1]
_MailS := ""
For ni := 1 to Len(_MailServer)
	If Subst(_MailServer,ni,1) <> ":"
		_MailS := _MailS + Subst(_MailServer,ni,1)
	Else
		Exit
	Endif
Next

CONNECT SMTP SERVER _MailS Account aEmailConfig[2] PASSWORD aEmailConfig[3] TIMEOUT 200 RESULT lOk
If lOk 
	//Se o servidor SMTP exige autenticacao
	If aEmailConfig[6]
		lAutentica := MailAuth(aEmailConfig[2],aEmailConfig[3])
	Endif
	If lAutentica          
		SEND MAIL FROM aEmailConfig[4] ;
			TO _cMlCola ;
			CC _cMlSoli ;
			SUBJECT _cSubject ;
			BODY _cMsg ;
			FORMAT TEXT ;
			RESULT lOk
		
		If !lOk                      
			GET MAIL ERROR cErro
			Alert(STR0053 + CRLF + cErro) //"Erro no envio da mensagem."
		Endif
	Else
		Alert(STR0054)	//"Erro no envio da mensagem. Não foi possível autenticar o servidor SMTP"
	Endif
	DISCONNECT SMTP SERVER
Else
	GET MAIL ERROR cErro
	Alert(STR0055 + CRLF + cErro) //"Erro no envio da mensagem. Não foi possível estabelecer conexão com o servidor :"
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldLHTLog ºAutor ³Pablo Gollan Carrerasº Data ³  18/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para validacao de usuario do arquivo SIGAPSS         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CDV                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VldLHTLog()

Local lResp := .T.

If Type("LHT_LOGIN") # "U"
	If !Empty(M->LHT_LOGIN)
		If !UsrExist(M->LHT_LOGIN)
			lResp := .F.
		Else
			M->LHT_LOGIN := UsrRetName(M->LHT_LOGIN)
		Endif		
	Endif
Endif

Return lResp
