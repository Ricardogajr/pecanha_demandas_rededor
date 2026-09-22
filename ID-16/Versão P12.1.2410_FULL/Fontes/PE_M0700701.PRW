/*
{Protheus.doc} M0700701()
Ponto de Entrada MVC M0700701
*/
User Function M0700701()
   
    Local xRetorno := .T.
	Local oObj     := ParamIxb[1]
	Local cIdPonto := ParamIxb[2]

    If cIdPonto == 'MODELPOS' .And. ( oObj:nOperation == 3 .Or. oObj:nOperation == 4 ) // Após a gravação total do modelo e dentro da transação.
        xRetorno := ExistChav("P13",oObj:GetModel('MASTER'):GetValue("P13_DESCR"),3)
    EndIf

Return xRetorno
