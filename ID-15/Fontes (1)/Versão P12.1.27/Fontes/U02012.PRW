/*
{Protheus.doc} U02012
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 02/05/2019
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_004
@Obs Fontes: U01004.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U02012(lOnlyInfo)
Local aInfo := {'02','012','VALIDAÇÃO DE GRUPO E SUBGRUPO','02/05/19','11:09','002929122010200512U1100','03/05/19','01:45','929100051201'}
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
aAdd(aSX3,{'SB1','11','B1_XSUBGRP','C',4,0,'Sub_Grupo','Sub_Grupo','Sub_Grupo','Sub_Grupo de Produto','Sub_Grupo de Produto','Sub_Grupo de Produto','@!','U_F0201107()','€€€€€€€€€€€€€€ ','','SUBGRP',0,'þÀ','','S','U','N','A','R','€','U_F0201107()','','','','','','','','1','','','','','N','N','','','','','','2019050211:05:58'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
