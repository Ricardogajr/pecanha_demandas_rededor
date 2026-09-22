#Include 'PROTHEUS.CH'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} F0700301
Método que insere, atualiza ou apaga o registro.
@type 		function
@author 	alexandre.arume
@since 		24/01/2017
@version 	1.0
@param 		oSetor, objeto, Objeto com os campos e valores
@param 		nOpc, numérico, 1 = Upsert; 2 = Delete
@project	MAN000007423041_EF_003
@return 	cRetorno, Mensagem de sucesso ou erro

/*/
User Function F0700301(oSetor, nOpc)

	Local cRetorno := ""
	Local aCampos  := {}
	Local lRet := .T.

	Public __xOsetor := oSetor

	// Upsert.
	If nOpc == 1

		AAdd(aCampos,{"P11_FILIAL", oSetor:cFil })
		AAdd(aCampos,{"P11_COD"   , oSetor:cCod })
		AAdd(aCampos,{"P11_DESC"  , oSetor:cDesc   })
		AAdd(aCampos,{"P11_CCUSTO", oSetor:cCCusto })
		AAdd(aCampos,{"P11_MSBLQL", oSetor:cMSBLQL })
		AAdd(aCampos,{"P11_ID"    , U_GetIntegID() }) //-- função pra pegar o ID


		//Adiciona campos Onergy na integração de setores. Lucas Miranda de Aguiar 29/11/2024
		AAdd(aCampos,{"P11_ZONERG"    , .T. })
		AAdd(aCampos,{"P11_ZINTOG"    , "1" })

		DbSelectArea("P11")
		P11->(DbSetOrder(1))
		If oSetor:cMSBLQL == "2"
			//lRet := ValidaCusto(PadR(oSetor:cCCusto,TamSx3("CTT_CUSTO")[1]),NIL,,,.T.)//Função padrão MATXFUNB para validar custo - Lucas Miranda de Aguiar 29/11/2024
			If lRet
				If POSICIONE("CTT",1,XFILIAL("CTT")+PadR(oSetor:cCCusto,TamSx3("CTT_CUSTO")[1]),"CTT_BLOQ") == "1"
					lRet := .F.
				EndIf
			EndIf
			If !lRet
				aCampos := ASize(aCampos, 0)
				aCampos := Nil
				cRetorno := "ERRO|P11_CCUSTO |  C.Custo inválido, bloqueado ou não preenchido. | " + oSetor:cCCusto
				Return cRetorno
			EndIf
		EndIf


		cRetorno := U_F0700001("P11", {2}, "F0700101", "P11MASTER", aCampos, , )

		If ! Upper(Left(cRetorno,4)) == 'ERRO'
			cRetorno := "OK|"+P11->P11_COD
		EndIf

		// Delete.
	Else

		AAdd(aCampos,{"P11_FILIAL", 	oSetor:cFil		})
		AAdd(aCampos,{"P11_COD",    	oSetor:cCod		})

		cRetorno := U_F0700006("P11", {2}, "F0700101", 1, aCampos)

	EndIf

	aCampos := ASize(aCampos, 0)
	aCampos := Nil

Return cRetorno


//Função colocada no X3_VLDUSER do campo P11_CCUSTO para evitar validação do centro de custo em caso de inativação.
//Lucas Miranda de Aguiar 29/11/2024
User Function X0700301()
	Local lRet := Ctb105Cc()

	If Type("__xOsetor") <> "U"
		If __xOsetor:cMSBLQL == "1"
			lRet := .T.
		EndIf
	EndIf
Return lRet
