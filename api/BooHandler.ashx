<%@ WebHandler Language="C#" Class="BooHandler" %>

using System;
using System.Web;

public class BooHandler : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        context.Response.ContentType = "text/plain";
        context.Response.Write("HttpMethod=" + context.Request.HttpMethod);
        context.Response.Write("{id}=" + context.Items["id"]);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}