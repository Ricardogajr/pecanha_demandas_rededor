#INCLUDE "Protheus.ch"
#INCLUDE "APWEBSRV.CH"

/*
{Protheus.doc} W0702001()
Webservice responsavel pela inclusão/alteração no Cadastro de Clientes
@Author     Bruno de Oliveira
@Since		20/01/2017
@Version    P12.1.7
@Project    MAN0000007423041_EF_020
*/
User Function W0702001(); Return // --dummy

WSService W0702001 Description "WebService Server para inclusão/alteração no cadastro de clientes"
	WSData Cliente  as RegClient
	WSData cRetorno as String
	
	WSMethod UPSERTCLIENTE Description "Inclusão ou alteração no Cadastro de Clientes"
EndWSService

WSMethod UPSERTCLIENTE WSReceive Cliente WSSend cRetorno WSService W0702001
	::cRetorno := U_F0702001(Self:Cliente)
Return .T.

WSStruct RegClient
	WSData cFILREG  as String	//Filial
	WSData cCOD     as String	//Código Cliente
	WSData cLOJA    as String	//Loja do Cliente
	WSData cNOME    as String	//Nome
	WSData cNREDUZ  as String	//Nome Fantasia
	WSData cPESSOA  as String	//Tipo Pessoa Fisica/Juridica
	WSData cEND     as String	//Endereço
	WSData cCOMPLEM as String	//Complemento do Endereço
	WSData cBAIRRO  as String	//Bairro
	WSData cTIPO    as String	//Tipo do Cliente
	WSData cEST     as String	//Estado
	WSData cCEP     as String	//Cep
	WSData cCOD_MUN as String	//Código Municipio
	WSData cCGC     as String	//CNPJ/CPF do cliente
	WSData cPFISICA as String	//RG ou Passaporte
	WSData cPAIS    as String	//Pais
	WSData cCODPAIS as String	//Codigo Bacen
	WSData cEMAIL   as String	//E-mail
	WSData cXOPCM   as String	//Operadora (Sim/Não)
	WSData cINSCRM  as String	//Inscrição estadual do cliente
EndWSStruct
