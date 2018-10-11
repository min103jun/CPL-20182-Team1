<!-- #include virtual = "/inc/inc_function/Func_Connect.asp" -->
<!-- #include virtual = "/inc/inc_function/Func_Global.asp" -->
<%
Call OUTPUT_COOKIES()
Call DB_OPEN()
Response.Cookies("productInfo")("CLASS_CODE") = ""
Response.Cookies("productInfo")("OID") = ""
Response.Cookies("productInfo")("clsCode") = ""

Dim arrViewTime(100,1)
For k = 0 To 99
	arrViewTime(k, 1) = 0
Next

BOARD = "_ORDER_B2C"
SQL = "SELECT * FROM " & BOARD & " WHERE UID='" & COOKIE_UID & "' AND STATE='ing' ORDER BY SEQ DESC"
objRs.Open SQL, Dbcon, 1
If Not objRs.EOF Then
	While Not objRs.EOF
'		수강종료일 설정		
		If DateDiff("d",now(),objRs("lec_end")) < 0 Then
			SQL = "UPDATE _ORDER SET STATE='end' WHERE SEQ='"&objRs("SEQ")&"'"
			Dbcon.Execute SQL
		End If
	objRs.MoveNext
	Counter = Counter - 1
	Wend
End if
objRs.Close


SQL = "SELECT * FROM " & BOARD & " WHERE UID='" & COOKIE_UID & "' AND STATE='ing' ORDER BY SEQ DESC"
objRs.Open SQL, Dbcon, 1
If Not objRs.EOF Then
	Counter = 1
	While Not objRs.EOF
		SEQ = objRs("SEQ")
		LEC_CODE = objRs("LEC_CODE")
		LEC_NAME = objRs("LEC_NAME")
		OID = objRs("OID")

		QUERY = "SELECT * FROM _LECTURE WHERE SEQ='"&LEC_CODE&"' ORDER BY SEQ "
		objRs2.Open QUERY, Dbcon, 0
		If Not objRs2.EOF Then
			a_mode=objRs2("a_mode")
			a_pcode=objRs2("a_pcode")
			a_survey_code = objRs2("a_survey_code")
		End If
		objRs2.Close

		If a_mode = "N" Then
			a_mode_txt = langage(644)
		Elseif a_mode = "P" Then
			a_mode_txt = langage(643)
		End if
		
		addDate = DateDiff("D", now(), objRs("lec_end"))
		strLECList = strLECList & "<form name='form"&SEQ&"' method='post'>"
		strLECList = strLECList & "<input type='hidden' name='LEC_CODE' value='"&objRs("LEC_CODE")&"'>"
		strLECList = strLECList & "<input type='hidden' name='OID' value='"&objRs("OID")&"'>"
		strLECList = strLECList & "<tr height='50' bgcolor='#FFFFFF'>"
		strLECList = strLECList & "<td align='center'>"&Counter&"</td>"
		strLECList = strLECList & "<td align='center'>"&a_mode_txt&"</td>"
		If a_mode = "N" Then		

			strLECList = strLECList & "<td style='padding:0 0 0 10px;cursor:pointer;' onclick=""ClassView('"&objRs("LEC_CODE")&"','"&objRs("OID")&"','lecture_view.asp');"">" & objRs("LEC_NAME") & "</a></td>"
		
		Elseif a_mode = "P" Then
			strLECList = strLECList & "<td style='padding:0px 0 0px 10px;cursor:pointer;'>"
				strLECList = strLECList & "<table border='0' cellspacing='0' cellpadding='0'>"
				strLECList = strLECList & "<tr>"
				strLECList = strLECList & "<td height='50' onclick=""toggleContent(content"&objRs("SEQ")&");"">" & objRs("LEC_NAME") & "</a></td>"	
				strLECList = strLECList & "</tr>"

				strLECList = strLECList & "<tr>"
				strLECList = strLECList & "<td id='content"&objRs("SEQ")&"' style='display:none;'>"
					strLECList = strLECList & "<table border='0' cellspacing='0' cellpadding='0'>"
					arrPcode=Split(a_pcode,",")
					Scnt = 1
					For i = 0 To UBound(arrPcode)
					QUERY = "SELECT * FROM _LECTURE WHERE SEQ='"&arrPcode(i)&"' ORDER BY SEQ "
					objRs2.Open QUERY, Dbcon, 0
					If Not objRs2.EOF Then
						a_title=objRs2("a_title")
					End If
					objRs2.Close
					
					strLECList = strLECList & "<tr>"
					strLECList = strLECList & "<td style='padding:5px 0 5px 0px;cursor:pointer;'><a onclick=""PClassView('"&objRs("LEC_CODE")&"','"&objRs("OID")&"','"&arrPcode(i)&"','lecture_view.asp');"">"&Scnt &". "& a_title & "</a></td>"	
					strLECList = strLECList & "</tr>"
					Scnt = Scnt + 1
					Next

					strLECList = strLECList & "<tr>"
					strLECList = strLECList & "<td height='5'></td>"	
					strLECList = strLECList & "</tr>"
					strLECList = strLECList & "</table>"
				strLECList = strLECList & "</td>"
				strLECList = strLECList & "</tr>"
				strLECList = strLECList & "</table>"
			strLECList = strLECList & "</td>"
		End if
'		strLECList = strLECList & "<td align='center'>" & Replace(Left(objRs("lec_start"),10),"-",".") & "~" & Replace(Left(objRs("lec_end"),10),"-",".") & "</td>"
		strLECList = strLECList & "<td align='center'>"&addDate&" "&langage(568)&"</td>"
		strLECList = strLECList & "</tr>"
		strLECList = strLECList & "<tr>"
		strLECList = strLECList & "<td colspan='4' height='1' bgcolor='#E4E4E4'></td>"
		strLECList = strLECList & "</tr>"
		strLECList = strLECList & "</form>"

	objRs.MoveNext
	Counter = Counter + 1
	Wend
Else
	strLECList = strLECList & "<tr>"
	strLECList = strLECList & "<td colspan='4' height='50' bgcolor='#FFFFFF' align='center'>"&langage(569)&"</td>"
	strLECList = strLECList & "</tr>"
	strLECList = strLECList & "<tr>"
	strLECList = strLECList & "<td colspan='4' height='1' bgcolor='#E4E4E4'></td>"
	strLECList = strLECList & "</tr>"
End If
objRs.Close


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
</head>
<body>

<!-- #include virtual = "/inc/inc_frame/top.asp" -->

<div id="content">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	<td class="sub_tab">
		<table border="0" cellspacing="0" cellpadding="0">
		<tr>
		<td style="padding:0 0 0 10px;"><b><a href="/myroom/lecture.asp"><%=langage(420)%></a></b></td>
		</tr>
		</table>
	</td>
	</tr>
	</table>
	<div class="bot_10"></div>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	<td align="center">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#666666">
		<td width="49%" height="40" align="center"><a href="/myroom/lecture.asp"><span class="box_btn25_auto" style="padding:0 10px 0 10px;"><font color="#FF8C00"><b><%=langage(420)%></b></font></span></a></td>
		<td width="1%"><img src="/img/main/sub_tt_divide.gif" width="5" height="20" /></td>
		<td width="50%" align="center"><a href="/myroom/order_info.asp"><span class="box_btn25_auto" style="padding:0 10px 0 10px;"><%=langage(478)%></span></a></td>
		</tr>
		</table>
	</td>
	</tr>
	</table>
	<div class="bot_10"></div>


	<div>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	<td colspan="4" bgcolor="#E5E3E3" height="1"></td>
	</tr>
	<tr bgcolor="#F5F5F5" height="50" align="center">
	<td width="10%" align="center" style="font-weight:bold;"><%=langage(585)%></td>
	<td width="15%" align="center" style="font-weight:bold;"><%=langage(609)%></td>
	<td width="60%" align="center" style="font-weight:bold;"><%=langage(536)%></td>
	<td width="15%" align="center" style="font-weight:bold;"><%=langage(649)%></td>
	</tr>
	<tr>
	<td colspan="4" bgcolor="#E5E3E3" height="1"></td>
	</tr>
	<%=strLECList%>
	</table>
    </div>

	<form method="post" name="form">
	<input type="hidden" name="CLASS_CODE">
	<input type="hidden" name="OID">
	<input type="hidden" name="clsCode">
	</form>

</div>
<div class="bot_20"></div>
<!-- #include virtual = "/INC/INC_Frame/bottom.asp" -->
</body>
</html>