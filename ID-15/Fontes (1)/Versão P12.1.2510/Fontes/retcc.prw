#Include "Protheus.ch"
#Include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RETCTAEST  ºAutor  ³ Rossana Andrade   º Data ³ 15/02/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para retornar o Conta Contábil( CT1 ).            º±±
±±º          ³ Nos lançamentos de Estoque                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function RetCC(_cTipo)

Local _cConta  := GetSx3Cache("CT1_CONTA","X3_TAMANHO")
Local _aAreaSBM := SBM->(GetArea())
Local _lExecuta := .T.


//Bloco de Proteção da Função
If Alltrim(_cTipo) == ""

	MessageBox("Tipo de Retorno deve ser informado ao usar o programa RETCC " + CHR(13) + CHR(10)+;
				"Informar 1 - Débito ou 2 - Crédito" + CHR(13) + CHR(10)+;
				"Comunicar ao Aministrador do sitema","MB_OK",0)
	_lExecuta := .F.

ElseIf !Alltrim(_cTipo) $ "1|2"

	MessageBox("Tipo de Retorno deve ser 1 - Débito ou 2 - Crédito "+ CHR(13) + CHR(10)+;
				"Comunicar ao Administrador do sistema","MB_OK",0)
	_lExecuta := .F.

Endif
//Fim de Bloco de Proteção

If _lExecuta

	If _cTipo == "1" // Débito
	
		_cConta :=IIF(SD3->D3_TM = "527", POSICIONE("ZMT",1,XFILIAL("ZMT")+SD3->D3_XFILDES+"A","ZMT_CTMTUO"),IIF(SD3->D3_XCONTA<>" ", SD3->D3_XCONTA, POSICIONE("SBM",1,XFILIAL("SBM")+SD3->D3_COD,"SBM->BM_XCONTA")))
	
	Else // Crédito
	
		_cConta :=IIF(SD3->D3_TM = "019", POSICIONE("ZMT",1,XFILIAL("ZMT")+SD3->D3_XFILDES+"A","ZMT_CTMTUO"),IIF(SD3->D3_XCONTA<>" ", SD3->D3_XCONTA, POSICIONE("SBM",1,XFILIAL("SBM")+SD3->D3_COD,"SBM->BM_XCONTA")))
	Endif

Endif

RestArea(_aAreaSBM)
Return(_cConta)

