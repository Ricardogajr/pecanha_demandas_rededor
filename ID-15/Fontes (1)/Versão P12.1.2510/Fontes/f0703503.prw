#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*{Protheus.doc} F0703503
Validação do estorno de movimento interno
@author Alex Sandro Valario
@since 07/03/2017
@version 1.0
@Project MAN0000007423041_EF_035
@return
@ Sample

User Function MT240EST()
Local lRet := .f.

    lRet := U_F0703503() // Não pode estornar movimento gerados de integração.

Return lRet

*/

User Function F0703503()

    If IsBlind() // quando for rotina automatica, não valida.
        Return .t.
    EndIf


    If ! Empty(SD3->D3_XID)
        Help(,,'F0703503',,'Movimento gerado por integração, estorno não permitido!',1,0) 
        Return .f.
    EndIf

Return .t.