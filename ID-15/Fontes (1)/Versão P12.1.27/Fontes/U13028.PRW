/* 
{Protheus.doc} U13028
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 31/01/2018
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423048_EF_028
@Obs Fontes: F1302800.PRW,F1302801.PRW,F1302802.PRW,F1302803.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U13028(lOnlyInfo)
Local aInfo := {'13','028','RELATORIO SOLICITAÇÕES','31/01/18','14:21','018811232011800143U2132','12/03/18','10:49','811132014201'}
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
aAdd(aSX1,{'FSW1302800','01','Filial','','','MV_CH0','C',30,0,0,'R','','MV_PAR01','','','','RH3_FILIAL','','','','','','','','','','','','','','','','','','','','','SM0','','','','','','2018013114:12:10'})
aAdd(aSX1,{'FSW1302800','02','Solicitação','','','MV_CH0','C',30,0,0,'R','','MV_PAR02','','','','RH3_CODIGO','','','','','','','','','','','','','','','','','','','','','FSWSOL','','','','','','2018013114:12:10'})
aAdd(aSX1,{'FSW1302800','03','Data inicio','','','MV_CH0','D',8,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2018013114:12:10'})
aAdd(aSX1,{'FSW1302800','04','Data final','','','MV_CH0','D',8,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2018013114:12:10'})
aAdd(aSXB,{'FSWSOL','1','01','DB','Solicitação Portal','Solicitação Portal','Solicitação Portal','RH3','','2018013114:12:06'})
aAdd(aSXB,{'FSWSOL','2','01','01','Código','Codigo','Code','','','2018013114:12:06'})
aAdd(aSXB,{'FSWSOL','4','01','01','Filial','Sucursal','Branch','RH3_FILIAL','','2018013114:12:06'})
aAdd(aSXB,{'FSWSOL','4','01','02','Código','Codigo','Code','RH3_CODIGO','','2018013114:12:06'})
aAdd(aSXB,{'FSWSOL','5','01','','','','','RH3->RH3_CODIGO','','2018013114:12:06'})
aAdd(aSXB,{'FSWSOL','6','01','','','','','&(U_F1302814())','','2018013114:12:06'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
