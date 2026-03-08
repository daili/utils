#!/bin/bash
#30 8-15 * * 1-5  bash $HOME/.utils/force_mode.sh off  > /tmp/force_mode.log 2>&1

#* 0-7  * * 1-5  bash $HOME/.utils/force_mode.sh on >/tmp/forcemode.log 2>&1
#0-29 8 *  * * 1-5  bash $HOME/.utils/force_mode.sh on >/tmp/forcemode.log 2>&1

#31-59 15 * * 1-5  $HOME/.utils/force_mode.sh on >/tmp/forcemode.log 2>&1
#* 16-23  * * 1-5  $HOME/.utils/force_mode.sh on >/tmp/forcemode.log 2>&1

#* *  * * 6,0  $HOME/.utils/force_mode.sh on >/tmp/forcemode.log 2>&1

MODE="$1"  # Accept "on" or "off" as the first argument

SOCIAL_MEDIA_SITES=(
  "facebook.com" "www.facebook.com"
  "youtube.com" "www.youtube.com"
  "instagram.com" "www.instagram.com"
  "tiktok.com" "www.tiktok.com"
  "twitter.com" "www.twitter.com"
  "discord.com" "www.discord.com"

  # Additional US social / community sites
  "reddit.com" "www.reddit.com"
  "snapchat.com" "www.snapchat.com"
  "pinterest.com" "www.pinterest.com"
  "linkedin.com" "www.linkedin.com"
  "tumblr.com" "www.tumblr.com"
  "nextdoor.com" "www.nextdoor.com"
  "medium.com" "www.medium.com"

  # Chinese social media / platforms
  "weibo.com" "www.weibo.com"
  "weixin.qq.com" "wechat.com" "www.wechat.com"
  "douyin.com" "www.douyin.com"
  "xiaohongshu.com" "www.xiaohongshu.com"
  "bilibili.com" "www.bilibili.com"
  "qq.com" "www.qq.com"
  "zhihu.com" "www.zhihu.com"
  "kuaishou.com" "www.kuaishou.com"
  "toutiao.com" "www.toutiao.com"
  "renren.com" "www.renren.com"
)

SHOPPING_SITES=(
  "amazon.com" "www.amazon.com"
  "ebay.com" "www.ebay.com"
  "aliexpress.com" "www.aliexpress.com"
  "walmart.com" "www.walmart.com"
  "etsy.com" "www.etsy.com"
  "shopify.com" "www.shopify.com"
  "myer.com.au" "www.myer.com.au"
  "davidjones.com" "www.davidjones.com"
  "kmart.com.au" "www.kmart.com.au"
  "target.com.au" "www.target.com.au"
  "temu.com" "www.temu.com"
  "muji.com" "www.muji.com"
  "mujistore.com.au" "www.mujistore.com.au"

  # Additional US shopping sites
  "target.com" "www.target.com"
  "bestbuy.com" "www.bestbuy.com"
  "costco.com" "www.costco.com"

  # Chinese e-commerce platforms
  "taobao.com" "www.taobao.com"
  "tmall.com" "www.tmall.com"
  "jd.com" "www.jd.com"
  "pinduoduo.com" "www.pinduoduo.com"
  "meituan.com" "www.meituan.com"
  "dianping.com" "www.dianping.com"
)

OTHER_SITES=(
  "netflix.com" "www.netflix.com"
  "stan.com.au" "www.stan.com.au"
  "primevideo.com" "www.primevideo.com"
  "primevideo.com.au" "www.primevideo.com.au"
  "disneyplus.com" "www.disneyplus.com"
  "binge.com.au" "www.binge.com.au"
  "hulu.com" "www.hulu.com"
  "tv.apple.com"
  "9now.com.au" "www.9now.com.au"
  "7plus.com.au" "www.7plus.com.au"
  "iview.abc.net.au"
  "dailymotion.com" "www.dailymotion.com"
  "twitch.tv" "www.twitch.tv"
  "vimeo.com" "www.vimeo.com"
  "aigua.tv" "www.aigua.tv"

  # Chinese streaming / video services
  "iqiyi.com" "www.iqiyi.com"
  "youku.com" "www.youku.com"
  "mgtv.com" "www.mgtv.com"
  "sohu.com" "www.sohu.com"
)

# Combine all categories for blocking
BLOCKED_SITES=("${SOCIAL_MEDIA_SITES[@]}" "${SHOPPING_SITES[@]}" "${OTHER_SITES[@]}")

DISTRACTING_APPS=(
  "Messages"
  "FaceTime"
  "Steam"
  "Discord"
  "Roblox"
  "Minecraft"
)

HOUR=$(date +%H)
MIN=$(date +%M)
TARGET_USER="lidai"

if [ "$MODE" = "on" ]; then
  blocked_any=false
  for site in "${BLOCKED_SITES[@]}"; do
    if ! grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null 2>&1; then
      echo "127.0.0.1 $site" >> /etc/hosts
      echo "[INFO] Blocked site: $site"
      blocked_any=true
    fi
  done

  quit_any=false
  for app in "${DISTRACTING_APPS[@]}"; do
    if [ "$app" = "Minecraft" ]; then
      if { [ "$HOUR" -lt 8 ] || [ "$HOUR" -gt 15 ] || { [ "$HOUR" -eq 15 ] && [ "$MIN" -ge 30 ]; }; }; then
        if pgrep -x "$app" > /dev/null; then
          pkill -x "$app"
          echo "[INFO] Killed app: $app (after school hours)"
          quit_any=true
        fi
      fi

    else
      if pgrep -x "$app" > /dev/null; then
        pkill -x "$app"
        echo "[INFO] Killed app: $app"
        quit_any=true
      fi
    fi
  done


elif [ "$MODE" = "off" ]; then
  cp /etc/hosts /etc/hosts.bak
  echo "[INFO] Backed up /etc/hosts to /etc/hosts.bak"
  for site in "${BLOCKED_SITES[@]}"; do
    if grep -E "^[^#]*127\.0\.0\.1[[:space:]]+$site" /etc/hosts > /dev/null 2>&1; then
      # Use GNU sed if available, otherwise use macOS sed -i ''
      if sed --version >/dev/null 2>&1; then
        sed -i "/^127\.0\.0\.1 $site/d" /etc/hosts
      else
        sed -i '' "/^127\.0\.0\.1 $site/d" /etc/hosts
      fi
      echo "[INFO] Unblocked site: $site"
    fi
  done
  echo "Focus mode disabled."
else
  echo "Usage: $0 [on|off]"
fi
