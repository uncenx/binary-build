# Migration: Segment 6s → 2s + CF-Ray Logging + เปลี่ยนโดเมน Cloudflare

## สิ่งที่เปลี่ยนใน install.sh

| # | จุดที่แก้ | ก่อน | หลัง |
|---|----------|------|------|
| 1 | Segment Duration | `SEGMENT_DUR:-4` (หรือ 6) | `SEGMENT_DUR:-2` |
| 2 | VOD log format | ไม่มี cf_ray | เพิ่ม `cf_ray:$http_cf_ray` |
| 3 | Public log format | ไม่มี | เพิ่ม `public_log` format + cf_ray |
| 4 | Public access_log | ไม่ใช้ named format | ใช้ `public_log` format |

---

## Step 1: Deploy Config ใหม่บน Server

### วิธี A: รัน install.sh ใหม่ (แนะนำ — ง่ายสุด)
```bash
ssh root@95.216.114.182
# upload install.sh ใหม่แล้วรัน
bash install.sh
```

### วิธี B: แก้ config ด้วยมือ (ถ้าไม่อยาก rebuild module)
```bash
ssh root@95.216.114.182

# 1. แก้ segment duration
sed -i 's/vod_segment_duration [0-9]*;/vod_segment_duration 2000;/' /etc/nginx/nginx.conf

# 2. แก้ log format — เพิ่ม cf_ray ใน nginx.conf
# เปลี่ยนบรรทัด log_format vod_log เป็น:
#   log_format vod_log '$remote_addr "$request" $status vod:$vod_status cf_ray:$http_cf_ray';
# เพิ่ม format ใหม่:
#   log_format public_log '$remote_addr "$request" $status $body_bytes_sent '
#                         '"$http_referer" "$http_user_agent" cf_ray:$http_cf_ray';

# 3. แก้ local.conf — ใช้ public_log format
# เปลี่ยน: access_log /var/log/nginx/public.log;
# เป็น:   access_log /var/log/nginx/public.log public_log;
```

## Step 2: Clear Cache + Restart

```bash
rm -rf /var/cache/nginx/vod/*
nginx -t
systemctl restart nginx
```

## Step 3: ตรวจสอบ Segment = 2s

```bash
# เช็ค vod_status — cache ควรเป็น 0
curl http://127.0.0.1:8889/vod_status

# ดู segment duration ใน playlist
curl http://127.0.0.1:8889/hls/<ชื่อไฟล์>.json/index-v1-a1.m3u8 | head -20
# #EXTINF: ควรจะประมาณ 2.xxx
```

## Step 4: Purge Cloudflare Cache (โดเมนเก่า)

1. เข้า [Cloudflare Dashboard](https://dash.cloudflare.com)
2. เลือก Domain เก่า
3. **Caching** → **Configuration** → **Purge Everything**

## Step 5: ตั้งโดเมนใหม่ใน Cloudflare

### 5.1 Add Site
- Cloudflare Dashboard → **Add a Site** → ใส่โดเมนใหม่
- เลือก Plan → เปลี่ยน Nameserver ตามที่ Cloudflare บอก

### 5.2 DNS Record
| Type | Name | Content | Proxy |
|------|------|---------|-------|
| A | `@` หรือ subdomain | `95.216.114.182` | ☁️ Proxied |

### 5.3 SSL/TLS
- **SSL/TLS** → เลือก **Full** หรือ **Full (strict)**

### 5.4 Cache Rules (แนะนำ)

| ไฟล์ | Cache | TTL |
|------|-------|-----|
| `*.m3u8` | ไม่ cache หรือ 1-5 min | สั้น |
| `*.ts` / `*.jpeg` | Cache | 1 year |
| `*.jpg` (thumb) | Cache | 1 year |

### 5.5 อัปเดต Nginx server_name
```bash
sed -i 's/server_name _;/server_name newdomain.com;/' /etc/nginx/conf.d/local.conf
nginx -t && systemctl reload nginx
```

## Step 6: ทดสอบ

```bash
curl -I https://newdomain.com/healthz
# ควรได้ 200 OK

curl https://newdomain.com/<ชื่อไฟล์>/master.m3u8
# ควรได้ playlist กลับมา
```

## Step 7: อัปเดต Application

- เปลี่ยน URL streaming จากโดเมนเก่า → ใหม่
- เปลี่ยน prewarm URL (ถ้ามี)

---

## Checklist

- [ ] Deploy config ใหม่ (segment 2s + cf_ray log)
- [ ] Clear cache + restart nginx
- [ ] ตรวจสอบ segment = 2s
- [ ] Purge Cloudflare cache (โดเมนเก่า)
- [ ] เพิ่มโดเมนใหม่ + DNS + SSL
- [ ] ตั้ง Cache Rules
- [ ] อัปเดต server_name
- [ ] ทดสอบผ่านโดเมนใหม่
- [ ] อัปเดต URL ในแอป
