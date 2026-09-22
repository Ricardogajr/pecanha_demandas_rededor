/*
{Protheus.doc} U11001
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 27/07/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423045_EF_003
@Obs Fontes: F1100101.PRW,F1100102.PRW,F1100103.PRW,PE_GP240VAL.PRW,PE_MDTA6854.PR
*/
#INCLUDE 'PROTHEUS.CH'
User Function U11001(lOnlyInfo)
Local aInfo := {'11','001','RELATORIO MDT AFASTAMENTOS','27/07/17','14:33','011773012011100741U0123','03/08/17','18:55',''}
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
aAdd(aSIX,{'PAG','1','PAG_ TPMAN + PAG_DTMAN + PAG_HRMAN + PAG_NUSER'         ,'PAG_ TPMAN + PAG_DTMAN + PAG_HRMAN + PAG_NUSER'         ,'','','U','','','S','2017072714:28:53'})
aAdd(aSIX,{'PAG','2','PAG_FILIAL+PAG_MAT+PAG_CC+PAG_DTMAN+PAG_HRMAN+PAG_NUSER','PAG_FILIAL+PAG_MAT+PAG_CC+PAG_DTMAN+PAG_HRMAN+PAG_NUSER','','','U','','','S','2017072714:28:53'})
aAdd(aSX2,{'PAG','','PAG010','HIST CAD AFAST RETROATIVO','HIST CAD AFAST RETROATIVO','HIST CAD AFAST RETROATIVO','','E','E','E',0,'','PAG_ TPMAN + PAG_DTMAN + PAG_HRMAN + PAG_NUSER','',0,'','','','','','',0,0,0,'2017072714:28:45'})
aAdd(aSX3,{'PAG','01','PAG_FILIAL','C',08,0,'Filial      ','Sucursal    ','Branch      ','Filial do Sistema    ','Sucursal             ','Branch of the System ','@!','','€€€€€€€€€€€€€€€','','',1,'þÀ','','','U','N','','','','','','','','','','','033','','','','','','','','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','02','PAG_TPMAN' ,'C',01,0,'Tp Manutença','Tp Manutença','Tp Manutença','Tipo de Manutenção   ','Tipo de Manutenção   ','Tipo de Manutenção   ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','I=Incluir;A=Alterar;E=Excluir','I=Incluir;A=Alterar;E=Excluir','I=Incluir;A=Alterar;E=Excluir','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','03','PAG_DTMAN' ,'D',08,0,'Dt Manutença','Dt Manutença','Dt Manutença','Data de Manutenção   ','Data de Manutenção   ','Data de Manutenção   ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','04','PAG_HRMAN' ,'C',08,0,'Hr Manutença','Hr Manutença','Hr Manutença','Hora de Manutenção   ','Hora de Manutenção   ','Hora de Manutenção   ','@ 99:99:99','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','05','PAG_NUSER' ,'C',15,0,'Nome Usuario','Nome Usuario','Nome Usuario','Nome do Usuario      ','Nome do Usuario      ','Nome do Usuario      ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','€','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','06','PAG_CC'    ,'C',11,0,'Centro Custo','Centro Custo','Centro Custo','Centro de Custo      ','Centro de Custo      ','Centro de Custo      ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','07','PAG_DESCCC','C',20,0,'Desc C.Custo','Desc C.Custo','Desc C.Custo','Desc Centro de Custo ','Desc Centro de Custo ','Desc Centro de Custo ','','','€€€€€€€€€€€€€€ ','POSICIONE("CTT",1,XFILIAL("CTT")+M->PAG_CC,"CTT->CTT_NOME")','',0,'þÀ','','','U','N','V','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','08','PAG_MAT'   ,'C',06,0,'Cod.Matric  ','Cod.Matric  ','Cod.Matric  ','Codigo da Matricula  ','Codigo da Matricula  ','Codigo da Matricula  ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','09','PAG_NOME'  ,'C',30,0,'Nome Func.  ','Nome Func.  ','Nome Func.  ','Nome do Funcionario  ','Nome do Funcionario  ','Nome do Funcionario  ','','','€€€€€€€€€€€€€€ ','POSICIONE("SRA",1,XFILIAL("SRA")+M->PAG_MAT,"SRA->RA_NOME")','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','10','PAG_ADMISS','D',08,0,'Dt. Admissão','Dt. Admissão','Dt. Admissão','Data de Admissão     ','Data de Admissão     ','Data de Admissão     ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','11','PAG_SITFOL','C',01,0,'Sit. Folha  ','Sit. Folha  ','Sit. Folha  ','Situação da Folha    ','Situação da Folha    ','Situação da Folha    ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','12','PAG_CATFUN','C',01,0,'Cat. Funcion','Cat. Funcion','Cat. Funcion','Categoria Funcionário','Categoria Funcionário','Categoria Funcionário','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','13','PAG_TPAFAS','C',01,0,'Tipo Afast. ','Tipo Afast. ','Tipo Afast. ','Tipo de Afastamento  ','Tipo de Afastamento  ','Tipo de Afastamento  ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','14','PAG_CDAFAS','C',03,0,'Cod Ausência','Cod Ausência','Cod Ausência','Codido de Ausência   ','Codido de Ausência   ','Codido de Ausência   ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','15','PAG_TPDESC','C',75,0,'Desc. Ausênc','Desc. Ausênc','Desc. Ausênc','Descrição Ausência   ','Descrição Ausência   ','Descrição Ausência   ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','16','PAG_SEQAFA','C',03,0,'Sequência   ','Sequência   ','Sequência   ','Codigo da Sequência  ','Codigo da Sequência  ','Codigo da Sequência  ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','17','PAG_DTAFAS','D',08,0,'Data Afast. ','Data Afast. ','Data Afast. ','Data Inicio do Afast.','Data Inicio do Afast.','Data Inicio do Afast.','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
aAdd(aSX3,{'PAG','18','PAG_DTRETO','D',08,0,'Dt Fim Afast','Dt Fim Afast','Dt Fim Afast','Data Final do Afast. ','Data Final do Afast. ','Data Final do Afast. ','','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','','','','','','','','','N','N','','','','2017072714:27:47'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
