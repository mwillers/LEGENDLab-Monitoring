# Copyright (c) 2023, 2024, 2025 Michael Willers
# This software is part of LEGENDLab-Monitoring, released under the MIT License.
# https://github.com/mwillers/LEGENDLab-Monitoring
# See the LICENSE.txt file in the project root for full license information.

using Pkg;
Pkg.activate("/home/legend/software/LEGENDLab-Monitoring");
using Sockets
using Dates
using Parsers
using Printf


function get_lakeshore_temperature()
    read_data = ""
    try
       icpc_netcom_address = ip"172.16.0.10"
       lsc = connect(icpc_netcom_address, 2011)
       write(lsc,"KRDG? 0\n")
       sleep(0.5)
       read_data = readline(lsc)
       read_data = replace(read_data, "," => " ")
       read_data = replace(read_data, "+" => " ")
       read_data = replace(read_data, "\r" => " ")
       read_data = replace(read_data, "\n" => " ")
       close(lsc)
   catch err
       @warn err
   end
   return read_data
end

function read_tpg(Channel)
    read_data=""
    try
       netcom=ip"172.16.0.10"
       lsc=connect(netcom, 2001)
       write(lsc, "PR$Channel \r")
       sleep(0.1)
       ack_data = read(lsc,3)
       # 0x0d = CR
       # 0x0a = LF
       # 0x06 = ACK
       # 0x15 = NAC
       # if first byte is ACK we can proceed
       if ack_data[1] == 0x06
            write(lsc, 0x05)
            read_data = read(lsc,12)
            close(lsc)
            read_data = read_data[3:10]
       else
            #println("no ACK received")
            close(lsc)
       end
    catch err
       @warn err
    end
    return read_data
end

temps = get_lakeshore_temperature()
pressure = read_tpg(2)

pressure = Parsers.tryparse(Float64, pressure)
if pressure !== nothing
    pressure = @sprintf("%.3e", pressure)
end

print(Dates.format(now(), "HH:MM"))
print(",")
print(split(temps, " ")[2])
print(",")
print(split(temps, " ")[4])
print(",")
println(pressure)
