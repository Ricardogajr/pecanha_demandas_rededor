#Include 'Protheus.ch'

User Function MATA094()

 Local xRetorno := .T.
	Local oObj
	Local cIdPonto
    
    If ParamIxb <> Nil .And. Len(ParamIxb) >= 2
        oObj     := ParamIxb[1]
        cIdPonto := ParamIxb[2]

        If cIdPonto == 'BUTTONBAR'
            xRetorno := {}
			Aadd( xRetorno , U_F1206801(oObj:nOperation,1) )
			Aadd( xRetorno , U_F1206801(oObj:nOperation,2) )
            Aadd( xRetorno , U_F1206801(oObj:nOperation,3) )
        EndIf
    EndIf

Return xRetorno