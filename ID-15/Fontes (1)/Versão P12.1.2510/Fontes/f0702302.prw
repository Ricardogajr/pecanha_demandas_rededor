#Include 'Protheus.ch'

/*/{Protheus.doc} F0702302
Bloqueia a exclusão de produto inserido pela integração
@type function
@author queizy.nascimento
@since 13/02/2017
@version 1.0
@project MAN0000007423041_EF_023
/*/
User Function F0702302()
	Local lRet := .T.
	
	If!(Empty(SB1->B1_XP12FRO) .AND. Empty(SB1->B1_XFROP12))
		Help(,,'Atenção',,'Exclusão não permitida',1,0)
		lRet := .F.
	EndIf
	
Return lRet
	
	



