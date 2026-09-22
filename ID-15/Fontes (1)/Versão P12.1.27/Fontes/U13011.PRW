/*
{Protheus.doc} U13011
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 29/11/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423048_EF_011
@Project NÃO IDENTIFICADO
@Obs Fontes: F1301101.PRW,F1301110.PRW,F1301112.PRW,F1301113.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U13011(lOnlyInfo)
Local aInfo := {'13','011','CONTROLE DE SUBSTITUIÇÃO','29/11/17','15:48','011798132111100153U1124','08/12/17','15:39','798124015211'}
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
aAdd(aSIX,{'PAJ','1','PAJ_FILIAL+PAJ_CODIGO','Código','Código','Código','U','','','S','2017112915:30:19'})
aAdd(aSIX,{'PAJ','2','PAJ_FILSUB+PAJ_MATSUB','Filial Aprov+Matric.Aprov','Filial Aprov+Matric.Aprov','Filial Aprov+Matric.Aprov','U','','','S','2017112915:30:19'})
aAdd(aSIX,{'PAJ','3','PAJ_FILFUN+PAJ_MATFUN','Filial Subst+Matric.Subst','Filial Subst+Matric.Subst','Filial Subst+Matric.Subst','U','','','S','2017112915:30:19'})
aAdd(aSIX,{'PAK','1','PAK_FILSOL+PAK_CODSOL','Filial+Solicitação','Filial+Solicitação','Filial+Solicitação','U','','','S','2017112915:30:19'})
aAdd(aSIX,{'PAK','2','PAK_FILPOS+PAK_CODPOS','Filial Posto+Código Posto','Filial Posto+Código Posto','Filial Posto+Código Posto','U','','','S','2017112915:30:19'})
aAdd(aSIX,{'PAK','3','PAK_FILSUB+PAK_MATSUB','Filial+Matrícula','Filial+Matrícula','Filial+Matrícula','U','','','S','2017112915:30:19'})
aAdd(aSX2,{'PAJ','','PAJ010','CADASTRO DE SUBSTITUIÇÃO','CADASTRO DE SUBSTITUIÇÃO','CADASTRO DE SUBSTITUIÇÃO','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017112915:30:16'})
aAdd(aSX2,{'PAK','','PAK010','HISTORICO APROVACAO SUBSTITUTO','HISTORICO APROVACAO SUBSTITUTO','HISTORICO APROVACAO SUBSTITUTO','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017112915:30:16'})
aAdd(aSX3,{'PAJ','01','PAJ_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','02','PAJ_CODIGO','C',6,0,'Código','Código','Código','Código da Substituição','Código da Substituição','Código da Substituição','@!','','€€€€€€€€€€€€€€ ','GETSX8NUM("PAJ","PAJ_CODIGO")','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','03','PAJ_FILSUB','C',8,0,'Filial','Filial','Filial','Filial do Substituido','Filial do Substituido','Filial do Substituido','@!','','€€€€€€€€€€€€€€ ','','FSWFIL',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','04','PAJ_MATSUB','C',6,0,'Matricula','Matricula','Matricula','Matricula do Substituido','Matricula do Substituido','Matricula do Substituido','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','05','PAJ_NOMSUB','C',30,0,'Substituido','Substituido','Substituido','Nome do Substituido','Nome do Substituido','Nome do Substituido','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','06','PAJ_FILPOS','C',8,0,'Filial Posto','Filial Posto','Filial Posto','Filial Posto Substituido','Filial Posto Substituido','Filial Posto Substituido','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','07','PAJ_CODPOS','C',9,0,'Código Posto','Código Posto','Código Posto','Código Posto Substituido','Código Posto Substituido','Código Posto Substituido','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','08','PAJ_FILFUN','C',8,0,'Filial','Filial','Filial','Filial Substituto','Filial Substituto','Filial Substituto','@!','','€€€€€€€€€€€€€€ ','','FSWFIL',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','09','PAJ_MATFUN','C',6,0,'Matricula','Matricula','Matricula','Matricula do Substituto','Matricula do Substituto','Matricula do Substituto','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','10','PAJ_NOMFUN','C',30,0,'Substituto','Substituto','Substituto','Nome do Substituto','Nome do Substituto','Nome do Substituto','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','11','PAJ_FILPFN','C',8,0,'Filial Posto','Filial Posto','Filial Posto','Filial Posto Substituto','Filial Posto Substituto','Filial Posto Substituto','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','12','PAJ_CODPFN','C',9,0,'Código Posto','Código Posto','Código Posto','Código Posto Substituto','Código Posto Substituto','Código Posto Substituto','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','13','PAJ_STATUS','C',1,0,'Status','Status','Status','Status da Substituição','Status da Substituição','Status da Substituição','@!','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','V','R','','','1=Programado;2=Ativo;3=Inativo','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','14','PAJ_TPDATA','C',1,0,'Tipo da Data','Tipo da Data','Tipo da Data','Tipo da Data','Tipo da Data','Tipo da Data','@!','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','A','R','','','1=Determinada;2=Indeterminada','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','15','PAJ_DTINI','D',8,0,'Data inicio','Data inicio','Data inicio','Data de inicio do periodo','Data de inicio do periodo','Data de inicio do periodo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','16','PAJ_DTFIM','D',8,0,'Data fim','Data fim','Data fim','Data do final do periodo','Data do final do periodo','Data do final do periodo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','17','PAJ_MOTIVO','M',10,0,'Motivo','Motivo','Motivo','Motivo da substituição','Motivo da substituição','Motivo da substituição','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','18','PAJ_USUARI','C',6,0,'Usuario','Usuario','Usuario','Código do usuario','Código do usuario','Código do usuario','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','19','PAJ_NOMUSU','C',30,0,'Nome usuario','Nome usuario','Nome usuario','Nome do usuario','Nome do usuario','Nome do usuario','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','20','PAJ_DTINCL','D',8,0,'Dta inclusao','Dta inclusao','Dta inclusao','Data da inclusão','Data da inclusão','Data da inclusão','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAJ','21','PAJ_HRINCL','C',5,0,'Hr inclusao','Hr inclusao','Hr inclusao','Hora da inclusão','Hora da inclusão','Hora da inclusão','@99:99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','01','PAK_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','02','PAK_FILPOS','C',8,0,'Filial Posto','Filial Posto','Filial Posto','Filial Posto Substituto','Filial Posto Substituto','Filial Posto Substituto','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','03','PAK_CODPOS','C',9,0,'Código Posto','Código Posto','Código Posto','Código Posto Substituto','Código Posto Substituto','Código Posto Substituto','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','04','PAK_FILSUB','C',8,0,'Filial','Filial','Filial','Filial do Substituto','Filial do Substituto','Filial do Substituto','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','05','PAK_MATSUB','C',6,0,'Matrícula','Matrícula','Matrícula','Matrícula do Substituto','Matrícula do Substituto','Matrícula do Substituto','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','06','PAK_NOMSUB','C',30,0,'Substituto','Substituto','Substituto','Nome do Substituto','Nome do Substituto','Nome do Substituto','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','07','PAK_FILSOL','C',8,0,'Filial','Filial','Filial','Filial da Solicitação','Filial da Solicitação','Filial da Solicitação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','08','PAK_CODSOL','C',5,0,'Solicitação','Solicitação','Solicitação','Código da Solicitação','Código da Solicitação','Código da Solicitação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','09','PAK_TPSOL','C',3,0,'Tipo','Tipo','Tipo','Tipo da Solicitação','Tipo da Solicitação','Tipo da Solicitação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','10','PAK_TPSOLN','C',30,0,'Descrição','Descrição','Descrição','Descrição solicitação','Descrição solicitação','Descrição solicitação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','11','PAK_DTOPER','D',8,0,'Data Oper.','Data Oper.','Data Oper.','Data da Operação','Data da Operação','Data da Operação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','12','PAK_HROPER','C',5,0,'Hora Oper.','Hora Oper.','Hora Oper.','Hora da Operação','Hora da Operação','Hora da Operação','@ 99:99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','13','PAK_FILSBD','C',8,0,'Filial','Filial','Filial','Filial do Substituido','Filial do Substituido','Filial do Substituido','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','14','PAK_MATSBD','C',6,0,'Matricula','Matricula','Matricula','Matricula Substituido','Matricula Substituido','Matricula Substituido','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','15','PAK_NOMSBD','C',30,0,'Substituido','Substituido','Substituido','Nome do Substituido','Nome do Substituido','Nome do Substituido','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'PAK','16','PAK_OPERAC','C',1,0,'Operação','Operação','Operação','Operação Realizada','Operação Realizada','Operação Realizada','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:03'})
aAdd(aSX3,{'RH3','41','RH3_XSUBST','C',1,0,'Substituição','Substituição','Substituição','Houve Substituição?','Houve Substituição?','Houve Substituição?','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:05'})
aAdd(aSX3,{'RH3','42','RH3_XFILSU','C',8,0,'Filial','Filial','Filial','Filial do Substituido','Filial do Substituido','Filial do Substituido','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:05'})
aAdd(aSX3,{'RH3','43','RH3_XMATSU','C',6,0,'Matrícula','Matrícula','Matrícula','Matrícula do Substituido','Matrícula do Substituido','Matrícula do Substituido','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017112915:30:05'})
aAdd(aSXB,{'FSFUNS','1','01','RE','Funcionarios','Funcionarios','Funcionarios','SRA','','2017112915:30:27'})
aAdd(aSXB,{'FSFUNS','2','01','01','','','','U_F1301103(2)','','2017112915:30:27'})
aAdd(aSXB,{'FSFUNS','5','01','','','','','U_F1301105(2)','','2017112915:30:27'})
aAdd(aSXB,{'FSSRAC','1','01','RE','Funcionários','Funcionários','Funcionários','SRA','','2017112915:30:27'})
aAdd(aSXB,{'FSSRAC','2','01','01','','','','U_F1301106(1)','','2017112915:30:27'})
aAdd(aSXB,{'FSSRAC','5','01','','','','','U_F1301105(1)','','2017112915:30:27'})
aAdd(aSXB,{'FSSRAG','1','01','RE','Funcionários','Funcionários','Funcionários','SRA','','2017112915:30:27'})
aAdd(aSXB,{'FSSRAG','2','01','01','','','','U_F1301106(2)','','2017112915:30:27'})
aAdd(aSXB,{'FSSRAG','5','01','','','','','U_F1301105(2)','','2017112915:30:27'})
aAdd(aSXB,{'FSSRAS','1','01','RE','Funcionarios','Funcionarios','Funcionarios','SRA','','2017112915:30:27'})
aAdd(aSXB,{'FSSRAS','2','01','01','','','','U_F1301103(1)','','2017112915:30:27'})
aAdd(aSXB,{'FSSRAS','5','01','','','','','U_F1301105(1)','','2017112915:30:27'})
aAdd(aSXB,{'FSWFIL','1','01','DB','Filiais','Sucursales','Branches','SM0','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','2','01','01','Código','Codigo','Code','','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','2','02','02','Nome','Nombre','Name','','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','01','01','Código','Codigo','Code','M0_CODFIL','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','01','02','Filial','Sucursal','Branch','M0_FILIAL','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','01','03','Município','Municipio','City','M0_CIDENT','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','02','04','Empresa','Empresa','Company','M0_NOME','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','02','05','Filial','Sucursal','Branch','M0_CODFIL','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','5','01','','','','','FWCodFil()','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','6','01','','','','','SM0->M0_CODIGO == CEMPANT','','2017032712:34:44'})
aAdd(aSX3Hlp,{'PAJ_CODIGO','Código do cadastro da substituição'})
aAdd(aSX3Hlp,{'PAJ_FILSUB','Filial do Aprovador Substituido.'})
aAdd(aSX3Hlp,{'PAJ_MATSUB','Matricula do Aprovador Substituido.'})
aAdd(aSX3Hlp,{'PAJ_NOMSUB','Nome do aprovador substituido.'})
aAdd(aSX3Hlp,{'PAJ_FILPOS','Filial do Posto do AprovadorSubstituido.'})
aAdd(aSX3Hlp,{'PAJ_CODPOS','Código do posto do aprovadorsubstituido.'})
aAdd(aSX3Hlp,{'PAJ_FILFUN','Filial do Aprovador Substituto.'})
aAdd(aSX3Hlp,{'PAJ_MATFUN','Matricula do aprovador substituto.'})
aAdd(aSX3Hlp,{'PAJ_NOMFUN','Nome do aprovador substituto.'})
aAdd(aSX3Hlp,{'PAJ_FILPFN','Filial do posto do substituto'})
aAdd(aSX3Hlp,{'PAJ_CODPFN','Código do posto do substituto.'})
aAdd(aSX3Hlp,{'PAJ_STATUS','Status da Substituição'})
aAdd(aSX3Hlp,{'PAJ_TPDATA','Tipo da Data (1=Determinada;2=Indeterminada).'})
aAdd(aSX3Hlp,{'PAJ_DTINI','Data de inicio do período desubstituição.'})
aAdd(aSX3Hlp,{'PAJ_DTFIM','Data fim do periodo de substituição'})
aAdd(aSX3Hlp,{'PAJ_MOTIVO','Motivo da substituição.'})
aAdd(aSX3Hlp,{'PAJ_USUARI','Código do usuário responsavel pelocadastro.'})
aAdd(aSX3Hlp,{'PAJ_NOMUSU','Nome do usuário responsável pelocadastro.'})
aAdd(aSX3Hlp,{'PAJ_DTINCL','Data da inclusão'})
aAdd(aSX3Hlp,{'PAJ_HRINCL','Hora da inclusão'})
aAdd(aSX3Hlp,{'PAK_FILPOS','Filial do Posto Substituto'})
aAdd(aSX3Hlp,{'PAK_CODPOS','Código do Posto do Substituto'})
aAdd(aSX3Hlp,{'PAK_FILSUB','Filial do Substituto aprovador'})
aAdd(aSX3Hlp,{'PAK_MATSUB','Matrícula do Substituto aprovador'})
aAdd(aSX3Hlp,{'PAK_NOMSUB','Nome do substituto aprovador'})
aAdd(aSX3Hlp,{'PAK_FILSOL','Filial da solicitação.'})
aAdd(aSX3Hlp,{'PAK_CODSOL','Código da solicitação.'})
aAdd(aSX3Hlp,{'PAK_TPSOL','Tipo da solicitação.'})
aAdd(aSX3Hlp,{'PAK_TPSOLN','Descrição do tipo de solicitação'})
aAdd(aSX3Hlp,{'PAK_DTOPER','Data da Operação (aprovação oureprovação)'})
aAdd(aSX3Hlp,{'PAK_HROPER','Hora da operação (aprovação oureprovação).'})
aAdd(aSX3Hlp,{'PAK_FILSBD','Filial do Substituido'})
aAdd(aSX3Hlp,{'PAK_MATSBD','Matricula do substituido'})
aAdd(aSX3Hlp,{'PAK_NOMSBD','Nome do Substituido.'})
aAdd(aSX3Hlp,{'PAK_OPERAC','Operação Realizada (1=Aprovado,2=Reprovado)'})
aAdd(aSX3Hlp,{'RH3_XSUBST','Houve Substituição?'})
aAdd(aSX3Hlp,{'RH3_XFILSU','Filial do substituido'})
aAdd(aSX3Hlp,{'RH3_XMATSU','Matrícula do Substituido'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
