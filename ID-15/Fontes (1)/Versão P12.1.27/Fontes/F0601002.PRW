#Include 'Protheus.ch'

/*/{Protheus.doc}  F0601002

@Author Nairan Alves Silva
@Since  21/11/2016
@Sample U_F0601002()

@Obs Rotina Responsável por Exibir o Log das Integrações de Cadastro de Funcionário

@Project MAN0000007423040_EF_010

/*/

User Function F0601002()
Local aDados := {}

AAdd(aDados,{"Cadastro de Funcionários","EF06001","Status, ID, Filial, Matrícula, CPF, Nome, PIS, Data Admissão, Tipo Admissão, Salário,  Cargo, Data Envio, Hora de Envio, Operação, Data de Processamento, Hora de Processamento, Observação","EF06001_STATUS,EF06001_ID,EF06001_FILIAL,EF06001_MATRICULA,EF06001_CPF,EF06001_NOME,EF06001_PIS,EF06001_ADMISSA,EF06001_TIPOADM,EF06001_SALARIO,EF06001_CARGO,EF06001_DTTRANSAC,EF06001_HRTRANSAC,EF06001_OPERACAO,EF06001_DTPROCESS,EF06001_HRPROCESS,EF06001_OBSERVA"})

u_F0601001(aDados)
	
Return

/*/{Protheus.doc}  F0601003

@Author Nairan Alves Silva
@Since  21/11/2016
@Sample U_F0601003()

@Obs Rotina Responsável por Exibir o Log das Integrações de Cadastro de Afastamento

@Project MAN0000007423040_EF_010

/*/

User Function F0601003()
Local aDados := {}

AAdd(aDados,{"Cadastro de Afastamento","EF06002","Status, ID, Filial, Matrícula, Início Afastamento, Tipo Afastamento, Final Afastamento, Data Envio, Hora de Envio, Operação, Data de Processamento, Hora de Processamento, Observação","EF06002_STATUS, EF06002_ID, EF06002_FILIAL, EF06002_MATRICULA, EF06002_DTINIAFAST, EF06002_TIPOAFAST, EF06002_DTFIMAFAST, EF06002_DTTRANSAC, EF06002_HRTRANSAC,  EF06002_OPERACAO, EF06002_DTPROCESS, EF06002_HRPROCESS, EF06002_OBSERVA"})

u_F0601001(aDados)
	
Return

/*/{Protheus.doc}  F0601004

@Author Nairan Alves Silva
@Since  21/11/2016
@Sample U_F0601004()

@Obs Rotina Responsável por Exibir o Log das Integrações de Alterações Contratuais

@Project MAN0000007423040_EF_010

/*/

User Function F0601004()
Local aDados := {}

AAdd(aDados,{"Alterações Contratuais","EF06003","Status, ID, Filial, Matrícula, Data da Movimentação, Turno Origem, Sequencia Origem, Regra Origem, Turno Destino, Sequência Destino, Regra Destino, Jornada Origem, Jornada Destino, Tipo de Aumento, Valor, Sindicato, Função, Centro de Custo, Turno de Trabalho, Horas Mensais, Motivo de Alteração, Data Base do Sistema, Hora, Operação, Data de Processamento, Hora de Processamento, Observação","EF06003_STATUS, EF06003_ID, EF06003_FILIAL, EF06003_MATRICULA, EF06003_DTMOV, EF06003_TURNODE, EF06003_SEQUEDE, EF06003_REGRADE, EF06003_TURONPA, EF06003_SEQUEPA, EF06003_REGRAPA, EF06003_JORNDE, EF06003_JORNPA, EF06003_TIPO, EF06003_VALOR, EF06003_SINDICATO, EF06003_FUNCAO, EF06003_CC, EF06003_TURNO, EF06003_CARGHR, EF06003_MOTIVO, EF06003_DTTRANSAC, EF06003_HRTRANSAC, EF06003_OPERACAO, EF06003_DTPROCESS, EF06003_HRPROCESS, EF06003_OBSERVA"})

u_F0601001(aDados)
	
Return

/*/{Protheus.doc}  F0601005

@Author Nairan Alves Silva
@Since  21/11/2016
@Sample U_F0601005()

@Obs Rotina Responsável por Exibir o Log das Integrações de Cadastro de Ponto

@Project MAN0000007423040_EF_010

/*/

User Function F0601005()
Local aDados := {}

AAdd(aDados,{"Controle de Ponto","EF06004","Status, ID, Filial, Matrícula, Código da Verba, Referencia, Horas lançadas   , Valor do lançamento, Data Referência, Data Referência, Hora, Operação, Data de Processamento, Hora de Processamento, Observação","EF06004_STATUS, EF06004_ID, EF06004_FILIAL, EF06004_MATRIC, EF06004_VERBA, EF06004_REFERENCIA, EF06004_QTDA, EF06004_VALOR, EF06004_DTREFER, EF06004_DTTRANSAC, EF06004_HRTRANSAC, EF06004_OPERACAO, EF06004_DTPROCESS, EF06004_HRPROCESS, EF06004_OBSERVA"})

u_F0601001(aDados)
	
Return

/*/{Protheus.doc}  F0601006

@Author Nairan Alves Silva
@Since  21/11/2016
@Sample U_F0601006()

@Obs Rotina Responsável por Exibir o Log das Integrações de Cadastro de Férias

@Project MAN0000007423040_EF_010

/*/

User Function F0601006()
Local aDados := {}

AAdd(aDados,{"Cadastro de Férias","EF06005","Status, ID, Filial, Matrícula do Funcionário, Data Início de Férias, Data Final de Férias, Data Base do Sistema, Hora, Operação, Data de Processamento, Hora de Processamento, Observação","EF06005_STATUS, EF06005_ID, EF06005_FILIAL, EF06005_MATRICULA, EF06005_DTINIFERIAS, EF06005_DTFIMFERIAS, EF06005_DTTRANSAC, EF06005_HRTRANSAC, EF06005_OPERACAO, EF06005_DTPROCESS, EF06005_HRPROCESS, EF06005_OBSERVA"})

u_F0601001(aDados)
	
Return

/*/{Protheus.doc}  F0601007

@Author Nairan Alves Silva
@Since  21/11/2016
@Sample U_F0601007()

@Obs Rotina Responsável por Exibir o Log das Integrações de Cadastro de Troca de Empresas

@Project MAN0000007423040_EF_010

/*/

User Function F0601007()
Local aDados := {}

AAdd(aDados,{"Troca de Empresas","EF06007","Status, ID, Filial de Origerm, Matrícula de Origem, Centro de Custo Origem, Departamento Origem, Código Processo Origem, Item Contábil De, Classe de Valor De, Filial de Destino, Matricula de Destino, Centro de Custo Destino, Departamento Destino, Código Processo Destino, Item Contábil Para, Classe de Valor Para, Data de Transferência, Data Base do Sistema, Hora, Operação, Data de Processamento, Hora de Processamento, Observação","EF06007_STATUS, EF06007_ID, EF06007_FILIALORI, EF06007_MATRICORI, EF06007_CCUSTOORI, EF06007_DEPTOORI, EF06007_PROCORI, EF06007_ITEMORI, EF06007_CLVLOR, EF06007_FILIALDST, EF06007_MATRICDST, EF06007_CCUSTODST, EF06007_DEPTODST, EF06007_PROCDST, EF06007_ITEMDST, EF06007_CLVLDST, EF06007_DTTRANSF, EF06007_DTTRANSAC, EF06007_HRTRANSAC, EF06007_OPERACAO, EF06007_DTPROCESS, EF06007_HRPROCESS, EF06007_OBSERVA"})

u_F0601001(aDados)
	
Return

/*/{Protheus.doc}  F0601008

@Author Nairan Alves Silva
@Since  21/11/2016
@Sample U_F0601008()

@Obs Rotina Responsável por Exibir o Log das Integrações de Cadastro de Cálculo de Desligamento

@Project MAN0000007423040_EF_010

/*/

User Function F0601008()
Local aDados := {}

AAdd(aDados,{"Cálculo de Desligamento","EF06008","Status, ID, Filial, Matrícula, Código da verba, Referência, Quantidade, Status, Ano/Mês Ref., Data Base do Sistema, Hora da Transação, Operação, Data de Processamento, Hora de Processamento, Observações","EF06008_STATUS, EF06008_ID, EF06008_FILIAL, EF06008_MATRIC, EF06008_CODVER, EF06008_REFVER, EF06008_QTDVER, EF06008_VALVER, EF06008_ANOMESREF, EF06008_DTTRANSAC, EF06008_HRTRANSAC, EF06008_OPERACAO, EF06008_DTPROCESS, EF06008_HRPROCESS, EF06008_OBSERVA"})

u_F0601001(aDados)
	
Return

/*/{Protheus.doc}  F0601009

@Author Nairan Alves Silva
@Since  21/11/2016
@Sample U_F0601009()

@Obs Rotina Responsável por Exibir o Log das Integrações de RH

@Project MAN0000007423040_EF_010

/*/

User Function F0601009()
Local aDados := {}

AAdd(aDados,{"Cadastro de Funcionários","EF06001","Status, ID, Filial, Matrícula, CPF, Nome, PIS, Data Admissão, Tipo Admissão, Salário,  Cargo, Data Envio, Hora de Envio, Operação, Data de Processamento, Hora de Processamento, Observação","EF06001_STATUS,EF06001_ID,EF06001_FILIAL,EF06001_MATRICULA,EF06001_CPF,EF06001_NOME,EF06001_PIS,EF06001_ADMISSA,EF06001_TIPOADM,EF06001_SALARIO,EF06001_CARGO,EF06001_DTTRANSAC,EF06001_HRTRANSAC,EF06001_OPERACAO,EF06001_DTPROCESS,EF06001_HRPROCESS,EF06001_OBSERVA"})
AAdd(aDados,{"Cadastro de Afastamento","EF06002","Status, ID, Filial, Matrícula, Início Afastamento, Tipo Afastamento, Final Afastamento, Data Envio, Hora de Envio, Operação, Data de Processamento, Hora de Processamento, Observação","EF06002_STATUS, EF06002_ID, EF06002_FILIAL, EF06002_MATRICULA, EF06002_DTINIAFAST, EF06002_TIPOAFAST, EF06002_DTFIMAFAST, EF06002_DTTRANSAC, EF06002_HRTRANSAC,  EF06002_OPERACAO, EF06002_DTPROCESS, EF06002_HRPROCESS, EF06002_OBSERVA"})
AAdd(aDados,{"Alterações Contratuais","EF06003","Status, ID, Filial, Matrícula, Data da Movimentação, Turno Origem, Sequencia Origem, Regra Origem, Turno Destino, Sequência Destino, Regra Destino, Jornada Origem, Jornada Destino, Tipo de Aumento, Valor, Sindicato, Função, Centro de Custo, Turno de Trabalho, Horas Mensais, Motivo de Alteração, Data Base do Sistema, Hora, Operação, Data de Processamento, Hora de Processamento, Observação","EF06003_STATUS, EF06003_ID, EF06003_FILIAL, EF06003_MATRICULA, EF06003_DTMOV, EF06003_TURNODE, EF06003_SEQUEDE, EF06003_REGRADE, EF06003_TURONPA, EF06003_SEQUEPA, EF06003_REGRAPA, EF06003_JORNDE, EF06003_JORNPA, EF06003_TIPO, EF06003_VALOR, EF06003_SINDICATO, EF06003_FUNCAO, EF06003_CC, EF06003_TURNO, EF06003_CARGHR, EF06003_MOTIVO, EF06003_DTTRANSAC, EF06003_HRTRANSAC, EF06003_OPERACAO, EF06003_DTPROCESS, EF06003_HRPROCESS, EF06003_OBSERVA"})
AAdd(aDados,{"Controle de Ponto","EF06004","Status, ID, Filial, Matrícula, Código da Verba, Referencia, Horas lançadas   , Valor do lançamento, Data Referência, Data Referência, Hora, Operação, Data de Processamento, Hora de Processamento, Observação","EF06004_STATUS, EF06004_ID, EF06004_FILIAL, EF06004_MATRIC, EF06004_VERBA, EF06004_REFERENCIA, EF06004_QTDA, EF06004_VALOR, EF06004_DTREFER, EF06004_DTTRANSAC, EF06004_HRTRANSAC, EF06004_OPERACAO, EF06004_DTPROCESS, EF06004_HRPROCESS, EF06004_OBSERVA"})
AAdd(aDados,{"Cadastro de Férias","EF06005","Status, ID, Filial, Matrícula do Funcionário, Data Início de Férias, Data Final de Férias, Data Base do Sistema, Hora, Operação, Data de Processamento, Hora de Processamento, Observação","EF06005_STATUS, EF06005_ID, EF06005_FILIAL, EF06005_MATRICULA, EF06005_DTINIFERIAS, EF06005_DTFIMFERIAS, EF06005_DTTRANSAC, EF06005_HRTRANSAC, EF06005_OPERACAO, EF06005_DTPROCESS, EF06005_HRPROCESS, EF06005_OBSERVA"})
AAdd(aDados,{"Cadastro de Rescisao","EF06006","Status, ID, Filial, Matrícula, Data Demissao, Motivo, Data Envio, Hora Envio, Operação, Data de Processamento, Hora de Processamento, Observação","EF06006_STATUS, EF06006_ID, EF06006_FILIAL, EF06006_MATRICULA, EF06006_DTATEND, EF06006_MOTIVO, EF06006_DTTRANSAC, EF06006_HRTRANSAC, EF06006_OPERACAO, EF06006_DTPROCESS, EF06006_HRPROCESS, EF06006_OBSERVA"})
AAdd(aDados,{"Troca de Empresas","EF06007","Status, ID, Filial de Origerm, Matrícula de Origem, Centro de Custo Origem, Departamento Origem, Código Processo Origem, Item Contábil De, Classe de Valor De, Filial de Destino, Matricula de Destino, Centro de Custo Destino, Departamento Destino, Código Processo Destino, Item Contábil Para, Classe de Valor Para, Data de Transferência, Data Base do Sistema, Hora, Operação, Data de Processamento, Hora de Processamento, Observação","EF06007_STATUS, EF06007_ID, EF06007_FILIALORI, EF06007_MATRICORI, EF06007_CCUSTOORI, EF06007_DEPTOORI, EF06007_PROCORI, EF06007_ITEMORI, EF06007_CLVLOR, EF06007_FILIALDST, EF06007_MATRICDST, EF06007_CCUSTODST, EF06007_DEPTODST, EF06007_PROCDST, EF06007_ITEMDST, EF06007_CLVLDST, EF06007_DTTRANSF, EF06007_DTTRANSAC, EF06007_HRTRANSAC, EF06007_OPERACAO, EF06007_DTPROCESS, EF06007_HRPROCESS, EF06007_OBSERVA"})
AAdd(aDados,{"Cálculo de Desligamento","EF06008","Status, ID, Filial, Matrícula, Código da verba, Referência, Quantidade, Status, Ano/Mês Ref., Data Base do Sistema, Hora da Transação, Operação, Data de Processamento, Hora de Processamento, Observações","EF06008_STATUS, EF06008_ID, EF06008_FILIAL, EF06008_MATRIC, EF06008_CODVER, EF06008_REFVER, EF06008_QTDVER, EF06008_VALVER, EF06008_ANOMESREF, EF06008_DTTRANSAC, EF06008_HRTRANSAC, EF06008_OPERACAO, EF06008_DTPROCESS, EF06008_HRPROCESS, EF06008_OBSERVA"})


u_F0601001(aDados)
	
Return

/*/{Protheus.doc}  F0601010

@Author Eduardo Fernandes
@Since  21/12/2016
@Sample U_F0601010()

@Obs Rotina Responsável por Exibir o Log das Integrações do Cadastro de Rescisao

@Project MAN0000007423040_EF_010

/*/

User Function F0601010()
Local aDados := {}

AAdd(aDados,{"Cadastro de Rescisao","EF06006","Status, ID, Filial, Matrícula, Data Demissao, Motivo, Data Envio, Hora Envio, Operação, Data de Processamento, Hora de Processamento, Observação","EF06006_STATUS, EF06006_ID, EF06006_FILIAL, EF06006_MATRICULA, EF06006_DTATEND, EF06006_MOTIVO, EF06006_DTTRANSAC, EF06006_HRTRANSAC, EF06006_OPERACAO, EF06006_DTPROCESS, EF06006_HRPROCESS, EF06006_OBSERVA"})

u_F0601001(aDados)

Return
