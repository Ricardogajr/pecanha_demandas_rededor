/*{Protheus.doc} F1100105
Função responsável por gravar a tabela auxiliar de Afastamentos lançados de forma retroativa.
@author		Nairan Alves Silva
@since		03/08/2017
@project	MAN0000007423045_EF_003 
*/
User Function F1100105()
Local aAreaSRA	:= SRA->(GetArea())
Local aGravar	:= {}
Local nOpcao	:= 0 
If SRA->(DbSeek(TOF->TOF_FILIAL+SubStr(TOF->TOF_NUMFIC,1,6)))
	If (SubStr(DTOS(TOF->TOF_DTSLIC),1,6) < SubStr(DTOS(Date()),1,6) .And. !Empty(TOF->TOF_DTSLIC)).OR.;
			(SubStr(DTOS(TOF->TOF_DTRLIC),1,6) < SubStr(DTOS(Date()),1,6) .And.  !Empty(TOF->TOF_DTRLIC))
		If INCLUI
			nOpcao := 3
		ElseIf ALTERA
			nOpcao := 4
		Else
			nOpcao := 5
		Endif
		aAdd(aGravar,{	TOF->TOF_FILIAL,;//-01 //-SR8->R8_FILIAL
				SRA->RA_MAT,;//-03 //-SR8->R8_MAT
				SRA->RA_CC,;//-02 //-SR8->R8_CC
				SRA->RA_ADMISSA,;//-04 //-
				SRA->RA_SITFOLH,;//-05 //-
				SRA->RA_CATFUNC,;//-06 //-
				,;//-07 //-SR8->R8_TIPO
				TOF->TOF_CODAFA,;//-08 //-SR8->R8_TIPOAFA	//-(*) Campo novo
				"MAT",;//-09 //-SR8->R8_SEQ
				TOF->TOF_DTSLIC,;//-10 //-SR8->R8_DATAINI
				TOF->TOF_DTRLIC; //-11 //-SR8->R8_DATAFIM
		})			
		If Len(aGravar) >= 1
			U_F1100102(nOpcao,aGravar)
		EndIf
	EndIf
EndIf
RestArea(aAreaSRA)
Return