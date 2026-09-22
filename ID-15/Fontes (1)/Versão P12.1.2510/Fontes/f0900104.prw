#include 'protheus.ch'
#include 'FWMVCDef.ch'

/*{Protheus.doc} F0900104
Utilizado para filtrar consulta padrão de produto na solicitação 
@author Alex Sandro Valario
@since 26/05/2017
@Project MAN0000007423043_EF_001
*/

User Function F0900104()

    Local aIndex     := {}
    Local aSeek      := {}
    Local cRetProd   := ""
    Local cAliasExqr := GetNextAlias()
    Local cCodCat    := GetMV("FS_CTRLPLA", , "000001" )
    Local cQuery     := ""
    Local oColumn
    Local oDlg
    Local oQryBrw

    AAdd(aSeek, {"Código"   , {{"", "C", TamSX3("B1_COD")[1] , 0, "Código"   , , }}})	
    AAdd(aSeek, {"Descrição", {{"", "C", TamSX3("B1_DESC")[1], 0, "Descrição", , }}})

    AAdd(aIndex, "B1_COD" )
    AAdd(aIndex, "B1_DESC")

    cQuery := " SELECT SB1.B1_COD, SB1.B1_DESC FROM " + RetSqlName("SB1") + " AS SB1 "
    cQuery += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND D_E_L_E_T_ = ' '"
    /*
    cQuery += " AND B1_COD NOT IN ("
    cQuery += "      SELECT DISTINCT ACV_CODPRO" 
    cQuery += "      FROM " + RetSqlName("ACV") + " AS ACV"
    cQuery += "      WHERE ACV.ACV_FILIAL = '" + xFilial("ACV") + "'"
    cQuery += "      AND ACV.ACV_CATEGO IN ("
    cQuery += "          SELECT ACU.ACU_COD FROM " + RetSqlName("ACU") + " AS ACU "
    cQuery += "          WHERE ACU.ACU_FILIAL = '" + xFilial("ACU") + "'"
    cQuery += "          AND (ACU.ACU_COD = '" + cCodCat + "' OR ACU.ACU_CODPAI = '" + cCodCat + "')"
    cQuery += "          AND ACU.ACU_COD <> '" + Space(Len(ACU->ACU_COD)) + "'"
    cQuery += "          AND ACU.D_E_L_E_T_ = ' '"
    cQuery += "          ) "
    cQuery += "      AND ACV.ACV_CODPRO <> '" + Space(Len(ACV->ACV_CODPRO)) + "'"
    cQuery += "      AND ACV.D_E_L_E_T_ = ' '"
    cQuery += "      ) "
	*/
    DEFINE MSDIALOG oDlg TITLE "Consulta Produto F0900104" FROM 0, 0 TO 460, 990 OF oMainWnd PIXEL

    oQryBrw := FWFormBrowse():New() 
    oQryBrw:SetOwner(oDlg)
    oQryBrw:SetDataQuery(.T.)
    oQryBrw:SetAlias(cAliasExqr)
    oQryBrw:SetQueryIndex(aIndex)
    oQryBrw:SetQuery(cQuery)
    oQryBrw:SetSeek(,aSeek)
    oQryBrw:SetDescription("Produtos")
    oQryBrw:SetMenuDef("")
    oQryBrw:DisableDetails()

    oQryBrw:SetDoubleClick( { || cRetProd := (oQryBrw:Alias())->B1_COD, oDlg:End()} )
    oQryBrw:AddButton( "Confirmar", {|| cRetProd := (oQryBrw:Alias())->B1_COD, oDlg:End() } , , 2 ) 
    oQryBrw:AddButton( "Cancelar" , {|| cRetProd := Space(Len(SB1->B1_COD))  , oDlg:End() } , , 2 ) 
    oQryBrw:DisableDetails()
    
    oColumn := FWBrwColumn():New(); If( ValType() == "N" ); oColumn:SetAlign(); EndIf; If( ValType() == "N" ); oColumn:SetBackColor(); EndIf; If( ValType() == "C" ); oColumn:SetComment(); EndIf; If( ValType({||B1_COD}) == "B" ); oColumn:SetData({||B1_COD}); EndIf; If( ValType() == "N" ); oColumn:SetDecimal(); EndIf; If.F.; oColumn:SetDelete(.F.); EndIf; If.F.; oColumn:SetDetails(.F.); EndIf; If( ValType() == "B" ); oColumn:SetDoubleClick(); EndIf; If.F.; oColumn:SetEdit(.F.); EndIf; If( ValType() == "N" ); oColumn:SetForeColor(); EndIf; If( ValType() == "B" ); oColumn:SetHeaderClick(); EndIf; oColumn:SetOptions(); If( ValType() == "N" ); oColumn:SetOrder(); EndIf; If( ValType() == "C"); oColumn:SetPicture(); ElseIf( ValType() == "B"); oColumn:SetPicture(); EndIf; If( ValType() == "C" ); oColumn:SetReadVar(); EndIf; If( ValType(TamSX3("B1_COD")[1]) == "N" ); oColumn:SetSize(TamSX3("B1_COD")[1]); EndIf; If.F.; oColumn:SetImage(.F.); EndIf; If( ValType("Código") == "C" ); oColumn:SetTitle("Código"); Else; oColumn:SetTitle(" "); EndIf; If( ValType() == "C" ); oColumn:SetType(); EndIf; If( ValType() == "B" ); oColumn:SetValid(); EndIf; If( ValType(oQryBrw) == "O" ); If ( oQryBrw:ClassName() $ "FWBROWSE|FWFORMBROWSE|FWMBROWSE|FWMARKBROWSE" ); oQryBrw:SetColumns({oColumn}); EndIf; EndIf
    oColumn := FWBrwColumn():New(); If( ValType() == "N" ); oColumn:SetAlign(); EndIf; If( ValType() == "N" ); oColumn:SetBackColor(); EndIf; If( ValType() == "C" ); oColumn:SetComment(); EndIf; If( ValType({||B1_DESC}) == "B" ); oColumn:SetData({||B1_DESC}); EndIf; If( ValType() == "N" ); oColumn:SetDecimal(); EndIf; If.F.; oColumn:SetDelete(.F.); EndIf; If.F.; oColumn:SetDetails(.F.); EndIf; If( ValType() == "B" ); oColumn:SetDoubleClick(); EndIf; If.F.; oColumn:SetEdit(.F.); EndIf; If( ValType() == "N" ); oColumn:SetForeColor(); EndIf; If( ValType() == "B" ); oColumn:SetHeaderClick(); EndIf; oColumn:SetOptions(); If( ValType() == "N" ); oColumn:SetOrder(); EndIf; If( ValType() == "C"); oColumn:SetPicture(); ElseIf( ValType() == "B"); oColumn:SetPicture(); EndIf; If( ValType() == "C" ); oColumn:SetReadVar(); EndIf; If( ValType(TamSX3("B1_DESC")[1]) == "N" ); oColumn:SetSize(TamSX3("B1_DESC")[1]); EndIf; If.F.; oColumn:SetImage(.F.); EndIf; If( ValType("Descrição") == "C" ); oColumn:SetTitle("Descrição"); Else; oColumn:SetTitle(" "); EndIf; If( ValType() == "C" ); oColumn:SetType(); EndIf; If( ValType() == "B" ); oColumn:SetValid(); EndIf; If( ValType(oQryBrw) == "O" ); If ( oQryBrw:ClassName() $ "FWBROWSE|FWFORMBROWSE|FWMBROWSE|FWMARKBROWSE" ); oQryBrw:SetColumns({oColumn}); EndIf; EndIf
                
    oQryBrw:Activate()

    Activate MsDialog oDlg 

Return cRetProd


