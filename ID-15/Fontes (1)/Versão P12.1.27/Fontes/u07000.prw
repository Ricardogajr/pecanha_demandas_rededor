/*
{Protheus.doc} U07000
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 07/02/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423041_EF_000
@Obs manual desmark
@history Sandro - QALOG
*/
#INCLUDE 'PROTHEUS.CH'
User Function U07000(lOnlyInfo)
Local aInfo := {'07','000','FUNCIONALIDADES DE SUPORTE','07/02/17','15:26','000776072010000257U0102','24/04/19','14:22','776102025201'}
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

aAdd(aSIX,{'P19','1','P19_FILIAL+P19_DTHRI','Dt.Hr.Inicio','Dt.Hr.Inicio','Dt.Hr.Inicio','U','N','','','','','2019012410:14:52'})
aAdd(aSIX,{'P19','2','P19_FILIAL+P19_ID','ID Integ.','ID Integ.','ID Integ.','U','N','','','','','2019012410:14:52'})
aAdd(aSIX,{'P19','3','P19_FILIAL+P19_ROTINA+P19_DTHRI','Rotina+Dt.Hr.Inicio','Rotina+Dt.Hr.Inicio','Rotina+Dt.Hr.Inicio','U','N','','','','','2019012410:14:52'})
aAdd(aSIX,{'P20','1','P20_FILIAL+P20_DTHR','Dt.Hr.Inicio','Dt.Hr.Inicio','Dt.Hr.Inicio','U','N','','','','','2019012410:14:52'})
aAdd(aSIX,{'P20','2','P20_FILIAL+P20_ID','ID Integ.','ID Integ.','ID Integ.','U','N','','','','','2019012410:14:52'})
aAdd(aSIX,{'P20','3','P20_FILIAL+P20_ROTINA+P20_DTHR','Rotina+Dt.Hr.Inicio','Rotina+Dt.Hr.Inicio','Rotina+Dt.Hr.Inicio','U','N','','','','','2019012410:14:52'})

aAdd(aSX2,{'P19','\system\','P19010','LOG WS Server','LOG WS Server','LOG WS Server','','E','E','E',0,'','','',0,'','','','','','',0,0,0,'2019012410:14:51'})
aAdd(aSX2,{'P20','\system\','P20010','LOG WS Client','LOG WS Client','LOG WS Client','','E','E','E',0,'','','',0,'','','','','','',0,0,0,'2019012410:14:51'})

aAdd(aSX3,{'P19','01','P19_FILIAL','C',5,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P19','02','P19_ID','C',36,0,'ID Integ.','ID Integ.','ID Integ.','ID da Integracao','ID da Integracao','ID da Integracao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P19','03','P19_INDKEY','C',250,0,'IndexKey','IndexKey','IndexKey','IndexKey','IndexKey','IndexKey','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P19','04','P19_DTHRI','C',14,0,'Dt.Hr.Inicio','Dt.Hr.Inicio','Dt.Hr.Inicio','Data/Hora Inicio','Data/Hora Inicio','Data/Hora Inicio','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P19','05','P19_DTHRF','C',14,0,'Dt.Hr.Fim','Dt.Hr.Fim','Dt.Hr.Fim','Dt.Hr.Fim','Dt.Hr.Fim','Dt.Hr.Fim','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P19','06','P19_ROTINA','C',10,0,'Rotina','Rotina','Rotina','Rotina','Rotina','Rotina','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P19','07','P19_STATUS','C',1,0,'Status','Status','Status','Status','Status','Status','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','Pertence("123")','1=Gravando;2=Sucesso;3=Falha','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P19','08','P19_INPUT','M',10,0,'Entrada','Entrada','Entrada','Entrada','Entrada','Entrada','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P19','09','P19_OUTPUT','M',10,0,'Saída','Saída','Saída','Saida','Saida','Saida','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})

aAdd(aSX3,{'P20','01','P20_FILIAL','C',5,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','02','P20_FILPRO','C',8,0,'Filial Proc.','Filial Proc.','Filial Proc.','Filial Processamento','Filial Processamento','Filial Processamento','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','03','P20_ID','C',36,0,'ID Integ.','ID Integ.','ID Integ.','ID da Integracao','ID da Integracao','ID da Integracao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','04','P20_IDJOB','C',36,0,'ID Job.','ID Job','ID Job','ID da Integracao','ID da Integracao','ID da Integracao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','05','P20_DTHR','C',14,0,'Dt.Hr.Inicio','Dt.Hr.Inicio','Dt.Hr.Inicio','Data/Hora Inicio','Data/Hora Inicio','Data/Hora Inicio','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','06','P20_DTHRR','C',14,0,'Dt.Hr.Job','Dt.Hr.Job','Dt.Hr.Job','Dt.Hr.Job','Dt.Hr.Job','Dt.Hr.Job','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','07','P20_ROTINA','C',10,0,'Rotina','Rotina','Rotina','Rotina','Rotina','Rotina','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','08','P20_STATUS','C',1,0,'Status','Status','Status','Status','Status','Status','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','Pertence("12")','1=Falha;2=Sucesso','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','09','P20_INPUT','M',10,0,'Entrada','Entrada','Entrada','Entrada','Entrada','Entrada','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','10','P20_OUTPUT','M',10,0,'Saída','Saída','Saída','Saida','Saida','Saida','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})
aAdd(aSX3,{'P20','11','P20_INDKEY','C',250,0,'IndexKey','IndexKey','IndexKey','IndexKey','IndexKey','IndexKey','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','','','2019012410:14:44'})

aAdd(aSX6,{'','FS_WSTRACE','C','Habilita log de WebServices','','','','','','','','','1','1','1','U','','','','','','','','2019012410:14:57'})
aAdd(aSX6,{'','FS_VVNFSER','C','Serie da nota fiscal de saida','','','','','','','','','001','001','001','U','','','','','','','','2018080615:25:28'})


Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
 
 