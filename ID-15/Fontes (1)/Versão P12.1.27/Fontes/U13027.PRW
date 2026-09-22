/* 
{Protheus.doc} U13027
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 21/02/2018
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_003
@Obs Fontes: F0100308.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U13027(lOnlyInfo)
Local aInfo := {'13','027','NAO CANCELAMENTO','21/02/18','11:31','017811232011700213U2123','12/03/18','10:49','811123021201'}
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
aAdd(aSX3,{'RH3','41','RH3_XFILPO','C',8,0,'Filial Posto','Filial Posto','Filial Posto','Filial Posto','Filial Posto','Filial Posto','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2018022111:29:28'})
aAdd(aSX3,{'RH3','42','RH3_XCODPO','C',9,0,'Cod.Posto','Cod.Posto','Cod.Posto','Código do Posto','Código do Posto','Código do Posto','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2018022111:29:28'})
aAdd(aSX3,{'SQS','03','QS_XSTATUS','C',1,0,'Status','Status','Status','Status da Vaga','Status da Vaga','Status da Vaga','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','1=Aprovada;2=Em Recrutamento;3=Em Movimentacao (RI);4=Cadastro;5=Cancelada;6=Suspensa;7=Concluida;8=Exame-Docto;9=Ass.Contrato','','','','','','','','','','','','N','N','','','',''})
aAdd(aSX3Hlp,{'RH3_XFILPO','Filial Posto'})
aAdd(aSX3Hlp,{'RH3_XCODPO','Código do Posto'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
