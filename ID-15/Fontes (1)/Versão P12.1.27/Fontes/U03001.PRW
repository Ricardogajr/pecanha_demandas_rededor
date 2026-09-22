/*
{Protheus.doc} U03001
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 26/12/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000463701_EF_001
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U03001(lOnlyInfo)
Local aInfo := {'03','001','ALOCAÇÃO PARTICIPANTES','26/12/16','09:07','001667032100100293U0120','05/04/17','18:42',''}
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
aAdd(aSX1,{'FSW0300102','01','Visão Origem','Visão Origem','Visão Origem','MV_CH0','C',6,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','RDK','','','','','','2017040518:21:21'})
aAdd(aSX1,{'FSW0300102','02','Visão Destino','Visão Destino','Visão Destino','MV_CH0','C',6,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','RDK','','','','','','2017040518:21:21'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
