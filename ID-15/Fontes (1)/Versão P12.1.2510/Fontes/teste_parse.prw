#include 'protheus.ch'
#include 'parmtype.ch'

	User Function Teste()
  Local oWsdl
  Local xRet
   
  // Cria o objeto da classe TWsdlManager
  oWsdl := TWsdlManager():New()
   
  // Faz o parse de uma URL
  xRet := oWsdl:ParseURL( "http://schemas.xmlsoap.org/wsdl/" )
  if xRet == .F.
    conout( "Erro: " + oWsdl:cError )
  else
    conout( "Parse feito com sucesso" )
  endif
Return
return