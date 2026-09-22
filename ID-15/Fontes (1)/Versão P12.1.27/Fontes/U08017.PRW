/* 
{Protheus.doc} U08017
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 07/06/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423042_EF_016
@Project MAN0000007423042_EF_004
@Project MAN0000007423042_CV_014
@Obs Fontes: F0801601.PRW,F0801602.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08017(lOnlyInfo)
Local aInfo := {'08','017','VAGA','07/06/17','16:38','007778182010700668U1103','12/06/17','18:59','778103066201'}
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
aAdd(aSX3,{'RH3','36','RH3_XVAGA','C',6,0,'Vaga','Vaga','Vaga','Código da vaga','Código da vaga','Código da vaga','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017060716:37:07'})
aAdd(aSX3Hlp,{'RH3_XVAGA','Código da vaga'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
