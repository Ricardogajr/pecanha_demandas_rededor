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
	
	// Upsert.
	If nOpc == 1
		
		AAdd(aCampos,{"P11_FILIAL", oSetor:cFil })
		AAdd(aCampos,{"P11_COD"   , oSetor:cCod })
		AAdd(aCampos,{"P11_DESC"  , oSetor:cDesc   })
		AAdd(aCampos,{"P11_CCUSTO", oSetor:cCCusto })
		AAdd(aCampos,{"P11_MSBLQL", oSetor:cMSBLQL })
		AAdd(aCampos,{"P11_ID"    , U_GetIntegID() }) //-- função pra pegar o ID
		
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
