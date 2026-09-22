 #include 'TOTVS.CH'
 
/*/{Protheus.doc} F290BAIXA

//Executa PE apos a baixa do titulo que gerou a fatura.
//Pode ser retornado um historico que sera utilizado na contabilizacao, atraves da variavel STRLCTPAD

@type User function
@author Marcel Mendes Trindade
@since 14/06/2019
@version 12.17
@project 
@return NIL
/*/

User Function F290BAIXA()

Local aArea := fwGetArea()
Local cRet  := ""


// Rafael Yera Barchi - 27/10/2021
// Chamado 12765973
// Tratativa para verificar se não está sendo executada por job/Schedule
If !IsBlind()

	// O Tratamento para checar se já houve baixa parcial é feito para rotina F0702901
	If !Empty(SE2->E2_XID)
		U_F0702901(SE2->E2_XID)
	Endif

EndIf

fwRestArea(aArea)
 
Return(cRet)


