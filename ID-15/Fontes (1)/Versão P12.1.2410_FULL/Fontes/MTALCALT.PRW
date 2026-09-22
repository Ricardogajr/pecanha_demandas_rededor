#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MTALCALT
//Atualiza o nome do usuário na tabela SCR.
@author Ricardo
@since 06/06/2017 
@version 1.0
@type function
/*/
User Function MTALCALT()

    Local aArea	:= GetArea()

    RecLock("SCR", .F.)
    SCR->CR_XNOME := UsrFullName(SCR->CR_USER)
    SCR->(MsUnLock())

    //ID 1475 - Gravação de Campos - Marcelo Mendes
    U_F1201004(SCR->CR_FILIAL,ALLTRIM(SCR->CR_NUM),SCR->CR_TIPO)

	//MAN0000007423048_EF_74 - Aprovador Substituto
    U_F1207503() //Rotina para gravar código do aprovador original.

    RestArea(aArea)

Return
