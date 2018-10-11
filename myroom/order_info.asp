<!-- #include virtual = "/inc/inc_function/Func_Connect.asp" -->
<!-- #include virtual = "/inc/inc_function/Func_Global.asp" -->
<%
Call OUTPUT_COOKIES()
Call DB_OPEN()
Response.Cookies("productInfo")("CLASS_CODE") = ""
Response.Cookies("productInfo")("OID") = ""

BOARD = "_ORDER_B2C"
SQL = "SELECT * FROM " & BOARD & " WHERE UID='" & COOKIE_UID & "' ORDER BY SEQ DESC"
objRs.Open SQL, Dbcon, 1
If Not objRs.EOF Then
	Counter = 1
	While Not objRs.EOF
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
		End If

		If objRs("PAY_TYPE") = "SC0010" Then PAY_TYPE = "신용카드" End If
		If objRs("PAY_TYPE") = "SC0030" Then PAY_TYPE = "계좌이체" End If
		If objRs("PAY_TYPE") = "SC0060" Then PAY_TYPE = "휴대폰" End If
		If objRs("PAY_TYPE") = "BANK" Then PAY_TYPE = "무통장입금" End If

		PAY_DATE = LEFT(objRs("PAY_DATE"),10)
		If STATE = "wait" Then
			PAY_DATE = "·" 
			STATE_TXT = langage(663)
		Elseif STATE = "ing" Then
			STATE_TXT = langage(664)
		Elseif STATE = "end" Then
			STATE_TXT = langage(665)
		ElseIf STATE = "cancel" Then 
			STATE_TXT = langage(666)
		End If

		strB2C = strB2C & "<tr height='50' bgcolor='#FFFFFF'>"
		strB2C = strB2C & "<td align='center'>" & Counter & "</td>"
		strB2C = strB2C & "<td align='center'>" & a_mode_txt & "</td>"
		strB2C = strB2C & "<td style='padding:0 0 0 10px;'>" & objRs("LEC_NAME") & "</td>"
		strB2C = strB2C & "<td align='center'>"& PAY_DATE & "</td>"
		strB2C = strB2C & "<td align='center'>" & FormatNumber(objRs("PRICE"),0) &" "& langage(607)&"</td>"
		strB2C = strB2C & "</tr>"

		strB2C = strB2C & "<tr>"
		strB2C = strB2C & "<td colspan='6' height='1' bgcolor='#E4E4E4'></td>"
		strB2C = strB2C & "</tr>"


	objRs.MoveNext
	Counter = Counter + 1
Wend
Else
		strB2C = strB2C & "<tr>"
		strB2C = strB2C & "<td colspan='6' height='50' bgcolor='#FFFFFF' align='center'>"&langage(569)&"</td>"
		strB2C = strB2C & "</tr>"
		strB2C = strB2C & "<tr>"
		strB2C = strB2C & "<td colspan='6' height='1' bgcolor='#E4E4E4'></td>"
		strB2C = strB2C & "</tr>"
End If
objRs.Close


BOARD = "_ORDER_BOOK"
SQL = "SELECT * FROM " & BOARD & " WHERE UID='" & COOKIE_UID & "' ORDER BY SEQ DESC"
objRs.Open SQL, Dbcon, 1
If Not objRs.EOF Then
	Counter = 1
	While Not objRs.EOF
		BOOK_CODE = objRs("BOOK_CODE")
		BOOK_NAME = objRs("BOOK_NAME")
		OID = objRs("OID")

		If objRs("PAY_TYPE") = "SC0010" Then PAY_TYPE = "신용카드" End If
		If objRs("PAY_TYPE") = "SC0030" Then PAY_TYPE = "계좌이체" End If
		If objRs("PAY_TYPE") = "SC0060" Then PAY_TYPE = "휴대폰" End If
		If objRs("PAY_TYPE") = "BANK" Then PAY_TYPE = "무통장입금" End If


		PAY_DATE = LEFT(objRs("PAY_DATE"),10)
		If STATE = "wait" Then
			PAY_DATE = "·" 
			STATE_TXT = langage(663)
		Elseif STATE = "ing" Then
			STATE_TXT = langage(664)
		Elseif STATE = "end" Then
			STATE_TXT = langage(665)
		ElseIf STATE = "cancel" Then 
			STATE_TXT = langage(666)
		End If


		strBOOK = strBOOK & "<tr height='50' bgcolor='#FFFFFF'>"
		strBOOK = strBOOK & "<td align='center'>" & Counter & "</td>"
		strBOOK = strBOOK & "<td style='padding:0 0 0 10px;'>" & objRs("BOOK_NAME") & "</td>"
'		strBOOK = strBOOK & "<td align='center'>" & Replace(Left(objRs("lec_start"),10),"-",".") & " ~ " & Replace(Left(objRs("lec_end"),10),"-",".") & "</td>"
		strBOOK = strBOOK & "<td align='center'>"& PAY_DATE & "</td>"
		strBOOK = strBOOK & "<td align='center'>" & FormatNumber(objRs("PRICE"),0) &" "&langage(607)& "</td>"
		strBOOK = strBOOK & "<td align='center'>" & STATE_TXT & "</td>"
		strBOOK = strBOOK & "</tr>"
		strBOOK = strBOOK & "<tr>"
		strBOOK = strBOOK & "<td colspan='6' height='1' bgcolor='#E4E4E4'></td>"
		strBOOK = strBOOK & "</tr>"

	objRs.MoveNext
	Counter = Counter + 1
	Wend
Else
		strBOOK = strBOOK & "<tr>"
		strBOOK = strBOOK & "<td colspan='6' height='50' bgcolor='#FFFFFF' align='center'>"&langage(569)&"</td>"
		strBOOK = strBOOK & "</tr>"
		strBOOK = strBOOK & "<tr>"
		strBOOK = strBOOK & "<td colspan='6' height='1' bgcolor='#E4E4E4'></td>"
		strBOOK = strBOOK & "</tr>"
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
		<td width="49%" height="40" align="center"><a href="/myroom/lecture.asp"><span class="box_btn25_auto" style="padding:0 10px 0 10px;"><%=langage(420)%></span></a></td>
		<td width="1%"><img src="/img/main/sub_tt_divide.gif" width="5" height="20" /></td>
		<td width="50%" align="center"><a href="/myroom/order_info.asp"><span class="box_btn25_auto" style="padding:0 10px 0 10px;"><font color="#FF8C00"><b><%=langage(478)%></b></font></span></a></td>
		</tr>
		</table>
	</td>
	</tr>
	</table>
	<div class="bot_10"></div>


	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
	<td height="25" style="padding:0 0 0 2px;"><font color="#FF8C00"><b><%=langage(552)%></b></font></td>
	</tr>
	</table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	<td colspan="6" bgcolor="#CCCCCC" height="1"></td>
	</tr>
	<tr bgcolor="#EAEAEA" height="50" align="center">
	<td width="10%" style="font-weight:bold;"><%=langage(585)%></td>
	<td width="15%" style="font-weight:bold;"><%=langage(609)%></td>
	<td width="35%" style="font-weight:bold;"><%=langage(536)%></td>
	<td width="20%" style="font-weight:bold;"><%=langage(554)%></td>
	<td width="20%" style="font-weight:bold;"><%=langage(555)%></td>
	</tr>
	<tr>
	<td colspan="6" bgcolor="#CCCCCC" height="1"></td>
	</tr>
	<%=strB2C%>
	</table>

	
	<div class="mt30"></div>

	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
	<td height="25" style="padding:0 0 0 2px;"><font color="#FF8C00"><b><%=langage(478)%></b></font></td>
	</tr>
	</table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	<td colspan="6" bgcolor="#CCCCCC" height="1"></td>
	</tr>
	<tr bgcolor="#EAEAEA" height="40" align="center">
	<td width="10%" style="font-weight:bold;"><%=langage(585)%></td>
	<td width="30%" style="font-weight:bold;"><%=langage(557)%></td>
	<td width="20%" style="font-weight:bold;"><%=langage(554)%></td>
	<td width="20%" style="font-weight:bold;"><%=langage(555)%></td>
	<td width="20%" style="font-weight:bold;"><%=langage(479)%></td>
	</tr>
	<tr>
	<td colspan="6" bgcolor="#CCCCCC" height="1"></td>
	</tr>
	<%=strBOOK%>
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