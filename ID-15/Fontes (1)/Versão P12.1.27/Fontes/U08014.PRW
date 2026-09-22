/*
{Protheus.doc} U08014
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 18/05/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project NÃO IDENTIFICADO
@Project MAN00000463301_EF_003
@Obs Fontes: F0801401.PRW,F0801402.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08014(lOnlyInfo)
Local aInfo := {'08','014','HISTORICO APROVAÇÃOES','18/05/17','19:56','004786182010400598U1115','23/05/17','12:02','786115059201'}
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
aAdd(aSIX,{'PAE','1','PAE_FILIAL+PAE_NUMSOL','Solicitação','Solicitação','Solicitação','U','','','N','2017051819:55:42'})
aAdd(aSIX,{'PAE','2','PAE_FILIAL+PAE_FILAPR+PAE_MATAPR','Filial+Matricula','Filial+Matricula','Filial+Matricula','U','','','N','2017051819:55:42'})
aAdd(aSIX,{'PAE','3','PAE_FILAPR+PAE_MATAPR','Filial+Matricula','Filial+Matricula','Filial+Matricula','U','','','N','2017051819:55:42'})
aAdd(aSIX,{'PAE','4','PAE_FILIAL+PAE_NUMSOL+PAE_FILAPR+PAE_MATAPR','Solicitação+Filial+Matricula','Solicitação+Filial+Matricula','Solicitação+Filial+Matricula','U','','','N','2017051819:55:42'})
aAdd(aSX2,{'PAE','','PAE990','HIST. APROVAÇÕES','HIST. APROVAÇÕES','HIST. APROVAÇÕES','','E','E','E',0,'','','',0,'','','','','','',0,0,0,'2017051819:55:39'})
aAdd(aSX3,{'PAE','01','PAE_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017051819:55:18'})
aAdd(aSX3,{'PAE','02','PAE_NUMSOL','C',5,0,'Solicitação','Solicitação','Solicitação','Numero da solicitação','Numero da solicitação','Numero da solicitação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','','','','2017051819:55:18'})
aAdd(aSX3,{'PAE','03','PAE_FILAPR','C',8,0,'Filial','Filial','Filial','Filial Aprovador','Filial Aprovador','Filial Aprovador','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','','','','2017051819:55:18'})
aAdd(aSX3,{'PAE','04','PAE_DESCFI','C',30,0,'Desc.Filial','Desc.Filial','Desc.Filial','Descrição da filial','Descrição da filial','Descrição da filial','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','€','','','','','','','','','','','','','','N','N','','','','2017051819:55:18'})
aAdd(aSX3,{'PAE','05','PAE_MATAPR','C',6,0,'Matricula','Matricula','Matricula','Matricula Aprovador','Matricula Aprovador','Matricula Aprovador','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017051819:55:18'})
aAdd(aSX3,{'PAE','06','PAE_NOMEAP','C',30,0,'Nome','Nome','Nome','Nome Aprovador','Nome Aprovador','Nome Aprovador','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017051819:55:18'})
aAdd(aSX3,{'PAE','07','PAE_FUNAPR','C',30,0,'Função','Função','Função','Função aprovador','Função aprovador','Função aprovador','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017051819:55:18'})
aAdd(aSX3,{'PAE','08','PAE_DCCAPR','C',20,0,'Descrição CC','Descrição CC','Descrição CC','Descrição centro custo','Descrição centro custo','Descrição centro custo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017051819:55:18'})
aAdd(aSX3,{'PAE','09','PAE_OBS','M',10,0,'Observação','Observação','Observação','Observação do aprovador','Observação do aprovador','Observação do aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017051819:55:18'})
aAdd(aSX3Hlp,{'PAE_NUMSOL','Numero da solicitação'})
aAdd(aSX3Hlp,{'PAE_FILAPR','Filial aprovador'})
aAdd(aSX3Hlp,{'PAE_DESCFI','Descrição da filial do aprovador'})
aAdd(aSX3Hlp,{'PAE_MATAPR','Matricula do aprovador'})
aAdd(aSX3Hlp,{'PAE_NOMEAP','Nome do aprovador'})
aAdd(aSX3Hlp,{'PAE_FUNAPR','Função do aprovador'})
aAdd(aSX3Hlp,{'PAE_DCCAPR','Descrição do Centro de Custo'})
aAdd(aSX3Hlp,{'PAE_OBS','Observação feita pelo aprovador'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
