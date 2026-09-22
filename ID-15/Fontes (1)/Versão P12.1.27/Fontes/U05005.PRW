/*
{Protheus.doc} U05005
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 02/05/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423039_EF_005
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U05005(lOnlyInfo)
Local aInfo := {'05','005','CONSULTA RCL POSTO MOVIMENTO','02/05/17','18:40','005720052010500585U0104','02/05/17','19:37','720104058201'}
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
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
