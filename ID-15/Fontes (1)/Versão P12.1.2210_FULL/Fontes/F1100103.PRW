#INCLUDE 'Protheus.ch'

/*{Protheus.doc} F1100103
Pto.Entrada (GP2410VAL) 

@author		Ademar Fernandes
@since		27/07/2017
@project	MAN0000007423045_EF_003 
*/
User Function F1100103(oGrid,oGridSRA)
	Local aGravar := {}
	Local lRet := .T.
	Local nLenGrid	:= oGrid:Length()
	Local nLinha	:= 0
	Local nLinAtual := oGrid:GetLine()
	Local nOpcao	:= 5
	Local lRDtIn    := .F.
	Local lRDtFn    := .F.	
	
	For nLinha := 1 to nLenGrid
		oGrid:GoLine(nLinha)
		SR8->(dbGoto(oGrid:GetDataId()))
		If !oGrid:IsDeleted() .And. (oGrid:IsInserted() .Or. (( lRDtIn := oGrid:GetValue("R8_DATAINI") != SR8->R8_DATAINI) .Or. (lRDtFn := oGrid:GetValue("R8_DATAFIM") != SR8->R8_DATAFIM)))//oGrid:IsUpdated()	//-A linha foi modificada?
			If (IIF(lRDtIn,SubStr(DTOS(oGrid:GetValue("R8_DATAINI")),1,6) < SubStr(DTOS(Date()),1,6),.F.) .And. !Empty(oGrid:GetValue("R8_DATAINI"))) .OR.;
				(IIF(lRDtFn,SubStr(DTOS(oGrid:GetValue("R8_DATAFIM")),1,6) < SubStr(DTOS(Date()),1,6),.F.) .And. !Empty(oGrid:GetValue("R8_DATAFIM")))
				aGravar := {}
				If !oGrid:IsInserted()
					aAdd(aGravar,{	oGrid:GetValue("R8_FILIAL"),;//-01 //-SR8->R8_FILIAL
								oGrid:GetValue("R8_MAT"),;//-03 //-SR8->R8_MAT
								POSICIONE("SRA",1,oGrid:GetValue("R8_FILIAL")+oGrid:GetValue("R8_MAT"),"RA_CC"),;//-02 //-SR8->R8_CC
								oGridSRA:GetValue("RA_ADMISSA"),;//-04 //-
								POSICIONE("SRA",1,oGrid:GetValue("R8_FILIAL")+oGrid:GetValue("R8_MAT"),"RA_SITFOLH"),;//-05 //-
								POSICIONE("SRA",1,oGrid:GetValue("R8_FILIAL")+oGrid:GetValue("R8_MAT"),"RA_CATFUNC"),;//-06 //-
								,;//-07 //-SR8->R8_TIPO
								oGrid:GetValue("R8_TIPOAFA"),;//-08 //-SR8->R8_TIPOAFA	//-(*) Campo novo
								oGrid:GetValue("R8_SEQ"),;//-09 //-SR8->R8_SEQ
								oGrid:GetValue("R8_DATAINI"),;//-10 //-SR8->R8_DATAINI
								oGrid:GetValue("R8_DATAFIM"); //-11 //-SR8->R8_DATAFIM
								})
					nOpcao := 4
				Else
					SRA->(DbSetOrder(1))
					If SRA->(DbSeek(oGridSRA:GetValue("RA_FILIAL")+oGridSRA:GetValue("RA_MAT")))
						aAdd(aGravar,{	SRA->RA_FILIAL,;//-01 //-SR8->R8_FILIAL
									SRA->RA_MAT,;//-03 //-SR8->R8_MAT
									SRA->RA_CC,;//-02 //-SR8->R8_CC
									SRA->RA_ADMISSA,;//-04 //-
									SRA->RA_SITFOLH,;//-05 //-
									SRA->RA_CATFUNC,;//-06 //-
									,;//-07 //-SR8->R8_TIPO
									oGrid:GetValue("R8_TIPOAFA"),;//-08 //-SR8->R8_TIPOAFA	//-(*) Campo novo
									oGrid:GetValue("R8_SEQ"),;//-09 //-SR8->R8_SEQ
									oGrid:GetValue("R8_DATAINI"),;//-10 //-SR8->R8_DATAINI
									oGrid:GetValue("R8_DATAFIM"); //-11 //-SR8->R8_DATAFIM
									})	
						nOpcao := 3			
					EndIf
				EndIf
			EndIf
			If Len(aGravar) > 0
				If !oGrid:IsDeleted()	//-A linha está deletada?
					//-Grava a tabela de Afastamentos cadastrados de forma retroativa
					U_F1100102(nOpcao,aGravar)
				Else
					//-Grava a tabela de Afastamentos cadastrados de forma retroativa
					U_F1100102(nOpcao,aGravar)
				EndIf
			EndIf
		Else
			If oGrid:IsDeleted()	//-A linha está deletada?
				If (SubStr(DTOS(oGrid:GetValue("R8_DATAINI")),1,6) < SubStr(DTOS(Date()),1,6) .And. !Empty(oGrid:GetValue("R8_DATAINI"))) .OR.;
					(SubStr(DTOS(oGrid:GetValue("R8_DATAFIM")),1,6) < SubStr(DTOS(Date()),1,6) .And. !Empty(oGrid:GetValue("R8_DATAFIM")))
						aGravar := {}	
						aAdd(aGravar,{	oGrid:GetValue("R8_FILIAL"),;//-01 //-SR8->R8_FILIAL
									oGrid:GetValue("R8_MAT"),;//-03 //-SR8->R8_MAT
									POSICIONE("SRA",1,oGrid:GetValue("R8_FILIAL")+oGrid:GetValue("R8_MAT"),"SRA->RA_CC"),;//-02 //-SR8->R8_CC
									oGridSRA:GetValue("RA_ADMISSA"),;//-04 //-
									POSICIONE("SRA",1,oGrid:GetValue("R8_FILIAL")+oGrid:GetValue("R8_MAT"),"RA_SITFOLH"),;//-05 //-
									POSICIONE("SRA",1,oGrid:GetValue("R8_FILIAL")+oGrid:GetValue("R8_MAT"),"RA_CATFUNC"),;//-06 //-
									,;//-07 //-SR8->R8_TIPO
									oGrid:GetValue("R8_TIPOAFA"),;//-08 //-SR8->R8_TIPOAFA	//-(*) Campo novo
									oGrid:GetValue("R8_SEQ"),;//-09 //-SR8->R8_SEQ
									oGrid:GetValue("R8_DATAINI"),;//-10 //-SR8->R8_DATAINI
									oGrid:GetValue("R8_DATAFIM"); //-11 //-SR8->R8_DATAFIM
									})
				EndIf
				If Len(aGravar) > 0
					//-Grava a tabela de Afastamentos cadastrados de forma retroativa
					U_F1100102(nOpcao,aGravar)
				EndIf
			EndIf
		EndIf
	Next nLinha
Return(lRet)
/*
{ STR0003,	"M685INC"   , 0 , 3},;	 //"Incluir"
{ STR0004,	"M685INC"   , 0 , 4},;	 //"Alterar"
{ STR0005,	"M685INC"   , 0 , 5, 3},;//"Excluir"
*/
