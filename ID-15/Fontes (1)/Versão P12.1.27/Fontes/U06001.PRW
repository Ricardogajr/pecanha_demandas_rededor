/*
{Protheus.doc} U06001
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 07/11/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423040_EF_001
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U06001(lOnlyInfo)
Local aInfo := {'06','001','INTEGRACAO CADASTRO DE FUNCIONARIO','07/11/16','14:01','001671062110100146U0100','14/12/17','17:01',''}
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
aAdd(aSX3,{'SRA','S3','RA_XINTAPD','C',1,0,'Int ApData?','Int ApData?','Int ApData?','Integrado com Apdata?','Integrado com Apdata?','Integrado com Apdata?','@!','','€€€€€€€€€€€€€€ ','"N"','',0,'þÀ','','','U','N','V','R','','','S=Sim;N=Não','','','','','','','','','','','','N','N','','','','2017121416:52:58'})
aAdd(aSX6,{'','FS_DBMS','C','Gerenciador do Banco de Dados','','','','','','','','','MSSQL','MSSQL','MSSQL','U','','','','','','','2016110714:01:00'})
aAdd(aSX6,{'','FS_DTBASE','C','Nome do Banco de Dados','','','','','','','','','APDATA','APDATA','APDATA','U','','','','','','','2016110714:01:00'})
aAdd(aSX6,{'','FS_PORT','C','Porta do Banco de Dados','','','','','','','','','7890','7890','7890','U','','','','','','','2016110714:01:00'})
aAdd(aSX6,{'','FS_SERVER','C','Caminho do servidor','','','','','','','','','172.16.31.117','172.16.31.117','172.16.31.117','U','','','','','','','2016110714:01:00'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
