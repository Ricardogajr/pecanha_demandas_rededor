/*{Protheus.doc} GP660ROT()
Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
@Author			Nairan Alves Silva
@Since			16/09/2016
@Version		P12.7
@Project    	MAN00000463801_EF_001
@Return		Nil	 */
User Function GP660ROT()
Local aRotina := aClone(PARAMIXB[1])
//Valida pelos parametros se essa empresa irá executar essas chamadas.
If !U_VALIDEMP()
	Return aRotina
EndIf
	
aRotina := U_F0400104(aRotina)

Return aRotina