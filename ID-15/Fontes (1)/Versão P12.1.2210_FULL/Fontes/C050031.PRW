#INCLUDE 'PROTHEUS.CH'
/*
{Protheus.doc} C050031
Função para carga de dados 
@author	FsTools V6.2.14
@since 08/11/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423039_EF_003
@Project MAN00000463301_EF_003
*/
User Function C050031(lReadOnly)
Local aVal := {} 


aadd(aVal, 'U_C05PA71(lReadOnly)')
Return aVal 
