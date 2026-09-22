#Include 'Protheus.ch'

/*
{Protheus.doc} F0101005()
PE FA750BRW Para adicionar o botão recusa nas rotinas FINA750 
@Author     Tiago Paulo Silva
@Since      28/04/2016
@Version    P12.7
@Project    MAN00000462901_EF_010
@Return		aRotina, Vetor de Menu
*/
User Function F0101005(aRotina)

    Local cGrpAce := Alltrim(SuperGetMV("FS_ACESREC",.F., " ")) //Parâmetro que guarda os grupos autorizados a acessar os botões de recusa
    Local cCodUsr := RetCodUsr()
    Local aGrpUsr := {}
    Local nG      := 0
    Local lAcessR := .F.    

    DEFAULT aRotina := {}

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

    If lAcessR
        AAdd(aRotina, {'Recusar'        , "U_F010101A"             , 0, 3})
        AAdd(aRotina, {'Cancelar Recusa', 'U_F010101PCANCELARECUSA', 0, 3} )
    EndIf
    AAdd(aRotina, {'Hist. Recusa'   , 'U_F010101G'             , 0, 3})

Return aRotina
