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
import re

script_path = os.path.abspath(__file__)
script_dir = os.path.dirname(script_path)

now = dt.datetime.now()
script_timestamp = now.strftime("%Y.%m.%d %H:%M:%S")
today = now.strftime("%Y_%m_%d")

png_file = script_dir + '/html/img/latest.png'

column_names = ['timestamp', 'T1', 'T2', 'P2']

def load_and_concatenate_csvs(start_date, end_date):
    pattern = re.compile(r'\d{4}_\d{2}_\d{2}\.csv')
    concatenated_df = pd.DataFrame()

    for filename in os.listdir(script_dir+'/log'):
        if pattern.match(filename):
            file_date = dt.datetime.strptime(filename.split('.')[0], '%Y_%m_%d')
            if start_date <= file_date <= end_date:
                df = pd.read_csv(script_dir+'/log/'+filename,names=column_names,)
                df['timestamp'] = pd.to_datetime(filename.split('.')[0].replace('_', '-') + ' ' + df['timestamp'])
                df['P2'] = pd.to_numeric(df['P2'], errors='coerce')
                concatenated_df = pd.concat([concatenated_df, df])

    return concatenated_df

start_date = (now - dt.timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)
end_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
xlim_start = now - dt.timedelta(days=1)
xlim_end = now + dt.timedelta(hours=2)

data = load_and_concatenate_csvs(start_date, end_date)
data = data[data['timestamp'] >= now - dt.timedelta(days=1)]
df = data
#print(data)

pressure_min = df['P2'].min()
pressure_max = df['P2'].max()
decade_min = 10 ** np.floor(np.log10(pressure_min))
decade_max = 10 ** np.ceil(np.log10(pressure_max))

T1_last = df.sort_values(by='timestamp', ascending=False).iloc[0]['T1']
T2_last = df.sort_values(by='timestamp', ascending=False).iloc[0]['T2']
P2_last = df.sort_values(by='timestamp', ascending=False).iloc[0]['P2']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))  # figsize controls the size of the entire figure

grid_style = {'linestyle': ':', 'linewidth': 0.5, 'color': 'gray'}
timefont = {'family': 'monospace', 'color':  'dimgrey', 'weight': 'normal', 'size': 8}

ax1.plot(df['timestamp'], df['T1'], 'bo', markersize=1, label='Cold finger (T1)')
ax1.plot(df['timestamp'], df['T2'], 'ro', markersize=1, label='Detector cup (T2)')
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
ax1.xaxis.set_major_locator(mdates.HourLocator(interval=2))
ax1.legend(loc='upper center')
ax1.grid(**grid_style)
ax1.set_xlim(xlim_start, xlim_end)
ax1.set_ylim(50,300)
ax1.set_ylabel('Temperature (K)')
ax1.axhline(y=77, color='orangered', linewidth=0.5, linestyle=':')
ax1.axhline(y=87, color='darkorange', linewidth=0.5, linestyle=':')
ax1.text(0.01, 0.05, 'T1 latest reading: ' + f'{T1_last:5.1f}' + ' K', fontdict=timefont, horizontalalignment='left', verticalalignment='bottom', transform=ax1.transAxes, bbox=dict(facecolor='white', alpha=0.5, edgecolor='none', pad=2))
ax1.text(0.01, 0.01, 'T2 latest reading: ' + f'{T2_last:5.1f}' + ' K', fontdict=timefont, horizontalalignment='left', verticalalignment='bottom', transform=ax1.transAxes, bbox=dict(facecolor='white', alpha=0.5, edgecolor='none', pad=2))


ax2.plot(df['timestamp'], df['P2'], 'ko', markersize=1, label='CUBE3 (P2)')
ax2.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
ax2.xaxis.set_major_locator(mdates.HourLocator(interval=2))
ax2.legend(loc='upper center')
ax2.set_ylabel('Pressure (mbar)')
ax2.grid(**grid_style)
ax2.set_yscale('log')
ax2.set_xlim(xlim_start, xlim_end)
ax2.set_ylim(decade_min, decade_max)
ax2.text(0.99, 0.05, 'P2 latest reading: ' + f'{P2_last:.1E}' + ' mbar', fontdict=timefont, horizontalalignment='right', verticalalignment='bottom', transform=ax2.transAxes, bbox=dict(facecolor='white', alpha=0.5, edgecolor='none', pad=2))
ax2.text(0.99, 0.01, 'Plot generated on: ' + script_timestamp, fontdict=timefont, horizontalalignment='right', verticalalignment='bottom', transform=ax2.transAxes, bbox=dict(facecolor='white', alpha=0.5, edgecolor='none', pad=2))

fig.autofmt_xdate()
plt.savefig(png_file, dpi=300, bbox_inches='tight')