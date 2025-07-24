# CUBE3 Monitoring

<img src="img/LEGENDLabMonitoring.png" alt="Logo" width="240"/>

Simple set of scripts to monitor the CUBE3 setup in the LEGENDLab at TUM.
Sensors to read out are:

* Pfeiffer full range gauges connected to a TPG256 pressure monitor
* Temperature diodes connected to a Lakeshore LS218 temperature monitor
* TPG256 and LS218 are connected via their serial ports to a ... serial to Ethernet adapter (this assumes a dedicated network interface connected into a "measurement" network with the serial to Ethernet adapter).

It's split into a Monitoring section (reading pressure / temperature values and writing them to a CSV file + generating plots) and a "WebGen" section to generate a webpage that is served at the local network interface.

## Install julia

```bash
curl -L  "https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.0-linux-x86_64.tar.gz"     | tar -x -z -f -
export PATH="`pwd`/julia-1.9.0/bin:$PATH"
# to install dependencies
julia Setup.jl
```

## Install python (anaconda)

as root

```bash
curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg
install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" | sudo tee /etc/apt/sources.list.d/conda.list
apt update
apt install conda
ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
mkdir /opt/conda/envs/
/opt/conda/bin/conda create --prefix /opt/conda/envs/python python=3.11 ipykernel
```

## Install docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

## Install Service

as root

```bash
bash InstallService.sh
systemctl start LEGENDLab-Monitoring.timer
```
