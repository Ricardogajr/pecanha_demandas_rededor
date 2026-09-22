#include 'protheus.ch'
#include 'apwebsrv.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} F0700602
Função para Cadastrar/Alterar o Local de Estoque
@type function
@author queizy.nascimento
@since 26/01/2017
@version 1.0
@param LocalEstoque, ${param_type}, (Descrição do parâmetro)
@Project MAN0000007423041_EF_006
/*/
User Function F0700602(LocalEstoque)
	Local cRetorno := ""
	Local aCampos  := {}
	Local lRet := .T.

	Public __xOsetor := LocalEstoque

	AAdd(aCampos,{"NNR_FILIAL", LocalEstoque:cFil		})
	AAdd(aCampos,{"NNR_CODIGO", LocalEstoque:cCodigo  })
	AAdd(aCampos,{"NNR_DESCRI", LocalEstoque:cDescri  })
	AAdd(aCampos,{"NNR_TIPO"  , LocalEstoque:cTipo    })
	AAdd(aCampos,{"NNR_MSBLQL", LocalEstoque:cMsblql  })
	AAdd(aCampos,{"NNR_XCUSTO", LocalEstoque:cCCusto  })
	AAdd(aCampos,{"NNR_XID"   , U_GetIntegID()        }) //-- função pra pegar o ID

	DbSelectArea("NNR")
	NNR->(DbSetOrder(1))
	If LocalEstoque:cMSBLQL == "2"
		//lRet := ValidaCusto(PadR(LocalEstoque:cCCusto,TamSx3("CTT_CUSTO")[1]),NIL,,,.T.)//Função padrão MATXFUNB para validar custo - Lucas Miranda de Aguiar 02/01/2025
		DbSelectArea("CTT")
		DbSetOrder(1)
		if DbSeek(XFILIAL("CTT")+PadR(LocalEstoque:cCCusto,TamSx3("CTT_CUSTO")[1]))
			if CTT->CTT_BLOQ == "1"
				lRet := .F.
				cRetorno := "ERRO|NNR_XCUSTO |  C.Custo está bloqueado. | " + LocalEstoque:cCCusto
			else
				lRet := U_P52VLDCC(LocalEstoque:cCCusto)
				if !lRet 
					cRetorno := "Centro de custo não autorizado para uso nesta filial! | " + LocalEstoque:cCCusto
				endif
			endif
		else
			lRet := .F.
			cRetorno := "ERRO|NNR_XCUSTO |  C.Custo não existe. | " + LocalEstoque:cCCusto
		EndIf
		
		If !lRet
			aCampos := ASize(aCampos, 0)
			aCampos := Nil
			//cRetorno := "ERRO|NNR_XCUSTO |  C.Custo inválido, bloqueado, não preenchido ou não existente. | " + LocalEstoque:cCCusto
			Return cRetorno		
		EndIf

	EndIf

	cRetorno := U_F0700001("NNR", {2}, "AGRA045", "NNRMASTER", aCampos,)
	If ! Upper(Left(cRetorno,4)) == 'ERRO'
		cRetorno := "OK|"+NNR->NNR_CODIGO
	EndIf


	aCampos := ASize(aCampos,0)
	aCampos := Nil

Return cRetorno
