/*
{Protheus.doc} U20004
Função de instalação de dicionario especifico.
@author	FsTools V6.2.15
@since 15/06/2021
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
*/
#INCLUDE 'PROTHEUS.CH'
User Function U20004(lOnlyInfo)
Local aInfo := {'20','004','INTEGRAÇÃO MOV. BANCÁRIO/BAIXAS','15/06/21','17:42','024152002012400670U0214','25/06/21','09:51','152214067201'}
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
aAdd(aSIX,{'FK2','B','FK2_FILIAL+FK2_XCDXRT+FK2_XPCXRT','Código XRT+Par Cont XRT','Código XRT+Par Cont XRT','Código XRT+Par Cont XRT','U','','FSW2000406','S','','','2021061517:38:33'})
aAdd(aSIX,{'FK5','B','FK5_FILIAL+FK5_XCDXRT+FK5_XPCXRT','Código XRT+Par Cont XRT','Código XRT+Par Cont XRT','Código XRT+Par Cont XRT','U','','FSW2000404','S','','','2021061517:38:33'})
aAdd(aSIX,{'SE2','P','E2_FILIAL+DTOS(E2_VENCREA)+E2_XOPFXRT+E2_NATUREZ','Vencto Real+Op. Fin. XRT+Natureza','Vencto. Real+Op. Fin. XRT+Modalidad','Actual Due D+Op. Fin. XRT+Modalidad','U','','FSW2000400','S','','','2021061517:38:43'})
aAdd(aSX3,{'FK2','36','FK2_XPCXRT','C',30,0,'Par Cont XRT','Par Cont XRT','Par Cont XRT','Par Contábil XRT','Par Contábil XRT','Par Contábil XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021061517:34:40'})
aAdd(aSX3,{'FK2','37','FK2_XCDXRT','C',30,0,'Código XRT','Código XRT','Código XRT','Código XRT','Código XRT','Código XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021061517:34:40'})
aAdd(aSX3,{'FK5','36','FK5_XPCXRT','C',30,0,'Par Cont XRT','Par Cont XRT','Par Cont XRT','Par Contábil XRT','Par Contábil XRT','Par Contábil XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021061517:34:40'})
aAdd(aSX3,{'FK5','37','FK5_XCDXRT','C',30,0,'Código XRT','Código XRT','Código XRT','Código XRT','Código XRT','Código XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021061517:34:40'})
aAdd(aSX3,{'SE2','DD','E2_XOPFXRT','C',16,0,'Op. Fin. XRT','Op. Fin. XRT','Op. Fin. XRT','Operação Financeira XRT','Operação Financeira XRT','Operação Financeira XRT','9999999999999999','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','U_F2000415()','','','','','','','','1','','','','','N','N','','','','','','2021061517:36:36'})
aAdd(aSX3,{'SE2','38','E2_XIDP19','C',44,0,'ID Log Int','ID Log Int','ID Log Int','ID Log Int','ID Log Int','ID Log Int','','','€€€€€€€€€€€€€€ ','','',0,'xxxxxx x','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021062509:20:11'})
aAdd(aSX3,{'SE5','9G','E5_XPCXRT','C',30,0,'Par Cont XRT','Par Cont XRT','Par Cont XRT','Par Contábil XRT','Par Contábil XRT','Par Contábil XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021061517:36:37'})
aAdd(aSX3,{'SE5','9H','E5_XCODXRT','C',30,0,'Código XRT','Código XRT','Código XRT','Código XRT','Código XRT','Código XRT','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021061517:36:37'})
aAdd(aSX3,{'SE5','9I','E5_XINTXRT','C',3,0,'Integr. XRT','Integr. XRT','Integr. XRT','Integrado XRT','Integrado XRT','Integrado XRT','','','€€€€€€€€€€€€€€ ','"Não"','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021061517:36:37'})
aAdd(aSX3,{'SE5','40','E5_XIDP19','C',44,0,'ID Log Int','ID Log Int','ID Log Int','ID Log Int','ID Log Int','ID Log Int','','','€€€€€€€€€€€€€€ ','','',0,'xxxxxx x','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','','','2021062509:20:12'})
aAdd(aSX6,{'','FS_C200040','C','Indica se a contabilização é feita online 1-Sim ou','Indica se a contabilização é feita online 1-Sim ou','Indica se a contabilização é feita online 1-Sim ou','2-Não. Caso não informado, assume o valor padrão','2-Não. Caso não informado, assume o valor padrão','2-Não. Caso não informado, assume o valor padrão','configurado nos parâmetros da rotina (Tecla F12)','configurado nos parâmetros da rotina (Tecla F12)','configurado nos parâmetros da rotina (Tecla F12)','','','','U','','','','','','','','2021061517:40:00'})
aAdd(aSX6,{'','FS_C200041','C','Motivo de baixa utilizado nas baixas de operação','Motivo de baixa utilizado nas baixas de operação','Motivo de baixa utilizado nas baixas de operação','financeira (a pagar) vindas do XRT','financeira (a pagar) vindas do XRT','financeira (a pagar) vindas do XRT','','','','DEB','DEB','DEB','U','','','','','','','','2021061517:40:00'})
aAdd(aSX6,{'','FS_C200042','C','Informe os códigos dos usuários que poderão cance','Informe os códigos dos usuários que poderão cance','Informe os códigos dos usuários que poderão cance','lar movimentos bancários originados do XRT, separa','lar movimentos bancários originados do XRT, separa','lar movimentos bancários originados do XRT, separa','dos por ponto-vírgula','dos por ponto-vírgula','dos por ponto-vírgula','000000;','000000;','000000;','U','','','','','','','','2021061517:40:00'})
aAdd(aSX6,{'','FS_N200041','N','Timeout, em segundos, da chamada do WebService','Timeout, em segundos, da chamada do WebService','Timeout, em segundos, da chamada do WebService','','','','','','','120','120','120','U','','','','','','','','2021051910:11:12'})
aAdd(aSX3Hlp,{'FK2_XPCXRT','Código do Par contábil do XRT. Agrupa  umou mais movimentos bancários  integrados do XRT.'})
aAdd(aSX3Hlp,{'FK2_XCDXRT','Código único da baixa integrada do XRT.'})
aAdd(aSX3Hlp,{'FK5_XPCXRT','Código do Par contábil do XRT. Agrupa  umou mais movimentos bancários  integrados do XRT.'})
aAdd(aSX3Hlp,{'FK5_XCDXRT','Código único da movimentação bancária  integrada do XRT.'})
aAdd(aSX3Hlp,{'E2_XOPFXRT','Indicar qual o número da operação  financeira no XRT, para posterior baixa  do título através de integração.'})
aAdd(aSX3Hlp,{'E2_XIDP19','ID da tabela de log de integração (P19)'})
aAdd(aSX3Hlp,{'E5_XPCXRT','Código do Par contábil do XRT. Agrupa  umou mais movimentos bancários  integrados do XR'})
aAdd(aSX3Hlp,{'E5_XCODXRT','Código único da movimentação bancária  integrada do XRT'})
aAdd(aSX3Hlp,{'E5_XINTXRT','Indica se o movimento foi integrado do  XRT.'})
aAdd(aSX3Hlp,{'E5_XIDP19','ID da tabela de log de integração (P19)'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga,aSX1Hlp}
