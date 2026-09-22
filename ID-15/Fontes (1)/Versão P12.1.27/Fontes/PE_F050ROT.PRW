/*{Protheus.doc} F050ROT()
Ponto de Entrada para adicionar as opções do Banco de Conhecimento no aRotina
@Author			Nairan Alves Silva
@Since			16/09/2016
@Version		P12.7
@Project    	MAN00000463801_EF_001
@Return		Nil	 */
User Function F050ROT()

    Local aRotina := aClone(PARAMIXB)
	//Local lGrpHblt  := U_F2000132() //Verifica tabela PX1 para a empresa/filial atual

    // ticket n° 10162361
    If Funname() <> 'FINA750'
		If FindFunction('U_F0400104')
       		aRotina := U_F0400104(aRotina) //BANCO DE CONHECIMENTO
		EndIf

		If FindFunction('U_F0101002')
        	aRotina := U_F0101002(aRotina) //RECUSA
		EndIf
    EndIf 

	//Integração XRT - 25/06/2021
	//Verifica se está habilitada a integração neste grupo de empresas
    //If lGrpHblt
        If FindFunction('U_F2000120')
			AAdd(aRotina, {'Integ. AP XRT' ,"U_F2000120()", 0 , 2})
		EndIf
		If FindFunction('U_F2000421')
			AAdd(aRotina, {'Integ. Op. Fin. XRT' ,"U_F2000421()", 0 , 2})
		EndIf
    //EndIf  
	
Return aRotina
