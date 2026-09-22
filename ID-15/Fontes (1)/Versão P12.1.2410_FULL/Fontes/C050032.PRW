#INCLUDE 'PROTHEUS.CH'
/*
{Protheus.doc} C05PA71
Função para carga de dados 
@author	FsTools V6.2.14
@since 08/11/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423039_EF_003
@Project MAN00000463301_EF_003
*/


User Function C05PA71(lReadOnly)
Local cAlias := 'PA7' 
Local cDesc  := 'CONTROLE SOLICITAÇÃO PORTAL   '
Local nTam   := 7
Local aVal   := {}
If lReadOnly 
    aAdd(aVal, {cAlias, cDesc, nTam} )
    Return aVal 
Endif 
aAdd(aVal, {'PA7', 'PA7_FILIAL', 'PA7_DESCR', 'PA7_CODIGO'})
aAdd(aVal, {"PA7", "", "TREINAMENTO / EVENTO", "001"})
aAdd(aVal, {"PA7", "", "VAGA", "002"})
aAdd(aVal, {"PA7", "", "AUMENTO DE QUADRO / ORÇAMENTO", "003"})
aAdd(aVal, {"PA7", "", "FAP", "004"})
aAdd(aVal, {"PA7", "", "DESLIGAMENTO DE FUNCIONARIO", "005"})
aAdd(aVal, {"PA7", "", "MOVIMENTAÇÃO PESSOAL", "006"})
aAdd(aVal, {"PA7", "", "INCENTIVO ACADEMICO", "007"})
Return aVal 
