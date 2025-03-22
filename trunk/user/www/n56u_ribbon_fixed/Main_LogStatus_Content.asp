<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - 系统日志</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script>
var $j = jQuery.noConflict();

// 新增日志关键词翻译函数
function translateLog(logText) {
    var translations = {
        "kernel:": "内核:",
        "entered forwarding state": "进入转发状态",
        "AP-Client probe:": "无线探针:",
        "probe response:": "探针响应:",
        "LINK UP": "连接建立",
        "WAN up": "外网连接成功",
        "Server listening": "服务监听中",
        "ignoring nameserver": "忽略DNS服务器",
        "using nameserver": "使用DNS服务器",
        "Synchronizing time": "正在同步时间",
        "System time changed": "系统时间已变更",
        "DHCP WAN Client:": "DHCP客户端:",
        "starting on": "正在启动",
        "bound": "已绑定",
        "Load Ralink": "加载",
        "Timer Module": "定时器模块",
        "Storage save:": "存储操作:",
        "Invalid storage": "无效存储",
        "read /etc/hosts": "读取主机文件",
        "read /etc/storage": "读取存储配置"
    };
    
    Object.keys(translations).forEach(function(key) {
        var regex = new RegExp(key, "g");
        logText = logText.replace(regex, translations[key]);
    });
    return logText;
}

$j(document).ready(function(){
    // 日志加载后自动翻译
    var textArea = E('textarea');
    var originalLog = textArea.value;
    textArea.value = translateLog(originalLog);
    textArea.scrollTop = textArea.scrollHeight;
});

function initial(){
    show_banner(2);
    show_menu(5,10,1);
    show_footer();
    showclock();
}

// 修改时间显示格式
function showclock(){
    JS_timeObj.setTime(systime_millsec);
    systime_millsec += 1000;
    JS_timeObj2 = JS_timeObj.toLocaleString('zh-CN', { 
        weekday: 'short',
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZoneName: 'short'
    }) + " 北京时间" + timezone;
    $("system_time").innerHTML = JS_timeObj2;
    setTimeout("showclock()", 1000);
}

function clearLog(){
    document.form.next_host.value = location.host;
    document.form.action_mode.value = " ClearLog ";
    document.form.submit();
}
</script>
<style>
/* 优化中文显示 */
textarea {
    font-family: 'Microsoft YaHei', '宋体', monospace !important;
    font-size: 14px !important;
    line-height: 1.5;
}
.alert-info { font-weight: bold; }
.nav-tabs > li > a {
    padding-right: 6px;
    padding-left: 6px;
}
</style>
</head>

<body onload="initial();">

<div class="wrapper">
    <div class="container-fluid" style="padding-right: 0px">
        <div class="row-fluid">
            <div class="span3"><center><div id="logo"></div></center></div>
            <div class="span9" >
                <div id="TopBanner"></div>
            </div>
        </div>
    </div>

    <div id="Loading" class="popup_bg"></div>

    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
    <form method="post" name="form" action="apply.cgi" class="form_thin">
    <input type="hidden" name="current_page" value="Main_LogStatus_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span3">
                <!--Sidebar content-->
                <!--=====Beginning of Main Menu=====-->
                <div class="well sidebar-nav side_nav" style="padding: 0px;">
                    <ul id="mainMenu" class="clearfix"></ul>
                    <ul class="clearfix">
                        <li>
                            <div id="subMenu" class="accordion"></div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="span9">
                <!--Body content-->
                <div class="row-fluid">
                    <div class="span12">
                        <div class="box well grad_colour_dark_blue">
                            <h2 class="box_head round_top">系统状态 - 系统日志</h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <td colspan="3" style="border-top: 0 none; padding-bottom: 0px;">
                                                <b>系统时间:</b><span class="alert alert-info" style="margin-left: 10px; padding-top: 4px; padding-bottom: 4px;" id="system_time"></span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="border-top: 0 none; padding-bottom: 0px;">
                                                <textarea rows="21" class="span12" style="height:377px;" readonly="readonly" wrap="off" id="textarea"><% nvram_dump("syslog.log",""); %></textarea>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="15%" style="text-align: left; padding-bottom: 0px;">
                                                <input type="submit" onClick="clearLog();" value="清除日志" class="btn btn-info" style="width: 170px">
                                            </td>
                                            <td width="15%" style="text-align: left; padding-bottom: 0px;">
                                                <input type="button" onClick="location.href='syslog.txt'" value="保存日志" class="btn btn-success" style="width: 170px">
                                            </td>
                                            <td style="text-align: right; padding-bottom: 0px;">
                                                <input type="button" onClick="location.href=location.href" value="刷新页面" class="btn btn-primary" style="width: 219px">
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    </form>

    <div id="footer"></div>
</div>
</body>
</html>
