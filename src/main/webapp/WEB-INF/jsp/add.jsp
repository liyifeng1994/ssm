<%@ page import="java.io.PrintWriter" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html>
<head>
    <meta content="text/html;charset=utf-8" http-equiv="Content-Type"/>
    <title>添加城市</title>
</head>
<body>
<div id= "cityinput">
  <form action="save" method="post">
	  城市:<input type="text" name="city"/><br />
	  价格<input type="text" name="price"/>
	  <input type="submit"/>
  </form>
</div>
<br />
<a href="../home.jsp">返回</a>
</body>
</html>