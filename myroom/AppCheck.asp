<!-- #include virtual = "/inc/inc_function/Func_Connect.asp" -->
<!-- #include virtual = "/inc/inc_function/Func_Global.asp" -->
<%
Call DB_OPEN()

uid=Request("uid")
ocode=Request("ocode")
app_code=Request("IMEI")

SQL = "SELECT * FROM _APPConfirm WHERE UID='"&uid&"' AND OID_CODE='"&ocode&"' AND APP_CODE='"&app_code&"' ORDER BY SEQ"
objRs.Open SQL, Dbcon, 1
If Not objRs.EOF Then
	Response.Write "Y"
Else
	SQL2 = "SELECT * FROM _APPConfirm WHERE UID='"&uid&"' AND OID_CODE='"&ocode&"' ORDER BY SEQ"
	objRs2.Open SQL2, Dbcon, 1
	If Not objRs2.EOF Then
		Response.Write "N"			'먼가 있는데 틀린경우
	Else
		Response.Write "Nothing"	'아무것도 없을경우		
	End If
	objRs2.Close
End If
objRs.Close

Call DB_CLOSE()
%>
