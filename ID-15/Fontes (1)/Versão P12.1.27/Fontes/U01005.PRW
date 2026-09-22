/*
{Protheus.doc} U01005
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 21/07/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_005
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U01005(lOnlyInfo)
Local aInfo := {'01','005','EF01005','21/07/16','17:16','005616012010500771U0121','29/12/16','14:28',''}
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
aAdd(aSIX,{'RDJ','D','RDJ_FILIAL+RDJ_CODPAR+RDJ_CURSO','Cod.Particip+Cod.Curso','Cod.Particip+Cod.Curso','Attend.Code+Cod.Curso','U','','FSWDJ','N','2016072117:15:30'})
aAdd(aSX3,{'RDJ','43','RDJ_XDTFIM','D',8,0,'Data Termino','Data Termino','Data Termino','Data de termino do curso','Data de termino do curso','Data de termino do curso','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016072117:15:27'})
aAdd(aSX3,{'RDJ','44','RDJ_XNTAVL','N',12,2,'Nt Avaliacao','Nt Avaliacao','Nt Avaliacao','Nota da avaliação','Nota da avaliação','Nota da avaliação','@E 999,999,999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016072117:15:27'})
aAdd(aSXB,{'FSWRDU','1','01','DB','Busca PDI','Busca PDI','Busca PDI','RDU','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','2','01','01','Codigo','Codigo','Code','','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','2','02','02','Descricao + Codigo','Descripcion + Codigo','Description + Code','','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','2','03','03','Data Inicial + Codig','Fecha Inicio + Codig','Initial Date + Code','','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','01','01','Codigo','Codigo','Code','RDU_CODIGO','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','01','02','Descricao','Descripcion','Description','RDU_DESC','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','01','03','Data Inicial','Fecha Inicio','Initial Date','RDU_DATINI','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','01','04','Data Final','Fecha Final','Final Date','RDU_DATFIM','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','02','01','Codigo','Codigo','Code','RDU_CODIGO','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','02','02','Descricao','Descripcion','Description','RDU_DESC','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','02','03','Data Inicial','Fecha Inicio','Initial Date','RDU_DATINI','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','02','04','Data Final','Fecha Final','Final Date','RDU_DATFIM','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','03','01','Codigo','Codigo','Code','RDU_CODIGO','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','03','02','Descricao','Descripcion','Description','RDU_DESC','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','03','03','Data Inicial','Fecha Inicio','Initial Date','RDU_DATINI','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','4','03','04','Data Final','Fecha Final','Final Date','RDU_DATFIM','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','5','01','','','','','RDU->RDU_CODIGO','','2016072117:15:33'})
aAdd(aSXB,{'FSWRDU','6','01','','','','','RDU->RDU_TIPO == 2','','2016072117:15:33'})
aAdd(aSX3Hlp,{'RDJ_XDTFIM','Data de termino do curso'})
aAdd(aSX3Hlp,{'RDJ_XNTAVL','Média do curso'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
