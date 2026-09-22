#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} F1301601
//TODO Descrição auto-gerada.
@author queizy.nascimento
@since 10/11/2017
@version 1.0
@return ${return}, ${return_description}
@project MAN0000007423048_EF_016
@type function
/*/
User function F1301602()

	Local cText := OemToAnsi("Selecione o Arquivo para importação:")
	Local cVar  := READVAR()

	Private cFile := ""

	Pergunte('FSW1301601',.F.)

	cFile := cGetFile( 'Todos os Arquivos | *.CSV' , cText, 0, 'C:\', .F., GETF_LOCALHARD,.F.)
	&cVar := cFile

Return .T.

