-- NMEA UDP V0.1 by Ubi Sumus. Edit avibix for Pronebo


-- networking
local defaultIP   = "127.0.0.1"
local defaultPort = 16969
local IP   = ""
local Port = ""

--  the config file to keep IP and Port
local filename = SCRIPT_DIRECTORY .. "NMEA_UDP.cfg"

-- needed for CRC
local bxor = bit.bxor

-- the structure we hold current plane's situatuion
local data = {}

-- current plane situation
-- lat, lon and alt are provided by FlyWithLua

-- that's what we request from X-Plane
dataref("groundspeed", "sim/flightmodel/position/groundspeed")
dataref("truetrack",   "sim/flightmodel/position/psi")
dataref("variation",   "sim/flightmodel/position/magnetic_variation")
dataref("magtrack",    "sim/flightmodel/position/magpsi")


-- send the NMEA sentences via UPD to given IP-address and port
function sendUDP(txt)

	local socket = require "socket"
	-- local address = IP 
	-- local pPort = Port 
	local udp = socket.udp()

	udp:settimeout(0)
	-- udp:setpeername(IP, pPort)
	udp:setpeername(IP, Port)
	udp:send(txt)
  socket.try(udp:close())
	return 
	
end


--
-- all the functions needed for NMEA 
--

-- get the data we need to compose the NMEA sentences
function readData()
  
  -- system UTC time (the ! makes it UTC)
	local hr    = os.date('!%H')
	local mi    = os.date('!%M')
	local se    = os.date('!%S')
  
	data.time   = string.format("%02d%02d%02d", hr, mi, se)
	data.date   = os.date("%d%m%y")
	data.lat    = LATITUDE 
	data.lon    = LONGITUDE 
	data.alt    = ELEVATION 
	data.gs     = groundspeed * 1.943844  -- convert m/s to kts 
	data.tt     = truetrack 
	data.var    = variation 
	data.mt     = magtrack  
	
  -- convert decimal latitude to NMEA latitude
	local degLat = math.floor(math.abs(data.lat))
	local minLat = (math.abs(data.lat) - degLat) * 60
	if data.lat > 0 then NS = 'N'
		else NS = 'S'
	end
	data.lat = string.format("%02d%07.4f,%s", degLat, minLat, NS)
  
  -- convert decimal longitude to NMEA longitude
	local degLon = math.floor(math.abs(data.lon))
	local minLon = (math.abs(data.lon) - degLon) * 60
	if data.lon > 0 then EW = 'E'
		else EW = 'W'
	end
	data.lon = string.format("%03d%07.4f,%s", degLon, minLon, EW)

	-- same for  variation
  if data.var >= 0 then
		data.var = string.format("%2.2f,W", math.abs(data.var))
	else
		data.var = string.format("%2.2f,E", math.abs(data.var))
	end
  
	data.alt = string.format("%1.1f", data.alt)
	
end

-- calculate the nmea checksum CRC16
function getChecksum(txt)

  local crc = 0
   for i = 1, #txt do   
      local c = txt:byte(i)
      crc = bxor(crc, c)
  end
  return crc

end

-- let's build GPRMC, GPGGA, GPGSA
function composeNMEA()

	readData()

  local checksum = 0
	-- RMC - minimum recommended data
	local GPRMC = string.format("GPRMC,%s,A,%s,%s,%4.1f,%05.1f,%s,%s", data.time, data.lat, data.lon, data.gs, data.tt, data.date, data.var)
	checksum = getChecksum(GPRMC)
	GPRMC = string.format("$%s*%02X", GPRMC, checksum)

	-- GGA - essential fix data which provide 3D location and accuracy data
	local GPGGA = string.format("GPGGA,%s,%s,%s,1,12,1,%s,M,,,,", data.time, data.lat, data.lon, data.alt)
	checksum = getChecksum(GPGGA)
	GPGGA = string.format("$%s*%02X", GPGGA, checksum)

	--  GSA - GPS DOP and active satellites (dummy only)
	local GPGSA = "$GPGSA,A,3,04,05,06,09,12,20,22,24,25,26,28,30,1,1,1,*02"

	local NMEA = string.format("%s\r\n%s\r\n%s\r\n", GPRMC, GPGGA, GPGSA)
	
  sendUDP(NMEA)
	
end


--
-- all the functions needed to read/write the settings file
--


-- http://lua-users.org/wiki/FileInputOutput
-- Return true if file exists and is readable.
function file_exists(path)
  
  local file = io.open(path, "r")
  if file then file:close() end
  return file ~= nil
  
end

-- Read an entire file.
function readall(filename)
  
	local content = {}
	local rfile = io.open(filename, "r")
	for line in rfile:lines() do
		content[#content + 1] = line
	end
	rfile:close()
	return content
  
end

-- Write a string to a file.
function write_file(filename, contents)
  
  local fh = assert(io.open(filename, "w+"))
  fh:write(contents)
  fh:flush()
  fh:close()
  
end

function checkConfig()
  
  if file_exists(filename) then
    -- do we have a config file
    local config = {}
    config = readall(filename)
    IP = config[1]
    Port = config[2]
  else
    -- if not, create one with default IP and Port
    IP = defaultIP
    Port = defaultPort
    write_file(filename, IP .. "\n" .. Port)
  end
  
end


--
-- all the functions needed for the config window
--

function ibd_on_build(ibd_wnd, x, y)

	imgui.TextUnformatted("Set IP-Address and UDP-Port")
	imgui.SetCursorPosY(40)
  
	-- Allow the user to input text
	local IPchanged, newIP = imgui.InputText("IP-Address", IP, 15)
	local Portchanged, newPort = imgui.InputText("UDP-Port", Port, 6)
	imgui.SetCursorPosY(110)

	-- IP changed
	if IPchanged then
		IP = newIP
	end

	-- Port changed
	if Portchanged then
		Port = newPort
	end
  
	imgui.SetCursorPosX(80)
	
  if imgui.Button("Set IP and Port", 130, 30) then
		write_file(filename, IP .. "\n" .. Port)
  end
		
end

-- show the config window
function cfg_show_wnd()
  
    ibd_wnd = float_wnd_create(350, 200, 1, true)
    float_wnd_set_title(ibd_wnd, "NMEA UDP V0.1 by Ubi Sumus")
    float_wnd_set_imgui_builder(ibd_wnd, "ibd_on_build")

end


--
-- here we start
--

-- make sure the script doesn't stop old FlyWithLua versions
if not SUPPORTS_FLOATING_WINDOWS then
      logMsg("imgui not supported by your FlyWithLua version")
    return
end

-- add an entry in FlyWithLua Macros
add_macro("NMEA UDP settings", "cfg_show_wnd()")

-- first lets check the config
checkConfig()

-- send NMEA sentences every second
do_often ("composeNMEA()") -- можно использовать do_every_frame (каждый кадр, но смысла нет, так как Пронебо интерполирует) или do_often (каждую секунду)
