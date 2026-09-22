/*
{Protheus.doc} U05004
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 19/12/2016
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423039_EF_004
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U05004(lOnlyInfo)
Local aInfo := {'05','004','SOLICITAÇÃO DE MOVIMENTAÇÃO DE PESSOAL','19/12/16','09:12','004692052100400295U0111','24/04/17','11:42',''}
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
aAdd(aSX3,{'SRA','S1','RA_XSTMVTO','C',1,0,'Status Solic','Status Solic','Status Solic','Status Solicitaçao','Status Solicitaçao','Status Solicitaçao','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2016121909:11:15'})
aAdd(aSX6,{'','FS_BLQSLTF','C','S=Bloqueia incluir uma solicitação de transferênci','rio.(fonte: F0500401).','','a com alteração de Salario. N=Permite Incluir uma','','','solicitação de Transferência com Alteração de Sala','','','S','','','U','','','','','','','2016121909:11:29'})
aAdd(aSX6,{'','FS_BTCONF','C','Informar as filiails+matriculas que poderão acessa','','','o botão de configuração de parametros especiificos','','','(Fonte: F0500401).','','','01010002000006','','','U','','','','','','','2016121909:11:29'})
aAdd(aSX6,{'','FS_CTABAXV','C','Codigo da tabela Movimentações de Pessoal X Visões','','','(Fonte: F0500401).','','','','','','U004','','','U','','','','','','','2016121909:11:29'})
aAdd(aSX6,{'','FS_DEPTCAN','C','Codigos dos departamentos que poderão acessar o bo','','','tão Cancelar Solicitação (Fonte: F0500401).','','','','','','000000008','','','U','','','','','','','2016121909:11:29'})
aAdd(aSX6,{'','FS_PSALSUP','N','Se  não preenchido qualquer solicitaçao de aumento','o diferenciada que não esta relacionada a tabela U','','salarial não passará  por uma  visão  diferenciada','004. (Fonte: F0500401).','','Caso esteja preenchido, será enviado para  um visã','','','15','','','U','','','','','','','2016121909:11:29'})
aAdd(aSX6,{'','FS_VSALSUP','C','Codigo da Visão quando ultrapassar a solicitação d','','','e aumento de salario ultrapassar os limtes  estipu','','','lados (Fonte: F0500401).','','','000009','','','U','','','','','','','2016121909:11:29'})
aAdd(aSXB,{'FSSQBM','1','01','DB','Depto. Mov.Pessoal','Depto. Mov.Pessoal','Depto. Mov.Pessoal','SQB','','2017012713:13:13'})
aAdd(aSXB,{'FSSQBM','2','01','01','Departamento','Departamento','Departamento','','','2017012713:13:13'})
aAdd(aSXB,{'FSSQBM','4','01','01','Departamento','Departamento','Departamento','QB_DEPTO','','2017012713:13:13'})
aAdd(aSXB,{'FSSQBM','4','01','02','Descricao','Descricao','Descricao','QB_DESCRIC','','2017012713:13:13'})
aAdd(aSXB,{'FSSQBM','5','01','','','','','SQB->QB_DEPTO','','2017012713:13:13'})
aAdd(aSXB,{'FSSQBM','6','01','','','','','@#U_F0500411(1)','','2017012713:13:13'})
aAdd(aSXB,{'FSCTTM','1','01','DB','C.Custo Mov.Pessoal','C.Custo Mov.Pessoal','C.Custo Mov.Pessoal','CTT','','2017012713:13:13'})
aAdd(aSXB,{'FSCTTM','2','01','01','C.Custo','C.Custo','C.Custo','','','2017012713:13:13'})
aAdd(aSXB,{'FSCTTM','4','01','01','C.Custo','C.Custo','C.Custo','CTT_CUSTO','','2017012713:13:13'})
aAdd(aSXB,{'FSCTTM','4','01','02','Desc Moeda 1','Desc Moeda 1','Desc Moeda 1','CTT_DESC01','','2017012713:13:13'})
aAdd(aSXB,{'FSCTTM','5','01','','','','','CTT->CTT_CUSTO','','2017012713:13:13'})
aAdd(aSXB,{'FSCTTM','6','01','','','','','@#U_F0500411(2)','','2017012713:13:13'})
aAdd(aSXB,{'FSRCLM','1','01','DB','Posto Mov.Pessoal','Posto Mov.Pessoal','Posto Mov.Pessoal','RCL','','2017012713:13:13'})
aAdd(aSXB,{'FSRCLM','2','01','01','Cod.Depto+Codigo','Cod.Depto+Codigo','Cod.Depto+Codigo','','','2017012713:13:13'})
aAdd(aSXB,{'FSRCLM','4','01','01','Codigo Posto','Codigo Posto','Codigo Posto','RCL_POSTO','','2017012713:13:13'})
aAdd(aSXB,{'FSRCLM','4','01','02','Situacao','Situacao','Situacao','RCL_STATUS','','2017012713:13:13'})
aAdd(aSXB,{'FSRCLM','5','01','','','','','RCL->RCL_POSTO','','2017012713:13:13'})
aAdd(aSXB,{'FSRCLM','6','01','','','','','@#U_F0500411(3)','','2017012713:13:13'})
aAdd(aSXB,{'FSRCL2','1','01','RE','Postos Movim. Transf','Postos Movim. Transf','Postos Movim. Transf','RCL','','2017042110:29:52'})
aAdd(aSXB,{'FSRCL2','2','01','01','','','','U_FSRCL2()','','2017042110:29:52'})
aAdd(aSXB,{'FSRCL2','5','01','','','','','U_FSRCL2R1()','','2017042110:29:52'})
aAdd(aSXB,{'FSRCL2','5','02','','','','','u_FSRCL2R2()','','2017042110:29:52'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
