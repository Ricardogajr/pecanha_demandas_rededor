/*
//=============================================================================================\\
// Programa   E-Mail   | Autor  Diego Fraidemberge Mariano                | Data    28/08/24   ||
//=============================================================================================||
//Desc.     | Classe para envio de email. Busca dados nos parâmetros os métodos sempre retornam||
//          | .t. ou .f., e a MSG de erro esta armazenada no elemento cError.                  ||
//          | Use o método ExibeErro ou usar o elemento diretamente.                           ||
//=============================================================================================//
*/
#Include "Protheus.ch"   //  padrão
#include "ap5mail.ch"    // definições para emails

*=====================================================================================================================================*
user Function EmailClass()	//--- Função existente somente para aparecer este programa no INSPETOR DE OBJETOS,
							//		e para testar se este programa está compilado no repositório...
*=====================================================================================================================================*
Return .T.

*=====================================================================================================================================*
Class EMail	// Classe para envio de email
*=====================================================================================================================================*
	Data cSMTPServer										// nome do servidor	
	Data cMailConta											// remetente
	Data cMailFrom                                          // remetente do email
	Data cMailSenha											// senha do remetente
	Data lAutentica											// Determina se o Servidor de Email necessita de Autenticação
	Data cUserAut											// Usuário para Autenticação no Servidor de Email
	Data cPassAut											// Senha para Autenticação no Servidor de Email
	Data aEmail												// array com os destinos
	Data aEmailCC											// array com os destinos
	Data aEmailCCo											// array com os destinos
	Data cAssunto											// assunto
	Data cMensagem											// corpo da msg ; pode ser um html
	Data aAnexos											// arquivos anexados
	Data cAnexo
	Data cError												// recupera a msg de erro
	Data lExibeErro											// .F. não exibe mensagem de erro/alerta, .T. Exibe o erro em TELA (normal) ou no CONSOLE.LOG (Background)
	Data lError												// .F. para sucesso e .T. para problemas
    Data cErrorMet											// Nome do método onde ocorreu o erro
   
	Method New() Constructor								// Método contrutor que inicializa o objeto
	Method Destino(cEMail)									// define os endereços de destino
	Method DestCC(cEMail)									// define os endereços de destino
	Method DestCCo(cEMail)									// define os endereços de destino
	Method Assunto(cTexto)									// Define o assunto
	Method Mensagem(cTexto,lAdd)							// Define o corpo da Mensagem. Pode ser um HTML. (cTexto=Mensagem, lAdd=.T. para ADICIONAR À MENSAGEM EXISTENTE, lAdd=.F. PARA INICIALIZAR A MENSAGEM)
	Method Anexo(cAnexo)				                    // Carrega anexos ao email
	Method MandaMail()										// Envia o email registrado
    Method Parametros()										// Configura os parâmetros no SX6 
    Method SetError(cTexto,lErro,cMetodo,lExibeMsg)	        // Marca a ocorrencia de erro no objeto
   															//		cTexto=Mensagem de Erro/Alerta
   															//		lErro=.T. Houve erro //	lErro=.F. Não houve erro
   															//		cMetodo=Nome do Método da Classe E-Mail onde ocorreu a mensagem
   															//		lExibeMsg=.T.	Exibe a mensagem de erro	//	lExibeMsg=.F.	Não exibe a mensagem de erro
    Method ExibeErro()										// Exibe a mensagem de erro
	Method SetGetShowErr(cOnOff)							// liga ("ON") ou desliga ("OFF") a exibição das mensagens de erro do objeto E-mail; Sem parâmetros retorna o estado atual
EndClass

*=====================================================================================================================================*
Method New() class EMail                           // Inicializa a classe com valores básicos
*=====================================================================================================================================*
	Self:cSMTPServer:= AllTrim(GetMv("MV_RELSERV"))				// nome do servidor
	Self:cMailconta := AllTrim(GetMv("MV_RELACNT"))	
	Self:cMailfrom  := AllTrim(GetMv("MV_RELFROM"))  			// remetente
	Self:cMailsenha := AllTrim(GetMv("MV_RELPSW"))				// senha do remetente
	Self:lAutentica := GetMv("MV_RELAUTH",,.F.)					// Determina se o Servidor de Email necessita de Autenticação
	Self:cUserAut   := Alltrim(GetMv("MV_RELAUSR",," "))		// Usuário para Autenticação no Servidor de Email
	Self:cPassAut   := Alltrim(GetMv("MV_RELAPSW",," "))		// Senha para Autenticação no Servidor de Email
	Self:lExibeErro := .T.										// Flag que define se as mensagens de erro do objeto de e-mail serão exibidas (TELA/BACKGROUND)
	Self:aEmail     := {}										// array com os destinos
	Self:aEmailCC   := {}										// array com os destinos
	Self:aEmailCCo  := {}										// array com os destinos
	Self:cAssunto   := ""										// assunto
	Self:cMensagem  := ""										// corpo da msg ; pode ser um html
	Self:aAnexos    := {}										// arquivos anexados
	Self:SetError("Objeto Email inicializado",.F.,"NEW")		// recupera a msg de erro
return Self

*=====================================================================================================================================*
Method Destino(cEMail) class EMail	// Método que monta os destinatários do email
*=====================================================================================================================================*
	aAdd(Self:aEmail,If(Empty(cEMail),"",cEMail))
	If	Empty(cEMail)
		Self:SetError("Endereço de E-mail Destino não definido corretamente",.T.,"Destino")
	EndIf
return Self:lError

*=====================================================================================================================================*
Method DestCC(cEMail) class EMail	// Método que monta os destinatários do email
*=====================================================================================================================================*
	aAdd(Self:aEmailCC,If(Empty(cEMail),"",cEMail))
	If	Empty(cEMail)
		Self:SetError("Endereço de E-mail Destino CC não definido corretamente",.T.,"Destino")
	EndIf
return Self:lError

*=====================================================================================================================================*
Method DestCCo(cEMail) class EMail	// Método que monta os destinatários do email
*=====================================================================================================================================*
	aAdd(Self:aEmailCCo,If(Empty(cEMail),"",cEMail))
	If	Empty(cEMail)
		Self:SetError("Endereço de E-mail Destino CCo não definido corretamente",.T.,"Destino")
	EndIf
return Self:lError

*=====================================================================================================================================*
Method Assunto(cTexto) class EMail 		// Método que define o assunto do email
*=====================================================================================================================================*
	Self:cAssunto	:=	cTexto
	If	Empty(Self:cAssunto)
		Self:SetError("Assunto do E-mail não definido corretamente",.T.,"Assunto")
	EndIf
return Self:lError 

*=====================================================================================================================================*
//user method Anexo(cAnexo) class u_E_mail //| Método que carrega os anexos do email |		
Method Anexo(cAnexo) class EMail //| Método que carrega os anexos do email |
*=====================================================================================================================================*
    If	Empty(cAnexo)
		Self:SetError("Anexo do E-mail não definido corretamente",.T.,"Anexo")
	Else
		aadd(self:aAnexos,cAnexo)
	EndIf
return self:lError

	
*=====================================================================================================================================*
Method Mensagem(cTexto,lAdd) class EMail			// Método que monta o corpo do email
*=====================================================================================================================================*
	Default lAdd:=.F.
//	Try
		If lAdd
			Self:cMensagem	+=	cTexto
		Else
			Self:cMensagem	:=	cTexto
		EndIf
//	Catch oErroTry
//		Self:SetError("Erro na atribuição do corpo do E-mail (campo 'Mensagem'): "+oErroTry:Description+ENTER+oErroTry:ErrorStack,.T.,"Mensagem")
//	EndTry
return Self:lError

*=====================================================================================================================================*
Method MandaMail() class EMail	// Método que efetivamente envia o e-mail
*=====================================================================================================================================*
Local cError

Self:lError := .F. 

If !Empty(Self:cSMTPServer) .And. !Empty(Self:cMailConta) .And. !Empty(Self:cMailSenha)							// Existe uma conta configurada
	If	!Empty(Self:cMensagem)																					// existe mensagem
		If Len(Self:aEmail)	>	0												 								// existe destinatário
			If MailSmtpOn(Self:cSMTPServer,Self:cMailConta,Self:cMailSenha)										// Efetiva a conexão
				If Self:lAutentica																				// precisa autenticação
					If !MailAuth(Self:cUserAut,Self:cPassAut)													// tenta autenticar
						GET MAIL ERROR cError																	// verifica erro no autenticação
						Self:SetError(cError,.T.,"MandaMail - MailAuth")													// marca que houve erro
					EndIf
				EndIf
				If !Self:lError																					// não houve erro
					//If !MailSend(Self:cMailConta,Self:aEmail,{},{},Self:cAssunto,Self:cMensagem,Self:aAnexos)	// não conseguiu enviar
					If !MailSend(Self:cMailFrom,Self:aEmail,Self:aEmailCC,Self:aEmailCCo,Self:cAssunto,Self:cMensagem,Self:aAnexos)
						GET MAIL ERROR cError																	// verifica erro no envio
						Self:SetError(cError,.T.,"MandaMail - MailSEnd")
						Self:lError := .T.													// marca que houve erro
					Else
						Self:lError := .F. 
					EndIf
				EndIf
				MailSmtpOff()
			Else
				GET MAIL ERROR cError		  																	// verifica erro na conexão
				Self:SetError(cError,.T.,"MandaMail - MailSmtpOn")															// marca que houve erro
			EndIf
		Else
			Self:SetError("Não foi informado nenhum destinatário",.F.,"MandaMail")								// marca que houve erro
		EndIf
	Else
		Self:SetError("Não há mensagem para ser enviada no e-mail",.F.,"MandaMail")								// marca que houve erro
	EndIf
Else
	Self:SetError("Conta de E-Mail não configurada",.F.,"MandaMail")											// marca que houve erro
EndIf
Return( Self:lError )

*=====================================================================================================================================*
Method Parametros() class EMail  // Método para configuração dos parâmetros no SX6
*=====================================================================================================================================*
local oDlg, nGrava:=0 , cTitulo:= "Parâmetros para envio de Email"
local aSay := {},aGet := {} ,cVar:="" ,cBloco:="", i:=0
		//	aoGets = 		valor, linha, coluna, texto
private	aoGets:= {	{padr(AllTrim(GetMv("MV_RELSERV",," ")),120),"Servidor SMTP"       ,"MV_RELSERV",.f.},;
							{padr(AllTrim(GetMv("MV_RELACNT",," ")),120),"Conta remetente"     ,"MV_RELACNT",.f.},;
							{padr(AllTrim(GetMv("MV_RELPSW" ,," ")),120),"Senha remetente"     ,"MV_RELPSW" ,.t.},;
							{padr(Alltrim(GetMv("MV_RELAUSR",," ")),120),"Usuário Autenticador","MV_RELAUSR",.f.},;
							{padr(Alltrim(GetMv("MV_RELAPSW",," ")),120),"Senha Autenticador"  ,"MV_RELAPSW",.t.}}

Self:lAutentica := GetMv("MV_RELAUTH",,.F.)			//Determina se o Servidor de Email necessita de Autenticação
Define MSDialog oDlg Title cTitulo						// definição da janela e suas propriedades
oDlg:nLeft		:=	0;	oDlg:nTop	:=	0					// a partir Canto Superior Esquerdo
oDlg:nWidth		:=	400										// Comprimento
oDlg:nHeight	:=	100 + Len(aoGets)*40					// Altura
oDlg:lCentered	:=	.T.

@ 02,060	BUTTON	"Gravar"	SIZE 40,10 ACTION ( nGrava:=1,oDlg:end() ) OF oDlg PIXEL  // botões de controle aparecem centralizados
@ 02,105	BUTTON	"Sair"	SIZE 40,10 ACTION ( nGrava:=0,oDlg:end() ) OF oDlg PIXEL  //

for i:= 1 to Len(aoGets)
	
	aadd( aSay, TSAY():Create(oDlg) )   // cria um label
	aSay[i]:cCaption := aoGets[i,2]     // com este texto
	aSay[i]:nLeft := 05                 // nestas posições
	aSay[i]:nTop := i*40
	aSay[i]:nWidth := 120
	aSay[i]:nHeight := 12
	
	cVar:="Var"+strZero(i,3,0)											// criação dinâmica da nome da variável
	&cVar := aoGets[i,1]													// criação dinâmica da variável
	cBloco := "{|u| If(PCount()>0,"+cvar+":=u,"+cvar+") }"	// criação do Code Block que associa a variavel ao get
	aadd( aGet,TGET():Create(oDlg) )									// cria o get
	aget[i]:nLeft		:=	aSay[i]:nLeft								// a propriedade bSetGet é responsável pela associação
	aget[i]:nTop		:=	aSay[i]:nTop + 18							// do Edit Box a variável usando o code block definido
	aget[i]:nWidth		:=	oDlg:nWidth-30								// antes da criação do get, o nome desta variável está
	aget[i]:nHeight	:=	20												// declarado como str na prop. cVariable
	aget[i]:cVariable :=	cVar
	aget[i]:bSetGet	:=	&cBloco
	aget[i]:lPassWord	:=	aoGets[i,4]
	
next

@ 125,05 CHECKBOX Self:lAutentica Prompt "Servidor requer Autenticação"  SIZE 120,08 PIXEL OF oDlg

oDlg:Activate()
If nGrava==1																											// a janela foi fechada usando o botão grava
	for i:= 1 to len(aoGets)
		cVar:="Var"+strZero(i,3,0)
		If !SetMv( Upper( aoGets[i,3]) , &cVar )																// o nome do parâmetro deve ser sempre maiúsculo
			Self:SetError("Falha na gravação do parâmetro "+aoGets[i,3],.T.,"Parâmetros")			// marca que houve erro
		EndIf
	next
	SetMv("MV_RELAUTH",Self:lAutentica)
	//
	If !Self:lError
		Self:cSMTPServer:= AllTrim(GetMv("MV_RELSERV"))														// nome do servidor
		Self:cMailconta := AllTrim(GetMv("MV_RELACNT"))														// remetente
		Self:cMailsenha := AllTrim(GetMv("MV_RELPSW"))														// senha do remetente
		Self:lAutentica := GetMv("MV_RELAUTH",,.F.)															// Determina se o Servidor de Email necessita de Autenticação
		Self:cUserAut   := Alltrim(GetMv("MV_RELAUSR",," "))										  		// Usuário para Autenticação no Servidor de Email
		Self:cPassAut   := Alltrim(GetMv("MV_RELAPSW",," "))										 		// Senha para Autenticação no Servidor de Email
		//Self:SetError("Parâmetros gravados com sucesso",Self:lError,"Parâmetros")					// marca que não houve erro
		Self:SetError("Parâmetros gravados com sucesso",Self:lError,"Parâmetros")					// marca que não houve erro
	EndIf
	//
Else
	Self:SetError("A configuração não foi alterada",Self:lError,"Parâmetros")						// marca que houve erro
EndIf
return Self:lError

*=====================================================================================================================================*
Method SetError(cTexto,lErro,cMetodo) class EMail          // Marca a ocorrência de erro
*=====================================================================================================================================*
	Default cTexto:="Erro indefinido"
	Self:cError:=cTexto
	Self:lError:=lErro
	Self:cErrorMet:=Upper(cMetodo)
    //AR   If Self:lExibeErro
    If Self:lExibeErro .And. Self:lError //AR
	   Self:ExibeErro()
	EndIf
return Self:lError

*=====================================================================================================================================*
Method SetGetShowErr(cOnOff) Class EMail
//	Funcionalidade:	Método com função dupla. Este método pode ser chamado através de um programa/rdmake desenvolvido pelo analista.
//							Este método RETORNARÁ qual a configuração da exibição das mensagens de erro do objeto E-MAIL.
//							Para executar este método, o objeto estar instanciado.
//							Chamada do método				Parâmetro		Retorno
//							---------------------		-------------	-------------------------------------------------------------------------------------------------
//							:SetGetShowErr()				nenhum			Retornará a configuração CORRENTE da exibição de erro do objeto (.T. para EXIBE, ou .F. para NÃO EXIBE)
//							:SetGetShowErr('ON')			'ON'				Irá ativar a exibição de erro do objeto
//							:SetGetShowErr('OFF')		'OFF'				Irá desativar a exibição de erro do objeto
//							----------------------------------------------------------------------------------------------------------------------------------------
//							Observação: A interferência na configuração da exibição de erro/alerta do objeto, via este método, irá afetar apenas a execução atual do mesmo.
*=====================================================================================================================================*
If valtype(cOnOff)=="C"
	cOnOff:= Trim(cOnOff)
	Self:lExibeErro := if( cOnOff=="ON",  .T., Self:lExibeErro )
	Self:lExibeErro := if( cOnOff=="OFF", .F., Self:lExibeErro )
EndIf
Return Self:lExibeErro

*=====================================================================================================================================*
Method ExibeErro() class EMail  // Método para exibição do aviso de erro 
*=====================================================================================================================================*
If !isBlind()
   If Self:lError
	   MsgStop(Self:cError,"Classe E-mail - Método "+AllTrim(Self:cErrorMet))
   Else 
	   MsgInfo(Self:cError,"Classe E-mail - Método "+AllTrim(Self:cErrorMet))
   EndIf
Else
   ConOut("["+DtoC(Date())+" || "+Time()+"] "+AllTrim(Self:cAssunto)+": Classe E-mail - Método "+AllTrim(Self:cErrorMet)+" <<< "+If(Self:lError,"ERRO","INFO")+" >>>: "+AllTrim(Self:cError))
EndIf
return Self:lError
