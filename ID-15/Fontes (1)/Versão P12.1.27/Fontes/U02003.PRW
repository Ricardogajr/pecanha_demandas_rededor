/*
{Protheus.doc} U02003
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 27/12/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000463301_EF_003
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U02003(lOnlyInfo)
Local aInfo := {'02','003','SOLICITAÇÃO PORTAL','02/02/17','13:35','003725022010300232U0103','21/06/17','18:14',''}
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
aAdd(aSIX,{'PA3','1','PA3_FILIAL+PA3_XMATRI+PA3_XSETOR+PA3_XCENTR+PA3_XUNIDA','Matricula+Setor+C. Custo+Unidade','Matricula+Setor+C. Custo+Unidade','Matricula+Setor+C. Custo+Unidade','U','','FSW0201','S','2017020213:35:10'})
aAdd(aSIX,{'PA3','2','PA3_FILIAL+PA3_XMATRI+PA3_XSETOR+PA3_XUNIDA','Matricula+Setor+Unidade','Matricula+Setor+Unidade','Matricula+Setor+Unidade','U','','FSW0202','S','2017020213:35:10'})
aAdd(aSIX,{'PA3','3','PA3_FILIAL+PA3_XCOD','Código','Código','Código','U','','FSW0203','S','2017020213:35:10'})
aAdd(aSIX,{'PA3','4','PA3_FILIAL+PA3_XMATRI','Matricula','Matricula','Matricula','U','','FSW0204','S','2017020213:35:10'})
aAdd(aSIX,{'PA3','5','PA3_FILIAL+PA3_XTIPO','Tp Curso','Tp Curso','Tp Curso','U','','FSW0205','S','2017020213:35:10'})
aAdd(aSIX,{'PA3','6','PA3_FILIAL+PA3_XMATRI+PA3_XTIPO','Matricula+Tp Curso','Matricula+Tp Curso','Matricula+Tp Curso','U','','FSW0206','S','2017020213:35:10'})
aAdd(aSX2,{'PA3','','PA3010','INCENTIVO A EDUCAÇÃO','INCENTIVO A EDUCAÇÃO','INCENTIVO A EDUCAÇÃO','','C','C','C',0,'','','',0,'','','','2','1','',0,0,0,'2017020213:35:08'})
aAdd(aSX3,{'PA3','01','PA3_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','A','R','','','','','','','','','033','','','','','','N','N','','','','2017020213:34:58'})
aAdd(aSX3,{'PA3','02','PA3_XSTATU','C',1,0,'Status','Status','Status','Status Solicitação','Status Solicitação','Status Solicitação','@!','','€€€€€€€€€€€€€€€','"3"','',0,'þÀ','','','U','N','V','R','€','','1=Aprovado;2=Reprovado;3=Aguardando Aprovação','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','03','PA3_XCOD','C',6,0,'Código','Código','Código','Codigo da Solicitação','Codigo da Solicitação','Codigo da Solicitação','999999','','€€€€€€€€€€€€€€ ','GETSX8NUM("PA3","PA3_XCOD")','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','04','PA3_XMATRI','C',6,0,'Matricula','Matricula','Matricula','Matricula do Participante','Matricula do Participante','Matricula do Participante','@!','','€€€€€€€€€€€€€€ ','','FSWSRA',0,'þÀ','','S','U','S','A','R','€','','','','','','INCLUI','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','05','PA3_XNOME','C',30,0,'Nome','Nome','Nome','Nome do participante','Nome do participante','Nome do participante','@!','','€€€€€€€€€€€€€€ ','IIF(!INCLUI,POSICIONE("SRA",1,XFILIAL("SRA")+M->PA3_XMATRI,"RA_NOME"),"")','',0,'þÀ','','','U','S','V','V','','','','','','','','POSICIONE("SRA",1, XFILIAL("SRA")+PA3->PA3_XMATRI,"RA_NOME")','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','06','PA3_XCENTR','C',11,0,'C. Custo','C. Custo','C. Custo','Centro de Custo','Centro de Custo','Centro de Custo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','07','PA3_XNOMCC','C',20,0,'Desc.C.Custo','Desc.C.Custo','Desc.C.Custo','Descrição Centro de Custo','Descrição Centro de Custo','Descrição Centro de Custo','@!','','€€€€€€€€€€€€€€ ','IIF(!INCLUI,POSICIONE("CTT",1,XFILIAL("CTT")+M->PA3_XCENTR,"CTT_DESC01"),"")','',0,'þÀ','','','U','N','V','V','','','','','','','','','','','','','','','N','N','','','2','2017020213:34:59'})
aAdd(aSX3,{'PA3','08','PA3_XCARGO','C',5,0,'Cargo','Cargo','Cargo','Cargo do Participante','Cargo do Participante','Cargo do Participante','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','09','PA3_XNMCRG','C',30,0,'Descrição','Descrição','Descrição','Descrição do Cargo','Descrição do Cargo','Descrição do Cargo','@!','','€€€€€€€€€€€€€€ ','IIF(!INCLUI,POSICIONE("SQ3",1,XFILIAL("SQ3") + M->PA3_XCARGO,"Q3_DESCSUM"),"")','',0,'þÀ','','S','U','N','V','V','','','','','','','','','','','','','','','N','N','','','2','2017020213:34:59'})
aAdd(aSX3,{'PA3','10','PA3_XSETOR','C',30,0,'Setor','Setor','Setor','Setor do Participante','Setor do Participante','Setor do Participante','@!','','€€€€€€€€€€€€€€ ','IIF(!INCLUI,POSICIONE("SQB",1,XFILIAL("SQB")+M->PA3_XMATRI,"QB_DESCRIC"),"")','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','11','PA3_XUNIDA','C',8,0,'Unidade','Unidade','Unidade','Unidade do Participante','Unidade do Participante','Unidade do Participante','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','12','PA3_XNMUNI','C',25,0,'Nome Unidade','Nome Unidade','Nome Unidade','Nome da Unidade','Nome da Unidade','Nome da Unidade','@!','','€€€€€€€€€€€€€€ ','IIF(INCLUI,"",FWFILIALNAME(,M->PA3_XUNIDA,1))','',0,'þÀ','','','U','N','V','V','','','','','','','','','','','','','','','N','N','','','2','2017020213:34:59'})
aAdd(aSX3,{'PA3','13','PA3_XTIPO','C',2,0,'Tipo Curso','Tipo Curso','Tipo Curso','Tipo do curso','Tipo do curso','Tipo do curso','@!','','€€€€€€€€€€€€€€ ','','FSWRIS',0,'þÀ','','S','U','S','A','R','€','ExistCpo("RIS","83"+M->PA3_XTIPO,1)','','','','','INCLUI','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','14','PA3_DSCTPC','C',20,0,'Descrição','Descrição','Descrição','Descrição tipo de curso','Descrição tipo de curso','Descrição tipo de curso','@!','','€€€€€€€€€€€€€€ ','IIF(!INCLUI,POSICIONE("RIS",1, XFILIAL("RIS")+"83"+M->PA3_XTIPO,"RIS_DESC"),"")','',0,'þÀ','','','U','S','V','V','','','','','','','','POSICIONE("RIS",1, XFILIAL("RIS")+"83"+PA3->PA3_XTIPO,"RIS_DESC")','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','15','PA3_XINSTI','C',6,0,'Instituição','Instituição','Instituição','Instituição realizadora','Instituição realizadora','Instituição realizadora','@!','','€€€€€€€€€€€€€€ ','','RA0',0,'þÀ','','S','U','N','A','R','€','ExistCpo("RA0")','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','16','PA3_NMINST','C',40,0,'Nome','Nome','Nome','Nome da Instituição','Nome da Instituição','Nome da Instituição','@!','','€€€€€€€€€€€€€€ ','POSICIONE("RA0",1,XFILIAL("RA0")+M->PA3_XINSTI,"RA0_DESC")','',0,'þÀ','','','U','N','V','V','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','17','PA3_XCURS','C',50,0,'Nome Curso','Nome Curso','Nome Curso','Nome do curso','Nome do curso','Nome do curso','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','18','PA3_XTELEF','C',11,0,'Telefone','Telefone','Telefone','Telefone Curso','Telefone Curso','Telefone Curso','@R (99) 999999999','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','19','PA3_XRAMAL','C',4,0,'Ramal','Ramal','Ramal','Ramal Curso','Ramal Curso','Ramal Curso','9999','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','20','PA3_XEMAIL','C',60,0,'E-mail','E-mail','E-mail','E-mail Curso','E-mail Curso','E-mail Curso','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','21','PA3_XINICI','D',8,0,'Inicio','Inicio','Inicio','Data de início do curso','Data de início do curso','Data de início do curso','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','22','PA3_XTERMI','D',8,0,'Termino','Termino','Termino','Data de termino do curso','Data de termino do curso','Data de termino do curso','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','23','PA3_XDURAC','N',3,0,'Duração','Duração','Duração','Duração do curso em dias','Duração do curso em dias','Duração do curso em dias','999','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','!NEGATIVO()','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','24','PA3_XMENSL','N',12,2,'Mensalidade','Mensalidade','Mensalidade','Valor da mensalidade','Valor da mensalidade','Valor da mensalidade','@E 999,999,999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','Positivo()','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','25','PA3_XVLTAL','N',12,2,'Investimento','Investimento','Investimento','Investimento do curso ano','Investimento do curso ano','Investimento do curso ano','@E 999,999,999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','Positivo()','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','26','PA3_XVLTCU','N',12,2,'Total Curso','Total Curso','Total Curso','Valor Total do curso','Valor Total do curso','Valor Total do curso','@E 999,999,999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','Positivo()','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','27','PA3_XPCBEN','N',6,2,'%Beneficio','%Beneficio','%Beneficio','% Beneficio Concedido','% Beneficio Concedido','% Beneficio Concedido','@E 999.99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','Positivo()','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','28','PA3_XOBSER','M',200,0,'Observação','Observação','Observação','Observação','Observação','Observação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','29','PA3_XSOLIC','C',6,0,'Solicitante','Solicitante','Solicitante','Código do Solicitante','Código do Solicitante','Código do Solicitante','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','30','PA3_XNMSOL','C',30,0,'Nome','Nome','Nome','Nome do solicitante','Nome do solicitante','Nome do solicitante','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','V','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'PA3','31','PA3_RSPAPR','C',6,0,'Resp.Aprov.','Resp.Aprov.','Resp.Aprov.','Responsavel Aprovação','Responsavel Aprovação','Responsavel Aprovação','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017020213:34:59'})
aAdd(aSX3,{'RH3','25','RH3_XTPCTM','C',3,0,'Tipo Solicit','Tipo Solicit','Tipo Solicit','Tipo Solicit customizada','Tipo Solicit customizada','Tipo Solicit customizada','@!','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017020213:35:00'})
aAdd(aSX3,{'RH4','08','RH4_XOBS','M',10,0,'Observacao','Observacao','Observacao','Observaçao solicitação','Observaçao solicitação','Observaçao solicitação','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017020213:35:00'})
aAdd(aSX7,{'PA3_XINSTI','001','Posicione("RA0",1,xFilial("RA0")+M->PA3_XINSTI,"RA0_DESC")','PA3_NMINST','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSX7,{'PA3_XMATRI','001','SRA->RA_NOME','PA3_XNOME','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSX7,{'PA3_XMATRI','002','SRA->RA_CC','PA3_XCENTR','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSX7,{'PA3_XMATRI','003','POSICIONE("CTT",1,XFILIAL("CTT")+SRA->RA_CC,"CTT_DESC01")','PA3_XNOMCC','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSX7,{'PA3_XMATRI','004','SRA->RA_CARGO','PA3_XCARGO','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSX7,{'PA3_XMATRI','005','POSICIONE("SQ3",1,XFILIAL("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM")','PA3_XNMCRG','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSX7,{'PA3_XMATRI','006','POSICIONE("SQB",1,XFILIAL("SQB")+SRA->RA_DEPTO,"QB_DESCRIC")','PA3_XSETOR','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSX7,{'PA3_XMATRI','007','SRA->RA_FILIAL','PA3_XUNIDA','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSX7,{'PA3_XMATRI','008','FWFILIALNAME(,SRA->RA_FILIAL,1)','PA3_XNMUNI','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSX7,{'PA3_XTIPO','001','Posicione("RIS",1,xFilial("RIS")+"83"+M->PA3_XTIPO,"RIS_DESC")','PA3_DSCTPC','P','N','',0,'','','U','2017020213:35:12'})
aAdd(aSXB,{'FSWRIS','1','01','DB','Outros Benefic','Outros Benefic','Outros Benefic','RIS','','2017020213:35:16'})
aAdd(aSXB,{'FSWRIS','2','01','01','Tipo Benef + Cod.ben','Tipo Benef + Cod.ben','Benefit Type + Benef','','','2017020213:35:16'})
aAdd(aSXB,{'FSWRIS','4','01','01','Cod.Benef','Cod.Benef','Benefit Code','RIS_COD','','2017020213:35:16'})
aAdd(aSXB,{'FSWRIS','4','01','02','Desc. Benef','Desc. Benef','Benefit Desc','RIS_DESC','','2017020213:35:16'})
aAdd(aSXB,{'FSWRIS','5','01','','','','','RIS->RIS_COD','','2017020213:35:16'})
aAdd(aSXB,{'FSWRIS','6','01','','','','','RIS->RIS_TPBENE == "83"','','2017020213:35:16'})
aAdd(aSXB,{'FSWSRA','1','01','DB','Funcionario','Funcionario','Funcionario','SRA','','2017020213:35:16'})
aAdd(aSXB,{'FSWSRA','2','01','01','Matricula','Matricula','Registration','','','2017020213:35:16'})
aAdd(aSXB,{'FSWSRA','4','01','01','Matricula','Matricula','Registration','RA_MAT','','2017020213:35:16'})
aAdd(aSXB,{'FSWSRA','4','01','02','Nome','Nombre','Name','RA_NOME','','2017020213:35:16'})
aAdd(aSXB,{'FSWSRA','5','01','','','','','SRA->RA_MAT','','2017020213:35:16'})
aAdd(aSXB,{'FSWSRA','6','01','','','','','RA_DEMISSA = " "','','2017020213:35:16'})
aAdd(aSX3Hlp,{'PA3_FILIAL','Filial do Sistema.'})
aAdd(aSX3Hlp,{'PA3_XSTATU','Status da Solicitação de IncentivoAcadêmico(1=Aprovado;2=Reprovado;3=AguardandoAprovação).'})
aAdd(aSX3Hlp,{'PA3_XCOD','Código da Solicitação'})
aAdd(aSX3Hlp,{'PA3_XMATRI','Informe a matricula do participante aoqual será solicitado o incentivoacadêmico.'})
aAdd(aSX3Hlp,{'PA3_XNOME','Nome do participante.'})
aAdd(aSX3Hlp,{'PA3_XCENTR','Centro de Custo do participante.'})
aAdd(aSX3Hlp,{'PA3_XNOMCC','Descrição do Centro de Custo.'})
aAdd(aSX3Hlp,{'PA3_XCARGO','Cargo do Participante.'})
aAdd(aSX3Hlp,{'PA3_XNMCRG','Descrição do Cargo do participante.'})
aAdd(aSX3Hlp,{'PA3_XSETOR','Setor do Participante.'})
aAdd(aSX3Hlp,{'PA3_XUNIDA','Unidade do Participante.'})
aAdd(aSX3Hlp,{'PA3_XNMUNI','Nome da Unidade.'})
aAdd(aSX3Hlp,{'PA3_XTIPO','Tipo do curso de subsídio acadêmico.'})
aAdd(aSX3Hlp,{'PA3_DSCTPC','Descrição do tipo de curso'})
aAdd(aSX3Hlp,{'PA3_XINSTI','Informe qual será a Instituiçãorealizadora.'})
aAdd(aSX3Hlp,{'PA3_NMINST','Nome da Instituição.'})
aAdd(aSX3Hlp,{'PA3_XCURS','Nome do curso a ser realizado.'})
aAdd(aSX3Hlp,{'PA3_XTELEF','Telefone de contato do curso.'})
aAdd(aSX3Hlp,{'PA3_XRAMAL','Ramal do curso.'})
aAdd(aSX3Hlp,{'PA3_XEMAIL','E-mail de contato do curso.'})
aAdd(aSX3Hlp,{'PA3_XINICI','Data de início do curso.'})
aAdd(aSX3Hlp,{'PA3_XTERMI','Data de termino do curso.'})
aAdd(aSX3Hlp,{'PA3_XDURAC','Duração do curso em dias.'})
aAdd(aSX3Hlp,{'PA3_XMENSL','Valor da mensalidade.'})
aAdd(aSX3Hlp,{'PA3_XVLTAL','Investimento do curso ano vigente.'})
aAdd(aSX3Hlp,{'PA3_XVLTCU','Valor Total do curso.'})
aAdd(aSX3Hlp,{'PA3_XPCBEN','Percentual do beneficio concedido pelaempresa para o participante.'})
aAdd(aSX3Hlp,{'PA3_XOBSER','Observação.'})
aAdd(aSX3Hlp,{'PA3_XSOLIC','Código do solicitante do incentivoacadêmico.'})
aAdd(aSX3Hlp,{'PA3_XNMSOL','Nome do solicitante.'})
aAdd(aSX3Hlp,{'PA3_RSPAPR','Código do Responsável pela aprovação.'})
aAdd(aSX3Hlp,{'RH3_XTPCTM','Tipo de solicitação customizada portal'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
