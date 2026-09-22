#INCLUDE "PROTHEUS.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} F0501701
Validação de usuário na tabela U015
 
@author Nairan Alves Silva
@since  07/12/2017
@return Nil  

@project MAN0000007423048_EF_017, MAN0000007423048_EF_018, MAN0000007423048_EF_019
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------

User Function F0501701(cCampo, nTipo)

Local lRet	:= .T.

Default cCampo	:= __cUserID
Default nTipo	:= 2

If nTipo == 1
	If FWFilExist(,cCampo)
		GDFieldPut("DESCRICAO",FWFilialName(,cCampo))
	Else
		Aviso('Registro Não Encontrado',"Filial não encontrada.", {'OK'}, 1)
		lRet := .F.
	EndIf
Else
	If UsrExist(cCampo)	
		GDFieldPut("NOME",UsrFullName(cCampo))
	Else
		Aviso('Registro Não Encontrado',"Usuário não encontrado.", {'OK'}, 1)	
		lRet := .F.
	EndIf
EndIf

Return lRet