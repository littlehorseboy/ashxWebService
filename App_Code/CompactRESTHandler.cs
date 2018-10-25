using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

/// <summary>
/// CompactRESTHandler 的摘要描述
/// </summary>
public abstract class CompactRESTHandler<T> : IHttpHandler where T : new()
{
    public CompactRESTHandler()
    {
        //
        // TODO: 在這裡新增建構函式邏輯
        //
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

    protected static bool IsNullOrEmpty(T item)
    {
        return EqualityComparer<T>.Default.Equals(item, default(T));
    }

    public void ProcessRequest(HttpContext context)
    {
        var args = new Dictionary<string, string>();
        JavaScriptSerializer jss = new JavaScriptSerializer();

        foreach (var key in context.Items.Keys)
        {
            args.Add(key.ToString(), Convert.ToString(context.Items[key]));
        }

        // 傳回 JSON 內容的共用方法
        Action<object, int> dumpDataJsonWithStatusCode = (data, statusCode) =>
        {
            if (statusCode > 0)
            {
                context.Response.StatusCode = statusCode;
            }

            context.Response.ContentType = "application/json; charset=utf-8";
            context.Response.Write(jss.Serialize(data));
        };

        Action<object> dumpDataJson = (data) =>
        {
            dumpDataJsonWithStatusCode(data, 0);
        };

        // 傳回特定 Status Code 的共用方法
        Action<int, string> returnHttpStatus = (statusCode, content) =>
        {
            context.Response.StatusCode = statusCode;
            if (!string.IsNullOrEmpty(content))
            {
                context.Response.Write(content);
            }
        };

        // 由 HttpMethod 及參數決定呼叫何種方法
        string httpMethod = context.Request.HttpMethod;
        // 除了 GET 以外, POST/PUT/DELETE, Request 的文本內容應為資料物件 JSON
        // 此將其反序列化回 .NET 端的物件
        T item = default(T);
        if (httpMethod != "GET")
        {
            // 檢查 ContentType 必須為 application/json, 確保 Client 端明確知道要傳 JSON
            if (!context.Request.ContentType.StartsWith("application/json"))
            {
                throw new ArgumentException("ContentType is not application/json");
            }
            try
            {
                // 理論上還要依 ContentType 的 charset 決定 Encoding, 在此偷懶省略
                using (StreamReader sr = new StreamReader(context.Request.InputStream))
                {
                    string jsonString = sr.ReadLine();
                    item = (T)jss.Deserialize<T>(jsonString);
                }
            }
            catch (Exception ex)
            {
                throw new ArgumentException("Failed to parse JSON string");
            }
        }

        try
        {
            switch (httpMethod)
            {
                case "GET": // GetList 及 GetItem 由是否提供 Id 來區分
                    if (args.ContainsKey("id"))
                    {
                        item = GetItem(args);

                        if (IsNullOrEmpty(item))
                        {
                            returnHttpStatus(404, "Not Found");
                        }
                        else
                        {
                            dumpDataJson(item);
                        }
                    }
                    else
                    {
                        dumpDataJson(GetList(args));
                    }
                    break;
                case "POST":
                    // 傳回 HTTP 201 Created
                    dumpDataJsonWithStatusCode(CreateItem(item), 201);
                    // 加上 Response Header - Location
                    context.Response.AddHeader("Location", GetCreateLocationHeader(item));
                    break;
                case "PUT":
                    UpdateItem(item);
                    break;
                case "DELETE":
                    DeleteItem(item);
                    break;
            }
        }
        catch (Exception ex)
        {
            dumpDataJsonWithStatusCode(ex.Message, 500);
        }
    }

    // 查詢取得物件集合
    public abstract List<T> GetList(Dictionary<string, string> args);
    // 取得特定資料物件
    public abstract T GetItem(Dictionary<string, string> args);
    // 新增資料 (需回傳新增成功的資料物件)
    public abstract T CreateItem(T item);
    // 傳回新增資料後的 Location Response Header
    public abstract string GetCreateLocationHeader(T item);
    // 更新資料
    public abstract void UpdateItem(T item);
    // 刪除資料
    public abstract void DeleteItem(T item);
}