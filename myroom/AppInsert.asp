<!-- #include virtual = "/inc/inc_function/Func_Connect.asp" -->
<!-- #include virtual = "/inc/inc_function/Func_Global.asp" -->
<%
Call DB_OPEN()

BOARD = "_APPConfirm"
uid=Request("uid")
ocode=Request("ocode")
app_code=Request("IMEI")

SQL = "SELECT * FROM _APPConfirm WHERE UID='"&uid&"' AND OID_CODE='"&ocode&"' AND APP_CODE='"&app_code&"' ORDER BY SEQ"
objRs.Open SQL, Dbcon, 1
If objRs.BOF Or objRs.EOF Then
	SQL = "INSERT INTO " & BOARD & " (UID, OID_CODE, APP_CODE, regdate) Values "
	SQL = SQL & "('" & uid
	SQL = SQL & "','" & ocode
	SQL = SQL & "','" & app_code
	SQL = SQL & "'," & "getdate()"
	SQL = SQL & ")"
	Dbcon.Execute SQL
End if
objRs.Close


SQL = "SELECT * FROM _APPConfirm WHERE UID='"&uid&"' AND OID_CODE='"&ocode&"' AND APP_CODE='"&app_code&"' ORDER BY SEQ"
objRs.Open SQL, Dbcon, 1
If Not objRs.EOF Then
	Response.Write "Y"
Else
	Response.Write "N"
End if
objRs.Close
Call DB_CLOSE()
%>
