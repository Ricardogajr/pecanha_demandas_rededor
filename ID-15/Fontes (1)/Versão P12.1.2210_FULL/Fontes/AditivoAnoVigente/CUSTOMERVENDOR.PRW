#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} CUSTOMERVENDOR
description
@type function
@version  
@author rubens
@since 01/12/2021
@return variant, return_description
/*/
User Function CUSTOMERVENDOR()
	Local aParam     := PARAMIXB
	Local oObj       := Nil
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local nOper      := 0
	Local xRet       :=.t.

	//Se tiver parâmetros
	If aParam <> NIL

		//Pega informações dos parâmetros
		oObj     := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		nOper := aParam[1]:GetOperation()

		//Chamada na validação total do modelo.
		If cIdPonto == "MODELPOS"				//Chamada na validação total do modelo
		
		ElseIf cIdPonto == "FORMPOS"			//Chamada na validação total do formulário
		    xRet:= U_SA2VLD01()
		ElseIf cIdPonto == "FORMLINEPRE"		//Chamada na pré validação da linha do formulário
		
		ElseIf cIdPonto == "FORMLINEPOS"		//Chamada na validação da linha do formulário.
		
		ElseIf cIdPonto == "MODELCOMMITTTS"		//Chamada após a gravação total do modelo e dentro da transação.
		
		ElseIf cIdPonto == "MODELCOMMITNTTS"	//Chamada após a gravação total do modelo e fora da transação.
            //Commit das operações (após a gravação)
            //Mostrando mensagens no fim da operação
            If nOper == 4  
				xRet:= U_SA2VLD01()
            EndIf

		ElseIf cIdPonto == "FORMCOMMITTTSPRE"	//Chamada após a gravação da tabela do formulário.

		ElseIf cIdPonto == "FORMCOMMITTTSPOS"	//Chamada após a gravação da tabela do formulário.

		ElseIf cIdPonto == "MODELCANCEL"		//Cancelamento
     
        //Adição de opções no Ações Relacionadas dentro da tela
        ElseIf cIdPonto == 'BUTTONBAR'

		EndIf
	EndIf


return(xRet)
