#Include 'Protheus.ch'

/*/{Protheus.Doc} F0900106()    
Valida Pedido de Compra - Fonte MATA120
@project	MAN00000462901_EF_004     
@author		Paulo Krüger
@Return		lCotValida, logico, Informa se a cotação é válida ou não.
/*/
User Function F0900106()

	Local aAreas     := {SAJ->(GetArea()),GetArea() }
	Local lCotValida := .T.
	
	SAJ->(DbSetOrder(2))
	If !SAJ->(DbSeek(xFilial('SAJ') + RetCodUsr()))
		Help( , , 'F0900106', , 'Usuário sem Grupo de compras!', 1, 0, , , , , , {"Solicite seu cadastro para a equipe responsável."} )
		lCotValida := .F.
	EndIf	

	AEval(aAreas, {|aArea| RestArea(aArea) })

Return lCotValida
