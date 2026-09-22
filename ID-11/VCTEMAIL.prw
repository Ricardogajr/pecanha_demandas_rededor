#include "protheus.ch"
/*/{Protheus.doc} VCTEMAIL
Valida o prenchimento do campo Envio de email e mostra mensagem para usuário.
@type function
@version  P122410
@author Ricardo Junior
@since 5/6/2026
@return logical, Retorna se valida ou não o campo
/*/
User Function VCTEMAIL()
	Local lRet := .T.
	Local cMsg := SuperGetMv("MV_XMCTRV",,"Prezado(a), Você selecionou a opção de não enviar o pedido de compra de forma automática. O fornecedor não receberá o número do pedido e isso poderá impactar o processo de entrada da Nota Fiscal. Deseja continuar?")
	Local cCampo := ReadVar()
	Local nX := 0
	Local cMsgAux := ""
	Local nQuebra := 1

	if INCLUI .Or. FWIsInCallStack("U_xEMAICN9")

		aMsg := StrTokArr2(cMsg, " ")

		For nx := 01 To Len(aMsg)
			cMsgAux += aMsg[nX] + " "
			if  "." $ aMsg[nX]
				cMsgAux += CRLF
				nQuebra := 0
			endif
			if nQuebra == 12
				cMsgAux += CRLF
				nQuebra := 0
			endif
			nQuebra++
		Next nX

		if &(cCampo) == "N"
			if !MsgYesNo(cMsgAux, "Atenção")
				lRet := .F.
				M->CN9_XENVPC := "S"
			endif
		endif
	endif

Return lRet
