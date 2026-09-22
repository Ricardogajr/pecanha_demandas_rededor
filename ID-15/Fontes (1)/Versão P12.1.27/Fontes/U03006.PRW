/*
{Protheus.doc} U03006
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 13/07/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN00000463701_EF_006
@Project NÃO IDENTIFICADO
@Obs Fontes: F0300601.PRW,F0300602.PRW,F0300603.PRW,F0300604.PRW,F0300605.PR
@Obs Fontes: F0300606.PRW,F0300607.PRW,F0300608.PRW,F0300609.PRW,F0300610.PR
*/
#INCLUDE 'PROTHEUS.CH'
User Function U03006(lOnlyInfo)
Local aInfo := {'03','006','PLANO DE SAUDE','13/07/17','16:01','006731032010600763U0110','14/07/17','12:12','731110076201'}
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
aAdd(aSX1,{'FSW0300602','01','Filial','Filial','Filial','MV_CH0','C',8,0,0,'G','','MV_PAR01','','','','D MG 01','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300602','02','Escolha o plano','Escolha o plano','Escolha o plano','MV_CH0','C',1,0,1,'C','','MV_PAR02','Plano saude','Plano saude','Plano saude','','','Odontologico','Odontologico','Odontologico','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300602','03','Dir Arquivo','Dir Arquivo','Dir Arquivo','MV_CH0','C',30,0,0,'G','','MV_PAR03','','','','C:\AREA1\COPAR.TXT','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','01','Filial de','Filial de','Filial de','MV_CH0','C',8,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','02','Filial ate','Filial ate','Filial ate','MV_CH0','C',8,0,0,'G','','MV_PAR02','','','','ZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','03','Periodo Inicial De','Periodo Inicial De','Periodo Inicial De','MV_CH0','C',6,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','RCH','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','04','Periodo Inicial Ate','Periodo Inicial Ate','Periodo Inicial Ate','MV_CH0','C',6,0,0,'G','','MV_PAR04','','','','ZZZZZZ','','','','','','','','','','','','','','','','','','','','','RCH','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','05','Admissao de','Admissao de','Admissao de','MV_CH0','D',8,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','06','Admissao ate','Admissao ate','Admissao ate','MV_CH0','D',8,0,0,'G','','MV_PAR06','','','','29991231','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','07','Matricula De','Matricula De','Matricula De','MV_CH0','C',6,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','SRA','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','08','Matricula Ate','Matricula Ate','Matricula Ate','MV_CH0','C',6,0,0,'G','','MV_PAR08','','','','ZZZZZZ','','','','','','','','','','','','','','','','','','','','','SRA','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','09','Tipo de arquivo','Tipo de arquivo','Tipo de arquivo','MV_CH0','N',1,0,1,'C','','MV_PAR09','Medico','Medico','Medico','','','Odontologico','Odontologico','Odontologico','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300603','10','Caminho de gravaçao','Caminho de gravaçao','Caminho de gravaçao','MV_CH1','C',20,0,0,'G','','MV_PAR10','','','','c:\area1\DEPE','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','01','Filial de','Filial de','Filial de','MV_CH0','C',8,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','02','Filial ate','Filial ate','Filial ate','MV_CH0','C',8,0,0,'G','','MV_PAR02','','','','ZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','03','Periodo Inicial De','Periodo Inicial De','Periodo Inicial De','MV_CH0','C',6,0,0,'G','','MV_PAR03','','','','0','','','','','','','','','','','','','','','','','','','','','RCH','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','04','Periodo Inicial Ate','Periodo Inicial Ate','Periodo Inicial Ate','MV_CH0','C',6,0,0,'G','','MV_PAR04','','','','ZZZZZZ','','','','','','','','','','','','','','','','','','','','','RCH','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','05','Admissao de','Admissao de','Admissao de','MV_CH0','D',8,0,0,'G','','MV_PAR05','','','','20000101','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','06','Admissao ate','Admissao ate','Admissao ate','MV_CH0','D',8,0,0,'G','','MV_PAR06','','','','20161031','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','07','Matricula De','Matricula De','Matricula De','MV_CH0','C',6,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','SRA','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','08','Matricula Ate','Matricula Ate','Matricula Ate','MV_CH0','C',6,0,0,'G','','MV_PAR08','','','','ZZZZZZ','','','','','','','','','','','','','','','','','','','','','SRA','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','09','Tipo de arquivo','Tipo de arquivo','Tipo de arquivo','MV_CH0','N',1,0,1,'C','','MV_PAR09','Medico','Medico','Medico','','','Odontologico','Odontologico','Odontologico','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300604','10','Caminho de gravaçao','Caminho de gravaçao','Caminho de gravaçao','MV_CH1','C',20,0,0,'G','','MV_PAR10','','','','c:\Enviar\grpFamilia','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300605','01','Filial de','Filial de','Filial de','MV_CH0','C',8,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300605','02','Filial ate','Filial ate','Filial ate','MV_CH0','C',8,0,0,'G','','MV_PAR02','','','','ZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300605','03','Periodo Final De','Periodo Final De','Periodo Final De','MV_CH0','C',6,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','RCH','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300605','04','Periodo Final Ate','Periodo Final Ate','Periodo Final Ate','MV_CH0','C',6,0,0,'G','','MV_PAR04','','','','ZZZZZZ','','','','','','','','','','','','','','','','','','','','','RCH','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300605','05','Demissao De','Demissao De','Demissao De','MV_CH0','D',8,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300605','06','Demissao Ate','Demissao Ate','Demissao Ate','MV_CH0','D',8,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300605','07','Tipo de Arquivo','Tipo de Arquivo','Tipo de Arquivo','MV_CH0','C',1,0,1,'C','','MV_PAR07','Medico','Medico','Medico','','','Odontologico','Odontologico','Odontologico','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300605','08','Caminho de Gravação','Caminho de Gravação','Caminho de Gravação','MV_CH0','C',40,0,0,'G','','MV_PAR08','','','','C:/AREA1/EXCLU','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300606','01','Filial de','Filial de','Filial de','MV_CH0','C',8,0,0,'G','','MV_PAR01','','','','D MG 01','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300606','02','Filial ate','Filial ate','Filial ate','MV_CH0','C',8,0,0,'G','','MV_PAR02','','','','M PR 02','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300606','03','Transferencia de','Transferencia de','Transferencia de','MV_CH0','D',8,0,0,'G','','MV_PAR03','','','','20160101','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300606','04','Transferencia ate','Transferencia ate','Transferencia ate','MV_CH0','D',8,0,0,'G','','MV_PAR04','','','','20161031','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300606','05','Matricula De','Matricula De','Matricula De','MV_CH0','C',8,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','SRA','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300606','06','Matricula Ate','Matricula Ate','Matricula Ate','MV_CH0','C',8,0,0,'G','','MV_PAR06','','','','C:\AREA1\TRANSF','','','','','','','','','','','','','','','','','','','','','SRA','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300606','07','Tipo de arquivo','Tipo de arquivo','Tipo de arquivo','MV_CH0','C',1,0,1,'C','','MV_PAR07','Medico','Medico','Medico','','','Odontologico','Odontologico','Odontologico','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300606','08','Caminho do arquivo','Caminho do arquivo','Caminho do arquivo','MV_CH0','C',40,0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300607','01','Filial','Filial','Filial','MV_CH0','C',8,0,0,'G','','MV_PAR01','','','','D MG 01','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300607','02','Escolha o plano','Escolha o plano','Escolha o plano','MV_CH0','C',1,0,1,'C','','MV_PAR02','Plano saude','Plano saude','Plano saude','','','Odontologico','Odontologico','Odontologico','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300607','03','Caminho do arquivo','Caminho do arquivo','Caminho do arquivo','MV_CH0','C',40,0,0,'G','','MV_PAR03','','','','C:\AREA1\IMPCAR.CSV','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300610','01','Filial de','Filial de','Filial de','MV_CH0','C',8,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300610','02','Filial ate','Filial ate','Filial ate','MV_CH0','C',8,0,0,'G','','MV_PAR02','','','','ZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','XM0','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300610','03','Periodo Inicial De','Periodo Inicial De','Periodo Inicial De','MV_CH0','C',6,0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','RCH','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300610','04','Periodo Inicial Ate','Periodo Inicial Ate','Periodo Inicial Ate','MV_CH0','C',6,0,0,'G','','MV_PAR04','','','','ZZZZZZ','','','','','','','','','','','','','','','','','','','','','RCH','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300610','05','Matricula De','Matricula De','Matricula De','MV_CH0','C',6,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','SRA','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300610','06','Matricula Ate','Matricula Ate','Matricula Ate','MV_CH0','C',6,0,0,'G','','MV_PAR06','','','','ZZZZZZ','','','','','','','','','','','','','','','','','','','','','SRA','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300610','07','Tipo de arquivo','Tipo de arquivo','Tipo de arquivo','MV_CH0','N',1,0,1,'C','','MV_PAR07','Medico','Medico','Medico','','','Odontologico','Odontologico','Odontologico','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX1,{'FSW0300610','08','Caminho de gravaçao','Caminho de gravaçao','Caminho de gravaçao','MV_CH1','C',20,0,0,'G','','MV_PAR08','','','','c:\Enviar\mudPlano','','','','','','','','','','','','','','','','','','','','','','','','','','','2017071315:59:20'})
aAdd(aSX3,{'RHK','13','RHK_NCARVD','C',20,0,'N Carteira','N Carteira','N Carteira','N Carteira','N Carteira','N Carteira','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017071315:58:47'})
aAdd(aSX3,{'RHK','14','RHK_XSTAT','C',1,0,'Status','Status','Status','Status','Status','Status','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','1=Grupo Familiar;2=Com troca de fornecedor;3=Sem troca de fornecedor;4=Demissão;5=Voluntária','','','','','','','','','','','','N','N','','','','2017071315:58:47'})
aAdd(aSX3,{'RHL','12','RHL_NCARVD','C',20,0,'N Carteira','N Carteira','N Carteira','N Carteira','N Carteira','N Carteira','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017071315:58:47'})
aAdd(aSX3,{'RHL','13','RHL_XSTAT','C',1,0,'Status','Status','Status','Status','Status','Status','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','1=Grupo Familiar;2=Com troca de fornecedor;3=Sem troca de fornecedor;4=Demissão;5=Voluntária;6=Inclusão de dependente','','','','','','','','','','','','N','N','','','','2017071315:58:47'})
aAdd(aSX3,{'RHM','14','RHM_XSTAT','C',1,0,'Status','Status','Status','Status','Status','Status','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','1=Grupo Familiar;2=Com troca de fornecedor;3=Sem troca de fornecedor;4=Demissão;5=Voluntária;6=Inclusão de dependente','','','','','','','','','','','','N','N','','','','2017071315:58:47'})
aAdd(aSX3Hlp,{'RHK_XSTAT','1= Grupo Familiar;2=Com troca de fornecedor;3=Sem troca de fornecedor;4=Demissão;5=Voluntária'})
aAdd(aSX3Hlp,{'RHL_XSTAT','1=Grupo Familiar;2=Com troca de fornecedor;3=Sem troca de fornecedor;4=Demissão;5=Voluntária;6=Inclusão de dependente'})
aAdd(aSX3Hlp,{'RHM_XSTAT','1=Grupo Familiar;2=Com troca de fornecedor;3=Sem troca de fornecedor;4=Demissão;5=Voluntária;6=Inclusão de dependente'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
