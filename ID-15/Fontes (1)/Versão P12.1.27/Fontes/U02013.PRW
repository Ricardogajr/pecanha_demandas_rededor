/*
{Protheus.doc} U02013
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 12/05/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000463301_EF_013
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U02013(lOnlyInfo)
Local aInfo := {'02','013','HOLERITE','01/06/16','08:00','003610122000300682U1100','29/12/16','14:29',''}
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
aAdd(aSX3,{'SRA','53','RA_BCDEPSA','C',8,0,'Bco.Ag.D.Sal','Bco.Ag.D.Sue','Bk.Of.Dp.Sal','Banco Ag. Dep. de Salario','Banco Ag. Dep. de Sueldo','Bank Off.Bk. Sal. Deposit','@R 999/99999','','€€€€€€€€€€€€€€ ','','BA1',1,'–€','','','','N','','','','Vazio() .Or. ExistCpo("SA6",Subs(M->RA_BCDEPSA,1,3)+Subs(M->RA_BCDEPSA,4,5))','','','','','','','','2','S','','','N','N','N','','1','2','2016060108:00:00'})
aAdd(aSX6,{'','FS_CONTCC','C','Código do banco com 4 posições + agencia com 4 pos','','','posições + número da conta corrente da filial.','','','','','','','','','U','','','','','','','2016060108:00:00'})
aAdd(aSX6,{'','FS_CONVEN','C','Número do convênio da filial a ser relacionado com','','','o arquivo a ser enviado ao banco , com 12 posições','','','','','','','','','U','','','','','','','2016060108:00:00'})
aAdd(aSX6,{'','FS_ROTARQ','C','Caminho onde será gravado o arquivo, com as','','','informações do Holerite.','','','','','','C:\santander\','','','U','','','','','','','2016060108:00:00'})
aAdd(aSXB,{'FS013','1','01','DB','Funcionarios','Funcionarios','Funcionarios','SRA','','2016060108:00:00'})
aAdd(aSXB,{'FS013','2','01','01','Matricula','Matricula','Registration','','','2016060108:00:00'})
aAdd(aSXB,{'FS013','4','01','01','Filial','Sucursal','Branch','RA_FILIAL','','2016060108:00:00'})
aAdd(aSXB,{'FS013','4','01','02','Matricula','Matricula','Registration','RA_MAT','','2016060108:00:00'})
aAdd(aSXB,{'FS013','4','01','03','Nome','Nombre','Name','RA_NOME','','2016060108:00:00'})
aAdd(aSXB,{'FS013','5','01','','','','','RA_MAT','','2016060108:00:00'})
aAdd(aSXB,{'FS013','6','01','','','','','RA_FILIAL = MV_PAR02','','2016060108:00:00'})
aAdd(aSXB,{'FS013','7','01','','','','','Space(FwSizeFilial())','','2016060108:00:00'})
aAdd(aSXB,{'FS013','7','02','','','','','Replicate("Z",FwSizeFilial())','','2016060108:00:00'})
aAdd(aSXB,{'FSSRY','1','01','DB','Roteiro','Roteiro','Roteiro','SRY','','2016060108:00:00'})
aAdd(aSXB,{'FSSRY','2','01','01','Roteiro','Procedimient','Procedure','','','2016060108:00:00'})
aAdd(aSXB,{'FSSRY','4','01','01','Roteiro','Procedimient','Procedure','RY_CALCULO','','2016060108:00:00'})
aAdd(aSXB,{'FSSRY','4','01','02','Desc.Rot.','Desc.Proc.','Proced.Desc.','RY_DESC','','2016060108:00:00'})
aAdd(aSXB,{'FSSRY','5','01','','','','','SRY->RY_CALCULO','','2016060108:00:00'})
aAdd(aSXB,{'FSSRY','6','01','','','','','SRY->RY_TIPO $ "5,6,2,3,1,F"','','2016060108:00:00'})
aAdd(aSX3Hlp,{'RA_BCDEPSA','Informe o Código do banco e agência  naqual será depositado o pagamento dosalário do funcionário.'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
