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
    <title>Book List</title>
    <link href="../css/bootstrap.min.css" type="text/css" rel="stylesheet" />
    <style type="text/css">
	　　A:link {
	　　color:blue; text－decoration: none
	　　}
	　　A:visited {
	　　color:red; text－decoration:line－through
	　　}
	　　A:active {
	　　color:white; text－decoration:underline
	　　}
	　　A:hover {
	　　color:yellow;text－decoration:none;background－color:black
	　　}
　　</style>
    <script src="../js/jquery.min.js" type="text/javascript"></script>
    <script src="../js/bootstrap.min.js" type="text/jscript"></script>
    <script type="text/javascript">
      function appointBook(id,studentId){
    	  $.ajax({
              url : "/ssm/book/"+id+"/appoint?studentId=1111",
              type : "POST",
              contentType : "application/json;charset=utf-8",
              success : function(result) {
                  if (result.success == true) {
                	  if(result.data){
                		  alert(result.data.stateInfo);
                	  }
                     location.reload();
                  } 
              },
              error:function(msg){
                  alert('Error!');
              }
          });
      };
      
    </script>
</head>
<body>
  <br/>
    <div class="box-123">
      <a id = "add" style='border-left: left' href='/book/add'>添加</a>
      <table class="table table-bordered">
         <tr>
             <th>ID</th>
             <th>书名</th>
             <th>库存量</th>
             <th>操作</th>
         </tr>
        <tbody id="cityCols">
		<c:forEach items="${list}" var="book">
			<tr>
			    <td>${book.bookId}</td>
				<td><a id = "add" target='_blank' href='/ssm/book/${book.bookId}/detail'  style='text-decoration:underline;'>${book.name}</a></td>
				<td>${book.number}</td>
				<td><button onclick='appointBook(${book.bookId},1111);'>预约</button></td>
			</tr>
		</c:forEach>
	   </tbody>        
     </table>
   </div>
</body>
</html>