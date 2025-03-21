<!-- 新建 www/NetworkDiag.asp -->
<% css("/style/network-diag.css"); %>
<script>
function checkStatus() {
    xhr.get("/network_status", function(status) {
        document.getElementById("status-led").className = "led-" + status;
    });
    setTimeout(checkStatus, 5000);
}

function doCustomPing() {
    var target = encodeURIComponent(document.getElementById("ping-target").value);
    xhr.get("/ping.cgi?target=" + target, function(res) {
        document.getElementById("ping-results").innerHTML = res;
    });
}
</script>

<div class="network-diag">
    <h3>网络状态: <span id="status-led" class="led-<%= get_network_status() %>"></span></h3>
    <div class="ping-box">
        <input type="text" id="ping-target" value="www.baidu.com">
        <button onclick="doCustomPing()">Ping测试</button>
    </div>
    <pre id="ping-results"></pre>
</div>