<!-- #include virtual = "/inc/inc_function/Func_Connect.asp" -->
<!-- #include virtual = "/inc/inc_function/Func_Global.asp" -->
<%

Call DB_OPEN()

uid = Request("uid")
ocode = Request("ocode")
scode = Request("scode")
lm_num = Request("lm_num")
user_name = Request("user_name")
lm_title = Request("lm_title")
lm_time = Request("lm_time")
'Response.Write uid & " " & ocode&" " &" " & scode & " "  & lm_num & " " & user_name

BOARD = "_MEDIA_HISTORY"
SQL="SELECT * FROM " & BOARD & " WHERE UID='"&uid&"' AND ORDER_CODE='"&ocode&"' AND SUBJECT_CODE='"&scode&"' AND CHAPTER_NUMBER='"&lm_num&"'"
objRs.Open SQL, Dbcon, 1
If objRs.BOF Or objRs.EOF Then
	CurrentTime = 0
	SQL = "INSERT INTO " & BOARD & " (UID, NAME, UNIV_ID, ORDER_CODE, SUBJECT_CODE, CHAPTER_NUMBER, CHAPTER_NAME, START_TIME, END_TIME, STAY_TIME, CurrentTime, IP) Values "
	SQL = SQL & "('" & uid
	SQL = SQL & "','" & user_name
	SQL = SQL & "','" & "B2C"
	SQL = SQL & "','" & ocode
	SQL = SQL & "','" & scode
	SQL = SQL & "','" & lm_num
	SQL = SQL & "','" & lm_title
	SQL = SQL & "'," & "getdate()"
	SQL = SQL & "," & "getdate()"
	SQL = SQL & ",'" & "10"
	SQL = SQL & "','" & CurrentTime
	SQL = SQL & "','" & Request.Servervariables("remote_addr")
	SQL = SQL & "')"
	Dbcon.Execute SQL
Else
	STAY_TIME = objRs("STAY_TIME")
	CurrentTime = objRs("CurrentTime")
End if
objRs.Close

lm_time = (lm_time*60)-60		'����ð����� 60����
If CurrentTime = "0" Or CurrentTime > lm_time Then	'���������� ������ �ѽð����� 60�� ���̸�
	CurrentState = "N"								'�̾�� �������
Else
	CurrentState = "Y"								'�̾�� ����
End If

Response.Write CurrentState & " " & CurrentTime
Response.End

%>