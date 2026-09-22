#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F0702804
Função para gravação do ID AL Mapper de integração na tabela FK5
@type User function
@author robson.william
@since 22/05/2017
@version 12.7
@project MAN0000007423041_EF_028
/*/

User Function F0702804(aPIXB)

	Local lInt := IsInCallStack("U_F0702801") 
    Local aParam     := aPIXB
    Local lRet       := .T.
    Local oObj       := ''
    Local cIdPonto   := ''
    Local cIdModel   := ''
    Local oSubFK5

    If lInt .and. aParam <> NIL .and. ValType( cXIDBXF) <> "U" .and. ValType(lEstorno) <> "U" .and. !lEstorno

        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := aParam[3]
      
        If cIdPonto == 'MODELPOS'
            oSubFK5	:= oObj:GetModel("FK5DETAIL")
            oSubFK5:SetValue( "FK5_XIDBXF" , cXIDBXF )	
        Endif
    Endif

Return lRet