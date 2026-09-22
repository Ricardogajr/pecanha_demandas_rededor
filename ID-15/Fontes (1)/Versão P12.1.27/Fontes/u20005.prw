/*
{Protheus.doc} U20005
Função de instalação de dicionario especifico.
@author	FsTools V6.2.15
@since 24/06/2021
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Obs Fontes: FONTE.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U20005(lOnlyInfo)
Local aInfo := {'20','005','INTEGRACAO DE LANCAMENTOS CONTABEIS DO XRT','24/06/21','17:17','025147002012500670U0221','25/06/21','09:51','147221067201'}
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
aAdd(aSIX,{'CT2','L','CT2_FILIAL+CT2_XCDXRT','Chave XRT','Chave XRT','Chave XRT','U','','FWS2000502','S','','','2021062417:14:49'})
aAdd(aSX3,{'CT2','95','CT2_XPCXRT','C',30,0,'Par Ctb XRT','Par Ctb XRT','Par Ctb XRT','Par contábil XRT','Par contábil XRT','Par contábil XRT','','','€€€€€€€€€€€€€€ ','','',0,'xxxxxx x','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021062417:13:34'})
aAdd(aSX3,{'CT2','96','CT2_XCDXRT','C',30,0,'Chave XRT','Chave XRT','Chave XRT','Chave XRT','Chave XRT','Chave XRT','','','€€€€€€€€€€€€€€ ','','',0,'xxxxxx x','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021062417:13:34'})
aAdd(aSX3,{'CT2','97','CT2_IDINT','C',44,0,'ID Integra','ID Integra','ID Integra','ID Integração na P19','ID Integração na P19','ID Integração na P19','','','€€€€€€€€€€€€€€ ','','',0,'xxxxxx x','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021062417:13:34'})
aAdd(aSX6,{'','FS_C200050','C','Integração XRT: Lote a ser preenchido quando o','Integração XRT: Lote a ser preenchido quando o','Integração XRT: Lote a ser preenchido quando o','registro for originado por integração','registro for originado por integração','registro for originado por integração','','','','XRT001','XRT001','XRT001','U','','','','','','','','2021062417:15:33'})
aAdd(aSX6,{'','FS_C200051','C','Integração XRT: Informar o E-mail dos responsáveis','Integração XRT: Informar o E-mail dos responsáveis','Integração XRT: Informar o E-mail dos responsáveis','que deverão ser notificados, no caso de alt/exc de','que deverão ser notificados, no caso de alt/exc de','que deverão ser notificados, no caso de alt/exc de','reg vindo do XRT, separados por ponto-e-vírgula','reg vindo do XRT, separados por ponto-e-vírgula','reg vindo do XRT, separados por ponto-e-vírgula','','','','U','','','','','','','','2021062417:15:33'})
aAdd(aSX6,{'','FS_N200051','N','Timeout, em segundos, da chamada do WebService','Timeout, em segundos, da chamada do WebService','Timeout, em segundos, da chamada do WebService','','','','','','','120','120','120','U','','','','','','','','2021051910:11:12'})
aAdd(aSX3Hlp,{'CT2_XPCXRT','Equivalente ao documento no Protheus,  será enviado do XRT. Aglutina dois ou  mais lançamentos contábeis.'})
aAdd(aSX3Hlp,{'CT2_XCDXRT','Campo chave do registro no XRT. Gerado  por linha'})
aAdd(aSX3Hlp,{'CT2_IDINT','ID Integração na P19'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga,aSX1Hlp}
