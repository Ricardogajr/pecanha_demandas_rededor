/*
{Protheus.doc} U03002
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 22/11/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000004_EF_002
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U03002(lOnlyInfo)
Local aInfo := {'03','002','PLANO DE AÇÕES PESQUISA DE CLIMA','22/12/16','17:21','002621032110200273U0122','29/12/16','14:27',''}
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
aAdd(aSIX,{'PA4','1','PA4_FILIAL+PA4_XCOD+DTOS(PA4_XDTIN)','Cod.Pesquisa+Data Inicio','Cod.Pesquisa+Data Inicio','Cod.Pesquisa+Data Inicio','U','','','S','2016122117:21:06'})
aAdd(aSX1,{'F0300202','01','Filial De ?','','','MV_CH0','C',08,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','SM0','','','','','','2016122117:21:06'})
aAdd(aSX1,{'F0300202','02','Filial Ate ?','','','MV_CH0','C',08,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','SM0','','','','','','2016122117:21:06'})
aAdd(aSX1,{'F0300202','03','Cod.Pesquisa De ?','','','MV_CH0','C',06,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','FSWRD5','','','','','','2016122117:21:06'})
aAdd(aSX1,{'F0300202','04','Cod.Pesquisa Ate ?','','','MV_CH0','C',06,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','FSWRD5','','','','','','2016122117:21:06'})
aAdd(aSX1,{'F0300202','05','Data Inicio De ?','','','MV_CH0','D',08,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2016122117:21:06'})
aAdd(aSX1,{'F0300202','06','Data Inicio Ate ?','','','MV_CH0','D',08,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2016122117:21:06'})
aAdd(aSX2,{'PA4','','PA4010','CONTROLE DE PESQUISA DE CLIMA','CONTROLE DE PESQUISA DE CLIMA','CONTROLE DE PESQUISA DE CLIMA','','E','E','E',0,'','','',0,'','','','','','',0,0,0,'2016122117:21:06'})
aAdd(aSX3,{'PA4','01','PA4_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','08','PA4_XCOD','C',6,0,'Cod.Pesquisa','Cod.Pesquisa','Cod.Pesquisa','Codigo da pesquisa','Codigo da pesquisa','Codigo da pesquisa','@!','','€€€€€€€€€€€€€€ ','','FSWRD5',0,'þÀ','','','U','S','A','R','€','U_F0300203()','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','09','PA4_XFIL','C',8,0,'Cod.Unidade','Cod.Unidade','Cod.Unidade','Codigo da unidade','Codigo da unidade','Codigo da unidade','@!','','€€€€€€€€€€€€€€ ','','SM0',0,'þÀ','','S','U','S','A','R','€','U_F0300204()','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','10','PA4_XDFIL','C',81,0,'Descr.Filial','Descr.Filial','Descr.Filial','Descrição Filial','Descrição Filial','Descrição Filial','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','V','','','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','11','PA4_XDIR','C',30,0,'Diretoria','Diretoria','Diretoria','Descrição da Diretoria','Descrição da Diretoria','Descrição da Diretoria','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','12','PA4_XAREA','C',30,0,'Area Pesquis','Area Pesquis','Area Pesquis','Area Pesquisada','Area pesquisada','Area pesquisada','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','13','PA4_XSETO','C',30,0,'Setor','Setor','Setor','Setor','Setor','Setor','@!','','€€€€€€€€€€€€€€ ','','SQB',0,'þÀ','','S','U','S','A','R','','U_F0300206()','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','14','PA4_XDSET','C',30,0,'Descri Setor','Descri Setor','Descri Setor','Descrição do Setor','Descrição do Setor','Descrição do Setor','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','15','PA4_XMAT','C',6,0,'Matricula','Matricula','Matricula','Matricula','Matricula','Matricula','@!','','€€€€€€€€€€€€€€ ','','FSWSRA',0,'þÀ','','S','U','S','A','R','€','U_F0300205()','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','16','PA4_XPART','C',60,0,'Nome.Respons','Nome.Respons','Nome.Respons','Nome do Responsavel','Nome do Responsavel','Nome do Responsavel','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','17','PA4_XACAO','C',60,0,'Acao Tomada','Acao Tomada','Acao Tomada','Ação a ser Tomada','Ação a ser Tomada','Ação a ser Tomada','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','INCLUI','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','18','PA4_XDTIN','D',8,0,'Data Inicio','Data Inicio','Data Inicio','Data Inicio','Data Inicio','Data Inicio','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','INCLUI','','','','','','','','N','N','','','','2','2016122117:21:06'})
aAdd(aSX3,{'PA4','19','PA4_XPRAZ','N',3,0,'Prazo Conclu','Prazo Conclu','Prazo Conclu','Prazo para conclusão ação','Prazo para conclusão ação','Prazo para conclusão ação','@E 999','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','INCLUI','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','20','PA4_XDTCO','D',8,0,'Data Conclus','Data Conclus','Data Conclus','Data da conclusão da ação','Data da conclusão da ação','Data da conclusão da ação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','!INCLUI','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','21','PA4_XOBS','M',10,0,'Observações','Observações','Observações','Observações','Observações','Observações','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX3,{'PA4','22','PA4_XSTART','C',1,0,'Status Ação','Status Ação','Status Ação','Status Ação','Status Ação','Status Ação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','1=Iniciado;2=Suspenso;3=Cancelado;4=Concluido','','','','','','','','','','','','N','N','','','','2016122117:21:06'})
aAdd(aSX7,{'PA4_XFIL','001','Alltrim(SM0->M0_FILIAL)+" - "+ Alltrim(SM0->M0_NOME)','PA4_XDFIL','P','S','SM0',1,'cEmpAnt+M->PA4_XFIL','','U','2016122117:21:06'})
aAdd(aSX7,{'PA4_XMAT','001','SRA->RA_NOME','PA4_XPART','P','S','SRA',1,'xFilial("SRA")+M->PA4_XMAT','','U','2016122117:21:06'})
aAdd(aSX7,{'PA4_XSETO','001','SQB->QB_DESCRIC','PA4_XDSET','P','S','SQB',1,'xFilial("SQB")+M->PA4_XSETO','','U','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','1','01','DB','TIPO AVALIACAO','TIPO AVALIACAO','TIPO AVALIACAO','RD5','','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','2','01','01','Codigo','Codigo','Code','','','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','2','02','02','Descricao + Codigo','Descripcion + Codigo','Description + Code','','','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','3','01','01','Cadastra Novo','Incluye Nuevo','Add New','01','','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','4','01','01','Codigo','Codigo','Code','RD5_CODTIP','','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','4','01','02','Descricao','Descripcion','Description','RD5_DESC','','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','4','02','01','Codigo','Codigo','Code','RD5_CODTIP','','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','4','02','02','Descricao','Descripcion','Description','RD5_DESC','','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','5','01','','','','','RD5->RD5_CODTIP','','2016122117:21:06'})
aAdd(aSXB,{'FSWRD5','6','01','','','','','RD5->RD5_TIPO == "2"','','2016122117:21:06'})
aAdd(aSX3Hlp,{'PA4_XCOD','Codigo da pesquisade clima.'})
aAdd(aSX3Hlp,{'PA4_XFIL','Codigo da unidade'})
aAdd(aSX3Hlp,{'PA4_XDFIL','Descrição Filial'})
aAdd(aSX3Hlp,{'PA4_XDIR','Descrição da Diretoria'})
aAdd(aSX3Hlp,{'PA4_XAREA','Area pesquisada'})
aAdd(aSX3Hlp,{'PA4_XSETO','Setor Pesquisado.'})
aAdd(aSX3Hlp,{'PA4_XDSET','Descrição do Setor'})
aAdd(aSX3Hlp,{'PA4_XMAT','Matricula'})
aAdd(aSX3Hlp,{'PA4_XPART','Nome.Respons'})
aAdd(aSX3Hlp,{'PA4_XACAO','Ação a ser Tomada'})
aAdd(aSX3Hlp,{'PA4_XDTIN','Data Inicio'})
aAdd(aSX3Hlp,{'PA4_XPRAZ','Prazo para conclusão ação'})
aAdd(aSX3Hlp,{'PA4_XDTCO','Data da conclusão da ação'})
aAdd(aSX3Hlp,{'PA4_XOBS','Observações'})
aAdd(aSX3Hlp,{'PA4_XSTART','Status Ação'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
