#Include 'Protheus.ch'

/*
{Protheus.doc} MTA010MNU()
Ponto de Entrada para Adicionar a rotina de menu Ações Relacionadas de Produto

@Author     Alex Sandro 
@Since      09/02/2017
@project MAN0000007423041_EF_024
@Return		aNewRot, Retorna as Novas Rotinas a serem inclusas no Ações Relacionadas Browse.  
*/

User Function MTA010MNU()
	
	 U_F0702402() // Adicona rotina de manutenção dos registros de tratamentos por filiais
	
Return (aRotina)
