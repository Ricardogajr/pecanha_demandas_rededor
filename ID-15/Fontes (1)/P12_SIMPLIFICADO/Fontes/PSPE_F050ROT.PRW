/*{Protheus.doc} F050ROT()
Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
@Author			Nairan Alves Silva
@Since			16/09/2016
@Version		P12.7
@Project    	MAN00000463801_EF_001
@Return		Nil	 */
User Function F050ROT()

    Local aRotina := aClone(PARAMIXB)
    // ticket n° 10162361
    If Funname() <> 'FINA750'
        aRotina := U_F0400104(aRotina) //BANCO DE CONHECIMENTO

        aRotina := U_F0101002(aRotina) //RECUSA
    EndIf 
    aAdd(aRotina, {'Gerar SP de Carga'        , 'U_RDCAR01'              , 0, 3})
    
Return aRotina
