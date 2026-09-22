/*
{Protheus.doc} U08004
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 10/03/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423042_EF_004
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08004(lOnlyInfo)
Local aInfo := {'08','004','CADASTRO DE ALÇADA','30/04/17','11:24','004704082010400418U0132','02/05/17','15:13','704132041201'}
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
aAdd(aSIX,{'PAB','1','PAB_FILIAL+PAB_CODIGO','Código','Código','Código','U','','','S','2017031010:49:10'})
aAdd(aSIX,{'PAB','2','PAB_FILIAL+PAB_TPSOLI+PAB_GRPSOL','Tp.Solicit.+Subgrupo','Tp.Solicit.+Subgrupo','Tp.Solicit.+Subgrupo','U','','','S','2017031010:49:10'})
aAdd(aSIX,{'PAC','1','PAC_FILIAL+PAC_CODALC+PAC_NIVEL','Cód.Alçada+Nível Aprov.','Cód.Alçada+Nível Aprov.','Cód.Alçada+Nível Aprov.','U','','','S','2017031010:49:10'})
aAdd(aSX2,{'PAB','','PAB010','CABEÇALHO CADASTRO ALÇADA','CABEÇALHO CADASTRO ALÇADA','CABEÇALHO CADASTRO ALÇADA','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017031010:49:08'})
aAdd(aSX2,{'PAC','','PAC010','ITENS DO CADASTRO DE ALÇADA','ITENS DO CADASTRO DE ALÇADA','ITENS DO CADASTRO DE ALÇADA','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017031010:49:08'})
aAdd(aSX3,{'PAB','01','PAB_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','02','PAB_CODIGO','C',6,0,'Código','Código','Código','Código Controle Alçada','Código Controle Alçada','Código Controle Alçada','@!','','€€€€€€€€€€€€€€ ','GETSX8NUM("PAB","PAB_CODIGO")','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','03','PAB_TPSOLI','C',3,0,'Tp.Solicit.','Tp.Solicit.','Tp.Solicit.','Código Tipo Solicitação','Código Tipo Solicitação','Código Tipo Solicitação','','','€€€€€€€€€€€€€€ ','','FSPA71',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','04','PAB_SOLDES','C',120,0,'Descrição','Descrição','Descrição','Descrição Tp.Solicitação','Descrição Tp.Solicitação','Descrição Tp.Solicitação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','05','PAB_GRPSOL','C',3,0,'Subgrupo','Subgrupo','Subgrupo','Subgrupo do Tp.Solicit.','Subgrupo do Tp.Solicit.','Subgrupo do Tp.Solicit.','','','€€€€€€€€€€€€€€ ','','FSPA72',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','06','PAB_GRPDES','C',120,0,'Descrição','Descrição','Descrição','Descrição do Subgrupo','Descrição do Subgrupo','Descrição do Subgrupo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','07','PAB_VISAO','C',6,0,'Visão','Visão','Visão','Código da visão','Código da visão','Código da visão','','','€€€€€€€€€€€€€€ ','','RDK',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','08','PAB_DESVIS','C',120,0,'Descrição','Descrição','Descrição','Descrição da Visão','Descrição da Visão','Descrição da Visão','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','09','PAB_NIVMIN','C',2,0,'Nível Minimo','Nível Minimo','Nível Minimo','Nivel minimo solicitante','Nivel minimo solicitante','Nivel minimo solicitante','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','01=RH;02=PA;03=Presidente;04=VP Executivo;05=Vice Presidente;06=Dir. Executivo;07=Diretor;08=Gerente;09=Superv;10=Lider;11=Livre','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','10','PAB_TPSOL','C',1,0,'Solicitante','Solicitante','Solicitante','Tipo de Solicitante','Tipo de Solicitante','Tipo de Solicitante','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','1=Todos os níveis inferiores;2=Apenas nível inferior imediato','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','11','PAB_LIMNIV','N',1,0,'Limite Nível','Limite Nível','Limite Nível','Limite de nível','Limite de nível','Limite de nível','9','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','12','PAB_APRMAX','C',2,0,'Aprov.Máximo','Aprov.Máximo','Aprov.Máximo','Aprovador Máximo','Aprovador Máximo','Aprovador Máximo','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','01=RH;02=PA;03=Presidente;04=VP Executivo;05=Vice Presidente;06=Dir. Executivo;07=Diretor;08=Gerente;09=Superv;10=Lider','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAB','13','PAB_NECAPV','C',1,0,'Necess. Aprv','Necess. Aprv','Necess. Aprv','Necessita Aprovação','Necessita Aprovação','Necessita Aprovação','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','A','R','','','1=SIM;2=NÃO','1=SIM;2=NÃO','1=SIM;2=NÃO','','','','','','','','','','N','N','','','','','2017043011:21:07'})
aAdd(aSX3,{'PAC','01','PAC_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017031010:49:02'})
aAdd(aSX3,{'PAC','02','PAC_CODALC','C',6,0,'Cód.Alçada','Cód.Alçada','Cód.Alçada','Código da Alçada','Código da Alçada','Código da Alçada','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAC','03','PAC_NIVEL','C',2,0,'Nível Aprov.','Nível Aprov.','Nível Aprov.','Nível de Aprovação','Nível de Aprovação','Nível de Aprovação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAC','04','PAC_APRNOT','C',1,0,'Aprov/Notif?','Aprov/Notif?','Aprov/Notif?','Aprovador/Notificador','Aprovador/Notificador','Aprovador/Notificador','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','A','R','','','1=Aprovador;2=Notificado','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAC','05','PAC_NOTREJ','C',1,0,'Notif.Rejeic','Notif.Rejeic','Notif.Rejeic','Notifica Rejeição','Notifica Rejeição','Notifica Rejeição','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','A','R','','','1=Sim;2=Não','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAC','06','PAC_NOTEFE','C',1,0,'Notif.Efetiv','Notif.Efetiv','Notif.Efetiv','Notifica Efetivação','Notifica Efetivação','Notifica Efetivação','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','A','R','','','1=Sim;2=Não','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAC','07','PAC_TIPAPR','C',1,0,'Tp.Aprovador','Tp.Aprovador','Tp.Aprovador','Tipo de Aprovador','Tipo de Aprovador','Tipo de Aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','1=Nível;2=Posto Fixo','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAC','08','PAC_NUMNIV','N',2,0,'Nível Super.','Nível Super.','Nível Super.','Nível Superior','Nível Superior','Nível Superior','99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAC','09','PAC_CODPOS','C',6,0,'Cód.Aprov.','Cód.Aprov.','Cód.Aprov.','Código de aprovação posto','Código de aprovação posto','Código de aprovação posto','','','€€€€€€€€€€€€€€ ','','FSPAD1',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSX3,{'PAC','10','PAC_DESPOS','C',120,0,'Descrição','Descrição','Descrição','Descrição grupo aprovação','Descrição grupo aprovação','Descrição grupo aprovação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017031010:49:02'})
aAdd(aSXB,{'FSPA71','1','01','RE','Tip.Solicitação','Tip.Solicitação','Tip.Solicitação','PA7','','2017031010:49:13'})
aAdd(aSXB,{'FSPA71','2','01','01','','','','U_F0800402()','','2017031010:49:13'})
aAdd(aSXB,{'FSPA71','5','01','','','','','PAB_TPSOLI','','2017031010:49:13'})
aAdd(aSXB,{'FSPA72','1','01','DB','SubGrupo','SubGrupo','SubGrupo','PA7','','2017031010:49:13'})
aAdd(aSXB,{'FSPA72','2','01','01','Codigo+cod.sub.grup','Codigo+cod.sub.grup','Codigo+cod.sub.grup','','','2017031010:49:13'})
aAdd(aSXB,{'FSPA72','4','01','01','Cod.Sub.Grup','Cod.Sub.Grup','Cod.Sub.Grup','PA7_CODSUB','','2017031010:49:13'})
aAdd(aSXB,{'FSPA72','4','01','02','Desc.Sub.Grp','Desc.Sub.Grp','Desc.Sub.Grp','PA7_DESSUB','','2017031010:49:13'})
aAdd(aSXB,{'FSPA72','5','01','','','','','PA7->PA7_CODSUB','','2017031010:49:13'})
aAdd(aSXB,{'FSPA72','5','02','','','','','PA7->PA7_DESSUB','','2017031010:49:13'})
aAdd(aSXB,{'FSPA72','6','01','','','','','PA7->PA7_CODIGO==M->PAB_TPSOLI','','2017031010:49:13'})
aAdd(aSXB,{'FSPAD1','1','01','DB','PostFilial Aprovação','PostFilial Aprovação','PostFilial Aprovação','PAD','','2017031010:49:13'})
aAdd(aSXB,{'FSPAD1','2','01','01','Codigo','Codigo','Codigo','','','2017031010:49:13'})
aAdd(aSXB,{'FSPAD1','4','01','01','Codigo','Codigo','Codigo','PAD_CODIGO','','2017031010:49:13'})
aAdd(aSXB,{'FSPAD1','4','01','02','Desc Grupo','Desc Grupo','Desc Grupo','PAD_DESCRI','','2017031010:49:13'})
aAdd(aSXB,{'FSPAD1','5','01','','','','','PAD->PAD_CODIGO','','2017031010:49:13'})
aAdd(aSX3Hlp,{'PAB_FILIAL','Filial do Sistema.'})
aAdd(aSX3Hlp,{'PAB_CODIGO','Código da Alçada.'})
aAdd(aSX3Hlp,{'PAB_TPSOLI','Código do Tipo de Solicitação'})
aAdd(aSX3Hlp,{'PAB_SOLDES','Descrição do tipo de solicitação.'})
aAdd(aSX3Hlp,{'PAB_GRPSOL','Código do subgrupo do tipo de solicitação.'})
aAdd(aSX3Hlp,{'PAB_GRPDES','Descrição do subgrupo do tipo de solicitação.'})
aAdd(aSX3Hlp,{'PAB_VISAO','Código da visão'})
aAdd(aSX3Hlp,{'PAB_DESVIS','Descrição da Visão'})
aAdd(aSX3Hlp,{'PAB_NIVMIN','Nível mínimo do solicitante(1=Presidente;2=VP Executivo;3=Vice Presidente;4=Diretor Executivo;5=Diretor;6=Gerente;7=Supervisor;8=Líder;9=Livre)'})
aAdd(aSX3Hlp,{'PAB_TPSOL','Tipo do Solicitante'})
aAdd(aSX3Hlp,{'PAB_LIMNIV','Número do nível caso o posto do superior direto não estiver ocupado.'})
aAdd(aSX3Hlp,{'PAB_APRMAX','Aprovador Máximo(1=Presidente;2=VP Executivo;3=Vice Presidente;4=Diretor Executivo;5=Diretor;6=Gerente;7=Supervisor;8=Líder)'})
aAdd(aSX3Hlp,{'PAC_FILIAL','Filial do sistema'})
aAdd(aSX3Hlp,{'PAC_CODALC','código da alçada'})
aAdd(aSX3Hlp,{'PAC_NIVEL','Nível de aprovação'})
aAdd(aSX3Hlp,{'PAC_APRNOT','Aprovador ou Notificado(1=Aprovador;2=Notificado)'})
aAdd(aSX3Hlp,{'PAC_NOTREJ','Notifica em caso de rejeição da solicitação(1=Sim;2=Não).'})
aAdd(aSX3Hlp,{'PAC_NOTEFE','Notifica em caso de efetivação da solicitação(1=Sim;2=Não).'})
aAdd(aSX3Hlp,{'PAC_TIPAPR','Tipo de Aprovador(1=Nível;2=Posto Fixo)'})
aAdd(aSX3Hlp,{'PAC_NUMNIV','Nível que irá subir na hierarquia'})
aAdd(aSX3Hlp,{'PAC_CODPOS','Código de aprovação por posto fixo'})
aAdd(aSX3Hlp,{'PAC_DESPOS','Descrição do grupo de aprovação'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
