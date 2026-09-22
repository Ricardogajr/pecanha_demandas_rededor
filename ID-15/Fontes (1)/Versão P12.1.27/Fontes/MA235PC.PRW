#include 'protheus.ch'
#include 'parmtype.ch'

user function MA235PC()
	
	Private aArea := GetArea()
	Public __cObsSC := Space(254)
	Private lRet 	:= .F.

	// Monta Tela do usuário para inserção da observação da eliminação de resíduos.
	SetPrvt("oDlgObsSC","oGrpObs","oSayObs","oSaySText","oObsSC","oBtnConfirmar","oBtnSair")

	oDlgObsSC := MSDialog():New( 086,233,422,1051,"Justificativa da eliminação de resíduos",,,.F.,,,,,,.T.,,,.T. )
	oGrpObs  := TGroup():New( 004,008,156,316,"Justificativa",oDlgObsSC,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSayObs  := TSay():New( 020,016,{||"Descrição"},oGrpObs,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,028,008)
	oObsSC   := TMultiGet():New( 020,044,{|u| If(PCount()>0,__cObsSC:=u,__cObsSC)},oDlgObsSC, 260, 122,,,,,, .T.,,,,,,.F.,/*{|| LerTamText()}*/,,,,,,,,)

	oBtnConfir  := TButton():New( 008,328,"&Confirmar",oDlgObsSC,{||RedaGrv(),oDlgObsSC:End()}   ,064,012,,,,.T.,,,,,,,.F. )
	oBtnSair    := TButton():New( 027,328,"&Sair"     ,oDlgObsSC,{||oDlgObsSC:End()},064,012,,,,.T.,,"",,,,.F. )

	oDlgObsSC:Activate(,,,.T.)	
Return	lRet
	
//Valida tela de observação, caso esteja preenchida corretamente retorna .T., executando o RecLock no Alias selecionado em MT235G2.
Static Function RedaGrv()

	If ( Len(AllTrim(__cObsSC)) > 254 )
		MsgAlert("Foi excedido o número de 254 caracteres, " + "foram digitados " + cValTochar(Len(AllTrim(__cObsSC))) + " caracteres" + "!", "Eliminação de resíduos")		
		Return lRet
	ElseIf Empty(__cObsSC)
		MsgAlert("Favor preencher o campo de descrição!", "Eliminação de Resíduos")
	Else
		lRet := .T.
	Endif
RestArea(aArea)
Return