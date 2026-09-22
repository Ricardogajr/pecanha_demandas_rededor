#Include 'Protheus.ch'

/*
{Protheus.doc} F0100405()
Função para a Inclusão do Botão Recusa no Documento de Entrada - PE MA103OPC
@Author     Mick William da Silva
@Since      09/05/2016
@Version    P12.7
@Project    MAN00000462901_EF_004
@Return		aRet, Vetor aRotina     
 */

User Function F0100405(aRetorno)
	
	Local cGrpAce := Alltrim(SuperGetMV("FS_ACESREC",.F., " ")) //Parâmetro que guarda os grupos autorizados a acessar os botões de recusa
    Local cCodUsr := RetCodUsr()
    Local aGrpUsr := {}
    Local nG      := 0
    Local lAcessR := .F.  
	Default aRetorno := {}	
	
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
		AAdd(aRetorno, {'Recusar'        , 'U_F010101A'              , 0, 3} )
		AAdd(aRetorno, {'Cancelar Recusa', 'U_F010101PCANCELARECUSA' , 0, 3} )
	EndIf
	AAdd(aRetorno, {'Hist. Recusa'   , 'U_F010101G'              , 0, 3})

Return aRetorno

