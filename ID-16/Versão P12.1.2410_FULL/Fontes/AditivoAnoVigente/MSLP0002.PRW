#Include "Protheus.ch"
#Include "Totvs.ch"




User Function MSLP0002(cProds,cCampo)


	Local aArea := GetArea()
	Local nValor := 0
	Default cProds   := " "


	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	SD1->(DbSeek(SE2->(E2_FILIAL +E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)))

	While !(SD1->(EOF())) .And. AllTrim(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)) == AllTrim(SE2->(E2_FILIAL +E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA))

		If AllTrim(SD1->D1_COD) $ cProds
			nValor += SD1->&(cCampo)
		EndIf

		SD1->(DbSkip())
	EndDo


	RestArea(aArea)
Return nValor
