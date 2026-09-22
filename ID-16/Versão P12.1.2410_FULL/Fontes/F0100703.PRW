#Include 'Protheus.ch'

/*
{Protheus.doc} F0100703()
Controle de conversão B91
@Author     Bruno de Oliveira
@Since      11/04/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_007
@Param		aParam, array, informações da empresa e filial
@Return
*/
User Function F0100703(aParam)
	
	Local cAlias1 := GetNextAlias()
	Local aMatric := {}
	Local nPos := 0
	Local cMat := ""
	Local cCpf := ""
	
	Default aParam := {"01","01010002"}
	
	RpcSetEnv(aParam[1],aParam[2])
	
	BeginSQL alias cAlias1
		
		Select TNY_FILIAL,TNY_NUMFIC,TNY_DTCONS,TNY_XCONVB,TNY_XCINSS
		
		From %table:TNY% TNY
		
		Where TNY_XCONVB = '1'
		AND TNY_XCINSS = ' '
		AND TNY.%notDel%
		
		Order By TNY_FILIAL,TNY_NUMFIC
		
	EndSql
	
	While (cAlias1)->(!EOF())
		
		cFilTNY := (cAlias1)->TNY_FILIAL
		
		DbSelectArea("TM0")
		TM0->(DbSetOrder(1))
		If TM0->(DbSeek(cFilTNY + (cAlias1)->TNY_NUMFIC))
			cMat := TM0->TM0_MAT
			cNome := Alltrim(TM0->TM0_NOMFIC)
			cCpf := TM0->TM0_CPF
		EndIf
		
		nPos := AScan(aMatric,{|x| x[1] == cFilTNY })
		If nPos > 0
			AAdd(aMatric[nPos],{cMat,cNome,cCpf,(cAlias1)->TNY_DTCONS})
		Else
			AAdd(aMatric,{cFilTNY,{cMat,cNome,cCpf,(cAlias1)->TNY_DTCONS}})
		EndIf
		
		(cAlias1)->(DbSkip())
	End
	
	If Len(aMatric) > 0
		FPrepEmail(aMatric)
	EndIf
	
	RpcClearEnv()
	
Return

/*
{Protheus.doc} FPrepEmail()
Preparação do corpo do e-mail
@Author     Bruno de Oliveira
@Since      12/04/2016
@Version    P12.1.07
@Project    MAN00000462901_EF_007
@Param		aDados, array, dados do e-mail
@Return
*/
Static Function FPrepEmail(aDados)
	
	Local cAssunto := "Contestação da B91"
	Local cEmailRsp := ""
	Local cConteudo := ""
	Local cCcopia	:= ""
	Local cDepto	:= "000000001"
	Local lRet := .T.
	Local nX := 0
	Local nY := 0
	Local cErro := ""
	
	For nX := 1 To Len(aDados)
		
		cErrJb := ""
		
		cConteudo += "Prezado," + CRLF
		cConteudo += "Por favor realizar a contestação da B91 no site da "
		cConteudo += "Previdência Social ou INSS no prazo de até 15 dias após a conversão." + CRLF
		cConteudo += '<html>' + CRLF
		cConteudo += '<head>' + CRLF
		cConteudo += '   <title></title>' + CRLF
		cConteudo += '</head>' + CRLF
		cConteudo += '<body>' + CRLF
		cConteudo += '<br>' + CRLF
		cConteudo += '   <table border=1 width=100% >' + CRLF
		cConteudo += '      <tr>' + CRLF
		cConteudo += '         <th><font size="1" > Matricula			</font></th>' + CRLF
		cConteudo += '         <th><font size="1" > Nome do Funcionário	</font></th>' + CRLF
		cConteudo += '         <th><font size="1" > CPF					</font></th>' + CRLF
		cConteudo += '         <th><font size="1" > Data Atestado		</font></th>' + CRLF
		cConteudo += '      </tr>' + CRLF
		
		For nY := 1 To Len(aDados[nX])
			
			If nY > 1
				dData := STOD(aDados[nX][nY][4])
				
				cConteudo += '     <tr>'
				cConteudo += '      <td><font size="1">' + aDados[nX][nY][1]		+ '</font></td>' + CRLF
				cConteudo += '      <td><font size="1">' + aDados[nX][nY][2]			+ '</font></td>' + CRLF
				cConteudo += '      <td><font size="1">' + aDados[nX][nY][3]			+ '</font></td>' + CRLF
				cConteudo += '      <td><font size="1">' + DTOC(dData)		+ '</font></td>' + CRLF
				cConteudo += '   </tr>'
			EndIf
			
		Next nY
		
		If Len(aDados[nX]) > 0
			
			cConteudo += '   </table>' + CRLF
			cConteudo += '</body>' + CRLF
			cConteudo += '</html>' + CRLF
			
			lRet := U_F0100702(aDados[nX][1],cAssunto,cConteudo,.F.)
			
		EndIf
		
		cConteudo := ""
		
	Next nX
	
Return lRet
