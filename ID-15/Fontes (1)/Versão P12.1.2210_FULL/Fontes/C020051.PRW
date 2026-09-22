#INCLUDE 'PROTHEUS.CH'
/*
{Protheus.doc} C020051()
Função para carga de dados 
@author	FsTools V6.2.14
@since 15/07/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000463301_EF_005
*/
User Function C020051(lReadOnly)
Local aVal := {} 


aadd(aVal,'U_C02P081(lReadOnly)')
Return aVal 
