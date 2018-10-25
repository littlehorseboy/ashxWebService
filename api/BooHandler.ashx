<%@ WebHandler Language="C#" Class="BooHandler" %>

using System;
using System.Web;
using System.Collections.Generic;
using Newtonsoft.Json;

public class BooHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "application/json";
        string httpMethod = context.Request.HttpMethod;
        string id = "";
        if (context.Items["id"] != null)
        {
            id = context.Items["id"].ToString();
        }

        List<Result> lstResult = new List<Result>();

        Result rlt = new Result() { httpMethod = httpMethod, id = id };

        lstResult.Add(rlt);

        string jsonData = JsonConvert.SerializeObject(lstResult);

        context.Response.Write(jsonData);
    }

    public class Result
    {
        public string httpMethod { get; set; }
        public string id { get; set; }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}