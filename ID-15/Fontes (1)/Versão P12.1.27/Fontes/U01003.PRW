/*
{Protheus.doc} U01003
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 28/03/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_003
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U01003(lOnlyInfo)
Local aInfo := {'01','003','SOLICITAÇAO DE VAGAS','05/04/17','16:25','003755012010300461U0102','14/09/17','20:44','785122030201'}
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
aAdd(aSX3,{'RH3','25','RH3_XTPCTM','C',3,0,'Tipo Custom.','Tipo Custom.','Tipo Custom.','Tipo de Solicitação Cust.','Tipo de Solicitação Cust.','Tipo de Solicitação Cust.','@!','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'RH3','26','RH3_XDSCTM','C',40,0,'Descrição','Descrição','Descrição','Descrição Tipo Solic.Cust','Descrição tipo Customizad','Descrição tipo Customizad','','','€€€€€€€€€€€€€€ ','POSICIONE("PA7",1,XFILIAL("PA7")+RH3->RH3_XTPCTM,"PA7_DESCR")','',0,'þÀ','','','U','S','V','V','','','','','','','','Posicione("PA7",1,xFilial("PA7")+RH3->RH3_XTPCTM,"PA7_DESCR")','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'RH3','27','RH3_XSUSPE','C',1,0,'Suspenso?','Suspenso?','Suspenso?','Solicitação Suspensa?','Solicitação Suspensa?','Solicitação Suspensa?','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','A','R','','','1=Nao;2=Sim','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'RH3','33','RH3_XDCARG','C',30,0,'Desc. Cargo','Desc. Cargo','Desc. Cargo','Descrição do Cargo','Descrição do Cargo','Descrição do Cargo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2','2017040516:13:49'})
aAdd(aSX3,{'RH3','04','RH3_NOME','C',50,0,'Nome','Nombre','Name','Nome do Solicitante','Nombre del Solicitante','Requester Name','@!','','€€€€€€€€€€€€€€ ','IF(INCLUI, "", U_F0100330(RH3->RH3_CODIGO, RH3->RH3_MAT, RH3->RH3_TIPO))','',1,'”€','','','','S','V','V','','.T.','','','','','','U_F0100330(RH3->RH3_CODIGO, RH3->RH3_MAT, RH3->RH3_TIPO)','','','S','','','N','N','N','','','1','2017051610:34:50'})
aAdd(aSX3,{'RH3','34','RH3_XFILAP','C',8,0,'Fil. Apr','Fil. Apr','Fil. Apr','Filial Aprovador','Filial Aprovador','Filial Aprovador','@!','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017052415:25:15'})
aAdd(aSX3,{'RH3','35','RH3_XMATAP','C',6,0,'Mat Apr','Mat Apr','Mat Apr','Matricula aprovador','Matricula aprovador','Matricula aprovador','@!','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017052415:25:15'})
aAdd(aSX3,{'RH4','08','RH4_XOBS','M',10,0,'Observacao','Observacao','Observacao','Observaçao solicitação','Observaçao solicitação','Observaçao solicitação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQG','71','QG_XTURNTB','C',3,0,'Turno Trab.','Turno Trab.','Turno Trab.','Turno de trabalho','Turno de trabalho','Turno de trabalho','','','€€€€€€€€€€€€€€ ','','SR6',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQG','72','QG_XHRMES','N',8,4,'Hora Mes','Hora Mes','Hora Mes','Hora Mês','Hora Mês','Hora Mês','@E 999.9999','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQG','73','QG_XHRSEM','N',8,4,'Horas Sem.','Horas Sem.','Horas Sem.','Horas semanais','Horas semanais','Horas semanais','@E 999.9999','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQG','74','QG_XSALHOR','N',12,2,'Salario Hora','Salario Hora','Salario Hora','Salario Hora','Salario Hora','Salario Hora','@E 999,999,999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQG','75','QG_XTPCONT','C',1,0,'Tp.Contrato','Tp.Contrato','Tp.Contrato','Tipo de Contrato','Tipo de Contrato','Tipo de Contrato','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','1=Indeterminado; 2=Determinado','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQG','76','QG_XCATFUN','C',1,0,'Cat.Func','Cat.Func','Cat.Func','Categoria do Funcionario','','','','','€€€€€€€€€€€€€€ ','','28',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQS','03','QS_XSTATUS','C',1,0,'Status','Status','Status','Status da Vaga','Status da Vaga','Status da Vaga','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','1=Aprovada;2=Em Recrutamento;3=Em Movimentacao (RI);4=Cadastro;5=Cancelada;6=Suspensa;7=Concluida;8=Exame-Docto;9=Ass.Contrato','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3,{'SQS','28','QS_XJORN','N',6,2,'Jornada','Jornada','Jornada','Jornada de Trabalho','Jornada de Trabalho','Jornada de Trabalho','@E 999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQS','29','QS_XOBSERV','M',10,0,'Observação','Observação','Observação','Observação da vaga','Observação da vaga','Observação da vaga','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQS','30','QS_XSOLFIL','C',8,0,'Filial Solic','Filial Solic','Filial Solic','Filial solicitação portal','Filial solicitação vaga','Filial solicitação vaga','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','033','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQS','31','QS_XSOLPTL','C',5,0,'Solic.Portal','Solic.Portal','Solic.Portal','Cod.Solicitação do Portal','Cod.Solicitação do Portal','Cod.Solicitação do Portal','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQS','34','QS_XPUBLIC','C',1,0,'Publica?','Publica?','Publica?','Publica vaga?','Publica vaga?','Publica vaga?','','','€€€€€€€€€€€€€€ ','"2"','',0,'þÀ','','','U','N','A','R','','','1=Sim;2=Nao','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQS','39','QS_XTURNO','C',3,0,'Turno','Turno','Turno','Turno da Vaga','Turno da Vaga','Turno da Vaga','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX3,{'SQS','36','QS_XDESTUR','C',50,0,'Desc. Turno','Desc. Turno','Desc. Turno','Descriçao do Turno','Descriçao do Turno','Descriçao do Turno','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017051212:28:05'})
aAdd(aSX3,{'SRA','S0','RA_XVAGA','C',6,0,'Cód.Vaga','Cód.Vaga','Cód.Vaga','Código da Vaga','Código da Vaga','Código da Vaga','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017040516:13:49'})
aAdd(aSX6,{'','FS_EFTVRH','C','E-mail do Rh que realizará a efetivação das solici','','','tações feitas no portal.','','','','','','bruolivrock@gmail.com','','','U','','','','','','','2017040516:13:49'})
aAdd(aSX7,{'QG_VAGA','002','U_F0100324(M->QG_VAGA,.F.)','QG_XCATFUN','P','N','',0,'','','U','2017040516:13:49'})
aAdd(aSX3Hlp,{'RH3_XTPCTM','Tipo de solicitação customizada.'})
aAdd(aSX3Hlp,{'RH3_XDSCTM','Descrição do tipo de solicitaçãocustomizada.'})
aAdd(aSX3Hlp,{'RH3_XSUSPE','Solicitação Suspensa? (1=Não;2=Sim)'})
aAdd(aSX3Hlp,{'RH3_XDCARG','Descrição do Cargo'})
aAdd(aSX3Hlp,{'QG_XTPCONT','Tipo de Contrato (1=Determinado;2=Indeterminado)'})
aAdd(aSX3Hlp,{'QS_XSTATUS','Status da Vaga (1=Aprovada,2=EmRecrutamento;3=EmMovimentação (RI); 4=Em Admissão;5=Cancelada; 6=Suspensa; 7=Concluída)'})
aAdd(aSX3Hlp,{'QS_XJORN','Jornada de Trabalho.'})
aAdd(aSX3Hlp,{'QS_XOBSERV','Observação da vaga'})
aAdd(aSX3Hlp,{'QS_XSOLFIL','Filial da solicitação do portal'})
aAdd(aSX3Hlp,{'QS_XSOLPTL','Código da solicitação realizada noportal.'})
aAdd(aSX3Hlp,{'QS_XPUBLIC','Publica vaga? (1=Sim;2=Nao)'})
aAdd(aSX3Hlp,{'RA_XVAGA','Código da vaga'})
aAdd(aSX3Hlp,{'RH3_XFILAP','Filial do aprovador logado'})
aAdd(aSX3Hlp,{'RH3_XMATAP','Matricula do aprovador logado'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
