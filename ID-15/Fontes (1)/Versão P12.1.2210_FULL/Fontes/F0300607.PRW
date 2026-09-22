#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#include 'FILEIO.ch'

Static aLogTt	:= {}

/*
{Protheus.doc} F0300607()
Importação carteirinha de saude
@Author     Rogerio Candisani
@Since      07/11/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Return
*/
User Function F0300607()
    
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca 		:= 0
	Local aArea			:= GetArea()
	Private cTpForn		:= ''
	Private	aRet		:= {}
	Private cArqImp		:= ''
	Private cPerg		:= "FSW0300607"	// Gp. perguntas especifico RHO
	Private cProcesso	:= ""			// Variavel utilizada na funcao gpRCHFiltro() Consulta Padrao - 1 = Periodos Abertos
	Private cDrvAt	:= ''
	Private cDirect	:= ''
				    
	cCadastro := OemToAnsi("Importação carteira saúde")
	AAdd(aSays,OemToAnsi("Esta rotina atualizará o número das carteirinhas com: ") + CRLF )   	// "Esta rotina importa valores para os seguintes arquivos: "
	AAdd(aSays,OemToAnsi("o Arquivo Carteira Saúde OU Carteira Odontológica ") + CRLF )
	AAdd(aSays,OemToAnsi("Conforme definido na rotina de cadastro de Layout de Importação.") )   			// "Conforme definido na rotina de cadastro de Layout de Importacao."
	//AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.)  } } )
	AAdd(aButtons, { 5,.T.,{|| ParamImp()  } } )
	//AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,If(MsgYesNo(OemToAnsi("Confirma a importação de carteira tipo  " + Iif(MV_PAR02==1,'SAÚDE','ODONTOLÓGICO') + "?"),OemToAnsi("Atencao")),FechaBatch(),nOpca:=0) }} )
	AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,if(U_F0300608(),If(MsgYesNo(OemToAnsi("Confirma a importação de carteira tipo  " + Iif(cTpForn=='1','SAÚDE','ODONTOLÓGICO') + "?"),OemToAnsi("Atencao")),FechaBatch(),nOpca:=0),.F.) }} )
	AAdd(aButtons, { 2,.T.,{|o| nOpca := 0, FechaBatch() }} )
		
	FormBatch( cCadastro, aSays, aButtons )
	If nOpca == 1
		Processa({|lEnd| F03006Proc(),"Importacao carteira de saúde"})
	EndIf
	
	aLogTt	:= {}
	cTpForn	:= ''
	aRet	:= {}
	cArqImp	:= ''
	
	RestArea(aArea)
	
Return( Nil )
/*{Protheus.doc} ParamImp
(long_description)
@type function
@author 
@since 22/12/2016
@version 1.0
@return ${return}, ${return_description}
*/
Static Function ParamImp()

	Local aPergs		:= {}
	Local cParaFil		:= Space(TamSx3('RHK_FILIAL')[1])
	Private nTipImp		:= 1
	Private	cCamIni		:= 'C:\' + space(97)
	
		aRet	:= {}
		
	 	AAdd( aPergs ,{1,"Selecione Para Filial:",cParaFil,"@!",'.T.','SM0','.T.',50,.F.})
	 	AAdd( aPergs ,{2,'Selecione o Tipo de Plano:',nTipImp,{'1=Saúde','2-Odontológico'},60,'.T.',.T.})
	 	AAdd( aPergs ,{6,'Selecione o arquivo:',cCamIni,'@!','.T.','.T.',100,.T.,"Arquivos .CSV|*.CSV",'C:\',GETF_LOCALHARD} )
	 	 	
	 	ParamBox(aPergs ,"Parametros ",aRet)      
	 	
Return 

/*{Protheus.doc} VlArq
(long_description)
@type function
@author Cris
@since 22/12/2016
@version 1.0
@return ${return}, ${return_description}
*/
Static Function VlArq()

	Local lVlArq	:= .T.
	Local cDrive	:= ''
	Local cDirect	:= ''
	Local cExtens	:= ''
	
		SplitPath(aRet[3],@cDrive,@cDirect,@cArqImp,@cExtens)	
		
		if Substring(aRet[1],1,1) == '1'
		
			if !'SAUDE' $ cArqImp
			
				Help("",1, "Help", "Tipo X Nome do Arquivo(VlArq_01)", "O tipo esta como 'SAUDE' selecione  um arquivo referente a Carteirinhas do Plano de Saúde,contendo em seu nome a palavra 'SAUDE'!" , 3, 0)
				lVlArq	:= .F.
				
			EndIf
			
			cTpForn	:= '1'
			
		Elseif  Substring(aRet[1],1,1) == '2'
		
			if !'ODONTOLOGIC' $ cArqImp

				Help("",1, "Help", "Tipo X Nome do Arquivo(VlArq_01)", "O tipo esta como 'ODONTOLOGICO' selecione  um arquivo referente a Carteirinhas do Odontológico,contendo em seu nome a palavra 'ODONTOLOGIC'!" , 3, 0)			
				lVlArq	:= .F.
				
			EndIf

				cTpForn	:= '2'
									
		Else
		
			lVlArq	:= .F.
			
		EndIf
		
Return lVlArq
/*
{Protheus.doc} F03006PROC
Leitura Arquivo Texto e Gravacao no Arq. Valores Variaveis.
@author Rogerio Candisani
@since 17/10/16
@version P12.7
*/
Static Function F03006PROC()

	Local aReg		:={}
	Local cArquivo	:=	""
	Local nX		:= 	0
	Local cTXT		:= 	''
	Local aBenef	:=	{}
	
	If Len(aRet) < 3
		MsgAlert("Favor selecionar o arquivo a ser importado! Verifique os parametros.", "Atenção!")
		Return
	Else
		cArquivo := aRet[3]
	EndIf

	//gerar importação dos arquivos
	oFile := FwFileReader():New(cArquivo)
	
	//Abertura do arquivo texto.
	If !(oFile:Open())
		MsgAlert("O arquivo de nome " + Alltrim(cArquivo) + " não pode ser aberto! Verifique os parametros.", "Atenção!")
		Return
	EndIf

	While (oFile:hasLine())

		cTXT := oFile:GetLine()
		AAdd(aReg,cTXT)
	
	End
	
	_cTotal := Len(aReg)
	ProcRegua(_cTotal)

		aItens := {}

	//Ler os aqrquivos .csv
	For nX:= 2 to len(aReg) // primeira linha cabecalho
		cBuffer := aReg[nX]

		aItens := StrTokArr2(cBuffer, ';', .T.)
                   
		If len(aItens) < 9 
			AAdd(aLogTt,{'','','','O layout da linha '+AllTrim(Str(nX))+' não está correto! A linha dever possuir no mínimo 9 colunas.'})	
		Else
			AAdd(aBenef,{  	aItens[1]  ,; //1-Filial
							aItens[2]  ,; //2-Matrícula
							aItens[3]  ,; //3-Tipo de benefício
							aItens[4]  ,; //4-Sequência do Dependente
							aItens[5]  ,; //5-Certificado
							aItens[6]  ,; //6-Cartão do plano
							aItens[7]  ,; //7-Nome do Segurado
							aItens[8]  ,; //8-Nº CPF Titular
							aItens[9] })//9-Nº CPF Dependente
		EndIf
	Next nX
	
	//inclui os CNS dos beneficiários
	InclBenef(aBenef)

Return

/*
{Protheus.doc} InclBenef
inclui os beneficiários
@Author     Rogerio Candisani
@Since      07/11/2016
@Version    P12.7
@Project    MAN00000463701_EF_006
@Param		aBenef, array que recebe os beneficiarios a serem atualizados
*/
Static Function InclBenef(aBenef)
	
	Local nY		:= 0
	Local lExisPln	:= .F.
	Local lDtFmPln	:= .F.
	Local lAtuPln	:= .F.
	Local cMesPer	:= StrZero(Month(dDatabase),2)
	Local cAnoPer	:= StrZero(Year(dDatabase),4)
	
	//definir os campos de gravação
	/*If MV_PAR02 == 1
		cTpForn := "1"
	Elseif MV_PAR02 == 2
		cTpForn:="2"
	Endif
	*/
		//posiciona no modelo do SRA
	For nY:= 1 to len(aBenef)

		lExisPln	:= .F.
		lDtFmPln	:= .F.
		lAtuPln		:= .F.
		
		If 	"TITULAR" $ UPPER(aBenef[nY][3]) .AND. (IIF(Empty(aRet[1]),.T.,aRet[1]==aBenef[nY][1]))
			//posicionar na RHK 
			DbSelectArea("RHK")
			RHK->(DbSetOrder(1))//RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR
			if RHK->(DbSeek(aBenef[nY][1] + aBenef[nY][2]))
				//Verifico se o titular possui o plano incluido 
				While !RHK->(EOF()) .AND. RHK->(RHK_FILIAL + RHK_MAT) == (aBenef[nY][1] + aBenef[nY][2])
				
					if RHK_TPFORN == cTpForn .AND. !lAtuPln
					
						//verificar se nao esta encerrado o plano
						lExisPln	:= .T.	
						If Empty(RHK->RHK_PERFIM) .OR. IIF(cAnoPer == Substring(RHK->RHK_PERFIM,3,4),cMesPer <= Substring(RHK->RHK_PERFIM,1,2),iIF(cAnoPer <= Substring(RHK->RHK_PERFIM,3,4),.T.,.F.)) //atualiza a carteira de vida
							
							if Alltrim(RHK->RHK_NCARVD) <> Alltrim(aBenef[nY][6])
							
								if	RHK->(Reclock('RHK',.F.))
									RHK->RHK_NCARVD	:= aBenef[nY][6]
									RHK->(MsUnlock())
													
									AAdd(aLogTt,{aBenef[nY][2],aBenef[nY][3],aBenef[nY][7],'Atualizado com sucesso.'})
									lAtuPln	:= .T.
									
								EndIf

							Else
												
								AAdd(aLogTt,{aBenef[nY][2],aBenef[nY][3],aBenef[nY][7],'O número da carteirinha já existe na base.'})													
								lAtuPln		:= .T.
								
							EndIf
							
							lDtFmPln	:= .F.
							
						Else
						
							lDtFmPln	:=  .T.
									
						Endif
					
					EndIf
					
					RHK->(DbSkip())
					
				Enddo
			
			EndIf
			
			//Se existi RHK mas a data final do plano for menor que a data atual
			if lExisPln .AND. lDtFmPln .AND. !lAtuPln
			
				AAdd(aLogTt,{aBenef[nY][2],aBenef[nY][3],aBenef[nY][7],'Não Atualizado. Plano(s) não estão vigente(s).'})
			
			Elseif !lExisPln .AND. !lAtuPln
			
				AAdd(aLogTt,{aBenef[nY][2],aBenef[nY][3],aBenef[nY][7],'Titular não cadastrado para este tipo de Plano.'})
					
			EndIf
			
		Elseif  (Empty(aRet[1]),.T.,aRet[1]==aBenef[nY][1])

			//posicionar na RHL 
			DbSelectArea("RHL")
			RHL->(DbSetOrder(2))//RHL_FILIAL + RHL_MAT + RHL_CODIGO + RHL_TPFORN + RHL_CODFOR
			if RHL->(DbSeek(aBenef[nY][1] + aBenef[nY][2] + aBenef[nY][4]))
					
				While !RHL->(EOF()) .AND.  AllTrim(RHL->(RHL_FILIAL + RHL_MAT + RHL_CODIGO)) == AllTrim((aBenef[nY][1] + aBenef[nY][2] + aBenef[nY][4]))

					If RHL_TPFORN == cTpForn .AND. !lAtuPln
					
						//verificar se nao esta encerrado o plano
						lExisPln	:= .T.	
	
						If Empty(RHL->RHL_PERFIM) .OR.  IIF(cAnoPer == Substring(RHL->RHL_PERFIM,3,4),cMesPer <= Substring(RHL->RHL_PERFIM,1,2),iIF(cAnoPer <= Substring(RHL->RHL_PERFIM,3,4),.T.,.F.))//atualiza a carteira de vida
							
							if Alltrim(RHL->RHL_NCARVD) <> aBenef[nY][6]
															
								if RHL->(Reclock('RHL',.F.))
									RHL->RHL_NCARVD	:= aBenef[nY][6]
									RHL->(MsUnlock())
								
									AAdd(aLogTt,{aBenef[nY][2],aBenef[nY][3],aBenef[nY][7],'Atualizado com sucesso.'})
									lAtuPln	:= .T.
									
								EndIf

							Else
												
								AAdd(aLogTt,{aBenef[nY][2],aBenef[nY][3],aBenef[nY][7],'O número da carteirinha já existe na base para este plano.'})
								lAtuPln	:= .T.
								
							EndIf
							
							lDtFmPln	:= .F.	
													
						Else
						
							lDtFmPln	:=  .T.
														
						Endif

					EndIf
					
					RHL->(DbSkip())
					
				Enddo
				
			Else
			
				AAdd(aLogTt,{aBenef[nY][2],aBenef[nY][3],aBenef[nY][7],'Dependente não cadastrado/Localizado no plano.'})
				
			EndIf
							
			//Se existi RHK mas a data final do plano for menor que a data atual
			if lExisPln .AND. lDtFmPln
			
				AAdd(aLogTt,{aBenef[nY][2],aBenef[nY][3],aBenef[nY][7],'Não Atualizado. Plano(s) não estão vigente(s).'})
							
			EndIf
				
		Endif
		
	Next nY

	if len(aLogTt) > 0
	
		//Chama rotina para gerar o excell com as informações de Log 
		FWMsgRun(,{|| GrvLog()},'Preenchendo o Arquivo de Log em Excel','Aguarde...' )
	
	EndIf
	
Return
/*
{Protheus.doc} GrvLog
Grava o log contendo o status da importação
@type function
@author 
@since 20/12/2016
@version P12.7
*/
Static Function GrvLog()

	Local oExcLog 	:= FWMsExcelEx():New()
	Local cAba1		:= 'Parametros'
	Local cTitulo1	:= 'Parametros Selecinados'
	Local cAba2		:= 'Informações'
	Local cTitulo2	:= 'Log de Importação de Carteirinha'
	Local nForLog	:= 0
	Local cNmArqEx	:= ''
	Local cCamiAux	:= Alltrim(aRet[3])
		
		//Aba - Parametros
		oExcLog:AddworkSheet(cAba1)
		oExcLog:AddTable (cAba1,cTitulo1)
		oExcLog:AddColumn(cAba1,cTitulo1,'Parametro',1,1)
		oExcLog:AddColumn(cAba1,cTitulo1,'Conteúdo Informado',2,1)
		oExcLog:AddRow(cAba1,cTitulo1,{'Filial',aREt[1]})
		oExcLog:AddRow(cAba1,cTitulo1,{'Tipo ',iif(iif(Valtype(aRet[2]) =='C',Substring(aRet[2],1,1),StrZero(aRet[2],1)) =='1','1=Médica','2=Odontológica')})
		oExcLog:AddRow(cAba1,cTitulo1,{'Caminho',cCamiAux})
	
		oExcLog:AddworkSheet(cAba2)
		oExcLog:AddTable (cAba2,cTitulo2)
		oExcLog:AddColumn(cAba2,cTitulo2,'Matrícula',1,1)
		oExcLog:AddColumn(cAba2,cTitulo2,'Tipo do Beneficiário',2,1)
		oExcLog:AddColumn(cAba2,cTitulo2,'Nome do Beneficiário',2,1)
		oExcLog:AddColumn(cAba2,cTitulo2,'Status',2,1)
		
	For nForLog := 1 to len(aLogTt)

		oExcLog:AddRow(cAba2,cTitulo2,{aLogTt[nForLog][1],aLogTt[nForLog][2],aLogTt[nForLog][3],aLogTt[nForLog][4]})
			
	Next nForLog
				
	oExcLog:Activate()
			
	cNmArqEx	:=	cDrvAt + cDirect + dtos(dDatabase) + '_' + StrTran(time(),':','_') + "_" + cArqImp + "_log.xls"
	
	oExcLog:GetXMLFile(cNmArqEx)
	
	oExcLog:DeActivate()
				
	Aviso('LOG DE IMPORTAÇÃO',"Verifique o log de importação (" + cNmArqEx + ") para analisar os status de cada beneficiário. ",{'OK'},1)
	 	
Return
