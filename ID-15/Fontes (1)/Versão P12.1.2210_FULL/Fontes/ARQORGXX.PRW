#INCLUDE 'PROTHEUS.CH'
#INCLUDE  'TOPCONN.CH'
#INCLUDE   'RWMAKE.CH'
#INCLUDE   'COLORS.CH'
#INCLUDE   'FILEIO.CH'
#INCLUDE     'FONT.CH'

#DEFINE EOL CHR(13) + CHR(10)

//+-------------------------+-------------------------------+------------+
//| Programa : arqorgxx.prw | Autor : Gustavo Thees Castro  | 16/04/2020 |
//+-------------------------+-------------------------------+------------+
//| Descrição: Relatório Arquitetura Organizacional. Completa / Parcial. |
//+----------------------------------------------------------------------+
//| Uso      : SIGARSP                                                   |
//+----------------------------------------------------------------------+

user function arqorgxx()

// ------------------------------------------------------------------
// 	[ Declaração de Variáveis ]
// ------------------------------------------------------------------
	SetPrvt('oDlg01','oDlg02','oPanel','oBmp01')
	SetPrvt('oGrp01','oGrp02','oGrp03','oGrp04','oGrp05')
	SetPrvt('oSay01','oSay02','oSay03','oSay04','oSay05','oSay06','oSay07','oSay08','oSay09','oSay10',;
		    'oSay11','oSay12','oSay13','oSay14','oSay15','oSay16','oSay17','oSay18','oSay19','oSay20',;
		    'oSay21','oSay22','oSay23','oSay24','oSay25','oSay26','oSay27','oSay28','oSay29','oSay30',;
		    'oSay31','oSay32','oSay33','oSay34','oSay35','oSay36','oSay37','oSay38','oSay39','oSay40' )
	SetPrvt('oGet01','oGet02','oGet03','oGet04','oGet05','oGet06','oGet07','oGet08','oGet09','oGet10',;
            'oGet11','oGet12','oGet13','oGet14','oGet15','oGet16','oGet17','oGet18','oGet19','oGet20',;
            'oGet21','oGet22','oGet23','oGet24','oGet25','oGet26','oGet27','oGet28','oGet29','oGet30',;
            'oGet31','oGet32','oGet33','oGet34','oGet35','oGet36','oGet37','oGet38','oGet39','oGet40' )
	SetPrvt('oBtn01','oBtn02','oBtn03','oBtn04','oBtn05','oBtn06','oCBox1','oCBox2',)
// --------------------------
    private cEmpCod     := cEmpAnt
// --------------------------
    private cRefFilCod  :=       space( tamsx3( 'RA_FILIAL'  )[1] )
    private cRefFilNom  :=       space( 040 )
    private cRefCICCod  :=       space( tamsx3( 'RA_CIC'     )[1] )
    private cRefMatCod  :=       space( tamsx3( 'RA_MAT'     )[1] )
    private cRefMatNom  :=       space( tamsx3( 'RA_NOMECMP' )[1] )
    private dRefMatAdm  := ctod( space( 010 ) )
    private dRefMatDem  := ctod( space( 010 ) )
    private cRefPosCod  :=       space( tamsx3( 'RA_POSTO'   )[1] )
    private cRefPosNom  :=       space( tamsx3( 'RD4_DESC'   )[1] )
// --------------------------
    private aRefEstTip  := { 'Completa' , 'Parcial' }
    private cRefEstTip  := aRefEstTip[1]
// --------------------------
    private cPath       := gettemppath()
    private cArq        := 'ARQORGXX_' + dtos( ddatabase ) + '_' + strtran( time() , ':' , '' ) + '.csv'
    private cArqDes     := space( 250 )
    private cRefArqDes  := cPath + cArq
// --------------------------
	private cVisao0     := supergetmv( 'MV_XVISAO' , .F. , '000002' )
	private cVisao1     := posicione( 'RDK' , 1 , xfilial( 'RDK' ) + cVisao0 , 'RDK_DESC' )
	private nHdl1       := 0
	private nBigKey     := 0
	private cIni        := ''
	private cFim        := ''
	private aCompleta   := {}
	private aParcial0   := {}
	private aParcial1   := {}
    private aParcialPes := {}
// ------------------------------------------------------------------
// [ Definição do Dialog e todos os seus componentes ]
// ------------------------------------------------------------------
	oDlg01 :=    MSDialog():New( 088,232,470,915,'Relatório de Arquitetura Organizacional',,,.F.,,,,,,.T.,,,.T. )
	oPanel :=      TPanel():New( 000,000,'',oDlg01,,.F.,.F.,,,344,250,.T.,.F. )
// ------------------------------------------------------------------
	oGrp01 :=      TGroup():New( 004,004,066,340,'Arquitetura Organizacional',oPanel,CLR_BLUE,CLR_WHITE,.T.,.F. )
// --------------------------
	oSay01 :=        TSay():New( 009,155,{||replicate( '-' , 80 )                                             },oGrp01,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,156,008)
	oSay02 :=        TSay():New( 018,155,{||'Esta rotina vai gerar o Relatório de Arquitetura Organizacional' },oGrp01,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,156,008)
	oSay03 :=        TSay():New( 027,155,{||'Completa ou Parcial, de acordo com os parâmetros informados.'    },oGrp01,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,156,008)
	oSay04 :=        TSay():New( 036,155,{||replicate( '-' , 80 )                                             },oGrp01,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,156,008)
// --------------------------
	if file( '.\system\lgrl01.bmp' )
	    oBmp01 := TBitmap():New( 012,008,120,052,,'lgrl01.bmp',.F.,oGrp01,,,.F.,.T.,,'',.T.,,.T.,,.F. )
	endif
// ------------------------------------------------------------------
	oGrp02 :=      TGroup():New( 068,004,144,340,'Parâmetros / Referência',oPanel,CLR_BLUE,CLR_WHITE,.T.,.F. )
// --------------------------
	oSay05 :=        TSay():New( 078,009,{||'Estrutura: ' },oGrp02,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,040,008)
	oSay06 :=        TSay():New( 091,009,{||'Filial: '    },oGrp02,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,040,008)
	oSay07 :=        TSay():New( 091,180,{||'CIC: '       },oGrp02,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,040,008)
	oSay08 :=        TSay():New( 104,009,{||'Matrícula: ' },oGrp02,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,040,008)
	oSay09 :=        TSay():New( 104,180,{||'Admissão: '  },oGrp02,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,040,008)
	oSay10 :=        TSay():New( 104,255,{||'Demissão: '  },oGrp02,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,040,008)
	oSay11 :=        TSay():New( 117,009,{||'Posto: '     },oGrp02,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,040,008)
	oSay12 :=        TSay():New( 130,009,{||'Arquivo: '   },oGrp02,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,040,008)
// --------------------------
    oCBox1 :=   TComboBox():New( 076,035,{|u|if(pcount()>0,cRefEstTip:=u,cRefEstTip)},aRefEstTip,040,010,oGrp02,,{|| fCombo() },,CLR_BLACK,CLR_WHITE,.T.,,'',,,,,,,'cRefEstTip' )
// --------------------------
	oBtn01 :=     TButton():New( 076,075,'Referência',oGrp02,{|| fRefer() },050,012,,,,.T.,,'',,{|| cRefEstTip == 'Parcial' },,.F. )
// --------------------------
	oGet01 :=        TGet():New( 089,035,{|u|if(pcount()>0,cRefFilCod:=u,cRefFilCod)},oGrp02,040,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','cRefFilCod',,,,.F.)
	oGet02 :=        TGet():New( 089,075,{|u|if(pcount()>0,cRefFilNom:=u,cRefFilNom)},oGrp02,100,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','cRefFilNom',,,,.F.)
	oGet03 :=        TGet():New( 089,210,{|u|if(pcount()>0,cRefCICCod:=u,cRefCICCod)},oGrp02,115,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','cRefCICCod',,,,.F.)
	oGet04 :=        TGet():New( 102,035,{|u|if(pcount()>0,cRefMatCod:=u,cRefMatCod)},oGrp02,040,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','cRefMatCod',,,,.F.)
	oGet05 :=        TGet():New( 102,075,{|u|if(pcount()>0,cRefMatNom:=u,cRefMatNom)},oGrp02,100,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','cRefMatNom',,,,.F.)
	oGet06 :=        TGet():New( 102,210,{|u|if(pcount()>0,dRefMatAdm:=u,dRefMatAdm)},oGrp02,040,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','dRefMatAdm',,,,.F.)
	oGet07 :=        TGet():New( 102,285,{|u|if(pcount()>0,dRefMatDem:=u,dRefMatDem)},oGrp02,040,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','dRefMatDem',,,,.F.)
	oGet08 :=        TGet():New( 115,035,{|u|if(pcount()>0,cRefPosCod:=u,cRefPosCod)},oGrp02,040,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','cRefPosCod',,,,.F.)
	oGet09 :=        TGet():New( 115,075,{|u|if(pcount()>0,cRefPosNom:=u,cRefPosNom)},oGrp02,100,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','cRefPosNom',,,,.F.)
	oGet10 :=        TGet():New( 128,035,{|u|if(pcount()>0,cRefArqDes:=u,cRefArqDes)},oGrp02,250,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.T.},.F.,.F.,,.F.,.F.,'','cRefArqDes',,,,.F.)
// --------------------------
    oGet06:SetContentAlign( -1 ) // data de admissão alinhada a esquerda
    oGet07:SetContentAlign( -1 ) // data de demissão alinhada a esquerda
// --------------------------
	oBtn02 :=     TButton():New( 126,287,'Selecionar',oGrp02,{|| fSelArq() },037,012,,,,.T.,,'',,,,.F. )
// ------------------------------------------------------------------
	oGrp04 :=      TGroup():New( 149,004,188,340,'Status do Processamento',oPanel,CLR_BLUE,CLR_WHITE,.T.,.F. )
// --------------------------
	oSay13 :=        TSay():New( 159,009,{||'Início:'  },oGrp04,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,022,008)
	oSay14 :=        TSay():New( 172,009,{||'Término:' },oGrp04,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,022,008)
// --------------------------
	oGet11 :=        TGet():New( 157,031,{|u|if(pcount()>0,cIni:=u,cIni)},oGrp04,075,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','cIni'    ,,)
	oGet12 :=        TGet():New( 170,031,{|u|if(pcount()>0,cFim:=u,cFim)},oGrp04,075,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.F.},.F.,.F.,,.F.,.F.,'','cFim'    ,,)
// --------------------------
	oBtn03 :=     TButton():New( 168,150,'Ok'       ,oGrp02,{||iif(fValSel(),oDlg01:End(),.F.) },037,012,,,,.T.,,'',,,,.F. )
	oBtn04 :=     TButton():New( 168,210,'Cancelar' ,oGrp04,{||              oDlg01:End()      },037,012,,,,.T.,,'',,,,.F. )
// ------------------------------------------------------------------
	oDlg01:Activate( , , , .T. )
return

// ------------------------------------------------------------------
static function fCombo()
    if ( alltrim( cRefEstTip ) == 'Completa' )
        cRefFilCod :=       space( tamsx3( 'RA_FILIAL'  )[1] )
        cRefFilNom :=       space( 040 )
        cRefCICCod :=       space( tamsx3( 'RA_CIC'     )[1] )
        cRefMatCod :=       space( tamsx3( 'RA_MAT'     )[1] )
        cRefMatNom :=       space( tamsx3( 'RA_NOMECMP' )[1] )
        dRefMatAdm := ctod( space( 010 ) )
        dRefMatDem := ctod( space( 010 ) )
        cRefPosCod :=       space( tamsx3( 'RA_POSTO'   )[1] )
        cRefPosNom :=       space( tamsx3( 'RD4_DESC'   )[1] )
    endif
return
// ------------------------------------------------------------------
static function fRefer()
// --------------------------
	local lRet := .F.
// --------------------------
    cPesFilCod := space( 09 ) // space( tamsx3( 'RA_FILIAL'  )[1] )
    cPesMatCod := space( 09 ) // space( tamsx3( 'RA_MAT'     )[1] )
    cPesPosCod := space( 09 ) // space( tamsx3( 'RA_POSTO'   )[1] )
// ------------------------------------------------------------------
	oDlg02 := MSDialog():New( 088,232,250,445,'Pesquisar Referência',,,.F.,,,,,,.T.,,,.T. )
	oGrp05 :=   TGroup():New( 005,005,075,105,'Referência',oDlg02,CLR_BLACK,CLR_WHITE,.T.,.F. )
// ------------------------------------------------------------------
	oSay31 := TSay():New( 020,010,{||'Filial'     },oGrp05,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
	oSay32 := TSay():New( 033,010,{||'Matrícula'  },oGrp05,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
	oSay33 := TSay():New( 046,010,{||'Cod. Posto' },oGrp05,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
// ------------------------------------------------------------------
	oGet30 := TGet():New( 018,055,{|u|If(PCount()>0,cPesFilCod:=u,cPesFilCod)},oGrp05,040,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.T.},.F.,.F.,,.F.,.F.,'FSWFIL','cPesFilCod',,)
	oGet31 := TGet():New( 031,055,{|u|If(PCount()>0,cPesMatCod:=u,cPesMatCod)},oGrp05,040,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.T.},.F.,.F.,,.F.,.F.,'SRA'   ,'cPesMatCod',,)
	oGet32 := TGet():New( 044,055,{|u|If(PCount()>0,cPesPosCod:=u,cPesPosCod)},oGrp05,040,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,{||.T.},.F.,.F.,,.F.,.F.,'RCL'   ,'cPesPosCod',,)
// ------------------------------------------------------------------
	oBtn05 := TButton():New( 057,010,'&OK'      ,oGrp05,{||iif(fPesquisa(),oDlg02:End(),.F.) },040,012,,,,.T.,,'',,,,.F. )
	oBtn06 := TButton():New( 057,055,'&Cancelar',oGrp05,{||                oDlg02:End()      },040,012,,,,.T.,,'',,,,.F. )
// --------------------------	
    oDlg02:Activate( , , , .T. )
// --------------------------
return
// ------------------------------------------------------------------
static function fPesquisa()
// --------------------------
    local cQry0a     := ''
    local cQry0b     := ''
// --------------------------
    local cAuxFilCod := iif( empty( alltrim( cPesFilCod )) , xfilial( 'SRA' ) , cPesFilCod                       )
    local cAuxMatCod :=                      cPesMatCod
    local cAuxPosCod := iif( empty( alltrim( cPesMatCod )) , cPesPosCod       , space( tamsx3( 'RA_POSTO' )[1] ) )
// --------------------------
    local lRet       := ( !empty( alltrim( cAuxMatCod )) .OR. ;
                          !empty( alltrim( cAuxPosCod ))      )
// --------------------------
    local cStatus    := ''
// --------------------------
    aParcialPes      := {}
// --------------------------
    if lRet
        cQry0a := "    SELECT   COUNT(*) TOTREG "
        cQry0a += "      FROM " + retsqlname( 'RD4' ) + " RD4 "
        cQry0a += " LEFT JOIN " + retsqlname( 'SRA' ) + " SRA "
        cQry0a += "        ON   SRA.D_E_L_E_T_ <> '*' "
        cQry0a += "       AND   SRA.RA_FILIAL   = RD4.RD4_FILIDE "
        cQry0a += "       AND   SRA.RA_POSTO    = RD4.RD4_CODIDE "
        cQry0a += "       AND   SRA.RA_ADMISSA <= '" + dtos( ddatabase )     + "' "
        cQry0a += "       AND ( SRA.RA_DEMISSA >= '" + dtos( ddatabase )     + "' "
        cQry0a += "        OR   SRA.RA_DEMISSA  = ' ' ) "
        cQry0a += "     WHERE   RD4.D_E_L_E_T_ <> '*' "
        cQry0a += "       AND   RD4.RD4_CHAVE  <> ' ' "
        cQry0a += "       AND   RD4.RD4_STATUS <> '2' "
        cQry0a += "       AND   RD4.RD4_CODIGO  = '" + cVisao0               + "' "
        cQry0a += "       AND   RD4.RD4_EMPIDE  = '" + cEmpCod               + "' "
        cQry0a += "       AND   RD4.RD4_FILIDE  = '" + cAuxFilCod            + "' "
        if ( !empty( alltrim( cAuxPosCod )))    
            cQry0a += "   AND   RD4.RD4_CODIDE  = '" + alltrim( cAuxPosCod ) + "' "
        endif
        if ( !empty( alltrim( cAuxMatCod )))    
            cQry0a += "   AND   SRA.RA_MAT      = '" + alltrim( cAuxMatCod ) + "' "
        endif
        cQry0a += "  ORDER BY   RD4_CHAVE , RA_ADMISSA "
// --------------------------           
        if select( 'QRY0a' ) > 0
            dbselectarea( 'QRY0a' )
            dbclosearea()
	    endif
//	    memowrite( 'C:\arqorg00_cQry0a.sql' , cQry0a )
	    tcquery cQry0a alias 'QRY0a' new
// --------------------------
	    lRet := QRY0a->TOTREG >= 1
    endif
// --------------------------
    if lRet
        cQry0b := "    SELECT   RD4.RD4_CHAVE  , "
        cQry0b += "             RD4.RD4_FILIAL , "
        cQry0b += "             RD4.RD4_CODIGO , "
        cQry0b += "             RD4.RD4_ITEM   , "
        cQry0b += "             RD4.RD4_EMPIDE , "
        cQry0b += "             RD4.RD4_FILIDE , "
        cQry0b += "             RD4.RD4_CODIDE , "
        cQry0b += "             RD4.RD4_DESC   , "
        cQry0b += "             RD4.RD4_TREE   , "
        cQry0b += "             RD4.RD4_DATA   , "
        cQry0b += "             RD4.RD4_STATUS , "
        cQry0b += "             SRA.RA_FILIAL  , "
        cQry0b += "             SRA.RA_MAT     , "
        cQry0b += "             SRA.RA_NOME    , "
        cQry0b += "             SRA.RA_NOMECMP , "
        cQry0b += "             SRA.RA_CIC     , "
        cQry0b += "             SRA.RA_ADMISSA , "
        cQry0b += "             SRA.RA_DEMISSA , "
        cQry0b += "             SRA.RA_DEPTO   , "
        cQry0b += "             SRA.RA_CC        "
// --------------------------
        cQry0b += " ,           SRA.RA_SITFOLH   "
// --------------------------
        cQry0b += "      FROM " + retsqlname( 'RD4' ) + " RD4 "
        cQry0b += " LEFT JOIN " + retsqlname( 'SRA' ) + " SRA "
        cQry0b += "        ON   SRA.D_E_L_E_T_ <> '*' "
        cQry0b += "       AND   SRA.RA_FILIAL   = RD4.RD4_FILIDE "
        cQry0b += "       AND   SRA.RA_POSTO    = RD4.RD4_CODIDE "
        cQry0b += "       AND   SRA.RA_ADMISSA <= '" + dtos( ddatabase )     + "' "
        cQry0b += "       AND ( SRA.RA_DEMISSA >= '" + dtos( ddatabase )     + "' "
        cQry0b += "        OR   SRA.RA_DEMISSA  = ' ' ) "
        cQry0b += "     WHERE   RD4.D_E_L_E_T_ <> '*' "
        cQry0b += "       AND   RD4.RD4_CHAVE  <> ' ' "
        cQry0b += "       AND   RD4.RD4_STATUS <> '2' "
        cQry0b += "       AND   RD4.RD4_CODIGO  = '" + cVisao0               + "' "
        cQry0b += "       AND   RD4.RD4_EMPIDE  = '" + cEmpCod               + "' "
        cQry0b += "       AND   RD4.RD4_FILIDE  = '" + cAuxFilCod            + "' "
        if ( !empty( alltrim( cAuxPosCod )))    
            cQry0b += "   AND   RD4.RD4_CODIDE  = '" + alltrim( cAuxPosCod ) + "' "
        endif
        if ( !empty( alltrim( cAuxMatCod )))    
            cQry0b += "   AND   SRA.RA_MAT      = '" + alltrim( cAuxMatCod ) + "' "
        endif
        cQry0b += "  ORDER BY   RD4_CHAVE , RA_ADMISSA "
// --------------------------
        if select( 'QRY0b' ) > 0
	        dbselectarea( 'QRY0b' )
            dbclosearea()
	    endif
//	    memowrite( 'C:\arqorg00_cQry0b.sql' , cQry0b )
	    tcquery cQry0b alias 'QRY0b' new
// --------------------------
	    cRefFilCod :=             QRY0b->RD4_FILIDE
	    cRefFilNom := fwfilname ( cEmpCod , cRefFilCod )
	    cRefCICCod :=             QRY0b->RA_CIC
        cRefMatCod :=             QRY0b->RA_MAT
        cRefMatNom :=             QRY0b->RA_NOMECMP
        dRefMatAdm :=       stod( QRY0b->RA_ADMISSA )
        dRefMatDem :=       stod( QRY0b->RA_DEMISSA )
        cRefPosCod :=             QRY0b->RD4_CODIDE
        cRefPosNom :=             QRY0b->RD4_DESC
// -------------------------------
        do while QRY0b->( ! eof() )

// -------------------------------
//            aadd( aParcialPes , { alltrim( QRY0b->RD4_FILIDE ) , ;
//                                  alltrim( QRY0b->RD4_CODIDE ) , ;
//                                  alltrim( QRY0b->RD4_DESC   ) , ;
//                                  alltrim( QRY0b->RA_MAT     ) , ;
//                                  alltrim( QRY0b->RA_NOMECMP ) , ;
//                                  alltrim( QRY0b->RD4_ITEM   ) , ;
//                                  alltrim( QRY0b->RD4_TREE   ) , ;
//                                  alltrim( QRY0b->RD4_CHAVE  ) } )
// -------------------------------
            cStatus := posicione( 'SX5' , 1 , xfilial( 'SX5' ) + '31' + QRY0b->RA_SITFOLH , 'X5_DESCRI' )
            aadd( aParcialPes , { alltrim( QRY0b->RD4_FILIDE ) , ;
                                  alltrim( QRY0b->RD4_CODIDE ) , ;
                                  alltrim( QRY0b->RD4_DESC   ) , ;
                                  alltrim( QRY0b->RA_MAT     ) , ;
                                  alltrim( QRY0b->RA_NOMECMP ) , ;
                                  alltrim( QRY0b->RD4_ITEM   ) , ;
                                  alltrim( QRY0b->RD4_TREE   ) , ;
                                  alltrim( QRY0b->RD4_CHAVE  ) , ;
                                transForm( QRY0b->RA_CIC , '@R 999.999.999-99'     ) , ;
                                           QRY0b->RA_SITFOLH   , ;
                                           cStatus             } )
// -------------------------------

            QRY0b->( dbskip() )
        enddo
// -------------------------------
    else
        msgalert( 'Nenhum registro válido encontrado com essa seleção!' , 'Atenção!' )
    endif
// --------------------------
return lRet

// ------------------------------------------------------------------
//static function fSelArq()
//	cRefArqDes := upper( cGetFile( 'Arquivos CSV |*.CSV' , 'Arquivo Destino' , , , .F. , , ))
//	if !empty( cRefArqDes )
//	    cRefArqDes := alltrim( upper( cRefArqDes ))
//	    if right( cRefArqDes , 4 ) <> '.CSV'
//	        cRefArqDes := cRefArqDes + '.CSV'
//	    endif
//		cRefArqDes := cRefArqDes + space( 250 - len( cRefArqDes ))
//	else
//		alert( 'Nenhum arquivo selecionado!' )
//	endif
//return
// ------------------------------------------------------------------
static function fSelArq()
	cArqDes := upper( cGetFile( 'Arquivos CSV |*.CSV' , 'Arquivo Destino' , , , .F. , , ))
	if !empty( alltrim( cArqDes ))
	    cRefArqDes := cArqDes
	endif
	if !empty( cRefArqDes )
	    cRefArqDes := alltrim( upper( cRefArqDes ))
	    if right( cRefArqDes , 4 ) <> '.CSV'
	        cRefArqDes := cRefArqDes + '.CSV'
	    endif
		cRefArqDes := cRefArqDes + space( 250 - len( cRefArqDes ))
	else
		alert( 'Nenhum arquivo selecionado!' )
	endif
return
// ------------------------------------------------------------------
static function fValSel()
// --------------------------
    local lRet  := .T.
// --------------------------
    if lRet
        if ( alltrim( cRefEstTip ) == 'Parcial' )
            if ( empty( alltrim( cRefFilCod )) .OR. ;
                 empty( alltrim( cRefPosCod ))      )
                msgalert( 'Referência não informada!' , 'Atenção!' )
		        lRet := .F.
            endif
        endif
    endif
// --------------------------
    if lRet
        if empty( alltrim( cRefArqDes ))
            msgalert( 'Nenhum arquivo informado!' , 'Atenção!' )
		    lRet := .F.
        else
    	    cRefArqDes := alltrim( upper( cRefArqDes ))
	        if right( cRefArqDes , 4 ) <> '.CSV'
	            cRefArqDes := cRefArqDes + '.CSV'
	        endif
		    cRefArqDes := cRefArqDes + space( 250 - len( cRefArqDes ))
        endif
    endif
// --------------------------
	if lRet
	    if file( cRefArqDes )
		    lRet :=  MSGNOYES( 'Arquivo já existe! Sobrepor? ( S / N )' , 'ATENÇÃO!')
	    endif
	endif
// --------------------------
	if lRet
		nHdl1 := fCreate( cRefArqDes )
		if nHdl1 == -1
			MsgAlert( 'Arquivo ' + cRefArqDes + ' não pode ser criado!' , 'Atenção!' )
			fClose( nHdl1 )
			lRet := .F.
		endif
		fClose( nHdl1 )
	endif
// -[ confirma processamento ]---------------------------------------
	if lRet
		if  MSGNOYES( 'Confirma o processamento? ( S / N )' , 'ATENÇÃO!')
			cIni  := time() + ' - ' + dtoc(date())
			oGet11:refresh()
// ----------------------------------------------
            if ( alltrim( cRefEstTip ) == 'Completa' )
			    Processa(     {|| lRet := arqorg01() } , 'Aguarde...' , 'Analisando Arquitetura Organizacional - Completa...' , .F. )
                if lRet
                    Processa( {|| arqorg02()         } , 'Aguarde...' , 'Gerando Arquitetura Organizacional - Completa...'    , .F. )
                endif
			elseif ( alltrim( cRefEstTip ) == 'Parcial'  )
			    Processa(     {|| lRet := arqorg03() } , 'Aguarde...' , 'Analisando Arquitetura Organizacional - Parcial...'  , .F. )
    			if lRet
                    Processa( {|| arqorg10()         } , 'Aguarde...' , 'Gerando Arquitetura Organizacional - Parcial...'     , .F. )
                endif
            endif
// ----------------------------------------------
			cFim  := time() + ' - ' + dtoc(date())
			oGet12:refresh()
			fClose( nHdl1 )
            if lRet
			    MSGALERT( 'Processamento concluído com sucesso!' , 'SUCESSO' )
                Close( oDlg01 )
			    if  MSGNOYES( 'Deseja abrir o arquivo? ( S / N )' , 'ATENÇÃO!' )
    				nRet := ShellExecute( 'Open' , cRefArqDes , '' , '' , 1 )
				    if nRet <= 32
    					MsgStop( 'Não foi possível abrir o arquivo excel!!! ' )
	    			endif
	    		endif
			endif
// -------------------------------			
		else
			MsgAlert( 'Processamento não confirmado!' , 'Atenção!' )
			fClose( nHdl1 )
			lRet := .F.
		endif
	endif
// -------------------------------
return( lRet )

// ------------------------------------------------------------------
// [ Analisando Arquitetura Organizacional - Completa ]
// ------------------------------------------------------------------
static function arqorg01
// -------------------------------
    local cQry1a := ''
    local cQry1b := ''
    local lRet   := .F.
    local cAdmis := ''
    local cDemis := ''
// -------------------------------
    cQry1a := "    SELECT COUNT(*) TOTREG "
    cQry1a += "      FROM " + retsqlname( 'RD4' ) + " RD4 "
    cQry1a += " LEFT JOIN " + retsqlname( 'SRA' ) + " SRA "
    cQry1a += "        ON   SRA.D_E_L_E_T_ <> '*' "
    cQry1a += "       AND   SRA.RA_FILIAL   = RD4.RD4_FILIDE "
    cQry1a += "       AND   SRA.RA_POSTO    = RD4.RD4_CODIDE "
    cQry1a += "       AND   SRA.RA_ADMISSA <= '" + dtos( ddatabase ) + "' "
    cQry1a += "       AND ( SRA.RA_DEMISSA >= '" + dtos( ddatabase ) + "' "
    cQry1a += "        OR   SRA.RA_DEMISSA  = ' ' ) "
    cQry1a += " LEFT JOIN " + retsqlname( 'SQB' ) + " SQB  "
    cQry1a += "        ON SQB.D_E_L_E_T_ <> '*' "
    cQry1a += "       AND SQB.QB_FILIAL   = SRA.RA_FILIAL "
    cQry1a += "       AND SQB.QB_DEPTO    = SRA.RA_DEPTO  "
    cQry1a += "     WHERE RD4.D_E_L_E_T_ <> '*' "
    cQry1a += "       AND RD4.RD4_CHAVE  <> ' ' "
    cQry1a += "       AND RD4.RD4_STATUS <> '2' "
    cQry1a += "       AND RD4.RD4_CODIGO  = '" + cVisao0 + "' "
    cQry1a += "  ORDER BY RD4_CHAVE , RA_MAT "
    cQry1a := changequery( cQry1a )
// -------------------------------
    if select( 'QRY1a' ) > 0
		dbselectarea( 'QRY1a' )
		dbclosearea()
	endif
//	memowrite( 'C:\arqorg00_cQry1a.sql' , cQry1a )
	tcquery cQry1a alias 'QRY1a' new
// -------------------------------
	if QRY1a->TOTREG > 0
	    lRet := .T.
	    procregua( QRY1a->TOTREG )	
// -------------------------------
        cQry1b := "    SELECT RD4.RD4_CHAVE  , " 
        cQry1b += "           RD4.RD4_FILIAL , "
        cQry1b += "           RD4.RD4_CODIGO , "
        cQry1b += "           RD4.RD4_ITEM   , "
        cQry1b += "           RD4.RD4_EMPIDE , "
        cQry1b += "           RD4.RD4_FILIDE , "
        cQry1b += "           RD4.RD4_CODIDE , "
        cQry1b += "           RD4.RD4_DESC   , "
        cQry1b += "           RD4.RD4_TREE   , "
        cQry1b += "           RD4.RD4_DATA   , "
        cQry1b += "           RD4.RD4_STATUS , "
        cQry1b += "           SRA.RA_FILIAL  , "
        cQry1b += "           SRA.RA_MAT     , "
        cQry1b += "           SRA.RA_NOME    , "
        cQry1b += "           SRA.RA_NOMECMP , "
        cQry1b += "           SRA.RA_ADMISSA , "
        cQry1b += "           SRA.RA_DEMISSA , "
        cQry1b += "           SRA.RA_DEPTO   , "
        cQry1b += "           SRA.RA_CC      , "
        cQry1b += "           SQB.QB_FILIAL  , "
        cQry1b += "           SQB.QB_DEPTO   , "
        cQry1b += "           SQB.QB_DESCRIC , "
        cQry1b += "           SQB.QB_CC        "
        cQry1b += "      FROM " + retsqlname( 'RD4' ) + " RD4 "
        cQry1b += " LEFT JOIN " + retsqlname( 'SRA' ) + " SRA "
        cQry1b += "        ON   SRA.D_E_L_E_T_ <> '*' "
        cQry1b += "       AND   SRA.RA_FILIAL   = RD4.RD4_FILIDE "
        cQry1b += "       AND   SRA.RA_POSTO    = RD4.RD4_CODIDE "
        cQry1b += "       AND   SRA.RA_ADMISSA <= '" + dtos( ddatabase ) + "' "
        cQry1b += "       AND ( SRA.RA_DEMISSA >= '" + dtos( ddatabase ) + "' "
        cQry1b += "        OR   SRA.RA_DEMISSA  = ' ' ) "
        cQry1b += " LEFT JOIN " + retsqlname( 'SQB' ) + " SQB  "
        cQry1b += "        ON SQB.D_E_L_E_T_ <> '*' "
        cQry1b += "       AND SQB.QB_FILIAL   = SRA.RA_FILIAL "
        cQry1b += "       AND SQB.QB_DEPTO    = SRA.RA_DEPTO  "
        cQry1b += "     WHERE RD4.D_E_L_E_T_ <> '*' "
        cQry1b += "       AND RD4.RD4_CHAVE  <> ' ' "
        cQry1b += "       AND RD4.RD4_STATUS <> '2' "
        cQry1b += "       AND RD4.RD4_CODIGO  = '" + cVisao0 + "' "
        cQry1b += "  ORDER BY RD4_CHAVE , RA_MAT "
        cQry1b := changequery( cQry1b )
// -------------------------------
        if select( 'QRY1b' ) > 0
		    dbselectarea( 'QRY1b' )
		    dbclosearea()
	    endif
//	    memowrite( 'C:\arqorg00_cQry1b.sql' , cQry1b )
	    tcquery cQry1b alias 'QRY1b' new
// -------------------------------
	    do while QRY1b->( ! eof() )
		    incproc()
// ---------------------
	        if ( len( alltrim( QRY1b->RD4_CHAVE ) ) > nBigKey )
	            nBigKey := len( alltrim( QRY1b->RD4_CHAVE ))
	        endif
// ---------------------
	        if empty( alltrim( QRY1b->RA_ADMISSA ))
	            cAdmis := ' '
	        else
	            cAdmis := dtoc( stod( QRY1b->RA_ADMISSA ))
	        endif
// ---------------------
	        if empty( alltrim( QRY1b->RA_DEMISSA ))
	            cDemis := ' '
	        else
	            cDemis := dtoc( stod( QRY1b->RA_DEMISSA ))
	        endif
// ---------------------
            aadd( aCompleta , { QRY1b->RD4_CHAVE  , ;
                                QRY1b->RD4_CODIDE , ;
                                QRY1b->RD4_DESC   , ;
                                QRY1b->RD4_FILIDE , ;
                                QRY1b->RA_MAT     , ;
                                QRY1b->RA_NOMECMP , ;
                                cAdmis            , ;
                                cDemis            , ;
                                QRY1b->RA_DEPTO   , ;
                                QRY1b->QB_DESCRIC , ;
                                QRY1b->QB_CC      } )
            QRY1b->( dbskip() )
        enddo
	else
        msgalert( 'Nenhum registro encontrado!' + EOL + ;
                  'Visão ' + cVisao0 + ' - ' + cVisao1 , 'Atenção!' )
	endif
// -------------------------------
return lRet

// ------------------------------------------------------------------
// [ Gerando Arquitetura Organizacional - Completa ]
// ------------------------------------------------------------------
static function arqorg02
// -------------------------------
    local nTam := 0
    local cKey := ''
    local cAux := ''
    local iX   := 0
    local iY   := 0
// -------------------------------
	nHdl1  := fopen( cRefArqDes , 1 )
// -------------------------------
//	fwrite( nHdl1 , 'Relatório de Arquitetura Organizacional - Completa'                              + EOL )
//	fwrite( nHdl1 , 'Data Base: ' + dtoc( ddatabase )                                                 + EOL )
//	fwrite( nHdl1 , 'Visão : '    + alltrim( cVisao0 ) + ' - ' + alltrim( cVisao1 )                   + EOL )
//	fwrite( nHdl1 , ' '                                                                               + EOL )
//	fwrite( nHdl1 , 'Nível' + replicate( ';' , ( nBigKey / 3 ) ) + ;
//	                'Posto;Descrição;Filial;Matrícula;Nome;Admissão;Demissão;Cód.Depto;Desc.Depto;CC' + EOL )
// -------------------------------
//	fwrite( nHdl1 , 'Relatório de Arquitetura Organizacional - Completa'                              + EOL )
//	fwrite( nHdl1 , 'Data Base: ' + dtoc( ddatabase )                                                 + EOL )
//	fwrite( nHdl1 , 'Visão : '    + alltrim( cVisao0 ) + ' - ' + alltrim( cVisao1 )                   + EOL )
//	fwrite( nHdl1 , ' '                                                                               + EOL )
//	fwrite( nHdl1 , 'Posto;Descrição;Filial;Matrícula;Nome;Admissão;Demissão;Cód.Depto;Desc.Depto;CC' + EOL )
// -------------------------------
	fwrite( nHdl1 , 'Relatório de Arquitetura Organizacional - Completa'                              + EOL )
	fwrite( nHdl1 , 'Data Base: ' + dtoc( ddatabase )                                                 + EOL )
	fwrite( nHdl1 , 'Visão : '    + alltrim( cVisao0 ) + ' - ' + alltrim( cVisao1 )                   + EOL )
	fwrite( nHdl1 , ' '                                                                               + EOL )
//	fwrite( nHdl1 , 'Posto;Descrição;Filial;Matrícula;Nome;Admissão;Demissão;Cód.Depto;Desc.Depto;CC' + EOL )
	fwrite( nHdl1 , 'Filial;Posto;Descrição;Matrícula;Nome'                                           + EOL )
// -------------------------------

	procregua(     len( aCompleta ))
	for iX := 1 to len( aCompleta )
// -------------------------------	
		incproc()
// -------------------------------
//        cAux := ''
//        cKey := alltrim( aCompleta[iX,01] )
//        nTam := ( ( len( cKey ) / 3 ) - 1 )
//        for iY := 0 to nTam
//            cAux += substr( cKey , ( iY * 3 ) + 1 , 3 ) + ' ; '
//        next iY
//        cAux += replicate( ';' , ( nBigKey / 3 ) - ( nTam + 1 ) )
// -------------------------------
//		fwrite( nHdl1 ,       alltrim( cAux             ) +         ;
//		                "'" + alltrim( aCompleta[iX,02] ) + ' ; ' + ;
//		                      alltrim( aCompleta[iX,03] ) + ' ; ' + ;
//					    "'" + alltrim( aCompleta[iX,04] ) + ' ; ' + ;
//					    "'" + alltrim( aCompleta[iX,05] ) + ' ; ' + ;
//					          alltrim( aCompleta[iX,06] ) + ' ; ' + ;
//					          alltrim( aCompleta[iX,07] ) + ' ; ' + ;
//					          alltrim( aCompleta[iX,08] ) + ' ; ' + ;
//					    "'" + alltrim( aCompleta[iX,09] ) + ' ; ' + ;
//					          alltrim( aCompleta[iX,10] ) + ' ; ' + ;
//					    "'" + alltrim( aCompleta[iX,11] ) + EOL     )
// -------------------------------
//		fwrite( nHdl1 , "'" + alltrim( aCompleta[iX,02] ) + ' ; ' + ;
//		                      alltrim( aCompleta[iX,03] ) + ' ; ' + ;
//					    "'" + alltrim( aCompleta[iX,04] ) + ' ; ' + ;
//					    "'" + alltrim( aCompleta[iX,05] ) + ' ; ' + ;
//					          alltrim( aCompleta[iX,06] ) + ' ; ' + ;
//					          alltrim( aCompleta[iX,07] ) + ' ; ' + ;
//					          alltrim( aCompleta[iX,08] ) + ' ; ' + ;
//					    "'" + alltrim( aCompleta[iX,09] ) + ' ; ' + ;
//					          alltrim( aCompleta[iX,10] ) + ' ; ' + ;
//					    "'" + alltrim( aCompleta[iX,11] ) + EOL     )
// -------------------------------
		fwrite( nHdl1 , "'" + alltrim( aCompleta[iX,04] ) + ' ; ' + ; 
		                "'" + alltrim( aCompleta[iX,02] ) + ' ; ' + ;
		                      alltrim( aCompleta[iX,03] ) + ' ; ' + ;
					    "'" + alltrim( aCompleta[iX,05] ) + ' ; ' + ;
					          alltrim( aCompleta[iX,06] ) + EOL     )
// -------------------------------
	next iX
    fclose( nHdl1 )
// -------------------------------    
return

// ------------------------------------------------------------------

static function arqorg03
// -------------------------------
    local cTreAux     := ''
    local cChaAux     := ''
    local aParcialAux := aParcialPes
    local lAchou0     := .T.
    local nReg0       := 0
    local nReg1       := 0
// -------------------------------
    aParcial0 := {}
    aParcial1 := {}
// --------------------------
    aadd( aParcial0 , aParcialAux )
    cTreAux :=      alltrim( aParcialAux[01,07] )
    cChaAux :=      alltrim( aParcialAux[01,08] )
    nBigKey := len( alltrim( aParcialAux[01,08] ) )
    do while ( len( cChaAux ) <> 3 ) .AND. lAchou0
        nReg0 := ( arqorg04( cTreAux  ))
            if nReg0 < 1
            lAchou0 := .F.
        elseif nReg0 == 1
            lAchou0 := .T.
        elseif nReg0 > 1
            lAchou0 := .T.
        endif
        if lAchou0
            aParcialAux := ( arqorg05( cTreAux ))
            aadd( aParcial0 , aParcialAux )
            cTreAux := alltrim( aParcialAux[01,07] )
            cChaAux := alltrim( aParcialAux[01,08] )
        endif
    enddo
// --------------------------
    cChaAux := alltrim( aParcial0[01,01,08] )
    nReg1   := ( arqorg06( cChaAux ))
    if nReg1 > 0
        procregua( nReg1 )
        aParcial1 := ( arqorg07( cChaAux ))
    endif
// --------------------------
return .T.

// ------------------------------------------------------------------

static function arqorg04( cTreAux )
// -------------------------------
    local cQry2a := ''
// -------------------------------
    cQry2a := "    SELECT COUNT(*) TOTREG "
    cQry2a += "      FROM " + retsqlname( 'RD4' ) + " RD4 "
    cQry2a += " LEFT JOIN " + retsqlname( 'SRA' ) + " SRA "
    cQry2a += "        ON   SRA.D_E_L_E_T_ <> '*' "
    cQry2a += "       AND   SRA.RA_FILIAL   = RD4.RD4_FILIDE "
    cQry2a += "       AND   SRA.RA_POSTO    = RD4.RD4_CODIDE "
    cQry2a += "       AND   SRA.RA_ADMISSA <= '" + dtos( ddatabase ) + "' "
    cQry2a += "       AND ( SRA.RA_DEMISSA >= '" + dtos( ddatabase ) + "' "
    cQry2a += "        OR   SRA.RA_DEMISSA  = ' ' ) "
    cQry2a += " LEFT JOIN " + retsqlname( 'SQB' ) + " SQB  "
    cQry2a += "        ON SQB.D_E_L_E_T_ <> '*' "
    cQry2a += "       AND SQB.QB_FILIAL   = SRA.RA_FILIAL "
    cQry2a += "       AND SQB.QB_DEPTO    = SRA.RA_DEPTO  "
    cQry2a += "     WHERE RD4.D_E_L_E_T_ <> '*' "
    cQry2a += "       AND RD4.RD4_CHAVE  <> ' ' "
    cQry2a += "       AND RD4.RD4_STATUS <> '2' "
    cQry2a += "       AND RD4.RD4_CODIGO  = '" + cVisao0 + "' "
    cQry2a += "       AND RD4.RD4_ITEM    = '" + cTreAux + "' "
    cQry2a += "  ORDER BY RD4_CHAVE , RA_MAT "
    cQry2a := changequery( cQry2a )
// -------------------------------
    if select( 'QRY2a' ) > 0
		dbselectarea( 'QRY2a' )
		dbclosearea()
	endif
//	memowrite( 'C:\arqorg00_cQry2a.sql' , cQry2a )
	tcquery cQry2a alias 'QRY2a' new
// -------------------------------
return QRY2a->TOTREG

// ------------------------------------------------------------------

static function arqorg05( cTreAux )
// -------------------------------
    local cQry2b      := ''
    local aParcialAux := {}
    local cStatus     := ''
// -------------------------------
    cQry2b := "    SELECT RD4.RD4_CHAVE  , "
    cQry2b += "           RD4.RD4_FILIAL , "
    cQry2b += "           RD4.RD4_CODIGO , "
    cQry2b += "           RD4.RD4_ITEM   , "
    cQry2b += "           RD4.RD4_EMPIDE , "
    cQry2b += "           RD4.RD4_FILIDE , "
    cQry2b += "           RD4.RD4_CODIDE , "
    cQry2b += "           RD4.RD4_DESC   , "
    cQry2b += "           RD4.RD4_TREE   , "
    cQry2b += "           RD4.RD4_DATA   , "
    cQry2b += "           RD4.RD4_STATUS , "
    cQry2b += "           SRA.RA_FILIAL  , "
    cQry2b += "           SRA.RA_MAT     , "
    cQry2b += "           SRA.RA_NOME    , "
    cQry2b += "           SRA.RA_NOMECMP , "
    cQry2b += "           SRA.RA_POSTO   , "
    cQry2b += "           SRA.RA_ADMISSA , "
    cQry2b += "           SRA.RA_DEMISSA , "
    cQry2b += "           SRA.RA_DEPTO   , "
    cQry2b += "           SRA.RA_CC      , "
    cQry2b += "           SQB.QB_FILIAL  , "
    cQry2b += "           SQB.QB_DEPTO   , "
    cQry2b += "           SQB.QB_DESCRIC , "
    cQry2b += "           SQB.QB_CC        "
// -------------------------------
    cQry2b += " ,         SRA.RA_CIC       "
    cQry2b += " ,         SRA.RA_SITFOLH   "
// -------------------------------
    cQry2b += "      FROM " + retsqlname( 'RD4' ) + " RD4 "
    cQry2b += " LEFT JOIN " + retsqlname( 'SRA' ) + " SRA "
    cQry2b += "        ON   SRA.D_E_L_E_T_ <> '*' "
    cQry2b += "       AND   SRA.RA_FILIAL   = RD4.RD4_FILIDE "
    cQry2b += "       AND   SRA.RA_POSTO    = RD4.RD4_CODIDE "
    cQry2b += "       AND   SRA.RA_ADMISSA <= '" + dtos( ddatabase ) + "' "
    cQry2b += "       AND ( SRA.RA_DEMISSA >= '" + dtos( ddatabase ) + "' "
    cQry2b += "        OR   SRA.RA_DEMISSA  = ' ' ) "
    cQry2b += " LEFT JOIN " + retsqlname( 'SQB' ) + " SQB  "
    cQry2b += "        ON SQB.D_E_L_E_T_ <> '*' "
    cQry2b += "       AND SQB.QB_FILIAL   = SRA.RA_FILIAL "
    cQry2b += "       AND SQB.QB_DEPTO    = SRA.RA_DEPTO  "
    cQry2b += "     WHERE RD4.D_E_L_E_T_ <> '*' "
    cQry2b += "       AND RD4.RD4_CHAVE  <> ' ' "
    cQry2b += "       AND RD4.RD4_STATUS <> '2' "
    cQry2b += "       AND RD4.RD4_CODIGO  = '" + cVisao0 + "' "
    cQry2b += "       AND RD4.RD4_ITEM    = '" + cTreAux + "' "
    cQry2b += "  ORDER BY RD4_CHAVE , RA_MAT "
    cQry2b := changequery( cQry2b )
// -------------------------------
    if select( 'QRY2b' ) > 0
		dbselectarea( 'QRY2b' )
		dbclosearea()
	endif
//	memowrite( 'C:\arqorg00_cQry2b.sql' , cQry2b )
	tcquery cQry2b alias 'QRY2b' new
// -------------------------------
    do while QRY2b->( ! eof() )

// -------------------------------
//        aadd( aParcialAux , { alltrim( QRY2b->RD4_FILIDE ) , ;
//                              alltrim( QRY2b->RD4_CODIDE ) , ;
//                              alltrim( QRY2b->RD4_DESC   ) , ;
//                              alltrim( QRY2b->RA_MAT     ) , ;
//                              alltrim( QRY2b->RA_NOMECMP ) , ;
//                              alltrim( QRY2b->RD4_ITEM   ) , ;
//                              alltrim( QRY2b->RD4_TREE   ) , ;
//                              alltrim( QRY2b->RD4_CHAVE  ) } )
// -------------------------------
        cStatus := posicione( 'SX5' , 1 , xfilial( 'SX5' ) + '31' + QRY2b->RA_SITFOLH , 'X5_DESCRI' )
        aadd( aParcialAux , { alltrim( QRY2b->RD4_FILIDE ) , ;
                              alltrim( QRY2b->RD4_CODIDE ) , ;
                              alltrim( QRY2b->RD4_DESC   ) , ;
                              alltrim( QRY2b->RA_MAT     ) , ;
                              alltrim( QRY2b->RA_NOMECMP ) , ;
                              alltrim( QRY2b->RD4_ITEM   ) , ;
                              alltrim( QRY2b->RD4_TREE   ) , ;
                              alltrim( QRY2b->RD4_CHAVE  ) , ;
                            transForm( QRY2b->RA_CIC , '@R 999.999.999-99'     ) , ;
                                       QRY2b->RA_SITFOLH   , ;
                                       cStatus             } )
// -------------------------------

        QRY2b->( dbskip() )
    enddo
// -------------------------------
return aParcialAux

// ------------------------------------------------------------------

static function arqorg06( cChaAux )
// -------------------------------
    local cQry2c := ''
// -------------------------------
    cQry2c := "    SELECT COUNT(*) TOTREG "
    cQry2c += "      FROM " + retsqlname( 'RD4' ) + " RD4 "
    cQry2c += " LEFT JOIN " + retsqlname( 'SRA' ) + " SRA "
    cQry2c += "        ON   SRA.D_E_L_E_T_ <> '*' "
    cQry2c += "       AND   SRA.RA_FILIAL   = RD4.RD4_FILIDE "
    cQry2c += "       AND   SRA.RA_POSTO    = RD4.RD4_CODIDE "
    cQry2c += "       AND   SRA.RA_ADMISSA <= '" + dtos( ddatabase ) + "' "
    cQry2c += "       AND ( SRA.RA_DEMISSA >= '" + dtos( ddatabase ) + "' "
    cQry2c += "        OR   SRA.RA_DEMISSA  = ' ' ) "
    cQry2c += " LEFT JOIN " + retsqlname( 'SQB' ) + " SQB  "
    cQry2c += "        ON SQB.D_E_L_E_T_   <> '*' "
    cQry2c += "       AND SQB.QB_FILIAL     = SRA.RA_FILIAL "
    cQry2c += "       AND SQB.QB_DEPTO      = SRA.RA_DEPTO  "
    cQry2c += "     WHERE RD4.D_E_L_E_T_   <> '*' "
    cQry2c += "       AND RD4.RD4_CHAVE  LIKE '" + cChaAux + "%' "
    cQry2c += "       AND RD4.RD4_CHAVE     > '" + cChaAux +  "' "
    cQry2c += "       AND RD4.RD4_STATUS   <> '2' "
    cQry2c += "       AND RD4.RD4_CODIGO    = '" + cVisao0 + "' "
    cQry2c += "  ORDER BY RD4_CHAVE , RA_MAT "
    cQry2c := changequery( cQry2c )
// -------------------------------
    if select( 'QRY2c' ) > 0
		dbselectarea( 'QRY2c' )
		dbclosearea()
	endif
//	memowrite( 'C:\arqorg00_cQry2c.sql' , cQry2c )
	tcquery cQry2c alias 'QRY2c' new
// -------------------------------
return QRY2c->TOTREG

// ------------------------------------------------------------------

static function arqorg07( cChaAux )
// -------------------------------
    local cQry2d      := ''
    local aParcialAux := {}
    local cAdmis      := ''
    local cDemis      := ''
// -------------------------------
    local cStatus     := ''
    local nReg0       := 0
    local lAchou0     := .T.
    local aParc       := {}
// -------------------------------
    if ( len( alltrim( cChaAux )) > nBigKey )
        nBigKey := len( alltrim( cChaAux ))
    endif
// -------------------------------
    cQry2d := "    SELECT RD4.RD4_CHAVE  , "
    cQry2d += "           RD4.RD4_FILIAL , "
    cQry2d += "           RD4.RD4_CODIGO , "
    cQry2d += "           RD4.RD4_ITEM   , "
    cQry2d += "           RD4.RD4_EMPIDE , "
    cQry2d += "           RD4.RD4_FILIDE , "
    cQry2d += "           RD4.RD4_CODIDE , "
    cQry2d += "           RD4.RD4_DESC   , "
    cQry2d += "           RD4.RD4_TREE   , "
    cQry2d += "           RD4.RD4_DATA   , "
    cQry2d += "           RD4.RD4_STATUS , "
    cQry2d += "           SRA.RA_FILIAL  , "
    cQry2d += "           SRA.RA_MAT     , "
    cQry2d += "           SRA.RA_NOME    , "
    cQry2d += "           SRA.RA_NOMECMP , "
    cQry2d += "           SRA.RA_POSTO   , "
    cQry2d += "           SRA.RA_ADMISSA , "
    cQry2d += "           SRA.RA_DEMISSA , "
    cQry2d += "           SRA.RA_DEPTO   , "
    cQry2d += "           SRA.RA_CC      , "
    cQry2d += "           SQB.QB_FILIAL  , "
    cQry2d += "           SQB.QB_DEPTO   , "
    cQry2d += "           SQB.QB_DESCRIC , "
    cQry2d += "           SQB.QB_CC        "
// -------------------------------
    cQry2d += " ,         SRA.RA_CIC       "
    cQry2d += " ,         SRA.RA_SITFOLH   "
// -------------------------------
    cQry2d += "      FROM " + retsqlname( 'RD4' ) + " RD4 "
    cQry2d += " LEFT JOIN " + retsqlname( 'SRA' ) + " SRA "
    cQry2d += "        ON   SRA.D_E_L_E_T_ <> '*' "
    cQry2d += "       AND   SRA.RA_FILIAL   = RD4.RD4_FILIDE "
    cQry2d += "       AND   SRA.RA_POSTO    = RD4.RD4_CODIDE "
    cQry2d += "       AND   SRA.RA_ADMISSA <= '" + dtos( ddatabase ) + "' "
    cQry2d += "       AND ( SRA.RA_DEMISSA >= '" + dtos( ddatabase ) + "' "
    cQry2d += "        OR   SRA.RA_DEMISSA  = ' ' ) "
    cQry2d += " LEFT JOIN " + retsqlname( 'SQB' ) + " SQB  "
    cQry2d += "        ON SQB.D_E_L_E_T_   <> '*' "
    cQry2d += "       AND SQB.QB_FILIAL     = SRA.RA_FILIAL "
    cQry2d += "       AND SQB.QB_DEPTO      = SRA.RA_DEPTO  "
    cQry2d += "     WHERE RD4.D_E_L_E_T_   <> '*' "
    cQry2d += "       AND RD4.RD4_CHAVE  LIKE '" + cChaAux + "%' "
    cQry2d += "       AND RD4.RD4_CHAVE     > '" + cChaAux +  "' "
    cQry2d += "       AND RD4.RD4_STATUS   <> '2' "
    cQry2d += "       AND RD4.RD4_CODIGO    = '" + cVisao0 + "' "
    cQry2d += "  ORDER BY RD4_CHAVE , RA_MAT "
    cQry2d := changequery( cQry2d )
// -------------------------------
    if select( 'QRY2d' ) > 0
		dbselectarea( 'QRY2d' )
		dbclosearea()
	endif
//	memowrite( 'C:\arqorg00_cQry2d.sql' , cQry2d )
	tcquery cQry2d alias 'QRY2d' new
// -------------------------------

// -------------------------------
    do while QRY2d->( ! eof() )
        incproc()
// ---------------------
        if ( len( alltrim( QRY2d->RD4_CHAVE ) ) > nBigKey )
            nBigKey := len( alltrim( QRY2d->RD4_CHAVE ))
        endif
// ---------------------
        if empty( alltrim( QRY2d->RA_ADMISSA ))
            cAdmis := ' '
        else
            cAdmis := dtoc( stod( QRY2d->RA_ADMISSA ))
        endif
// ---------------------
        if empty( alltrim( QRY2d->RA_DEMISSA ))
            cDemis := ' '
        else
            cDemis := dtoc( stod( QRY2d->RA_DEMISSA ))
        endif
// ---------------------
//        aadd( aParcialAux , { QRY2d->RD4_CHAVE  , ;
//                              QRY2d->RD4_CODIDE , ;
//                              QRY2d->RD4_DESC   , ;
//                              QRY2d->RD4_FILIDE , ;
//                              QRY2d->RA_MAT     , ;
//                              QRY2d->RA_NOMECMP , ;
//                              cAdmis            , ;
//                              cDemis            , ;
//                              QRY2d->RA_DEPTO   , ;
//                              QRY2d->QB_DESCRIC , ;
//                              QRY2d->QB_CC      } )
// ---------------------
// aqui
        nReg0 := ( arqorg04( QRY2d->RD4_TREE ))
            if nReg0 < 1
            lAchou0 := .F.
        elseif nReg0 == 1
            lAchou0 := .T.
        elseif nReg0 > 1
            lAchou0 := .T.
        endif
        if lAchou0
            aParc := {}
            aParc := ( arqorg05( QRY2d->RD4_TREE ))
        endif
// ---------------------
        cStatus := posicione( 'SX5' , 1 , xfilial( 'SX5' ) + '31' + QRY2d->RA_SITFOLH , 'X5_DESCRI' )
        if len( aParc ) == 0
            aadd( aParcialAux , { QRY2d->RD4_CHAVE  , ;
                                  QRY2d->RD4_CODIDE , ;
                                  QRY2d->RD4_DESC   , ;
                                  QRY2d->RD4_FILIDE , ;
                                  QRY2d->RA_MAT     , ;
                                  QRY2d->RA_NOMECMP , ;
                                  cAdmis            , ;
                                  cDemis            , ;
                                  QRY2d->RA_DEPTO   , ;
                                  QRY2d->QB_DESCRIC , ;
                                  QRY2d->QB_CC      , ;
                       transForm( QRY2d->RA_CIC , '@R 999.999.999-99' ) , ;
                                  QRY2d->RA_SITFOLH , ;
                                  cStatus           , ;
                                  ' '               , ;
                                  ' '               , ;
                                  ' '               , ;
                                  ' '               , ;
                                  ' '               , ;
                                  ' '               , ;
                                  ' '               } )
        else
            aadd( aParcialAux , { QRY2d->RD4_CHAVE  , ;
                                  QRY2d->RD4_CODIDE , ;
                                  QRY2d->RD4_DESC   , ;
                                  QRY2d->RD4_FILIDE , ;
                                  QRY2d->RA_MAT     , ;
                                  QRY2d->RA_NOMECMP , ;
                                  cAdmis            , ;
                                  cDemis            , ;
                                  QRY2d->RA_DEPTO   , ;
                                  QRY2d->QB_DESCRIC , ;
                                  QRY2d->QB_CC      , ;
                       transForm( QRY2d->RA_CIC , '@R 999.999.999-99' ) , ;
                                  QRY2d->RA_SITFOLH , ;
                                  cStatus           , ;
                                  aParc[1][01]      , ;
                                  aParc[1][02]      , ;
                                  aParc[1][03]      , ;
                                  aParc[1][04]      , ;
                                  aParc[1][09]      , ;
                                  aParc[1][05]      , ;
                                  aParc[1][11]      } )
        endif
// ---------------------
        QRY2d->( dbskip() )
    enddo
// -------------------------------

return aParcialAux

// ------------------------------------------------------------------
// [ Gerando Arquitetura Organizacional - Parcial ]
// ------------------------------------------------------------------
static function arqorg10
// -------------------------------
    local nTam   := 0
    local cKey   := ''
    local cAux   := ''
    local iX     := 0
    local iY     := 0
    local iZ     := 0
    local nTot   := 0
    local nTotal := 0
// -------------------------------
    for iX := 1 to len( aParcial0 )
        nTot += len( aParcial0[iX] )
    next iX
    nTotal := nTot + len( aParcial1 )
// -------------------------------
	nHdl1  := fopen( cRefArqDes , 1 )
// -------------------------------
//	fwrite( nHdl1 , 'Relatório de Arquitetura Organizacional - Parcial'             + EOL )
//	fwrite( nHdl1 , 'Data Base: ' + dtoc( ddatabase )                               + EOL )
//	fwrite( nHdl1 , 'Visão : '    + alltrim( cVisao0 ) + ' - ' + alltrim( cVisao1 ) + EOL )
//	fwrite( nHdl1 , ' '                                                             + EOL )
//	fwrite( nHdl1 , 'Nível' + replicate( ';' , ( nBigKey / 3 ) ) + ;
//         replicate( 'Filial;Posto;Descrição;Matrícula;Nome;' , nTot )             + EOL )
// -------------------------------

// -------------------------------
//	fwrite( nHdl1 , 'Relatório de Arquitetura Organizacional - Parcial'             + EOL )
//	fwrite( nHdl1 , 'Data Base: ' + dtoc( ddatabase )                               + EOL )
//	fwrite( nHdl1 , 'Visão : '    + alltrim( cVisao0 ) + ' - ' + alltrim( cVisao1 ) + EOL )
//	fwrite( nHdl1 , ' '                                                             + EOL )
//	fwrite( nHdl1 , replicate( 'Filial;Posto;Descrição;Matrícula;Nome;' , nTot )    + EOL )
// -------------------------------
	fwrite( nHdl1 , 'Relatório de Arquitetura Organizacional - Parcial'             + EOL )
	fwrite( nHdl1 , 'Data Base: ' + dtoc( ddatabase )                               + EOL )
	fwrite( nHdl1 , 'Visão : '    + alltrim( cVisao0 ) + ' - ' + alltrim( cVisao1 ) + EOL )
	fwrite( nHdl1 , ' '                                                             + EOL )
	fwrite( nHdl1 , replicate( 'Filial;Posto;Descrição;Matrícula;CPF;Nome;Status;' , nTot ) + EOL )
// -------------------------------

	procregua( nTotal )
// -------------------------------
//    cAux := ''
//    cKey := alltrim( aParcial0[01,01,08] )
//    nTam := ( ( len( cKey ) / 3 ) - 1 )
//    for iY := 0 to nTam
//        cAux += substr( cKey , ( iY * 3 ) + 1 , 3 ) + ' ; '
//    next iY
//    cAux += replicate( ';' , ( nBigKey / 3 ) - ( nTam + 1 ) )
// -------------------------------
//	fwrite( nHdl1 , alltrim( cAux ))
// -------------------------------
	for iX := 1 to len( aParcial0 )
// -------------------------------	
		incproc()
// -------------------------------
//        for iZ := 1 to len( aParcial0[iX] )
//            fwrite( nHdl1 , "'" + alltrim( aParcial0[iX,iZ,01] ) + ' ; ' + ;
//                            "'" + alltrim( aParcial0[iX,iZ,02] ) + ' ; ' + ;
//                                  alltrim( aParcial0[iX,iZ,03] ) + ' ; ' + ;
//                            "'" + alltrim( aParcial0[iX,iZ,04] ) + ' ; ' + ;
//                                  alltrim( aParcial0[iX,iZ,05] )           )
// -------------------------------
        for iZ := 1 to len( aParcial0[iX] )
            fwrite( nHdl1 , "'" + alltrim( aParcial0[iX,iZ,01] ) + ' ; ' + ;
                            "'" + alltrim( aParcial0[iX,iZ,02] ) + ' ; ' + ;
                                  alltrim( aParcial0[iX,iZ,03] ) + ' ; ' + ;
                            "'" + alltrim( aParcial0[iX,iZ,04] ) + ' ; ' + ;
                            "'" + alltrim( aParcial0[iX,iZ,09] ) + ' ; ' + ;
                                  alltrim( aParcial0[iX,iZ,05] ) + ' ; ' + ;
                                  alltrim( aParcial0[iX,iZ,11] )           )
// -------------------------------
            if ( iX <> len( aParcial0     ) .OR. ;
                 iZ <> len( aParcial0[iX] ) )
                fwrite( nHdl1 , ';' )
            else
                fwrite( nHdl1 , EOL )
            endif
        next iZ
// -------------------------------
	next iX
	
// ------------------------------------------------------------------
    if len( aParcial1 ) >= 1
        for iX := 1 to len( aParcial1 )
// -------------------------------	
		    incproc()
// -------------------------------
//            cAux := ''
//            cKey := alltrim( aParcial1[iX,01] )
//            nTam := ( ( len( cKey ) / 3 ) - 1 )
//            for iY := 0 to nTam
//                cAux += substr( cKey , ( iY * 3 ) + 1 , 3 ) + ' ; '
//            next iY
//            cAux += replicate( ';' , ( nBigKey / 3 ) - ( nTam + 1 ) )
// -------------------------------
//		    fwrite( nHdl1 ,       alltrim( cAux             ) +         ;
//		                    "'" + alltrim( aParcial1[iX,04] ) + ' ; ' + ;
//		                    "'" + alltrim( aParcial1[iX,02] ) + ' ; ' + ;
//					              alltrim( aParcial1[iX,03] ) + ' ; ' + ;
//					        "'" + alltrim( aParcial1[iX,05] ) + ' ; ' + ;
//					              alltrim( aParcial1[iX,06] ) + EOL     )
// -------------------------------
		    fwrite( nHdl1 , "'" + alltrim( aParcial1[iX,04] ) + ' ; ' + ;
		                    "'" + alltrim( aParcial1[iX,02] ) + ' ; ' + ;
					              alltrim( aParcial1[iX,03] ) + ' ; ' + ;
					        "'" + alltrim( aParcial1[iX,05] ) + ' ; ' + ;
					        "'" + alltrim( aParcial1[iX,12] ) + ' ; ' + ;
					              alltrim( aParcial1[iX,06] ) + ' ; ' + ;
					              alltrim( aParcial1[iX,14] ) + ' ; ' + ;
                            "'" + alltrim( aParcial1[iX,15] ) + ' ; ' + ;
		                    "'" + alltrim( aParcial1[iX,16] ) + ' ; ' + ;
					              alltrim( aParcial1[iX,17] ) + ' ; ' + ;
					        "'" + alltrim( aParcial1[iX,18] ) + ' ; ' + ;
					        "'" + alltrim( aParcial1[iX,19] ) + ' ; ' + ;
					              alltrim( aParcial1[iX,20] ) + ' ; ' + ;
					              alltrim( aParcial1[iX,21] ) + EOL     )
// -------------------------------
        next iX
	endif
// ------------------------------------------------------------------
    fclose( nHdl1 )
// -------------------------------    
return

// ------------------------------------------------------------------
// [ fim de arqorgxx.prw ]
// ------------------------------------------------------------------
