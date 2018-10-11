<!-- #include virtual = "/inc/inc_function/Func_Connect.asp" -->
<!-- #include virtual = "/inc/inc_function/Func_Global.asp" -->



<%
Call OUTPUT_COOKIES()
Call DB_OPEN()

Dim arrViewTime(100,1)
For k = 0 To 99
	arrViewTime(k, 1) = 0
Next

BOARD = "_ORDER_B2C"
If Request("CLASS_CODE")="" Then
	CLASS_CODE = Request.Cookies("productInfo")("CLASS_CODE")
	OID = Request.Cookies("productInfo")("OID")
Else
	CLASS_CODE = Request("CLASS_CODE")
	OID = Request("OID")
End if


If CLASS_CODE = "" Then
	Response.Write "<script>alert('[error]세션이 만료되었습니다.\n\n다시 로그인 해 주세요.');window.close();</script>"
Else
	SQL = "SELECT * FROM " & BOARD & " WHERE UID='" & COOKIE_UID & "' AND LEC_CODE='" & CLASS_CODE & "' AND OID='"&OID&"' AND STATE='ing' ORDER BY SEQ"
	objRs.Open SQL, Dbcon, 1
	If (objRs.BOF OR objRs.EOF) Then
		Response.Write "<script>location.href='/index.asp';</script>"
		Response.End
	Else
		LEC_NAME = objRs("LEC_NAME")
		Response.Cookies("productInfo")("CLASS_CODE") = CLASS_CODE
		Response.Cookies("productInfo")("OID") = OID
	End If
	objRs.Close
End If

'출석체크
setYear = year(now)
setMonth = month(now)
setDay = day(now)
regIP = Request.Servervariables("remote_addr")

SQL = "SELECT * FROM _ATTEND WHERE UID='"&COOKIE_UID&"' AND LEC_CODE='"&CLASS_CODE&"' AND OID='"&OID&"' AND year(regDate)='"&setYear&"' AND month(regDate)='"&setMonth&"' AND day(regDate)='"&setDay&"' ORDER BY SEQ"
objRs.Open SQL, Dbcon, 1
If (objRs.BOF OR objRs.EOF) Then
	SQL = "INSERT INTO _ATTEND (UID, LEC_CODE, OID, regIP, regDate) Values "
	SQL = SQL & "('" & COOKIE_UID
	SQL = SQL & "','" & CLASS_CODE
	SQL = SQL & "','" & OID
	SQL = SQL & "','" & regIP
	SQL = SQL & "'," & "getdate()"
	SQL = SQL & ")"
	Dbcon.Execute SQL
End If
objRs.Close

clsCode=Request("clsCode")
SQL = "SELECT * FROM _LECTURE WHERE SEQ='"&CLASS_CODE&"' ORDER BY SEQ"
objRs.Open SQL, Dbcon, 1
If Not objRs.EOF Then
	a_mode=objRs("a_mode")
	a_pcode=objRs("a_pcode")
End If
objRs.Close

BOARD = "_LECTURE_LIST"
If a_mode="N" Then	'일반과정
	SQL = "SELECT * FROM " & BOARD & " WHERE LEC_SEQ='" & CLASS_CODE & "' ORDER BY lm_num ASC"
	objRs.Open SQL, Dbcon, 1
	Re_Count = objRs.RecordCount
	If Not objRs.EOF Then
		While Not objRs.EOF
			lm_book = objRs("lm_book")
			lm_teacher = objRs("lm_teacher")
			lm_file = objRs("lm_file")
			CHAPTER_NUMBER = objRs("lm_num")
			VOD_TIME = objRs("lm_time")
			SIZE = split(objRs("lm_viewer"),"*")
			strList = strList & "<tr height='40' bgcolor='#FFFFFF'>"
			strList = strList & "<td align='center'>" & objRs("lm_num") & "</td>"
			strList = strList & "<td align='left' style='padding:0 0 0 10px;'>" & objRs("lm_title") & "</td>"
			If lm_file <> "" Then
				strList = strList & "<td align='center'><a href=# onclick=startAppOrGoStore();><span class='box_btn25_col'>"&langage(476)&"</span></a></td>"
			Else
				strList = strList & "<td align='center'><a onclick=""alert('업로드 대기중인 강의 입니다.')""><span class='box_btn25_col'>-</span></a></td>"
			End if

'			If lm_book <> "" Then
'				strList = strList & "<td align='center'><a href=/inc/inc_function/Func_Download.asp?dir=book&SEQ=" & CLASS_CODE & "&file=" & SERVER.UrlEncode(lm_book) & "><span class='box_btn25_col'>"&langage(598)&"</span></a></td>"
'			Else
'				strList = strList & "<td align='center'>·</td>"
'			End If
'			strList = strList & "<td align='center'>" & objRs("lm_time") & " "&langage(534)&"</td>"
			strList = strList & "</tr>"
			strList = strList & "<tr>"
			strList = strList & "<td colspan='3' height='1' bgcolor='#E4E4E4'></td>"
			strList = strList & "</tr>"
		objRs.MoveNext
		Counter = Counter - 1
		Wend
	Else
		strList = strList & "<tr>"
		strList = strList & "<td colspan='3' height='40' bgcolor='#FFFFFF' align='center'>"&langage(306)&"</td>"
		strList = strList & "</tr>"
		strList = strList & "<tr>"
		strList = strList & "<td colspan='3' height='1' bgcolor='#E4E4E4'></td>"
		strList = strList & "</tr>"
	End If
	objRs.Close
	clsCode = CLASS_CODE

Else	'패키지과정
	arrPcode=Split(a_pcode,",")
	strPackage = strPackage & "<table border='0' cellspacing='0' cellpadding='0'>"
	SUBJECT_CNT = 1
	For i = 0 To UBound(arrPcode)
		QUERY = "SELECT * FROM _LECTURE WHERE SEQ='"&arrPcode(i)&"' ORDER BY SEQ "
		objRs2.Open QUERY, Dbcon, 0
		If Not objRs2.EOF Then
			a_title=objRs2("a_title")
		End If
		objRs2.Close
		
		If clsCode = "" Then
			clsCode = arrPcode(0)
		End If
		
		If arrPcode(i) = clsCode Then
			strPackage = strPackage & "<tr>"
			strPackage = strPackage & "<td height='20'><a onclick=goView('"&arrPcode(i)&"','lecture_view.asp') style='cursor:pointer;'><font color='ff9900'>"&SUBJECT_CNT&"과목: <b>" & a_title & "</b></font></td>"
			strPackage = strPackage & "</tr>"
			arrow = " > "
			LEC_SUB_NAME = a_title
		Else
			strPackage = strPackage & "<tr>"
			strPackage = strPackage & "<td height='20'><a onclick=goView('"&arrPcode(i)&"','lecture_view.asp') style='cursor:pointer;'>"&SUBJECT_CNT&"과목: " & a_title & "</td>"
			strPackage = strPackage & "</tr>"
		End If
	SUBJECT_CNT = SUBJECT_CNT + 1
	Next
	strPackage = strPackage & "</table>"


	SQL = "SELECT * FROM " & BOARD & " WHERE LEC_SEQ='" & clsCode & "' ORDER BY lm_num ASC"
	objRs.Open SQL, Dbcon, 1
	Re_Count = objRs.RecordCount
	If Not objRs.EOF Then
		While Not objRs.EOF
			lm_book = objRs("lm_book")
			lm_teacher = objRs("lm_teacher")
			lm_file = objRs("lm_file")
			CHAPTER_NUMBER = objRs("lm_num")
			VOD_TIME = objRs("lm_time")
			SIZE = split(objRs("lm_viewer"),"*")
			strList = strList & "<tr height='40' bgcolor='#FFFFFF'>"
			strList = strList & "<td align='center'>" & objRs("lm_num") & "</td>"
			strList = strList & "<td align='left' style='padding:0 0 0 10px;'>" & objRs("lm_title") & "</td>"

			If lm_file <> "" Then
				strList = strList & "<td align='center'><a href=""javascript:mplay('"&OID&"','"&objRs("LEC_SEQ")&"','"&objRs("SEQ")&"');""><span class='box_btn25_col'>"&langage(476)&"</span></a></td>"
			Else
				strList = strList & "<td align='center'><a onclick=""alert('업로드 대기중인 강의 입니다.')""><span class='box_btn25_col'>-</span></a></td>"
			End if


'			If lm_file <> "" Then
'				browser=Request.ServerVariables("HTTP_USER_AGENT")
'				If InStr(browser,"Chrome")>0 OR InStr(browser,"Safari")>0 OR InStr(browser,"Android")>0 OR InStr(browser,"iPhone")>0 Then
'					strList = strList & "<td align='center'><a href=""javascript:MediaViewer_Flash('"&OID&"','"&objRs("LEC_SEQ")&"','"&objRs("SEQ")&"','"&SIZE(0)&"','"&SIZE(1)&"');""><span class='box_btn25_col'>"&langage(476)&"</span></a></td>"
'				Else
'					strList = strList & "<td align='center'><a href=""javascript:MediaViewer('"&OID&"','"&objRs("LEC_SEQ")&"','"&objRs("SEQ")&"','"&SIZE(0)&"','"&SIZE(1)&"');""><span class='box_btn25_col'>"&langage(476)&"</span></a></td>"
'				End if
'			Else
'				strList = strList & "<td align='center'><a onclick=""alert('업로드 대기중인 강의 입니다.')""><span class='box_btn25_col'>-</span></a></td>"
'			End if

'			If lm_book <> "" Then
'				strList = strList & "<td align='center'><a href=/inc/inc_function/Func_Download.asp?dir=book&SEQ=" & clsCode & "&file=" & SERVER.UrlEncode(lm_book) & "><span class='box_btn25_col'>"&langage(598)&"</span></a></td>"
'			Else
'				strList = strList & "<td align='center'>·</td>"
'			End If

'			strList = strList & "<td align='center'>" & objRs("lm_time") & " "&langage(534)&"</td>"
			strList = strList & "</tr>"
			strList = strList & "<tr>"
			strList = strList & "<td colspan='3' height='1' bgcolor='#E4E4E4'></td>"
			strList = strList & "</tr>"
		objRs.MoveNext
		Counter = Counter - 1
		Wend
	Else
		strList = strList & "<tr>"
		strList = strList & "<td colspan='3' height='40' bgcolor='#FFFFFF' align='center'>"&langage(306)&"</td>"
		strList = strList & "</tr>"
		strList = strList & "<tr>"
		strList = strList & "<td colspan='3' height='1' bgcolor='#E4E4E4'></td>"
		strList = strList & "</tr>"
	End If
	objRs.Close
End if

Call DB_CLOSE()
%>
<!-- #include virtual="/inc/inc_function/Func_LoginCheck.asp" -->



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ko" lang="ko">
<head>
<meta name="format-detection" content="telephone=no" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width" />
<title>EDU TOPIK</title>
<link rel="stylesheet" type="text/css" href="/css/new_main.css" />

<script type="text/javascript" src="/js/common.js"></script>
<script type="text/javascript" src="/js/myroom.js"></script>

<script language="JavaScript">
function mplay(ocode, scode, vseq) {
	var theForm = document.form;
	var ocode, scode, vseq;
	theForm.action = "/inc/yplayer/mplay.asp?ocode="+ocode+"&scode="+scode+"&vseq="+vseq;
	theForm.submit();	
}

function startAppOrGoStore(){

	var params = [
	'uid=',
	'ocode=',
	'scode=',
	'vseq=',
	'lm_num=',
	'url=',
	'CurrentState=',
	'CurrentTime=',
	'lecture_title=',
	'lecture_unit='
	].join('&');

/*
필요한 것
uid
ocode
scode
vseq
lm_num
url
CurrentState
CurrentTime
lecture_title
lecture_unit

*/



	var intentURI = [
    'intent://player?'.concat(params).concat('#Intent'),
    'scheme=edutopik',
    'package=com.example.sy.gisa79test',
    //'S.browser_fallback_url=http://www.naver.com',  추후 play store에 어플 업로드하면 나오는 링크 추가 예정
    'end'
	].join(';');

	location.href = intentURI;
}
</script>


</head>
<body>

<!-- #include virtual = "/inc/inc_frame/top.asp" -->

<div id="content">

	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	<td class="sub_tab">
		<table border="0" cellspacing="0" cellpadding="0">
		<tr>
		<td style="padding:0 0 0 10px;"><a href="/myroom/lecture.asp"><b><%=langage(420)%></b></a></td>
		<td width="15" align="center"> > </td>
		<td><%=LEC_NAME%></td>
		</tr>
		</table>
	</td>
	</tr>
	</table>
	<div class="bot_10"></div>

	<!-- 패키지 메뉴 -->
	<div align="right">
	<table border="0" cellspacing="0" cellpadding="0">
	<tr>
	<td><%=strPackage%></td>
	</tr>
	</table>
	</div>
	<!-- 패키지 메뉴 -->

	<div>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	<td colspan="3" bgcolor="#E5E3E3" height="1"></td>
	</tr>
	<tr bgcolor="#F5F5F5" height="50">
	<td width="10%" align="center" style="font-weight:bold;"><%=langage(549)%></td>
	<td width="70%" align="center" style="font-weight:bold;"><%=langage(550)%></td>
	<td width="20%" align="center" style="font-weight:bold;"><%=langage(476)%></td>

	</tr>
	<tr>
	<td colspan="3" bgcolor="#E5E3E3" height="1"></td>
	</tr>
	<%=strList%>
	</table>
	</div>


	<form method="post" name="form">
	<input type="hidden" name="clsCode">
	</form>

</div>
<div class="bot_20"></div>
<!-- #include virtual = "/INC/INC_Frame/bottom.asp" -->
</body>
</html>