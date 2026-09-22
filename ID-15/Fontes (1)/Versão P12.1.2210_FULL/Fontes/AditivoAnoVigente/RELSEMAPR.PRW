#include "protheus.ch"

/*/{Protheus.doc} RELSEMAPR

Rotina para a geração do relatório de Solicitação de Pagamento Pendentes de Aprovação

@type function
@version  
@author Sato
@since 12/11/2024
@return variant, return_description
/*/
User Function RELSEMAPR()

Local oReport

oReport:= ReportDef()
oReport:PrintDialog()

Return




/*/{Protheus.doc} ReportDef

Função para a criação do componente de impressão

@type function
@version  
@author Sato
@since 12/11/2024
@return variant, return_description
/*/
Static Function ReportDef()

Local oReport
Local oSection




/*/{Protheus.doc} TReport():New

Criacao do componente de impressao

@author Sato
@since 12/11/2024
@param <cReport>, Caracter, Nome do relatório.
@param <cTitle>, Caracter, Título do relatório.
@param <uParam>, Caracter/Bloco de Código, Parâmetros do relatório cadastrado no Dicionário de Perguntas (SX1). Também pode ser utilizado bloco de código para parâmetros customizados.
@param <bAction>, Bloco de Código, Bloco de código que será executado quando o usuário confirmar a impressão do relatório.
@param <cDescription>, Caracter, Descrição do relatório.
@param <lLandscape>, Lógico, Aponta a orientação de página do relatório como paisagem.
@param <uTotalText>, Caracter/Bloco de Código, Texto do totalizador do relatório, podendo ser caracter ou bloco de código.
@param <lTotalInLine>, Lógico, Imprime as células em linha.
@param <cPageTText>, Caracter, Texto do totalizador da página.
@param <lPageTInLine>, Lógico, Imprime totalizador da página em linha.
@param <lTPageBreak>, Lógico, Quebra página após a impressão do totalizador.
@param <nColSpace>, Numérico, Espaçamento entre as colunas
@return Objeto, Objeto da classe TReport
/*/
oReport:= TReport():New("RELSEMAPR", OemToAnsi("Relatório de Solicitação de Pagamento Pendentes de Aprovação"), "RELSEMAPR", {|oReport| ReportPrint(oReport)}, OemToAnsi("Este relatório realiza a extração das Solicitação de Pagamento Pendentes de Aprovação"))

Pergunte("RELSEMAPR",.F.)

oReport:nfontbody := 10

/*/{Protheus.doc} TRSection():New

Criacao do componente de impressao

@author Sato
@since 12/11/2024

TRSection():New( <oParent> , <cTitle> , <uTable> , <aOrder> , <lLoadCells> , <lLoadOrder> , <uTotalText> , <lTotalInLine> , <lHeaderPage> , <lHeaderBreak> , <lPageBreak> , <lLineBreak> , <nLeftMargin> , <lLineStyle> , <nColSpace> , <lAutoSize> , <cCharSeparator> , <nLinesBefore> , <nCols> , <nClrBack> , <nClrFore> , <nPercentage> )

@param <oParent>, Objeto, Objeto da classe TReport ou TRSection que será o pai da classe TRSection. *** Obrigatório
@param <cTitle>, Caracter, Título da seção.
@param <uTable>, Caracter /, Tipo Caracter: Tabela que sera utilizada pela seção.
                 Array       Tipo Array: Lista de tabelas que serão utilizadas pela seção.
@param <aOrder>, Array, Array contendo a descrição das ordens. Elemento: 1-Descrição, como por exemplo, Filial+Código.
@param <lLoadCells>, Lógico, Carrega os campos do Dicionário de Campos (SX3) das tabelas da seção como células.
@param <lLoadOrder>, Lógico, Carrega os índices do Dicionário de Índices (SIX).
@param <uTotalText>, Caracter/Bloco de Código, Texto do totalizador da seção, podendo ser caracter ou bloco de código.
@param <lTotalInLine>, Lógico, Imprime as células em linha.
@param <lHeaderPage>, Lógico, Cabeçalho da seção no topo da página.
@param <lHeaderBreak>, Lógico, Imprime cabeçalho na quebra da seção.
@param <lPageBreak>, Lógico, Imprime cabeçalho da seção na quebra de página.
@param <lLineBreak>, Lógico, Quebra a linha na impressão quando as informações não couberem na página.
@param <nLeftMargin>, Numérico, Tamanho da margem à esquerda da seção.
@param <lLineStyle>, Lógico, Imprime a seção em linha.
@param <nColSpace>,  Numérico, Espaçamento entre as colunas.
@param <lAutoSize>, Lógico, Ajusta o tamanho das células para que caiba emu ma página.
@param <cCharSeparator>, Caracter, Define o caracter que separa as informações na impressão em linha.
@param <nLinesBefore>, Numérico, Aponta a quantidade de linhas a serem saltadas antes da impressão da seção.
@param <nCols>, Numérico, Quantidade de colunas a serem impressas.
@param <nClrBack>, Numérico, Cor de fundo das células da seção.
@param <nClrFore>, Numérico, Cor da fonte das células da seção.
@param <nPercentage>, Numérico, Tamanho da página a ser considerada na impressão em percentual.

@return Objeto, Objeto da classe TRSection
/*/
oSection := TRSection():New(oReport, OemToAnsi("Relatório de Solicitações de Pagamentos Pendentes de Arpovação"), {"TMPSC7","TMPSCR"}, /*{Array com as ordens do relatÃ³rio}*/, /*Campos do SX3*/, /*Campos do SIX*/)

oSection:SetHeaderPage()


/*/{Protheus.doc} TRCell():New

Criacao da celulas da secao do relatorio 

@author Sato
@since 12/11/2024

TRCell():New( <oParent> , <cName> , <cAlias> , <cTitle> , <cPicture> , <nSize> , <lPixel> , <bBlock> , <cAlign> , <lLineBreak> , <cHeaderAlign> , <lCellBreak> , <nColSpace> , <lAutoSize> , <nClrBack> , <nClrFore> , <lBold> ) 

@param <oParent>, Objeto, Objeto da classe TRSection que a célula pertence.
@param <cName>, Caracter, Nome da célula.
@param <cAlias>, Caracter, Tabela utilizada pela célula.
@param <cTitle>, Caracter, Título da célula.
@param <cPicture>, Caracter, Mascara da célula.
@param <nSize>, Numérico, Tamanho da célula.
@param <lPixel>, Lógico, Aponta se o tamanho foi informado em pixel.
@param <bBlock>, Bloco de Código, Bloco de código com o retorno do campo.
@param <cAlign>, Caracter, Alinhamento da célula. "LEFT", "RIGHT" e "CENTER".
@param <lLineBreak>, Lógico, Quebra linha se o conteúdo estourar o tamanho do campo.
@param <cHeaderAlign>, Caracter, Alinhamento do cabeçalho da célula. "LEFT", "RIGHT" e "CENTER".	
@param <lCellBreak>, Lógico, Compatibilidade – Não utilizado.
@param <nColSpace>, Numérico, Espaçamento entre as células.
@param <lAutoSize>, Lógico, Ajusta o tamanho da célula com base no tamanho da página e as informações impressas.
@param <nClrBack>, Numérico, Cor de fundo da célula.
@param <nClrFore>, Numérico, Cor da fonte da célula.
@param <lBold>, Lógico, Imprime a fonte em negrito.

@return Objeto, Objeto da classe TRCell
/*/
/*
TRCell():New(oSection,"C7_FILIAL"   ,"SC7" ,"Filial"                    , , TamSX3("Z7_FILIAL")[1], .T. ) 
TRCell():New(oSection,"M0_FILIAL"   ,"SM0" ,"Nome Filial"               , , 30, .T. ) 
TRCell():New(oSection,"CR_NIVEL"    ,"SCR" ,"Nível"                     , , TamSX3("CR_NIVEL")[1], .T. ) 
TRCell():New(oSection,"C7_XNOMFOR"  ,"SC7" ,"Fornecedor"                , , TamSX3("C7_XNOMFOR")[1], .T. ) 
TRCell():New(oSection,"C7_CC"       ,"SC7" ,"Centro de Custo"           , , TamSX3("C7_CC")[1], .T. ) 
TRCell():New(oSection,"CTT_DESC01"  ,"CTT" ,"DEscrição CC"              , , TamSX3("CTT_DESC01")[1], .T. ) 
TRCell():New(oSection,"C7_OBS"      ,"SC7" ,"Observaões"                , , TamSX3("C7_OBS")[1], .T. ) 
TRCell():New(oSection,"C7_NUM"      ,"SC7" ,"Número SP"                 , , TamSX3("C7_NUM")[1], .T. ) 
TRCell():New(oSection,"C7_XDOC"     ,"SC7" ,"Nota Fiscal"               , , TamSX3("C7_XDOC")[1], .T. ) 
TRCell():New(oSection,"C7_XSERIE"   ,"SC7" ,"Série"                     , , TamSX3("C7_XSERIE")[1], .T. ) 
TRCell():New(oSection,"C7_TOTAL"    ,"SC7" ,"Total"                     , , TamSX3("C7_TOTAL")[1], .T. ) 
TRCell():New(oSection,"F1_EMISSAO"  ,"SF1" ,"Data Emissão NF"           , , TamSX3("F1_EMISSAO")[1], .T. ) 
TRCell():New(oSection,"F1_XDTVNF"   ,"SF1" ,"Data Vencimento NF"        , , TamSX3("F1_XDTVNF")[1], .T. ) 
TRCell():New(oSection,"C7_EMISSAO"  ,"SC7" ,"Data Entrada"              , , TamSX3("C7_EMISSAO")[1], .T. ) 
TRCell():New(oSection,"C7_XUSR"     ,"SC7" ,"Cód. Usuário"              , , TamSX3("C7_XUSR")[1], .T. ) 
TRCell():New(oSection,"C7_XUSRSP"   ,"SC7" ,"Nome Usuário"              , , TamSX3("C7_XUSRSP")[1], .T. ) 
TRCell():New(oSection,"C7_XTIPO"    ,"SC7" ,"Grupo"                     , , TamSX3("C7_XTIPO")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME0"   ,"SCR" ,"Aprovador N00"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB0"   ,"SCR" ,"Data Aprovação N00"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME1"   ,"SCR" ,"Aprovador N01"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB1"   ,"SCR" ,"Data Aprovação N01"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME2"   ,"SCR" ,"Aprovador N02"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB2"   ,"SCR" ,"Data Aprovação N02"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME3"   ,"SCR" ,"Aprovador N03"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB3"   ,"SCR" ,"Data Aprovação N03"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME4"   ,"SCR" ,"Aprovador N04"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB4"   ,"SCR" ,"Data Aprovação N04"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME5"   ,"SCR" ,"Aprovador N05"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB5"   ,"SCR" ,"Data Aprovação N05"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME6"   ,"SCR" ,"Aprovador N06"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB6"   ,"SCR" ,"Data Aprovação N06"        , , TamSX3("CR_DATALIB")[1], .T. ) 
*/
TRCell():New(oSection,"C7_FILIAL"   ,"TMPSC7" ,"Filial"                    , , TamSX3("Z7_FILIAL")[1], .T. ) 
TRCell():New(oSection,"M0_FILIAL"   ,"TMPSC7" ,"Nome Filial"               , , 30, .T. ) 
TRCell():New(oSection,"CR_NIVEL"    ,"TMPSC7" ,"Nível"                     , , TamSX3("CR_NIVEL")[1], .T. ) 
TRCell():New(oSection,"C7_XNOMFOR"  ,"TMPSC7" ,"Fornecedor"                , , TamSX3("C7_XNOMFOR")[1], .T. ) 
TRCell():New(oSection,"C7_CC"       ,"TMPSC7" ,"Centro de Custo"           , , TamSX3("C7_CC")[1], .T. ) 
TRCell():New(oSection,"CTT_DESC01"  ,"TMPSC7" ,"Descrição CC"              , , TamSX3("CTT_DESC01")[1], .T. ) 
TRCell():New(oSection,"C7_OBS"      ,"TMPSC7" ,"Observaões"                , , TamSX3("C7_OBS")[1], .T. ) 
TRCell():New(oSection,"C7_NUM"      ,"TMPSC7" ,"Número SP"                 , , TamSX3("C7_NUM")[1], .T. ) 
TRCell():New(oSection,"C7_XDOC"     ,"TMPSC7" ,"Nota Fiscal"               , , TamSX3("C7_XDOC")[1], .T. ) 
TRCell():New(oSection,"C7_XSERIE"   ,"TMPSC7" ,"Série"                     , , TamSX3("C7_XSERIE")[1], .T. ) 
TRCell():New(oSection,"C7_TOTAL"    ,"TMPSC7" ,"Total"                     , , TamSX3("C7_TOTAL")[1], .T. ) 
TRCell():New(oSection,"F1_EMISSAO"  ,"TMPSC7" ,"Data Emissão NF"           , , TamSX3("F1_EMISSAO")[1], .T. ) 
TRCell():New(oSection,"F1_XDTVNF"   ,"TMPSC7" ,"Data Vencimento NF"        , , TamSX3("F1_XDTVNF")[1], .T. ) 
TRCell():New(oSection,"C7_EMISSAO"  ,"TMPSC7" ,"Data Entrada"              , , TamSX3("C7_EMISSAO")[1], .T. ) 
TRCell():New(oSection,"C7_XUSR"     ,"TMPSC7" ,"Cód. Usuário"              , , TamSX3("C7_XUSR")[1], .T. ) 
TRCell():New(oSection,"C7_XUSRSP"   ,"TMPSC7" ,"Nome Usuário"              , , TamSX3("C7_XUSRSP")[1], .T. ) 
TRCell():New(oSection,"C7_XTIPO"    ,"TMPSC7" ,"Tipo Requisição"           , , TamSX3("C7_XTIPO")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME0"   ,"TMPSCR" ,"Aprovador N00"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB0"   ,"TMPSCR" ,"Data Aprovação N00"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME1"   ,"TMPSCR" ,"Aprovador N01"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB1"   ,"TMPSCR" ,"Data Aprovação N01"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME2"   ,"TMPSCR" ,"Aprovador N02"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB2"   ,"TMPSCR" ,"Data Aprovação N02"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME3"   ,"TMPSCR" ,"Aprovador N03"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB3"   ,"TMPSCR" ,"Data Aprovação N03"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME4"   ,"TMPSCR" ,"Aprovador N04"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB4"   ,"TMPSCR" ,"Data Aprovação N04"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME5"   ,"TMPSCR" ,"Aprovador N05"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB5"   ,"TMPSCR" ,"Data Aprovação N05"        , , TamSX3("CR_DATALIB")[1], .T. ) 
TRCell():New(oSection,"CR_XNOME6"   ,"TMPSCR" ,"Aprovador N06"             , , TamSX3("CR_XNOME")[1], .T. ) 
TRCell():New(oSection,"CR_DTLIB6"   ,"TMPSCR" ,"Data Aprovação N06"        , , TamSX3("CR_DATALIB")[1], .T. ) 

Return(oReport)


/*/{Protheus.doc} ReportPrint

Função responsável pela impressão do Relatorio

@type function
@version  
@author Sato
@since 12/11/2024
@param oReport, object, param_description
@return variant, return_description
/*/
Static Function ReportPrint(oReport)

Local oSection  := oReport:Section(1)

Local cTmpSC7 as Character
Local cTmpSCR as Character
Local cQrySC7 as Character
Local cQrySCR as Character
Local aDados  as Array
Local cFilSol as Character
Local cSolPag as Character
Local nX      as Numeric
Local nCont   as Numeric
Local nLinha  as Numeric

aDados  := {}

cTmpSC7 := GetNextAlias()

cQrySC7 := "select c7_filial, "
cQrySC7 += "(select rtrim(m0_filial) from " + RetSqlName("SM0") + " where m0_codfil = c7_filial) as m0_filial, "
cQrySC7 += "(select max(cr_nivel) from " + RetSqlName("SCR") + " scr where cr_filial = c7_filial and cr_num = c7_num and cr_tipo = 'PC' and scr.d_e_l_e_t_= ' ' ) as nivel,
cQrySC7 += "c7_xnomfor, c7_cc, ctt_desc01, "

cQrySC7 += "(select cr_xnome from " + RetSqlName("SCR") + " nom0 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '00' and cr_tipo = 'PC' and rownum = 1 and nom0.d_e_l_e_t_= ' ' ) as cr_xnome0, "
cQrySC7 += "(select to_date(cr_datalib,'yyyy-mm-dd hh24:mi:ss') from " + RetSqlName("SCR") + " dat0 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '00' and cr_tipo = 'PC' and rownum = 1 and dat0.d_e_l_e_t_= ' ' ) as cr_dtlib0, "

cQrySC7 += "(select cr_xnome from " + RetSqlName("SCR") + " nom1 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '01' and cr_tipo = 'PC' and rownum = 1 and nom1.d_e_l_e_t_= ' ' ) as cr_xnome1, "
cQrySC7 += "(select to_date(cr_datalib,'yyyy-mm-dd hh24:mi:ss') from " + RetSqlName("SCR") + " dat1 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '01' and cr_tipo = 'PC' and rownum = 1 and dat1.d_e_l_e_t_= ' ' ) as cr_dtlib1, "

cQrySC7 += "(select cr_xnome from " + RetSqlName("SCR") + " nom2 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '02' and cr_tipo = 'PC' and rownum = 1 and nom2.d_e_l_e_t_= ' ' ) as cr_xnome2, "
cQrySC7 += "(select to_date(cr_datalib,'yyyy-mm-dd hh24:mi:ss') from " + RetSqlName("SCR") + " dat2 
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '02' and cr_tipo = 'PC' and rownum = 1 and dat2.d_e_l_e_t_= ' ' ) as cr_dtlib2, "

cQrySC7 += "(select cr_xnome from " + RetSqlName("SCR") + " nom3 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '03' and cr_tipo = 'PC' and rownum = 1 and nom3.d_e_l_e_t_= ' ' ) as cr_xnome3, "
cQrySC7 += "(select to_date(cr_datalib,'yyyy-mm-dd hh24:mi:ss') from " + RetSqlName("SCR") + " dat3 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '03' and cr_tipo = 'PC' and rownum = 1 and dat3.d_e_l_e_t_= ' ' ) as cr_dtlib3, "

cQrySC7 += "(select cr_xnome from " + RetSqlName("SCR") + " nom4 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '04' and cr_tipo = 'PC' and rownum = 1 and nom4.d_e_l_e_t_= ' ' ) as cr_xnome4, "
cQrySC7 += "(select to_date(cr_datalib,'yyyy-mm-dd hh24:mi:ss') from " + RetSqlName("SCR") + " dat4 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '04' and cr_tipo = 'PC' and rownum = 1 and dat4.d_e_l_e_t_= ' ' ) as cr_dtlib4, "

cQrySC7 += "(select cr_xnome from " + RetSqlName("SCR") + " nom5 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '05' and cr_tipo = 'PC' and rownum = 1 and nom5.d_e_l_e_t_= ' ' ) as cr_xnome5, "
cQrySC7 += "(select to_date(cr_datalib,'yyyy-mm-dd hh24:mi:ss') from " + RetSqlName("SCR") + " dat5 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '05' and cr_tipo = 'PC' and rownum = 1 and dat5.d_e_l_e_t_= ' ' ) as cr_dtlib5, "

cQrySC7 += "(select cr_xnome from " + RetSqlName("SCR") + " nom6 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '06' and cr_tipo = 'PC' and rownum = 1 and nom6.d_e_l_e_t_= ' ' ) as cr_xnome6, "
cQrySC7 += "(select to_date(cr_datalib,'yyyy-mm-dd hh24:mi:ss') from " + RetSqlName("SCR") + " dat6 "
cQrySC7 += "where cr_filial = c7_filial and cr_num = c7_num and cr_status = '03' and cr_nivel = '06' and cr_tipo = 'PC' and rownum = 1 and dat6.d_e_l_e_t_= ' ' ) as cr_dtlib6, "

cQrySC7 += "c7_obs, c7_xdoc, c7_xserie, c7_num, c7_total, "
cQrySC7 += "CASE when f1_emissao <> ' ' then to_date(f1_emissao,'yyyy-mm-dd hh24:mi:ss') else null END as f1_emissao, "
cQrySC7 += "CASE when f1_xdtvnf <> ' ' then to_date(f1_xdtvnf,'yyyy-mm-dd hh24:mi:ss') else null END as f1_xdtvnf, "
cQrySC7 += "to_date(c7_emissao,'yyyy-mm-dd hh24:mi:ss') as c7_emissao, "
cQrySC7 += "c7_xusr, c7_xusrsp, c7_xtipo "
//cQrySC7 += "CASE when cr_datalib <> ' ' then to_date(cr_datalib,'yyyy-mm-dd hh24:mi:ss') else null END  as  cr_datalib "
cQrySC7 += "from " + RetSqlName("SC7") + " sc7 "
cQrySC7 += "inner join " + RetSqlName("CTT") + " ctt on ctt_custo = c7_cc and ctt.d_e_l_e_t_= ' ' "
cQrySC7 += "left  join " + RetSqlName("SF1") + " sf1 on f1_filial = c7_filial and f1_doc = c7_xdoc and f1_serie = c7_xserie and f1_fornece = c7_fornece and f1_loja = c7_loja and sf1.d_e_l_e_t_= ' ' "
cQrySC7 += "where c7_xsolpag = '1' "
cQrySC7 += "and c7_conapro = 'B' "
cQrySC7 += "and c7_quje < c7_quant "

If (!EMPTY(mv_par01) .and. !EMPTY(mv_par02)) .and. (mv_par02 >= mv_par01)
   cQrySC7 += "and c7_emissao >= '"+ DTOS(mv_par01) +"' "
   cQrySC7 += "and c7_emissao <= '"+ DTOS(mv_par02) +"' "
Else
   cQrySC7 += "and c7_emissao >= '20240101' "      // 01/01/2024 - Data utilizada como Data de Corte
EndIf

If !EMPTY(mv_par04)
   cQrySC7 += "and c7_xtipo >= '"+ mv_par03 +"' "
   cQrySC7 += "and c7_xtipo <= '"+ mv_par04 +"' "
EndIf

cQrySC7 += "and sc7.d_e_l_e_t_= ' ' "
cQrySC7 += "order by c7_filial,c7_num"

cQrySC7 := ChangeQuery(cQrySC7)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySC7),cTmpSC7)

DbSelectArea(cTmpSC7)
(cTmpSC7)->(DbGoTop())

cFilSol := ""
cSolPag := ""
nLinha  := 1

While !(cTmpSC7)->(EOF())
   If oReport:Cancel()
      Exit
   EndIf

   oReport:IncMeter()

   cTmpSCR := GetNextAlias()

   cQrySCR := "select cr_filial, cr_num, cr_nivel, cr_status, cr_xnome "
   cQrySCR += "from " + RetSqlName("SCR") + " scr "
   cQrySCr += "where cr_filial = '" + (cTmpSC7)->C7_FILIAL + "'
   cQrySCr += "and cr_num = '" + (cTmpSC7)->C7_NUM + "'
   cQrySCr += "and cr_status = '02'
   cQrySCr += "and scr.d_e_l_e_t_= ' ' "

   cQrySCr := ChangeQuery(cQrySCr)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySCr),cTmpSCR)

   DbSelectArea(cTmpSCR)
   (cTmpSCR)->(DbGoTop())

   nCont := 1

   If cFilSol <> (cTmpSC7)->C7_FILIAL .or. cSolPag <> (cTmpSC7)->C7_NUM
      AADD(aDados, { (cTmpSC7)->C7_FILIAL,; 
					      (cTmpSC7)->M0_FILIAL,; 
                     (cTmpSC7)->NIVEL,;
                     (cTmpSC7)->C7_XNOMFOR,;
                     (cTmpSC7)->C7_CC,;
                     (cTmpSC7)->CTT_DESC01,;
                     (cTmpSC7)->C7_OBS,;
                     (cTmpSC7)->C7_NUM,;
                     (cTmpSC7)->C7_XDOC,;
                     (cTmpSC7)->C7_XSERIE,;
                     (cTmpSC7)->C7_TOTAL,;
                     (cTmpSC7)->F1_EMISSAO,;
                     (cTmpSC7)->F1_XDTVNF,;
                     (cTmpSC7)->C7_EMISSAO,;
                     (cTmpSC7)->C7_XUSR,;
                     (cTmpSC7)->C7_XUSRSP,;
                     (cTmpSC7)->C7_XTIPO,;
                     (cTmpSC7)->CR_XNOME0,;
                     (cTmpSC7)->CR_DTLIB0,;
                     (cTmpSC7)->CR_XNOME1,;
                     (cTmpSC7)->CR_DTLIB1,;
                     (cTmpSC7)->CR_XNOME2,;
                     (cTmpSC7)->CR_DTLIB2,;
                     (cTmpSC7)->CR_XNOME3,;
                     (cTmpSC7)->CR_DTLIB3,;
                     (cTmpSC7)->CR_XNOME4,;
                     (cTmpSC7)->CR_DTLIB4,;
                     (cTmpSC7)->CR_XNOME5,;
                     (cTmpSC7)->CR_DTLIB5,;
                     (cTmpSC7)->CR_XNOME6,;
                     (cTmpSC7)->CR_DTLIB6;
				   })

      While !(cTmpSCR)->(EOF())
         If nCont == 1
            DO CASE
               CASE (cTmpSCR)->CR_NIVEL == '00'
                     aDados[nLinha][18] := (cTmpSCR)->CR_XNOME
               CASE (cTmpSCR)->CR_NIVEL == '01'
                     aDados[nLinha][20] := (cTmpSCR)->CR_XNOME
               CASE (cTmpSCR)->CR_NIVEL == '02'
                     aDados[nLinha][22] := (cTmpSCR)->CR_XNOME
               CASE (cTmpSCR)->CR_NIVEL == '03'
                     aDados[nLinha][24] := (cTmpSCR)->CR_XNOME
               CASE (cTmpSCR)->CR_NIVEL == '04'
                     aDados[nLinha][26] := (cTmpSCR)->CR_XNOME
               CASE (cTmpSCR)->CR_NIVEL == '05'
                     aDados[nLinha][28] := (cTmpSCR)->CR_XNOME
               CASE (cTmpSCR)->CR_NIVEL == '06'
                     aDados[nLinha][30] := (cTmpSCR)->CR_XNOME
            ENDCASE
            nCont++
         Else
            AADD(aDados, { "",; 
                           "",; 
                           "",;
                           "",;
                           "",;
                           "",;
                           "",;
                           "",;
                           "",;
                           "",;
                           0,;
                           "",;
                           "",;
                           "",;
                           "",;
                           "",;
                           (cTmpSC7)->C7_XTIPO,;
                           IIf((cTmpSCR)->CR_NIVEL == '00', (cTmpSCR)->CR_XNOME, ""),;
                           "",;
                           IIf((cTmpSCR)->CR_NIVEL == '01', (cTmpSCR)->CR_XNOME, ""),;
                           "",;
                           IIf((cTmpSCR)->CR_NIVEL == '02', (cTmpSCR)->CR_XNOME, ""),;
                           "",;
                           IIf((cTmpSCR)->CR_NIVEL == '03', (cTmpSCR)->CR_XNOME, ""),;
                           "",;
                           IIf((cTmpSCR)->CR_NIVEL == '04', (cTmpSCR)->CR_XNOME, ""),;
                           "",;
                           IIf((cTmpSCR)->CR_NIVEL == '05', (cTmpSCR)->CR_XNOME, ""),;
                           "",;
                           IIf((cTmpSCR)->CR_NIVEL == '06', (cTmpSCR)->CR_XNOME, ""),;
                           "";
                     })

         EndIf
         
         nLinha++

         (cTmpSCR)->( DbSkip() )

      End

      (cTmpSCR)->( DbCloseArea() )

   EndIf

   cFilSol := (cTmpSC7)->C7_FILIAL
   cSolPag := (cTmpSC7)->C7_NUM

   (cTmpSC7)->( DbSkip() )
End

(cTmpSC7)->( DbCloseArea() )

If !(EMPTY(aDados))
   oReport:SetMeter(Len(aDados))
   oReport:IncMeter()
   For nX := 1 To Len(aDados)

      If oReport:Cancel()
         Exit
      EndIf

      oSection:Init()
		oReport:IncMeter()

      oSection:cell("C7_FILIAL"):SetValue(ALLTRIM(aDados[nX][1]))
      oSection:cell("M0_FILIAL"):SetValue(ALLTRIM(aDados[nX][2]))
      oSection:cell("CR_NIVEL"):SetValue(aDados[nX][3])
      oSection:cell("C7_XNOMFOR"):SetValue(aDados[nX][4])
      oSection:cell("C7_CC"):SetValue(aDados[nX][5])
      oSection:cell("CTT_DESC01"):SetValue(aDados[nX][6])
      oSection:cell("C7_OBS"):SetValue(aDados[nX][7])
      oSection:cell("C7_NUM"):SetValue(aDados[nX][8])
      oSection:cell("C7_XDOC"):SetValue(aDados[nX][9])
      oSection:cell("C7_XSERIE"):SetValue(aDados[nX][10])
      oSection:cell("C7_TOTAL"):SetValue(aDados[nX][11])
      oSection:cell("F1_EMISSAO"):SetValue(aDados[nX][12])
      oSection:cell("F1_XDTVNF"):SetValue(aDados[nX][13])
      oSection:cell("C7_EMISSAO"):SetValue(aDados[nX][14])
      oSection:cell("C7_XUSR"):SetValue(aDados[nX][15])
      oSection:cell("C7_XUSRSP"):SetValue(ALLTRIM(aDados[nX][16]))
      oSection:cell("C7_XTIPO"):SetValue(aDados[nX][17])

      oSection:cell("CR_XNOME0"):SetValue(aDados[nX][18])
      oSection:cell("CR_DTLIB0"):SetValue(aDados[nX][19])
      oSection:cell("CR_XNOME1"):SetValue(aDados[nX][20])
      oSection:cell("CR_DTLIB1"):SetValue(aDados[nX][21])
      oSection:cell("CR_XNOME2"):SetValue(aDados[nX][22])
      oSection:cell("CR_DTLIB2"):SetValue(aDados[nX][23])
      oSection:cell("CR_XNOME3"):SetValue(aDados[nX][24])
      oSection:cell("CR_DTLIB3"):SetValue(aDados[nX][25])
      oSection:cell("CR_XNOME4"):SetValue(aDados[nX][26])
      oSection:cell("CR_DTLIB4"):SetValue(aDados[nX][27])
      oSection:cell("CR_XNOME5"):SetValue(aDados[nX][28])
      oSection:cell("CR_DTLIB5"):SetValue(aDados[nX][29])
      oSection:cell("CR_XNOME6"):SetValue(aDados[nX][30])
      oSection:cell("CR_DTLIB6"):SetValue(aDados[nX][31])

      oSection:PrintLine()
   Next nX
EndIf
oSection:Finish()

Return NIL

