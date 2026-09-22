/*
{Protheus.doc} U08016
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 01/06/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423042_EF_016
@Project MAN0000007423042_EF_004
@Project MAN0000007423042_CV_014
@Obs Fontes: F0801601.PRW,F0801602.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08016(lOnlyInfo)
Local aInfo := {'08','016','PADRONIZAÇÃO E-MAIL','01/06/17','16:59','006719182010600668U1105','07/06/17','18:00','719105066201'}
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
aAdd(aSIX,{'PAF','1','PAF_FILIAL+PAF_CODIGO','Codigo','Codigo','Codigo','U','','','N','2017060116:57:17'})
aAdd(aSIX,{'PAF','2','PAF_FILIAL+PAF_CODIGO+PAF_TIPO+PAF_SUBGRP','Codigo+Tipo+SubGrupo','Codigo+Tipo+SubGrupo','Codigo+Tipo+SubGrupo','U','','','N','2017060116:57:17'})
aAdd(aSIX,{'PAF','3','PAF_FILIAL+PAF_CODIGO+PAF_TIPO','Codigo+Tipo','Codigo+Tipo','Codigo+Tipo','U','','','N','2017060116:57:17'})
aAdd(aSIX,{'PAF','4','PAF_FILIAL+PAF_TIPO+PAF_SUBGRP','Tipo+SubGrupo','Tipo+SubGrupo','Tipo+SubGrupo','U','','','N','2017060116:57:17'})
aAdd(aSX2,{'PAF','','PAF990','MENSAGEM DE E-MAILS','MENSAGEM DE E-MAILS','MENSAGEM DE E-MAILS','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017060116:57:14'})
aAdd(aSX3,{'PAF','01','PAF_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017060116:56:58'})
aAdd(aSX3,{'PAF','02','PAF_CODIGO','C',6,0,'Codigo','Codigo','Codigo','Codigo','Codigo','Codigo','@!','','€€€€€€€€€€€€€€ ','GETSX8NUM("PAF","PAF_CODIGO")','',0,'þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','','','','2017060116:56:58'})
aAdd(aSX3,{'PAF','03','PAF_TIPO','C',3,0,'Tipo','Tipo','Tipo','Tipo da solicitação','Tipo da solicitação','Tipo da solicitação','@!','','€€€€€€€€€€€€€€ ','','FSPA73',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','2017060116:56:58'})
aAdd(aSX3,{'PAF','04','PAF_TIPDES','C',120,0,'Descrição','Descrição','Descrição','Descrição do Tipo','Descrição do Tipo','Descrição do Tipo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017060116:56:58'})
aAdd(aSX3,{'PAF','05','PAF_SUBGRP','C',3,0,'SubGrupo','SubGrupo','SubGrupo','SubGrupo','SubGrupo','SubGrupo','@!','','€€€€€€€€€€€€€€ ','','FSPA72',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','2017060116:56:58'})
aAdd(aSX3,{'PAF','06','PAF_GRPDES','C',120,0,'Descrição','Descrição','Descrição','Descrição do subgrupo','Descrição do subgrupo','Descrição do subgrupo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017060116:56:58'})
aAdd(aSX3,{'PAF','07','PAF_TXTAPR','C',250,0,'Aprovação','Aprovação','Aprovação','Texto da Aprovação','Texto da Aprovação','Texto da Aprovação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017060116:56:58'})
aAdd(aSX3,{'PAF','08','PAF_TXTREP','C',250,0,'Reprovação','Reprovação','Reprovação','Texto de reprovação','Texto de reprovação','Texto de reprovação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017060116:56:58'})
aAdd(aSX3,{'PAF','09','PAF_TXTEFE','C',250,0,'Efetivação','Efetivação','Efetivação','Texto da efetivação','Texto da efetivação','Texto da efetivação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017060116:56:58'})
aAdd(aSX3,{'PAF','10','PAF_TXTNAP','C',250,0,'NOTIF APROV','NOTIF APROV','NOTIF APROV','Texto Notificado Aprovado','Texto Notificado Aprovado','Texto Notificado Aprovado','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017060116:56:58'})
aAdd(aSXB,{'FSPA71','1','01','RE','Tip.Solicitação','Tip.Solicitação','Tip.Solicitação','PA7','','2017060116:57:25'})
aAdd(aSXB,{'FSPA71','2','01','01','','','','U_F0800402()','','2017060116:57:25'})
aAdd(aSXB,{'FSPA71','5','01','','','','','PAB_TPSOLI','','2017060116:57:25'})
aAdd(aSXB,{'FSPA72','1','01','DB','SubGrupo','SubGrupo','SubGrupo','PA7','','2017060116:57:25'})
aAdd(aSXB,{'FSPA72','2','01','01','Codigo+cod.sub.grup','Codigo+cod.sub.grup','Codigo+cod.sub.grup','','','2017060116:57:25'})
aAdd(aSXB,{'FSPA72','4','01','01','Cod.Sub.Grup','Cod.Sub.Grup','Cod.Sub.Grup','PA7_CODSUB','','2017060116:57:25'})
aAdd(aSXB,{'FSPA72','4','01','02','Desc.Sub.Grp','Desc.Sub.Grp','Desc.Sub.Grp','PA7_DESSUB','','2017060116:57:25'})
aAdd(aSXB,{'FSPA72','5','01','','','','','PA7->PA7_CODSUB','','2017060116:57:25'})
aAdd(aSXB,{'FSPA72','5','02','','','','','PA7->PA7_DESSUB','','2017060116:57:25'})
aAdd(aSXB,{'FSPA72','6','01','','','','','PA7->PA7_CODIGO==M->PAB_TPSOLI .OR. PA7->PA7_CODIGO==M->PAF_TIPO','','2017060718:00:55'})
aAdd(aSXB,{'FSPA73','1','01','RE','Tp Solicitacao','Tp Solicitacao','Tp Solicitacao','PA7','','2017060116:57:25'})
aAdd(aSXB,{'FSPA73','2','01','01','','','','U_F0801602()','','2017060116:57:25'})
aAdd(aSXB,{'FSPA73','5','01','','','','','PAF_TIPO','','2017060116:57:25'})
aAdd(aSXB,{'FSWPA5','1','01','RE','TIPO SOLICITACAO','TIPO SOLICITACAO','TIPO SOLICITACAO','PA7','','2017060116:57:25'})
aAdd(aSXB,{'FSWPA5','2','01','01','','','','U_F0500210()','','2017060116:57:25'})
aAdd(aSXB,{'FSWPA5','5','01','','','','','PA7_CODIGO','','2017060116:57:25'})
aAdd(aSXB,{'FSWPA7','1','01','DB','Tipo Solicitação','Tipo Solicitação','Tipo Solicitação','PA7','','2017060116:57:25'})
aAdd(aSXB,{'FSWPA7','2','01','01','Codigo','Codigo','Codigo','','','2017060116:57:25'})
aAdd(aSXB,{'FSWPA7','4','01','01','Codigo','Codigo','Codigo','PA7_CODIGO','','2017060116:57:25'})
aAdd(aSXB,{'FSWPA7','4','01','02','Descricao','Descricao','Descricao','PA7_DESCR','','2017060116:57:25'})
aAdd(aSXB,{'FSWPA7','5','01','','','','','PA7->PA7_DESCR','','2017060116:57:25'})
aAdd(aSX3Hlp,{'PAF_CODIGO','Código'})
aAdd(aSX3Hlp,{'PAF_TIPO','Tipo da solicitação'})
aAdd(aSX3Hlp,{'PAF_TIPDES','Descrição do Tipo'})
aAdd(aSX3Hlp,{'PAF_SUBGRP','SubGrupo do tipo de solicitação'})
aAdd(aSX3Hlp,{'PAF_GRPDES','Descrição do subgrupo'})
aAdd(aSX3Hlp,{'PAF_TXTAPR','Texto utilizado nos e-mails de aprovação'})
aAdd(aSX3Hlp,{'PAF_TXTREP','Texto utilizado nos e-mails dereprovação'})
aAdd(aSX3Hlp,{'PAF_TXTEFE','Texto utilizado nos e-mails deefetivação'})
aAdd(aSX3Hlp,{'PAF_TXTNAP','Texto utilizado nos e-mails denotificação/aprovação'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
