#include 'protheus.ch'

/*/{Protheus.doc} TDataPackage
(long_description)
@author    Roberto
@since     13/09/2018 
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class TDataPackage 

	method new() constructor 
	
	DATA cName         As String 
	DATA cDescription  As String

endclass

/*/{Protheus.doc} new
Metodo construtor
@author    Roberto
@since     13/09/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method new() class TDataPackage
   Self:cName        := ""
   Self:cDescription := ""
return Self
