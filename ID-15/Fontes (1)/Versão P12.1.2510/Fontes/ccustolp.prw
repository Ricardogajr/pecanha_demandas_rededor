#Include "Protheus.Ch"

User Function cCustoLp

Local cCusto := ""
Local cConta := ""

IF SD3->D3_TM = "527"
	cConta := POSICIONE("ZMT",1,XFILIAL("ZMT")+SD3->D3_XFILDES+"A","ZMT_CTMTUO")
Else
	IF SD3->D3_XCONTA<>" "
		cConta := SD3->D3_XCONTA
	Else
		cConta := POSICIONE("SBM",1,XFILIAL("SBM")+SD3->D3_GRUPO,"BM_XCONTA") 
	Endif
Endif

If Substring(cConta,1,1) $ "3|4"
	cCusto := IIF(SD3->D3_CC<>' ',SD3->D3_CC,POSICIONE("NNR",1,XFILIAL("NNR")+NNR->NNR_CODIGO,"NNR_XCUSTO"))   
Endif

Return(cCusto)
