/*{Protheus.doc} F0700005
Retorna uma chave de pesquisa a partir de um array de campos,
ajustando o conteúdo conforme o dicionário de dados.
@author izac.ciszevski
@since 19/01/2017
@param cTabela, character, Nome da Tabela para Busca
@param aCampos, array, campos a serem atualizados no formato {{"CAMPO", xConteudo}}
@param aPos, array, posição númerica dos campos chave no array aCampos
@Project MAN0000007423041_EF_000 - Funções de Suporte
*/
User Function F0700005(cTabela, aCampos, aPos)
    Local cChave := XFilial(cTabela)
    Local nX     := 0
    Local nPos   := 0
   
    For nX := 1 to Len(aPos)
        nPos   := aPos[nX]
        cChave += PadR(aCampos[nPos][2], TamSX3(aCampos[nPos][1])[1])
    Next

Return cChave