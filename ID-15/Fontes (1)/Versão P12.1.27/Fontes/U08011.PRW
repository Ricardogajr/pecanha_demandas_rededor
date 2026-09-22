/*
{Protheus.doc} U08011
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 31/03/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423042_EF_011
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08011(lOnlyInfo)
Local aInfo := {'08','011','FERIAS','31/03/17','18:18','001718182010100388U1131','31/03/17','19:13','718131038201'}
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
aAdd(aSX6,{'','FS_DINIFER','N','Dias antes do inicio das ferias, para garantir que','','','o periodo de solicitação/aprovação atenda os','','','prazos legais','','','45','','','U','','','','','','','2017033118:16:34'})
aAdd(aSX6,{'','FS_DTER2PE','N','Dias antes do término do 2 peridodo aquisitivo, ev','','','itando assim o pagamento de férias em dobro, previ','','','sto na CLT.','','','75','','','U','','','','','','','2017033118:16:34'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
