/*
{Protheus.doc} U03003
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 30/11/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000463701_EF_003
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U03003(lOnlyInfo)
Local aInfo := {'03','003','RELATORIO PLANO DE SUCESSAO','16/03/2017','15:40','003760032010300353U0114','24/04/17','18:41',''}
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
aAdd(aSX1,{'FSW0300301','01','Filial ?'			,'Filial ?'			,'Filial ?'			,'MV_CH1','C',Len(SRA->RA_FILIAL),0,0,'G','','MV_PAR01','','','','01','','','','','','','','','','','','','','','','','','','','','SM0','','','.RHFILIAL.','','','2017031615:58:22'})
aAdd(aSX1,{'FSW0300301','02','Matricula ?'		,'Matricula ?'		,'Matricula ?'		,'MV_CH2','C',60,0,0,'R',''				,'MV_PAR02','','','','RDD_CODADO','','','','','000169;000181;000158;','','','','','','','','','','','','','','','','SRA','','','.RHMATRIC.','','','2017031615:58:22'})
aAdd(aSX1,{'FSW0300301','03','1a.Avaliacao (y)?','1a.Avaliacao (y)?','1a.Avaliacao (y)?','MV_CH3','C',06,0,0,'G','NaoVazio()'	,'MV_PAR03','','','','000001','','','','','','','','','','','','','','','','','','','','','RD6','','','','','','2017031615:58:22'})
aAdd(aSX1,{'FSW0300301','04','2a.Avaliacao (x)?','2a.Avaliacao (x)?','2a.Avaliacao (x)?','MV_CH4','C',06,0,0,'G','NaoVazio()'	,'MV_PAR04','','','','000003','','','','','','','','','','','','','','','','','','','','','RD6','','','','','','2017031615:58:22'})
aAdd(aSX1,{'FSW0300301','05','Tipo de Geracao ?','Tipo de Geracao ?','Tipo de Geracao ?','MV_CH5','N',01,0,1,'C',''				,'MV_PAR05','1-Gerar Excel','1-Gerar Excel','1-Gerar Excel','','','2-Relatorio','2-Relatorio','2-Relatorio','','','','','','','','','','','','','','','','','','','','','','','2017031615:58:22'})
aAdd(aSX1,{'FSW0300301','06','Dir Arquivo'		,'Dir Arquivo'		,'Dir Arquivo'		,'MV_CH6','C',30,0,0,'G','U_F0100329()' ,'MV_PAR06','','','','C:\TEMP\','','','','','','','','','','','','','','','','','','','','','','','','','','','2017031615:12:00'})
aAdd(aSX1,{'FSW0300301','07','Quadrante B1 x B2?','Desc.Resultado A?','Desc.Resultado A?','MV_CH7','C',15,0,0,'G','          ',''	,'','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','08','Quadrante B1 x C2?','Desc.Resultado B?','Desc.Resultado B?','MV_CH8','C',15,0,0,'G','          ',''	,'','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','09','Quadrante B1 x D2?','Desc.Resultado C?','Desc.Resultado C?','MV_CH9','C',15,0,0,'G','          ',''	,'','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','10','Quadrante B1 x E2?','Desc.Resultado D?','Desc.Resultado D?','MV_CHA','C',15,0,0,'G','          ',''	,'','','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','11','Quadrante C1 x B2?','Desc.Resultado E?','Desc.Resultado E?','MV_CHB','C',15,0,0,'G','          ',''	,'','','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','12','Quadrante C1 x C2?','Desc.Resultado F?','Desc.Resultado F?','MV_CHC','C',15,0,0,'G','          ',''	,'','','MV_PAR12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','13','Quadrante C1 x D2?','Desc.Resultado G?','Desc.Resultado G?','MV_CHD','C',15,0,0,'G','          ',''	,'','','MV_PAR13','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','14','Quadrante C1 x E2?','Desc.Resultado H?','Desc.Resultado H?','MV_CHE','C',15,0,0,'G','          ',''	,'','','MV_PAR14','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','15','Quadrante D1 x B2?','Desc.Resultado I?','Desc.Resultado I?','MV_CHF','C',15,0,0,'G','          ',''	,'','','MV_PAR15','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','16','Quadrante D1 x C2?','Desc.Resultado J?','Desc.Resultado J?','MV_CHG','C',15,0,0,'G','          ',''	,'','','MV_PAR16','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','17','Quadrante D1 x D2?','Desc.Resultado K?','Desc.Resultado K?','MV_CHH','C',15,0,0,'G','          ',''	,'','','MV_PAR17','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','18','Quadrante D1 x E2?','Desc.Resultado L?','Desc.Resultado L?','MV_CHI','C',15,0,0,'G','          ',''	,'','','MV_PAR18','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','19','Quadrante E1 x B2?','Desc.Resultado M?','Desc.Resultado M?','MV_CHJ','C',15,0,0,'G','          ',''	,'','','MV_PAR19','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','20','Quadrante E1 x C2?','Desc.Resultado N?','Desc.Resultado N?','MV_CHK','C',15,0,0,'G','          ',''	,'','','MV_PAR20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','21','Quadrante E1 x D2?','Desc.Resultado O?','Desc.Resultado O?','MV_CHL','C',15,0,0,'G','          ',''	,'','','MV_PAR21','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})
aAdd(aSX1,{'FSW0300301','22','Quadrante E1 x E2?','Desc.Resultado P?','Desc.Resultado P?','MV_CHM','C',15,0,0,'G','          ',''	,'','','MV_PAR22','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017033013:13:13'})

Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
