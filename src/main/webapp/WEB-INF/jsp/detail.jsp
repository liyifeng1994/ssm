<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page isELIgnored="false"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD//XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8"/>
    <title>Book Detail</title>
    <link href="../../css/bootstrap.min.css" type="text/css" rel="stylesheet" />
    <script src="../../js/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/bootstrap.min.js" type="text/jscript"></script>
</head>
<body>
  <br/>
    <div class="box-123">
      <table class="table table-bordered">
         <tr>
             <th>图书详情</th>
             <th>..</th>
          </tr>
        <tbody id="cityCols">
          <tr>
            <td>书名</td>
            <td>${book.name}</td>
          </tr>
           <tr>
            <td>库存</td>
            <td>${book.number}</td>
          </tr>
           <tr>
            <td>简介</td>
            <td>${book.description}</td>
          </tr>
           <tr>
            <td>出版社</td>
            <td>${book.press}</td>
          </tr>
	   </tbody>        
     </table>
   </div>
</body>
</html>