# Copyright (c) 2023, 2024, 2025 Michael Willers
# This software is part of LEGENDLab-Monitoring, released under the MIT License.
# https://github.com/mwillers/LEGENDLab-Monitoring
# See the LICENSE.txt file in the project root for full license information.
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import datetime as dt
import os

script_path = os.path.abspath(__file__)
script_dir = os.path.dirname(script_path)

now = dt.datetime.now()
script_timestamp = now.strftime("%Y.%m.%d %H:%M:%S")
today = now.strftime("%Y_%m_%d")

csv_file = script_dir + '/log/' + today + '.csv'
png_file = script_dir + '/html/img/' + today + '.png'
latest_file = script_dir + '/html/img/latest.png'

column_names = ['timestamp', 'T1', 'T2', 'P2']
df = pd.read_csv(csv_file, names=column_names, parse_dates=[0], date_parser=lambda x: dt.datetime.strptime(x, '%H:%M'))
df['P2'] = pd.to_numeric(df['P2'], errors='coerce')

pressure_min = df['P2'].min()
pressure_max = df['P2'].max()
decade_min = 10 ** np.floor(np.log10(pressure_min))
decade_max = 10 ** np.ceil(np.log10(pressure_max))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))  # figsize controls the size of the entire figure

grid_style = {'linestyle': ':', 'linewidth': 0.5, 'color': 'gray'}
timefont = {'family': 'monospace', 'color':  'darkgrey', 'weight': 'normal', 'size': 8}
arbitrary_date = dt.date(1900, 1, 1)  # for example, November 3, 2023
time_start = dt.time(00, 1)  # 8:00 AM
time_end = dt.time(23, 59)  # 8:00 AM
xlim_start = dt.datetime.combine(arbitrary_date, time_start)
xlim_end = dt.datetime.combine(arbitrary_date, time_end)

ax1.plot(df['timestamp'], df['T1'], 'bo', markersize=1, label='Cold finger (T1)')
ax1.plot(df['timestamp'], df['T2'], 'ro', markersize=1, label='Detector cup (T2)')
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
ax1.xaxis.set_major_locator(mdates.HourLocator(interval=2))
ax1.legend(loc='upper center')
ax1.grid(**grid_style)
ax1.set_xlim(xlim_start, xlim_end)
ax1.set_ylim(60,300)
#ax1.set_xlabel('Time')
ax1.set_ylabel('Temperature (K)')

ax2.plot(df['timestamp'], df['P2'], 'ko', markersize=1, label='CUBE3 (P2)')
ax2.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
ax2.xaxis.set_major_locator(mdates.HourLocator(interval=2))
ax2.legend(loc='upper center')
#ax2.set_xlabel('Time')
ax2.set_ylabel('Pressure (mbar)')
ax2.grid(**grid_style)
ax2.set_yscale('log')
ax2.set_xlim(xlim_start, xlim_end)
#ax2.set_ylim(5E-7,5E-2)
ax2.set_ylim(decade_min, decade_max)
ax2.text(0.99, 0.01, 'Plots generated on: ' + script_timestamp, fontdict=timefont, horizontalalignment='right', verticalalignment='bottom', transform=ax2.transAxes, bbox=dict(facecolor='white', alpha=1, edgecolor='none', pad=2))

fig.autofmt_xdate()
plt.savefig(png_file, dpi=300, bbox_inches='tight')
#plt.savefig(latest_file, dpi=300, bbox_inches='tight')