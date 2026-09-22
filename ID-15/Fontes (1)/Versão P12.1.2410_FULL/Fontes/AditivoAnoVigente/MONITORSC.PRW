#Include "Protheus.ch"
#Include "Fwmvcdef.ch"

#DEFINE CRLF Chr(13)+Chr(10)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MONITORSC

Rotina para realizar o monitoramento das Solicitações de Compras Pendentes

@type function
@version   
@author Sato
@since 23/06/2025
@return variant, return_description
/*/
//------------------------------------------------------------------------------
User Function MONITORSC()

Local aArea     as Array
Local oBrowse   as Object
Local aCampos   as Array
Local aColunas  as Array
Local aPesquisa as Array
Local aFiltros  as Array
Local cAliasTmp as Character
Local cTitulo   as Character

//Private aRotina   as Array
//Private cAliasTmp as Character

aArea     := FWGetArea()

aCampos   := {}
aColunas  := {}
aPesquisa := {}
aFiltros  := {}
cAliasTmp := GetNextAlias()
cTitulo   := "Monitor de SC Pendentes"


//--------------------------
// Monta os campos da tabela temporária
//--------------------------
aAdd( aCampos, {"TMP_STATUS" , "N",  1, 0} )
aAdd( aCampos, {"TMP_FILIAL" , "C",  8, 0} )
aAdd( aCampos, {"TMP_NOMFIL" , "C", 41, 0} )
aAdd( aCampos, {"TMP_NUM"    , "C",  6, 0} )
aAdd( aCampos, {"TMP_IDPLAN" , "C", 20, 0} )
aAdd( aCampos, {"TMP_TOTITE" , "N",  3, 0} )
aAdd( aCampos, {"TMP_ITENSP" , "N",  3, 0} )
aAdd( aCampos, {"TMP_TPSC"   , "C",  2, 0} )
aAdd( aCampos, {"TMP_DSCTIP" , "C", 55, 0} )
aAdd( aCampos, {"TMP_MOTIVO" , "C",  2, 0} )
aAdd( aCampos, {"TMP_DSCMOT" , "C", 55, 0} )
aAdd( aCampos, {"TMP_GRPCOM" , "C",  6, 0} )
aAdd( aCampos, {"TMP_DSCGRP" , "C", 40, 0} )
aAdd( aCampos, {"TMP_IDBIO"  , "C",  9, 0} )
//aAdd( aCampos, {"TMP_EMISSA" , "C", 10, 0} )
aAdd( aCampos, {"TMP_EMISSA" , "D",  8, 0} )
aAdd( aCampos, {"TMP_QTDDIA" , "N",  5, 0} )
aAdd( aCampos, {"TMP_USR"    , "C",  6, 0} )
aAdd( aCampos, {"TMP_NOMSOL" , "C", 40, 0} )
aAdd( aCampos, {"TMP_PCS"    , "C",  1, 0} )

//--------------------------
// Monta os campos a serem utilizados no Filtro
//--------------------------
aAdd( aFiltros, { "TMP_FILIAL" , "Filial",          "C",  8, 0, "@!"})
aAdd( aFiltros, { "TMP_NUM"    , "Número SC",       "C",  6, 0, "@!"})
aAdd( aFiltros, { "TMP_IDPLAN" , "Id Planexo",      "C", 20, 0, "@!"})
aAdd( aFiltros, { "TMP_TOTITE" , "Total Itens",     "N",  3, 0, "999"})
aAdd( aFiltros, { "TMP_ITENSP" , "Itens Pendentes", "N",  3, 0, "999"})
aAdd( aFiltros, { "TMP_TPSC"   , "Tipo",            "C",  2, 0, "@!"})
aAdd( aFiltros, { "TMP_DSCTIP" , "Desc. Tipo",      "C", 55, 0, "@!"})
aAdd( aFiltros, { "TMP_MOTIVO" , "Motivo",          "C",  2, 0, "@!"})
aAdd( aFiltros, { "TMP_DSCMOT" , "Desc. Motivo",    "C", 55, 0, "@!"})
aAdd( aFiltros, { "TMP_GRPCOM" , "Grupo",           "C",  6, 0, "@!"})
aAdd( aFiltros, { "TMP_DSCGRP" , "Desc. Grupo",     "C", 40, 0, "@!"})
aAdd( aFiltros, { "TMP_IDBIO"  , "Id Bionexo",      "C",  9, 0, "@!"})
//aAdd( aFiltros, { "TMP_EMISSA" , "Dt. Emissão",     "C", 10, 0, "@!"})
aAdd( aFiltros, { "TMP_EMISSA" , "Data Emissão",    "D",  8, 0, })
aAdd( aFiltros, { "TMP_QTDDIA" , "Qtd. Dias",       "N",  5, 0, "99999"})
aAdd( aFiltros, { "TMP_USR"    , "Solicitante",     "C",  6, 0, "@!"})
aAdd( aFiltros, { "TMP_NOMSOL" , "Nome Solic.",     "C", 40, 0, "@!"})
aAdd( aFiltros, { "TMP_PCS"    , "PCS",             "C",  1, 0, "@!"})

//--------------------------
// Cria a tabela temporária
//--------------------------
oTempTable := FWTemporaryTable():New(cAliasTmp)
oTempTable:SetFields(aCampos)
oTempTable:AddIndex("1", {"TMP_FILIAL","TMP_NUM"} )
oTempTable:AddIndex("2", {"TMP_TPSC"} )
oTempTable:AddIndex("3", {"TMP_MOTIVO"} )
oTempTable:AddIndex("4", {"TMP_GRPCOM"} )
oTempTable:AddIndex("5", {"TMP_PCS"} )
oTempTable:Create()


//--------------------------
// Definindo as colunas que serÃ£o usadas no browse
//--------------------------
/*
Estrutura do array
TABELA DE DADOS
[n][01] Título da coluna
[n][02] Code-Block de carga dos dados
[n][03] Tipo de dados
[n][04] Máscara
[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
[n][06] Tamanho
[n][07] Decimal
[n][08] Indica se permite a edição
[n][09] Code-Block de validação da coluna após a edição
[n][10] Indica se exibe imagem
[n][11] Code-Block de execução do duplo clique
[n][12] Variável a ser utilizada na edição (ReadVar)
[n][13] Code-Block de execução do clique no header
[n][14] Indica se a coluna está deletada
[n][15] Indica se a coluna será exibida nos detalhes do Browse
[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
TABELA TEMPORÁRIA
[n][01] Descrição do campo
[n][02] Nome do campo
[n][03] Tipo
[n][04] Tamanho
[n][05] Decimal
[n][06] Picture	
*/
aAdd(aColunas, {"Filial",          "TMP_FILIAL" , "C",  5, 0, "@!"})
aAdd(aColunas, {"Desc. Filial",    "TMP_NOMFIL" , "C", 20, 0, "@!"})
aAdd(aColunas, {"Número SC",       "TMP_NUM"    , "C",  3, 0, "@!"})
aAdd(aColunas, {"Id Planexo",      "TMP_IDPLAN" , "C", 10, 0, "@!"})
aAdd(aColunas, {"Total Itens",     "TMP_TOTITE" , "N",  3, 0, "@9"})
aAdd(aColunas, {"Itens Pendentes", "TMP_ITENSP" , "N",  3, 0, "@9"})
aAdd(aColunas, {"Tipo",            "TMP_TPSC"   , "C",  3, 0, "@!"})
aAdd(aColunas, {"Desc. Tipo",      "TMP_DSCTIP" , "C", 20, 0, "@!"})
aAdd(aColunas, {"Motivo",          "TMP_MOTIVO" , "C",  3, 0, "@!"})
aAdd(aColunas, {"Desc. Motivo",    "TMP_DSCMOT" , "C", 20, 0, "@!"})
aAdd(aColunas, {"Grupo",           "TMP_GRPCOM" , "C",  3, 0, "@!"})
aAdd(aColunas, {"Desc. Grupo",     "TMP_DSCGRP" , "C", 20, 0, "@!"})
aAdd(aColunas, {"Id Bionexo",      "TMP_IDBIO"  , "C",  3, 0, "@!"})
//aAdd(aColunas, {"Dt. Emissão",     "TMP_EMISSA" , "C",  8, 0, "@!"})
aAdd(aColunas, {"Data Emissão",    "TMP_EMISSA" , "D",  8, 0, })
aAdd(aColunas, {"Qtd. Dias",       "TMP_QTDDIA" , "N",  3, 0, "@9"})
aAdd(aColunas, {"Solicitante",     "TMP_USR"    , "C",  3, 0, "@!"})
aAdd(aColunas, {"Nome Solic.",     "TMP_NOMSOL" , "C",  5, 0, "@!"})
aAdd(aColunas, {"PCS",             "TMP_PCS"    , "C",  1, 0, "@!"})


//--------------------------
// Adiciona os indices para pesquisar
//--------------------------
/*
    [n,1] Título da pesquisa
    [n,2,1] LookUp
    [n,2,2] Tipo de dados
    [n,2,3] Tamanho
    [n,2,4] Decimal
    [n,2,5] Título do campo
    [n,2,6] Máscara
    [n,3] Ordem da pesquisa
    [n,4] Exibe na pesquisa
*/
aAdd(aPesquisa, {"Filial+Numero SC", {{"", "C", 14, 0, "Filial+Numero SC", "@!"}} } )
aAdd(aPesquisa, {"Tipo", {{"", "C", 3, 0, "Tipo", "@!"}} } )
aAdd(aPesquisa, {"Motivo", {{"", "C", 3, 0, "Motivo", "@!"}} } )
aAdd(aPesquisa, {"Grupo", {{"", "C", 3, 0, "Grupo", "@!"}} } )
aAdd(aPesquisa, {"PCS", {{"", "C", 1, 0, "PCS", "@!"}} } )



//--------------------------
// Populando tabela temporária
//--------------------------
//PopulaTmp(cAliasTmp)
FWMsgRun(, { |oSay| PopulaTmp(oSay, cAliasTmp) }, "Carregando", "Carregando tabela das SC pendentes...")


//--------------------------
// Criando o browse da tabela temporária
//--------------------------
oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cAliasTmp)
oBrowse:SetTemporary(.T.)
oBrowse:SetFields(aColunas)
oBrowse:DisableDetails()
oBrowse:SetDescription(cTitulo)
oBrowse:SetSeek(.T., aPesquisa)
oBrowse:SetFieldFilter(aFiltros)
oBrowse:SetUseFilter(.T.)


//--------------------------
// Adiciona legenda no Browse
//--------------------------
oBrowse:AddLegend('TMP_STATUS == 1', "RED"   , "Emergencial")
oBrowse:AddLegend('TMP_STATUS == 2', "PINK"  , "Cotação Bionexo")
oBrowse:AddLegend('TMP_STATUS == 3', "BLUE"  , "Reservado Schedule")
oBrowse:AddLegend('TMP_STATUS == 4', "LBLUE" , "Reservado Usuário")
oBrowse:AddLegend('TMP_STATUS == 5', "YELLOW", "Parcialmente Pendente")
oBrowse:AddLegend('TMP_STATUS == 6', "GREEN" , "Totalmento Pendente")

oBrowse:Activate()

oTempTable:Delete()

FWRestArea(aArea)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} PopulaTmp

Rotina responsável por popular a tbela temporaria

@type function
@version  
@author Sato
@since 10/07/2025
@param oSay, object, param_description
@param cAliasTmp, character, param_description
@return variant, return_description
/*/
//------------------------------------------------------------------------------
Static Function PopulaTmp(oSay as Object, cAliasTmp as Character)

Local cQuery as Character

Default cAliasTmp := ""

//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
cQuery := "select c1_filial, " + CRLF
cQuery += "       (select rtrim(m0_filial) from protheus_12.sys_company where  m0_codfil = c1_filial) as m0_filial, " + CRLF
cQuery += "       c1_num, "  + CRLF
cQuery += "       c1_xidplan, " + CRLF
cQuery += "       (select count(*) from " + RetSqlName("SC1") + " A where A.c1_filial = sc1.c1_filial " + CRLF
cQuery += "               and A.c1_num = sc1.c1_num and A.d_e_l_e_t_ = ' ' ) as TOTAL, " + CRLF
cQuery += "       (select count(*) from " + RetSqlName("SC1") + " B where B.c1_filial = sc1.c1_filial " + CRLF
cQuery += "               and B.c1_num = sc1.c1_num and B.c1_quje < B.c1_quant and B.d_e_l_e_t_ = ' ' ) as ITENS, " + CRLF
cQuery += "       c1_xtpsc, " + CRLF
cQuery += "       RTRIM(sx51.x5_descri) as TIPO, " + CRLF
cQuery += "       c1_xmotivo, " + CRLF
cQuery += "       RTRIM(sx52.x5_descri) as MOTIVO, " + CRLF
//cQuery += "       case c1_grupcom when ' ' then ' ' else RTRIM(c1_grupcom||' - '||saj.aj_xdescri) " + 'end as "GRUPO COMPRAS", ' + CRLF
cQuery += "       case c1_grupcom when ' ' then ' ' else c1_grupcom end as c1_grupcom, " + CRLF
cQuery += "       case c1_grupcom when ' ' then ' ' else RTRIM(saj.aj_xdescri) end as aj_xdescri, " + CRLF
cQuery += "       C1_XIDBIO, " + CRLF
cQuery += "       C1_XNUMMED, " + CRLF
//cQuery += "       TO_DATE(C1_EMISSAO,'yyyy-mm-dd hh24:mi:ss') as C1_EMISSAO, " + CRLF
cQuery += "       C1_EMISSAO, " + CRLF
cQuery += "       trunc(SYSDATE - TO_DATE(C1_EMISSAO, 'YYYYMMDD')) as DIAS, " + CRLF
cQuery += "       C1_USER, " + CRLF
cQuery += "       USR.USR_NOME,  " + CRLF
cQuery += "       PRF.USR_GRUPO  " + CRLF
cQuery += "   from " + RetSqlName("SC1") + " sc1 " + CRLF
cQuery += "      left join " + RetSqlName("SX5") + " sx51 on sx51.x5_tabela = 'ZX' and sx51.x5_chave = c1_xtpsc and sx51.d_e_l_e_t_ = ' ' " + CRLF
cQuery += "      left join " + RetSqlName("SX5") + " sx52 on sx52.x5_tabela = 'ZZ' and sx52.x5_chave = c1_xmotivo and sx52.d_e_l_e_t_ = ' ' " + CRLF
cQuery += "      left join " + RetSqlName("SAJ") + " saj  on saj.aj_filial = c1_filial and saj.aj_grcom = c1_grupcom and saj.d_e_l_e_t_ = ' ' " + CRLF
cQuery += "      left join protheus_12.sys_usr usr on usr_id = c1_user and usr.d_e_l_e_t_ = ' ' " + CRLF
cQuery += "      left join protheus_12.sys_usr_groups prf on prf.usr_id = c1_user and (prf.usr_grupo = '000092' or prf.usr_grupo = '000567') and prf.d_e_l_e_t_ = ' ' " + CRLF
/*/ SOMENTE PARA TESTE /*/
cQuery += "   where c1_filial = '01310001' " + CRLF
cQuery += "     and c1_pedido = ' ' " + CRLF

//cQuery += "   where c1_pedido = ' ' " + CRLF
cQuery += "     and c1_residuo = ' ' " + CRLF
cQuery += "     and c1_aprov = 'L' " + CRLF
cQuery += "     and sc1.d_e_l_e_t_ = ' ' " + CRLF
cQuery += "   group by C1_FILIAL, 'M0_FILIAL', C1_NUM, C1_XIDPLAN, 'TOTAL', 'ITENS', " + CRLF
cQuery += "            c1_xtpsc, " + CRLF
cQuery += "            RTRIM(sx51.x5_descri), " + CRLF
cQuery += "            c1_xmotivo, " + CRLF
cQuery += "            RTRIM(sx52.x5_descri), " + CRLF
//cQuery += "            case c1_grupcom when ' ' then ' ' else RTRIM(c1_grupcom||' - '||saj.aj_xdescri) end, " + CRLF
cQuery += "            case c1_grupcom when ' ' then ' ' else c1_grupcom end, " + CRLF
cQuery += "            case c1_grupcom when ' ' then ' ' else RTRIM(saj.aj_xdescri) end, " + CRLF
cQuery += "            C1_XIDBIO, C1_XNUMMED, C1_EMISSAO, C1_USER, USR.USR_NOME, PRF.USR_GRUPO  " + CRLF
cQuery += "   order by c1_filial, c1_num"

cQuery := ChangeQuery(cQuery)

MPSysOpenQuery( cQuery, 'QRYTMP' )

dbSelectArea('QRYTMP')
QRYTMP->( dbGoTOP() )
IF QRYTMP->( !EOF() )
    Do While QRYTMP->( !EOF() )
        (cAliasTmp)->( RecLock(cAliasTmp, .T.) )
            
            Do Case
                Case QRYTMP->C1_XTPSC == '02' .or. QRYTMP->C1_XMOTIVO =  '13'
                    (cAliasTmp)->TMP_STATUS   := 1
                Case QRYTMP->C1_XIDBIO <> ' ' 
                    (cAliasTmp)->TMP_STATUS   := 2
                Case QRYTMP->C1_XNUMMED == 'ZZZZZZ' 
                    (cAliasTmp)->TMP_STATUS   := 3
                Case QRYTMP->C1_XNUMMED == 'XXXXXX' 
                    (cAliasTmp)->TMP_STATUS   := 4
                Case QRYTMP->TOTAL <> QRYTMP->ITENS
                    (cAliasTmp)->TMP_STATUS   := 5
                Case QRYTMP->TOTAL == QRYTMP->ITENS
                    (cAliasTmp)->TMP_STATUS   := 6
            EndCase
            
            (cAliasTmp)->TMP_FILIAL := QRYTMP->C1_FILIAL
            (cAliasTmp)->TMP_NOMFIL := QRYTMP->M0_FILIAL
            (cAliasTmp)->TMP_NUM    := QRYTMP->C1_NUM
            (cAliasTmp)->TMP_IDPLAN := QRYTMP->C1_XIDPLAN
            (cAliasTmp)->TMP_TOTITE := QRYTMP->TOTAL
            (cAliasTmp)->TMP_ITENSP := QRYTMP->ITENS
            (cAliasTmp)->TMP_TPSC   := QRYTMP->C1_XTPSC
            (cAliasTmp)->TMP_DSCTIP := QRYTMP->TIPO
            (cAliasTmp)->TMP_MOTIVO := QRYTMP->C1_XMOTIVO
            (cAliasTmp)->TMP_DSCMOT := QRYTMP->MOTIVO
            (cAliasTmp)->TMP_GRPCOM := QRYTMP->C1_GRUPCOM
            (cAliasTmp)->TMP_DSCGRP := QRYTMP->AJ_XDESCRI
            (cAliasTmp)->TMP_IDBIO  := QRYTMP->C1_XIDBIO
            (cAliasTmp)->TMP_USR    := QRYTMP->C1_USER
            //(cAliasTmp)->TMP_EMISSA := DtoC(QRYTMP->C1_EMISSAO)
            (cAliasTmp)->TMP_EMISSA := StoD(QRYTMP->C1_EMISSAO)
            (cAliasTmp)->TMP_QTDDIA := QRYTMP->DIAS
            (cAliasTmp)->TMP_NOMSOL := QRYTMP->USR_NOME
            If QRYTMP->USR_GRUPO = '000092' .or. QRYTMP->USR_GRUPO = '000567'
                (cAliasTmp)->TMP_PCS := 'S'
            Else
                (cAliasTmp)->TMP_PCS := 'N'
            EndIf

        (cAliasTmp)->( MsUnlock() )

        QRYTMP->( dbSkip() )
    End
EndIf

QRYTMP->( dbCloseArea() )

Return .T.
