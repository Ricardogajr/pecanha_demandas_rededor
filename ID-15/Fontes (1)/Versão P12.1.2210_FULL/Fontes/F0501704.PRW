//-----------------------------------------------------------------------
/*/{Protheus.doc} F0501704
Validação na alteração de linha das funções GPEA580 e GPEA590
 
@author Nairan Alves Silva
@since  07/12/2017
@return Nil  

@project MAN0000007423048_EF_018
@cliente Rededor
@version P12.1.7
             
/*/
//-----------------------------------------------------------------------
User Function F0501704()
	Local lRet			:= .T.
	Local nX			:= 0
	Local nY			:= 0
	Local nPosDeleted	:= GdFieldPos("GDDELETED") 
	Local nPosIntApd	:= GdFieldPos("RGB_XIMPAP")
	Local nPosSeq		:= GdFieldPos("RGB_SEQ")
	Local nPosEfetiva	:= GdFieldPos("RGB_EFETIVA")
	Local nPosFil		:= GdFieldPos("RGB_FILIAL")
	Local nPosRec		:= GdFieldPos("RGB_REC_WT")
	Local nLinAtu		:= oGet:nAt
	Local aAreaRGB		:= RGB->(GetArea())
	
	If Len(aColsAnt) >= nLinAtu .And. aCols[oGet:nAt][nPosRec] > 1
		RGB->(DbGoTo(aCols[oGet:nAt][nPosRec]))
		If AllTrim(aColsAnt[nLinAtu][nPosIntApd]) == "I" 
			For nY := 1 To Len(aHeader)				
				If U_F0501702(__cUserId)
					If ((aColsAnt[nLinAtu][nY] != aCols[nLinAtu][nY])  .And. nPosSeq != nY) .Or. aColsAnt[nLinAtu][Len(aHeader)+1]
						If AllTrim(RGB->RGB_ROTEIRO) != "RES" //.And. AllTrim(aColsAnt[nLinAtu][nPosEfetiva]) != "S" AllTrim(aCols[nX][nPosIntApd]) == "I"	
							MsgAlert("Somente registros com o roteiro RES e não efetivados podem ser alterados.","ATENCAO")
							lRet := .F.		
						EndIf 
					EndIf
				Else
					MsgAlert("Usuário não possui permissão para alterar registros originados via integração Apdata.","ATENCAO")
					lRet := .F.
					Exit
				EndIf
			Next
		EndIf
	EndIf

	RestArea(aAreaRGB)	
Return (lRet)