#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT130IFC
Ponto de entrada de filtro na tela de gerar cotação.
É utilizado para filtrar cotações que não foram integrada com o 
bionexo e também adicionar o botao INTEGRAR BIONEXO ao menu de 
ações relacionadas.
@type function
@author Ricardo da Silva
@since 26/06/2017
@version 1.0
@return aDados Filtro do browser
/*/

User Function MT130IFC()
	
	Local aDados := {" .And. C1_XENVBIO == ' ' .And. C1_XIDBIO == ' ' ", " AND C1_XENVBIO = ' ' AND C1_XIDBIO = ' ' "}
	//1=Aguardando Integr. Bionexo, 2=Integrado Bionexo, 3=Aguardando Desvinculo Bionexo, 4=Erro de Integra��o Bionexo
	
Return( aDados )