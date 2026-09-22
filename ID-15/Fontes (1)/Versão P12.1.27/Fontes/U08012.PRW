/*
{Protheus.doc} U08012
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 26/03/2018
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_001
@Obs Fontes: F0100101.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08012(lOnlyInfo)
Local aInfo := {'08','012','MELHORIA FROES 2','26/03/18','10:33','002863182010200308U1123','10/04/18','14:11',''}
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
aAdd(aSIX,{'PAL','1','PAL_FILIAL+PAL_MATAPR','Mat Aprov','Mat Aprov','Mat Aprov','U','','','N','2018032610:31:58'})
aAdd(aSIX,{'PAL','2','PAL_FILIAL+PAL_FILSOL+PAL_NUMSOL+PAL_NIVSOL','Fil Solicita+Num Solicita+Niv Solicita','Fil Solicita+Num Solicita+Niv Solicita','Fil Solicita+Num Solicita+Niv Solicita','U','','','N','2018032610:31:58'})
aAdd(aSX2,{'PAL','','PAL990','APROVADORES SOLICITAÇOES RH','APROVADORES SOLICITAÇOES RH','APROVADORES SOLICITAÇOES RH','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2018032610:31:57'})
aAdd(aSX3,{'PAL','01','PAL_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2018032610:31:53'})
aAdd(aSX3,{'PAL','02','PAL_MATAPR','C',6,0,'Mat Aprov','Mat Aprov','Mat Aprov','Matricula do Aprovador','Matricula do Aprovador','Matricula do Aprovador','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2018032610:31:53'})
aAdd(aSX3,{'PAL','03','PAL_FILSOL','C',8,0,'Fil Solicita','Fil Solicita','Fil Solicita','Filial da Solicitaçao','Filial da Solicitaçao','Filial da Solicitaçao','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2018032610:31:53'})
aAdd(aSX3,{'PAL','04','PAL_NUMSOL','C',5,0,'Num Solicita','Num Solicita','Num Solicita','Numero da Solicitaçao','Numero da Solicitaçao','Numero da Solicitaçao','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2018032610:31:53'})
aAdd(aSX3,{'PAL','05','PAL_NIVSOL','C',2,0,'Niv Solicita','Niv Solicita','Niv Solicita','Nível da Solicitaçao','Nível da Solicitaçao','Nível da Solicitaçao','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2018032610:31:53'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
