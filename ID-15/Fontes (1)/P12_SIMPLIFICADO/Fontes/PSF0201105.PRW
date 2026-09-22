#Include 'Totvs.ch'

/*
{Protheus.doc} F0201105()
Gatilhos para Arvore de Busca de SubGrupo, Grupo e Tipo
@Author     Robson William
@Since      17/05/2017
@Version    P12.7
@Project    MAN000000463301_AID_011_02
@Menu		Compras\Atualizacoes\Cadastros\Produtos  

@Author     Marcos Furtado
@Since      13/09/2018
@Version    P12.1.17
@Desc       Alteração para gravação com MVC

*/
  
User Function F0201105()
    
    Local cRetorno := &(ReadVar())
    Local cCampo   := StrTran(ReadVar(),"M->","")

	Local oModel := FWModelActive()

    If Empty(cRetorno)
        Return cRetorno
    Endif

    P25->(DbSetOrder(2)) //P25_FILIAL+P25_SUBGRP+P25_GRUPO

    If cCampo $ "B1_XSUBGRP"
        If !P25->(DbSeek(xFilial("P25")+cRetorno))
            Help(,,'F02011051',,"SubGrupo " + M->B1_XSUBGRP + " não possui amarração com Grupo nem Tipo. Favor informar um SubGrupo válido!",1,0)
            cRetorno := Space(TamSX3(cCampo)[1])
        Else
            SBM->(DbSetOrder(1))
            If !SBM->(DbSeek(XFilial("SBM")+P25->P25_TIPO)) .Or. ( SBM->(FieldPos("BM_MSBLQL") > 0 .And. BM_MSBLQL == "1") )
                Help(,,'F02011055',,"Tipo " + P25->P25_TIPO + " não encontrado ou bloqueado!",1,0)
                cRetorno := Space(TamSX3(cCampo)[1])
            Else
/*                M->B1_XGRPPRO := P25->P25_GRUPO
                M->B1_GRUPO   := P25->P25_TIPO
                M->B1_CONTA   := SBM->BM_XCTPAT
                M->B1_XCTDES  := SBM->BM_XCONTA
                M->B1_XCTREC  := SBM->BM_XCTREC     */

				oModel:SetValue("SB1MASTER",'B1_XGRPPRO',P25->P25_GRUPO)
				oModel:SetValue("SB1MASTER",'B1_GRUPO'  ,P25->P25_TIPO)                
				oModel:SetValue("SB1MASTER",'B1_CONTA'  ,SBM->BM_XCTPAT)                
				oModel:SetValue("SB1MASTER",'B1_XCTDES' ,SBM->BM_XCONTA)        
				oModel:SetValue("SB1MASTER",'B1_XCTREC' ,SBM->BM_XCTREC)  
							       								
            EndIf
    	EndIf        
    Endif
    
    If Empty(cRetorno)
 /*      M->B1_XGRPPRO := Space(TamSX3("B1_XGRPPRO")[1])
        M->B1_GRUPO   := Space(TamSX3("B1_GRUPO")[1])
        M->B1_CONTA   := Space(TamSX3("BM_XCTPAT")[1])
        M->B1_XCTDES  := Space(TamSX3("BM_XCONTA")[1])
        M->B1_XCTREC  := Space(TamSX3("BM_XCTREC")[1])     */
        
		oModel:SetValue("SB1MASTER",'B1_XGRPPRO',Space(TamSX3("B1_XGRPPRO")[1]))
		oModel:SetValue("SB1MASTER",'B1_GRUPO'  ,Space(TamSX3("B1_GRUPO")[1]))                
		oModel:SetValue("SB1MASTER",'B1_CONTA'  ,Space(TamSX3("B1_CONTA")[1]))                
		oModel:SetValue("SB1MASTER",'B1_XCTDES' ,Space(TamSX3("B1_XCTDES")[1]))        
		oModel:SetValue("SB1MASTER",'B1_XCTREC' ,Space(TamSX3("B1_XCTREC")[1]))  
				        
	EndIf	                                                    
				
	oModel:CommitData() 
    
Return cRetorno
