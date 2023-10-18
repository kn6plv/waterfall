#!/usr/bin/lua
--[[

	Part of AREDN -- Used for creating Amateur Radio Emergency Data Networks
	Copyright (C) 2023 Tim Wilkinson
	See Contributors file for additional contributors

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation version 3 of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	Additional Terms:

	Additional use restrictions exist on the AREDN(TM) trademark and logo.
		See AREDNLicense.txt for more info.

	Attributions to the AREDN Project must be retained in the source code.
	If importing this code into a new or existing project attribution
	to the AREDN project must be added to the source code.

	You must not misrepresent the origin of the material contained within.

	Modified versions must be modified to attribute to the original source
	and be marked in reasonable ways as differentiate it from the original
	version

--]]

require("iwinfo")
require("aredn.hardware")

VERSION="0.5.2"

wifiiface = aredn.hardware.get_iface_name("wifi")
phy = iwinfo.nl80211.phyname(wifiiface)
channels = aredn.hardware.get_rfchannels(wifiiface)
basefreq = channels[1].frequency
nf = iwinfo.nl80211.noise(wifiiface) or -95
bw = 10
for line in io.lines("/etc/config.mesh/_setup")
do
    bw = line:match("^wifi_chanbw%s=%s(%d+)")
    if bw then
        break
    end
end
bw = tonumber(bw) or 10

start_freq = 0
end_freq = 0
freq2chan = "freq2chan = (f) => (f - 5000) / 5;"
if basefreq > 900 and basefreq < 2300 then
    start_freq = 902 - bw / 2
    end_freq = 925 + bw / 2
    freq2chan = "freq2chan = (f) => (f - 887) / 5;"
elseif basefreq > 2300 and basefreq < 3000 then
    start_freq = 2387 - bw / 2
    end_freq = 2472 + bw / 2
    freq2chan = "freq2chan = (f) => (f - 2407) / 5;"
elseif basefreq > 3000 and basefreq < 5100 then
    -- transverted
    start_freq = 5370 - bw / 2
    end_freq = 5500 + bw / 2
else
    start_freq = 5655 - bw / 2
    end_freq = 5920 + bw / 2
end

nr_subsamples = 56
buckets_per_freq = nr_subsamples / bw
nr_buckets = math.floor((end_freq - start_freq) * buckets_per_freq)
