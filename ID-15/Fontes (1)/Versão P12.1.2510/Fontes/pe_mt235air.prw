#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MT235AIR
Ponto de entrada no final do processamento da Eliminação de Resíduo
@type User function
@author robson.william
@since 23/01/2017
@version 12.7
@param
@project MAN0000007423041_EF_022
@return Nil
/*/

User Function MT235AIR
    Local cAliasQry := ParamIxb[1]

    If IsInCallStack("MA235PC")
        U_F0702203( Nil, 8, Nil, (cAliasQry)->SC7RECNO )   // Rotina para integrara com os fronts ws client de Desbloqueio
    Endif
    //Tratativa para evitar rollback em todo o processo.
    If InTransact()
    	///__endtran()
    	////__begintran()
    EndIf	         
Return
