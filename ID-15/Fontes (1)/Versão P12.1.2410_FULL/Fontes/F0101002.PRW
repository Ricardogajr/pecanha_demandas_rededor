#Include 'Protheus.ch'

/*
{Protheus.doc} F0101002()
PE F050ROT para adicionar botões de recusa na rotina FINA050.
@Author     Tiago Paulo Silva
@Since      28/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_010
@param      aRotina, array, descricao
@Return		aRet, Vetor aRotina
*/
User Function F0101002(aRotina)

	Local lBloq   := OAPP:CMODNAME $ SuperGetMV("FS_XBLOQCP",,.T.)
	Local cGrpAce := Alltrim(SuperGetMV("FS_ACESREC",.F., " ")) //Parâmetro que guarda os grupos autorizados a acessar os botões de recusa
    Local cCodUsr := RetCodUsr()
    Local aGrpUsr := {}
    Local nG      := 0
    Local lAcessR := .F.

	If !Empty(cCodUsr)
        aGrpUsr := UsrRetGrp(cCodUsr)
        If Len(aGrpUsr) > 0
            For nG := 1 to Len(aGrpUsr)
                If aGrpUsr[nG] $ cGrpAce
                    lAcessR := .T.
                EndIf 
            Next nG
        EndIf
    EndIf

	IF  !lBloq .And. Funname() == 'FINA050' .And. lAcessR
		AAdd(aRotina, {'Recusar'        , 'U_F010101A'              , 0, 3} )
		AAdd(aRotina, {'Cancelar Recusa', 'U_F010101PCANCELARECUSA' , 0, 3} )
	Endif

	AAdd(aRotina, {'Hist. Recusa'   , 'U_F010101G'              , 0, 3})

Return aRotina
