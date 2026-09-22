#Include "Protheus.ch"

/*/{Protheus.doc} MTALCGRU
Ponto de entrada para alterar o Aprovador (qualquer operação).

Implementado para tratar erro na MATXALC.PRX, de matxalc_20190312, linha 1862, cuja SC1 está ponteirada em início
de arquivo e caso a SC esteja consumida a SCR de SC fica ponteirada no primeiro ítem da alçada não aprovando os 
níveis seguintes.

Será aberto ticket na Totvs pela REDEDOR e quando o problema for solucionado o tratamento deste PE poderá ser desativado.

@project
@type       User Function
@author     Marcelo Mendes
@since      05/06/2019
@version    12.1.17
@return     Nil
/*/

User Function MTALCGRU()

Local aArea := GetArea()

IF SCR->CR_TIPO = "SC"
	dbSelectArea("SC1")
	dbSetOrder(1)
	SC1->( dbSeek(SCR->CR_FILIAL + ALLTRIM(SCR->CR_NUM) ))	
ENDIF

RestArea(aArea)

Return(Nil)
