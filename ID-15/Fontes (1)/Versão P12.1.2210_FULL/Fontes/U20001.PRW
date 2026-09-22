/*
{Protheus.doc} U20001
Função de instalação de dicionario especifico.
@author	FsTools V6.2.15
@since 19/05/2021 
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
*/
#INCLUDE 'PROTHEUS.CH'
User Function U20001(lOnlyInfo)
Local aInfo := {'20','001','INTEGRAÇÃO TÍTULOS PREVISTOS - XRT','19/05/21','10:17','021197002012100500U0211','11/08/21','14:25','197211050201'}
Local aSIX	:= {}
Local aSX1	:= {}
Local aSX2	:= {}
Local aSX3	:= {}
Local aSX6	:= {}
Local aSX7	:= {}
Local aSXA	:= {}
Local aSXB	:= {}
Local aSX1Hlp := {}
Local aSX3Hlp := {}
Local aCarga  := {}
DEFAULT lOnlyInfo := .f.
If lOnlyInfo
	Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
EndIf
aAdd(aSIX,{'PX0','1','PX0_FILIAL+PX0_ORIGEM+PX0_CHAVE+PX0_EXC','Tab. Origem+Chave do Tit+Excluído XRT','Tab. Origem+Chave do Tit+Excluído XRT','Tab. Origem+Chave do Tit+Excluído XRT','U','','','S','','','2021051910:09:28'})
aAdd(aSIX,{'PX0','2','PX0_FILIAL+PX0_STTIT+PX0_ORIGEM+PX0_CHAVE+PX0_EXC','St.Tit(Temp)+Tab. Origem+Chave do Tit+Excluído XRT','St.Tit(Temp)+Tab. Origem+Chave do Tit+Excluído XRT','St.Tit(Temp)+Tab. Origem+Chave do Tit+Excluído XRT','U','','','S','','','2021051910:09:28'})
aAdd(aSIX,{'PX0','3','PX0_FILIAL+PX0_CHVXRT','Chave XRT','Chave XRT','Chave XRT','U','','','S','','','2021051910:09:28'})
aAdd(aSIX,{'PX0','4','PX0_FILIAL+PX0_DTHR+PX0_CHVXRT','Dt. Hr.+Chave XRT','Dt. Hr.+Chave XRT','Dt. Hr.+Chave XRT','U','','','S','','','2021051910:09:28'})
aAdd(aSIX,{'PX0','5','PX0_FILIAL+PX0_STTIT+PX0_NUMBOR','St.Tit(Temp)+Borderô','St.Tit(Temp)+Borderô','St.Tit(Temp)+Borderô','U','','','S','','','2021051910:09:28'})
aAdd(aSIX,{'PX1','1','PX1_FILIAL+PX1_EMPINT+PX1_FILINT','Grp. Empresa+Filial','Grp. Empresa+Filial','Grp. Empresa+Filial','U','','','S','','','2021073111:01:05'})
aAdd(aSX2,{'PX0','','PX0990','Títulos Integração XRT','Títulos Integração XRT','Títulos Integração XRT','','E','E','E',0,'','','',0,'','','','','','',2,0,0,'2021051910:09:07'})
aAdd(aSX2,{'PX1','','PX1990','Integ. XRT - Empresas Habil.','Integ. XRT - Empresas Habil.','Integ. XRT - Empresas Habil.','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2021073111:00:53'})
aAdd(aSX3,{'PX0','01','PX0_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'€€','','','U','N','','','','','','','','','','','033','','','','','','','','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','02','PX0_ORIGEM','C',3,0,'Tab. Origem','Tab. Origem','Tab. Origem','Tabela de Origem','Tabela de Origem','Tabela de Origem','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','03','PX0_CHAVE','C',60,0,'Chave do Tit','Chave do Tit','Chave do Tit','Chave do Título','Chave do Título','Chave do Título','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','04','PX0_STTIT','C',1,0,'St.Tit(Temp)','St.Tit(Temp)','St.Tit(Temp)','Status Título (Temp.)','Status Título (Temp.)','Status Título (Temp.)','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','S','V','R','','','1=Temp -1;2=Temp 1;3=Temp 2','1=Temp -1;2=Temp 1;3=Temp 2','1=Temp -1;2=Temp 1;3=Temp 2','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','05','PX0_STXRT','C',1,0,'St. Integ','St. Integ','St. Integ','Status Integração','Status Integração','Status Integração','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','S','V','R','','','1=Pendente Integ.;2=Integ. Sucesso;3=Falha Comunic.;4=Falha de Dados;5=Enviado ao Barramento','1=Pendente Integ.;2=Integ. Sucesso;3=Falha Comunic.;4=Falha de Dados;5=Enviado ao Barramento','1=Pendente Integ.;2=Integ. Sucesso;3=Falha Comunic.;4=Falha de Dados;5=Enviado ao Barramento','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','06','PX0_STINT','C',1,0,'Flag Integ.','Flag Integ.','Flag Integ.','Flag de Integração','Flag de Integração','Flag de Integração','','','€€€€€€€€€€€€€€ ','"2"','',0,'þÀ','','','U','S','V','R','','','1=Sim;2=Não','1=Sim;2=Não','1=Sim;2=Não','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','07','PX0_VALOR','N',16,2,'Valor Tít.','Valor Tít.','Valor Tít.','Valor do Título','Valor do Título','Valor do Título','@E 9,999,999,999,999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','08','PX0_CNAB','C',10,0,'ID CNAB','ID CNAB','ID CNAB','ID CNAB','ID CNAB','ID CNAB','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','09','PX0_NUMBOR','C',6,0,'Borderô','Borderô','Borderô','Borderô','Borderô','Borderô','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','10','PX0_NUMBCO','C',15,0,'Cheque','Cheque','Cheque','Cheque','Cheque','Cheque','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','11','PX0_CHVXRT','C',30,0,'Chave XRT','Chave XRT','Chave XRT','Chave XRT','Chave XRT','Chave XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','12','PX0_EXC','C',1,0,'Excluído XRT','Excluído XRT','Excluído XRT','Excluído XRT','Excluído XRT','Excluído XRT','','','€€€€€€€€€€€€€€ ','"2"','',0,'þÀ','','','U','S','V','R','','','1=Sim;2=Não','1=Sim;2=Não','1=Sim;2=Não','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','13','PX0_DADOS','M',10,0,'Dados Título','Dados Título','Dados Título','Dados Título','Dados Título','Dados Título','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','14','PX0_MSGXRT','M',10,0,'Msg XRT','Msg XRT','Msg XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'PX0','15','PX0_IDP20','C',44,0,'ID Log Int','ID Log Int','ID Log Int','ID Log Int','ID Log Int','ID Log Int','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021062509:20:48'})
aAdd(aSX3,{'PX0','16','PX0_DTHR','C',14,0,'Dt. Hr.','Dt. Hr.','Dt. Hr.','Dt. Hr.','Dt. Hr.','Dt. Hr.','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:23'})
aAdd(aSX3,{'SE2','DB','E2_XMSGXRT','M',10,0,'Mensagem XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021051910:07:59'})
aAdd(aSX3,{'SE2','DC','E2_XENVBCO','C',1,0,'Enviado Bco','Enviado Bco','Enviado Bco','Enviado ao Banco','Enviado ao Banco','Enviado ao Banco','','','€€€€€€€€€€€€€€€','"2"','',0,'þÀ','','','U','N','V','R','','','1=Sim;2=Não','1=Sim;2=Não','1=Sim;2=Não','','','','','','','','','','N','N','','','','','','2021052514:53:45'})
aAdd(aSX3,{'PX1','01','PX1_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'€€','','','U','N','','','','','','','','','','','033','','','','','','','','','','','','','2021073110:59:34'})
aAdd(aSX3,{'PX1','02','PX1_EMPINT','C',2,0,'Grp. Empresa','Grp. Empresa','Grp. Empresa','Grupo Empresa','Grupo Empresa','Grupo Empresa','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','INCLUI','','','','','','','','N','N','','','','','','2021073110:59:34'})
aAdd(aSX3,{'PX1','03','PX1_FILINT','C',8,0,'Filial','Filial','Filial','Filial','Filial','Filial','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','INCLUI','','','','','','','','N','N','','','','','','2021073110:59:34'})
aAdd(aSX3,{'PX1','04','PX1_ATIVO','C',1,0,'Ativo?','Ativo?','Ativo?','Ativa integração?','Ativa integração?','Ativa integração?','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','S','A','R','€','','1=Sim;2=Não','1=Sim;2=Não','1=Sim;2=Não','','','','','','','','','','N','N','','','','','','2021073110:59:34'})
aAdd(aSX6,{'','FS_N010010','N','Número de títulos a serem integrados por chamada','Número de títulos a serem integrados por chamada','Número de títulos a serem integrados por chamada','do barramento ao XRT.','do barramento ao XRT.','do barramento ao XRT.','','','','100','100','100','U','','','','','','','','2021051910:11:12'})
aAdd(aSX6,{'','FS_N010011','N','Timeout, em segundos, da chamada do WebService','Timeout, em segundos, da chamada do WebService','Timeout, em segundos, da chamada do WebService','','','','','','','120','120','120','U','','','','','','','','2021051910:11:12'})
aAdd(aSX6,{'','FS_C200012','C','Integração XRT: Informar o E-mail dos responsáveis','Integração XRT: Informar o E-mail dos responsáveis','Integração XRT: Informar o E-mail dos responsáveis','que deverão ser notificados, no caso de erro de','que deverão ser notificados, no caso de erro de','que deverão ser notificados, no caso de erro de','título enviado ao XRT, separados por ;','título enviado ao XRT, separados por ;','título enviado ao XRT, separados por ;','','','','U','','','','','','','','2021062417:15:33'})
aAdd(aSX6,{'','FS_N200014','N','Integração XRT: Periodo, em dias, para considerar','Integração XRT: Periodo, em dias, para considerar','Integração XRT: Periodo, em dias, para considerar','a data de vencimento máxima a integrar','a data de vencimento máxima a integrar','a data de vencimento máxima a integrar','titulos previstos','titulos previstos','titulos previstos','90','90','90','U','','','','','','','','2021051910:11:12'})
aAdd(aSX3Hlp,{'PX0_ORIGEM','Tabela de origem do título. SE2 ou FK2'})
aAdd(aSX3Hlp,{'PX0_CHAVE','Chave única do título ou da baixa  E2_FILIAL + E2_PREFIXO + E2_NUM +  E2_PARCELA + E2_TIPO + E2_FORNECE +  E2_LOJA  ou  FK2_FILIAL+FK2_IDFK2'})
aAdd(aSX3Hlp,{'PX0_STTIT','Equivalente a Temperatura do título. 1=Temp -1 - Baixas de título/Realizado, 2=Temp 1 - Títulos enviados ao banco/Previsão, 3=Temp 2 - Títulos em aberto/Previsão.  Por padrão, títulos baixados  integralmente ou parcialmente não podem  ser excluídos'})
aAdd(aSX3Hlp,{'PX0_STXRT','1-Pendente Integração (ou vazio)  2-Integrado com Sucesso  3-Falha na comunicação  4-Falha nos dados  5-Enviado ao barramento  Obs.: Caso ocorra falha na comunicação,  o registro poderá ser integrado  novamente. Caso ocorra falha nos dados,  o usuário precisará corrigir o título  antes de reenviar, atualizando  automaticamente o status para  1-pendenteintegração.'})
aAdd(aSX3Hlp,{'PX0_STINT','Indica se o registro já foi integrado  emalgum momento ao XRT.'})
aAdd(aSX3Hlp,{'PX0_VALOR','Valor do Título. Valores zerados  indicamexclusão no XRT, e valores  negativos    indicam estorno'})
aAdd(aSX3Hlp,{'PX0_CNAB','Preenchido com E2_IDCNAB nos pontos  ondeocorre alteração da PX0.'})
aAdd(aSX3Hlp,{'PX0_NUMBOR','Borderô do título'})
aAdd(aSX3Hlp,{'PX0_NUMBCO','Número do cheque do título'})
aAdd(aSX3Hlp,{'PX0_CHVXRT','Sequencial único do PX0_CHVXRT. Os  primeiros caracteres compõem empresa e  filial, e demais campos da chave são  sequenciais'})
aAdd(aSX3Hlp,{'PX0_EXC','Excluído no XRT 1-Sim;2-Não. É  utilizadopara manter histórico da PX0, e  eventualmente criar uma linha  nova no   XRT, para um mesmo título do  Protheus.'})
aAdd(aSX3Hlp,{'PX0_DADOS','Dados do título que são enviados para o  XRT, no formato JSON. Grava apenas os  campos que são integrados'})
aAdd(aSX3Hlp,{'PX0_MSGXRT','Mensagem retornada pelo XRT em caso de  falha na integração.'})
aAdd(aSX3Hlp,{'PX0_IDP20','ID da tabela de log de integração (P20)'})
aAdd(aSX3Hlp,{'PX0_DTHR','Armazena a data/hora da gravação da PX0'})
aAdd(aSX3Hlp,{'E2_XMSGXRT','Mensagem retornada pelo XRT em caso de  falha na integração.'})
aAdd(aSX3Hlp,{'E2_XENVBCO','Indica se foi enviado ao banco ou não.  Égravado no momento da geração do CNAB,  eatualizado na rejeição do retorno  bancário. Caso o retorno realize a  baixa, não é alterado.  Utilizado para indicar, na integração  doXRT, se a baixa gerada na FK2 deve ser  integrada ou não. Caso a baixa gerada  esteja vínculada a título enviado ao  banco, não é necessário reenviar ao XRT.'})
aAdd(aSX3Hlp,{'PX1_EMPINT','Grupo da empresa'})
aAdd(aSX3Hlp,{'PX1_FILINT','Filial'})
aAdd(aSX3Hlp,{'PX1_ATIVO','Indica se as integrações estão ativas  nesta empresa'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga,aSX1Hlp}
