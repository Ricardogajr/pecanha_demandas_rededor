#INCLUDE "Protheus.ch"
 
/*
{Protheus.doc} F0201406()
Seleciona arquivo
@Author     Henrique Madureira
@Since
@Version    P12.7
@Project    MAN00000463301_EF_014
@Return	 cFile, retorna o caminho do arquivo selecionado
*/
User Function F0201406()
	
	Local cText := OemToAnsi("Selecione o Arquivo principal da documentação:")
	Local cFile := ""
	Local cVar  := READVAR() 
	
	cFile := cGetFile( 'Todos os Arquivos | *.*' , cText, 0, 'C:\', .F., GETF_LOCALHARD,.F.)
	&cVar := cFile
	   		
Return cFile
