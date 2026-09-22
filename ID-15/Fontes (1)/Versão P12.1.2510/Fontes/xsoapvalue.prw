#include 'protheus.ch'
#include 'parmtype.ch'
//#XTRANSLATE ChkType(<cNode>,<xValue>,<cType>) => 	If valtype(<xValue>) != <cType> ; UserException('WSCERR055 / Invalid Property Type ('+valtype( <xValue> )+') for '+ <cNode> +' ('+ <cType> +')') ; Endif

// Translates para a marcação de Tempo e montagem de profile de execução

#XTRANSLATE MarkTimer() => __XMLCTimer := Seconds()
#XTRANSLATE ShowTimer(<cEcho>) => __XMLCPLog += str(Seconds() - __XMLCTimer,12,3)+' s. ['+<cEcho>+']' + CRLF 

User Function XSoapValue(cNode,xObjValue,xParamValue,cType,lObrigat,lRpc)

Local xFunc
Local cSoapRet := ''
Local xParam 	:= NIL
Local oTmpEnum
If xParamValue != NIL
	xParam := xParamValue
ElseIF xObjValue != NIL
	xParam := xObjValue
Endif

DEFAULT lRpc := .F. 

If lRpc
	If iknowtype(cType)
		cSoapRet += 	'<'+cNode+' xsi:type="xsd:'+cType+'">'
	Else
		cSoapRet += 	'<'+cNode+' xsi:type="q1:'+cType+'">'
	Endif
Else
	cSoapRet += 	'<'+cNode+'>'
Endif

//ChkType(cNode,xParam,'O')
//cSoapRet += xParam:SoapSend()
For nX := 01 To Len(xParam:OWsItem)
cSoapRet += '<item xsi:type="q1:processAttachmentDto">' + CRLF
cSoapRet += '<attachmentSequence xsi:type="xsd:int">1</attachmentSequence>' + CRLF
cSoapRet += '<attachments xsi:type="q1:attachment">' + CRLF
cSoapRet += '<attach xsi:type="xsd:boolean">true</attach>' + CRLF
cSoapRet += '<descriptor xsi:type="xsd:boolean">false</descriptor>' + CRLF
cSoapRet += '<editing type="xsd:boolean">true</editing>' + CRLF
For nY := 01 To Len(xParam:OWsItem[nx]:OWSATTACHMENTS)
	cSoapRet += '<fileName type="xsd:string">'+xParam:OWsItem[nx]:OWSATTACHMENTS[nY]:cFileName+'</fileName>' + CRLF
	cSoapRet += '<fileSize type="xsd:long">'+cValToCHar(xParam:OWsItem[nx]:OWSATTACHMENTS[nY]:nFileSize)+'</fileSize>' + CRLF
	cSoapRet += '<filecontent type="xsd:string">'+xParam:OWsItem[nx]:OWSATTACHMENTS[nY]:cFileContent+'</filecontent>' + CRLF
Next nY
cSoapRet += '</attachments>' + CRLF
cSoapRet += '<colleagueId xsi:type="xsd:string">'+xParam:OWsItem[nx]:cColleagueId +'</colleagueId>' + CRLF
cSoapRet += '<colleagueName xsi:type="xsd:string">'+xParam:OWsItem[nx]:cColleagueName+'</colleagueName>' + CRLF
cSoapRet += '<companyId xsi:type="xsd:long">'+cValToCHar(xParam:OWsItem[nx]:nCompanyId)+'</companyId>' + CRLF
cSoapRet += '<crc xsi:type="xsd:long">0</crc>' + CRLF
cSoapRet += '<deleted xsi:type="xsd:boolean">false</deleted>' + CRLF
cSoapRet += '<description xsi:type="xsd:string">'+xParam:OWsItem[nx]:cDescription+'</description>' + CRLF
cSoapRet += '<fileName xsi:type="xsd:string">'+xParam:OWsItem[nx]:cFileName+'</fileName>' + CRLF
cSoapRet += '<newAttach xsi:type="xsd:boolean">true</newAttach>' + CRLF
cSoapRet += '<originalMovementSequence xsi:type="xsd:int">1</originalMovementSequence>' + CRLF
cSoapRet += '<permission xsi:type="xsd:string">3</permission>' + CRLF
cSoapRet += '<processInstanceId xsi:type="xsd:int">'+cValToChar(xParam:OWsItem[nx]:nProcessInstanceId)+'</processInstanceId>' + CRLF
cSoapRet += '<size xsi:type="xsd:float">'+cValToChar(xParam:OWsItem[nx]:nSize)+'</size>' + CRLF
cSoapRet += '<version xsi:type="xsd:int">0</version>' + CRLF
cSoapRet += '</item>' + CRLF

Next nX
cSoapRet += '</'+cNode+'>'

Return cSoapRet
/* ----------------------------------------------------------------------------------
Funcao		IKnowType(cDataType)
Descricao	Funcao que retorna .T. Caso o tipo passado como parametro seja básico
---------------------------------------------------------------------------------- */
STATIC FUNCTION IKnowType(cDataType)
Return NoNameSpace(Upper(cDataType))$"STRING,INTEGER,BYTE,DOUBLE,INT,FLOAT,DATE,NULLPARAM,BASE64BINARY,BOOLEAN,UNSIGNEDLONG,UNSIGNEDINT,DATETIME,DECIMAL,LONG,ANYTYPE"

/* ----------------------------------------------------------------------------------
Funcao		NoNameSpace(cType)
Descricao	Funcao que retira o namespace ( xxx: ) de uma string
---------------------------------------------------------------------------------- */
STATIC FUNCTION NoNameSpace(cType)
Local nP
Return IIf( (nP := at(":",cType)) > 0 , Substr(cType,nP+1) , cType )
