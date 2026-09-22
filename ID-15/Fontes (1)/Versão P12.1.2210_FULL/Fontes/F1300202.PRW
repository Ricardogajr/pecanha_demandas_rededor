#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} F1300202
//TODO Descrição auto-gerada.
@author henrique.toyada
@since 18/10/2017
@version 6
@project MAN0000007423048_EF_002
@param cFilSoli, characters, filial da pessoa no momento
@param cMatSoli, characters, matricula da pessoa no momento
@param cVisao, characters, visão selecionada nos perguntes
@return cGeren, characters, Nome dos responsaveis pelo posto
@type function
/*/
user function F1300202(cFilSoli, cMatSoli, cVisao)
	//Criar rotina que busca concatenado os nomes dos gestores imediatos 
	Local cGeren    := ""
	Local cAliasAux := "TMPAUX"
	Local cQuery    := ""

	Local aAreaRD4	:= RD4->(GetArea())
	Local aAreaSRA	:= SRA->(GetArea())
	Local aAreaRCX	:= RCX->(GetArea())
	Local cFilRCX	:= ""
	Local cPostRCX	:= ""
	Local cCodRD4   := ""
	Local cItemRD4  := ""
	Local cFilResp  := ""
	Local cCodResp  := ""
	
	Default cFilSoli := ""
	Default cMatSoli := ""
	Default cVisao   := ""

	RD4->(DbSetOrder(7))
	
	If RD4->(DbSeek(xFilial("RD4")+ cVisao + cEmpAnt + cFilSoli + cMatSoli))
		cCodRD4	 := RD4->RD4_CODIGO
		cItemRD4 := RD4->RD4_TREE

		RD4->(DbSetOrder(1))
		If RD4->(DbSeek(xFilial("RD4")+ cCodRD4 + cItemRD4))
			cFilResp	:= RD4->RD4_FILIDE
			cCodResp	:= RD4->RD4_CODIDE

			If RCX->(DbSeek(cFilResp + cCodResp))
				cGeren := ""
				While RCX->(RCX_FILIAL + RCX_POSTO) == (cFilResp + cCodResp)
					If !Empty(cGeren)
						cGeren += ", "
					EndIf
					If SRA->(DbSeek(RCX->(RCX_FILFUN + RCX_MATFUN)))
						cGeren += SRA->RA_NOME
					EndIf
					RCX->(DbSkip())
				EndDo
			EndIf				
		EndIf		
	EndIf
	
	If Empty(cGeren)
		cGeren := "VAZIO"
	EndIf
	
	RestArea(aAreaRD4)
	RestArea(aAreaSRA)
	RestArea(aAreaRCX)
	
return cGeren
