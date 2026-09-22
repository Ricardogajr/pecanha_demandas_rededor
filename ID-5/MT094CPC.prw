#Include 'Protheus.ch'
/*/{Protheus.doc} MT094CPC	
O Ponto de Entrada MT094CPC tem como funcionalidade exibir informações de outros campos reais do pedido de compra/autorização de entrega no momento da liberação do documento. Campos do tipo MEMO não são exibidos na grid.
@type function
@version P122410 
@author Ricardo Junior
@since 12/4/2025
@return variant, String que contém o nome dos campos da tabela de pedido de compra/autorização de entrega intercalados com barras verticais.
/*/
User Function MT094CPC()

	//Local cCampos := "C7_DINICQ|C7_QUJE|C7_IPIBRUT|C7_VALICM" //  A separação dos campos devem ser feitos com uma barra vertical ( | ), igual é demonstrado no exemplo.
	Local cCampos := "" //  A separação dos campos devem ser feitos com uma barra vertical ( | ), igual é demonstrado no exemplo.
	//Customização para gerar amarração na CNN para que usuário tenha visão do contrato ou medição.
	if AllTrim(SCR->CR_TIPO) $ "CT|RV|MD"
		if AllTrim(SCR->CR_TIPO) $ "CT|RV"
			cCod := "037"
		else
			cCod := "035"
		endif

		DbSelectArea("CNN")
		CNN->(DbSetOrder(1))
		if !CNN->(DbSeek(Padr(SCR->CR_FILIAL, FwTamSX3("CNN_FILIAL")[1])+Padr(SCR->CR_USER, FwTamSX3("CNN_USRCOD")[1])+Padr(SCR->CR_NUM,FwTamSX3("CNN_CONTRA")[1])+Padr(cCod, FwTamSx3("CNN_TRACOD")[01])))
			RecLock("CNN",.T.)
			CNN->CNN_FILIAL := SCR->CR_FILIAL
			CNN->CNN_CONTRA := SCR->CR_NUM
			CNN->CNN_USRCOD := SCR->CR_USER
            CNN->CNN_TRACOD := cCod
			CNN->CNN_XMIGLT := DToS(Date()) + " " + Time()
			CNN->(MsUnlock())
		endif
	endif
Return(cCampos)
