// #########################################################################################
// Projeto: CONECTA REDE D´OR
// Modulo : SIGAGPE
// Fonte  : RD0001.prw
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+---------------------------------------------------------
// 15/11/2016 | Samuel de Vincenzo | Gerado com auxílio do Assistente de Código do TDS.
// -----------+-------------------+---------------------------------------------------------

#include "protheus.ch"
#include "Report.ch"
//#include "RD0001.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RD0001
RELATÓRIO DE DEPENDENTES EXCLUSIVO REDE D´OR
@author    Samuel de Vincenzo
@version   11.3.3.201609231349
@since     15/11/2016
/*/
//------------------------------------------------------------------------------------------

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³RD0002   ºAutor     ³Samuel Vincenzo      º Data ³ 15/11/2016        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.      ³ 5.	Relação de Beneficiários (pensionista),   						º±±
±±º           ³ com dados do titular (matrícula e nome)                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso        ³ Folha de pagamento  - Específico REDE D´OR                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³ Data     ³ BOPS           ³ Motivo da Alteracao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º			   ³          ³                ³                                        º±±
±±º            ³          ³				   ³									    º±±
±±º            ³          ³                ³										º±±
±±º            ³          ³                ³										º±±
±±º			   ³		  ³				   ³										º±±
±±³            ³          ³                ³										º±±
±±³            ³          ³                ³										º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} RD0002
//TODO Descrição auto-gerada.
@author Samuel de Vincenzo
@since 16/11/2016
@version undefined

@type function
/*/
User Function RD0002()

	Local oReport
	Local aArea			:= GetArea()
	Private cTitulo		:= "Relatório de Beneficiários(Pensionista)"
	Private aOrd		:= {"MATRICULA","NOME"}
	Private cPerg		:= "RD0002R"
	Private cString 	:= "SRA"
	Private cString1	:= "SRQ"

	//verifica as perguntas selecionadas
	Pergunte(cPerg,.F.)
	oReport := ReportDef()
	oReport:PrintDialog()

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef  ³ Autor ³ Tania Bronzeri        ³ Data ³ 30/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Dependentes									    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPER190                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local cDesc1	:= "Relatório de Beneficiários " + " Será impresso de acordo com os parametros solicitados pelo usuário"

	//Criação dos componentes de impressao
	DEFINE REPORT oReport NAME "RD0002" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| RD02Imp(oReport)} DESCRIPTION cDesc1	

	//oReport:SetTotalInLine(.F.)     // para totalizar em linhas
	oReport:nFontBody	:= 7
	oReport:SetDynamic()

	//SECTION 1
	DEFINE SECTION oSection1 OF oReport TITLE OemToAnsi("FUNCIONARIOS") TABLES "SRA", "SRQ" ORDERS aOrd	//Processo / Periodo

		DEFINE CELL NAME "RA_FILIAL"   OF oSection1 ALIAS "SRA" TITLE OemToAnsi("Fil.") 
		DEFINE CELL NAME "RA_MAT"      OF oSection1 ALIAS "SRA" TITLE OemToAnsi("Matrícula.")
		DEFINE CELL NAME "RA_NOME"     OF oSection1 ALIAS "SRA" TITLE OemToAnsi("Nome Func.")
		DEFINE CELL NAME "RQ_NOME"     OF oSection1 ALIAS "SRQ" TITLE OemToAnsi("Nome Benef.")
		DEFINE CELL NAME "RQ_NASC"     OF oSection1 ALIAS "SRQ" TITLE OemToAnsi("DT. Nasc Benef.")
		DEFINE CELL NAME "RQ_CIC"      OF oSection1 ALIAS "SRQ" TITLE OemToAnsi("CPF Benef.")
		DEFINE CELL NAME "RQ_PERCENT"  OF oSection1 ALIAS "SRQ" TITLE OemToAnsi("Perc. Benef.") 
		DEFINE CELL NAME "RQ_NRSLMIN"  OF oSection1 ALIAS "SRQ" TITLE OemToAnsi("Nr. Sal. Min.") 
		DEFINE CELL NAME "RQ_BCDEPBE"  OF oSection1 ALIAS "SRQ" TITLE OemToAnsi("Banco Benefe.") 
		DEFINE CELL NAME "RQ_CTDEPBE"  OF oSection1 ALIAS "SRQ" TITLE OemToAnsi("C.Corre Benef.") 				
		
		DEFINE FUNCTION FROM oSection1:Cell("RQ_PERCENT")		FUNCTION COUNT NO END SECTION NO END REPORT PICTURE "@E 999,999.99"
		DEFINE FUNCTION FROM oSection1:Cell("RQ_NRSLMIN")		FUNCTION COUNT NO END SECTION NO END REPORT PICTURE "@E 999,999.99"
	
	Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RD02Imp  ºAutor  ³ Samuel Vincenzo    º Data ³  16/11/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao do relatorio.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ RD0002                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RD02Imp(oReport)
	Local oSection 	:= oReport:Section(1)
	Local cFiltro  	:= ""
	Local cAliasQry	:= ""
	Local cSitQuery	:= ""
	Local cCatQuery	:= ""
	Local cTitCC	:= ""
	Local cTitFil	:= ""
	Local cAuxPrc	:= ""
	Local nReg		:= 0
	Local nTamCod	:= 0
	Local X			:= 0
	Local xQuebra	:= 0

	//Variaveis de Acesso de usuario
	Private cAcessaSRA	:= &(" { || " + ChkRH("RD0002", "SRA", "2") + " } " )
	Private nOrdem 		:= oSection:GetOrder()

	//Carregando variaveis MV_par?? para variaveis de sistema

	// mv_par01        //  Filial
	// mv_par02        //  Matricula
	// mv_par03        //  Nome
	// mv_par04        //  Situacoes
	// mv_par05        //  Categorias

	Private cSituacao	:= mv_par04
	Private cCategoria	:= mv_par05
	Private aInfo		:= {}
	Private lSalta		:= .F.

	// Quebrar e Totalizar por Filial
	DEFINE BREAK oBreakFil OF oSection WHEN oSection:Cell("RA_FILIAL") TITLE OemToAnsi("TOTAL FILIAL")			// "TOTAL FILIAL -> "
	DEFINE FUNCTION FROM oSection:Cell("RA_MAT")		FUNCTION COUNT BREAK oBreakFil NO END REPORT NO END SECTION
	oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi("TOTAL FILIAL")+x,fInfo(@aInfo,y)})	//"TOTAL FILIAL -> "
	oBreakFil:SetTotalText({||cTitFil})

	If lSalta
		oBreakFil:OnPrintTotal({||oBreakCCusto:SetPageBreak(.T.),oBreakFil:SetPageBreak(.T.)})
	Else
		oBreakFil:SetPageBreak(.F.)
	EndIf

	// Condicao de impressao do Funcionario
	oSection:SetLineCondition({|| fRD001Cond(cAliasQry) })

	cAliasQry := "SRA"

	// Modifica variaveis para a Query
	cSitQuery := ""
	For nReg:=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSituacao)
			cSitQuery += ","
		EndIf
	Next nReg
	cSitQuery := "%" + cSitQuery + "%"

	cCatQuery := ""
	For nReg:=1 to Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCategoria)
			cCatQuery += ","
		EndIf
	Next nReg
	cCatQuery := "%" + cCatQuery + "%"

	// Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	BEGIN REPORT QUERY oSection

		If nOrdem == 1
			cOrdem := "%SRA.RA_FILIAL,SRA.RA_MAT%"
		ElseIf nOrdem == 2
			cOrdem := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_MAT%"
		ElseIf nOrdem == 3
			cOrdem := "%SRA.RA_FILIAL,SRA.RA_NOME%"
		EndIf

		// NAO RETIRAR ESTA LINHA!
		// Este relatorio abre a query abaixo com o Alias "SRA" e como a tabela "SRA" eh utilizada
		// em varios outros programas, neste caso, o Controle de Acesso de Usuarios, e preciso
		// fechar primeiro a area para depois poder utiliza-la.
		SRA->( dbCloseArea() )
		SRB->( dbCloseArea() )

		BeginSql alias cAliasQry
		SELECT	SRA.RA_FILIAL,  SRA.RA_MAT,     SRA.RA_NOME,   SRA.RA_SITFOLH, SRA.RA_CATFUNC,
		RQ_NOME, RQ_NASC, RQ_CIC, RQ_PERCENT, RQ_NRSLMIN, RQ_BCDEPBE, RQ_CTDEPBE
		FROM %table:SRA% SRA
		INNER JOIN %table:SRQ% SRQ ON SRA.RA_MAT = SRQ.RQ_MAT
		WHERE SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%) 	AND
		SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
		SRA.%notDel%
		ORDER BY %exp:cOrdem%
		EndSql

	END REPORT QUERY oSection PARAM mv_par01, mv_par02, mv_par03
	// Define o total da regua da tela de processamento do relatorio
	oReport:SetMeter( 100 )

	oSection:Print()

	// Termino do Relatorio
	// Fecha area da query utilizada como SRA para abrir a
	// Tabela SRA corretamente em alguma das proximas rotinas.
	(cAliasQry)->( DbCloseArea() )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fRD001Cond    ³ Autor ³ Samuel Vincenzo  ³ Data ³ 16/11/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica Condicao para Impressao da Linha do Relatorio     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RD0001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fRD001Cond(cAliasQry)
	Local lRet	:= .T.
	Default cAliasQry	:= "SRA"

	// Consiste Filiais e Acessos
	If !( (cAliasQry)->RA_FILIAL $ fValidFil() ) .Or. !Eval( cAcessaSRA )
		lRet	:= .F.
	EndIf

Return lRet