local wifi_nr = aredn.hardware.get_iface_name("wifi"):match("wlan(%d+)")
if wifi_nr and (nixio.fs.stat("/sys/kernel/debug/ieee80211/phy" .. wifi_nr .. "/ath9k") or nixio.fs.stat("/sys/kernel/debug/ieee80211/phy" .. wifi_nr .. "/ath10k")) then
    return { href = "waterfall", display = "Waterfall", hint = "Waterfall of wireless activity" }
end
