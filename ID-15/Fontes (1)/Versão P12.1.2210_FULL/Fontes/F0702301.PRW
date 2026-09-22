#Include "Protheus.ch"

/*/{Protheus.doc} F0702301
Validação para bloquear o cadastro de produto, caso exista amarracao entre Serviço e Faturavel
@type function
@author queizy.nascimento
@since 13/02/2017
@version 1.0
@project MAN0000007423041_EF_023
/*/
User Function F0702301()
	Local lOk := .T.

	If ((M->B1_XMATSER == "2" ) .And. ( M->B1_XFATURA == "N"))		
		Help(,,'Atenção',,"Este Tipo de Amarração Mat/Serviço – Serviço e Faturável – Não pode ser gravado no Protheus",1,0)
		lOk := .F.
	EndIf

Return lOk




