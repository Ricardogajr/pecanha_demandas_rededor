/*{Protheus.doc} RS01DEPA
Este Ponto de Entrada tem como objetivo permitir alterar / incluir campos e valores a serem carregados na tela de Cadastro de Funcionários.
A chamada do P.E. será realizada após a leitura e fechamento do arquivo RSPDEPA e antes da carga da tela de Cadastro de Funcionário.
@type User Function
@author Ademar Fernandes
@since 20/06/2017
@version P12.1.7
@Project MAN0000007423039_EF_003
@return Deve ser retornado 2 arrays, contendo os campos e conteúdos a serem carregados/gravados:
-Primeiro array deve ser o parâmetro PARAMIXB[1] original ou atualizado.
-Segundo array dever o parâmetro PARAMIXB[2] original ou atualizado
*/
User Function RS01DEPA()
	Private xParam1 := PARAMIXB[1] // - aDePara - array com campos da SRA a serem carregados na apresentação da tela de Cadastro de Funcionários
	Private xParam2 := PARAMIXB[2] // - aDePara2 - array com campos das outras tabelas (diferente de SRA) que serão atualizadas após gravação do Funcionário da SRA.
	
	U_F0500315()
Return({xParam1,xParam2})
