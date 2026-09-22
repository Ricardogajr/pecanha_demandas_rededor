#Include 'Protheus.ch'

/*{Protheus.doc} 
Ponto de entrada para a validação na gravação da Cópia de Lancamento Contábil com (LCT MANUAL + Usuário logado)
@author  Thiago Pereira
@since   26/03/2019
ID 1544 BACKOFICCE 
*/

User Function CT105POS ()

	Local lRetorno := ParamIXB[1]
	Local nRecTMP := TMP->(Recno())

	//Se for copia	
	if Opcao = 7
		tmp->( dbGoTop() )
		While TMP->(!EOF()) 
			TMP->(RecLock("TMP",.F.))
			tmp->CT2_ORIGEM := "LCT MANUAL - " +  RetNameC()
			TMP->(MsUnlock())
		
			TMP->(dbskip())
		EndDo
	Endif

	//Volta para o recno original
	TMP->(DbGoTo(nRecTMP))
Return (lRetorno)
Static Function RetNameC()
Return UsrRetName(RetCodUsr())
