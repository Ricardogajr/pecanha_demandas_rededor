/*
{Protheus.doc} U08002
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 21/03/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423042_EF_002
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08002(lOnlyInfo)
Local aInfo := {'08','002','HISTORICO DE LOG SOLICITACOES RH','21/03/17','17:25','002715082010200378U0122','27/03/17','17:20',''}
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
aAdd(aSIX,{'PAA','1','PAA_FILIAL+PAA_CODIGO','Codigo','Codigo','Codigo','U','','','N','2017032117:21:51'})
aAdd(aSIX,{'PAA','2','PAA_FILIAL+PAA_TPOPER+PAA_CODALC+PAA_CODCAO','Tp.Operaçao+Cod.Alçada+Tipo Solic','Tp.Operaçao+Cod.Alçada+Tipo Solic','Tp.Operaçao+Cod.Alçada+Tipo Solic','U','','','N','2017032117:21:51'})
aAdd(aSIX,{'PAA','3','PAA_FILIAL+PAA_FILSOL+PAA_NUMSOL','Fil.Solic.RH+Num.Solic.RH','Fil.Solic.RH+Num.Solic.RH','Fil.Solic.RH+Num.Solic.RH','U','','','N','2017032117:21:51'})
aAdd(aSX2,{'PAA','','PAA010','HIST DE LOG DE SOLICITACAO','HIST DE LOG DE SOLICITACAO','HIST DE LOG DE SOLICITACAO','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017032117:21:49'})
aAdd(aSX3,{'PAA','01','PAA_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','SM0',1,'þÀ','','','U','S','','','','','','','','','','','033','','','','','','','','','','','2017032117:21:32'})
aAdd(aSX3,{'PAA','02','PAA_CODIGO','C',6,0,'Codigo','Codigo','Codigo','Codigo','Codigo','Codigo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:32'})
aAdd(aSX3,{'PAA','03','PAA_DATA','D',8,0,'Data','Data','Data','Data','Data','Data','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:32'})
aAdd(aSX3,{'PAA','04','PAA_HORA','C',8,0,'Hora','Hora','Hora','Hora','Hora','Hora','@R 99:99:99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:32'})
aAdd(aSX3,{'PAA','05','PAA_TPOPER','C',1,0,'Tp.Operaçao','Tp.Operaçao','Tp.Operaçao','Tipo da Operaçao','Tipo da Operaçao','Tipo da Operaçao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','1=Incluir;2=Cancelar;3=Aprovar;4=Rejeitar','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','06','PAA_CODVIS','C',6,0,'Cod.Visao','Cod.Visao','Cod.Visao','Codigo da Visao','Codigo da Visao','Codigo da Visao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','07','PAA_CODALC','C',6,0,'Cod.Alçada','Cod.Alçada','Cod.Alçada','Codigo de Alçada','Codigo de Alçada','Codigo de Alçada','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','08','PAA_CODCAO','C',3,0,'Tipo Solic','Tipo Solic','Tipo Solic','Cod. Tipo de Solicitaçao','Cod. Tipo de Solicitaçao','Cod. Tipo de Solicitaçao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','09','PAA_DESCAO','C',120,0,'Desc.Tp.Sol.','Desc.Tp.Sol.','Desc.Tp.Sol.','Desc.Tipo de Solicitaçao','Desc.Tipo de Solicitaçao','Desc.Tipo de Solicitaçao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','10','PAA_CODSUB','C',3,0,'Cod SubGrupo','Cod SubGrupo','Cod SubGrupo','Codigo do SubGrupo','Codigo do SubGrupo','Codigo do SubGrupo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','11','PAA_DESSUB','C',120,0,'Desc SubGrup','Desc SubGrup','Desc SubGrup','Descricao do SubGrupo','Descricao do SubGrupo','Descricao do SubGrupo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','12','PAA_FILANT','C',8,0,'F.Solicitant','F.Solicitant','F.Solicitant','Filial do Solicitante','Filial do Solicitante','Filial do Solicitante','','','€€€€€€€€€€€€€€ ','','SM0',0,'þÀ','','','U','S','A','R','','','','','','','','','033','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','13','PAA_CODANT','C',6,0,'C.Solicitant','C.Solicitant','C.Solicitant','Codigo do Solicitante','Codigo do Solicitante','Codigo do Solicitante','','','€€€€€€€€€€€€€€ ','','SRA',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','14','PAA_POSANT','C',9,0,'P.Solicitant','P.Solicitant','P.Solicitant','Posto do Solicitante','Posto do Solicitante','Posto do Solicitante','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','15','PAA_DESANT','C',120,0,'Depto.Solic.','Depto.Solic.','Depto.Solic.','Depto do Solicitante','Depto do Solicitante','Depto do Solicitante','','','€€€€€€€€€€€€€€ ','POSICIONE("SQB",1,XFILIAL("SQB")+M->PAA_POSANT,"QB_DESCRIC")','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','16','PAA_FILDOR','C',8,0,'F.Aprovador','F.Aprovador','F.Aprovador','Filial do Aprovador','Filial do Aprovador','Filial do Aprovador','','','€€€€€€€€€€€€€€ ','','SM0',0,'þÀ','','','U','S','A','R','','','','','','','','','033','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','17','PAA_CODDOR','C',6,0,'C.Aprovador','C.Aprovador','C.Aprovador','Codigo do Aprovador','Codigo do Aprovador','Codigo do Aprovador','','','€€€€€€€€€€€€€€ ','','SRA',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','18','PAA_POSDOR','C',9,0,'P.Aprovador','P.Aprovador','P.Aprovador','Posto do Aprovador','Posto do Aprovador','Posto do Aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','19','PAA_DESDOR','C',120,0,'Depto.Aprov.','Depto.Aprov.','Depto.Aprov.','Depto do Aprovador','Depto do Aprovador','Depto do Aprovador','','','€€€€€€€€€€€€€€ ','POSICIONE("SQB",1,XFILIAL("SQB")+M->PAA_POSDOR,"QB_DESCRIC")','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','20','PAA_OBSERV','C',250,0,'Observacao','Observacao','Observacao','Observacao','Observacao','Observacao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','21','PAA_NUMSOL','C',5,0,'Num.Solic.RH','Num.Solic.RH','Num.Solic.RH','Numero Solicitacao do RH','Numero Solicitacao do RH','Numero Solicitacao do RH','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','22','PAA_FILSOL','C',8,0,'Fil.Solic.RH','Fil.Solic.RH','Fil.Solic.RH','Filial Solicitacao do RH','Filial Solicitacao do RH','Filial Solicitacao do RH','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','23','PAA_EMAIL','C',50,0,'Email Aprov.','Email Aprov.','Email Aprov.','Email Aprovador','Email Aprovador','Email Aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3,{'PAA','24','PAA_NIVAPR','C',2,0,'Nivel Aprov.','Nivel Aprov.','Nivel Aprov.','Nivel Aprovador','Nivel Aprovador','Nivel Aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017032117:21:33'})
aAdd(aSX3Hlp,{'PAA_FILSOL','Filial Solicitacao do RH'})
aAdd(aSX3Hlp,{'PAA_EMAIL','Email Aprovador'})
aAdd(aSX3Hlp,{'PAA_NIVAPR','Nivel Aprovador'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
