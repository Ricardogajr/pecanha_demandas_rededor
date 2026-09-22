#include "protheus.ch"
/*/{Protheus.doc} P52VldCC
Função responsável por filtrar 
@type function
@version P122410
@author Ricardo Junior
@since 12/22/2025
@return variant, Nulo
/*/
User Function P52VldCC(cVarCusto)
    Local aArea     := FWGetArea()
    Local cCampo    := ReadVar()
    Local cConteudo := &(cCampo)
    Local lRet      := .T.

    private cMsg1 := "Centro de custo não autorizado para o uso nesta filial!"
    private cMsg2 := "Centro de custo não autorizado para uso nesta filial! Caso seu documento precise se associado a este centro de custo acione a equipe de planejamento abrindo um chamado no sistema Portal Conecta no formulário de contas a pagar para habilitar o centro de custo na filial."

    Default cVarCusto := ""
    
    cConteudo := iif(!Empty(cVarCusto),cVarCusto,cConteudo)

    lGreen := GField(cFilAnt)
    lRet := Regra1(cConteudo, cFilAnt)//Regra de validação do Centro de custo existe na filial
    
    if !lGreen//Se não for greenfield executa a segunda regra
        if !lRet
            lRet := !Regra2(cConteudo)//Regra de validação do Centro de custo existe em outra filial
        endif
    endif

    if !lRet 
        //FWAlertHelp(cMsg1, cMsg2)        
        Help(NIL, NIL, "VALIDCC", NIL, "Centro de custo não autorizado para uso nesta filial!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Caso seu documento precise ser associado a este centro de custo nesta filial, solicite através de um chamado no Portal Conecta no seguinte formulário: Serviços Financeiros > Centro de Custos."})
    endif

    FwRestArea(aArea)
Return lRet

/*/{Protheus.doc} GField
Valida se é Greenfield.
@type function
@version P122410 
@author Ricardo Junior
@since 12/22/2025
@return variant, retorna se é greenfield sim ou não
/*/
Static Function GField(cFil)
    Local aArea  := FwGetArea()
    Local cQuery := ""
    Local lRet   := .F.

    cQuery += " SELECT P53_FILGRE FROM " + RetSqlName("P53")
    cQuery += " WHERE D_E_L_E_T_ = ' ' " 
    cQuery += " AND P53_FILGRE = '"+cFil+"'
    
    DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "cAlias", .F., .T.)
    
    If cAlias->(!EoF())
        lRet := .T.
    endif 

    cAlias->(DbCloseArea())
    FwRestArea(aArea)
Return lRet

/*/{Protheus.doc} Regra1
Regra de validação do Centro de custo existe na filial
@type function
@version P122410 
@author Ricardo Junior
@since 12/22/2025
@param cConteudo, character, centro de custo
@return variant, valida ou não o centro de custo
/*/
Static Function Regra1(cConteudo, cFil)
    Local aArea  := FwGetArea()
    Local cQuery := ""
    Local lRet   := .F.
    
    cQuery += " SELECT P52_FILCC, P52_CC, P52_ATIVO FROM " + RetSqlName("P52") + " P52 " + CRLF
    cQuery += " INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_CUSTO = P52_CC AND CTT_BLOQ = '2' AND CTT.D_E_L_E_T_ = ' ' "  + CRLF
    cQuery += " WHERE P52.D_E_L_E_T_ = ' ' "  + CRLF
    cQuery += " AND P52_FILCC = '"+cFil+"' " + CRLF
    cQuery += " AND P52_CC = '"+cConteudo+"' " + CRLF
    cQuery += " AND P52_ATIVO = '1' " + CRLF
    
    DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "cAlias", .F., .T.)

    if cAlias->(!EoF())
        lRet := .T.
    endif

    cAlias->(DbCloseArea())
    FwRestArea(aArea)
Return lRet


/*/{Protheus.doc} Regra2
Regra de validação do Centro de custo existe em outra filial
@type function
@version P122410 
@author Ricardo Junior
@since 12/22/2025
@param cConteudo, character, centro de custo
@return variant, valida ou não o centro de custo
/*/
Static Function Regra2(cConteudo)
    Local aArea  := FwGetArea()
    Local cQuery := ""
    Local lRet   := .F.
    
    cQuery += " SELECT P52_FILCC, P52_CC, P52_ATIVO FROM " + RetSqlName("P52") + " P52 " + CRLF
    cQuery += " INNER JOIN "+RetSqlName("CTT")+" CTT ON CTT_CUSTO = P52_CC AND CTT_BLOQ = '2' AND CTT.D_E_L_E_T_ = ' ' "  + CRLF
    cQuery += " WHERE P52.D_E_L_E_T_ = ' ' "  + CRLF
    cQuery += " AND P52_CC = '"+cConteudo+"' " + CRLF
    cQuery += " AND P52_ATIVO = '1' " + CRLF
    cQuery += " AND P52_FILCC <> '"+cConteudo+"' " + CRLF
    cQuery += " AND P52_FILCC <> ' ' " + CRLF
    
    DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "cAlias", .F., .T.)

    if cAlias->(!EoF())
        lRet := .T.
    endif

    cAlias->(DbCloseArea())
    FwRestArea(aArea)
Return lRet
