/*
{Protheus.doc} U08005
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 20/03/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423042_EF_005
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U08005(lOnlyInfo)
Local aInfo := {'08','005','BUSCA SUPERIOR','20/03/17','11:42','005702082010500318U0124','03/04/17','18:47','702124031201'}
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
aAdd(aSIX,{'PA9','2','PA9_FILIAL+PA9_CODIGO+PA9_FILSOL','Codigo+Filial Solic','Codigo+Filial Solic','Codigo+Filial Solic','U','','','S','2017032011:36:43'})
aAdd(aSX3,{'RH3','28','RH3_XCODAL','C',6,0,'Cod.Alcada','Cod.Alcada','Cod.Alcada','Código da Alçada','Código da Alçada','Código da Alçada','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017032011:36:38'})
aAdd(aSX3,{'RH3','29','RH3_XPRXNV','C',2,0,'Prox.Nivel','Prox.Nivel','Prox.Nivel','Proximo nível aprovador','Proximo nível aprovador','Proximo nível aprovador','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017032011:36:38'})
aAdd(aSX3,{'SRJ','15','RJ_XGEREN','C',2,0,'Nivel?','Nivel?','Nivel?','Nivel?','Nivel?','Nivel?','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','S','A','R','','','01=RH;02=PA;03=Presidente;04=VP Executivo;05=Vice Presidente;06=Dir. Executivo;07=Diretor;08=Gerente;09=Superv;10=Lider;11=Livre','1=Presidente;2=VP Executivo;3=Vice Presidente;4=Diretor Executivo;5=Diretor;6=Gerente;7=Supervisor;8=Líder;9=Livre','1=Presidente;2=VP Executivo;3=Vice Presidente;4=Diretor Executivo;5=Diretor;6=Gerente;7=Supervisor;8=Líder;9=Livre','','','','','','','','','','N','N','','','','2017032717:18:09'})
aAdd(aSX3Hlp,{'RH3_XCODAL','Código da alçada'})
aAdd(aSX3Hlp,{'RH3_XPRXNV','Próximo nível do aprovador.'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
