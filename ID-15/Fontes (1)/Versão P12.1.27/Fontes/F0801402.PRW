#Include 'Protheus.ch'

/*
{Protheus.doc} F0801402()
Efetua a gravação dentro da tabela de histórico
@Author     Henrique Madureira
@Since      19/05/2017
@Version    P12.1.07
@Project    MAN0000007423042_CV_014
@Param      cFIRH3H4, caracter, filial solicitação
@Param      cSolicit, caracter, solicitação
@Param      cFilApr, caracter, filial aprovador
@Param      cMatApr, caracter, matricula aprovador
@Param      cObs, caracter, observação
@Return	 
*/
User Function F0801402(cFIRH3H4, cSolicit, cFilApr, cMatApr, cObs)
	
	Local aAreas     := {SRA->(GetArea()),PAE->(GetArea()),GetArea()}
	
	SRA->(DbSetOrder(1))
	If SRA->(DbSeek(cFilApr + cMatApr))
		
		Reclock("PAE", .T.)
		PAE->PAE_FILIAL := cFIRH3H4
		PAE->PAE_NUMSOL := cSolicit
		PAE->PAE_FILAPR := cFilApr
		PAE->PAE_DESCFI := FWFilialName(,cFIRH3H4,1)
		PAE->PAE_MATAPR := cMatApr
		PAE->PAE_FUNAPR := POSICIONE("SRJ",1,XFILIAL("SRJ") + SRA->RA_CODFUNC, "RJ_DESC")
		PAE->PAE_NOMEAP := SRA->RA_NOME
		PAE->PAE_DCCAPR := Posicione("CTT", 1, XFilial("CTT") + SRA->RA_CC, "CTT_DESC01")
		PAE->PAE_OBS    := cObs
		PAE->(MsUnlock())
	
	EndIf
	
	AEval(aAreas, {|x| RestArea(x)} )
	
Return 

