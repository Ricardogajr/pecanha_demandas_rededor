/*
{Protheus.doc} U12078
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 23/05/2019
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_004
@Project MAN00000463801_EF_001
@Project NÃO IDENTIFICADO
@Project MAN00000463801_EF_051
@Project MAN0000007423046
@Obs Fontes: F0100404.PRW,F0400101.PRW,F1200704.PRW,F1200705.PRW,F1200707.PR
@Obs Fontes: F1200710.PRW,U01004.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U12078(lOnlyInfo)
Local aInfo := {'12','078','CADASTRO DE CLIENTE','23/05/19','13:13','018933722011800532U7121','25/06/19','11:41','933121053201'}
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
aAdd(aSX3,{'SA1','Q0','A1_XUSRIN','C',17,0,'Dt/Hr Inclus','Dt/Hr Inclus','Dt/Hr Inclus','Data e Hora de inclusão','Data e Hora de inclusão','Data e Hora de inclusão','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019052313:08:18'})
aAdd(aSX3,{'SA1','Q1','A1_XUSRAL','C',17,0,'Dt/Hr Altera','Dt/Hr Altera','Dt/Hr Altera','Data e Hora de alteração','Data e Hora de alteração','Data e Hora de alteração','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019052313:08:18'})
aAdd(aSX3,{'SA1','Q2','A1_XREVIS','C',1,0,'Revisão','Revisão','Revisão','Revisão','Revisão','Revisão','','','€€€€€€€€€€€€€€ ','"2"','',0,'þÀ','','','U','N','A','R','','','1=Sim;2=Não','','','','','','','','','','','','N','N','','','','','','2019052313:08:18'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
