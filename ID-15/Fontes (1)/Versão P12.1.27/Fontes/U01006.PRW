/*
{Protheus.doc} U01006
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 18/11/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_006
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U01006(lOnlyInfo)
Local aInfo := {'01','006','INCLUSAO COMENTARIOS','18/11/16','13:42','006682012110600131U0114','29/12/16','14:28',''}
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
aAdd(aSX3,{'SQG','69','QG_XOBS','M',10,0,'Observação','Observação','Observação','Observação do Currículo','Observação do Currículo','Observação do Currículo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016111813:41:40'})
aAdd(aSX3,{'SQG','70','QG_XAPROV','C',30,0,'Aprovador','Aprovador','Aprovador','Aprovador do curriculo.','Aprovador do curriculo.','Aprovador do curriculo.','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016111813:41:40'})
aAdd(aSX3Hlp,{'QG_XOBS','Observação do Currículo.'})
aAdd(aSX3Hlp,{'QG_XAPROV','Aprovador do currículo.'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
