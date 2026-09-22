#INCLUDE "PROTHEUS.CH"

// MODELO PARA CRIAR EXCEL DE QUALQUER ALIAS
// IRÁ PEGAR A ESTRUTURA DO ALIAS E CONVERTER EM EXCEL
// GRAVANDO TODAS AS COLUNAS E SEUS VALORES COMO TEXTO
User Function CriaExcl(_cAlias, _cNome)

	Local oExcel 	:= FWMsExcelEx():New()
	Local _nX		:= 1
	Local _aCampos 	:= {}
	Local _aCols 	:= {}
	Local cExlNome	:= ""

	Default _cAlias := ""
	Default _cNome  := ""
	
	_cAlias := Alltrim(_cAlias)
	_cNome  := Alltrim(_cNome)
	
	MakeDir("C:/TEMP/")

	If !Empty(_cAlias)

		DbSelectArea(_cAlias)
		
		_aCampos := (_cAlias)->(dbStruct())

		(_cAlias)->(DbGoTop())

		If Len(_aCampos) > 0

			oExcel:AddworkSheet(_cAlias)
			oExcel:AddTable(_cAlias,_cAlias)

			For _nX := 1 To Len(_aCampos)
				oExcel:AddColumn(_cAlias,_cAlias,_aCampos[_nX][1],1)
			Next _nX

			nCont := 0

			While !(_cAlias)->(Eof())
				/*
				iF nCont < 10
					nCont++
				Else
					Exit
				EndIf
				*/

				For _nX := 1 To Len(_aCampos)
					aadd(_aCols, &((_cAlias)->(_aCampos[_nX][1])))
				Next _nX

				oExcel:AddRow(_cAlias,_cAlias, _aCols )

				_aCols := {}

				(_cAlias)->(dbSkip())
			EndDo

			oExcel:Activate()
			
			cExlNome := IIF(Empty(_cNome),_cAlias,_cNome)
			
			oExcel:GetXMLFile("C:/TEMP/"+cExlNome+".xml")
		Else
			MsgAlert("Alias sem estrutura, não é possível gerar excel !!")
		EndIf
	Else
		MsgAlert("Alias inexistente ou em branco, não é possível gerar excel !!")
	EndIf
	
Return cExlNome

