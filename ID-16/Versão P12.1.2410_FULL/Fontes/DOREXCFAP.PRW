#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Protheus.ch"
#include "fileio.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DOREXCFAP
description Rotina responsável por gerar via execauto a FAP
@author  Laura Peghini  
@since   07/05/2025
@version 1.0
/*/ 
//-------------------------------------------------------------------
User function DOREXCFAP(aDados, nOpc)

Local lRetorno	:= .T.
Local nY 		:= 0
Local cNSolPA	:= ''
Local aDdUsr	:= {}

Private oModel 		:= FWLoadModel('F0500300')
Private lMsErroAuto := .F.
Private aHeader := {}
Private aCols   := {}
Private cP2Filia   
Private cP2Vaga   
Private cP2FilVg
Private cP2Vlr
Private cP2Slfech
Private cP2CdCand
Private cP2Nome
Private cP2CPF
Private cP2Sol
Private cP2TpAlts
Private cGetError := ""

Default aDados 		:= {}
Default nOpc   		:= 3

    /*aDados   := { {"PA2_FILIAL","01310027"},; // Filial da solicitação
                    {"PA2_CDVAGA","003636"},; // Codigo da vaga
                    {"PA2_FILVG","01310027"},; // Valor da vaga
                    {"PA2_SLFECH",2500.00},; // Salario fechamento
                    {"PA2_CDCAND","197616"},; // Codigo do candidato 
                    {"PA2_TPALTS","001"},; // Tipo de Aumento salarial == 001
                    {"PA2_XMULTI","1"},; // Multiplos vinculos == 1
                    {"PA2_XORIGE","2" }} // Origem FAP  == 2 */
	//Loga na empresa e filial.
	RpcSetEnv("01", aDados[1][2])

	If Len(aDados) == 0 
		return .F.
	endif

	oModel:SetOperation(nOpc)
	oModel:Activate()

	If cfilant <> aDados[1][2]
		cfilant := aDados[1][2]
	Endif

    for nY := 01 To Len(aDados)		
		fConvert(aDados[nY][1],aDados[nY][2], 'F05003_PA2')
	next nY

	Begin Transaction
		//Valida dados.
		if oModel:VldData()
			oModel:CommitData()
			ConfirmSx8()
			aError := GravaLog()
			//aError := oModel:GetErrorMessage()
			cNSolPA := PA2->PA2_SOL
		else
			aError := GravaLog()
			//aError := oModel:GetErrorMessage()
			lRetorno := .F.
			RollBackSX8()
			DisarmTransaction()
		endif
	End Transaction

return aError

//-------------------------------------------------------------------
/*/{Protheus.doc} fConvert
description Converte o campo para o tipo do campo da base.
@author  Laura Peghini
@since   07/05/2025
@version 1.0
/*/
//-------------------------------------------------------------------
static function fConvert(cCampo, cConteudo, cModelPA2)

Local xConteudo := Nil

	do case
	case type(cCampo) == "D" .And. valType(&(cCampo)) != "D"
		xConteudo := SToD(cConteudo)
	Case Type(cCampo) == "N" .And. valType(&(cCampo)) != "N"
		xConteudo := Val(cConteudo)
	Case Type(cCampo) == "L" .And. valType(&(cCampo)) != "L"
		xConteudo := iIf(AllTrim(&(cCampo))=="F", .F., .T.)
	OtherWise
		xConteudo := cConteudo
	endcase
	oModel:SetValue(cModelPA2, cCampo, xConteudo)

Return

Static function GravaLog()

Local nX	 := 00
Local aError := {}
Local aRetMsg := ""

	aGetError := oModel:GetErrorMessage()
	If !Empty(cGetError)
		aRetMsg := StrTokArr(cGetError, "/")
		If Len(aRetMsg) > 0
			If aRetMsg[1] == 'F'
				aAdd(aError, "ERRO")
				aAdd(aError, aRetMsg[2])
				aAdd(aError, AllTrim(PA2->PA2_SOL))
			Else
				aAdd(aError, "SUCESSO")
				aAdd(aError, aRetMsg[2]) //cGetError
				aAdd(aError, AllTrim(PA2->PA2_SOL))
			EndIf
		Else
			aAdd(aError, "ERRO")
			aAdd(aError, cGetError)
			aAdd(aError, AllTrim(PA2->PA2_SOL))
		EndIf
	ElseIf aGetError[2] != "POST"	
		aAdd(aError, "ERRO")	
		aAdd(aError, aGetError[6])
		aAdd(aError, AllTrim(PA2->PA2_SOL))
	Else
		aAdd(aError, "SUCESSO")
		aAdd(aError, "FAP gerada com sucesso.")
		aAdd(aError, AllTrim(PA2->PA2_SOL) )
	Endif

Return aError

User Function ValidUsa()

Local cQuery 	:= ""
Local cAliasTrb := GetNextAlias() 
Local lRet 		:= .F.
Local cFilUsr	:= ""
Local cMatric 	:= ""

	If !Empty(cRequisit)
		cQuery := " SELECT PAM_FILUSR, PAM_MATRIC, PAM_STATUS "
		cQUery += " FROM "+ RetSqlName("PAM")+ " PAM"
		cQuery += " WHERE PAM_FILIAL = '"+xFilial("PAM")+"' "
		cQuery += " AND UPPER(TRIM(PAM_EMAIL)) = '"+UPPER(AllTrim(cRequisit))+"'"
		cQuery += " AND PAM_STATUS = '1' "
		cQuery += " AND PAM.D_E_L_E_T_ = '' "
 
		PLSQuery( cQuery, cAliasTrb )
		(cAliasTrb)->(DBGoTop())
    	If !(cAliasTrb)->(Eof())
			lRet := .T.
			cFilUsr := (cAliasTrb)->PAM_FILUSR
			cMatric := (cAliasTrb)->PAM_MATRIC
		EndIf
		(cAliasTrb)->(DbCloseArea())
	Endif 

Return{lRet,cFilUsr,cMatric}
