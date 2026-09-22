/* 
{Protheus.doc} U05017
Função de instalação de dicionario especifico.
@author	FsTools V6.2.14
@since 07/12/2017
@param lOnlyInfo Indica se deve retornar so as informacoes sobre o update ou todos os ajustes a serem realizados
@Project MAN0000007423048_EF_017 MAN0000007423048_EF_018 MAN0000007423048_EF_019 CLIENTE REDEDOR
@Project MAN0000007423048_EF_019 CLIENTE REDEDOR
@Obs Fontes: F0501701.PRW,F0501702.PRW,F0501703.PRW
@Obs manual desmark
*/
#INCLUDE 'PROTHEUS.CH'
User Function U05017(lOnlyInfo)
Local aInfo := {'05','017','PERGUNTE FSW0501703 E CAMPO RGB_XIMPAP','07/12/17','18:33','007773152110700285U1103','11/12/17','07:55','773103028211'}
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
aAdd(aSX1,{'FSW0501703','01','Processo ?','¿Proceso ?','Process ?','MV_CH1','C',5,0,0,'G','Gpem020VldPrc() .and. Gpm020SetVar()','MV_PAR01','','','','00001','','','','','','','','','','','','','','','','','','','','','RCJ','S','','.RHPRO.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','02','Roteiro ?','¿Procedimiento ?','Script ?','MV_CH2','C',3,0,0,'G','Gpem160Rot(MV_PAR01, ,,"MV_PAR02",.T.,.T.)','MV_PAR02','','','','FOL','','','','','','','','','','','','','','','','','','','','','SRY01','S','','.RHROT.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','03','Período ?','¿Periodo ?','Period ?','MV_CH3','C',6,0,0,'S','','MV_PAR03','','','','201709','','','','','','','','','','','','','','','','','','','','','','S','','.RHPER.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','04','Nro. Pagamento ?','¿Nº Pago ?','Payment No. ?','MV_CH4','C',2,0,0,'S','','MV_PAR04','','','','01','','','','','','','','','','','','','','','','','','','','','','S','','.RHNPA.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','05','Tipo Cancelamento ?','¿Tipo Anulacion ?','Cancellation Type ?','MV_CH5','N',1,0,3,'C','','MV_PAR05','Integ. ApData','Integ. ApData','Integ. ApData','','','','','','','','','','','','','','','','','','','','','','','S','','.GPEM16001.','9','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','06','Informe as verbas ?','¿Informe los conceptos ?','Enter Payroll Items ?','MV_CH6','C',30,0,0,'G','fVerbas() .and. NaoVazio()','MV_PAR06','','','','B46','','','','','','','','','','','','','','','','','','','','','','S','','.GPEM16012.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','07','Filial De ?','¿De Sucursal ?','Branch From ?','MV_CH7','C',2,0,0,'G','','MV_PAR07','','','','01130001','','','','','','','','','','','','','','','','','','','','','XM0','S','033','.RHFILDE.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','08','Filial Até ?','¿A Sucursal ?','Branch To ?','MV_CH8','C',2,0,0,'G','NaoVazio()','MV_PAR08','','','','01130001','','','','','','','','','','','','','','','','','','','','','XM0','S','033','.RHFILAT.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','09','Centro de Custo De ?','¿De Centro de Costo ?','Cost Center From ?','MV_CH9','C',9,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','CTT','S','004','.RHCCDE.','@!','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','10','Centro de Custo Até ?','¿A Centro de Costo ?','Cost Center To ?','MV_CHA','C',9,0,0,'G','NaoVazio()','MV_PAR10','','','','ZZZZZZZZZZZ','','','','','','','','','','','','','','','','','','','','','CTT','S','004','.RHCCAT.','@!','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','11','Matrícula De ?','¿De Matricula ?','Registration From ?','MV_CHB','C',6,0,0,'G','','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','','SRA','S','','.RHMATD.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','12','Matrícula Até ?','¿A Matricula ?','Registration To ?','MV_CHC','C',6,0,0,'G','NaoVazio()','MV_PAR12','','','','ZZZZZ','','','','','','','','','','','','','','','','','','','','','SRA','S','','.RHMATA.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','13','Situações ?','¿Situaciones ?','Status ?','MV_CHD','C',5,0,0,'G','fSituacao()','MV_PAR13','','','','ADFT','','','','','','','','','','','','','','','','','','','','','','S','','.RHSITUA.','','','2017120718:32:34'})
aAdd(aSX1,{'FSW0501703','14','Categorias ?','¿Categorias ?','Categories ?','MV_CHE','C',15,0,0,'G','fCategoria()','MV_PAR14','','','','ACDEGHIJMPST***','','','','','','','','','','','','','','','','','','','','','','S','','.RHCATEG.','','','2017120718:32:34'})
aAdd(aSX3,{'RGB','34','RGB_XIMPAP','C',1,0,'Int ApData','Int ApData','Int ApData','Integraçao Apdata?','Integraçao Apdata?','Integraçao Apdata?','@!','','€€€€€€€€€€€€€€ ','','',0,'þÀ','','','U','N','A','R','','','','','','','.F.','','','','','','','','N','N','','','','2017120718:32:28'})
aAdd(aSX3Hlp,{'RGB_XIMPAP','Informa se o registro veio daintegraçaoApdata x Protheus'})
Return {aInfo,aSIX,aSX1,aSX2,aSX3,aSX6,aSX7,aSXA,aSXB,aSX3Hlp,aCarga}
