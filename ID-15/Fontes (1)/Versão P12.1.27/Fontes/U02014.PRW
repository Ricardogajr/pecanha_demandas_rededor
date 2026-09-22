/*
{Protheus.doc} U02014
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 29/07/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000463301_EF_014
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U02014(lOnlyInfo)
Local aInfo := {'02','014','EF02014','29/07/16','16:18','004698122010400762U1121','23/05/17','12:18',''}
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
aAdd(aSIX,{'PA0','1','PA0_FILIAL+PA0_XCPF','CPF','CPF','CPF','U','','P0XCPF','S','2016072916:17:27'})
aAdd(aSIX,{'PA1','1','PA1_FILIAL+PA1_XCPF','CPF','CPF','CPF','U','','P1XCPF','S','2016072916:17:27'})
aAdd(aSIX,{'PA1','2','PA1_FILIAL+PA1_XCPF+PA1_XDAT','CPF+Data Alterac','CPF+Data Alterac','CPF+Data Alterac','U','','','S','2016072916:17:27'})
aAdd(aSIX,{'PA1','3','PA1_FILIAL+PA1_XDAT+PA1_XCPF','Data Alterac+CPF','Data Alterac+CPF','Data Alterac+CPF','U','','','S','2016072916:17:27'})
aAdd(aSX2,{'PA0','','PA0010','ARQUIVO DE CONTRA INDICADOS','ARQUIVO DE CONTRA INDICADOS','ARQUIVO DE CONTRA INDICADOS','','C','C','C',0,'','','',0,'','','','2','1','',0,0,0,'2016072916:17:25'})
aAdd(aSX2,{'PA1','','PA1010','LOG ALTERACOES CAD. CONTRA IND','LOG ALTERACOES CAD. CONTRA IND','LOG ALTERACOES CAD. CONTRA IND','','C','C','C',0,'','','',0,'','','','2','1','',0,0,0,'2016072916:17:25'})
aAdd(aSX3,{'PA0','01','PA0_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2016072916:17:19'})
aAdd(aSX3,{'PA0','02','PA0_XCPF','C',11,0,'CPF','CPF','CPF','N° CPF do Contra Indicado','N° CPF do Contra Indicado','N° CPF do Contra Indicado','@R 999.999.999-99','If(EMPTY(M->PA0_XCPF),.T.,CHKCPF(M->PA0_XCPF)) .AND. FHIST()','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','If(EMPTY(M->PA0_XCPF),.T.,CHKCPF(M->PA0_XCPF)) .AND. FHIST()','','','','','','','','','','','','','N','N','','','','2016072916:17:19'})
aAdd(aSX3,{'PA0','03','PA0_XNOME','C',60,0,'Nome Complet','Nome Complet','Nome Complet','Nome Completo','Nome Completo','Nome Completo','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','€','','','','','','','','','','','','','','N','N','','','','2016072916:17:19'})
aAdd(aSX3,{'PA0','13','PA0_XRES','C',45,0,'Responsavel','Responsavel','Responsavel','Nome do Responsavel','Nome do Responsavel','Nome do Responsavel','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016072916:17:19'})
aAdd(aSX3,{'PA0','14','PA0_XDTI','D',8,0,'Data Inclusa','Data Inclusa','Data Inclusa','Data Inclusao','Data Inclusao','Data Inclusao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2016072916:17:19'})
aAdd(aSX3,{'PA1','01','PA1_FILIAL','C',8,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal','Branch of the System','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2016072916:17:19'})
aAdd(aSX3,{'PA1','02','PA1_XCPF','C',11,0,'CPF','CPF','CPF','N° CPF do Contra Indicado','N° CPF do Contra Indicado','N° CPF do Contra Indicado','@R 999.999.999-99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2016072916:17:19'})
aAdd(aSX3,{'PA1','03','PA1_XDAT','D',8,0,'Data Alterac','Data Alterac','Data Alterac','Data Alteracao','Data Alteracao','Data Alteracao','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2016072916:17:19'})
aAdd(aSX3,{'PA1','04','PA1_XUSUA','C',15,0,'Usuario','Usuario','Usuario','Usuario que alterou a inf','Usuario que alterou a inf','Usuario que alterou a inf','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','','','','','','','','','','','','','N','N','','','','2016072916:17:19'})
aAdd(aSX3,{'PA1','05','PA1_XTIPO','C',1,0,'Tp Inclusao','Tp Inclusao','Tp Inclusao','Tipo Inclusão','Tipo Inclusão','Tipo Inclusão','9','','€€€€€€€€€€€€€€€','','',0,'þÀ','','','U','N','A','R','','PERTENCE("1234")','','','','','','','','','','','','','N','N','','','','2016072916:17:19'})
aAdd(aSX3Hlp,{'PA0_XCPF','N° CPF do Contra Indicado'})
aAdd(aSX3Hlp,{'PA0_XNOME','Nome Completo do Contra Indicado'})
aAdd(aSX3Hlp,{'PA0_XRES','Nome do Responsavel'})
aAdd(aSX3Hlp,{'PA0_XDTI','Data da Inclusão na Lista'})
aAdd(aSX3Hlp,{'PA1_XCPF','N° CPF do Contra Indicado'})
aAdd(aSX3Hlp,{'PA1_XDAT','Data da alteração dos dados'})
aAdd(aSX3Hlp,{'PA1_XUSUA','Usuário que alterou a informação'})
aAdd(aSX3Hlp,{'PA1_XTIPO','Tipo Inclusão:1 - Incluido2 - Importado'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
