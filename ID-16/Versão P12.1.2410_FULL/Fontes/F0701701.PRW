#include 'protheus.ch'
/*{Protheus.doc} F0701701
Realiza o Upsert de um Registro TUSS
@author izac.ciszevski
@since 19/01/2017  
@param oTuss, object, Objeto TUSS fornecido pelo WebService W0701701
@Project MAN0000007423041_EF_014
*/
User Function F0701701(oTuss)
    Local cRetorno := ""
    Local aCampos  := {}
    Local cChave   := ""

    aCampos := {; 
                    {"P15_FILIAL", oTuss:cFilReg        },;
                    {"P15_COD"   , oTuss:cCOD           },;
                    {"P15_DESCR" , oTuss:cDescr         },;
                    {"P15_APRES" , oTuss:cAPRES         },;
                    {"P15_ANVISA", oTuss:cANVISA        },;                    
                    {"P15_REFER" , oTuss:cREFER         },;
                    {"P15_DTVIN" , CToD(oTuss:cDTVIN)   },;
                    {"P15_DTVFIM", CToD(oTuss:cDTVFIM)  },;
                    {"P15_CLRISC", oTuss:cCLRISC        },;
                    {"P15_TERMIN", oTuss:cTERMIN        },;
                    {"P15_FABRIC", oTuss:cFABRIC        },;
                    {"P15_DTIMPL", CToD(oTuss:cDTIMPL)  },;
                    {"P15_ID"    , U_GetIntegID()       }; //-- função pra pegar o ID
                }
                
    cRetorno := U_F0700001("P15", {2}, "F0701601", "MASTER", aCampos)//-- chamar função de log

    aCampos := ASize(aCampos, 0)
    aCampos := Nil

Return cRetorno