#Include 'Protheus.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
{Protheus.doc} AMS00004()
Funcao por JOB/Rotina para integrar afastamentos
@Author     Rogerio Carvalho
@Since      24/05/2017
@Version    P12.1.07
@Project    
*/

User Function AMS00004()

Local aAreaAnt := getarea()
Local cDtIntAf := " "
Local cPA6ID   := " " 
Local cEmpInt  := " "
Local cFilInt  := " "
Local cQuery   := " "
Local lIntRot  := .t. 
Local cQueryUpd:= " "
Local nExecSql := 0
Local nIntFer  := 0

If empty(alltrim(cDtIntAf))
	cDtIntAf := DTOS(date())
Endif

If Isblind()
   lIntRot := .f.
	cEmpInt:="01"
	cFilInt:="01010001"

	If !RpcSetEnv(cEmpInt,cFilInt,,,"FAT",,)
		Conout("Integra Afastamentos (INC) - Inicialização de Ambiente Não Realizada")
		restarea(aAreaAnt)
		Return
		
	Endif

		cDtIntAf := Supergetmv("ES_DTINTAF",.T.," ") // variavel para ser utilizada com data retroativa para integracao

		If empty(alltrim(cDtIntAf))
			cDtIntAf := DTOS(date())
		Endif
	
	 cQuery  := " SELECT R8_FILIAL, R8_MAT, R8_DATAINI , R8_TIPOAFA, R8_DATA ,SR8.R_E_C_N_O_ "
	 cQuery  += " FROM "+ RetSqlName("SR8") + " SR8 ," + RetSqlName("RCM") + " RCM " 
	 cQuery  += " WHERE SR8.D_E_L_E_T_ = ' ' "
	 cQuery  += " AND RCM.D_E_L_E_T_ = ' ' "
	 cQuery  += " AND R8_TIPOAFA = RCM_TIPO "
	 cQuery  += " AND RCM_CODRAI BETWEEN '00' AND '59' "
	 cQuery  += " AND RCM_TIPOAF = '1' "	 	 
	 cQuery  += " AND R8_XINTINC = ' ' " 
	 cQuery  += " AND R8_XIDINC = '                                ' "
	 cQuery  += " AND R8_DATA = '"+cDtIntAf+"' "	 
	 cQuery  += " ORDER BY SR8.R_E_C_N_O_  "

	 cQueryA  := " SELECT R8_FILIAL, R8_MAT, R8_DATAINI , R8_TIPOAFA, R8_DATA, SR8.R_E_C_N_O_ "
	 cQueryA  += " FROM "+ RetSqlName("SR8") + " SR8 ," + RetSqlName("RCM") + " RCM "
	 cQueryA  += " WHERE SR8.D_E_L_E_T_ = ' ' "
	 cQueryA  += " AND RCM.D_E_L_E_T_ = ' ' "
	 cQueryA  += " AND R8_TIPOAFA = RCM_TIPO "
	 cQueryA  += " AND RCM_CODRAI BETWEEN '00' AND '59' "
	 cQueryA  += " AND RCM_TIPOAF = '1' "	 	 
	 cQueryA  += " AND R8_XINTINC = 'S' "	 
	 cQueryA  += " AND R8_XIDINC <> '                                ' "
	 cQueryA  += " AND R8_DATA    <> '        ' "
	 cQueryA  += " AND R8_XHROPER <> '        ' "
	 cQueryA  += " AND R8_XDTTRAN <> '        ' "	 
     cQueryA  += " AND R8_XHRTRAN <> '        ' "	 
     cQueryA  += " AND R8_DATA||R8_XHROPER > R8_XDTTRAN||R8_XHRTRAN "	 
	 cQueryA  += " ORDER BY SR8.R_E_C_N_O_  "

	 cQueryD  := " SELECT R8_FILIAL, R8_MAT, R8_DATAINI , R8_TIPOAFA, R8_DATA, SR8.R_E_C_N_O_ "
	 cQueryD  += " FROM "+ RetSqlName("SR8") + " SR8 ," + RetSqlName("RCM") + " RCM "
	 cQueryD  += " WHERE SR8.D_E_L_E_T_ = '*' "
	 cQueryD  += " AND RCM.D_E_L_E_T_ = ' ' "
	 cQueryD  += " AND R8_TIPOAFA = RCM_TIPO "
	 cQueryD  += " AND RCM_CODRAI BETWEEN '00' AND '59' "
	 cQueryD  += " AND RCM_TIPOAF = '1' "	 	 
	 cQueryD  += " AND R8_XINTINC = 'S' " 
	 cQueryD  += " AND R8_XIDINC <> '                                ' "
	 cQueryD  += " AND R8_XINTEXC = ' ' " 
	 cQueryD  += " AND R8_XIDEXC = '                                ' "
	 cQueryD  += " AND R8_DATA = '"+cDtIntAf+"' "
	 cQueryD  += " ORDER BY SR8.R_E_C_N_O_  "

	 
Else

    nIntFer := MessageBox ( "Deseja realmente [INTEGRAR] os AFASTAMENTOS para esta Filial ["+cFilant+"] agora???",'INTEGRACAO DE AFASTAMENTOS', 4 )
    
    If nIntFer <> 6
       restarea(aAreaAnt)
		Return
	Endif
	
	 cQuery  := " SELECT R8_FILIAL, R8_MAT, R8_DATAINI , R8_TIPOAFA, R8_DATA ,SR8.R_E_C_N_O_ "
	 cQuery  += " FROM "+ RetSqlName("SR8") + " SR8 ," + RetSqlName("RCM") + " RCM " 
	 cQuery  += " WHERE SR8.D_E_L_E_T_ = ' ' "
	 cQuery  += " AND RCM.D_E_L_E_T_ = ' ' "
	 cQuery  += " AND R8_TIPOAFA = RCM_TIPO "
	 cQuery  += " AND RCM_CODRAI BETWEEN '00' AND '59' "
	 cQuery  += " AND RCM_TIPOAF = '1' "	 	 
	 cQuery  += " AND R8_FILIAL ='" + cFilant + "' "	 
	 cQuery  += " AND R8_XINTINC = ' ' " 
	 cQuery  += " AND R8_XIDINC = '                                ' "
	 cQuery  += " AND R8_DATA = '"+cDtIntAf+"' "	 
	 cQuery  += " ORDER BY SR8.R_E_C_N_O_  "

	 cQueryA  := " SELECT R8_FILIAL, R8_MAT, R8_DATAINI , R8_TIPOAFA, R8_DATA, SR8.R_E_C_N_O_ "
	 cQueryA  += " FROM "+ RetSqlName("SR8") + " SR8 ," + RetSqlName("RCM") + " RCM "
	 cQueryA  += " WHERE SR8.D_E_L_E_T_ = ' ' "
	 cQueryA  += " AND RCM.D_E_L_E_T_ = ' ' "
	 cQueryA  += " AND R8_TIPOAFA = RCM_TIPO "
	 cQueryA  += " AND RCM_CODRAI BETWEEN '00' AND '59' "
	 cQueryA  += " AND RCM_TIPOAF = '1' "	 	 
	 cQueryA  += " AND R8_XINTINC = 'S' "	 
	 cQueryA  += " AND R8_FILIAL ='" + cFilant + "' "	 
	 cQueryA  += " AND R8_XIDINC <> '                                ' "
	 cQueryA  += " AND R8_DATA    <> '        ' "
	 cQueryA  += " AND R8_XHROPER <> '        ' "
	 cQueryA  += " AND R8_XDTTRAN <> '        ' "	 
     cQueryA  += " AND R8_XHRTRAN <> '        ' "	 
     cQueryA  += " AND R8_DATA||R8_XHROPER > R8_XDTTRAN||R8_XHRTRAN "	 
	 cQueryA  += " ORDER BY SR8.R_E_C_N_O_  "

	 cQueryD  := " SELECT R8_FILIAL, R8_MAT, R8_DATAINI , R8_TIPOAFA, R8_DATA, SR8.R_E_C_N_O_ "
	 cQueryD  += " FROM "+ RetSqlName("SR8") + " SR8 ," + RetSqlName("RCM") + " RCM "
	 cQueryD  += " WHERE SR8.D_E_L_E_T_ = '*' "
	 cQueryD  += " AND RCM.D_E_L_E_T_ = ' ' "
	 cQueryD  += " AND R8_TIPOAFA = RCM_TIPO "
	 cQueryD  += " AND RCM_CODRAI BETWEEN '00' AND '59' "
	 cQueryD  += " AND RCM_TIPOAF = '1' "	 	 
	 cQueryD  += " AND R8_FILIAL ='" + cFilant + "' "	 
	 cQueryD  += " AND R8_XINTINC = 'S' " 
	 cQueryD  += " AND R8_XIDINC <> '                                ' "
	 cQueryD  += " AND R8_XINTEXC = ' ' " 
	 cQueryD  += " AND R8_XIDEXC = '                                ' "
	 cQueryD  += " AND R8_DATA = '"+cDtIntAf+"' "
	 cQueryD  += " ORDER BY SR8.R_E_C_N_O_  "

	            
	 ProcRegua(0)
	                        
Endif


// Atualização

	If Select("ASR8") > 0
		ASR8->(DbCloseArea())
	EndIf
	
	TCQUERY cQueryA NEW ALIAS "ASR8"
	
	ASR8->( dbGoTop() )
	
	ProcRegua(0)
	
 	While ASR8->(!Eof())	
    
       If lIntRot 
          ProcRegua(ASR8->(RecCount()))
    
	      IncProc("[INTEGRACAO - AFASTAMENTOS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + ASR8->R8_MAT)
	   Endif
	   
   	  	cPA6ID := U_F0600901("F0600201",ASR8->R_E_C_N_O_,"SR8",ASR8->R8_FILIAL + ASR8->R8_MAT + ASR8->R8_DATAINI + ASR8->R8_TIPOAFA ,"",CTOD(""),"UPSERT",ASR8->R8_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SR8")   
		cQueryUpd += " SET R8_XINTALT= 'S' , "
		cQueryUpd += " R8_XIDALT = '" + cPA6ID + "' , "
		cQueryUpd += " R8_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " R8_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
		cQueryUpd += " AND R8_XINTINC= 'S' "
		cQueryUpd += " AND R8_XIDINC <> '                                ' "
		cQueryUpd += " AND R8_FILIAL = '"+ ASR8->R8_FILIAL + "' "
		cQueryUpd += " AND R8_MAT = '"+ ASR8->R8_MAT + "' "
		cQueryUpd += " AND R8_DATAINI = '"+ ASR8->R8_DATAINI + "' "
		cQueryUpd += " AND R8_TIPOAFA = '"+ ASR8->R8_TIPOAFA + "' "
		cQueryUpd += " AND R8_DATA = '"+ ASR8->R8_DATA + "' "
		
		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
		      Conout ( "Exclusão de Afastamentos - Erro na atualização de integração da tabela SR8 " )
		   Endif
		Endif
	   
	   cQueryUpd := " "
	   ASR8->(dbskip())
	   
    Enddo

	ASR8->(DbCloseArea())
    cQueryUpd := " "

// inclusao
	If Select("TSR8") > 0
		TSR8->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TSR8"
	
	TSR8->( dbGoTop() )
	
 	While TSR8->(!Eof())	
    
       If lIntRot 
          ProcRegua(TSR8->(RecCount()))
    
	      IncProc("[INTEGRACAO - AFASTAMENTOS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + TSR8->R8_MAT)
	   Endif
	   
   	  	cPA6ID := U_F0600901("F0600201",TSR8->R_E_C_N_O_,"SR8",TSR8->R8_FILIAL + TSR8->R8_MAT + TSR8->R8_DATAINI + TSR8->R8_TIPOAFA,"",CTOD(""),"UPSERT",TSR8->R8_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SR8")   
		cQueryUpd += " SET R8_XINTINC= 'S' , "
		cQueryUpd += " R8_XIDINC = '" + cPA6ID + "' , "
		cQueryUpd += " R8_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " R8_XDTTRAN = '" +dtos(date())+"' "
		cQueryUpd += " WHERE D_E_L_E_T_= ' ' "
		cQueryUpd += " AND R8_XINTINC = ' ' "		
		cQueryUpd += " AND R8_XIDINC = '                                ' "
		cQueryUpd += " AND R8_FILIAL = '"+ TSR8->R8_FILIAL + "' "
		cQueryUpd += " AND R8_MAT = '"+ TSR8->R8_MAT + "' "
		cQueryUpd += " AND R8_DATAINI = '"+ TSR8->R8_DATAINI + "' "
		cQueryUpd += " AND R8_TIPOAFA = '"+ TSR8->R8_TIPOAFA + "' "
		cQueryUpd += " AND R8_DATA = '"+ TSR8->R8_DATA + "' "

		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
				Conout ( "AFASTAMENTOS - Erro na atualização de integração da tabela SR8." )
		   Endif
		Endif
	   cQueryUpd := " "
	   TSR8->(dbskip())
	   
    Enddo

	TSR8->(DbCloseArea())
    cQueryUpd := " "

   
// Exclusao 
    
	If Select("DSR8") > 0
		DSR8->(DbCloseArea())
	EndIf
	
	TCQUERY cQueryD NEW ALIAS "DSR8"
	
	DSR8->( dbGoTop() )
	
	ProcRegua(0)
	
 	While DSR8->(!Eof())	
    
       If lIntRot 
          ProcRegua(DSR8->(RecCount()))
    
	      IncProc("[INTEGRACAO - AFASTAMENTOS] -->  Emp.: " + cEmpAnt + "  Fil.: " + cFilant + "  Matricula.: " + DSR8->R8_MAT)
	   Endif
	   
   	  	cPA6ID := U_F0600901("F0600201",DSR8->R_E_C_N_O_,"SR8",DSR8->R8_FILIAL + DSR8->R8_MAT + DSR8->R8_DATAINI + DSR8->R8_TIPOAFA,"",CTOD(""),"DELETE",DSR8->R8_FILIAL)
	   		   	  	
		cQueryUpd := " UPDATE "+ RetSqlName("SR8")   
		cQueryUpd += " SET R8_XINTEXC= 'S' , "
		cQueryUpd += " R8_XIDEXC = '" + cPA6ID + "' , "
		cQueryUpd += " R8_XHRTRAN = '" +TIME()+"' , "
		cQueryUpd += " R8_XDTTRAN = '" +dtos(date())+"' "		
		cQueryUpd += " WHERE D_E_L_E_T_= '*' "
		cQueryUpd += " AND R8_XINTINC= 'S' "
		cQueryUpd += " AND R8_XIDINC <> '                                ' "
		cQueryUpd += " AND R8_XINTEXC = ' ' "
		cQueryUpd += " AND R8_XIDEXC = '                                ' "				
		cQueryUpd += " AND R8_FILIAL = '"+ DSR8->R8_FILIAL + "' "
		cQueryUpd += " AND R8_MAT = '"+ DSR8->R8_MAT + "' "
		cQueryUpd += " AND R8_DATAINI = '"+ DSR8->R8_DATAINI + "' "		
		cQueryUpd += " AND R8_TIPOAFA = '"+ DSR8->R8_TIPOAFA + "' "
		cQueryUpd += " AND R8_DATA = '"+ DSR8->R8_DATA + "' "

		nExecSql := TCSQLEXEC(cQueryUpd) 

		If nExecSql > 0
		   If !lIntRot
		      Conout ( "AFASTAMENTOS - Erro na atualização de integração da tabela SR8 " )
		   Endif
		Endif
		
	   cQueryUpd := " "
	   DSR8->(dbskip())
	   
    Enddo

	DSR8->(DbCloseArea())
    cQueryUpd := " "
    
	restarea(aAreaAnt)
		
		
Return .T.  
