#include 'protheus.ch'

/*/{Protheus.doc} RELFRMDEL

Rotina para a gera��o da relacao dos Formul�rios de Compras Delegada

@type function
@version  
@author Sato
@since 24/09/2024
@return variant, return_description
/*/
User Function RELFRMDEL()

Local oReport

oReport:= ReportDef()
oReport:PrintDialog()

Return



/*/{Protheus.doc} ReportDef

Fun��o para a cria��o do componente de impress�o

@type function
@version  
@author Sato
@since 24/09/2024
@return variant, return_description
/*/
Static Function ReportDef()

Local oReport
Local oSection

/*/{Protheus.doc} TReport():New

Criacao do componente de impressao

@author Sato
@since 24/09/2024
@param <cReport>, Caracter, Nome do relat�rio.
@param <cTitle>, Caracter, T�tulo do relat�rio.
@param <uParam>, Caracter/Bloco de C�digo, Par�metros do relat�rio cadastrado no Dicion�rio de Perguntas (SX1). Tamb�m pode ser utilizado bloco de c�digo para par�metros customizados.
@param <bAction>, Bloco de C�digo, Bloco de c�digo que ser� executado quando o usu�rio confirmar a impress�o do relat�rio.
@param <cDescription>, Caracter, Descri��o do relat�rio.
@param <lLandscape>, L�gico, Aponta a orienta��o de p�gina do relat�rio como paisagem.
@param <uTotalText>, Caracter/Bloco de C�digo, Texto do totalizador do relat�rio, podendo ser caracter ou bloco de c�digo.
@param <lTotalInLine>, L�gico, Imprime as c�lulas em linha.
@param <cPageTText>, Caracter, Texto do totalizador da p�gina.
@param <lPageTInLine>, L�gico, Imprime totalizador da p�gina em linha.
@param <lTPageBreak>, L�gico, Quebra p�gina ap�s a impress�o do totalizador.
@param <nColSpace>, Num�rico, Espa�amento entre as colunas
@return Objeto, Objeto da classe TReport
/*/
oReport:= TReport():New("RELFRMDEL", OemToAnsi("Formul�rio de Compras Delegada"), "RELFRMDEL", {|oReport| ReportPrint(oReport)}, OemToAnsi("Este relat�rio extrai uma rela��o dos Formul�rios de Compras Delegada"))

Pergunte("RELFRMDEL",.F.)

//Parametriza o TReport para alinhamento a direita 
//oReport:SetRightAlignPrinter(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection := TRSection():New(oReport, OemToAnsi("Formul�rio de Compras Delegada"), {"TMPSZ7"}, /*{Array com as ordens do relatório}*/, /*Campos do SX3*/, /*Campos do SIX*/)

oSection:SetHeaderPage()


// TRCell():New( /*<oParent>*/, /*<cName>*/, /*<cAlias>*/, /*<cTitle>*/, /*<cPicture>*/, /*<nSize>*/, /*<lPixel>*/, /*<bBlock>*/, /*<cAlign>*/, /*<lLineBreak>*/, /*<cHeaderAlign>*/, /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ )  
TRCell():New(oSection,"Z7_FILIAL"   ,"TMPSZ7" ,"Filial"                    ,                          , TamSX3("Z7_FILIAL")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"M0_FILIAL"   ,"TMPSZ7" ,"Nome Filial"               ,                          , 30, /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_NUMFOR"   ,"TMPSZ7" ,"Formulario"                ,                          , TamSX3("Z7_NUMFOR")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"RA_MAT"      ,"TMPSZ7" ,"Mat Comprador"             ,                          , TamSX3("RA_MAT")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"USR_CODIGO"  ,"TMPSZ7" ,"CPF Comprador"             ,PesqPict("SRA","RA_CIC")  , TamSX3("RA_CIC")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"C7_XNOMECO"  ,"TMPSZ7" ,"Comprador"                 ,                          , TamSX3("C7_XNOMECO")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_NUMPC"    ,"TMPSZ7" ,"Pedido"                    ,                          , TamSX3("Z7_NUMPC")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"C7_EMISSAO"  ,"TMPSZ7" ,"Emissao"                   ,                          , TamSX3("C7_EMISSAO")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"C7_TOTAL"    ,"TMPSZ7" ,"Total"                     ,PesqPict("SC7","C7_TOTAL"), TamSX3("C7_TOTAL")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_MAT"      ,"TMPSZ7" ,"Mat Demandante"            ,                          , TamSX3("Z7_MAT")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"RA_CIC"      ,"TMPSZ7" ,"CPF Demandante"            ,                          , TamSX3("RA_CIC")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_NOME"     ,"TMPSZ7" ,"Demandante"                ,                          , TamSX3("Z7_NOME")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"C7_FORNECE"  ,"TMPSZ7" ,"Cod Fornecedor"            ,                          , TamSX3("C7_FORNECE")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"C7_LOJA"     ,"TMPSZ7" ,"Loja Fornecedor"           ,                          , TamSX3("C7_LOJA")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"C7_XNOMFOR"  ,"TMPSZ7" ,"Fornecedor"                ,                          , TamSX3("C7_XNOMFOR")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"CR_NIVEL1"   ,"TMPSZ7" ,"Primeiro Nivel"            ,                          , TamSX3("CR_NIVEL")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"CR_USER1"    ,"TMPSZ7" ,"Cod Aprov Primeiro Nivel"  ,                          , TamSX3("CR_USER")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"CR_XNOME1"   ,"TMPSZ7" ,"Aprovador Primeiro Nivel"  ,                          , TamSX3("CR_XNOME")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"CR_NIVELN"   ,"TMPSZ7" ,"Ultimo Nivel"              ,                          , TamSX3("CR_NIVEL")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"CR_USERN"    ,"TMPSZ7" ,"Cod Aprov Ultimo Nivel"    ,                          , TamSX3("CR_USER")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"CR_XNOMEN"   ,"TMPSZ7" ,"Aprovador Ultimo Nivel"    ,                          , TamSX3("CR_XNOME")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_AUSENCI"  ,"TMPSZ7" ,"Ausencia"                  ,                          , 1, /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_PADRAO"   ,"TMPSZ7" ,"Padrao"                    ,                          , 1, /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_REPETE"   ,"TMPSZ7" ,"Recorrencia"               ,                          , 1, /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_MOMENTO"  ,"TMPSZ7" ,"Momento"                   ,                          , 40, /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_EMERGEN"  ,"TMPSZ7" ,"Emergencia"                ,                          , 1, /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_COTACAO"  ,"TMPSZ7" ,"Cotacao"                   ,                          , 1, /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"Z7_QTDCOTA"  ,"TMPSZ7" ,"QTDE Cotacao"              ,                          , 4, /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"ACV_CODPRO"  ,"TMPSZ7" ,"PCS"                       ,                          , 1, /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"C7_PRODUTO"  ,"TMPSZ7" ,"Produto"                   ,                          , TamSX3("C7_PRODUTO")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 
TRCell():New(oSection,"C7_DESCRI"   ,"TMPSZ7" ,"Descricao"                 ,                          , TamSX3("C7_DESCRI")[1], /*<lPixel>*/, /*<bBlock>*/, "CENTER", /*<lLineBreak>*/, "CENTER", /*<lCellBreak>*/, /*<nColSpace>*/, /*<lAutoSize>*/, /*<nClrBack>*/, /*<nClrFore> , /*<lBold>*/ ) 

Return(oReport)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportPrint³Autor ³Alexandre Inacio Lemes ³Data  ³16/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime o Relatorio Release 4                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR086                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oSection  := oReport:Section(1)

oReport:Section(1):BeginQuery()

BeginSql Alias "TMPSZ7"

select z7_filial as z7_filial, // FILIAL 
       (select rtrim(m0_filial) from %table:SM0% where m0_codfil = z7_filial) as m0_filial, // "NOME FILIAL"
       z7_numfor as z7_numfor, // FORMULARIO
       (select ra_mat from  %table:SRA% sra where ra_cic = usr_codigo and ra_sitfolh <> 'D' and ra_sitfolh <> 'T' and sra.%notDel%)  as ra_mat, // "MAT COMPRADOR"
       usr_codigo as usr_codigo, // "CPF COMPRADOR"
       c7_xnomeco as c7_xnomeco, // "NOME COMPRADOR"
       z7_numpc as z7_numpc, // PEDIDO
       //to_char(to_date(c7_emissao,'yyyy-mm-dd hh24:mi:ss'), 'dd/mm/yyyy') as c7_emissao, // EMISSAO
       to_date(c7_emissao,'yyyy-mm-dd hh24:mi:ss') as c7_emissao, // EMISSAO
       c7_total, // TOTAL
       z7_mat as z7_mat, // "MAT DEMANDANTE"
       (select ra_cic from %table:SRA% sra where ra_mat = z7_mat and ra_sitfolh <> 'D' and ra_sitfolh <> 'T' and sra.%notDel%) as ra_cic, // "CPF DEMANDANTE"
       z7_nome as z7_nome, // DEMANDANTE
       c7_fornece as c7_fornece, // "COD FORNECEDOR"
       c7_loja as c7_loja, // LOJA
       c7_xnomfor as c7_xnomfor, // FORNECEDOR
       (select cr_nivel from %table:SCR% scr1 
          where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and cr_status = '03'
            and cr_nivel = (select min(cr_nivel) from %table:SCR% scr11 where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and scr11.%notDel%)
            and scr1.%notDel%) as cr_nivel1, // "PRIMEIRO NIVEL"
       (select cr_user from %table:SCR% scr2
          where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and cr_status = '03'
            and cr_nivel = (select min(cr_nivel) from %table:SCR% scr21 where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and scr21.%notDel%)
            and scr2.%notDel%) as cr_user1, // "COD APROV PRIMEIRO NIVEL"
       (select cr_xnome from %table:SCR% scr3 
          where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and cr_status = '03'
            and cr_nivel = (select min(cr_nivel) from %table:SCR% scr31 where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and scr31.%notDel%)
            and scr3.%notDel%) as cr_xnome1, // "APROVADOR PRIMEIRO NIVEL"
       (select cr_nivel from %table:SCR% scr4 
          where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and cr_status = '03'
            and cr_nivel = (select max(cr_nivel) from %table:SCR% scr41 where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and scr41.%notDel%)
            and scr4.%notDel%) as cr_nivelN, // "ULTIMO NIVEL" 
       (select cr_user from %table:SCR% scr5 
          where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and cr_status = '03'
            and cr_nivel = (select max(cr_nivel) from %table:SCR% scr51 where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and scr51.%notDel%)
            and scr5.%notDel%) as cr_userN, // "COD APROV ULTIMO NIVEL"
       (select cr_xnome from %table:SCR% scr6 
          where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and cr_status = '03'
            and cr_nivel = (select max(cr_nivel) from %table:SCR% scr61 where cr_filial = z7_filial and cr_num = z7_numpc and cr_tipo = 'PC' and scr61.%notDel%)
            and scr6.%notDel%) as cr_xnomeN, // "APROVADOR ULTIMO NIVEL" 
       z7_ausenci as z7_ausenci, // AUSENCIA 
       z7_padrao as z7_padrao, // PADRAO
       z7_repete as z7_repete, // RECORRENCIA
       decode(z7_momento, '1', 'Final de semana (s�bado, domingo, feriado)',
                          '2', 'Hor�rio n�o corporativo (18:00 �s 08:00)',
                          '3', 'Nenhuma das alternativas anteriores') as z7_momento, // MOMENTO
       z7_emergen as z7_emergen, // EMERGENCIA
       z7_cotacao as z7_cotacao, // COTACAO
       z7_qtdcota as z7_qtdcota, // QTDE COTACAO
       decode(acv_codpro, null, 'N', 'S') as acv_codpro, // PCS
       c7_produto as c7_produto, // PRODUTO
       c7_descri as c7_descri // DESCRICAO
   from %table:SZ7% sz7
      inner join %table:SC7% sc7 on c7_filial = z7_filial and c7_num = z7_numpc and sc7.%notDel% 
      inner join sys_usr usr on usr_id = c7_user 
      left  join %table:ACV% acv on acv_filial = c7_filial and acv_codpro = c7_produto and acv.%notDel% 
   where z7_filial  >= %Exp:mv_par01% 
     and z7_filial  <= %Exp:mv_par02% 
     and z7_numfor  >= %Exp:mv_par03% 
     and z7_numfor  <= %Exp:mv_par04% 
     and z7_numpc   >= %Exp:mv_par05% 
     and z7_numpc   <= %Exp:mv_par06% 
     and c7_emissao >= %Exp:Dtos(mv_par07)% 
     and c7_emissao <= %Exp:Dtos(mv_par08)% 
     and sz7.%notDel% 

EndSql 

// aResult := GetLastQuery() /// para poder pegar a query que foi executada n0o BeginSql

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo EndQuery ( Classe TRSection )                                    ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

oReport:SetMeter(TMPSZ7->( RecCount() ))
oSection:Init()

TMPSZ7->( dbGoTop() )

while TMPSZ7->( !EOF() )
   If oReport:Cancel()
      Exit
   EndIf

   oReport:IncMeter()

   oSection:cell("Z7_FILIAL"):SetValue(ALLTRIM(TMPSZ7->Z7_FILIAL))
   oSection:cell("Z7_FILIAL"):SetAlign("CENTER")

   oSection:cell("M0_FILIAL"):SetValue(ALLTRIM(TMPSZ7->M0_FILIAL))
   oSection:cell("M0_FILIAL"):SetAlign("LEFT")

   oSection:cell("Z7_NUMFOR"):SetValue(TMPSZ7->Z7_NUMFOR)
   oSection:cell("Z7_NUMFOR"):SetAlign("CENTER")

   oSection:cell("RA_MAT"):SetValue(TMPSZ7->RA_MAT)
   oSection:cell("RA_MAT"):SetAlign("CENTER")

   oSection:cell("USR_CODIGO"):SetValue(TMPSZ7->USR_CODIGO)
   oSection:cell("USR_CODIGO"):SetAlign("CENTER")

   oSection:cell("C7_XNOMECO"):SetValue(TMPSZ7->C7_XNOMECO)
   oSection:cell("C7_XNOMECO"):SetAlign("LEFT")

   oSection:cell("Z7_NUMPC"):SetValue(ALLTRIM(TMPSZ7->Z7_NUMPC))
   oSection:cell("Z7_NUMPC"):SetAlign("CENTER")

   oSection:cell("C7_EMISSAO"):SetValue(TMPSZ7->C7_EMISSAO)
   oSection:cell("C7_EMISSAO"):SetAlign("CENTER")

   oSection:cell("C7_TOTAL"):SetValue(TMPSZ7->C7_TOTAL)
   oSection:cell("C7_TOTAL"):SetAlign("RIGHT")

   oSection:cell("Z7_MAT"):SetValue(TMPSZ7->Z7_MAT)
   oSection:cell("Z7_MAT"):SetAlign("CENTER")

   oSection:cell("RA_CIC"):SetValue(ALLTRIM(TMPSZ7->RA_CIC))
   oSection:cell("RA_CIC"):SetAlign("CENTER")

   oSection:cell("Z7_NOME"):SetValue(ALLTRIM(TMPSZ7->Z7_NOME))
   oSection:cell("Z7_NOME"):SetAlign("LEFT")

   oSection:cell("C7_FORNECE"):SetValue(ALLTRIM(TMPSZ7->C7_FORNECE))
   oSection:cell("C7_FORNECE"):SetAlign("CENTER")

   oSection:cell("C7_LOJA"):SetValue(ALLTRIM(TMPSZ7->C7_LOJA))
   oSection:cell("C7_LOJA"):SetAlign("CENTER")

   oSection:cell("C7_XNOMFOR"):SetValue(ALLTRIM(TMPSZ7->C7_XNOMFOR))
   oSection:cell("C7_XNOMFOR"):SetAlign("LEFT")

   oSection:cell("CR_NIVEL1"):SetValue(ALLTRIM(TMPSZ7->CR_NIVEL1))
   oSection:cell("CR_NIVEL1"):SetAlign("CENTER")

   oSection:cell("CR_USER1"):SetValue(ALLTRIM(TMPSZ7->CR_USER1))
   oSection:cell("CR_USER1"):SetAlign("CENTER")

   oSection:cell("CR_XNOME1"):SetValue(ALLTRIM(TMPSZ7->CR_XNOME1))
   oSection:cell("CR_XNOME1"):SetAlign("LEFT")

   oSection:cell("CR_NIVELN"):SetValue(ALLTRIM(TMPSZ7->CR_NIVELN))
   oSection:cell("CR_NIVELN"):SetAlign("CENTER")

   oSection:cell("CR_USERN"):SetValue(ALLTRIM(TMPSZ7->CR_USERN))
   oSection:cell("CR_USERN"):SetAlign("CENTER")

   oSection:cell("CR_XNOMEN"):SetValue(ALLTRIM(TMPSZ7->CR_XNOMEN))
   oSection:cell("CR_XNOMEN"):SetAlign("LEFT")

   oSection:cell("Z7_AUSENCI"):SetValue(ALLTRIM(TMPSZ7->Z7_AUSENCI))
   oSection:cell("Z7_AUSENCI"):SetAlign("CENTER")

   oSection:cell("Z7_PADRAO"):SetValue(TMPSZ7->Z7_PADRAO)
   oSection:cell("Z7_PADRAO"):SetAlign("CENTER")

   oSection:cell("Z7_REPETE"):SetValue(TMPSZ7->Z7_REPETE)
   oSection:cell("Z7_REPETE"):SetAlign("CENTER")

   oSection:cell("Z7_MOMENTO"):SetValue(TMPSZ7->Z7_MOMENTO)
   oSection:cell("Z7_MOMENTO"):SetAlign("LEFT")

   oSection:cell("Z7_EMERGEN"):SetValue(TMPSZ7->Z7_EMERGEN)
   oSection:cell("Z7_EMERGEN"):SetAlign("CENTER")

   oSection:cell("Z7_COTACAO"):SetValue(TMPSZ7->Z7_COTACAO)
   oSection:cell("Z7_COTACAO"):SetAlign("CENTER")

   oSection:cell("Z7_QTDCOTA"):SetValue(TMPSZ7->Z7_QTDCOTA)
   oSection:cell("Z7_QTDCOTA"):SetAlign("CENTER")

   oSection:cell("ACV_CODPRO"):SetValue(ALLTRIM(TMPSZ7->ACV_CODPRO))
   oSection:cell("ACV_CODPRO"):SetAlign("CENTER")

   oSection:cell("C7_PRODUTO"):SetValue(TMPSZ7->C7_PRODUTO)
   oSection:cell("C7_PRODUTO"):SetAlign("CENTER")

   oSection:cell("C7_DESCRI"):SetValue(ALLTRIM(TMPSZ7->C7_DESCRI))
   oSection:cell("C7_DESCRI"):SetAlign("LEFT")

   oSection:PrintLine()

   TMPSZ7->( dbSkip() )
end

oSection:Finish()

Return NIL
