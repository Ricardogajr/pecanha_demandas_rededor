#Include 'Protheus.ch'
#Include 'parmtype.ch'

/*/{Protheus.doc} F0200602 

@Project MAN00000463301_EF_006 001
@author bruno.aferreira
@since 07/10/2016
@version 12.1.7
@param dDATADE, date, descricao
@param dDATAATE, date, descricao
/*/
User Function  F0200602(dDataDe, dDateAte)
	Local lRet := .F.
	
	cErroMsg := "Data final informada é menor que a data inicial." + CRLF
	cErroMsg += "Favor verificar as Datas Informadas."
	
	If Empty(dDateAte)
		Alert ("Pergunta 'Data até?' Não pode ser deixado em branco")
	Elseif dDataDe > dDateAte
		MsgInfo (cErroMsg)
	Else
		lRet:= .T.
	Endif

Return lRet