<!DOCTYPE html>
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">

<style>
.network-status {
    padding: 8px 15px;
    border-radius: 4px;
    font-weight: bold;
    display: inline-block;
    margin-top: 5px;
}
.status-connected {
    background-color: #dff0d8;
    color: #3c763d;
    border: 1px solid #d6e9c6;
}
.status-disconnected {
    background-color: #f2dede;
    color: #a94442;
    border: 1px solid #ebccd1;
}
.status-checking {
    background-color: #d9edf7;
    color: #31708f;
    border: 1px solid #bce8f1;
}
</style>

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="formcontrol.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script>

<% wanlink(); %>

var $j = jQuery.noConflict();
var id_update_wanip = 0;
var checkInterval = 30000; // 30秒检测间隔
var networkCheckTimer = null;
var last_bytes_rx = 0;
var last_bytes_tx = 0;
var last_time = 0;

window.performance = window.performance || {};
performance.now = (function() {
    return performance.now ||
    performance.mozNow ||
    performance.msNow ||
    performance.oNow ||
    performance.webkitNow ||
    function() { return new Date().getTime(); };
})();

function initial(){
    flash_button();

    if(!support_usb())
        $j("#domore")[0].remove(6);

    if(sw_mode == '4'){
        $j("#domore")[0].remove(4);
        $j("#domore")[0].remove(3);
    }

    if(!support_ipv6())
        $j("#domore")[0].remove(2);

    if(typeof parent.modem_devnum === 'function'){
        if(parent.modem_devnum().length > 0)
            $("row_modem_prio").style.display = "";
    }

    fill_info();
    id_update_wanip = setTimeout("update_wanip();", 2500);
    
    // 初始化网络检测
    startNetworkCheck();
}

//=============== 新增网络检测逻辑 ===============//
var isChecking = false; // 检测锁

function startNetworkCheck() {
    // 立即执行首次检测
    update_network_status();
    // 设置周期性检测
    networkCheckTimer = setInterval(update_network_status, checkInterval);
}

function stopNetworkCheck() {
    clearInterval(networkCheckTimer);
}

function update_network_status(){
    if(isChecking) return;
    isChecking = true;
    
    var scode = wanlink_status();
    var statusElement = document.getElementById('router-status-text');
    var statusDiv = document.getElementById('network-status');
    
    statusElement.textContent = '正在检测互联网...';
    statusDiv.className = 'network-status status-checking';
    
    // 三阶段检测
    checkBaidu().then(() => {
        setConnectedStatus(statusElement, statusDiv);
    }).catch(() => {
        checkQQ().then(() => {
            setConnectedStatus(statusElement, statusDiv);
        }).catch(() => {
            checkPublicIP().then(() => {
                setConnectedStatus(statusElement, statusDiv);
            }).catch(() => {
                setDisconnectedStatus(statusElement, statusDiv);
            });
        });
    }).finally(() => {
        isChecking = false;
    });
}

function checkBaidu() {
    return new Promise((resolve, reject) => {
        $j.ajax({
            url: 'https://www.baidu.com/favicon.ico',
            method: 'HEAD',
            timeout: 3000,
            success: resolve,
            error: reject
        });
    });
}

function checkQQ() {
    return new Promise((resolve, reject) => {
        const img = new Image();
        img.onload = resolve;
        img.onerror = reject;
        img.src = 'https://www.qq.com/favicon.ico?_=' + Date.now();
    });
}

function checkPublicIP() {
    return new Promise((resolve, reject) => {
        $j.ajax({
            url: 'http://icanhazip.com',
            timeout: 3000,
            success: resolve,
            error: reject
        });
    });
}

function setConnectedStatus(element, div) {
    element.textContent = '路由器已联网（互联网访问正常）';
    div.className = 'network-status status-connected';
}

function setDisconnectedStatus(element, div) {
    element.textContent = '路由器未联网（无互联网访问）';
    div.className = 'network-status status-disconnected';
}

function submitInternet(v){
    parent.showLoading();
    document.internetForm.action = "wan_action.asp";
    document.internetForm.wan_action.value = v;
    document.internetForm.modem_prio.value = $("modem_prio").value;
    document.internetForm.submit();
}

</script>
</head>

<body class="body_iframe" onload="initial();">
<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table" id="tbl_info">
  <tr>
    <th width="50%" style="border-top: 0 none;"><#InetControl#></th>
    <td style="border-top: 0 none;" colspan="3">
      <input type="button" id="btn_connect_1" class="btn btn-info" value="<#Connect#>" onclick="submitInternet('Connect');">
      <input type="button" id="btn_connect_0" class="btn btn-danger" value="<#Disconnect#>" onclick="submitInternet('Disconnect');">
    </td>
  </tr>
  <tr id="row_modem_prio" style="display:none">
    <th><#ModemPrio#></th>
    <td colspan="3">
        <select id="modem_prio" class="input" style="width: 260px;" onchange="submitInternet('ModemPrio');">
            <option value="0" <% nvram_match_x("", "modem_prio", "0", "selected"); %>><#ModemPrioItem0#></option>
            <option value="1" <% nvram_match_x("", "modem_prio", "1", "selected"); %>><#ModemPrioItem1#></option>
            <option value="2" <% nvram_match_x("", "modem_prio", "2", "selected"); %>><#ModemPrioItem2#></option>
        </select>
    </td>
  </tr>
  <tr id="row_link_ether" style="display:none">
    <th><#SwitchState#></th>
    <td colspan="3"><span id="WANEther"></span></td>
  </tr>
  <tr id="row_link_apcli" style="display:none">
    <th><#InetStateWISP#></th>
    <td colspan="2"><span id="WANAPCli"></span></td>
    <td width="40px" style="text-align: right; padding: 6px 8px"><button type="button" class="btn btn-mini" style="height: 21px; outline:0;" title="<#Connect#>" onclick="submitInternet('WispReassoc');"><i class="icon icon-refresh"></i></button></td>
  </tr>
  <tr>
    <th><#ConnectionStatus#></th>
    <td id="wan_status" colspan="3"></td>
  </tr>
  <tr>
    <th><#Connectiontype#>:</th>
    <td colspan="3"><span id="WANType"></span></td>
  </tr>
  <tr id="row_uptime" style="display:none">
    <th><#WAN_Uptime#></th>
    <td colspan="3"><span id="WANTime"></span></td>
  </tr>
  <tr id="row_dltime" style="display:none">
    <th><#WAN_Lease#></th>
    <td colspan="3"><span id="WANLease"></span></td>
  </tr>
  <tr id="row_bytes" style="display:none">
    <th><#WAN_Bytes#></th>
    <td width="90px"><span id="WANBytesRX"></span></td>
    <td colspan="2"><span id="WANBytesTX"></span></td>
  </tr>
  <tr id="row_brate" style="display:none">
    <th><#WAN_BRate#></th>
    <td width="90px"><span id="WANBRateRX"></span></td>
    <td colspan="2"><span id="WANBRateTX"></span></td>
  </tr>
  <tr>
    <th><#IP4_Addr#> WAN:</th>
    <td colspan="3"><span id="WANIP4"></span></td>
  </tr>
  <tr id="row_man_ip4" style="display:none">
    <th><#IP4_Addr#> MAN:</th>
    <td colspan="3"><span id="MANIP4"></span></td>
  </tr>
  <tr id="row_wan_ip6" style="display:none">
    <th><#IP6_Addr#> WAN:</th>
    <td colspan="3"><span id="WANIP6"></span></td>
  </tr>
  <tr id="row_lan_ip6" style="display:none">
    <th><#IP6_Addr#> LAN:</th>
    <td colspan="3"><span id="LANIP6"></span></td>
  </tr>
  <tr>
    <th><#Gateway#> WAN:</th>
    <td colspan="3"><span id="WANGW4"></span></td>
  </tr>
  <tr id="row_man_gw4" style="display:none">
    <th><#Gateway#> MAN:</th>
    <td colspan="3"><span id="MANGW4"></span></td>
  </tr>
  <tr>
    <th>DNS:</th>
    <td colspan="3"><span id="WANDNS"></span></td>
  </tr>
  <tr>
    <th><#MAC_Address#></th>
    <td colspan="3"><span id="WANMAC"></span></td>
  </tr>
  <!-- 新增网络诊断行 -->
  <tr id="row_network_status">
    <th>网络诊断</th>
    <td colspan="3">
      <div id="network-status" class="network-status">
        <span id="router-status-text"></span>
      </div>
    </td>
  </tr>
  <tr id="row_more_links">
    <td style="padding-bottom: 0px;">&nbsp;</td>
    <td style="padding-bottom: 0px;" colspan="3">
        <select id="domore" class="domore" style="width: 260px;" onchange="domore_link(this);">
          <option selected="selected"><#MoreConfig#>...</option>
          <option value="../Advanced_WAN_Content.asp"><#menu5_3_1#></option>
          <option value="../Advanced_IPv6_Content.asp"><#menu5_3_3#></option>
          <option value="../Advanced_VirtualServer_Content.asp"><#menu5_3_4#></option>
          <option value="../Advanced_Exposed_Content.asp"><#menu5_3_5#></option>
          <option value="../Advanced_DDNS_Content.asp"><#menu5_3_6#></option>
          <option value="../Advanced_Modem_others.asp"><#menu5_4_4#></option>
          <option value="../vpnsrv.asp"><#menu2#></option>
          <option value="../vpncli.asp"><#menu6#></option>
        </select>
    </td>
  </tr>
</table>

<form method="post" name="internetForm" action="">
<input type="hidden" name="wan_action" value="">
<input type="hidden" name="modem_prio" value="">
</form>

</body>
</html>
