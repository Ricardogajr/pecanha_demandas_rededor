/*
{Protheus.doc} U12070
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 07/05/2019
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_004
@Obs Fontes: U01004.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U12070(lOnlyInfo)
Local aInfo := {'12','070','SOLICITACAO DE NOVOS CAMPOS','07/05/19','14:35','010975722011000542U7103','07/05/19','14:36','975103054201'}
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
aAdd(aSX3,{'SC7','I3','C7_XMULTA','N',14,2,'Valor Multa','Valor Multa','Valor Multa','Valor Multa','Valor Multa','Valor Multa','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019050714:33:32'})
aAdd(aSX3,{'SD1','Y4','D1_XMULTA','N',14,2,'Valor Multa','Valor Multa','Valor Multa','Valor Multa','Valor Multa','Valor Multa','@E 99,999,999,999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','2','2019050714:33:32'})
aAdd(aSX3,{'SD1','Y5','D1_XOBS','C',30,0,'Observacoes ','Observac.','Note','Observacoes','Observaciones','Observations','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2019050714:33:32'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
