#include "Protheus.ch"
#include "topconn.ch"
#INCLUDE 'TBICONN.CH'
#Include "RPTDEF.CH" //Thais Paiva - 12013888
#INCLUDE 'PARMTYPE.CH' //Thais Paiva - 12013888
#DEFINE IMP_PDF 6 //Thais Paiva - 12013888
#define POP3 0
#define IMAP 1
#define MAPI 2

/*/{Protheus.doc} MT120GOK
Tratamento no PC antes de sua contabilização
@type function
@version P122410 
@author Lucas Aguiar
@since 5/7/2026
@return variant, return_description
/*/
User Function MT120GOK()

	Local cPedido    :=  PARAMIXB[1] // Numero do Pedido
	Local lInclui    :=  PARAMIXB[2] // Inclusão
	Local lExclusao  :=  PARAMIXB[4] // Exclusão
	Local nReCAtu    := SC7->(RECNO())
	Local cAliasC7   := GetNextAlias()
	Local cQuery := ""
	Local lPrim     := .F.
	Local cUser := ""
	Local cUpd := ""
	Local aArea := GetArea()


	If IsInCallStack("U_F0702601")
		Return
	EndIf

	If (isincallstack("MATA094") .Or. IsInCallStack("U_XMATA094"))
		
		If SCR->CR_TIPO == "MD"
			aAreaSC7 := SC7->(GetArea())
			SC7->(DbSetOrder(1))
			SC7->(MsSeek(cFilant + AllTrim(cPedido)))

			If !Empty(SC7->C7_MEDICAO)
				cUser := Posicione("CND",4,SCR->CR_FILIAL+AllTrim(SCR->CR_NUM),"CND_FORNEC")
				If !Empty(cUser)
					While SC7->(!Eof() .and. C7_FILIAL + C7_NUM == cFilant + AllTrim(cPedido))
						RecLock("SC7",.F.)
						SC7->C7_USER := cUser
						SC7->C7_OBS := Posicione("CND",4,SCR->CR_FILIAL+AllTrim(SCR->CR_NUM),"CND_OBS")
						SC7->C7_FORNECE :=  SCR->CR_XFORNEC
						SC7->C7_LOJA := SCR->CR_XLOJA
						SC7->C7_XNOMFOR := AllTrim(Posicione("SA2",1,xFilial("SA2")+AllTrim(SCR->CR_XFORNEC)+AllTrim(SCR->CR_XLOJA),"A2_NOME"))
						SC7->(MsUnlock())
						SC7->(DbSkip())
					EnddO
				EndIf
			EndIf
			aAreaSC7 := SC7->(GetArea())
		EndIF
	EndIf

	If lInclui
		If IsInCallStack("U_F1200709")
			SC7->(DbSetOrder(1))
			SC7->(MsSeek(cFilant + AllTrim(cPedido)))

			DbSelectArea("SC1")
			SC1->(DbSetOrder(1))
			While (SC7->(!EOF()) .And. SC7->C7_FILIAL+SC7->C7_NUM == cFilAnt+cPedido)
				If SC1->(DbSeek(SC7->C7_FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC))

					Reclock("SC1",.F.)
					If SC1->C1_QUJE+SC7->C7_QUANT >= SC1->C1_QUANT
						SC1->C1_QUJE := SC1->C1_QUANT
					Else
						SC1->C1_QUJE := SC1->C1_QUJE + SC7->C7_QUANT
					EndIf
					SC1->(MsUnlock())
				EndIf
				SC7->(DbSkip())
			EndDo
		EndIf
	EndIF
	If lExclusao
		aAReaSC7 := SC7->(GetArea())
		SC7->(DbSeek(cFilant + AllTrim(cPedido)))
		cTpCont 	:= AllTrim(CN9->CN9_TPCTO) 
		if !Empty(SC7->C7_MEDICAO) .And. cTpCont $ GetMv("EZ_XCONSER")
			cSMTP     := alltrim( getmv( 'MV_RELSERV' )) // smtp.ig.com.br ou 200.181.100.51
			cConta    := alltrim( getmv( 'MV_RELACNT' )) // fulano@ig.com.br
			cPass     := alltrim( getmv( 'MV_RELPSW'  )) // 123abc
			 cAssunto  := 'Cancelamento do Pedido de compra: ' + cPedido  + ' - Filial: ' + cFilNom + ' - Fornecedor: ' + cForNom
			 cCorpo    := U_MSEMAILPC()//alltrim( getmv( 'FS_EF12005' , , 'Caro fornecedor, <br> Anexo, enviamos o espelho do Pedido de Compra para seu conhecimento.<br>' ))
			 cRet      := ''
			 cMensagem := ''
			if CN9->CN9_XENVPC == 'S'	
				cArquivo := u_tewbtyr2( 'SC7' , SC7->(Recno()) , Nil , 1 )
				cRet := enviaemail( cSMTP      , ;
				cConta     , ;
				cPass      , ;
				Alltrim( SA2->A2_EMAIL )  , ;
				cAssunto   , ;
				cArquivo   , ;
				cMensagem  , ;
				alltrim( CN9->CN9_XEMAIL ) , ;
				SC7->(Recno())      )
			endif
			RestArea(aAReaSC7)
		endif
		
		If IsInCallStack("U_F1200709") .Or. IsInCallStack("CNTA121") .Or. IsInCallStack("CNTA120")
			cQuery := "SELECT * FROM " + RetSqlName("SC7")
			cQuery += " WHERE R_E_C_D_E_L_ <> 0 AND C7_FILIAL = '"+cFilAnt+"'"
			cQuery += " AND C7_NUM = '"+cPedido+"' ORDER BY R_E_C_N_O_ DESC "

			dbusearea( .T. , 'TOPCONN' , TCGenQry( , , cQuery ) , cAliasC7 , .F. , .T. )
			nRecSc1 := SC1->(RecNo())
			While (cAliasC7)->(!EOF())

				If (cAliasC7)->C7_ITEM == "0001" .And. lPrim
					Exit
				EndIf

				If (cAliasC7)->(C7_ITEM) == "0001"
					lPrim := .T.
				EndIf
				
				cUpd := "UPDATE "+RETSQLNAME("SC1")+ " SET C1_QUJE = 0, C1_PEDIDO = ' ', C1_XCONTR = ' ', C1_FORNECE = ' ',"
				cUpd += "C1_FLAGGCT = ' ' WHERE D_E_L_E_T_ = ' ' AND C1_FILIAL = '"+SC1->C1_FILIAL+"'"
				cUpd += " AND C1_XNUMMED = '"+(cAliasC7)->C7_MEDICAO+"'"
				TCSqlExec(cUpd)
				(cAliasC7)->(DbSkip())
			EndDo
			(cAliasC7)->(DbCloseArea())
		EndIf
	EndIf

	SC7->(DbGoto(nReCAtu))
	RestArea(aArea)
Return


/*/{Protheus.doc} enviaemail
Envia email de estorno da medicação de contrato.
@type function
@version  
@author Ricardo
@since 5/19/2026
@param cSMTP, character, param_description
@param cConta, character, param_description
@param cPass, character, param_description
@param cContaDes, character, param_description
@param cAssunto, character, param_description
@param cArquivo, character, param_description
@param cMensagem, character, param_description
@param cMailContr, character, param_description
@param nRecSC7, numeric, param_description
@return variant, return_description
/*/
static function enviaemail( cSMTP , cConta , cPass , cContaDes , cAssunto , cArquivo , cMensagem , cMailContr , nRecSC7 )
// ------------------------------------
	local lConSMTP   := .F.
	local lEnvEmail  := .F.
	local cError     := ''
	local cRet       := ''
	local cNomeAnexo := cArquivo
	Local _cBcc := Alltrim(SuperGetMV('MV_XPCCCO', .F., "")) //Thais Paiva 01/07/2021
	Local _cEmail := "" //Thais Paiva - 12013888
// ------------------------------------
	Connect SMTP Server cSMTP Account cConta Password cPass Result lConSMTP

	if lConSMTP

		if !IsInCallStack( 'U_F1200600' )

			cNomeAnexo := '\workflow\' + substr( cArquivo , rat( '\' , cArquivo ) + 1 )

			if !ExistDir( '\workflow' )
				mkdir( '\workflow' )
			endif

			//cpyt2s( cArquivo , '\workflow\' , .T. )
			__CopyFile( cArquivo , cNomeAnexo)

		endif

		//Início - Thais Paiva 01/07/2021
		//if empty( cMailContr )
		Do Case
		Case Empty( cMailContr ) .AND. Empty( _cBcc )
			SEND MAIL FROM cConta TO cContaDes               SUBJECT cAssunto BODY cMensagem ATTACHMENT cNomeAnexo Result lEnvEmail
			//else
		Case !Empty( cMailContr ) .AND. Empty( _cBcc )
			SEND MAIL FROM cConta TO cContaDes CC cMailContr SUBJECT cAssunto BODY cMensagem ATTACHMENT cNomeAnexo Result lEnvEmail
		Case Empty( cMailContr ) .AND. !Empty( _cBcc )
			SEND MAIL FROM cConta TO cContaDes BCC _cBcc SUBJECT cAssunto BODY cMensagem ATTACHMENT cNomeAnexo Result lEnvEmail
		Otherwise
			SEND MAIL FROM cConta TO cContaDes CC cMailContr BCC _cBcc SUBJECT cAssunto BODY cMensagem ATTACHMENT cNomeAnexo Result lEnvEmail
			//endif
		EndCase
		//Fim - Thais Paiva 01/07/2021

		//ferase( cNomeanexo ) Thais Paiva - 06/07/2021

		dbselectarea( 'SC7' ) // Ped.Compra / Aut.Entrega
		SC7->( dbgoto( nRecSC7 ))

		if !lEnvEmail // Erro no envio do email

			Get Mail Error cError
			cRet := 'Erro no envio do email: ' + cError

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cWFLStaEnv := 'ERRO'
			cWFLMsg3   := 'NÃO OK (3.2) - ' + cRet
// ------------------------------------

			reclock( 'SC7' , .F. )
			SC7->C7_XENVMAL := 'N'
			SC7->( msunlock() )

		else

// ------------------------------------
//          [ DOR06872720_TK_8056955 ]
// ------------------------------------
			cWFLStaEnv := 'OK'
			cWFLMsg3   := 'OK (3.0) - Conexão SMTP OK! Email enviado!'
// ------------------------------------

			reclock( 'SC7' , .F. ) 
			SC7->C7_XENVMAL := 'S'
			SC7->( msunlock() )

			//Início - Thais Paiva - 12013888
			_cEmail := SalvaEmail(cConta,cContaDes,cMailContr,_cBcc,cAssunto,cMensagem,cNomeAnexo) //Thais Paiva - 12013888
			If !Empty(Alltrim(_cEmail)) .AND. !IsInCallStack( 'U_F1200600' )
				//cpyt2s( _cEmail , '\workflow\' , .T. )
				__CopyFile( _cEmail , cNomeAnexo)
			EndIf

		endif

		Disconnect SMTP Server

	else // Erro na conexao com o SMTP Server

		Get Mail Error cError
		cRet := 'Erro na conexão SMTP: ' + cError

// ------------------------------------
//      [ DOR06872720_TK_8056955 ]
// ------------------------------------
		cWFLStaEnv := 'ERRO'
		cWFLMsg3   := 'NÃO OK (3.1) - ' + cRet
// ------------------------------------

	endif

return cRet
