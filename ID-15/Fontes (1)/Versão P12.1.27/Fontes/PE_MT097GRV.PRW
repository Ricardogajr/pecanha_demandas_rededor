#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} MT097GRV()
Controla a gravação de alçadas nos processos de compras. Antes da gravação da tabela SCR.
@author     Paulo Krüger
@since      18/09/2017
@version    P12.7
@Project    MAN0000007423046
@Return     lRet
/*/

User Function MT097GRV() 

    Local aArea := GetArea()
    Local aDocto   := PARAMIXB[1]
    Local dDataRef := PARAMIXB[2]
    Local nOper    := PARAMIXB[3]
    Local cDocSF1  := PARAMIXB[4]
    Local lResiduo := PARAMIXB[5]
    Local lRet  := .T.

    lRet := U_F1200717(.T.) //Verifica se a medição de contrato vem de rotina customizada

	IF FindFunction("U_F1207504")
		If nOper == 2  //Transferência da Alçada para o Superior
			U_F1207504("A",aDocto,nOper) //Rotina para gravar o código do aprovador anterior.
		EndIf
	EndIf
 
 	If FindFunction("U_RecNoSCR")
        U_RecNoSCR(SCR->(Recno()))
    EndIf

    RestArea(aArea)

Return lRet