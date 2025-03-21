<!-- trunk/user/www/dial_log.asp -->
<div class="setup-inner">
    <h2>拨号状态监控</h2>
    <div id="log-container" style="height:400px;overflow:auto;">
        <pre id="real-time-log"></pre>
    </div>
    <div class="btn-group">
        <button onclick="clearLog()" class="btn">清空日志</button>
    </div>
</div>

<script>
function updateLog() {
    $.ajax({
        url: "/dial_log.txt",
        success: function(data) {
            $("#real-time-log").html(data);
            $("#log-container").scrollTop($("#log-container").scrollHeight);
        }
    });
}
setInterval(updateLog, 2000);
</script>