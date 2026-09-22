#Include 'Protheus.ch'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MA020TOK
(long_description)
@type function
@author Cris
@since 03/08/2017
@version 1.0
@return ${lógico}, ${.T. válido .F. não válido}
@example
(examples)
@see http://tdn.totvs.com.br/pages/releaseview.action?pageId=6087599&src=search
/*///---------------------------------------------------------------------------------------------------------------------------
User Function MA020TOK()

	Local lVld	:= .T.
	
		lVld	:= U_SA2VLD01()

Return lVld