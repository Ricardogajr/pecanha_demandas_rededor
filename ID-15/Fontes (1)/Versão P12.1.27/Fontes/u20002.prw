/*
{Protheus.doc} U20002
Função de instalação de dicionario especifico.
@author	FsTools V6.2.15
@since 08/06/2021
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
*/
#INCLUDE 'PROTHEUS.CH'
User Function U20002(lOnlyInfo)
Local aInfo := {'20','002','INTEGRAÇÃO TÍTULOS REALIZADOS - XRT','08/06/21','12:04','022184002012200620U0200','22/06/21','16:14','184200062201'}
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
aAdd(aSX3,{'FK2','34','FK2_XMSXRT','M',10,0,'Mensagem XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021060811:56:19'})
aAdd(aSX3,{'FK2','35','FK2_XPX0','C',1,0,'Integ. XRT','Integ. XRT','Integ. XRT','Integrou XRT','Integrou XRT','Integrou XRT','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','V','R','','','1=Não Processado;2=Integrado com PX0;3=Baixa por retorno bancário','1=Não Processado;2=Integrado com PX0;3=Baixa por retorno bancário','1=Não Processado;2=Integrado com PX0;3=Baixa por retorno bancário','','','','','','','','','','N','N','','','','','','2021060811:56:19'})
aAdd(aSX3,{'FK5','38','FK5_XMSXRT','M',10,0,'Mensagem XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','Mensagem XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021060811:56:19'})
aAdd(aSX3,{'FK5','39','FK5_XPX0','C',1,0,'Integ. XRT','Integ. XRT','Integ. XRT','Integrou XRT','Integrou XRT','Integrou XRT','','','€€€€€€€€€€€€€€ ','"1"','',0,'þÀ','','','U','N','V','R','','','1=Não Processado;2=Integrado com PX0;3=Não relacionado a Ctas a Pagar','1=Não Processado;2=Integrado com PX0;3=Não relacionado a Ctas a Pagar','1=Não Processado;2=Integrado com PX0;3=Não relacionado a Ctas a Pagar','','','','','','','','','','N','N','','','','','','2021060811:56:19'})
aAdd(aSX3Hlp,{'FK2_XMSXRT','Mensagem retornada pelo XRT em caso de  falha na integração.'})
aAdd(aSX3Hlp,{'FK2_XPX0','Indica se o movimento de baixa gerado  foi processado para posterior  integraçãocom o XRT (gerou a tabela  PX0).'})
aAdd(aSX3Hlp,{'FK5_XMSXRT','Mensagem retornada pelo XRT em caso de  falha na integração.'})
aAdd(aSX3Hlp,{'FK5_XPX0','Indica se o movimento de PA gerado  foi  processado para posterior  integraçãocomo XRT (gerou a tabela  PX0).'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga,aSX1Hlp}
