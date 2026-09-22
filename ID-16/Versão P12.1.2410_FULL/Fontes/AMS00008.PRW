#Include 'Protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
{Protheus.doc} AMS00008()
Funcao por JOB/Rotina para integrar Alteracao no Cadastro de Funcionários (PIS/Sindicato/Carga Horaria) 
@Author     Rogerio Carvalho
@Since      19/07/2018
@Version    P12.1.07
@Project    
*/

User Function AMS00008()

    Local aAreaAnt := getarea()
    Local cDtIntPS := " "
    Local cPA6ID   := " "
    Local cEmpInt  := " "
    Local cFilInt  := " "
    Local cQuery   := " "
    Local lIntRot  := .t.
    Local cQueryUpd:= " "
    Local nExecSql := 0
    Local nIntFer  := 0
    Local lUpdate  := .T.

    If empty(alltrim(cDtIntPS))
        cDtIntPS := DTOS(date())
    Endif

    If Isblind()
        lIntRot := .f.
        cEmpInt:="01"
        cFilInt:="01010001"

        If !RpcSetEnv(cEmpInt,cFilInt,,,"FAT",,)
            Conout("Integração Admissão - Cadastro de Funcionarios (INC) - Inicialização de Ambiente Não Realizada")
            restarea(aAreaAnt)
            Return

        Endif

        Conout("Integração Admissão - Cadastro de Funcionarios (INC) - Inicialização de Ambiente Não Realizada")

        cDtIntPS := Supergetmv("ES_DTINTPS",.T.," ") // variavel para ser utilizada com data retroativa para integracao

        If empty(alltrim(cDtIntPS))
            cDtIntPS := DTOS(date())
        Endif

        Conout(cDtIntPs)

        cQuery  := " SELECT R9_FILIAL, R9_MAT,R9_CAMPO,R9_DATA,R9_XDTOPER,R9_XHROPER, R_E_C_N_O_ "
        cQuery  += " FROM "+ RetSqlName("SR9") + " SR9 "
        cQuery  += " WHERE SR9.D_E_L_E_T_ = ' ' "
        cQuery  += " AND R9_XINTINC = ' ' "
        cQuery  += " AND R9_XIDINC = '                                ' "
        cQuery  += " AND R9_XDTOPER = '"+cDtIntPS+"' "
        //cQuery  += " AND R9_CAMPO IN ('RA_PIS' , 'RA_HRSMES' , 'RA_SINDICA' , 'RA_NOMECMP') "	 //Melhoria inclui o nome completo na query de alteração para subir no APDATA - Lucas Miranda de  Aguiar 30/12/2021 Thais Paiva - 14205299
		cQuery  += " AND R9_CAMPO IN ('RA_PIS' , 'RA_HRSMES' , 'RA_SINDICA' , 'RA_NOMECMP', 'RA_NOME', 'RA_CIC', 'RA_VIEMRAI' , " //Thais Paiva - 14205299
		cQuery  += " 'RA_ADMISSA', 'RA_NASC', 'RA_NACIONA', 'RA_TIPOADM', 'RA_SEXO', 'RA_DDDFONE', 'RA_TELEFON' )" //Thais Paiva - 14205299
        cQuery  += " ORDER BY SR9.R_E_C_N_O_  "

        Conout(cQuery)

    Else

        nIntFer := MessageBox ( "Deseja realmente [INTEGRAR] ALTERAÇÃO - CADASTRO DE FUNCIONARIOS para esta Filial ["+cFilant+"] agora???",'INTEGRACAO ALTERAÇÃO - CADASTRO DE FUNCIONARIOS', 4 )

        If nIntFer <> 6
            restarea(aAreaAnt)
            Return
        Endif

        cQuery  := " SELECT R9_FILIAL, R9_MAT, R9_CAMPO,R9_DATA,R9_XDTOPER,R9_XHROPER,R_E_C_N_O_ "
        cQuery  += " FROM "+ RetSqlName("SR9") + " SR9 "
        cQuery  += " WHERE SR9.D_E_L_E_T_ = ' ' "
        cQuery  += " AND R9_FILIAL ='" + cFilant + "' "
        cQuery  += " AND R9_XINTINC = ' ' "
        cQuery  += " AND R9_XIDINC = '                                ' "
        cQuery  += " AND R9_XDTOPER = '"+cDtIntPS+"' "
        //cQuery  += " AND R9_CAMPO IN ('RA_PIS' , 'RA_HRSMES' , 'RA_SINDICA' , 'RA_NOMECMP') "	 //Melhoria inclui o nome completo na query de alteração para subir no APDATA - Lucas Miranda de  Aguiar 30/12/2021 Thais Paiva - 14205299
		cQuery  += " AND R9_CAMPO IN ('RA_PIS' , 'RA_HRSMES' , 'RA_SINDICA' , 'RA_NOMECMP', 'RA_NOME', 'RA_CIC', 'RA_VIEMRAI' , " //Thais Paiva - 14205299
		cQuery  += " 'RA_ADMISSA', 'RA_NASC', 'RA_NACIONA', 'RA_TIPOADM', 'RA_SEXO', 'RA_DDDFONE', 'RA_TELEFON' )" //Thais Paiva - 14205299
	        cQuery  += " ORDER BY SR9.R_E_C_N_O_  "

        ProcRegua(0)

    Endif


// inclusao
    If Select("TSR9") > 0
        TSR9->(DbCloseArea())
    EndIf

    TCQUERY cQuery NEW ALIAS "TSR9"

    TSR9->( dbGoTop() )

    While TSR9->(!Eof())

        If lIntRot
            ProcRegua(TSR9->(RecCount()))

            IncProc("[INTEGRACAO ALTERAÇÃO - CADASTROS DE FUNCIONÁRIOS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + TSR9->R9_MAT)
        Endif
        //Pensar em fazer uma outra tratativa caso o campo seja o do nome completo, chamar a função abaixo mas com os dados da SRA
        //If TSR9->R9_CAMPO == "RA_NOMECMP" 
		If Alltrim(TSR9->R9_CAMPO) == "RA_NOMECMP" .OR. Alltrim(TSR9->R9_CAMPO) == "RA_NOME" .OR. Alltrim(TSR9->R9_CAMPO) == "RA_CIC" .OR. ;
		   Alltrim(TSR9->R9_CAMPO) == "RA_VIEMRAI" .OR. Alltrim(TSR9->R9_CAMPO) == "RA_ADMISSA" .OR. Alltrim(TSR9->R9_CAMPO) == "RA_NASC" .OR. ;
		   Alltrim(TSR9->R9_CAMPO) == "RA_NACIONA" .OR. Alltrim(TSR9->R9_CAMPO) == "RA_TIPOADM" .OR. Alltrim(TSR9->R9_CAMPO) == "RA_SEXO" .OR. ;
		   Alltrim(TSR9->R9_CAMPO) == "RA_DDDFONE" .OR. Alltrim(TSR9->R9_CAMPO) == "RA_TELEFON" .OR. Alltrim(TSR9->R9_CAMPO) == "RA_PIS" .OR. ;
		   Alltrim(TSR9->R9_CAMPO) == "RA_SINDICA"
            DbSelectArea("SRA")
            DbSetOrder(13)
            If DbSeek(TSR9->R9_MAT + TSR9->R9_FILIAL)
                U_F0600107()
                lUpdate := .T.
            Else
                lUpdate := .F.
                Conout("Não encontrou a matricula/filial utilizando a chave " + TSR9->RA_MAT + TSR9->RA_FILIAL)
            EndIf
            cPA6ID := AllTrim(u_ams00003())
        Else
            cPA6ID := U_F0600901("F0600301",TSR9->R_E_C_N_O_,"SR9",	TSR9->R9_FILIAL + TSR9->R9_MAT + alltrim(TSR9->R9_CAMPO) + TSR9->R9_DATA,"",CTOD(""),"UPSERT") // Operacao
            lUpdate := .T.
        EndIf
        If lUpdate
            cQueryUpd := " UPDATE "+ RetSqlName("SR9")
            cQueryUpd += " SET R9_XINTINC = 'S' , "
            cQueryUpd += " R9_XIDINC = '" + cPA6ID + "' , "
            cQueryUpd += " R9_XHRTRAN = '" +TIME()+"' , "
            cQueryUpd += " R9_XDTTRAN = '" +dtos(date())+"' "
            cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
            cQueryUpd += " AND R9_XINTINC = ' ' "
            cQueryUpd += " AND R9_XIDINC = '                                ' "
            cQueryUpd += " AND R9_FILIAL = '"+ TSR9->R9_FILIAL + "' "
            cQueryUpd += " AND R9_MAT = '"+ TSR9->R9_MAT + "' "
            cQueryUpd += " AND R9_XDTOPER = '"+ TSR9->R9_XDTOPER + "' "
            cQueryUpd += " AND R9_XHROPER = '"+ TSR9->R9_XHROPER + "' "
            cQueryUpd += " AND R9_CAMPO = '"+ TSR9->R9_CAMPO + "' "

            nExecSql := TCSQLEXEC(cQueryUpd)

            If nExecSql > 0
                If !lIntRot
                    Conout ( "INTEGRACAO ALTERACAO - CADASTRO DE FUNCIONARIOS - Erro na atualização de integração da tabela SR9." )
                Endif
            Endif
            cQueryUpd := " "
        EndIf
        TSR9->(dbskip())

    Enddo

    TSR9->(DbCloseArea())
    cQueryUpd := " "

Return .T.
