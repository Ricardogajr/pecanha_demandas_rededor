/*
{Protheus.doc} U08003
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 08/04/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423042_EF_003
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08003(lOnlyInfo)
Local aInfo := {'08','003','FILIAL E POSTO DE APROVAÇAO','08/04/17','15:44','003784082010300458U0104','01/06/17','16:06','784104045201'}
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
aAdd(aSIX,{'PAD','1','PAD_FILIAL+PAD_CODIGO','Codigo','Codigo','Codigo','U','','','N','2017040815:42:10'})
aAdd(aSIX,{'PA9','1','PA9_FILIAL+PA9_CODIGO','Codigo','Codigo','Codigo','U','','','N','2017032712:34:42'})
aAdd(aSIX,{'PA9','2','PA9_FILIAL+PA9_CODIGO+PA9_FILSOL','Codigo+Filial Solicitacao','Codigo+Filial Solicitacao','Codigo+Filial Solicitacao','U','','','N','2017032712:34:42'})
aAdd(aSX2,{'PAD','','PAD990','CABEÇALHO POSTO FILIAL DE APRO','CABEÇALHO POSTO FILIAL DE APRO','CABEÇALHO POSTO FILIAL DE APRO','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017040815:42:09'})
aAdd(aSX2,{'PA9','','PA9010','POSTO-FILIAL DE APROVAÇAO','POSTO-FILIAL DE APROVAÇAO','POSTO-FILIAL DE APROVAÇAO','','C','C','C',0,'','','',0,'','','','','','',0,0,0,'2017032712:34:41'})
aAdd(aSX3,{'PAD','01','PAD_FILIAL','C',2,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017040815:42:07'})
aAdd(aSX3,{'PAD','02','PAD_CODIGO','C',6,0,'Codigo','Codigo','Codigo','Codigo Aprovaçao Posto/Fi','Codigo Aprovaçao Posto/Fi','Codigo Aprovaçao Posto/Fi','@!','','€€€€€€€€€€€€€€ ','GETSX8NUM( "PAD","PAD_CODIGO")','',0,'þÀ','','','U','S','V','R','€','','','','','','','','','','','','','','N','N','','','','2017040815:42:07'})
aAdd(aSX3,{'PAD','03','PAD_DESCRI','C',200,0,'Descriçao','Descriçao','Descriçao','Descriçao do Grupo','Descriçao do Grupo','Descriçao do Grupo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017040815:42:07'})
aAdd(aSX3,{'PA9','01','PA9_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017032712:34:38'})
aAdd(aSX3,{'PA9','02','PA9_CODIGO','C',6,0,'Codigo','Codigo','Codigo','Código Sequencial Aprov','Código Sequencial Aprov','Código Sequencial Aprov','@!','','€€€€€€€€€€€€€€ ','GETSX8NUM( "PA9","PA9_CODIGO")','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017032712:34:38'})
aAdd(aSX3,{'PA9','03','PA9_DESCRI','C',120,0,'Desc Grupo','Desc Grupo','Desc Grupo','Descriçao de Grupo Aprova','Descriçao de Grupo Aprova','Descriçao de Grupo Aprova','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2017032712:34:38'})
aAdd(aSX3,{'PA9','04','PA9_FILAPR','C',8,0,'Filial Aprov','Filial Aprov','Filial Aprov','Filial Aprovaçao','Filial Aprovaçao','Filial Aprovaçao','@!','','€€€€€€€€€€€€€€ ','','SM0',0,'þÀ','','','U','S','A','R','€','U_F0800302()','','','','','','','','','','','','','N','N','','','','2017032712:34:38'})
aAdd(aSX3,{'PA9','05','PA9_POSAPR','C',9,0,'Posto Aprova','Posto Aprova','Posto Aprova','Posto Aprovacao','Posto Aprovacao','Posto Aprovacao','@!','','€€€€€€€€€€€€€€ ','','FSORG2',0,'þÀ','','S','U','S','A','R','€','U_F0800304()','','','','','','','','','','','','','N','N','','','','2017032712:34:38'})
aAdd(aSX3,{'PA9','06','PA9_PAPDES','C',120,0,'Desc Cargo','Desc Cargo','Desc Cargo','Descriçao de Cargo','Descriçao de Cargo','Descriçao de Cargo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017032712:34:38'})
aAdd(aSX3,{'PA9','07','PA9_FILSOL','C',8,0,'Filial Solic','Filial Solic','Filial Solic','Filial Solicitante','Filial Solicitante','Filial Solicitante','@!','','€€€€€€€€€€€€€€ ','','FSWFIL',0,'þÀ','','S','U','S','A','R','€','U_F0800303()','','','','','','','','','','','','','N','N','','','','2017032712:34:38'})
aAdd(aSX3,{'PA9','08','PA9_FSODES','C',120,0,'Desc Fil Sol','Desc Fil Sol','Desc Fil Sol','Descriçao da Filial Solic','Descriçao da Filial Solic','Descriçao da Filial Solic','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','2017032712:34:38'})
aAdd(aSX3,{'PA9','11','PA9_SESMT','C',1,0,'SESMT','SESMT','SESMT','Posto SESMT?','Posto SESMT?','Posto SESMT?','@!','','€€€€€€€€€€€€€€ ','1','',0,'þÀ','','','U','N','A','R','','','1=Não;2=Sim','','','','','','','','','','','','N','N','','','2017060116:03:33'})
aAdd(aSXB,{'FSORG2','1','01','RE','Postos Visao','Puestos vision','Vision Stations','','','2017032712:34:44'})
aAdd(aSXB,{'FSORG2','2','01','01','','','','U_FSORG2()','','2017032712:34:44'})
aAdd(aSXB,{'FSORG2','5','01','','','','','u_FSORG2R1()','','2017032712:34:44'})
aAdd(aSXB,{'FSORG2','5','02','','','','','u_FSORG2R2()','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','1','01','DB','Filiais','Sucursales','Branches','SM0','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','2','01','01','Código','Codigo','Code','','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','2','02','02','Nome','Nombre','Name','','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','01','01','Código','Codigo','Code','M0_CODFIL','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','01','02','Filial','Sucursal','Branch','M0_FILIAL','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','01','03','Município','Municipio','City','M0_CIDENT','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','02','04','Empresa','Empresa','Company','M0_NOME','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','4','02','05','Filial','Sucursal','Branch','M0_FILIAL','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','5','01','','','','','FWCodFil()','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','5','01','','','','','SM0->M0_NOME','','2017032712:34:44'})
aAdd(aSXB,{'FSWFIL','6','01','','','','','SM0->M0_CODIGO == CEMPANT','','2017032712:34:44'})
aAdd(aSX3Hlp,{'PAD_CODIGO','Codigo Aprovaçao Posto e Filial'})
aAdd(aSX3Hlp,{'PAD_DESCRI','Descriçao do Grupo de aprovaçao'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
