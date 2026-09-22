//#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"

/*
|----------------------------------------------------------------------------|
|Programa  |RDDG002  |Autor  |TECNOSUM            | Data |  09/07/2016       |
|----------------------------------------------------------------------------|
|Descrição |Gatilho para alimentar o campo Data da Necessidade de acordo com |
|          |o projeto MAN00000463101_EF_SUP_COM_N008_v01                     |
|----------------------------------------------------------------------------|
|Uso       |REDEDOR                                                          |						  
|----------------------------------------------------------------------------|
*/


User Function RDDG002(cTipoSC,cProd)
	Local dDtNec 	:= ctod("") //Data da Necessidade
	Local nDias		:= 0
	Local cTpEmerg	:= Alltrim(GETMV("MV_XTPEMER")) //Informa o código do tipo emergencial.
	Local dDtEmis	:= GdFieldGet("C1_EMISSAO")
	//Só ajusta a Data da necessidade se não for emergencial,
	//Caso seja emergencial, o campo ficará em branco, forçando o usuário a escolher um prazo de entrega 
	//no campo C1_XPRAZO  
	If cTipoSC <>  cTpEmerg //Só ajusta a Data da necessidade se não for emergencial, 

		DbSelectArea("SBZ")
		DbSetOrder(1)

		If DbSeek(xFilial("SBZ")+cProd)
			/* tipo Prazo
			H- HORAS
			D- DIAS
			S- SEMANA
			M- MES
			A- ANO
			*/
			DO CASE 
				CASE SBZ->BZ_TIPE = "H"
				nDias := INT(SBZ->BZ_PE/24)//quando resultado for 0(zero) a soma dará no mesmo dia.
				dDtNec := DaySum(dDtEmis,nDias+SBZ->BZ_XTEMPRO) 

				CASE SBZ->BZ_TIPE = "D"
				dDtNec := DaySum(dDtEmis,SBZ->BZ_PE+SBZ->BZ_XTEMPRO)

				CASE SBZ->BZ_TIPE = "S"
				nDias := SBZ->BZ_PE*7 //Multiplica por 7dias cada semana
				dDtNec := DaySum(dDtEmis,nDias+SBZ->BZ_XTEMPRO) 

				CASE SBZ->BZ_TIPE = "M"
				dDtNec := MonthSum(dDtEmis,SBZ->BZ_PE+SBZ->BZ_XTEMPRO)

				CASE SBZ->BZ_TIPE = "A"
				dDtNec := YearSum(dDtEmis,SBZ->BZ_PE+SBZ->BZ_XTEMPRO)
			EndCase

		Endif
	Else
		dDtNec := U_RDDG003(cTipoSC,cProd)
	Endif


Return DataValida(dDtNec,.t.)

User Function RDDI001()
	Local dDtNec 	:= ctod("") //Data da Necessidade
	Local nDias		:= 0
	Local cTpEmerg	:= Alltrim(GETMV("MV_XTPEMER")) //Informa o código do tipo emergencial.
	Local dDtEmis	:= GdFieldGet("C1_EMISSAO")
	Local cTipoSC	:= GdFieldGet("C1_XTPSC")
	Local cProd		:= GdFieldGet("C1_PRODUTO")
	Local lRet		:= .f.
	
	If cTipoSC <>  cTpEmerg //Só ajusta a Data da necessidade se não for emergencial, 

		DbSelectArea("SBZ")
		DbSetOrder(1)

		If !DbSeek(xFilial("SBZ")+cProd)
			lRet := .t.
		Endif
	Endif
	
Return lRet
	

