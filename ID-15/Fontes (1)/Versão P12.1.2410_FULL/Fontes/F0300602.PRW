#Include 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'FILEIO.ch'
#define CRLF CHR(13) + CHR(10)

/*
{Protheus.doc} F0300602()
Importagco coparticipagco
@Author     Rogerio Candisani
@Since      14/10/2016
@Version    P12.7 
@Project    MAN00000463701_EF_006
@Return
*/
User Function F0300602()
	
	Local aSays     := {}
	Local aButtons  := {}
	Local nOpca     := 0
	
	Private cTpForn := ''
	Private cDrvAt  := ''
	Private cDirect := ''
	Private	aRet    := {}
	Private cArqImp := ''
	Private nTipImp := '1=Saúde'
	
	Private cCamIni  := 'C:\' + space(97)
	Private cNomeLOG := 'ImportPLANO' + Space(12)
	Private cFilOld	:= cFilAnt //ID FSW 1322 - MArcos Furtado - 18/09/2018
	
	cCadastro := OemToAnsi("RHO - Co-Participação e Reembolso") 	// "RHO - Co-Participacao e Reembolso"
	
	AAdd(aSays,OemToAnsi("Esta rotina importa valores para os seguintes arquivos: ") + CRLF )   	// "Esta rotina importa valores para os seguintes arquivos: "
	AAdd(aSays,OemToAnsi("RHO - Co-Participacao e Reembolso ") + CRLF )   	// "RHO - Co-Participacao e Reembolso "
	AAdd(aSays,OemToAnsi("Conforme definido na rotina de cadastro de Layout de Importação.") )   			// "Conforme definido na rotina de cadastro de Layout de Importacao."
	AAdd(aButtons, { 5,.T.,{|| ParamImp()  } } )
	AAdd(aButtons, { 1,.T.,{|o| nOpca := 1,if(U_F0300608(nTipImp,cCamIni),If(MsgYesNo(OemToAnsi("Confirma a importação da Co-particição referente ao Plano tipo  " + Iif(cTpForn=='1','SAÚDE','ODONTOLÓGICO') + "?"),OemToAnsi("Atencao")),FechaBatch(),nOpca:=0),(.F.,nOpca:=0))}} )
	AAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons )
	If nOpca == 1
		Processa({|lEnd| F03006Proc(),"Importação de Coparticipação"})   //"Importacao de Co-particicpagco"
	EndIf
	
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
	
	Local aPergs   := {}
	Local cParaFil := Space(TamSx3('RHO_FILIAL')[1])
	Local cExcel   := '1=Sim'
	Local dData    := date()
	
	aRet	:= {}
	
	AAdd( aPergs ,{1,"Selecione Para Filial:",cParaFil,"@!",'.T.','SM0','.T.',50,.T.})
	AAdd( aPergs ,{2,'Selecione o Plano:',nTipImp,{'1=Saúde','2-Odontológico'},60,'.T.',.T.})
	AAdd( aPergs ,{6,'Arquivo a Importar:',cCamIni,'@!','.T.','.T.',100,.F.,"Arquivos .TXT|*.TXT",'C:\',GETF_LOCALHARD} )
	AAdd( aPergs ,{1,'Nome do Arquivo de LOG:',cNomeLOG,'@!','.T.',,'.T.',100,.T.})
	AAdd( aPergs ,{2,'Deseja abrir o log?',cExcel,{'1=Sim','2-Não'},60,'.T.',.T.})	
	AAdd( aPergs ,{1,"Data da Importação:",dData,"",'.T.','','.T.',50,.T.})

	ParamBox(aPergs ,"Parametros ",aRet)
	
Return
/*
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
11111111111111111111111111111111111111111111111111111111111111111111111111111
11ZDDDDDDDDDDBDDDDDDDDDDDDBDDDDDDDBDDDDDDDDDDDDDDDDDDDDDBDDDDDDBDDDDDDDDDD?11
113Funcao    3 F03006PROC 3 Autor 3 Rogerio Candisani   3 Data 3 17/10/16 311
11CDDDDDDDDDDEDDDDDDDDDDDDADDDDDDDADDDDDDDDDDDDDDDDDDDDDADDDDDDADDDDDDDDDD411
113Descricao 3 Leitura Arquivo Texto e Gravacao no Arq. Valores Variaveis.311
11CDDDDDDDDDDEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD411
113Uso       3 		                                                     311
11@DDDDDDDDDDADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDY11
11111111111111111111111111111111111111111111111111111111111111111111111111111
_____________________________________________________________________________/*/
Static Function F03006PROC()
	
	//	Local aReg:={}
	Local cArquivo:= aRet[3]
	Local lExcel	:= AllTrim(aRet[5]) == '1'
	Local dDtImp	:= aRet[6]
	Local nX:= 0
	Local cCPF:= ""

	Local dDtOcor := ""
	Local cOrigem := ""
	Local cCodFor := ""
	Local cCodigo := ""
	Local cTplLan := ""
	Local cPD := ""
	Local nVlrFun:= 0
	Local nVlrEmp:= 0
	Local dCompPg:= ""
	Local cObserv:= ""
	Local aCop:={}
	Local cAssis  := ""                                                                      	
	
	Local oFile
	Local cPathFile
	Local cPathF
	Local aRetLog	:= {}
	Local aRetTit	:= {}
	Local nCont	:= 0	
	Local cLog		:= ""
	Local lFind		:= .F.
	Local aPerAtual := {}

	Local lPerAbt := .F.
	Local cDtVerf := ""
		                   
	Private nContLin:= 0		                      
	Private ctmpMat	:=""		                                         
	Private cSRAMat := ""		
	Private aLog1 := {}
	Private aLog3 := {}
	Private aLog4 := {}
	Private aLog5 := {}
	Private aTitLog1 := {}
	Private aTitLog3 := {}
	Private aTitLog4 := {}
	Private aTitLog5 := {}
	Private aLogExcel:= {}
	//Monta o cabeçalho do CSV
	AAdd(aLogExcel,{1,"Linha;CPF;Matrícula;Situação;Mensagem"})
	oFile := FWFileReader():New(cArquivo)
	//gerar importagco dos arquivos
	//mudança de rotina para nao dar estouro de string
	//TXT := fReadStr( nHandle,nBytes )
	
	//Abertura do arquivo texto.
	//----------------------------------------------------------------------
	
	// Nairan - Função criada a pedido do Aribaldo/André Magalhães no dia 08/01/17 às 10:30
	//	ExcRegitros(dDtImp,Substring(aRet[2],1,1)) 
	
	IF Empty(cArquivo)
		ExcRegitros(dDtImp,Substring(aRet[2],1,1)) 
		Aviso( "Finalizado", "Processo de Importação Finalizado", {"Ok"} )		
	EndIf   

	cFilOld	:= aRet[1]	
	cFilAnt	:= aRet[1]
	
	If !(oFile:Open())
		If !Empty(cArquivo)
			MsgAlert("O arquivo de nome " + cArquivo + " não pode ser aberto! Verifique os parametros.", "Atenção!")
		EndIf
		Return
	EndIf
	
	//Ler os aqrquivos e seus respectivos tipos
	//	For  nX:= 1 to len(aReg)
	while (oFile:hasLine())
		//layout dos arquivos
		//TIPO 0						Data de Referjncia do Movimento
		//TIPO DE REGISTRO	001	001	NN	01	-	0
		//DATA POSTERIOR COMPET	002	007	NN	06	00	Mmaaaa
		//DATA COMPETJNCIA	008	013	NN	06	00	Mmaaaa
		//TIPO MOVIMENTO	014	014	AN	01	-	S (fixo)  // D (fixo)  /; D=Dental/ S=Saude
		//FILLER	015	300	AN	286	-	Brancos
		//cAssis    := subst(aReg[x],14,1)
		cReg:= oFile:GetLine()
		cReg:= StrTran(cReg, "ï", "") //Thais Paiva - 10056335
		cReg:= StrTran(cReg, "»", "") //Thais Paiva - 10056335
		cReg:= StrTran(cReg, "¿", "") //Thais Paiva - 10056335
		cReg:= StrTran(cReg, "Âº", " ") //Thais Paiva - 10056335
		nContLin++
		If subst(cReg,1,1) == "0"
			dCompPg:= subst(cReg,8,6)
			cAssis := subst(cReg,14,1)
			
			// Data de ocorrencia deve ser o multimko dia do mes. para quem utilizar a coparticipação,
			// pois só deve apresentar um unico registro para o titular e um unico registro para
			// o dependente
			
			/*Nairan - Alterado dia 08/01/17 a pedido do Aribaldo de acordo com levantamento realizado com o Cliente
			If subst(cReg,8,2)<> "02"
				dDtOcor:= "30/" + subst(cReg,8,2) + "/" + subst(cReg,10,4)
			Else
				dDtOcor:= "28/" + subst(cReg,8,2) + "/" + subst(cReg,10,4)
			Endif
			*/
			
			dDtOcor := DTOC(dDtImp)
			cDtVerf := SubStr(dDtOcor,4,2)+SubStr(dDtOcor,7,4)
			//Bruno - validação criada a pedido do Aribaldo/Selma no dia 22/09/17 às 10:30
			If cDtVerf == dCompPg
				lPerAbt := fGetPerAtual( @aPerAtual, aRet[1], "00001", "PLA" )
				If lPerAbt
					If aPerAtual[1][4]+aPerAtual[1][5] == dCompPg
						// Nairan - Função criada a pedido do Aribaldo/André Magalhães no dia 08/01/17 às 10:30
						ExcRegitros(dDtImp,Substring(aRet[2],1,1))
					Else
						MsgAlert("Não será importado o arquivo: O periodo em aberto não é igual a competencia informada no arquivo.", "Atenção!")
						Return					
					EndIf
				Else
					MsgAlert("Não será importado o arquivo: Não existe periodo em aberto para a filial " + aRet[1] + " e Roteiro = PLA.", "Atenção!")
					Return
				EndIf			
			Else			
				MsgAlert("Não será importado o arquivo: Data da importação digitada é diferente da competencia informada no arquivo.", "Atenção!")
				Return
			EndIf
			
		Endif
		//TIPO 1						Informagues do Titular
		//TIPO DE REGISTRO	001	001	NN	01	-	1
		//EMPRESA	002	041	AN	40	-	Nome da Empresa
		//CGC	042	059	AN	18	-	CGC da Empresa  - 99.999.999/9999-99
		//MOEDA	060	069	AN	10	-	REAL
		//TITULAR	070	109	AN	40	-	Nome do Titular
		//CPF	110	123	AN	14	-	CPF do Titular  - 999.999.999-99
		//COMPONENTE	124	129	AN	06	-	5* a 10* Posigco do Cargo/Ocupagco
		//MATRMCULA	130	149	AN	20	-	Cartco do Titular
		//DATA INMCIO	150	159	AN	10	-	dd/mm/aaaa
		//DATA FIM	160	169	AN	10	-	dd/mm/aaaa
		//DATA EMISSCO	170	179	AN	10	-	dd/mm/aaaa
		//MATRICULA ESPECIAL	180	191	AN	12	-	ID da EMPRESA
		//SUBFATURA	192	194	NN	03	-	Csdigo da subfatura
		//FILLER	195	300	AN	106	-	Brancos
		If subst(cReg,1,1) == "1"
			lFind := .F.
			cCPF:= subst(cReg,110,14)
			cCPF:=strtran(cCPF,'.','')
			cCPF:=strtran(cCPF,'-','')
			//verificar se existe registro no Protheus
			ctmpMat:=GetNextAlias()
			//_Fil := aRet[1]
			BeginSql Alias ctmpMat
				SELECT RA_FILIAL, RA_MAT, RA_SITFOLH, RA_AFASFGT
				FROM %table:SRA% SRA
				WHERE RA_CIC = %Exp:cCPF%
				AND RA_FILIAL = %Exp:aRet[1]%
				AND SRA.%NotDel%
			EndSql
			
			//xxx :=  GetLastQuery() 
			
			DbSelectArea(ctmpMat)
			While !EOF()
				lFind := .T.
				If (ctmpMat)->RA_SITFOLH != "D"
					cSRAMat := (ctmpMat)->RA_MAT
					exit
				else
					cSRAMat := (ctmpMat)->RA_MAT
					If AllTrim((ctmpMat)->RA_AFASFGT) == "N1" .Or. AllTrim((ctmpMat)->RA_AFASFGT) == "N2"
						fIncLog({"03","Linha: " + cValToChar((nContLin)) + " / CPF " + Alltrim(cCPF) + " / Matricula " + Alltrim((ctmpMat)->RA_MAT) + " Transferido."})
						AAdd(aLogExcel,{2,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim((ctmpMat)->RA_MAT) + ";Não;Transferido"})
					Else
						fIncLog({"03","Linha: " + cValToChar((nContLin)) + " / CPF " + Alltrim(cCPF) + " / Matricula " + Alltrim((ctmpMat)->RA_MAT) + " Demitido."})					
						AAdd(aLogExcel,{2,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim((ctmpMat)->RA_MAT) + ";Não;Demitido"})
					Endif
					cSRAMat := ""
				EndIf
				(ctmpMat)->(DbSkip())
			Enddo
			(ctmpMat)->(DbCloseArea())
			If !lFind
				cSRAMat := ""
				fIncLog({"01","Linha: " + cValToChar(nContLin) + " / CPF " + Alltrim(cCPF) + " nao encontrado no sistema/filial."})
				AAdd(aLogExcel,{2,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + " " + ";Não;Não encontrado no sistema/filial"})
				Loop
			Endif
		Endif
		
		If Empty(cSRAMat)
			Loop
		EndIf
		
		//TIPO 2						Informagues sobre Utilizagues
		//TIPO DE REGISTRO	001	001	NN	01	-	2
		//DATA UTILIZAGCO	002	011	AN	10	-	dd/mm/aaaa
		//CSDIGO USUARIO	012	013	NN	02	-	Csdigo do Paciente
		//NOME USUARIO	014	053	AN	40	-	Nome do Paciente
		//NOME PRESTADOR	054	123	AN	70	-	Nome do Prestador de Servigo
		//TIPO MEIO UTILIZAGCO	124	125	AN	02	-	SR (Reembolso) / RR (Rede)
		//CGC/CPF PRESTADOR	126	143	AN	18	-	CGC/CPF do Prestador de Servigo
		//TIPO DE SERVIGO	144	168	AN	25	-	Nome do Procedimento
		//NZMERO DA SR	169	175	NN	07	-	Zeros
		//VALOR ORIGINAL	176	187	AN	12	-	9.999.999,99
		//Valor Cobrado (Extrato)
		//VALOR REEMBOLSO	188	199	NA	12	-	9.999.999,99
		//Valor Tabela B.S. (Extrato)
		//VALOR PARTICIPAGCO	200	211	NA	12	-	9.999.999,99
		//Valor Participagco (Extrato)
		//VALOR CO-PARTICIPAGCO	212	223	NA	12	-	9.999.999,99
		//Valor Excedente (Extrato)
		//DOCUMENTO	224	235	NN	12	-	Nzmero do Documento/Senha
		//PROCEDIMENTO	236	243	NN	08	-	Csdigo do Procedimento
		//SEQ. PROCEDIMENTO	244	250	NA	07	-	Sequencial Procedimento
		//CERTIFICADO	251	257	NN	07	-	Csdigo do Certificado do Segurado
		//MATRICULA ESPECIAL	258	269	AN	12	-	Matrmcula Especial do Segurado
		//SUBFATURA	270	272	NN	03	-	Csdigo da subfatura
		//FILLER	273	300	NA	28	-	Brancos
		
		If subst(cReg,1,1) == "2"
			cCodigo := subst(cReg,12,2)
			If cAssis = "S"
				cPD:= fTabela("U002",1,6)   //Posicione("RHK",1,xFilial("RHK") + cSRAMat,"RHK_PD")
			Else
				cPD:= fTabela("U002",1,7)
			Endif
			If cCodigo != "00"
				cCodigo := RetDep(cSRAMat,cCodigo)
			EndIf
			If Empty(cCodigo)
				fIncLog({"02","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Carteirinha " + subst(cReg,12,2) + " nao encontrada no sistema."})
				AAdd(aLogExcel,{2,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(cSRAMat) + ";Não; Carteirinha " + subst(cReg,12,2) + " nao encontrada no sistema."})
				Loop
			Endif
			cCodFor:= Posicione("RHK",1,aRet[1] + cSRAMat,"RHK_CODFOR")
			nVlrFun:= subst(cReg,200,12)
			nVlrEmp:= 0
			cObs:= subst(cReg,144,25)
			cOrigem:= IIF(cCodigo == "00","1","2")
			cTpLan:= "1" // sempre sera co=participagco
		Endif
		
		//soma os valores por matricula e beneficiario
		If subst(cReg,1,1) == "2"
			//	dDtOcor:= subst(aReg[x],2,8)
			nVlrFun:=	strtran(nVlrFun,",","")
			nVlrFun:=	strtran(nVlrFun,".","")
			nVlrFun:= Val(nVlrFun)
			nVlrFun :=  nVlrFun / 100 // 2 casas decimais
			IF nVlrFun <> 0
				//verificar se ja existe este beneficiario e plano e somar
				//SetUniqueLine( { 'RHO_DTOCOR', 'RHO_TPFORN', 'RHO_CODFOR', 'RHO_ORIGEM','RHO_CODIGO','RHO_PD','RHO_COMPPG' } )
				If ValType(dDtOcor) == "C"
					If ValType(cTpForn) == "C"
						If ValType(cCodFor) == "C"
							If ValType(cOrigem) == "C"
								If ValType(cCodigo) == "C"
									If ValType(cPD) == "C"
										If ValType(dCompPg) == "C"
											If RHO_LinhaOK(cOrigem,cTpForn,cCodigo,cCodFor,dDtOcor,nContLin,cCPF,cSRAMat)
												//dDtOcor + cTpForn + cCodFor + cOrigem + cCodigo + cPD + dCompPg
												nPosX := AScan( aCop, { |nX| nX[1] + nX[3] + nX[5] + nX[6] + nX[4] + nX[7] + nX[9] + nX[2] == cSRAMat + dDtOcor + cTpForn + cCodFor + cOrigem + cCodigo + cPD + dCompPg } ) // compara o setUniqueLine
												If nPosX = 0 // Adiciona os itens nco encontrados no primeiro array
													AAdd(aCop,{	cSRAMat  ,; //1
													dCompPg  ,; //2
													dDtOcor  ,; //3
													cOrigem  ,; //4
													cTpForn  ,; //5
													cCodFor  ,; //6
													cCodigo  ,; //7
													cTpLan   ,; //8
													cPD      ,; //9
													nVlrFun  ,; //10
													cObs     }) //11
												Else
													aCop[nPosX][10]:= nVlrFun + aCop[nPosX][10]
												Endif     
											Else  
											//	Help( ,, 'HELP',, "Dados incorretos. Verifique os arquivo de Log", 1, 0)  
											//	oFile:Close()
										   //		Return
												
											EndIf
										ELse
											oFile:Close()
											fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Dado incorreto na data de competência."})
											AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(ctmpMat) + ";Não; Dado incorreto na data de competência"})
											Help( ,, 'HELP',, "Dado incorreto na data de competência verifique antes de prosseguir", 1, 0)
											Return
										EndIf
									Else
										oFile:Close()
										fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Dado incorreto na informação da verba."})
										AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(ctmpMat) + ";Não; Dado incorreto na informação da verba"})
										Help( ,, 'HELP',, "Dado incorreto na informação da verba verifique antes de prosseguir", 1, 0)
										Return
									EndIf
								Else
									oFile:Close()
									fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Dado da Sequência Depen/Agregado invalido."})
									AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(ctmpMat) + ";Não; Dado da Sequência Depen/Agregado invalido"})
									Help( ,, 'HELP',, "Dado da Sequência Depen/Agregado inválido verifique antes de prosseguir", 1, 0)
									Return
								EndIf
							Else
								oFile:Close()
								fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Codigo da origem do arquivo inválido."})
								AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(ctmpMat) + ";Não; Codigo da origem do arquivo inválido"})
								Help( ,, 'HELP',, "Código da origem do arquivo inválido verifique antes de prosseguir", 1, 0)
								Return
							EndIf
						Else
							oFile:Close()
							fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Codigo do fornecedor invalido."})
							AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(ctmpMat) + ";Não; Codigo do fornecedor invalido."})
							Help( ,, 'HELP',, "Código do fornecedor inválido verifique antes de prosseguir", 1, 0)
							Return
						EndIf
					Else
						oFile:Close()
						fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Tipo do fornecedor invalido."})
						AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(ctmpMat) + ";Não; Tipo do fornecedor invalido."})
						Help( ,, 'HELP',, "Tipo do fornecedor inválido verifique antes de prosseguir", 1, 0)
						Return
					EndIf
				Else
					oFile:Close()
					fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Data da Ocorrência invalido."})
					AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(ctmpMat) + ";Não; Data da Ocorrência invalido."})
					Help( ,, 'HELP',, "Data da Ocorrência inválido verifique antes de prosseguir", 1, 0)
					Return
				EndIf
			Endif
		Endif
	EndDO
	oFile:Close()
	//inclui os registros de co-participagco
	If Len(aCop) > 0
		InclCop(aCop)
	EndIf
	
	//Criar o arquivo de Log
	/*
	fMakeLog(	aLogFile 	,;	//Array que contem os Detalhes de Ocorrencia de Log
				aLogTitle	,;	//Array que contem os Titulos de Acordo com as Ocorrencias
				cPerg		,;	//Pergunte a Ser Listado
				lShowLog	,;	//Se Havera "Display" de Tela
				cLogName	,;	//Nome Alternativo do Log
				cTitulo		,;	//Titulo Alternativo do Log
				cTamanho	,;	//Tamanho Vertical do Relatorio de Log ("P","M","G")
				cLandPort	,;	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
				aRet		,;	//Array com a Mesma Estrutura do aReturn
				lAddOldLog	 ;	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
			  )
	*/
//?	fMakeLog(aLog1,aTitLog1,/*cPerg*/,.F.,cNomeLOG,/*cTitulo*/,/*cTamanho*/,/*cLandPort*/,/*aRet*/,.F.)
	
	If !Empty(aLog1)
		cLog := ""
		AAdd(aRetTit,aTitLog1[1])
		For nCont := 1 To Len(aLog1)
			cLog += aLog1[nCont][1] + CRLF
		Next
		cLog += "Total de Arquivos: " + cValtoChar(Len(aLog1))
		AAdd(aRetLog,{cLog})
	EndIf
	
	If !Empty(aLog3)
		cLog := ""
		AAdd(aRetTit,aTitLog3[1])
		For nCont := 1 To Len(aLog3)
			cLog += aLog3[nCont][1] + CRLF
		Next
		cLog += "Total de Arquivos: " + cValtoChar(Len(aLog3))
		AAdd(aRetLog,{cLog})
	EndIf

	If !Empty(aLog4)
		cLog := ""
		AAdd(aRetTit,aTitLog4[1])	
		For nCont := 1 To Len(aLog4)
			cLog += aLog4[nCont][1] + CRLF
		Next
		cLog += "Total de Arquivos: " + cValtoChar(Len(aLog4))
		AAdd(aRetLog,{cLog})
	EndIf
	
	If !Empty(aLog5)
		cLog := ""
		AAdd(aRetTit,aTitLog5[1])
		For nCont := 1 To Len(aLog5)
			cLog += aLog5[nCont][1] + CRLF
		Next
		cLog += "Total de Arquivos: " + cValtoChar(Len(aLog5))
		AAdd(aRetLog,{cLog})
	EndIf
	
//	cPathFile := fMakeLog(aRetLog,aRetTit,/*cPerg*/,.T.,cNomeLOG,,"M","P",/*aRet*/,.F.)
	If lExcel 
		Help( ,, 'HELP',, "Dados incorretos. Verifique os arquivo de Log", 1, 0)	
		ExpExel(aLogExcel)
	EndIf
//	If !Empty(cPathFile)
//		cPathF := cPathFile
//	EndIf
//	cPathFile := fMakeLog(aLog3,aTitLog3,/*cPerg*/,.T.,cNomeLOG,/*cTitulo*/,/*cTamanho*/,/*cLandPort*/,/*aRet*/,.T.)
//	If !Empty(cPathFile)
//		cPathF := cPathFile
//	EndIf
//	cPathFile := fMakeLog(aLog4,aTitLog4,/*cPerg*/,.T.,cNomeLOG,/*cTitulo*/,/*cTamanho*/,/*cLandPort*/,/*aRet*/,.T.)
//	If !Empty(cPathFile)
//		cPathF := cPathFile
//	EndIf
//	If !Empty(cPathF)
////		Alert("Relatorio de LOG gerado em: " + cPathF, OemToAnsi("Atenção!"))
//	EndIf
Return

//------------------------------------------------------------
//inclui os registros de coparticipagco
//------------------------------------------------------------
Static Function InclCop(aCop)
	
	Local ny:= 0
	//Local nz:= 0
	Local cMat:=""
	//Indice Matricula + Ocorrencia + Tipo + Cod. Forn + Origem + Verba
	//Gravar usando modelo MVC (commit do modelo)
	//"GPEA003_MSRA" - matricula do funcionario
	//"GPEA003_MRHO" - co-participagco
	//posiciona no modelo do SRA
	For ny:= 1 to len(aCop)
		If Empty(aCop[ny][1])
			Loop
		Endif
		DbSelectArea("SRA")
		SRA->(DbSetOrder(1))
		If SRA->(DbSeek(aRet[1] + aCop[ny][1]))
			cMat := aCop[ny][1]
			//Abrir modelo
			oMdlGPEA003	:= FWLoadModel( "GPEA003" )	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
			IF aCop[ny][7]="00"
				cCodigo := "  "
			else
				cCodigo:= aCop[ny][7]
			Endif	
			dComPg:= subst(aCop[ny][2],3,4) + subst(aCop[ny][2],1,2)
			DbSelectArea("RHO")
			RHO->(DbSetOrder(3))
			oMdlGPEA003:SetOperation(MODEL_OPERATION_UPDATE) 
			oMdlGPEA003:Activate()
			oMdlGPEASRA:= oMdlGPEA003:GetModel("GPEA003_MSRA")
			oMdlGPEARHO:= oMdlGPEA003:GetModel("GPEA003_MRHO")
			
			//definir os campos de gravagco
			//				oMdlGPEARHO:AddLine() //campos para inclusco da linha
			//dDtOcor:= ctod(
	//		If nY > 1//oMdlGPEA003:GetOperation() == MODEL_OPERATION_INSERT
	//			oMdlGPEARHO:AddLine() //campos para inclusco da linha
			//	oMdlGPEASRA:SetValue("RHO_MAT" ,aCop[ny][1]  )
	//		EndIf
			If RHO->(!DbSeek(aRet[1] + aCop[ny][1] + DTOS(CTOD(aCop[ny][3])) + aCop[ny][5] + aCop[ny][6] + aCop[ny][4] + cCodigo + aCop[ny][9] + dComPg))// .And. !Empty(cCodigo)
				oMdlGPEARHO:AddLine()//oMdlGPEA003:SetOperation(MODEL_OPERATION_UPDATE) //operagco de langamento
			EndIf
			oMdlGPEARHO:SetValue( "RHO_DTOCOR", ctod(aCop[ny][3]) ) //data da ocorrencia
			oMdlGPEARHO:SetValue( "RHO_ORIGEM", aCop[ny][4] ) // 1-Titular,2-Dependente,3-Agregado
			oMdlGPEARHO:SetValue( "RHO_TPFORN", aCop[ny][5] ) // 1-Medico,2-Odontologico
			oMdlGPEARHO:SetValue( "RHO_CODFOR", aCop[ny][6] ) // codigo do fornecedor
			If aCop[ny][7] <> "00"
				oMdlGPEARHO:SetValue( "RHO_CODIGO", aCop[ny][7] ) // 2-  dependente, 3- agregado
			Endif
			oMdlGPEARHO:SetValue( "RHO_TPLAN" , aCop[ny][8] ) // 1-co-participagco, 2-Reembolso
			oMdlGPEARHO:SetValue( "RHO_PD" , aCop[ny][9] ) // codigo da verba
			oMdlGPEARHO:LoadValue( "RHO_VLRFUN" , aCop[ny][10] ) //R$ funcionario
			oMdlGPEARHO:LoadValue( "RHO_COMPPG" , dComPg ) //data da competencia
			oMdlGPEARHO:SetValue( "RHO_OBSERV" , aCop[ny][11] ) // obs
			If oMdlGPEA003:VldData()
				oMdlGPEA003:CommitData()
				fIncLog({"05","CPF:" + SRA->RA_CIC + " Matricula: " + Alltrim(aCop[ny][01] ) + "Origem: " + aCop[ny][4] + " Código: " + aCop[ny][7] + "-> Dados OK."})
				AAdd(aLogExcel,{5," -  ;" + Alltrim(SRA->RA_CIC) + ";" + Alltrim(aCop[ny][01] ) + ";Sim; Dados Ok."})
			Else
				aErro   := oMdlGPEA003:GetErrorMessage()
				fIncLog({"04","CPF:" + SRA->RA_CIC + " Matricula: " + Alltrim(aCop[ny][01] ) + "Origem: " + aCop[ny][4] + " Código: " + aCop[ny][7] + " -> Erro na Rotina automática. "+ AllTrim(aErro[6])})
			   	AAdd(aLogExcel,{4," -  ;" + Alltrim(SRA->RA_CIC) + ";" + Alltrim(aCop[ny][01] ) + ";Não; Erro na Rotina Automática. "+ AllTrim(aErro[6])})
			//	Help( ,, 'Help',, aErro[MODEL_MSGERR_MESSAGE], 1, 0 )
			Endif
		EndIf
	Next ny
	Aviso( "Finalizado", "Processo de Importação Finalizado", {"Ok"} )
Return

/////////////////////////////////////////
//Busca o código correto do dependente //
/////////////////////////////////////////
Static Function RetDep(cMatricula, cCodigo)
Local cQuery 		:= ""
Local cAliasTrb	:= GetNextAlias()
Local cRet			:= ""

cQuery := " SELECT RHL_CODIGO FROM " + RetSqlName("RHL") + " "
cQuery += " WHERE "
cQuery += " RHL_FILIAL = '" + aRet[1] + "' "
cQuery += " AND RHL_MAT = '" + cMatricula + "' "
cQuery += " AND RHL_TPFORN = '" + Substring(aRet[2],1,1) + "' "
cQuery += " AND SUBSTR(TRIM(RHL_NCARVD),-2,2) = '" + cCodigo + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)

If (cAliasTrb)->(!EOF())
	cRet := (cAliasTrb)->RHL_CODIGO
EndIf

(cAliasTrb)->(DbCloseArea())
Return cRet
///////////////////////////////////////////////
// Inclui um novo registro no arquivo de LOG //
///////////////////////////////////////////////
Static Function fIncLog(aReg)
/*
01 - CPF nao encontrado
02 - Codigo Dependente nao encontrado
03 - Funcionarios Demitivos
04 - Dados Invalidos
05 - Importacao OK
*/
If aReg[1] $ "01/02"
	If AScan(aTitLog1, { |x| x == "Erro no Cadastrou ou Rotina Automática" }) = 0
		AAdd(aTitLog1, "Erro no Cadastrou ou Execauto ou Rotina Automática")
	EndIf
	AAdd(aLog1,{"   " + aReg[2]})

ElseIf aReg[1] $ "03"
	If AScan(aTitLog3, { |x| x == "Funcionarios Demitidos" }) = 0
		AAdd(aTitLog3, "Funcionarios Demitidos")
	EndIf	
	AAdd(aLog3,{"   " + aReg[2]})

ElseIf aReg[1] $ "04"
	If AScan(aTitLog4, { |x| x == "Dados Invalidos" }) = 0
		AAdd(aTitLog4, "Dados Invalidos")
	EndIf	
	AAdd(aLog4,{"   " + aReg[2]})

ElseIf aReg[1] $ "05"
	If AScan(aTitLog5, { |x| x == "Importacao OK" }) = 0
		AAdd(aTitLog5, "Importacao OK")
	EndIf	
	AAdd(aLog5,{"   " + aReg[2]})

EndIf	
	
Return


///////////////////////
//Exporta para Excel	//
///////////////////////
Static Function ExpExel(aLogExcel)
Local cArqLoc		:= GetTempPath()
Local cNomeArq	:= DTOS(date()) + StrTran(Time(),":","") + '.CSV'
Local nHandle 	:= 0
Local cTxt			:= ""
Local nX			:= 0

If Len(aLogExcel)>1
	nHandle := FCREATE(cArqLoc + cNomeArq)
	If nHandle < 0
		Alert("Erro na geração do Arquivo")
	Else
		aSort(aLogExcel,,,{|x,y| x[01]<y[01]})
		For nX := 1 To Len(aLogExcel)
			cTxt := aLogExcel[nX][02] + ';' + CRLF
			FWrite(nHandle,cTxt)
		Next
		FClose(nHandle)
		shellExecute("Open", cArqLoc + cNomeArq,"Null" , "C:\", 1 )
	EndIf
EndIf

Return

Static Function ExcRegitros(dData,cTipo)
Local cQuery 		:= ""
Local cAliasTrb	:= GetNextAlias()
Local aAreaRHO	:= RHO ->(GetArea())

cQuery := " SELECT R_E_C_N_O_  RecRHO FROM " + RetSqlName("RHO") + " "
cQuery += " WHERE "
cQuery += " RHO_FILIAL = '" + aRet[1] + "' "
cQuery += " AND RHO_DTOCOR = '" + DTOS(dData) + "' "
cQuery += " AND RHO_TPFORN = '" + Substring(aRet[2],1,1) + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)

While (cAliasTrb)->(!EOF())
	If RHO->(DbGoTo((cAliasTrb)->RecRHO))
		RecLock("RHO",.F.)
		RHO->(dBDelete())
		RHO->(MsUnLock())
	EndIf
	(cAliasTrb)->(DbSkip())
EndDo

(cAliasTrb)->(DbCloseArea())
RestArea(aAreaRHO)
Return 


/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ RHO_LinhaOK	³Autor³  Mauricio Takakura³ Data ³16/10/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Validacao da Linha OK                                       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA003                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function RHO_LinhaOK(cOrigem,cTpForn,cCodigo,cCodFor,dDtOcor,nContLin,cCPF,cSRAMat)
	Local aArea		:= GetArea()
	
	Local cPerIni	:= ""
	Local cPerFim	:= ""
	Local cCodigo	:= "" 
	Local cDtOcor	:= ""
	Local cSvAlias:= ""
	
	Local lRet 		:= .T.
	Local lFound 	:= .F.
	
/*	cOrigem	:= oStruct:GetValue( "RHO_ORIGEM" )
	cTpForn	:= oStruct:GetValue( "RHO_TPFORN" )
	cCodigo	:= oStruct:GetValue( "RHO_CODIGO" )
	cCodFor	:= oStruct:GetValue( "RHO_CODFOR" )*/
	cDtOcor	:= CTOD(dDtOcor)
	cDtOcor	:= Substr(DTOS( cDtocor ), 1, 6 )

//	If Alltrim(cSRAMat) = '87390' // 747/804/861
//		Alert("87390")
//	Endif
	
	If cOrigem == "1" 
		DbSelectArea( "RHK" )      // RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR                                                                                                                        
		DbSetOrder( RetOrder( "RHK", "RHK_FILIAL+RHK_MAT+RHK_TPFORN+RHK_CODFOR" ) )		 // aqui
//		DbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cTpForn + cCodFor, .F. )
		DbSeek( aRet[1] + cSRAMat + cTpForn + cCodFor, .F. )  // Novo
		
		
		If Eof() // Não achou o registro na RHK então é necessário procurar na RHN (Histórico) 
			DbSelectArea( "RHN" )
			DbSetOrder( 1 )
//			DbSeek( SRA->RA_FILIAL + SRA->RA_MAT, .F. )
			DbSeek( aRet[1] + cSRAMat, .F. ) // Novo

			//Ao realizar o fechamento Mensal o sistema exclui da RHK o plano cujo periodo tenha expirado e o coloca na RHN
			//Se encontrar a Filial e a Matricula na RHN irá procurar o plano correto, que tenha sido Excluido e o tipo de alteração for Vigência
			While !Eof() .AND.;
			RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) != ;
			aRet[1]  + cSRAMat + "2" + cOrigem + "04" + cTpForn + cCodFor 
//			SRA->RA_FILIAL  + SRA->RA_MAT + "2" + cOrigem + "04" + cTpForn + cCodFor 
				DbSkip()
			EndDo 
			If Eof() //Se não encontrar tanto na RHK quanto na RHN irá informar a mensagem abaixo // Merda
				fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Plano não cadastrado para o usuario!"})
				AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(cSRAMat) + ";Não; Plano não cadastrado para o usuario!"})
				//Help(,,'HELP',,OemToAnsi("Plano não cadastrado para o usuario!"),1,0)	//"Plano não cadastrado para o usuario!"
				lRet := .F.
			EndIf
		EndIf
		
		If !Eof() //Se encontrou ou na RHK ou na RHN irá verificar se a data de Ocorrencia está de acordo com o periodo do plano
			cSvAlias := Alias() //Se for RHK significa que encontrou nela e não teve a necessidade de procurar na RHN
			lFound := .F.
			//Irá realizar a pesquisa de acordo com a tabela corrente.
			While !Eof() .and. (If(cSvAlias == "RHK",(RHK->(RHK_FILIAL + RHK_MAT + RHK_TPFORN + RHK_CODFOR ) == aRet[1] + SRA->RA_MAT + cTpForn + cCodFor),;
				(RHN->(RHN_FILIAL + RHN_MAT + RHN_TPFORN + RHN_CODFOR) == aRet[1]  + cSRAMat + cTpForn + cCodFor))		)
//				(RHN->(RHN_FILIAL + RHN_MAT + RHN_TPFORN + RHN_CODFOR) == SRA->RA_FILIAL  + SRA->RA_MAT + cTpForn + cCodFor))		)

				If cSvAlias == "RHK"
					cPerIni := Substr(RHK->RHK_PERINI,3,4) + Substr( RHK->RHK_PERINI,1,2)
					cPerFim	:= Substr(RHK->RHK_PERFIM,3,4) + Substr( RHK->RHK_PERFIM,1,2)
				Else
					If RHN->(RHN_OPERAC + RHN_ORIGEM + RHN_TPALT) == "2" + cOrigem + "04" 
						cPerIni := Substr(RHN->RHN_PERINI,3,4) + Substr( RHN->RHN_PERINI,1,2)
						cPerFim	:= Substr(RHN->RHN_PERFIM,3,4) + Substr( RHN->RHN_PERFIM,1,2)
					Else
						( cSvAlias )->( DbSkip() )	
						Loop
					EndIf	
				EndIf
				//If (cDtOcor >= cPerIni .And. (Empty(cPerFim) .Or. cDtOcor <= cPerFim)) Thais Paiva - 10056335
				If (cDtOcor >= cPerIni .And. (Empty(Alltrim(cPerFim)) .Or. cDtOcor <= cPerFim))
					lFound := .T.
					Exit
				EndIf
				( cSvAlias )->( DbSkip() )	
			EndDo
			
			//If (cDtOcor >= cPerIni .And. (Empty(cPerFim) .Or. cDtOcor <= cPerFim)) Thais Paiva - 10056335
			If (cDtOcor >= cPerIni .And. (Empty(Alltrim(cPerFim)) .Or. cDtOcor <= cPerFim))
				lFound := .T.
			EndIf
			
			If !lFound 
//				If IsBlind()                                                                                                         
					fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Data da Ocorrência esta fora do Período de validade do Plano Ativo!"})
					AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(cSRAMat) + ";Não; Data da Ocorrência esta fora do Período de validade do Plano Ativo!"})
				//	Help(,,'HELP',,OemToAnsi("Data da Ocorrência esta fora do Período de validade do Plano Ativo!"),1,0)	//"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
/*				Else
					MsgInfo(OemToAnsi(STR0010)) //"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
				EndIf*/
			EndIf		
		EndIf
	ElseIf cOrigem == "2" // Dependente
		DbSelectArea( "RHL" ) // Busca RHL
		DbSetOrder( RetOrdem( "RHL", "RHL_FILIAL+RHL_MAT+RHL_TPFORN+RHL_CODFOR+RHL_CODIGO" ) )
		DbSeek( aRet[1] + cSRAMat + cTpForn + cCodFor + cCodigo, .F. )
		If Eof() // Não achou o registro na RHL então é necessário procurar na RHN (Histórico)
			DbSelectArea( "RHN" )
			DbSetOrder( 1 )
			DbSeek( aRet[1] + cSRAMat, .F. )
			//Ao realizar o fechamento Mensal o sistema exclui da RHL o plano cujo periodo tenha expirado e o coloca na RHN
			//Se encontrar a Filial e a Matricula na RHN irá procurar o plano correto, que tenha sido Excluido e o tipo de alteração for Vigência
			While !Eof() .AND.;
			RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) != ;
			aRet[1]  + cSRAMat + "2" + cOrigem + "04" + cTpForn + cCodFor 
				DbSkip()
			EndDo
			If Eof() //Se não encontrar tanto na RHL quanto na RHN irá informar a mensagem abaixo  
				fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Plano não cadastrado para o usuario!"})
				AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(cSRAMat) + ";Não; Plano não cadastrado para o usuario!"})
			   //	Help(,,'HELP',,OemToAnsi("Plano não cadastrado para o usuario!"),1,0)	//"Plano não cadastrado para o usuario!"
				lRet := .F.
			EndIf
		EndIf

		If !Eof() //Se encontrou ou na RHL ou na RHN irá verificar se a data de Ocorrencia está de acordo com o periodo do plano
			cSvAlias := Alias() //Se for RHL significa que encontrou nela e não teve a necessidade de procurar na RHN
			lFound := .F.
			//Irá realizar a pesquisa de acordo com a tabela corrente.
			While !Eof() .and. (If(cSvAlias == "RHL",(RHL->(RHL_FILIAL + RHL_MAT + RHL_TPFORN + RHL_CODFOR ) == aRet[1] + cSRAMat + cTpForn + cCodFor),;
				(RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) == aRet[1]  + cSRAMat + "2" + cOrigem + "04" + cTpForn + cCodFor)) )
				If cSvAlias == "RHL"
					cPerIni := Substr(RHL->RHL_PERINI,3,4) + Substr( RHL->RHL_PERINI,1,2)
					cPerFim	:= Substr(RHL->RHL_PERFIM,3,4) + Substr( RHL->RHL_PERFIM,1,2)
				Else
					If RHN->(RHN_OPERAC + RHN_ORIGEM + RHN_TPALT) == "2" + cOrigem + "04" 
						cPerIni := Substr(RHN->RHN_PERINI,3,4) + Substr( RHN->RHN_PERINI,1,2)
						cPerFim	:= Substr(RHN->RHN_PERFIM,3,4) + Substr( RHN->RHN_PERFIM,1,2)
					Else
						( cSvAlias )->( DbSkip() )	
						Loop
					EndIf	
				EndIf
				//If (cDtOcor >= cPerIni .And. (Empty(cPerFim) .Or. cDtOcor <= cPerFim)) Thais Paiva - 10056335
				If (cDtOcor >= cPerIni .And. (Empty(Alltrim(cPerFim)) .Or. cDtOcor <= cPerFim))
					lFound := .T.
					Exit
				EndIf
				( cSvAlias )->( DbSkip() )	
			EndDo
			If !lFound 
//				If IsBlind() 
					fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Data da Ocorrência esta fora do Período de validade do Plano Ativo!"})
					AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(cSRAMat) + ";Não; Data da Ocorrência esta fora do Período de validade do Plano Ativo!"})
				//	Help(,,'HELP',,OemToAnsi("Data da Ocorrência esta fora do Período de validade do Plano Ativo!"),1,0)	//"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
/*				Else
					MsgInfo(OemToAnsi(STR0010)) //"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
				EndIf   */
			EndIf		
		EndIf
	ElseIf cOrigem == "3"
		DbSelectArea( "RHM" )
		DbSetOrder( RetOrdem( "RHM", "RHM_FILIAL+RHM_MAT+RHM_TPFORN+RHM_CODFOR+RHM_CODIGO" ) )
		DbSeek( aRet[1] + cSRAMat + cTpForn + cCodFor + cCodigo, .F. )
		If Eof() // Não achou o registro na RHM então é necessário procurar na RHN (Histórico)
			DbSelectArea( "RHN" )
			DbSetOrder( 1 )
			DbSeek( aRet[1] + cSRAMat, .F. )
			//Ao realizar o fechamento Mensal o sistema exclui da RHM o plano cujo periodo tenha expirado e o coloca na RHN
			//Se encontrar a Filial e a Matricula na RHN irá procurar o plano correto, que tenha sido Excluido e o tipo de alteração for Vigência
			While !Eof() .AND.;
			RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) != ;
			aRet[1]  + cSRAMat + "2" + cOrigem + "04" + cTpForn + cCodFor 
				DbSkip()
			EndDo
			If Eof() //Se não encontrar tanto na RHM quanto na RHN irá informar a mensagem abaixo
				fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Plano não cadastrado para o usuario!"})
				AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(cSRAMat) + ";Não; Plano não cadastrado para o usuario!"})
			 //	Help(,,'HELP',,OemToAnsi("Plano não cadastrado para o usuario!"),1,0)	//"Plano não cadastrado para o usuario!"
				lRet := .F.
			EndIf
		EndIf
		If !Eof() //Se encontrou ou na RHM ou na RHN irá verificar se a data de Ocorrencia está de acordo com o periodo do plano
			cSvAlias := Alias() //Se for RHM significa que encontrou nela e não teve a necessidade de procurar na RHN
			lFound := .F.
			//Irá realizar a pesquisa de acordo com a tabela corrente.
			While !Eof() .and. (If(cSvAlias == "RHM",(RHM->(RHM_FILIAL + RHM_MAT + RHM_TPFORN + RHM_CODFOR ) == aRet[1] + cSRAMat + cTpForn + cCodFor),;
				(RHN->(RHN_FILIAL + RHN_MAT + RHN_OPERAC + RHN_ORIGEM + RHN_TPALT + RHN_TPFORN + RHN_CODFOR) == aRet[1]  + cSRAMat + "2" + cOrigem + "04" + cTpForn + cCodFor))		)
				If cSvAlias == "RHM"
					cPerIni := Substr(RHM->RHM_PERINI,3,4) + Substr( RHM->RHM_PERINI,1,2)
					cPerFim	:= Substr(RHM->RHM_PERFIM,3,4) + Substr( RHM->RHM_PERFIM,1,2)
				Else
					If RHN->(RHN_OPERAC + RHN_ORIGEM + RHN_TPALT) == "2" + cOrigem + "04" 
						cPerIni := Substr(RHN->RHN_PERINI,3,4) + Substr( RHN->RHN_PERINI,1,2)
						cPerFim	:= Substr(RHN->RHN_PERFIM,3,4) + Substr( RHN->RHN_PERFIM,1,2)
					Else
						( cSvAlias )->( DbSkip() )	
						Loop
					EndIf	
				EndIf
				//If (cDtOcor >= cPerIni .And. (Empty(cPerFim) .Or. cDtOcor <= cPerFim)) Thais Paiva - 10056335
				If (cDtOcor >= cPerIni .And. (Empty(Alltrim(cPerFim)) .Or. cDtOcor <= cPerFim))
					lFound := .T.
					Exit
				EndIf
				( cSvAlias )->( DbSkip() )	
			EndDo
			If !lFound 
//				If IsBlind()
					fIncLog({"04","Linha: " + cValToChar(nContLin) + " / Matricula " + Alltrim(cSRAMat) + " -> Data da Ocorrência esta fora do Período de validade do Plano Ativo!"})
					AAdd(aLogExcel,{3,cValToChar((nContLin)) + ";" + Alltrim(cCPF) + ";" + Alltrim(cSRAMat) + ";Não; Data da Ocorrência esta fora do Período de validade do Plano Ativo!"})
			 //		Help(,,'HELP',,OemToAnsi("Data da Ocorrência esta fora do Período de validade do Plano Ativo!"),1,0)	//"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"   
					
/*				Else
					MsgInfo(OemToAnsi(STR0010)) //"Data da Ocorrência esta fora do Período de validade do Plano Ativo!"
				EndIf  */
			EndIf		
		EndIf
	EndIf	

	RestArea( aArea )

Return( lRet )
