<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<script runat="server">
    void Page_Load(object sender, EventArgs e)
    {
        string testItem = Request["test"];
        if (!string.IsNullOrEmpty(testItem))
        {
            // 測試1, 顯示 HTTP Method
            if (testItem == "method")
            {
                Response.Write("HttpMethod=" + Request.HttpMethod);
            }
            // 測試2, 傳回 HTTP 404
            else if (testItem == "404")
            {
                Response.StatusCode = 404;
            }
            // 測試3, 傳回 HTTP 201 及 Location header
            else if (testItem == "201")
            {
                Response.StatusCode = 201;
                Response.AppendHeader("Location", "https://github.com/");
            }
            // 測試4, 故意引發錯, 傳回 ASP.NET 預設錯誤頁
            else if (testItem == "error")
            {
                throw new ApplicationException("錯誤");
            }
            else if (testItem == "errorInfo")
            {
                Response.StatusCode = 500;
            }
            Response.End();
        }
    }
</script>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        測試項目: 
    <select id="selTestItem">
        <option value="method">DELETE Method</option>
        <option value="404">傳回404</option>
        <option value="201">傳回201及Header</option>
        <option value="error">發生錯誤</option>
        <option value="errorInfo">解析錯誤</option>
    </select>
        <input type="button" id="btnGet" value="直接瀏覽" />
        <input type="button" id="btnAjax" value="AJAX存取" />
        <hr />
        <div id="dvStatus"></div>
        <iframe id="frmShow" style="width: 800px; height: 600px"></iframe>
    </form>
    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
    <script>
        var selTestItem = document.querySelector('#selTestItem');
        var frmShow = document.querySelector('#frmShow');
        var btnGet = document.querySelector('#btnGet');
        btnGet.addEventListener('click', function () {
            frmShow.setAttribute('src', '?test=' + selTestItem.value);
        });

        var dvStatus = document.querySelector('#dvStatus');
        var btnAjax = document.querySelector('#btnAjax');
        btnAjax.addEventListener('click', function () {
            dvStatus.innerHTML = '';
            axios({
                method: 'get',
                url: '?test=' + selTestItem.value,
            })
                .then(function (response) {
                    if (response.status === 200) {
                        dvStatus.innerHTML = response.data;
                    } else if (response.status === 201) {
                        dvStatus.innerHTML = JSON.stringify(response.headers, null, 4);
                    }
                }).catch(function (error) {
                    if (error.response) {
                        if (error.response.status === 404) {
                            dvStatus.innerHTML = error.response.data;
                        } else if (error.response.status === 500) {
                            dvStatus.innerHTML = error.response.data;
                        }
                    } else if (error.request) {
                        // The request was made but no response was received
                        // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
                        // http.ClientRequest in node.js
                        console.log(error.request);
                    } else {
                        // Something happened in setting up the request that triggered an Error
                        console.log('Error', error.message);
                    }
                    console.log(error.config);
                });
        });
    </script>
</body>
</html>
