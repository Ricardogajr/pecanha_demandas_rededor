#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

//////////////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------------+//
//| PROGRAMA  | FISASQL01 | AUTORA| Thais Paiva              | DATA | 19/08/2021   |//
//+--------------------------------------------------------------------------------+//
//| DESCRICAO  | Função: Customizar filtro da tabela SF3 para transmissão de nota. |//
//| CHAMADO    | 12103488                                                          |//
//+--------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////

User Function FISASQL01()

LOCAL cAliasSF3 := PARAMIXB[1]
LOCAL cSerieIni := PARAMIXB[2]
LOCAL cSerieFim := PARAMIXB[3]
LOCAL cNotaIni := PARAMIXB[4]
LOCAL cNotaFin := PARAMIXB[5]
LOCAL cWhere := PARAMIXB[6]
LOCAL dDataIni := PARAMIXB[7]
LOCAL dDataFim := PARAMIXB[8]
LOCAL nCodIssF3	:= tamSX3("F3_CODISS")[1]
LOCAL cWhereR := ""

If cCodMun == "3304557"

	cWhereR := substr( cWhere , 1, At("And",cWhere) - 1 )
	cWhereR += substr( cWhere , At("ISS<>'')",cWhere) + 9)
	
	BeginSql Alias cAliasSF3
			
		COLUMN F3_ENTRADA AS DATE
		COLUMN F3_DTCANC AS DATE
		COLUMN F3_EMISSAO AS DATE

		SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC,F3_CODNFE,SF3.F3_CODISS,F3_EMISSAO,F3_CODRSEF
		FROM %Table:SF3% SF3
		WHERE
		SF3.F3_FILIAL		= %xFilial:SF3% AND
		SF3.F3_SERIE		>= %Exp:cSerieIni% AND
		SF3.F3_SERIE		<= %Exp:cSerieFim% AND
		SF3.F3_NFISCAL	>= %Exp:cNotaIni% AND
		SF3.F3_NFISCAL	<= %Exp:cNotaFin% AND			
		SF3.F3_CODRET 	<> %Exp:'111'% AND
		%Exp:cWhere% AND 
		SF3.F3_RECISS='1' AND
		SF3.F3_CODISS  <> %Exp:Space(nCodIssF3)% AND
		SF3.F3_DTCANC 	= %Exp:Space(8)% AND
		SF3.%notdel%
		UNION ALL
		SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC,F3_CODNFE,SF3.F3_CODISS,F3_EMISSAO,F3_CODRSEF
		FROM %Table:SF3% SF3
		JOIN %Table:SE2% SE2 ON
		SE2.E2_FILIAL 	 = SF3.F3_FILIAL AND
		SE2.E2_PREFIXO 	 = SF3.F3_SERIE AND 
		SE2.E2_NUM		 = SF3.F3_NFISCAL AND
		SE2.E2_FORNECE = SF3.F3_CLIEFOR AND
		SE2.E2_LOJA = SF3.F3_LOJA AND
		SE2.E2_BAIXA 	>= %Exp:dtos(dDataIni)% AND 
		SE2.E2_BAIXA 	<= %Exp:dtos(dDataFim)% AND
		SE2.E2_SALDO = 0 AND
		SE2.%notdel%
		WHERE
		SF3.F3_FILIAL		= %xFilial:SF3% AND
		SF3.F3_SERIE		>= %Exp:cSerieIni% AND
		SF3.F3_SERIE		<= %Exp:cSerieFim% AND
		SF3.F3_NFISCAL	>= %Exp:cNotaIni% AND
		SF3.F3_NFISCAL	<= %Exp:cNotaFin% AND			
		SF3.F3_CODRET 	<> %Exp:'111'% AND
		%Exp:cWhereR% AND 
		SF3.F3_RECISS='2' AND
		SF3.F3_CODISS  <> %Exp:Space(nCodIssF3)% AND
		SF3.F3_DTCANC 	= %Exp:Space(8)% AND
		SF3.%notdel%
	EndSql

EndIf

Return(cAliasSF3)
