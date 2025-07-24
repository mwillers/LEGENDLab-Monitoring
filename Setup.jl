# Copyright (c) 2023, 2024, 2025 Michael Willers
# This software is part of LEGENDLab-Monitoring, released under the MIT License.
# https://github.com/mwillers/LEGENDLab-Monitoring
# See the LICENSE.txt file in the project root for full license information.
import Pkg
Pkg.activate("/home/legend/software/LEGENDLab-Monitoring")
Pkg.add("Parsers")
Pkg.add("Sockets")
Pkg.add("Dates")
Pkg.instantiate()