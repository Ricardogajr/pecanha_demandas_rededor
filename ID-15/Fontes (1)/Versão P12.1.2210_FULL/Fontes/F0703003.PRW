#include "protheus.ch"

/*{Protheus.doc} F0703002
Relatorio de divergencia de fechamento
 
@author Alex Sandro Valario
@since  27/06/2017
@project MAN0000007423041_EF_030
@menu Divergencia de Fechamento
@version P12.1.7
@return Nil  
*/
User Function F0703003()
    Local oReport

    If TRepInUse()	
        oReport := ReportDef()	
        oReport:PrintDialog()	
    EndIf
Return

Static Function ReportDef()
    Local oReport
    Local oSection
    Local cTitulo := "Divergencias de fechamento de estoque Prothes x Fronts"
    Local cDescri := "Relacao dos produtos com divergencias de saldos entre o Protheus e o Fronts no fechamento de estoque."
    
    /*
    Private nDifQtd := 0
    Private nDifVlr := 0
    */
    oReport := TReport():New("FS07030", cTitulo, "", {|oReport| PrintReport(oReport)}, cDescri)
    oReport:SetLandscape()
    oSection := TRSection():New(oReport, "Divergencia de fechamento", {"SB2", "SB1"})
    
    TRCell():New(oSection,"B1_GRUPO"  , "SB1")
    TRCell():New(oSection,"B2_COD"    , "SB2")
    TRCell():New(oSection,"B1_DESC"   , "SB1")
    TRCell():New(oSection,"B2_LOCAL"  , "SB2")
    TRCell():New(oSection,"B2_XQTDE"  , "SB2")
    TRCell():New(oSection,"B2_XVLTOT" , "SB2")
    TRCell():New(oSection,"B1_XTERUM" , "SB1")
    TRCell():New(oSection,"B2_QFIM"   , "SB2")
    TRCell():New(oSection,"B2_VFIM1"  , "SB2")
    TRCell():New(oSection,"nDifQtd"	  , "" ,"Dif. Qtde" , "@E 9,999,999.99" )
    TRCell():New(oSection,"nDifVlr"	  , "" ,"Dif. Valor", "@E 9,999,999.99" )
    
        
Return oReport

Static Function PrintReport(oReport)
    Local oSection := oReport:Section(1)
    Local nDifQtd  := 0
    Local nDifVlr  := 0
    Local nTDifQtd := 0
    Local nTDifVlr := 0

    SB2->(DbSetOrder(1))
    SB2->(DbSeek(xFilial("SB2"), .T.))
    oReport:SetMeter(RecCount())
    While SB2->( !Eof() .And. xFilial("SB2") == B2_FILIAL )
        If oReport:Cancel()		
            Exit	
        EndIf		
    
        SB1->(DbSetOrder(1))
        SB1->(DbSeek(xFilial("SB1") + SB2->B2_COD))
    
        nDifQtd := SB2->B2_XQTDE - SB2->B2_QFIM
        nDifVlr := SB2->B2_XVLTOT - SB2->B2_VFIM1

        nTDifQtd += nDifQtd
        nTDifVlr += nDifVlr
        oSection:Init()	
        oSection:Cell("nDifQtd"):SetValue(nDifQtd)
        oSection:Cell("nDifVlr"):SetValue(nDifVlr)
        oSection:PrintLine()		
       
        SB2->(DbSkip())

        oReport:IncMeter()
    End

    oReport:SkipLine()

    oSection:Cell("B1_GRUPO"):Hide()
    oSection:Cell("B2_COD"  ):Hide()
    oSection:Cell("B1_DESC" ):Hide()
    oSection:Cell("B2_LOCAL"):Hide()
    oSection:Cell("B2_XQTDE"):Hide()
    oSection:Cell("B2_XVLTOT"):Hide()
    oSection:Cell("B1_XTERUM"):Hide()
    oSection:Cell("B2_QFIM" ):Hide()
    oSection:Cell("B2_VFIM1"):Hide()
    oSection:Cell("nDifQtd"):SetValue(nTDifQtd)
    oSection:Cell("nDifVlr"):SetValue(nTDifVlr)
    oSection:PrintLine()
    oSection:Finish()		

Return

