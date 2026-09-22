/* 
{Protheus.doc} U13006
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 01/11/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_002
@Project MAN00000463301_EF_003
@Project MAN0000007423048_EF_010
@Project MAN0000007423042_EF_004
@Project MAN0000007423042_EF_005
@Project NÃO IDENTIFICADO
@Project MAN0000007423048_EF_006 TYPE FUNCTION
@Obs Fontes: F0200326.PRW,F0500307.PRW,F0800401.PRW,F0800501.PRW,F1300601.PR
@Obs Fontes: F1300602.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U13006(lOnlyInfo)
Local aInfo := {'13','006','POSTO FIXO','01/11/17','12:03','016713032111600123U0100','04/12/17','18:50','713100012211'}
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
aAdd(aSIX,{'PAH','1','PAH_FILIAL+PAH_CODIGO','Codigo','Codigo','Codigo','U','','','N','2017110111:59:51'})
aAdd(aSIX,{'PAH','2','PAH_FILIAL+PAH_CODIGO+PAH_FILPOS+PAH_POSTO','Codigo+Filial Posto+Posto','Codigo+Filial Posto+Posto','Codigo+Filial Posto+Posto','U','','','N','2017110111:59:51'})
aAdd(aSIX,{'PAH','3','PAH_FILIAL+PAH_CODIGO+PAH_FILRES+PAH_MATRES','Codigo+Filial+Matricula','Codigo+Filial+Matricula','Codigo+Filial+Matricula','U','','','N','2017110111:59:51'})
aAdd(aSIX,{'PAH','4','PAH_CODIGO','Codigo','Codigo','Codigo','U','','','N','2017110111:59:51'})
aAdd(aSIX,{'PAI','1','PAI_FILIAL+PAI_CODIGO','Codigo','Codigo','Codigo','U','','','N','2017110111:59:51'})
aAdd(aSX2,{'PAH','','PAH990','LISTAGEM DE POSTOS','LISTAGEM DE POSTOS','LISTAGEM DE POSTOS','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017110111:59:48'})
aAdd(aSX2,{'PAI','','PAI990','CABEÇALHO LISTAGEM DE POSTOS','CABEÇALHO LISTAGEM DE POSTOS','CABEÇALHO LISTAGEM DE POSTOS','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017110111:59:48'})
aAdd(aSX3,{'PAC','11','PAC_VINCL','C',1,0,'Vinculo','Vinculo','Vinculo','Vinculo','Vinculo','Vinculo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','1=SIM;2=NAO','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAC','12','PAC_CODLG','C',8,0,'Listagem','Listagem','Listagem','Codigo da listagem','Codigo da listagem','Codigo da listagem','@!','','€€€€€€€€€€€€€€ ','','FSWPAI',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAC','13','PAC_DESLG','C',30,0,'Descrição','Descrição','Descrição','Descrição','Descrição','Descrição','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAH','01','PAH_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017110111:59:27'})
aAdd(aSX3,{'PAH','02','PAH_CODIGO','C',8,0,'Codigo','Codigo','Codigo','Código listagem','Código listagem','Código listagem','@!','','€€€€€€€€€€€€€€ ','GETSX8NUM( "PAH","PAH_CODIGO")','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAH','03','PAH_FILPOS','C',8,0,'Filial Posto','Filial Posto','Filial Posto','Filial Posto','Filial Posto','Filial Posto','@!','','€€€€€€€€€€€€€€ ','','FSWSM0',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAH','04','PAH_POSTO','C',9,0,'Posto','Posto','Posto','Posto','Posto','Posto','@!','','€€€€€€€€€€€€€€ ','','FSRCL4',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAH','05','PAH_FILRES','C',8,0,'Filial','Filial','Filial','Filial Alocado','Filial Alocado','Filial Alocado','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAH','06','PAH_MATRES','C',6,0,'Matricula','Matricula','Matricula','Matricula Alocado','Matricula Alocado','Matricula Alocado','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAH','07','PAH_NOMRES','C',30,0,'Nome','Nome','Nome','Nome Alocado','Nome Alocado','Nome Alocado','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAH','08','PAH_SITFOL','C',20,0,'Situação','Situação','Situação','Situacao Alocado','Situacao Alocado','Situacao Alocado','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAI','01','PAI_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017110111:59:27'})
aAdd(aSX3,{'PAI','02','PAI_CODIGO','C',8,0,'Codigo','Codigo','Codigo','Código','Código','Código','@!','','€€€€€€€€€€€€€€ ','GETSX8NUM( "PAI","PAI_CODIGO")','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSX3,{'PAI','03','PAI_DESCR','C',30,0,'Descrição','Descrição','Descrição','DESCRIÇÃO','DESCRIÇÃO','DESCRIÇÃO','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017110111:59:27'})
aAdd(aSXB,{'FSWPAI','1','01','DB','Listagem de postos','Listagem de postos','Listagem de postos','PAI','','2017110112:00:01'})
aAdd(aSXB,{'FSWPAI','2','01','01','Codigo','Codigo','Codigo','','','2017110112:00:01'})
aAdd(aSXB,{'FSWPAI','3','01','01','Cadastra Novo','Incluye Nuevo','Add New','01','','2017110112:00:01'})
aAdd(aSXB,{'FSWPAI','4','01','01','Filial','Sucursal','Branch','PAI_FILIAL','','2017110112:00:01'})
aAdd(aSXB,{'FSWPAI','4','01','02','Codigo','Codigo','Codigo','PAI_CODIGO','','2017110112:00:01'})
aAdd(aSXB,{'FSWPAI','4','01','03','Descrição','Descrição','Descrição','PAI_DESCR','','2017110112:00:01'})
aAdd(aSXB,{'FSWPAI','5','01','','','','','PAI->PAI_CODIGO','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','1','01','DB','Filiais','Sucursales','Branches','SM0','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','2','01','01','Código','Codigo','Code','','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','2','02','02','Nome','Nombre','Name','','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','4','01','01','Código','Codigo','Code','M0_CODFIL','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','4','01','02','Filial','Sucursal','Branch','M0_FILIAL','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','4','01','03','Município','Municipio','City','M0_CIDENT','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','4','02','01','Empresa','Empresa','Company','M0_NOME','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','4','02','02','Filial','Sucursal','Branch','M0_FILIAL','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','5','01','','','','','FWCodFil()','','2017110112:00:01'})
aAdd(aSXB,{'FSWSM0','6','01','','','','','SM0->M0_CODIGO == CEMPANT','','2017110112:00:01'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
