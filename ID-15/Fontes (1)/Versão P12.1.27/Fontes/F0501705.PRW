//-----------------------------------------------------------------------
/*/{Protheus.doc} F0501705
Validação exclusão de linha nas funções GPEA580 e GPEA590
 
@author Nairan Alves Silva
@since  07/12/2017
@return Nil  

@project MAN0000007423048_EF_018
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F0501705()
	Local aAreaRGB		:= RGB->(GetArea())
	Local aAreaSRC		:= SRC->(GetArea())
	Local lRet			:= .T.
	Local nPosIntApd	:= GdFieldPos("RGB_XIMPAP")
	Local nPosRec		:= GdFieldPos("RGB_REC_WT")
	
	If U_F0501702(__cUserId)
		If aColsAnt[n][nPosIntApd] == "I" .And. !Empty(aColsAnt[n][nPosIntApd])
			RGB->(DbGoTo(aCols[n][nPosRec]))
			If AllTrim(RGB->RGB_ROTEIRO) != "RES" .Or. (SRC->(DbSeek(RGB->(RGB_FILIAL + RGB_MAT + RGB_PD + RGB_CC + RGB_SEMANA + RGB_SEQ)))) 
				MsgAlert("Somente roteiro RES não calculados podem ser deletados.","ATENCAO")
				lRet := .F.
			EndIf
		EndIf
	Else
		MsgAlert("Usuário não possui permissão para alterar registros originados via integração Apdata.","ATENCAO")
		lRet := .F.
	EndIf

	RestArea(aAreaRGB)
	RestArea(aAreaSRC)
Return (lRet)