#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"

/*
{Protheus.doc} F0100319()
chamada da página para realizar a inclusão da solicitação.
@Author     Bruno de Oliveira
@Since      07/10/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_003
@Return 	cHtml, página html
*/
User Function F0100319()
	
	Local cHtml := ""
	
	Private cFilPEsc  := ""
	Private cPostoEsc := ""
	
	cCodDepto := HttpGet->cCodDepto
	cDescrDepto := HttpGet->cDescrDepto
	cPostFilial := HttpGet->cPostFilial
	cCcusto := HttpGet->cCcusto
	cDscCC := HttpGet->cDscCC
	WEB EXTENDED INIT cHtml START "InSite"

	HttpPost->Posto := HttpSession->Postos[VAL(HttpGet->nIndicePosto)]
		
	cNPosto := HttpGet->cNPost
	cOpc := HttpGet->cOpc
	
	cFilPEsc   := IIF(cNPosto == '1', cPostFilial, HttpPost->Posto:cPostFilial) //Se for novo posto, retorna a filial do departamento selecionado.
   	cPostoEsc  := IIF(cNPosto == '1', ''		 , HttpPost->Posto:cPosto)
   	
   	cFilRepor  := IIF(EMPTY(HttpGet->cFilRepor),"",HttpGet->cFilRepor)
	cDescRepor := IIF(EMPTY(HttpGet->cDescRepor),"",HttpGet->cDescRepor)
	cDepRepor  := IIF(EMPTY(HttpGet->cDepRepor),"",HttpGet->cDepRepor)
	cDesDpRepor := IIF(EMPTY(HttpGet->cDesDpRepor),"",HttpGet->cDesDpRepor)
	cPostRepor  := IIF(EMPTY(HttpGet->cPostRepor),"",HttpGet->cPostRepor)
	
	cFilSol  := IIF(EMPTY(HttpGet->cFilSol),"",HttpGet->cFilSol)
	cDescSol  := IIF(EMPTY(HttpGet->cDescSol),"",HttpGet->cDescSol)
	cDeptSol  := IIF(EMPTY(HttpGet->cDeptSol),"",HttpGet->cDeptSol)
	cDescDeptSol  := IIF(EMPTY(HttpGet->cDescDeptSol),"",HttpGet->cDescDeptSol)
	
	nIndiceDepto := HttpGet->nIndDept

	HttpCTType("text/html; charset=ISO-8859-1")
	cHtml := ExecInPage( "F0100319" )
			
	WEB EXTENDED END
		
Return cHtml