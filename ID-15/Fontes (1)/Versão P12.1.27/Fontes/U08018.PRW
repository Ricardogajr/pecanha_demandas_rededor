/*
{Protheus.doc} U08018
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 09/06/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423042_EF_018
@Project MAN0000007423042_CV_018
@Obs Fontes: F0801601.PRW,F0801602.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08018(lOnlyInfo)
Local aInfo := {'08','018','CAMPO DATA','09/06/17','12:35','008795182010800628U1103','13/06/17','12:45','795103062201'}
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
aAdd(aSIX,{'PAB','3','PAB_FILIAL+PAB_TPSOLI+PAB_GRPSOL+PAB_DTVLD','Tp.Solicit.+Subgrupo+Validade','Tp.Solicit.+Subgrupo+Validade','Tp.Solicit.+Subgrupo+Validade','U','','','N','2017061310:49:09'})
aAdd(aSX3,{'PAB','26','PAB_DTVLD','D',8,0,'Validade','Validade','Validade','Data de validade','Data de validade','Data de validade','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','M->PAB_DTVLD  > DATE()','','','','','','','','','','','','','N','N','','','','2017060912:34:01'})
aAdd(aSX3Hlp,{'PAB_DTVLD','Data de validade da alçada'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
