/*
{Protheus.doc} U08001
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 02/03/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423042_EF_001
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'

User Function U08001(lOnlyInfo)
Local aInfo := {'08','001','TIPOS DE SOLICITAÇÃO','02/03/17','16:58','001728082010100368U0105','05/04/17','11:47','757104049200'}
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
aAdd(aSIX,{'PA7','1','PA7_FILIAL+PA7_CODIGO+PA7_CODSUB','Codigo+Cod.Sub.Grup','Codigo+Cod.Sub.Grup','Codigo+Cod.Sub.Grup','U','','','S','2017040509:45:18'})
aAdd(aSX2,{'PA7','','PA7010','CONTROLE SOLICITAÇÃO PORTAL','CONTROLE SOLICITAÇÃO PORTAL','CONTROLE SOLICITAÇÃO PORTAL','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017040509:45:18'})
aAdd(aSX3,{'PA7','01','PA7_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017040509:45:18'})
aAdd(aSX3,{'PA7','02','PA7_CODIGO','C',3,0,'Codigo','Codigo','Codigo','Codigo do tipo','Codigo do tipo','Codigo do tipo','@!','','€€€€€€€€€€€€€€ ','GETSX8NUM("PA7","PA7_CODIGO")','',0,'þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','','','','2017040509:45:18'})
aAdd(aSX3,{'PA7','03','PA7_DESCR','C',30,0,'Descricao','Descricao','Descricao','Descrição do tipo','Descrição do tipo','Descrição do tipo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017040509:45:18'})
aAdd(aSX3,{'PA7','04','PA7_CODSUB','C',3,0,'Cod.Sub.Grup','Cod.Sub.Grup','Cod.Sub.Grup','Código do Sub Grupo','Código do Sub Grupo','Código do Sub Grupo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017040509:45:18'})
aAdd(aSX3,{'PA7','05','PA7_DESSUB','C',120,0,'Desc.Sub.Grp','Desc.Sub.Grp','Desc.Sub.Grp','Descrição do Sub Grupo','Descrição do Sub Grupo','Descrição do Sub Grupo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017040509:45:18'})
aAdd(aSXB,{'FSWPA7','1','01','DB','Tipo Solicitação','Tipo Solicitação','Tipo Solicitação','PA7','','2017040509:45:18'})
aAdd(aSXB,{'FSWPA7','2','01','01','Codigo','Codigo','Codigo','','','2017040509:45:18'})
aAdd(aSXB,{'FSWPA7','4','01','01','Codigo','Codigo','Codigo','PA7_CODIGO','','2017040509:45:18'})
aAdd(aSXB,{'FSWPA7','4','01','02','Descricao','Descricao','Descricao','PA7_DESCR','','2017040509:45:18'})
aAdd(aSXB,{'FSWPA7','5','01','','','','','PA7->PA7_DESCR','','2017040509:45:18'})
aAdd(aSXB,{'FSWTMV','1','01','DB','Tipo Movimentação','Tipo Movimentação','Tipo Movimentação','RCC','','2017040509:45:18'})
aAdd(aSXB,{'FSWTMV','2','01','01','Codigo + Rcc_fil+mes','Codigo + Rcc_fil+mes','Code + Rcc_fil+month','','','2017040509:45:18'})
aAdd(aSXB,{'FSWTMV','4','01','01','Código','Código','Código','SUBSTR(RCC_CONTEU,1,3)','','2017040509:45:18'})
aAdd(aSXB,{'FSWTMV','4','01','02','Descrição','Descrição','Descrição','SUBSTR(RCC_CONTEU,4)','','2017040509:45:18'})
aAdd(aSXB,{'FSWTMV','5','01','','','','','SUBSTR(RCC->RCC_CONTEU,1,3)','','2017040509:45:18'})
aAdd(aSXB,{'FSWTMV','5','02','','','','','DESC_TPMOV := SUBSTR(RCC->RCC_CONTEU,4,100)','','2017040509:45:18'})
aAdd(aSXB,{'FSWTMV','6','01','','','','','RCC->RCC_CODIGO="U010"','','2017040509:45:18'})
aAdd(aSX3Hlp,{'PA7_FILIAL','Filial do Sistema'})
aAdd(aSX3Hlp,{'PA7_CODIGO','Código do tipo de solicitação'})
aAdd(aSX3Hlp,{'PA7_DESCR','Descrição do tipo de solicitação'})    
aAdd(aSX3Hlp,{'PA7_CODSUB','Código do sub grupo'})
aAdd(aSX3Hlp,{'PA7_DESSUB','Descrição do Sub Grupo'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
