#Include 'Protheus.ch'
//---------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SA2VLD01
Valida o preechimento de alguns campos, funçao chamada pelo pontos de entrada MA020ALT(alteração) e MA020TOK (inclusão).
@type function
@author Cris
@since 03/08/2017
@version 1.0
@return ${lógico}, ${.T. válido .F. não válido}
/*///---------------------------------------------------------------------------------------------------------------------------
User Function SA2VLD01()

	Local aArea		:= GetArea()
	Local lVldSA2	:= .T.
	Local cTpForSA2	:= M->A2_TIPO
	Local cCGCSA2	:= M->A2_CGC
	Local cPFisSA2	:= M->A2_PFISICA

		if cTpForSA2 <> 'X' .AND. Empty(cCGCSA2)
			
			Help('',1,'SA2VLD01_01',,"Preenchimento obrigatório",1,0,,,,,,{"Para fornecedor tipo J(Jurídico) ou F(Físico) preencha o campo CNPJ/CPF(A2_CGC)."})
			lVldSA2	:= .F.
			
		Elseif cTpForSA2 == 'X' .AND. Empty(cPFisSA2)
			
			Help('',1,'SA2VLD01_02',,"Preenchimento obrigatório",1,0,,,,,,{"Para fornecedor tipo X(Outros) preencher o campo RG./Ced.Estr.(A2_PFISICA)"})
			lVldSA2	:= .F.
			
		Elseif cTpForSA2 == 'X' .AND. !Empty(cCGCSA2) //13/11/18: Alterado para !Empty, pois CGC não pode estar preenchido se for estrangeiro
			
			Help('',1,'SA2VLD01_03',,"Preenchimento incorreto",1,0,,,,,,{"Para fornecedor tipo X(Outros) não preencher o campo CPNJ/CPF(A2_CGC)"})
			lVldSA2	:= .F.
		
		Elseif cTpForSA2 <> 'X' .AND. !Empty(cPFisSA2)
			
			Help('',1,'SA2VLD01_04',,"Preenchimento incorreto",1,0,,,,,,{"Para fornecedor tipo J(Jurídico) ou F(Físico) não preencher o campo RG./Ced.Estr.(A2_PFISICA)"})
			lVldSA2	:= .F.
									
		EndIf

	RestArea(aArea)
	
Return lVldSA2