/*
{Protheus.doc} U01007
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 26/07/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_007
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U01007(lOnlyInfo)
Local aInfo := {'01','007','ATESTADO MEDICO','26/07/16','17:50','007660012010700771U0125','29/12/16','14:28',''}
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
aAdd(aSX3,{'TNY','42','TNY_XCONVB','C',1,0,'Conv.B91','Conv.B91','Conv.B91','Conversão B91','Conversão B91','Conversão B91','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','1=Sim;2-Não','','','','','','','3','','','','','N','N','','','','2016072617:49:14'})
aAdd(aSX3,{'TNY','43','TNY_XCINSS','C',1,0,'Cont.  INSS','Cont.  INSS','Cont.  INSS','Contestação INSS','Contestação INSS','Contestação INSS','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','1=Sim;2=Não','','','','','','','3','','','','','N','N','','','','2016072617:49:14'})
aAdd(aSX3Hlp,{'TNY_XCONVB','Conversão B91 (doença oriunda dotrabalho) (1=Sim;2-Não)'})
aAdd(aSX3Hlp,{'TNY_XCINSS','Contestação INSS (1=Sim;2=Não)'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
