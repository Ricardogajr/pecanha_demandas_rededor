/*
{Protheus.doc} U01002
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 19/07/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000462901_EF_002
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U01002(lOnlyInfo)
Local aInfo := {'01','002','EF01002','19/07/16','08:20','002690012000200781U0112','29/12/16','14:27',''}
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
aAdd(aSXB,{'FS43CD','1','01','DB','Cód. Tipo Res.','Cod. Tipo Res.','Code Type Res.','RCC','','2016071908:19:45'})
aAdd(aSXB,{'FS43CD','2','01','01','Cod.+Tp.Desligamento','Cod.+Tp.Salida','Code+TpTermination','','','2016071908:19:45'})
aAdd(aSXB,{'FS43CD','4','01','01','Cód.Mov.','Cod.Mov.','Cod.Mov.','SUBSTR(RCC_CONTEU,1,2)','','2016071908:19:45'})
aAdd(aSXB,{'FS43CD','4','01','02','Descrição','Descripcion','Description','SUBSTR(RCC_CONTEU,3,30)','','2016071908:19:45'})
aAdd(aSXB,{'FS43CD','5','01','','','','','SUBSTR(RCC_CONTEU,1,2)','','2016071908:19:45'})
aAdd(aSXB,{'FS43CD','5','02','','','','','DESCRICAO := SUBSTR(RCC_CONTEU,3,30)','','2016071908:19:45'})
aAdd(aSXB,{'FS43CD','6','01','','','','','RCC->RCC_CODIGO = "S043"','','2016071908:19:45'})
aAdd(aSXB,{'FS43DE','1','01','RE','Descrição','Descrição','Descrição','RCC','','2016071908:19:45'})
aAdd(aSXB,{'FS43DE','2','01','01','','','','POSICIONE("RCC",1,xFilial("RCC") + "S043" + "" + "" + CODRESCIS ,SUBSTR(RCC_CONTEU,3,30))','','2016071908:19:45'})
aAdd(aSXB,{'FS43DE','5','01','','','','','DESCRICAO := POSICIONE("RCC",1,xFilial("RCC") + "S043" + "" + "" + CODRESCIS ,SUBSTR(RCC_CONTEU,3,30)','','2016071908:19:45'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
