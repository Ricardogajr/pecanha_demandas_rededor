// #########################################################################################
// Projeto: REDE D´OR
// Modulo : SIGAGPE
// Fonte  : AMSREL01.prw
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+---------------------------------------------------------
// 08/03/2018 | Paulo Dias        | Relatório de Beneficiários (Pensão)
// -----------+-------------------+---------------------------------------------------------


#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

User Function AMSREL01()

Private oReport  := Nil
Private oSecCab	 := Nil
Private cPerg 	 := "AMSREL01" //PadR ("AMSREL01", Len (SX1->X1_GRUPO)) - Thais Paiva - Compatibilização P27


/*PutSx1(cPerg,"01","Filial?"  ,'','',"mv_ch1","C",TamSx3("RA_FILIAL")[1] ,0,,"G","","SRA","","","mv_par01","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"02","Matrícula De?"  ,'','',"mv_ch2","C",TamSx3("RA_MAT")[1] ,0,,"G","","SRA","","","mv_par02","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"03","Matrícula Ate?" ,'','',"mv_ch3","C",TamSx3("RA_MAT")[1] ,0,,"G","","SRA","","","mv_par03","","","","","","","","","","","","","","","","")*/

ReportDef()
oReport	:PrintDialog()	

Return Nil


Static Function ReportDef()

oReport := TReport():New("AMSREL01","Relatório de Beneficiários",cPerg,{|oReport| PrintReport(oReport)},"RELATÓRIO LÍQUIDO DE PENSÃO")
oReport:SetLandscape(.T.)

oSecCab := TRSection():New( oReport , "TESTE", {"QRY"} )
TRCell():New( oSecCab, "RQ_FILIAL"     , "QRY")
TRCell():New( oSecCab, "RQ_MAT"    , "QRY")
TRCell():New( oSecCab, "RQ_NOME"    , "QRY")
TRCell():New( oSecCab, "RQ_CIC"      , "QRY")
TRCell():New( oSecCab, "RQ_BCDEPBE"      , "QRY")
TRCell():New( oSecCab, "RQ_CTDEPBE"      , "QRY")
TRCell():New( oSecCab, "RC_VALOR"      , "QRY")


//TRFunction():New(oSecCab:Cell("RA_MAT"),/*cId*/,"COUNT"     ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)

Return Nil

Static Function PrintReport(oReport)

Local cQuery     := ""

Pergunte(cPerg,.T.)

cQuery += " SELECT "  
cQuery += "     SRQ.RQ_FILIAL " 
cQuery += "    ,SRQ.RQ_MAT " 
cQuery += "    ,SRQ.RQ_NOME "  
cQuery += "    ,SRQ.RQ_CIC " 
cQuery += "    ,SRQ.RQ_BCDEPBE "  
cQuery += "    ,SRQ.RQ_CTDEPBE "  
cQuery += "    ,SRC.RC_VALOR " 
cQuery += "   FROM " + RetSqlName("SRQ") + " SRQ " + "," +RetSqlName("SRC") + " SRC " + "," +RetSqlName("SRA") + " SRA " 
cQuery += "   WHERE SRQ.D_E_L_E_T_ = ' ' " 
cQuery += "   AND SRC.D_E_L_E_T_ = ' ' " 
cQuery += "   AND SRA.D_E_L_E_T_ = ' ' " 
cQuery += "   AND RA_FILIAL = RQ_FILIAL " 
cQuery += "   AND RA_FILIAL = RC_FILIAL " 
cQuery += "   AND RQ_FILIAL = RC_FILIAL " 
cQuery += "   AND RA_MAT = RQ_MAT " 
cQuery += "   AND RA_MAT = RC_MAT " 
cQuery += "   AND RQ_MAT = RC_MAT "
cQuery += "   AND RC_PD = '742' " 
cQuery += "   AND RA_FILIAL = '" + mv_par01 + "' "
cQuery += "   AND RA_MAT BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' " 
cQuery += "   ORDER BY RA_MAT,RA_FILIAL " 

If Select("QRY") > 0
	Dbselectarea("QRY")
	QRY->(DbClosearea())
EndIf

TcQuery cQuery New Alias "QRY"

oSecCab:BeginQuery()
oSecCab:EndQuery({{"QRY"},cQuery})    
oSecCab:Print()

Return Nil