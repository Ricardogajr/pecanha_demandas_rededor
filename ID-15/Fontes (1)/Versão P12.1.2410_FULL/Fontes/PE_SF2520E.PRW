#Include 'Protheus.ch'

/*/{Protheus.doc} SF2520E
Chamada para o Client de Resposta ao IIB (Chave de NF de Saida)
a partir do ponto e entrada SF2520E (Exclusão da Nota Fiscal de Saída).  
@author Paulo Krüger
@since  10/03/2017
@return Nil  
@project MAN0000007423041_EF_034
@cliente Rededor
@version P12.1.7
/*/

User Function SF2520E() 

Local aArea	:= GetArea()

U_F0703402(SF2->F2_FILIAL, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC)

RestArea(aArea)
Return