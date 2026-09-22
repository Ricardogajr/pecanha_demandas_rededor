#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | AMSR0002 | AUTORA| Thais Paiva               | DATA |15/06/2021 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Relatório por filiais – Tabela SIGAMAT                          |//
//+-----------------------------------------------------------------------------+//
//| Chamado   | 11571630 - DOR09039537 				                            |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

User Function AMSR0002()

Local oReport
Private cPerg    := "AMSREL002"
Private nRecTMP  := 0
Private aTabela := {"SM0"}
Private _aAllFil := {}
Private _aRelFil := {}
Private aOrdem := {}

If !Pergunte(cPerg,.T.)
	Return
EndIf 

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Interface de Impressão                                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
oReport:= ReportDef(cPerg)
oReport:PrintDialog()

Return
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| ReportDef                                                                   |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function ReportDef(cPerg)
Local oCell
Local oBreak
Private oReport
Private cTitulo := "Relatório por filiais – SIGAMAT"



oReport:= TReport():New("AMSR0002", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cTitulo )
oReport:SetLandscape(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport,"Seção 1",aTabela,aOrdem)

TRCell():New( oSection1, "M0_FILIAL","", "Filial", "@!", 08,  )
TRCell():New( oSection1, "M0_NOME","", "Nome", "@!", 40,  )
TRCell():New( oSection1, "M0_CGC","", "CNPJ", "@R 99.999.999/9999-99", 14,  )
TRCell():New( oSection1, "M0_NOMECOM","", "Razão Social", "@!", 60,  )
TRCell():New( oSection1, "M0_TEL","", "Telefone", "@!", 14,  )
TRCell():New( oSection1, "M0_INSCM","", "Inscrição Municipal", "@!", 25,  )
TRCell():New( oSection1, "M0_CODMUN","", "Código Município"	, "@R 9999999", 7,  )
TRCell():New( oSection1, "M0_INSC","", "Inscrição Estadual", "@!", 14,  )
TRCell():New( oSection1, "M0_ENDENT","", "Endereço", "@!", 60,  )
TRCell():New( oSection1, "M0_COMPENT","", "Complemento", "@!", 25,  )
TRCell():New( oSection1, "M0_BAIRENT","", "Bairro", "@!", 35,  )
TRCell():New( oSection1, "M0_CIDENT","", "Cidade", "@!", 60,  )
TRCell():New( oSection1, "M0_ESTENT","", "UF", "@!", 2,  )
TRCell():New( oSection1, "M0_CEPENT","", "CEP", "@R 99.999-999", 8,  )
TRCell():New( oSection1, "M0_COD_ATV","", "Código Atividade", "@R 99999", 5,  )
TRCell():New( oSection1, "M0_NIRE","", "Número NIRE", "@!", 25,  )
TRCell():New( oSection1, "M0_DTRE","", "Data NIRE", , 8,  )
TRCell():New( oSection1, "M0_DSCCNA","", "Atividade Econômica", "@!", 60,  )

oSection1:SetPageBreak(.T.)

Return(oReport)
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Inicializa ReportPrint                                                      |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function ReportPrint(oReport)
Local oSection1	:= oReport:Section(1)
Local cStartPath	:= GetSrvProfString("Startpath","")
Private _aRelFil := {}

AMSR0002A()

oSection1:Init()

If Len(_aRelFil) > 0
   
	For _nR := 1 to Len(_aRelFil)

	//-- Impressao do Relatorio
		If oReport:Cancel()
			Exit
		EndIf

		oSection1:Cell("M0_FILIAL"):SetValue(_aRelFil[_nR][1])
		oSection1:Cell("M0_NOME")   :SetValue(_aRelFil[_nR][2])
		oSection1:Cell("M0_CGC")  :SetValue(_aRelFil[_nR][3])
		oSection1:Cell("M0_NOMECOM")  :SetValue(_aRelFil[_nR][4])
		oSection1:Cell("M0_TEL")    :SetValue(_aRelFil[_nR][5])
		oSection1:Cell("M0_INSCM")  :SetValue(_aRelFil[_nR][6])
		oSection1:Cell("M0_CODMUN") :SetValue(_aRelFil[_nR][7])
		oSection1:Cell("M0_INSC") :SetValue(_aRelFil[_nR][8])
		oSection1:Cell("M0_ENDENT") :SetValue(_aRelFil[_nR][9])
		oSection1:Cell("M0_COMPENT") :SetValue(_aRelFil[_nR][10])
		oSection1:Cell("M0_BAIRENT") :SetValue(_aRelFil[_nR][11])
		oSection1:Cell("M0_CIDENT") :SetValue(_aRelFil[_nR][12])
		oSection1:Cell("M0_ESTENT") :SetValue(_aRelFil[_nR][13])
		oSection1:Cell("M0_CEPENT") :SetValue(_aRelFil[_nR][14])
		oSection1:Cell("M0_COD_ATV") :SetValue(_aRelFil[_nR][15])
		oSection1:Cell("M0_NIRE") :SetValue(_aRelFil[_nR][16])
		oSection1:Cell("M0_DTRE") :SetValue(DTOC(_aRelFil[_nR][17]))
		oSection1:Cell("M0_DSCCNA") :SetValue(_aRelFil[_nR][18])

		oSection1:PrintLine()

	Next _nR

	MsgInfo("Relatório por filial – Tabela SIGAMAT"+Chr(13),"*** FIM DO PROCESSAMENTO ***")

EndIf

//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Finaliza ReportPrint                                                        |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

oReport:IncMeter()
oSection1:Finish()
oSection1:PageBreak()


Return(Nil)
//////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| Gera Registros para Tabela Temporaria                                       |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function AMSR0002A()
Local _aAllFil := {}
Local _aCampos := {"M0_CODFIL","M0_FILIAL","M0_CGC","M0_NOMECOM","M0_TEL","M0_INSCM","M0_CODMUN","M0_INSC","M0_ENDENT","M0_COMPENT","M0_BAIRENT","M0_CIDENT","M0_ESTENT","M0_CEPENT","M0_COD_ATV","M0_NIRE","M0_DTRE","M0_DSCCNA"}
Local _aAuxRel := {}
Local _aAuxCp := {}

_aAllFil := FWLoadSM0( .T. , .F. )


If !Empty(Alltrim(MV_PAR01)) .Or. !Empty(Alltrim(MV_PAR02))
	For _nM0 := 1 to Len(_aAllFil)

		If _aAllFil[_nM0][2] >= MV_PAR01 .and. _aAllFil[_nM0][2] <= MV_PAR02
			
			_aAuxCp := FWSM0Util():GetSM0Data( _aAllFil[_nM0][1] , _aAllFil[_nM0][2] , _aCampos ) 
			
			For _nA := 1 to Len(_aAuxCp)
				Aadd(_aAuxRel, _aAuxCp[_nA][2])
			Next _nA

			Aadd(_aRelFil, _aAuxRel)

			_aAuxCp := {}
			_aAuxRel := {}
		
		EndIf

	Next _nM0
Else
	For _nM0 := 1 to Len(_aAllFil)

		_aAuxCp := FWSM0Util():GetSM0Data( _aAllFil[_nM0][1] , _aAllFil[_nM0][2] , _aCampos ) 
			
		For _nA := 1 to Len(_aAuxCp)
			Aadd(_aAuxRel, _aAuxCp[_nA][2])
		Next _nA

		Aadd(_aRelFil, _aAuxRel)

		_aAuxCp := {}
		_aAuxRel := {}

	Next _nM0
EndIf


aSort(_aRelFil,,,{ |X,Y| X[1] < Y[1]}) 

Return
