#INCLUDE 'PROTHEUS.CH'
 
/*
{Protheus.doc} F1200700()
Inclusao de Log de Eventos e Medicao Automatizada na rotina de "Geracao de Cotacao"
@Author     Paulo Krüger
@Since      29/08/2017
@Version    P12.7
@Project    MAN00000462901_EF_001    
@Return		aNewRot, Retorna as Novas Rotinas a serem inclusas no Acoes Relacionadas Browse.     
*/
 
User Function F1200700() 

	AAdd( aRotina, { "Logs de Eventos", "U_F0100106()", 0, 2, 0 } )
	AAdd( aRotina, { "Medicão Auto"	  , "U_F1200701(.T., .T., .F.)", 0, 2, 0 } )
//	AAdd( aRotina, { "MediÃ§Ã£o Auto" , "U_F0100109()", 0, 2, 0 } )

Return( )