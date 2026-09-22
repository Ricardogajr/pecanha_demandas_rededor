#include 'protheus.ch'


/*/{Protheus.doc} MATR086V2

Rotina para a gera��o da relacao dos Grupos de Compras Delegada

@type function
@version  
@author Sato
@since 8/16/2024
@return variant, return_description
/*/
User Function MATR086V2()

Local oReport

oReport:= ReportDef()
oReport:PrintDialog()

Return



/*/{Protheus.doc} ReportDef

Fun��o para a cria��o do componente de impress�o

@type function
@version  
@author Sato
@since 8/16/2024
@return variant, return_description
/*/
Static Function ReportDef()

Local oReport
Local oSection

/*/{Protheus.doc} TReport():New

Criacao do componente de impressao

@author Sato
@since 19/08/2024
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
oReport:= TReport():New("MATR086V2", OemToAnsi("Grupo de Compras Delegado"), /*"MATR086V2"*/, {|oReport| ReportPrint(oReport)}, OemToAnsi("Este relatorio imprime uma relacao do Grupo de Compras Delegada"))

// Pergunte("MATR086V2",.F.)

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
oSection := TRSection():New(oReport, OemToAnsi("Grupo de Compras Delegado"), {"TMPSAJ"}, /*{Array com as ordens do relatório}*/, /*Campos do SX3*/, /*Campos do SIX*/)

oSection:SetHeaderPage()

TRCell():New(oSection,"AJ_FILIAL"   ,"TMPSAJ" ,"Filial"              , , TamSX3("AJ_FILIAL")[1])
TRCell():New(oSection,"M0_FILIAL"   ,"TMPSAJ" ,"Nome Filial"         , , 30)
TRCell():New(oSection,"AJ_ITEM"     ,"TMPSAJ" ,"Item"                , , TamSX3("AJ_ITEM")[1])
TRCell():New(oSection,"USR_CODIGO"  ,"TMPSAJ" ,"Login (CPF)"         , , 25)
TRCell():New(oSection,"AJ_USER"     ,"TMPSAJ" ,"Cod. Usu�rio"        , , TamSX3("AJ_USER")[1])
TRCell():New(oSection,"AJ_US2NAME"  ,"TMPSAJ" ,"Usu�rio"             , , TamSX3("AJ_US2NAME")[1])
TRCell():New(oSection,"RA_MAT"      ,"TMPSAJ" ,"Matricula"           , , TamSX3("RA_MAT")[1])
TRCell():New(oSection,"QB_DESCRIC"  ,"TMPSAJ" ,"Departamento"        , , TamSX3("QB_DESCRIC")[1])
TRCell():New(oSection,"Q3_DESCSUM"  ,"TMPSAJ" ,"Cargo"               , , TamSX3("Q3_DESCSUM")[1])
TRCell():New(oSection,"C7_EMISSAO"  ,"TMPSAJ" ,"Data Ultima Compra"  , , 10)
TRCell():New(oSection,"USR_DTLOGON" ,"TMPSAJ" ,"Data Ultimo Acesso"  , , 20)
TRCell():New(oSection,"USR_MSBLQL"  ,"TMPSAJ" ,"Status"              , , 9)
TRCell():New(oSection,"RA_SITFOLH"  ,"TMPSAJ" ,"Status Folha"        , , 20)
TRCell():New(oSection,"AJ_GRCOM"    ,"TMPSAJ" ,"Grupo 1"             , , TamSX3("AJ_GRCOM")[1])
TRCell():New(oSection,"AJ_XDESCRI"  ,"TMPSAJ" ,"Descri��o"           , , TamSX3("AJ_XDESCRI")[1])
TRCell():New(oSection,"AJ_GRCOM2"   ,"TMPSAJ" ,"Grupo 2"             , , TamSX3("AJ_GRCOM")[1])
TRCell():New(oSection,"AJ_DESC2"    ,"TMPSAJ" ,"Descri��o"           , , TamSX3("AJ_XDESCRI")[1])

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

BeginSql Alias "TMPSAJ"

/*
select aj_filial,
       (select rtrim(m0_filial) from %table:SM0% where m0_codfil = saj1.aj_filial) as m0_filial,
       aj_item,
       (select rtrim(usr_codigo) from SYS_USR where usr_id = saj1.aj_user) as usr_codigo,
       aj_user,
       aj_us2name,
       (select rtrim(usr_depto) from SYS_USR where usr_id = saj1.aj_user) as usr_depto,
       (select rtrim(usr_cargo) from SYS_USR where usr_id = saj1.aj_user) as usr_cargo,
       (select CASE usr_dtlogon WHEN ' ' 
                    THEN usr_dtlogon
                    ELSE to_char(to_date(usr_dtlogon,'yyyy-mm-dd hh24:mi:ss'), 'dd/mm/yyyy')||' '||usr_hrlogon 
               END from sys_usr where usr_id = saj1.aj_user) as usr_dtlogon, 
       (select decode(usr_msblql, '1', 'BLOQUEADO', '2', 'ATIVO') from SYS_USR where usr_id = saj1.aj_user) as usr_msblql,
       aj_grcom,
       aj_xdescri,
       (select * from (select aj_grcom from %table:SAJ% SAJ2 where SAJ2.aj_filial = SAJ1.aj_filial and SAJ2.aj_grcom <> '000006' and SAJ2.aj_user = SAJ1.aj_user and SAJ2.d_e_l_e_t_ = ' ') where rownum = 1) as aj_grcom2, 
       (select * from (select aj_xdescri from %table:SAJ% SAJ2 where SAJ2.aj_filial = SAJ1.aj_filial and SAJ2.aj_grcom <> '000006' and SAJ2.aj_user = SAJ1.aj_user and SAJ2.d_e_l_e_t_ = ' ') where rownum = 1) as aj_desc2
   from %table:SAJ% SAJ1
   where aj_grcom = '000006' 
     and SAJ1.%notDel%
   order by aj_filial
*/

select aj_filial,
       (select rtrim(m0_filial) from %table:SM0% where m0_codfil = saj1.aj_filial) as m0_filial,
       aj_item,
       usr_codigo,
       aj_user,
       aj_us2name,
       ra_mat,
       ra_depto,
       qb_descric,
       ra_cargo,
       q3_descsum,
       (select max(c7_emissao) from %table:SC7% sc7 where c7_filial = aj_filial and c7_grupcom = aj_grcom and c7_conapro = 'L' and c7_user = aj_user and sc7.%notDel%) as c7_emissao,
       CASE usr_dtlogon WHEN ' ' 
            THEN usr_dtlogon
            ELSE to_char(to_date(usr_dtlogon,'yyyy-mm-dd hh24:mi:ss'), 'dd/mm/yyyy')||' '||usr_hrlogon 
       END as usr_dtlogon, 
       decode(usr_msblql, '1', 'BLOQUEADO', '2', 'ATIVO') as usr_msblql,
       decode(ra_sitfolh, ' ', 'ATIVO', 'A', 'AFASTADO', 'D', 'DEMITIDO', 'F', 'FERIAS', 'T', 'TRANSFERIDO') as ra_sitfolh,
       aj_grcom,
       aj_xdescri,
       (select * from (select saj2.aj_grcom from %table:SAJ% saj2 where saj2.aj_filial = saj1.aj_filial and saj2.aj_grcom <> '000006' and saj2.aj_user = saj1.aj_user and saj2.%notDel%) where rownum = 1) as aj_grcom2, 
       (select * from (select saj2.aj_xdescri from %table:SAJ% saj2 where saj2.aj_filial = saj1.aj_filial and saj2.aj_grcom <> '000006' and saj2.aj_user = saj1.aj_user and saj2.%notDel%) where rownum = 1) as aj_desc2
   from %table:SAJ% saj1
      inner join sys_usr usr on usr_id = saj1.aj_user
      left join %table:SRA%  sra on ra_cic = usr_codigo and ra_demissa = ' ' and sra.%notDel%
      left join %table:RCL%  rcl on rcl_filial = ra_filial and rcl_posto = ra_posto and rcl.%notDel%
      left join %table:SQ3%  sq3 on q3_cargo = ra_cargo and sq3.%notDel%
      left join %table:SQB%  sqb on qb_filial = ra_filial and qb_depto = ra_depto and sqb.%notDel%
   where saj1.aj_grcom = '000006' 
     and saj1.%notDel%
   order by aj_filial, aj_user, aj_item

EndSql 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo EndQuery ( Classe TRSection )                                    ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

oReport:SetMeter(TMPSAJ->( RecCount() ))
oSection:Init()

TMPSAJ->( dbGoTop() )

while TMPSAJ->( !EOF() )
   If oReport:Cancel()
      Exit
   EndIf

   oReport:IncMeter()

   oSection:cell("AJ_FILIAL"):SetValue(ALLTRIM(TMPSAJ->AJ_FILIAL))
   oSection:cell("AJ_FILIAL"):SetAlign("CENTER")

   oSection:cell("M0_FILIAL"):SetValue(ALLTRIM(TMPSAJ->M0_FILIAL))
   oSection:cell("M0_FILIAL"):SetAlign("LEFT")

   oSection:cell("AJ_ITEM"):SetValue(TMPSAJ->AJ_ITEM)
   oSection:cell("AJ_ITEM"):SetAlign("CENTER")

   oSection:cell("USR_CODIGO"):SetValue(ALLTRIM(TMPSAJ->USR_CODIGO))
   oSection:cell("USR_CODIGO"):SetAlign("CENTER")

   oSection:cell("AJ_USER"):SetValue(TMPSAJ->AJ_USER)
   oSection:cell("AJ_USER"):SetAlign("CENTER")

   oSection:cell("AJ_US2NAME"):SetValue(ALLTRIM(TMPSAJ->AJ_US2NAME))
   oSection:cell("AJ_US2NAME"):SetAlign("CENTER")

   oSection:cell("RA_MAT"):SetValue(ALLTRIM(TMPSAJ->RA_MAT))
   oSection:cell("RA_MAT"):SetAlign("CENTER")

   oSection:cell("QB_DESCRIC"):SetValue(ALLTRIM(TMPSAJ->QB_DESCRIC))
   oSection:cell("QB_DESCRIC"):SetAlign("LEFT")

   oSection:cell("Q3_DESCSUM"):SetValue(ALLTRIM(TMPSAJ->Q3_DESCSUM))
   oSection:cell("Q3_DESCSUM"):SetAlign("LEFT")

   oSection:cell("C7_EMISSAO"):SetValue(TMPSAJ->C7_EMISSAO)
   oSection:cell("C7_EMISSAO"):SetAlign("LEFT")

   oSection:cell("USR_DTLOGON"):SetValue(TMPSAJ->USR_DTLOGON)
   oSection:cell("USR_DTLOGON"):SetAlign("LEFT")

   oSection:cell("USR_MSBLQL"):SetValue(TMPSAJ->USR_MSBLQL)
   oSection:cell("USR_MSBLQL"):SetAlign("CENTER")

   oSection:cell("RA_SITFOLH"):SetValue(TMPSAJ->RA_SITFOLH)
   oSection:cell("RA_SITFOLH"):SetAlign("CENTER")

   oSection:cell("AJ_GRCOM"):SetValue(TMPSAJ->AJ_GRCOM)
   oSection:cell("AJ_GRCOM"):SetAlign("CENTER")

   oSection:cell("AJ_XDESCRI"):SetValue(ALLTRIM(TMPSAJ->AJ_XDESCRI))
   oSection:cell("AJ_XDESCRI"):SetAlign("LEFT")

   oSection:cell("AJ_GRCOM2"):SetValue(ALLTRIM(TMPSAJ->AJ_GRCOM2))
   oSection:cell("AJ_GRCOM2"):SetAlign("CENTER")

   oSection:cell("AJ_DESC2"):SetValue(ALLTRIM(TMPSAJ->AJ_DESC2))
   oSection:cell("AJ_DESC2"):SetAlign("LEFT")

   oSection:PrintLine()

   TMPSAJ->( dbSkip() )
end

oSection:Finish()

Return NIL
