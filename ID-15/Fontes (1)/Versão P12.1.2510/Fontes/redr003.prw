#include "Protheus.ch"
/*/{Protheus.doc} REDR003
Rotina responsável por gerar relatório de Cadastro de vagas.
@type function
@version P12 
@author Ricardo Junior
@since 06/01/2025
@return variant, Nulo
/*/
User Function REDR003()

	Local aPergs   		:= {}
	Local cFilDe  		:= Space(FwTamSX3("QS_FILIAL")[01])
	Local cFilAt  		:= Space(FwTamSX3("QS_FILIAL")[01])
	Local cCodDe  		:= Space(FwTamSX3("QS_XSOLPTL")[01])
	Local cCodAte  		:= Space(FwTamSX3("QS_XSOLPTL")[01])
	Local cDataDe  		:= Ctod(Space(8))
	Local cDataAt  		:= Ctod(Space(8))

	aAdd(aPergs, {1, "Filial De",  cFilDe,  "", ".T.", "SM0", ".T.", 50,  .F.})
	aAdd(aPergs, {1, "Filial Até", cFilAt,  "", ".T.", "SM0", ".T.", 50,  .T.})
	aAdd(aPergs, {1, "Cod Solic De", cCodDe,  "", ".T.", "SM0", ".T.", 50,  .F.})
	aAdd(aPergs, {1, "Cod Solic Até", cCodAte,  "", ".T.", "SM0", ".T.", 50,  .T.})
	aAdd(aPergs, {1, "Dt Abertura De", cDataDe,  "", ".T.", "", "", 50,  .T.})
	aAdd(aPergs, {1, "Dt Abertura Até", cDataAt,  "", ".T.", "", "", 50,  .T.})

	aAdd(aPergs,{2,"Status",1,{"1=Aprovada","2=Em recrutamento","3=Em movimentação RI", "4=Cadastro", "5=Cancelada", "6=Suspensa", "7=Concluída", "8=Exame/Docto", "9=Assinatura de Contrato", "X=Todos"},100,".T.",.F.})

	If !ParamBox(aPergs, "Informe os parâmetros")
		Return
	endif

	Processa({|| fProcRel()}, "Aguarde...", "Imprimindo relatório...", .T.)

Return
/*/{Protheus.doc} fProcRel
Processa relatorio
@type function
@version P12 
@author ricar
@since 1/6/2025
@return variant, Nulo
/*/
Static function fProcRel()
	Local aArea         := GetArea()
	Local cQuery        := ""
	Local cAlias        := GetNextAlias()
	Local cArquivo      := GetTempPath()+'cadastro_de_vagas'+FWTimeStamp(4,date(), time())+'.xml'
	Local cAba 			:= "Relatório"
	Local cTitulo 		:= "Tabela SQS - Cadastro de Vagas"
	Local nC 			:= 00
	Local nCount 		:= 00

	cQuery := " SELECT * " + CRLF
	cQuery += " FROM "+RetSqlName("SQS")+" SQS " + CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " AND QS_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'" + CRLF
	cQuery += " AND QS_XSOLPTL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'" + CRLF
	cQuery += " AND QS_DTABERT BETWEEN '"+DToS(MV_PAR05)+"' AND '"+DToS(MV_PAR06)+"'" + CRLF
	
	if ValType(MV_PAR07) == "N"
		cQuery += " AND QS_XSTATUS = '"+cValToChar(MV_PAR07)+"'" + CRLF
	else
		if AllTrim(MV_PAR07) != "X" 
			cQuery += " AND QS_XSTATUS = '"+MV_PAR07+"'" + CRLF
		endif
	endif

	DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), cAlias, .F., .T.)
	Count To nCount
	ProcRegua(nCount)
	(cAlias)->(DbGoTop())

	oGerExc := customExcel():new(cArquivo,cAba,cTitulo)

	//Alinhamento da coluna ( 1-Left,2-Center,3-Right )
	//Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
	aCampos := {;
		{"FILIAL",1,1},;
		{"COD. VAGA",1,1},;
		{"SOLIC. PORTAL",1,1},;//{"CUSTO DA VAGA",1,1},;		
		{"TIPO DA VAGA",1,1},;
		{"COD. POSTO",1,1},;
		{"CENTRO DE CUSTO",1,1},;
		{"NOME C. CUSTO",1,1},;
		{"COD FUNÇÃO",1,1},;
		{"NOME FUNÇÃO",1,1},;
		{"JORNADA",1,2},;
		{"TURNO",1,1},;
		{"DESC. TURNO",1,1},;
		{"DATA ABERTURA",1,4},;
		{"DATA FECHAMENTO",1,4},;
		{"JUSTIFICATIVA DE VAGA",1,1},;
		{"COMPUTADOR",1,1},;
		{"LOCALIDADE",1,1},;
		{"OUTROS",1,1},;
		{"SOLICITANTE",1,1},;
		{"ANALISTA RESPONS.",1,1},;
		{"STATUS DA VAGA",1,1}}

	oGerExc:addStruct(aCampos)

	While !((cAlias)->(EoF()))
		nC++
		Sleep(100)
		ProcessMessages()
		IncProc("Processando registro: " +cValToChar(nC) +"/"+cValToChar(nCount))		
		oGerExc:AddRow({;
			(cAlias)->QS_FILIAL,;
			(cAlias)->QS_VAGA,;
			(cAlias)->QS_XSOLPTL,;//(cAlias)->QS_VCUSTO,;
			iif(!Empty((cAlias)->QS_TIPO),X3CboxToArray("QS_TIPO")[1][Val((cAlias)->QS_TIPO)],""),;
			(cAlias)->QS_POSTO,;
			(cAlias)->QS_CC,;
			Posicione("CTT",1,FwxFilial("CTT")+(cAlias)->QS_CC,"CTT_DESC01"),;
			(cAlias)->QS_FUNCAO,;
			Posicione("SRJ",1,FwXFilial("SRJ")+(cAlias)->QS_FUNCAO, "RJ_DESC"),;
			(cAlias)->QS_XJORN,;
			(cAlias)->QS_XTURNO,;
			(cAlias)->QS_XDESTUR,;
			SToD((cAlias)->QS_DTABERT),;
			SToD((cAlias)->QS_DTFECH),;
			iif(!Empty((cAlias)->QS_XJUSTVA),X3CboxToArray("QS_XJUSTVA")[1][Val((cAlias)->QS_XJUSTVA)],""),;
			iif(!Empty((cAlias)->QS_XREQSOL),X3CboxToArray("QS_XREQSOL")[1][Val((cAlias)->QS_XREQSOL)],""),;
			iif(!Empty((cAlias)->QS_XLOCALI),X3CboxToArray("QS_XLOCALI")[1][Val((cAlias)->QS_XLOCALI)],""),;	
			(cAlias)->QS_XOUTROS,;
			(cAlias)->QS_SOLICIT,;
			(cAlias)->QS_MATRESP,;
			iif(!Empty((cAlias)->QS_XSTATUS),X3CboxToArray("QS_XSTATUS")[1][Val((cAlias)->QS_XSTATUS)],"")})

		(cAlias)->(DbSkip())
	EndDo	
/*	
1=Aumento de Quadro;2=Ajuste de Estrutura;3=Substituição de Colaborador;4=Substituição de Afastado                    
1=Não;2=Sim                                                                                                                     
1=Passeio;2=Plataforma;3=Central de Atendimento;4=Outros;5=JK                                                                 
*/

	oGerExc:generate()

	(cAlias)->(DbCloseArea())
	RestArea(aArea)
Return
