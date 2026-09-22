#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "finxfin.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} FINALEG
description ponto de entrada para adicionar legenda no titulo
@author  Ricardo Junior
@since   02/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function F040URET()
	Local aArea := GetArea()
	Local aRet := {}
	Local lPrjCni		:= ValidaCNI()
	Local lFaLegPares	:= ExistBlock("FaLegPARes") .And. ExecBlock("FaLegPARes",.f.,.f.)
	Local aLegenda		:= {{"BR_VERDE", 	STR0003 },;	//1.  "Titulo em aberto"
	{"BR_AZUL", 	STR0004 },;	//2.  "Baixado parcialmente"
	{"BR_VERMELHO", STR0005 },;	//3.  "Titulo Baixado"
	{"BR_PRETO", 	STR0006 },;	//4.  "Titulo em Bordero"
	{"BR_BRANCO", 	STR0007 },;	//5.  "Adiantamento com saldo"
	{"BR_CINZA",	STR0008 },; //6. "Titulo baixado parcialmente e em bordero"
	{"BR_AMARELO", STR0072} } 	//7. "Adiantamento de Imp. Bx. com saldo"

	If FunName() $ "FINA050|FINA750|FINA080|FINA090|FINA091|FINC050"
		aAdd(aRet,{'E2_XAPRVSP == "2"',"BR_MARRON_OCEAN"})//NOVO MENU
		If lPrjCni
			IF !Empty(SuperGetMv("MV_APRPAG",.F.,"")) .or. SuperGetMv("MV_CTLIPAG",.F.,.F.)
				Aadd(aLegenda, {"BR_PINK", STR0013})  //"Titulo aguardando liberacao"
				Aadd(aRet, { ' EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > GetMV("MV_VLMINPG") .AND. E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } )
			EndIf
		Else
			IF SuperGetMv("MV_CTLIPAG",.F.,.F.)
				Aadd(aLegenda, {"BR_PINK", STR0074})	//"Titulo aguardando liberacao"
				Aadd(aRet, { ' !( SE2->E2_TIPO $ MVPAGANT ).and. EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > SuperGetMV("MV_VLMINPG",.F.,0) .AND. E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } )
			EndIf
		EndIf

		Aadd(aLegenda, {"BR_LARANJA", STR0073}) //"Adiantamento de Viagem sem taxa"
		Aadd(aRet, { ' (ALLTRIM(SE2->E2_ORIGEM) $ "FINA667|FINA677") .and. SE2->E2_MOEDA > 1 .AND. SE2->E2_TXMOEDA == 0 .AND. SE2->E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } )

		IF lFaLegPares
			Aadd(aLegenda,{"BR_MARROM",STR0046})
			Aadd(aRet, { 'E2_TIPO == "'+MVPAGANT+'" .and. ROUND(E2_SALDO,2) > 0 .And. (ROUND(E2_SALDO,2) < ROUND(E2_VALOR,2))', aLegenda[Len(aLegenda)][1] } )
		Endif

		//Validação para uso do documento hábil - SIAFI
		If FinUsaDH()
			Aadd(aLegenda,{"BR_VIOLETA",STR0070}) // "Titulo Vinculado a Docto Hábil"
			Aadd(aRet, { 'ROUND(E2_SALDO,2) > 0 .And. !EMPTY(E2_DOCHAB)'	, aLegenda[Len(aLegenda)][1]				} ) //"Titulo relacionado ao Documento hábil"
		Endif
		Aadd(aRet, { 'E2_TIPO $ "INA/'+MVTXA+'" .and. ROUND(E2_SALDO,2) > 0 .And. E2_OK == "TA"  ', aLegenda[7][1] } )
		Aadd(aRet, { 'E2_TIPO == "'+MVPAGANT+'" .and. ROUND(E2_SALDO,2) > 0', aLegenda[5][1] } )
		Aadd(aRet, { 'ROUND(E2_SALDO,2) + ROUND(E2_SDACRES,2)  = 0', aLegenda[3][1] } )
		Aadd(aRet, { '!Empty(E2_NUMBOR) .and.(ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2))', aLegenda[6][1] } )
		Aadd(aRet, { '!Empty(E2_NUMBOR)', aLegenda[4][1] } )
		Aadd(aRet, { 'ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2)', aLegenda[2][1] } )
	endif
	RestArea(aArea)
Return aRet
