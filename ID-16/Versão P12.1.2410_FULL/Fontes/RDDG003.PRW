//#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
|----------------------------------------------------------------------------|
|Programa  |RDDG003  |Autor  |TECNOSUM            | Data |  09/07/2016       |
|----------------------------------------------------------------------------|
|Descrição |Gatilho para alimentar o campo Data da Necessidade de acordo com |
|          |o projeto MAN00000463101_EF_SUP_COM_N008_v01                     |
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/


User Function RDDG003(cTipoSC,cProd)
	Local dDtNec 	:= ctod("") //Data da Necessidade
	Local nDias		:= 0
	Local cTpEmerg	:= Alltrim(GETMV("MV_XTPEMER")) //Informa o código do tipo emergencial.
	Local dDtEmis	:= GdFieldGet("C1_EMISSAO")
	Local cXPrazo	:= GdFieldGet("C1_XPRAZO")
	
	//Só ajusta a Data da necessidade se não for emergencial,
	//Caso seja emergencial, o campo ficará em branco, forçando o usuário a escolher um prazo de entrega 
	//no campo C1_XPRAZO  
	If cTipoSC ==  cTpEmerg //Só ajusta a Data da necessidade se não for emergencial, 

		DO CASE 
			CASE cXPrazo = "1"
			nDias := 1
			dDtNec := DaySum(dDtEmis,nDias) 

			CASE cXPrazo = "2"
			nDias := 2
			dDtNec := DaySum(dDtEmis,nDias) 

			CASE cXPrazo = "3"
			nDias := 3
			dDtNec := DaySum(dDtEmis,nDias) 

			CASE cXPrazo = "4"
			nDias := 4
			dDtNec := DaySum(dDtEmis,nDias) 

			CASE cXPrazo = "5"
			nDias := 5
			dDtNec := DaySum(dDtEmis,nDias) 


		EndCase
	Endif

Return DataValida(dDtNec, .t.)



/*
|------------------------------------------------------------------------------------|
|Programa  |RetModEdt  |Autor  |TECNOSUM            | Data |  26/08/2016             |
|------------------------------------------------------------------------------------|
|Descrição |Valida de acordo com o Tipo de SC, se o campo Prazo (C1_XPRAZO)          |
|          |será editável ou não. Função chamada no modo de edição do campo (X3_WHEN)|
|------------------------------------------------------------------------------------|
|Uso       |REDEDOR                                                                  |						  
|------------------------------------------------------------------------------------|
*/
User Function RDDG0031

Local lModo   := .F.
Local cTpEmer := Alltrim(GETMV("MV_XTPEMER"))

If GdFieldGet("C1_XTPSC") == cTpEmer  
	lModo := .T.
EndIf

Return lModo




