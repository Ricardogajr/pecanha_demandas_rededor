/*
{Protheus.doc} U01004
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 29/08/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_004
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U01004(lOnlyInfo)
Local aInfo := {'01','004','SOLICITACAO DE PAGAMENTO','29/08/16','10:20','004690012010400801U0122','24/10/17','16:17',''}
Local aSIX	:= {}
Local aSX1	:= {}
Local aSX2	:= {}
Local aSX3	:= {}
Local aSX6	:= {}
Local aSX7	:= {}
Local aSXA	:= {}
Local aSXB	:= {}
Local aSX3Hlp := {}
Local aCarga  := {}
DEFAULT lOnlyInfo := .f.
If lOnlyInfo
	Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
EndIf
aAdd(aSIX,{'P02','1','P02_FILIAL+P02_COD+P02_DESC+P02_PREF','Cod. Tipo+Desc Tipo+Prefixo','Cod. Tipo+Desc Tipo+Prefixo','Cod. Tipo+Desc Tipo+Prefixo','U','','','S',''})
aAdd(aSIX,{'SC7','N','C7_FILIAL + C7_XPREF + C7_XDOC','Prefixo + Num. NF','Prefixo + Num. NF','Prefixo + Num. NF','U','','EF0100401','S',''})
aAdd(aSX2,{'P02','','P02010','TIPO DE DESPESAS','TIPO DE DESPESAS','TIPO DE DESPESAS','','E','E','E',0,'','','',0,'','','','','','',0,0,0,''})
aAdd(aSX3,{'P02','01','P02_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','A','R','','','','','','','','','033','','','','','','N','N','','','',''})
aAdd(aSX3,{'P02','02','P02_COD','C',3,0,'Cod. Tipo','Cod. Tipo','Cod. Tipo','Codigo de Tipo','Codigo de Tipo','Codigo de Tipo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','INCLUI','','','','','','','','N','N','','','','2017060216:18:23'})
aAdd(aSX3,{'P02','03','P02_DESC','C',220,0,'Desc Tipo','Desc Tipo','Desc Tipo','Descrição do Tipo','Descrição do Tipo','Descrição do Tipo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'P02','04','P02_PREF','C',3,0,'Prefixo','Prefixo','Prefixo','Prefixo do Tipo','Prefixo do Tipo','Prefixo do Tipo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'P02','05','P02_COMPRA','C',6,0,'Comprador','Comprador','Comprador','Codigo do Comprador','Codigo do Comprador','Codigo do Comprador','@!','','€€€€€€€€€€€€€€ ','','SY1',0,'þÀ','','','U','S','A','R','€','ExistCpo("SY1",M->P02_COMPRA)','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H1','C7_XESPECI','C',6,0,'Especie Doc','Especie Doc','Especie Doc','Especie do Documento','Especie do Documento','Especie do Documento','@!','','€€€€€€€€€€€€€€ ','','42',0,'þÀ','','','U','N','A','R','','ExistCpo("SX5", "42"+M->C7_XESPECI)','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H1','C7_XDOC','C',9,0,'Numero da NF','Numero da NF','Numero da NF','Numero da Nota Fiscal','Numero da Nota Fiscal','Numero da Nota Fiscal','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H1','C7_XSERIE','C',3,0,'Serie da NF','Serie da NF','Serie da NF','Serie da Nota Fiscal','Serie da Nota Fiscal','Serie da Nota Fiscal','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H1','C7_XDTEMI','D',8,0,'Dt Emis NF','Dt Emis NF','Dt Emis NF','Data de Emissao da NF','Data de Emissao da NF','Data de Emissao da NF','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','M->C7_XDTEMI <= DDATABASE','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H3','C7_XDTVEN','D',8,0,'Dt.Prim.Venc','Dt.Prim.Venc','Dt.Prim.Venc','Data Primeiro Vencimento','Data Primeiro Vencimento','Data Primeiro Vencimento','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H4','C7_XTIPO','C',3,0,'Tipo Pag.','Tipo Pag.','Tipo Pag.','Tipo Pagamento','Tipo Pagamento','Tipo Pagamento','@!','ExistCpo("P02")','€€€€€€€€€€€€€€ ','','P02',0,'þÀ','','S','U','S','A','R','','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H5','C7_XPREF','C',3,0,'Prefixo','Prefixo','Prefixo','Prefixo','Prefixo','Prefixo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H6','C7_XUSR','C',6,0,'Emitente','Emitente','Emitente','Emitente','Emitente','Emitente','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H7','C7_XSTATUS','C',1,0,'Status Reg.','Status Reg.','Status Reg.','Status do Registro','Status do Registro','Status do Registro','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','Pertence(" 12345")','1=Sol.Atend.;2=Aguard.Aprov.;3=Aprov. Recusada;4=Bloq. Orçamento;5=Recusa Contas a Pagar','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','H8','C7_XSOLPAG','C',1,0,'Solic.Pagam.','Solic.Pagam.','Solic.Pagam.','Solicitação de Pagamento','Solicitação de Pagamento','Solicitação de Pagamento','@!','','€€€€€€€€€€€€€€ ','"2"','',0,'þÀ','','','U','N','V','R','','Pertence("12")','1=Sim;2=Nao','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SC7','K5','C7_XJURMUL','N',14,2,'Juros/Multa','Juros/Multa','Juros/Multa','Juros e Multa de Sol. Pag','Juros e Multa de Sol. Pag','Juros e Multa de Sol. Pag','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','',1,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017102416:12:48'})
aAdd(aSX3,{'SD1','R2','D1_XPRIVEN','D',8,0,'Dt.Prim.Venc','Dt.Prim.Venc','Dt.Prim.Venc','Data Primeiro Vencimento','Data Primeiro Vencimento','Data Primeiro Vencimento','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SD1','R7','D1_XJURMUL','N',14,2,'Juros/Multa','Juros/Multa','Juros/Multa','Juros/Multa Solic.Pagamen','Juros/Multa Solic.Pagamen','Juros/Multa Solic.Pagamen','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','',1,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017102416:12:49'})
aAdd(aSX3,{'SF1','H2','F1_XUSR','C',30,0,'Emitente','Emitente','Emitente','Emitente','Emitente','Emitente','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','',''})
aAdd(aSX3,{'SF1','H3','F1_XTIPO','C',3,0,'Tipo Pag.','Tipo Pag.','Tipo Pag.','Tipo Pagamento','Tipo Pagamento','Tipo Pagamento','@!','ExistCpo("P02")','€€€€€€€€€€€€€€ ','','P02',0,'þÀ','','S','U','S','A','R','','','','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SF1','H4','F1_XSOLPAG','C',1,0,'Solic.Pagam.','Solic.Pagam.','Solic.Pagam.','Solicitação de Pagamento','Solicitação de Pagamento','Solicitação de Pagamento','@!','','€€€€€€€€€€€€€€ ','"2"','',0,'þÀ','','','U','N','V','R','','Pertence("12")','1=Sim;2=Nao','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX6,{'','FS_CONDPAG','C','Condição de pagamento para a inclusão do Pedido de','','','Compras','','','','','','001','001','001','U','','','','','','',''})
aAdd(aSXB,{'FSSB1','1','01','DB','Produto','Produto','Produto','SB1','',''})
aAdd(aSXB,{'FSSB1','2','01','01','Codigo','Codigo','Product','','',''})
aAdd(aSXB,{'FSSB1','2','02','02','Tipo + Codigo','Tipo + Codigo','Type + Product','','',''})
aAdd(aSXB,{'FSSB1','3','01','01','Cadastra Novo','Incluye Nuevo','Add New','01','',''})
aAdd(aSXB,{'FSSB1','4','01','01','Codigo','Codigo','Product','B1_COD','',''})
aAdd(aSXB,{'FSSB1','4','01','02','Descricao','Descripcion','Description','B1_DESC','',''})
aAdd(aSXB,{'FSSB1','4','01','03','Tipo','Tipo','Type','B1_TIPO','',''})
aAdd(aSXB,{'FSSB1','4','02','01','Codigo','Codigo','Product','B1_COD','',''})
aAdd(aSXB,{'FSSB1','4','02','03','Tipo','Tipo','Type','B1_TIPO','',''})
aAdd(aSXB,{'FSSB1','5','01','','','','','SB1->B1_COD','',''})
aAdd(aSXB,{'FSSB1','5','02','','','','','SB1->B1_DESC','',''})
aAdd(aSXB,{'FSSE4','1','01','DB','Cond. de Pagamento','Cond. de Pagamento','Cond. de Pagamento','SE4','',''})
aAdd(aSXB,{'FSSE4','2','01','01','Codigo','Codigo','Code','','',''})
aAdd(aSXB,{'FSSE4','3','01','01','Cadastra Novo','Incluye Nuevo','Add New','01','',''})
aAdd(aSXB,{'FSSE4','4','01','01','Codigo','Codigo','Code','E4_CODIGO','',''})
aAdd(aSXB,{'FSSE4','4','01','02','Descricao','Descripcion','Description','E4_DESCRI','',''})
aAdd(aSXB,{'FSSE4','4','01','03','Tipo','Tipo','Type','E4_TIPO','',''})
aAdd(aSXB,{'FSSE4','5','01','','','','','SE4->E4_CODIGO','',''})
aAdd(aSXB,{'FSSE4','5','02','','','','','SE4->E4_DESCRI','',''})
aAdd(aSXB,{'FSSED','1','01','DB','Natureza','Natureza','Natureza','SED','',''})
aAdd(aSXB,{'FSSED','2','01','01','Codigo','Codigo','Code','','',''})
aAdd(aSXB,{'FSSED','3','01','01','Cadastra Novo','Incluye Nuevo','Add New','01','',''})
aAdd(aSXB,{'FSSED','4','01','01','Codigo','Codigo','Code','ED_CODIGO','',''})
aAdd(aSXB,{'FSSED','4','01','02','Descricao','Descripcion','Description','ED_DESCRIC','',''})
aAdd(aSXB,{'FSSED','5','01','','','','','SED->ED_CODIGO','',''})
aAdd(aSXB,{'FSSED','5','02','','','','','SED->ED_DESCRIC','',''})
aAdd(aSXB,{'FSWP02','1','01','DB','Tipo de Despesas','Tipo de Despesas','Tipo de Despesas','P02','',''})
aAdd(aSXB,{'FSWP02','2','01','01','Cod. Tipo+desc Tipo+','Cod. Tipo+desc Tipo+','Cod. Tipo+desc Tipo+','','',''})
aAdd(aSXB,{'FSWP02','3','01','01','Cadastra Novo','Incluye Nuevo','Add New','01','',''})
aAdd(aSXB,{'FSWP02','4','01','01','Cod. Tipo','Cod. Tipo','Cod. Tipo','P02_COD','',''})
aAdd(aSXB,{'FSWP02','4','01','02','Desc Tipo','Desc Tipo','Desc Tipo','P02_DESC','',''})
aAdd(aSXB,{'FSWP02','4','01','03','Prefixo','Prefixo','Prefixo','P02_PREF','',''})
aAdd(aSXB,{'FSWP02','5','01','','','','','P02->P02_COD','',''})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
