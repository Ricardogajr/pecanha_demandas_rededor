#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F0702701
Função para integração de títulos de recebimento antecipado
@type User function
@author anieli.rodrigues
@since 09/03/2017
@version 12.7
@param nOperac, numérico, operação realizada 3 - Inclusão 4 - Alteração 5 - Exclusão
@project MAN0000007423041_EF_027
/*/

User Function F0702701(nOperac)
	
	Local aAreaSA1:= SA1->(GetArea())
	Local aDados	:= {}
	Local cRet		:= "" 
	Local cXID		:= U_GetIntegID()
	
	If Alltrim(SE1->E1_TIPO) == "RA" 
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))
			
		If SA1->A1_XOPCM == '1'
		
			If nOperac == 3 .Or. nOperac == 4  		
				RecLock("SE1",.F.)
				SE1->E1_XID := cXID
				SE1->(MsUnlock())
			EndIf
				
			aDados := { 	nOperac,;
							cFilAnt,; 
							SE1->E1_PREFIXO,; 
							SE1->E1_PARCELA,;
							SE1->E1_TIPO,;
							SE1->E1_NATUREZ,;
							SE1->E1_CLIENTE,;
							SE1->E1_LOJA,;
							SA1->A1_NOME,;
							StrZero(Day(SE1->E1_EMISSAO),2) + "/" + StrZero(Month(SE1->E1_EMISSAO),2) + "/" + StrZero(Year(SE1->E1_EMISSAO),4),;
							SE1->E1_NUM,;
							SE1->E1_BCOCHQ,; 
							SE1->E1_AGECHQ,; 
							SE1->E1_CTACHQ,;
							Iif(nOperac == 5, Str(0), Str(SE1->E1_VALOR)),;
							SA1->A1_CGC}
							//SE1->E1_NOMCLI,; 	
			cRet := U_F0702702(aDados)
			 
		EndIf  
	EndIf  
	
	RestArea(aAreaSA1)	
	
Return 
