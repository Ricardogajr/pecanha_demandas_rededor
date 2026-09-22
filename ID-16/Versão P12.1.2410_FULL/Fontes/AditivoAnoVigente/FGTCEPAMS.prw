#Include 'Totvs.ch'
#include 'restful.ch'
#Include "Protheus.ch"

//FGTCEPAMS
//Integração para receber as informações do CEP informado e gatilhar nos campos 
//A2_END, A2_BAIRRO, A2_MUNIC, A2_UF
//Lucas Miranda de Aguiar
//22/05/2023
User Function FGTCEPAMS(cCep)

	Local oResult := NIL
	Local oRestClient := NIL
	Local aHeadPar := {}
	Local lAtivo  := GetNewPar("MV_XINTCEP",.F.)

	Default cCep := "20745312"

	If M->A2_TIPO == "X"
		If cCep == "00000000"
			Return
		EndIf
	EndIf

// Se o parâmetro MV_XINTCEP estiver como false, a rotina não preenche os campos.
	If !lAtivo
		Return
	EndIf
	aAdd(aHeadPar, "Content-Type: application/json;charset=utf-8")
	aAdd(aHeadPar, "Accept: application/json;charset=utf-8")

	cUrl := 'http://viacep.com.br'
	oRestClient := FWRest():New(cUrl)
	oRestClient:setPath('/ws/'+cCEP+'/json/')

	If !Empty(AllTrim(FwFldGet("A2_CEP")))
		If ! oRestClient:Get(aHeadPar)
			Aviso('Atenção!', 'Houve erro na atualização no servidor!' + CRLF + 'Digite um CEP válido!', {'OK'}, 03)
			FwFldPUT("A2_CEP","")
		Else
			If '"erro"' $ oRestClient:GetResult()
				Aviso('Atenção!', 'Houve erro na atualização no servidor!' + CRLF + 'Digite um CEP válido!', {'OK'}, 03)
				FwFldPUT("A2_CEP","")
			Else
				FWJsonDeserialize( oRestClient:GetResult(), @oResult )

				//Gatilha os campos de acordo com a MIT31
				FwFldPUT("A2_END",FwCutOff(decodeUTF8(oResult:LOGRADOURO),.T.))
				FwFldPUT("A2_BAIRRO",FwCutOff(decodeUTF8(oResult:BAIRRO),.T.))
				FwFldPUT("A2_MUN",FwCutOff(decodeUTF8(oResult:LOCALIDADE),.T.))
				FwFldPUT("A2_EST",FwCutOff(decodeUTF8(oResult:UF),.T.))
				FwFldPUT("A2_XCODES",SubStr(FwCutOff(decodeUTF8(oResult:IBGE),.T.),1,2))
				FwFldPUT("A2_COD_MUN",SubStr(FwCutOff(decodeUTF8(oResult:IBGE),.T.),3,Len(oResult:IBGE)-2))
				FwFldPUT("A2_IBGE",FwCutOff(decodeUTF8(oResult:IBGE),.T.))
			EndIf
		EndIf
	EndIf
Return
