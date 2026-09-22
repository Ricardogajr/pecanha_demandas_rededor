#include 'protheus.ch'

User Function GRPXEMAIL()

Local aArea    := GetArea()

Local cAlias  := "SZJ"
Local cTitulo := "Grupos de Compradores X E-mail"
Local cVldExc := ".T."
Local cVldOk  := ".T."

dbSelectArea(cAlias)
(cAlias)->( dbSetOrder(1) )
AxCadastro(cAlias, cTitulo, cVldExc, cVldOk)

RestArea(aArea)
Return
