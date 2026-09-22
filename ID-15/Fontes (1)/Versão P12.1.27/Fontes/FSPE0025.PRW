#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MA235PC
    Rotina para registrar as informações da tela de eliminação de resíduo.

    @author Lucas Aguiar
    @since 17/09/17
    @version 1.0
/*/

user function FSPE0025()
	
	Local aArea := GetArea()
	Private cAtemp 	 := paramixb[1]
	Private cUsrNome := UsrFullName(RetCodUsr())

	//Reclock na tabela de Pedido de Compras OU Solicitação de compras após validar tela de observação e retornar .T. em MA235PC.
	If mv_par08 == 1
		DbSelectArea("SC7")
		DbSetOrder(1)
		SC7->(DbGoto((cAtemp)->SC7RECNO))
		//If !Empty(Alltrim(SC7->C7_ENCER))
		//If !Empty(Alltrim(SC7->C7_RESIDUO))
			RecLock("SC7", .F.)
			SC7->C7_XOBSRES := Alltrim(__cObsSC)
			SC7->C7_XUSRRES := cUsrNome
			SC7->C7_XDATRES := 	Date()
			SC7->(MsUnlock())
		//Endif
	ElseIf mv_par08 == 5
		DbSelectArea("SC1")
		DbSetOrder(1)
		SC1->(DbGoto((cAtemp)->SC1RECNO))
			RecLock("SC1", .F.)
			SC1->C1_XOBSRES := Alltrim(__cObsSC)
			SC1->C1_XUSRRES := cUsrNome
			SC1->C1_XDATRES := 	Date()
			SC1->(MsUnlock())
	Endif
RestArea(aArea)
Return .T.
