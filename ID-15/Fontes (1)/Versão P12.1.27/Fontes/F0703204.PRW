#Include 'TOTVS.CH'

/*/{Protheus.doc} F0703204
Limpa conteúdo de campos específicos na cópia de pedidos de venda.
@author Paulo Krüger
@since  09/11/2017
@return Nil  
@project MAN0000007423041_EF_032
@cliente Rededor
@version P12.1.7
/*/

User Function F0703204

	M->C5_XID		:=	Space(TAMSX3('C5_XID')[1]) 	 
	M->C5_XNUM		:=	Space(TAMSX3('C5_XNUM')[1]) 
	M->C5_XTIPO		:=	Space(TAMSX3('C5_XTIPO')[1]) 

Return