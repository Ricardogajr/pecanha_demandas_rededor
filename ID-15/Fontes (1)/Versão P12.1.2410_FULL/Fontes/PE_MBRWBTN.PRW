#Include "totvs.ch"
/*{Protheus.doc} MBRWBTN
Ponto de entrada de validação no momento que executa a rotina do browse.
@author Sandro
@since 28/08/2017
@project MAN0000007423046_EF_008
*/
User Function MBRWBTN()
    
    Local cAlias    := PARAMIXB[1]
    Local nRecno    := PARAMIXB[2]
    Local nOption   := PARAMIXB[3]
    Local cFunction := PARAMIXB[4]
    Local lRet      := .T.

    lRet := U_F1200802(cAlias, nRecno, nOption, cFunction )  //validação de alteração e exclusa da tabela de preço fornecedor
    
Return  lRet