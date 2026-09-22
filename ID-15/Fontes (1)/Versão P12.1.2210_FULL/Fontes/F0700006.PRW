#include 'protheus.ch'
#include 'fwmvcdef.ch'

/*{Protheus.doc} F0700006
Realiza Delete em um Registro com modelo MVC.
@author izac.ciszevski
@since 19/01/2017
@param cTabela, character, Nome da Tabela para Busca
@param aPosChave, array    , Posição da chave de Busca dos Registros sem o campo filial
@param cFonte, character, Nome do fonte MVC
@param [nInd], numeric, Opcional | Indice de busca
@Project MAN0000007423041_EF_000
*/
User Function F0700006(cTabela, aPosChave, cFonte, nInd, aCampos)

    Local cRetorno   := ""
    Local nOperation := MODEL_OPERATION_DELETE
    Local lOK        := .F.
    Local aInfo      := {}
    Local nRecLog    := 0
    Local aAreas     := {(cTabela)->(GetArea()), GetArea()}
	Local cId		 := FwUUIDv4()
	Local cChave     := ""
	
    Default nInd := 1

    DbSelectArea(cTabela)
    aInfo := { cTabela, aPosChave, cFonte, cId, nInd }
//    nRecLog := U_F07Log01(cID, aInfo, ProcName(1))

    Begin Sequence
        If !U_F07ChkFil(aCampos[1][2])
            cRetorno := "ERRO|Filial Inválida"
            Break
        EndIf 

	    nRecLog := U_F07Log01(cID, aInfo, ProcName(1))

        aCampos[1][2] := XFilial(cTabela) //-- ajusta a filial
        cChave := U_F0700005(cTabela, aCampos, aPosChave)
        
        (cTabela)->(DbSetOrder(nInd))
        If !((cTabela)->(DbSeek(cChave)))
            cRetorno := "ERRO|Registro Não Localizado"
            Break
        EndIf    

        If (lOK := U_F0700007(cFonte, , , nOperation, @cRetorno ))
            cRetorno := "OK|Registro excluído com sucesso"
        EndIf
    End Sequence
    
    U_F07Log02(nRecLog, cRetorno, lOK,cTabela)
    
    aInfo := ASize(aInfo, 0)
    aInfo := Nil
    
    AEval( aAreas, {|aArea| RestArea(aArea)}) 

Return cRetorno
