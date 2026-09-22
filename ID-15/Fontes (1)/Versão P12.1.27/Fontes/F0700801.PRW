#include 'protheus.ch'
#include 'apwebsrv.ch'
#INCLUDE 'FWMVCDEF.CH'
/*{Protheus.doc} F0700801
Validação para incluir e alterar
@author Fernando Carvalho
@since 23/01/2017
@Project MAN0000007423041_EF_008
@param oRegFabricante, objeto, (Descrição do parâmetro)
*/
User Function F0700801(oRegFabricante)
   Local cRetorno := ""
   Local aCampos  := {}
   Local nOperation := MODEL_OPERATION_INSERT
   
   AAdd(aCampos, {"P13_FILIAL", oRegFabricante:cFilFab})
   If ! Empty(oRegFabricante:cCOD )
      AAdd(aCampos, {"P13_COD", oRegFabricante:cCOD   })
      nOperation := MODEL_OPERATION_UPDATE
   EndIf
   AAdd(aCampos, {"P13_TIPO"  , oRegFabricante:cTIPO  }) 
   AAdd(aCampos, {"P13_DESCR" , oRegFabricante:cDESCR })
   AAdd(aCampos, {"P13_CGC"	  , oRegFabricante:cCGC   })
   AAdd(aCampos, {"P13_MSBLQL", oRegFabricante:cMSBLQL})
   AAdd(aCampos, {"P13_ID"    , U_GetIntegID()        })//-- função pra pegar o ID          	
    
   cRetorno := U_F0700001("P13", {2}, "F0700701", "MASTER", aCampos, , nOperation) //-- chamar função de log
   
   If ! Upper(Left(cRetorno,4)) == 'ERRO'
      cRetorno := "OK|" + P13->P13_COD
   EndIf

    aCampos := ASize(aCampos, 0)
    aCampos := Nil

Return cRetorno