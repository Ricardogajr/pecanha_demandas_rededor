/*
{Protheus.doc} U12074
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 07/05/2019
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_004
@Obs Fontes: U01004.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U12074(lOnlyInfo)
Local aInfo := {'12','074','CAMPOS PARA BLOQUEIO DE PRODUTO','07/05/19','14:22','014972722011400542U7102','07/05/19','14:36','972102054201'}
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
aAdd(aSX3,{'SB1','W2','B1_XBLQPER','C',1,0,'Bloqueio Def','Bloqueio Def','Bloqueio Def','Bloq. Perm','Bloq. Perm','Bloq. Perm','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019050714:20:46'})
aAdd(aSX3,{'SB1','W3','B1_XBLQOBS','M',10,0,'Mot.Bloqueio','Mot.Bloqueio','Mot.Bloqueio','Motivo do Bloqueio','Motivo do Bloqueio','Motivo do Bloqueio','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019050714:20:46'})
aAdd(aSX3Hlp,{'B1_XBLQOBS','Motivo do bloqueio definitivo do produto'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
