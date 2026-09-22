#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} MTALCFIM
Controla a gravação de alçadas nos processos de compras.
@author 	Paulo Krüger
@since 		18/09/2017
@version 	P12.7
@Project    MAN0000007423046
@Return 	Nil
/*/
 
User Function MTALCFIM()
Local aArea    := GetArea()
Local aDocto   := PARAMIXB[1]
Local dDataRef := PARAMIXB[2]
Local nOper    := PARAMIXB[3]
Local cDocSF1  := PARAMIXB[4]
Local lResiduo := PARAMIXB[5]
Local lRet
	
/* PARAMIXB[3] = Número da Operação, que pode ser:   
	1 = Inclusão de Documento
	2 = Transferência da Alçada para o Superior
	3 = Exclusão do Documento
	4 = Aprovação do Documento
	5 = Estorno da Aprovação
6 = Bloqueio Manual
*/
	
If IsInCallStack('U_F1200709') 
 	lRet := U_F1200717(.F.) //Verifica se a medição de contrato vem de rotina customizada
Else 
	If FindFunction("U_F1207504")
		lRet := U_F1207504("D",aDocto,nOper) //Rotina para gravar o código do aprovador anterior.
	Endif
Endif
    
   // ID 1529 - 13/02/2019 - Marcos Furtado - Incluir ajustes de campos customizados para operação de transferência da alçada.
   If nOper == 2  //Transferência da Alçada para o Superior
		U_F1201004(SCR->CR_FILIAL,ALLTRIM(SCR->CR_NUM),SCR->CR_TIPO) 
	EndIF

RestArea(aArea)

Return lRet
