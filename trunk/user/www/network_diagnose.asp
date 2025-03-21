<!-- trunk/user/www/network_diagnose.asp -->
<div class="setup-inner">
    <!-- 状态指示灯 -->
    <div class="status-light" id="statusLight">
        <span class="dot"></span>
        <span id="statusText">检测中...</span>
    </div>

    <!-- Ping测试模块 -->
    <div class="ping-box">
        <input type="text" id="pingTarget" value="www.baidu.com" placeholder="输入IP/域名">
        <button onclick="startPing()" class="btn">开始Ping测试</button>
        <pre id="pingResult"></pre>
    </div>
</div>

<style>
/* 状态指示灯样式 */
.status-light {
    margin: 20px 0;
    text-align: center;
}
.dot {
    display: inline-block;
    width: 16px;
    height: 16px;
    border-radius: 50%;
    margin-right: 10px;
}
.connected .dot { background: #4CAF50; }
.disconnected .dot { background: #F44336; }
#pingResult {
    background: #f5f5f5;
    padding: 10px;
    margin-top: 10px;
}
</style>

<script>
// 实时更新网络状态
function updateNetworkStatus() {
    $.ajax({
        url: '/cgi-bin/network_status',
        success: function(res) {
            const isOnline = res.trim() === 'connected';
            $('#statusLight').toggleClass('connected', isOnline)
                .toggleClass('disconnected', !isOnline);
            $('#statusText').text(isOnline ? '路由器已联网' : '路由器未联网');
        }
    });
}

// Ping测试功能
function startPing() {
    const target = $('#pingTarget').val();
    $('#pingResult').html('正在测试...');
    
    $.ajax({
        url: '/cgi-bin/ping_test?target=' + encodeURIComponent(target),
        success: function(data) {
            $('#pingResult').text(data.replace(/</g,'&lt;'));
        }
    });
}

// 每30秒自动更新状态
setInterval(updateNetworkStatus, 30000);
$(document).ready(updateNetworkStatus);
</script>