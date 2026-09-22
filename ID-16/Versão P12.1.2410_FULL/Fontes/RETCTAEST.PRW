#Include "Protheus.ch"
#Include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETCTAEST  ºAutor  ³ Auremar Duarte   º Data ³ 19/04/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para retornar a Conta Contabil ( CT1 ).           º±±
±±º          ³ Nos lançamentos de Estoque                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function RetCtaEst(_cTipo)

Local _cConta   := GetSx3Cache("CT1_CONTA","X3_TAMANHO")
Local _aAreaSB1 := SB1->(GetArea())
Local _lExecuta := .T.


//Bloco de Proteção da Função
If Alltrim(_cTipo) == ""

	MessageBox("Tipo de Retorno deve ser informado ao usar o programa RETCTAEST " + CHR(13) + CHR(10)+;
				"Informar 1 - Débito ou 2 - Crédito" + CHR(13) + CHR(10)+;
				"Comunicar ao Aministrador do sitema","MB_OK",0)
	_lExecuta := .F.

ElseIf !Alltrim(_cTipo) $ "1|2"

	MessageBox("Tipo de Retorno deve ser 1 - Débito ou 2 - Crédito "+ CHR(13) + CHR(10)+;
				"Comunicar ao Aministrador do sitema","MB_OK",0)
	_lExecuta := .F.

Endif
//Fim de Bloco de Proteção

If _lExecuta

	If _cTipo == "1" // Débito
	
		DO CASE
		Case Alltrim(SD3->D3_TM) $ "511"//alterado
			_cConta := "210201001051"
		Case Alltrim(SD3->D3_TM) $ "504"
			_cConta := "110401001050" //alterado
		Case Alltrim(SD3->D3_TM) $ "508"
			_cConta := "110401001051" //alterado
		Case Alltrim(SD3->D3_TM) $ "526"//incluído
			_cConta := "110401001100"
		Case Alltrim(SD3->D3_TM) $ "517|518|519|520|502|521|522|505|516|503" 
			_cConta := POSICIONE("SB1",1,XFILIAL("SB1")+SD3->D3_COD,"SB1->B1_XCTDES")//alterado					
		Case Alltrim(SD3->D3_TM) $ "527"
			_cConta := POSICIONE("ZMT",1,XFILIAL("ZMT")+SD3->D3_XFILDES+"A","ZMT_CTMTUO")	// ZMT_FILIAL+ZMT_FILDES+ZMT_TPMUTU - alterado
		EndCase
	
	Else // Crédito
	
		DO CASE
		Case Alltrim(SD3->D3_TM) $ "002"
			_cConta := "310303001201" //alterado
		Case Alltrim(SD3->D3_TM) $ "012|016|003|005" //incluido a 016
			_cConta := POSICIONE("SB1",1,XFILIAL("SB1")+SD3->D3_COD,"SB1->B1_XCTDES")//alterado
		Case Alltrim(SD3->D3_TM) $ "018" //incluído
			_cConta := "110401001100"
		Case Alltrim(SD3->D3_TM) $ "008"
			_cConta := "210201001051" //alterado
		Case Alltrim(SD3->D3_TM) $ "004|017"
			_cConta := "110401001050"//alterado
		Case Alltrim(SD3->D3_TM) $ "007"//confirmado
			_cConta := "310303001201"			
		Case Alltrim(SD3->D3_TM) $ "019"
			_cConta := POSICIONE("ZMT",1,XFILIAL("ZMT")+SD3->D3_XFILDES+"P","ZMT_CTMTUO")	//ALTERADO
		EndCase
	
	Endif

Endif

RestArea(_aAreaSB1)
Return(_cConta)

