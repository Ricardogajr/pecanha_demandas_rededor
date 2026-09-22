#Include "TOTVS.CH"

/*/{Protheus.doc} F0703402
Chamada para o Client de Resposta ao IIB (Chave de NF de Saida)
a partir do ponto e entrada SF2520E (Exclusão da Nota Fiscal de Saída).  
@author Paulo Krüger
@since  09/03/2017
@param	cFilOri  - Filial
@param	cCodCli	 - Codigo do Cliente
@param	cLojCli  - Loja do Cliente
@param	cEmissao - Data de Emissao
@param	cSerie   - Serie da Nota
@param	cNFiscal - Numero da Nota
@return Nil  
@project MAN0000007423041_EF_034
@cliente Rededor
@version P12.1.7
/*/

User Function F0703402(cFilOri, cCodCli, cLojCli, cEmissao, cSerie, cNFiscal)
	Local cAlias01	:= ""
	Local cStatus	:= ""
	Local cEspecie	:= ""
	Local cNumPed	:= ""
	Local cSTATRS	:= "1"
	Local nRecnoP22	:= 0
	Local cRet		:= ""

	cAlias01 := GetNextAlias()

	BeginSql Alias cAlias01
	%noparser%
	SELECT	P22.R_E_C_N_O_	AS REGNUM,
			P22.P22_NUMPV	AS NUMPED,
			SF3.F3_CHVNFE	AS CHVNFE,
			SF3.F3_ESPECIE	AS ESPECI
			
	FROM 	%Table:SF3% SF3 INNER JOIN %Table:P22% P22 ON		P22.P22_NOTA	=	SF3.F3_NFISCAL
															AND P22.P22_SERIE	=	SF3.F3_SERIE
															AND P22.P22_FILPV	=	SF3.F3_FILIAL
	WHERE 		SF3.%notDel%
			AND	P22.%notDel%
			AND SF3.F3_FILIAL	=	%Exp:cFilAnt%
			AND	SF3.F3_NFISCAL	=	%Exp:cNFiscal% 
			AND SF3.F3_SERIE	=	%Exp:cSerie%
			AND P22.P22_EMPPV 	=	%Exp:cEmpAnt%
			AND P22.P22_FILPV	=	%Exp:cFilAnt% 
	EndSql

	If !(cAlias01)->(Eof())
		cRet		:=	"OK|NOTA FISCAL EXCLUIDA " + cNFiscal + "/" + cSerie
		cStatus		:=	"C"
		nRecnoP22	:=	(cAlias01)->REGNUM
		cChvSEFAZ	:=	(cAlias01)->CHVNFE
		cEspecie	:=	(cAlias01)->ESPECI
		cNumPed		:=	(cAlias01)->NUMPED   
		(cAlias01)->(dbCloseArea())

		SC5->(DbSetOrder(01))
		If !SC5->(DbSeek(cFilAnt + cNumPed))
			Conout("F0703202 - Registro não encontrado na tabela SC5: Filial/Pedido: " +  cFilAnt + "/" + cNumPed)
			U_F0703401(CValToChar(nRecnoP22), cSTATRS, "F", cNumPed)
			Return
		EndIf

		SF2->(DbSetOrder(01))
		If !SF2->(DbSeek(SC5->C5_FILIAL + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
			Conout("F0703202 - Registro não encontrado na tabela SF2: Nota: " + SC5->C5_NOTA + "/" + SC5->C5_SERIE)
			U_F0703401(CValToChar(nRecnoP22), cSTATRS, "F", cNumPed)
			Return
		EndIf

		SF3->(DbSetOrder(04))
		If !SF3->(DbSeek(SF2->F2_FILIAL + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC + SF2->F2_SERIE))
			Conout("F0703202 - Registro não encontrado na tabela SF3: Nota: " + SC5->C5_NOTA + "/" + SC5->C5_SERIE)
			U_F0703401(CValToChar(nRecnoP22), cSTATRS, "F", cNumPed)
			Return
		EndIf

		U_F0703401( CValToChar(nRecnoP22)      , cSTATRS                    , cNumPed                   , cRet, ;
					SF3->F3_FILIAL             , SC5->C5_XTIPO              , cStatus                   , SF2->F2_NFELETR, ;
					SF3->F3_SERIE              , SF3->F3_CLIEFOR            , SF3->F3_LOJA              , "T"            , ;
					StrZero(Day(SF3->F3_EMISSAO),2) + "/" + StrZero(Month(SF3->F3_EMISSAO),2) + "/" + StrZero(Year(SF3->F3_EMISSAO),4), ;
					SF3->F3_ESPECIE            , CValToChar(SF2->F2_VALBRUT), CValToChar(SF2->F2_VALISS), CValToChar(SF2->F2_VALPIS), CValToChar(SF2->F2_VALCOFI), ;
					CValToChar(SF2->F2_VALCSLL), CValToChar(SF2->F2_VALIRRF), CValToChar(SF2->F2_VALFAT), SF2->F2_MENNOTA, SF3->F3_CHVNFE             , ;
					SC5->C5_XNUM, SF3->F3_CODNFE )
	Else
		Conout("ERRO|NOTA FISCAL EXCLUIDA " + cNFiscal + "/" + cSerie + " NAO REGISTRADA NA TABELA P22 (JOB PEDIDOS DE VENDA)")          
	EndIf

Return

