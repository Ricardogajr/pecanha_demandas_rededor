/*
{Protheus.doc} U05002
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 14/12/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project NÃO IDENTIFICADO
@Project MAN0000007423039_EF_002
@Project 2015GGS0758_MAN00000060101_EF_001
@Obs Fontes: U05002.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U05002(lOnlyInfo)
Local aInfo := {'05','002','MONITOR DE INDICADORES','14/12/16','11:06','002646052110200215U0110','26/05/17','11:54',''}
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
aAdd(aSIX,{'PA5','1','PA5_FILIAL+PA5_XNRSOL+PA5_XDATA','Num Solicita+Data da Movi','Num Solicita+Data da Movi','Num Solicita+Data da Movi','U','','','N','2016121411:03:52'})
aAdd(aSIX,{'PA5','2','PA5_FILIAL+PA5_XDATA+PA5_XNRSOL','Data da Movi+Num Solicita','Data da Movi+Num Solicita','Data da Movi+Num Solicita','U','','','N','2016121411:03:52'})
aAdd(aSX1,{'FSW0500204','01','Filial de:','','','MV_CH0','C',8,0,0,'G','','MV_PAR01','','','','01','','','','','','','','','','','','','','','','','','','','','SM0','','','','','','2017052611:25:34'})
aAdd(aSX1,{'FSW0500204','02','Filial ate:','','','MV_CH0','C',8,0,0,'G','','MV_PAR02','','','','ZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','SM0','','','','','','2017052611:25:34'})
aAdd(aSX1,{'FSW0500204','03','Num Solicitação de:','','','MV_CH0','C',5,0,0,'G','','MV_PAR03','','','','00000','','','','','','','','','','','','','','','','','','','','','FSWRH3','','','','','','2017052611:25:34'})
aAdd(aSX1,{'FSW0500204','04','Num Solicitação até:','','','MV_CH0','C',5,0,0,'G','','MV_PAR04','','','','99999','','','','','','','','','','','','','','','','','','','','','FSWRH3','','','','','','2017052611:25:34'})
aAdd(aSX1,{'FSW0500204','05','Data Ocorrencia de:','','','MV_CH0','D',8,0,0,'G','','MV_PAR05','','','','20161201','','','','','','','','','','','','','','','','','','','','','','','','','','','2017052611:25:34'})
aAdd(aSX1,{'FSW0500204','06','Data Ocorrencia até:','','','MV_CH0','D',8,0,0,'G','','MV_PAR06','','','','20171208','','','','','','','','','','','','','','','','','','','','','','','','','','','2017052611:25:34'})
aAdd(aSX1,{'FSW0500204','07','Tipo de Solicitação','','','MV_CH0','C',3,0,0,'G','','MV_PAR07','','','','002','','','','','','','','','','','','','','','','','','','','','FSWPA5','','','','','','2017052611:25:34'})
aAdd(aSX2,{'PA5','','PA5010','INDICADORES DE SOLICITAÇÕES','INDICADORES DE SOLICITAÇÕES','INDICADORES DE SOLICITAÇÕES','','E','E','E',0,'','','',0,'','','','','','',0,0,0,'2016121411:03:49'})
aAdd(aSX3,{'PA5','01','PA5_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','02','PA5_XNRSOL','C',5,0,'Num Solicita','Num Solicita','Num Solicita','Número da Solicitação','Número da Solicitação','Número da Solicitação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','03','PA5_XDESOL','C',30,0,'Desc. Solici','Desc. Solici','Desc. Solici','Descrição da Solicitação','Descrição da Solicitação','Descrição da Solicitação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','04','PA5_XSTAT','C',100,0,'Status Solic','Status Solic','Status Solic','Status Solicitação','Status Solicitação','Status Solicitação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','05','PA5_XCODEV','C',6,0,'Cod Evento','Cod Evento','Cod Evento','Código Evento','Código Evento','Código Evento','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','06','PA5_XDESEV','C',30,0,'Evento','Evento','Evento','Descrição do Evento','Descrição do Evento','Descrição do Evento','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','07','PA5_XNOME','C',40,0,'Nome Solicit','Nome Solicit','Nome Solicit','Nome Solicitante','Nome Solicitante','Nome Solicitante','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','08','PA5_XMAT','C',6,0,'Matr Solicit','Matr Solicit','Matr Solicit','Matricula Solicitante','Matricula Solicitante','Matricula Solicitante','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','09','PA5_XSETOR','C',30,0,'Setor Solici','Setor Solici','Setor Solici','Setor Solicitante','Setor Solicitante','Setor Solicitante','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','10','PA5_XUNIDA','C',12,0,'Unid Solicit','Unid Solicit','Unid Solicit','Unidade  Solicitante','Unidade  Solicitante','Unidade  Solicitante','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','11','PA5_XCC','C',12,0,'Centro Custo','Centro Custo','Centro Custo','Centro de Custo Solicitan','Centro de Custo Solicitan','Centro de Custo Solicitan','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','12','PA5_FUNCAO','C',20,0,'Função','Função','Função','Função','Função','Função','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','13','PA5_XCARGO','C',30,0,'Cargo Solici','Cargo Solici','Cargo Solici','Cargo Solicitante','Cargo Solicitante','Cargo Solicitante','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','14','PA5_XAPROV','C',40,0,'Aprovador','Aprovador','Aprovador','Aprovador','Aprovador','Aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','15','PA5_XMATAP','C',6,0,'Matr Aprovad','Matr Aprovad','Matr Aprovad','Matricula Aprovador','Matricula Aprovador','Matricula Aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','16','PA5_XSEAPV','C',30,0,'Setor Aprova','Setor Aprova','Setor Aprova','Setor Aprovador','Setor Aprovador','Setor Aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','17','PA5_XUNAPR','C',12,0,'Unid Aprovad','Unid Aprovad','Unid Aprovad','Unidade Aprovador','Unidade Aprovador','Unidade Aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','18','PA5_XCARAP','C',30,0,'Cargo Aprova','Cargo Aprova','Cargo Aprova','Cargo Aprovador','Cargo Aprovador','Cargo Aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','19','PA5_XCONTA','C',9,0,'Conta Orcame','Conta Orcame','Conta Orcame','Conta Orcamentaria','Conta Orcamentaria','Conta Orcamentaria','','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','20','PA5_XEMPEN','N',12,2,'Valor Empenh','Valor Empenh','Valor Empenh','Valor Empenhado','Valor Empenhado','Valor Empenhado','@E 999,999,999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','21','PA5_XDATA','D',8,0,'Data da Movi','Data da Movi','Data da Movi','Data da Movimentação','Data da Movimentação','Data da Movimentação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','22','PA5_XHORA','C',5,0,'Hr Movimenta','Hr Movimenta','Hr Movimenta','Hora da Movimentação','Hora da Movimentação','Hora da Movimentação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','23','PA5_XUSER','C',30,0,'Usuario Log.','Usuario Log.','Usuario Log.','Usuario Logado','Usuario Logado','Usuario Logado','','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'PA5','24','PA5_XCDSTA','C',3,0,'CodigoStatus','CodigoStatus','CodigoStatus','CodigoStatus','CodigoStatus','CodigoStatus','','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:32'})
aAdd(aSX3,{'SQS','29','QS_XSUSPEN','C',1,0,'Hist. Status','Hist. Status','Hist. Status','Historico do Status','Historico do Status','Historico do Status','','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:40'})
aAdd(aSX3,{'SQS','30','QS_XMOTIVO','M',80,0,'Motivo','Motivo','Motivo','Motivo Canc/Susp/Reabertu','Motivo Canc/Susp/Reabertu','Motivo Canc/Susp/Reabertu','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016121411:03:40'})
aAdd(aSX6,{'','FS_CELADM','C','Conta de e-mail para à Célula de Admissão','','','','','','','','','','','','U','','','','','','','2016112917:19:14'})
aAdd(aSX6,{'','FS_CELCAD','C','Conta de e-mail para a Célula de Cadastro','','','','','','','','','','','','U','','','','','','','2016112917:19:14'})
aAdd(aSX6,{'','FS_RECSEL','C','Conta de e-mail para Recrutamento e Selecao','','','','','','','','','','','','U','','','','','','','2016112917:19:14'})
aAdd(aSXB,{'FSWRH3','1','01','RE','FSWRH3','FSWRH3','FSWRH3','RH3','','2016121411:04:05'})
aAdd(aSXB,{'FSWRH3','2','01','01','','','','U_F0500208(1)','','2016121411:04:05'})
aAdd(aSXB,{'FSWRH3','5','01','','','','','RH3_CODIGO','','2016121411:04:05'})
aAdd(aSXB,{'FSWPA5','1','01','RE','TIPO SOLICITACAO','TIPO SOLICITACAO','TIPO SOLICITACAO','PA7','','2017052611:25:26'})
aAdd(aSXB,{'FSWPA5','2','01','01','','','','U_F0500210()','','2017052611:25:26'})
aAdd(aSXB,{'FSWPA5','5','01','','','','','PA7_CODIGO','','2017052611:25:26'})
aAdd(aSX3Hlp,{'PA5_XNRSOL','Número da Solicitação'})
aAdd(aSX3Hlp,{'PA5_XDESOL','Descrição da Solicitação'})
aAdd(aSX3Hlp,{'PA5_XSTAT','Status Solicitação'})
aAdd(aSX3Hlp,{'PA5_XCODEV','Código Evento'})
aAdd(aSX3Hlp,{'PA5_XDESEV','Descrição do Evento'})
aAdd(aSX3Hlp,{'PA5_XNOME','Nome Solicitante'})
aAdd(aSX3Hlp,{'PA5_XMAT','Matricula Solicitante'})
aAdd(aSX3Hlp,{'PA5_XSETOR','Setor Solicitante'})
aAdd(aSX3Hlp,{'PA5_XUNIDA','Unidade  Solicitante'})
aAdd(aSX3Hlp,{'PA5_XCC','Centro de Custo Solicitante'})
aAdd(aSX3Hlp,{'PA5_FUNCAO','Função'})
aAdd(aSX3Hlp,{'PA5_XCARGO','Cargo Solicitante'})
aAdd(aSX3Hlp,{'PA5_XAPROV','Aprovador'})
aAdd(aSX3Hlp,{'PA5_XMATAP','Matricula Aprovador'})
aAdd(aSX3Hlp,{'PA5_XSEAPV','Setor Aprovador'})
aAdd(aSX3Hlp,{'PA5_XUNAPR','Unidade Aprovador'})
aAdd(aSX3Hlp,{'PA5_XCARAP','Cargo Aprovador'})
aAdd(aSX3Hlp,{'PA5_XCONTA','Numero da Conta Orçamentária'})
aAdd(aSX3Hlp,{'PA5_XEMPEN','Valor Empenhado'})
aAdd(aSX3Hlp,{'PA5_XDATA','Data da Movimentação'})
aAdd(aSX3Hlp,{'PA5_XHORA','Hora da Movimentação'})
aAdd(aSX3Hlp,{'PA5_XUSER','Usuario Logado no Sistema'})
aAdd(aSX3Hlp,{'QS_XSUSPEN','1=Aprovada;2=Em Recrutamento;3=Em Movimentação (RI);4=Em Admissão;5=Cancelada;6=Suspensa;7=Concluída'})
aAdd(aSX3Hlp,{'QS_XMOTIVO','Motivo Cancelamento/Suspensão/Reabertura'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
