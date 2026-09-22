/*
{Protheus.doc} U08013
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 31/05/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Obs Fontes: F0801301.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08013(lOnlyInfo)
Local aInfo := {'08','013','RELATORIO DE POSTO X OCUPACAO','31/05/17','18:30','003710182010300588U1133','31/05/17','18:47','710133058201'}
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
aAdd(aSX1,{'FSW0801301','01','Filial ?','¿Sucursal ?','Branch ?','MV_CH1','C',99,0,0,'R','','MV_PAR01','','','','RCL_FILIAL','','','','','','','','','','','','','','','','','','','','','XM0','S','','.RHFILIAL.','','','2017053118:22:01'})
aAdd(aSX1,{'FSW0801301','02','Departamento ?','¿Departamento ?','Department ?','MV_CH2','C',9,0,0,'R','','MV_PAR02','','','','RCL_DEPTO','','','','','','','','','','','','','','','','','','','','','SQB','S','025','.ORG60R02.','','','2017053118:22:01'})
aAdd(aSX1,{'FSW0801301','03','Posto ?','¿Puesto ?','Position ?','MV_CH3','C',9,0,0,'R','','MV_PAR03','','','','RCL_POSTO','','','','','','','','','','','','','','','','','','','','','RCL','S','026','.ORG60R03.','','','2017053118:22:01'})
aAdd(aSX1,{'FSW0801301','04','Status a Imprimir ?','¿Estatus por Imprimir ?','Status to print ?','MV_CH4','C',4,0,0,'G','fOrg60Sta()','MV_PAR04','','','','1234','','','','','','','','','','','','','','','','','','','','','','S','','.ORG60R04.','','','2017053118:22:01'})
aAdd(aSX1,{'FSW0801301','05','Exibe Substitutos ?','¿Muestra Sustitutos ?','Show Substitutes ?','MV_CH5','N',1,0,2,'C','','MV_PAR05','Não','No','No','','','Sim','Si','Yes','','','','','','','','','','','','','','','','','','S','','.ORG60R05.','','','2017053118:22:01'})
aAdd(aSX1,{'FSW0801301','06','Tipo de Relatório ?','¿Tipo de Informe ?','Report Type ?','MV_CH6','N',1,0,1,'C','NaoVazio()','MV_PAR06','Analítico','Analitico','Detailed','','','Sintético','Sintetico','Summarized','','','','','','','','','','','','','','','','','','S','','.RHTPREL.','','','2017053118:22:01'})
aAdd(aSX1,{'FSW0801301','07','Gerar Relatorio ou Planilha ?','Gerar Relatorio ou Planilha ?','Gerar Relatorio ou Planilha ?','MV_CH7','N',1,0,1,'C','NaoVazio()','MV_PAR07','Relatorio','Relatorio','Relatorio','','','Planilha','Planilha','Planilha','','','','','','','','','','','','','','','','','','S','','','','','2017053118:22:01'})
aAdd(aSX6,{'','FS_GRPSOL','C','Informar o Tipo de Solicitação e o Subgrupo juntos','','','Exemplo: 002001/006003/006005/...','','','.','','','002001/006003/006005/006006/006007/006008/006010/','','','U','','','','','','','2017053118:21:59'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
