<%@ WebHandler Language="C#" Class="BlahHandler" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;

public class BlahEntry
{
    public string Key { get; set; }
    public string Value { get; set; }
    public BlahEntry() { }
    public BlahEntry(string key, string value)
    {
        Key = key;
        Value = value;
    }
}

public class BlahHandler : CompactRESTHandler<BlahEntry>
{
    static List<BlahEntry> dataStore = new List<BlahEntry>();
    static BlahHandler() // 預設放入兩筆資料
    {
        dataStore.Add(new BlahEntry("Github", "https://github.com/"));
        dataStore.Add(new BlahEntry("Author", "horse"));
    }

    // 清單查詢 API, 直接傳回結果
    public override List<BlahEntry> GetList(Dictionary<string, string> args)
    {
        return dataStore;
    }

    // 使用 LINQ 查詢特定 Key 值內容
    private BlahEntry GetItem(string key)
    {
        return dataStore.SingleOrDefault(o => string.Compare(o.Key, key, true) == 0);
    }

    // 查詢特定資料 API
    public override BlahEntry GetItem(Dictionary<string, string> args)
    {
        return GetItem(args["id"]);
    }

    // 新增資料 API
    public override BlahEntry CreateItem(BlahEntry item)
    {
        dataStore.Add(item);
        return GetItem(item.Key);
    }

    // 更新資料 API
    public override void UpdateItem(BlahEntry item)
    {
        var toUpdate = GetItem(item.Key);
        if (!IsNullOrEmpty(toUpdate))
        {
            // 使用 Remove + Add 模擬 Update
            dataStore.Remove(toUpdate);
            dataStore.Add(item);
        }
        else
        {
            throw new ApplicationException("Cannot find the data to update!");
        }
    }

    // 刪除資料 API
    public override void DeleteItem(BlahEntry item)
    {
        var toDelete = GetItem(item.Key);
        if (!IsNullOrEmpty(toDelete))
        {
            dataStore.Remove(toDelete);
        }
        else
        {
            throw new ApplicationException("Cannot find the data to delete!");
        }
    }

    // 新增資料時, 傳回剛才新增資料之 URI
    public override string GetCreateLocationHeader(BlahEntry item)
    {
        return "api/Blah/" + item.Key;
    }
}