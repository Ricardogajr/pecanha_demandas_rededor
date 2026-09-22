/*
{Protheus.doc} U05001
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 21/11/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423039_EF_001
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'

User Function U05001(lOnlyInfo)
Local aInfo := {'05','001','SOLICITACAO DE DESLIGAMENTO','28/04/17','17:40','001780052010100475U0124','28/04/17','19:01','780124047201'}
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
aAdd(aSIX,{'P10','1','P10_FILIAL+P10_COD','P10_FILIAL+P10_COD','P10_FILIAL+P10_COD','P10_FILIAL+P10_COD','U','','','S','2017040615:12:15'})
aAdd(aSIX,{'P10','2','P10_FILIAL+P10_MATRIC','P10_FILIAL+P10_MATRIC','P10_FILIAL+P10_MATRIC','P10_FILIAL+P10_MATRIC','U','','','S','2017040615:12:15'})
aAdd(aSX2,{'P10','','P10010','SOLICITACAO DE DESLIGAMENTO','SOLICITACAO DE DESLIGAMENTO','SOLICITACAO DE DESLIGAMENTO','','E','E','E',0,'','','',0,'','','','','','',0,0,0,'2017040615:12:15'})
aAdd(aSX3,{'P10','01','P10_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017040615:12:15'})
aAdd(aSX3,{'P10','02','P10_COD','C',6,0,'Solicitacao','Solicitacao','Solicitacao','Codigo da Solicitacao.','Codigo da Solicitacao.','Codigo da Solicitacao.','@!','','€€€€€€€€€€€€€€ ','GETSXENUM("P10","P10_COD")','',0,'þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','','','1','2017040615:12:15'})
aAdd(aSX3,{'P10','03','P10_DTSOLI','D',8,0,'Dt Solicitac','Dt Solicitac','Dt Solicitac','Data da Solicitacao','Data da Solicitacao','Data da Solicitacao','','','€€€€€€€€€€€€€€ ','MSDATE()','',0,'þÀ','','','U','S','V','R','€','','','','','','INCLUI','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'P10','04','P10_MATRIC','C',6,0,'Matricula','Matricula','Matricula','Matricula do Funcionario','Matricula do Funcionario','Matricula do Funcionario','999999','','€€€€€€€€€€€€€€ ','','SRA',0,'þÀ','','S','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'P10','05','P10_NOME','C',30,0,'Funcionario','Funcionario','Funcionario','Nome do Funcionario','Nome do Funcionario','Nome do Funcionario','','','€€€€€€€€€€€€€€ ','IIF(!INCLUI, POSICIONE("SRA", 1, XFILIAL("SRA")+M->P10_MATRIC, "RA_NOME"), "")','',0,'þÀ','','','U','N','V','V','','','','','','','','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'P10','06','P10_CODRES','C',6,0,'Rescisao','Rescisao','Rescisao','Codigo da Rescisao','Codigo da Rescisao','Codigo da Rescisao','@!','','€€€€€€€€€€€€€€ ','','FS43BR',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'P10','07','P10_DESRES','C',250,0,'Descricao','Descricao','Descricao','Descricao da Rescisao','Descricao da Rescisao','Descricao da Rescisao','@!','','€€€€€€€€€€€€€€ ','FDESCRCC("S043",IF(TYPE("M->P10_CODRES")=="C" .AND. !EMPTY(M->P10_CODRES),M->P10_CODRES,""),1,2,3,30)','',0,'þÀ','','','U','N','V','V','','','','','','','','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'P10','08','P10_DTDEMI','D',8,0,'Dt Demissao','Dt Demissao','Dt Demissao','Data de Demissao','Data de Demissao','Data de Demissao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'P10','09','P10_MOTIVO','M',10,0,'Motivo','Motivo','Motivo','Motivo','Motivo','Motivo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2','2017040615:12:15'})
aAdd(aSX3,{'P10','10','P10_MATSOL','C',6,0,'Matr Solicit','Matr Solicit','Matr Solicit','Matricula do Solicitante','Matricula do Solicitante','Matricula do Solicitante','@!','','€€€€€€€€€€€€€€ ','__CUSERID','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'P10','11','P10_CODRH3','C',5,0,'Cod.Portal','Cod.Portal','Cod.Portal','Codigo da Solic.Portal','Codigo da Solic.Portal','Codigo da Solic.Portal','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'P10','12','P10_STATUS','C',1,0,'Status','Status','Status','Status','Status','Status','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','V','R','','','1=Em processo de aprovação;2=Atendida;3=Reprovada;4=Aguardando Efetivacao do RH"','','','','','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'RH3','25','RH3_XTPCTM','C',3,0,'Tipo Solicit','Tipo Solicit','Tipo Solicit','Tipo Solicit customizada','Tipo Solicit customizada','Tipo Solicit customizada','@!','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','2','2017040615:12:15'})
aAdd(aSX3,{'SRJ','15','RJ_XGEREN','C',2,0,'Nivel?','Nivel?','Nivel?','Nivel?','Nivel?','Nivel?','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','01=RH;02=PA;03=Presidente;04=VP Executivo;05=Vice Presidente;06=Dir. Executivo;07=Diretor;08=Gerente;09=Superv;10=Lider;11=Livre','','','','','','','','','','','','N','N','','','','2017040615:12:15'})
aAdd(aSX3,{'SRG','07','RG_DESCTPR','C',30,0,'Desc.Tp.Resc','Desc.Tp.Resc','T.Term.Desc.','Descricao Tipo Rescisao','Descripc. Tipo Rescision','Type of Termination Desc.','@!','','€€€€€€€€€€€€€€¨','U_F05001INIT()','',1,'„€','','','','S','V','V','','.T.','','','','','','fDescRCC("S043",SRG->RG_TIPORES,1,2,3,30)','','1','S','','','N','N','N','','','1','2','2017042817:39:43'})
aAdd(aSX6,{'','FS_VISR001','C','Visao pra regra de excecao 001','','','','','','','','','000007','','','U','','','','','','','2017040615:12:15'})
aAdd(aSX6,{'','FS_VISR002','C','Visao pra regra de excecao 002','','','','','','','','','000008','','','U','','','','','','','2017040615:12:15'})
aAdd(aSX7,{'P10_MATRIC','001','M->P10_NOME:=SRA->RA_NOME','P10_NOME','P','S','SRA',1,'xFilial("SRA")+M->P10_MATRIC','!EMPTY(M->P10_MATRIC)','U','2017040615:12:15'})
aAdd(aSXB,{'FS43BR','1','01','DB','Tipo de Rescisao','Tipo de Rescisao','Tipo de Rescisao','RCC','','2017040615:12:15'})
aAdd(aSXB,{'FS43BR','2','01','01','Codigo + Rcc_fil+mes','Codigo + Rcc_fil+mes','Code + Rcc_fil+month','','','2017040615:12:15'})
aAdd(aSXB,{'FS43BR','4','01','01','Codigo','Codigo','Code','SUBSTR(RCC_CONTEU,1,2)','','2017040615:12:15'})
aAdd(aSXB,{'FS43BR','4','01','02','Descricao','Descricao','Descricao','SUBSTR(RCC_CONTEU,3,30)','','2017040615:12:15'})
aAdd(aSXB,{'FS43BR','5','01','','','','','SUBSTR(RCC->RCC_CONTEU,1,2)','','2017040615:12:15'})
aAdd(aSXB,{'FS43BR','5','02','','','','','SUBSTR(RCC->RCC_CONTEU,3,30)','','2017040615:12:15'})
aAdd(aSXB,{'FS43BR','6','01','','','','','RCC->RCC_CODIGO="S043"','','2017040615:12:15'})
aAdd(aSXB,{'FSU006','1','01','DB','Codigo da Rescisao','Codigo da Rescisao','Codigo da Rescisao','RCC','','2017040615:12:15'})
aAdd(aSXB,{'FSU006','2','01','01','Codigo + Rcc_fil+mes','Codigo + Rcc_fil+mes','Code + Rcc_fil+month','','','2017040615:12:15'})
aAdd(aSXB,{'FSU006','4','01','01','Codigo','Codigo','Codigo','SUBSTR(RCC_CONTEU,1,3)','','2017040615:12:15'})
aAdd(aSXB,{'FSU006','4','01','02','Descricao','Descricao','Descricao','SUBSTR(RCC_CONTEU,4,30)','','2017040615:12:15'})
aAdd(aSXB,{'FSU006','5','01','','','','','SUBSTR(RCC->RCC_CONTEUDO,1,3)','','2017040615:12:15'})
aAdd(aSXB,{'FSU006','6','01','','','','','RCC->RCC_CODIGO="U006"','','2017040615:12:15'})
aAdd(aSX3Hlp,{'P10_COD','Codigo da Solicitacao.'})
aAdd(aSX3Hlp,{'P10_DTSOLI','Data da Solicitacao'})
aAdd(aSX3Hlp,{'P10_MATRIC','Matricula do Funcionario(a)'})
aAdd(aSX3Hlp,{'P10_NOME','Nome do(a) Funcionario(a)'})
aAdd(aSX3Hlp,{'P10_CODRES','Codigo da Rescisao'})
aAdd(aSX3Hlp,{'P10_DESRES','Descricao da Rescisao'})
aAdd(aSX3Hlp,{'P10_DTDEMI','Data de Demissao'})
aAdd(aSX3Hlp,{'P10_MOTIVO','Motivo'})
aAdd(aSX3Hlp,{'P10_MATSOL','Matricula do Solicitante'})
aAdd(aSX3Hlp,{'P10_CODRH3','Codigo na RH3'})
aAdd(aSX3Hlp,{'P10_STATUS','Status da solicitação'})
aAdd(aSX3Hlp,{'RJ_XGEREN','Informa se a função é de gerencia.'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
