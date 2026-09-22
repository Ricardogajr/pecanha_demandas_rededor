#INCLUDE "Protheus.ch"

/*{Protheus.doc} F0100329()
Seleciona o caminho para gravação
@author     Henrique Madureira	
@since      16/03/2017
@param      NIL
@return     NIL
@project    MAN00000463701_EF_003
*/
User Function F0100329()
	
	Local cVar     := READVAR() 
	Local cCamiAux := cGetFile( '*.txt' , 'Selecione a Pasta', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ), .F., .T. )
	
	&cVar	:= cCamiAux 

Return cCamiAux
