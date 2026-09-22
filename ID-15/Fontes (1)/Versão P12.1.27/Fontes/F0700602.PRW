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
    
    AAdd(aCampos,{"NNR_FILIAL", LocalEstoque:cFil		})
    AAdd(aCampos,{"NNR_CODIGO", LocalEstoque:cCodigo  })
    AAdd(aCampos,{"NNR_DESCRI", LocalEstoque:cDescri  })  
    AAdd(aCampos,{"NNR_TIPO"  , LocalEstoque:cTipo    })
    AAdd(aCampos,{"NNR_MSBLQL", LocalEstoque:cMsblql  })   
    AAdd(aCampos,{"NNR_XCUSTO", LocalEstoque:cCCusto  })   
    AAdd(aCampos,{"NNR_XID"   , U_GetIntegID()        }) //-- função pra pegar o ID    

    cRetorno := U_F0700001("NNR", {2}, "AGRA045", "NNRMASTER", aCampos,) 
    If ! Upper(Left(cRetorno,4)) == 'ERRO'
        cRetorno := "OK|"+NNR->NNR_CODIGO
    EndIf


	aCampos := ASize(aCampos,0)
   aCampos := Nil

Return cRetorno