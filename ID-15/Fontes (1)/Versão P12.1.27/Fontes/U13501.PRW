/* 
{Protheus.doc} U13501
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 27/10/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423048_EF_005 TYPE FUNCTION
@Obs Fontes: F1300501.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U13501(lOnlyInfo)
Local aInfo := {'13','501','TABELA SALARIAL','27/10/17','14:14','511774032111150043U0121','10/11/17','09:32','774121004211'}
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
aAdd(aSX1,{'FSW1300501','01','Filial De?','','','MV_CH1','C',99,0,0,'R','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017102714:14:01'})
aAdd(aSX1,{'FSW1300501','02','Filial Até?','','','MV_CH2','C',99,0,0,'R','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017102714:14:01'})
aAdd(aSX1,{'FSW1300501','03','Tabela De?','','','MV_CH3','C',99,0,0,'R','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','RB6','','','','','','2017102714:14:01'})
aAdd(aSX1,{'FSW1300501','04','Tabela Até?','','','MV_CH4','C',99,0,0,'R','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','RB6','','','','','','2017102714:14:01'})
aAdd(aSX1,{'FSW1300501','05','Data De','','','MV_CH5','D',8,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017102714:14:01'})
aAdd(aSX1,{'FSW1300501','06','Data Até','','','MV_CH6','D',8,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017102714:14:01'})
aAdd(aSX1,{'FSW1300501','07','Tipo Importação','','','MV_CH7','C',8,0,0,'C','','MV_PAR06','Cabeçalho','','','','','Itens','','','','','','','','','','','','','','','','','','','','','','','','','2017102714:14:01'})



Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
