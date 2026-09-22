/*
{Protheus.doc} U13030
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 08/02/2018
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_003
@Project 2015GGS0758_MAN00000060101_EF_001
@Project MAN00000462901_EF_002
@Project MAN00000463301_EF_003
@Project MAN0000007423039_EF_002
@Project MAN0000007423039_EF_003
@Project NÃO IDENTIFICADO
@Project MAN0000007423048_EF_025
@Project MAN0000007423039_EF_004
@Project MAN0000007423048_EF_030
@Obs Fontes: F0100305.PRW,F0100308.PRW,F0100323.PRW,F0200326.PRW,F0500207.PR
@Obs Fontes: F0500300.PRW,F0500401.PRW,F0500402.PRW,F1303001.PRW,PE_RS01AG.PR
@Obs Fontes: WSW0500308.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U13030(lOnlyInfo)
Local aInfo := {'13','030','ALTERAÇÃO INCLUSAO SOLICITAÇÕES','08/02/18','09:54','010884332001000293U3105','19/02/18','16:47','884105029200'}
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
aAdd(aSX3,{'RH3','43','RH3_XLIBPT','C',1,0,'Posto Livre?','Posto Livre?','Posto Livre?','Posto Livre?','Posto Livre?','Posto Livre?','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','=Sim;1=Nao','','','','','','','','','','','','N','N','','','','2018020809:45:19'})
aAdd(aSX6,{'','FS_BLQSOL','L','Libera as solicitações e continuidade do processo','','','no controle de postos.','','','','','','.F.','','','U','','','','','','','2018020809:45:33'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
