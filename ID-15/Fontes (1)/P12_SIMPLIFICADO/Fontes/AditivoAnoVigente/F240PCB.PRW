// #########################################################################################
// Projeto: Rede D'Or
// Modulo : Financeiro
// Fonte  : F240PCB
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 01/09/22 | Rafael Yera Barchi| Ponto de Entrada para validação do cancelamento do borderô
// ---------+-------------------+-----------------------------------------------------------

#INCLUDE    "PROTHEUS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F240PCB
//Ponto de Entrada para validação do cancelamento do borderô
@author Rafael Yera Barchi
@since 01/09/2022
@version 1.00
@type function

/*/
//------------------------------------------------------------------------------------------
User Function F240PCB()

    Local lRet      := .T.
    Local cBancoMNK := PadR(SuperGetMV("MK_BANCO"    , , ""), TamSX3("A6_COD")[1])


    If !IsBlind() .And. SE2->E2_PORTADO == cBancoMNK
        lRet := .F.
        FWAlertInfo("Não é permitido cancelar o borderô de títulos negociados no Portal Monkey", "Aviso")
    EndIf

Return lRet
