// 新建文件 user/httpd/network_monitor.c
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>

#define STATUS_FILE "/tmp/network_status"

void update_network_status() {
    int ret = system("ping -c 1 220.181.38.148 >/dev/null 2>&1");
    FILE *fp = fopen(STATUS_FILE, "w");
    if (fp) {
        fprintf(fp, "%s\n", (ret == 0) ? "online" : "offline");
        fclose(fp);
    }
}

int main() {
    daemon(1, 0); // 后台运行
    while (1) {
        update_network_status();
        sleep(30); // 30秒检测一次
    }
    return 0;
}