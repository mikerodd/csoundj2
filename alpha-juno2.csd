/*
  alpha-juno2.csd - Roland Alpha Juno-2 emulator with CSound / Cabbage
  
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
 
 <Cabbage>
bounds(0, 0, 0, 0)
form caption("Alpha Juno 2") size(800, 600), colour(26,26,26), pluginid("def1")
keyboard bounds(217, 476, 579, 122) 

label bounds(116, 76, 80, 16) text("DCO RNG")
combobox bounds(146, 92, 50, 21)     channel("dcorng") value(2) text("4", "8", "16", "32")

rslider bounds(10, 60, 48, 48) range(0, 127, 0, 1, 1) text("LFO RATE") channel("lforate") markercolour(140, 134, 134, 255)
rslider bounds(10, 120, 48, 48) range(0, 127, 0, 1, 1) text("LFO DELY") channel("lfodely")
rslider bounds(10, 174, 48, 48) range(0, 127, 0, 1, 1) channel("dcolfo") text("DCO LFO")
label bounds(118, 130, 80, 16) text("DCO ENV")
combobox bounds(120, 146, 80, 20) text("Normal", "Invert", "D-Norm", "D-Invert") channeltype("string") value("Normal") channel("dcoenvm")
rslider bounds(8, 236, 48, 48) range(0, 127, 0, 1, 1) text("DCO ENV") channel("dcoenvd") trackercolour(200, 13, 13, 255) trackerinsideradius(0.71) outlinecolour(202, 25, 25, 255) markercolour(202, 25, 25, 255)


combobox bounds(246, 240, 40, 22) channel("pulse")    text("00", "01", "02", "03") 


combobox bounds(306, 240, 40, 22) channel("sawtooth")    text("00", "01", "02", "03", "04", "05") 


combobox bounds(366, 240, 40, 22) channel("sub")    text("00", "01", "02", "03", "04", "05") 

label bounds(278, 274, 80, 16) text("SUB LVL") align("right")
combobox bounds(366, 270, 40, 22) channel("sublvl")    text("0", "1", "2", "3") 

label bounds(280, 300, 80, 16) text("NOIS LVL") align("right")
combobox bounds(368, 298, 40, 22) channel("noislvl") text("0", "1", "2", "3") value(4)

rslider bounds(146, 182, 48, 48) range(0, 127, 0, 1, 1) channel("pwpwm") text("PW/PWM")
rslider bounds(144, 240, 57, 48) range(0, 127, 0, 1, 1) channel("pwmrate") text("PWM RATE")


label bounds(478, 298, 80, 16) text("HPF FREQ") align("right")
combobox bounds(566, 294, 40, 22) text("00", "01", "02", "03") channel("hpffreq") 

rslider bounds(560, 326, 48, 48) range(0, 127, 127, 1, 1) channel("vcffreq") text("VCF FREQ")
rslider bounds(502, 326, 48, 48) range(0, 127, 0, 1, 1) channel("vcfreso") text("VCF RESO")
rslider bounds(622, 326, 48, 48) range(0, 127, 0, 1, 1) channel("vcfenvd")  text("VCF ENV") 





combobox bounds(308, 10, 149, 38), channel("combobox"), populate("*.snaps") channeltype("string") value("1") 

image bounds(204, 58, 529, 175) file("imgs/j2panel.png")
image bounds(6, 6, 277, 44) file("imgs/j2Logo.png")

rslider bounds(470, 226, 32, 32) range(0, 127, 0, 1, 1) channel("envt1")
rslider bounds(732, 92, 32, 32) range(0, 127, 0, 1, 1) channel("envl1")
rslider bounds(732, 124, 32, 32) range(0, 127, 0, 1, 1) channel("envl2")
rslider bounds(732, 158, 32, 32) range(0, 127, 0, 1, 1) channel("envl3")
rslider bounds(510, 226, 32, 32) range(0, 127, 0, 1, 1) channel("envt2")
rslider bounds(558, 226, 32, 32) range(0, 127, 0, 1, 1) channel("envt3")
rslider bounds(652, 226, 32, 32) range(0, 127, 0, 1, 1) channel("envt4")





vslider bounds(10, 460, 47, 129) range(0, 1, 0.4, 1, 0.001) colour(149, 140, 140, 255) textboxoutlinecolour(0, 0, 0, 0) channel("volume") text("Volume") trackercolour(255, 0, 0, 255)
button bounds(84, 492, 51, 31) channel("OctDown") colour:1(255, 0, 0, 255) text("Down") radiogroup("oct")
button bounds(140, 492, 51, 31) channel("OctUp") text("Normal", "Normal") radiogroup("oct") colour:1(255, 0, 0, 255)

label bounds(70, 460, 128, 16) text("OCT TRANSPOSE")
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>

; Initialize the global variables. 
sr=44100
kr=4410
ksmps = 10
nchnls = 2
0dbfs = 1

// ---------------------------------------------------------------------------------------------------------------
// Global variables
// ---------------------------------------------------------------------------------------------------------------


// Values of lfo amplitude in % of frequency when applied to DCO from 0-127 for "DCO LFO"
// NB : I  interpolated those values from my 30 years old Juno-2, results weren't stable between measures...
gilfovals[] fillarray 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.001567, 0.003348, 0.005130, 
                      0.006911, 0.008692, 0.010473, 0.012254, 0.014036, 0.015817, 0.017598, 0.019379, 0.021160, 
                      0.022942, 0.024723, 0.026504, 0.028285, 0.029891, 0.031496, 0.033101, 0.034707, 0.036312, 
                      0.037918, 0.039523, 0.041128, 0.042734, 0.044339, 0.045998, 0.047657, 0.049316, 0.050975, 
                      0.052634, 0.054292, 0.055951, 0.057610, 0.059269, 0.060928, 0.062511, 0.064093, 0.065675, 
                      0.067258, 0.068840, 0.070423, 0.072005, 0.073588, 0.075170, 0.076753, 0.078404, 0.080055, 
                      0.081706, 0.083358, 0.085009, 0.086660, 0.088311, 0.089963, 0.091614, 0.093265, 0.095941, 
                      0.098616, 0.101292, 0.103968, 0.106643, 0.109319, 0.111994, 0.114670, 0.117346, 0.120021, 
                      0.123462, 0.126902, 0.130342, 0.133782, 0.137222, 0.140662, 0.144102, 0.147542, 0.150982, 
                      0.154422, 0.157786, 0.161150, 0.164513, 0.167877, 0.171241, 0.174604, 0.177968, 0.181332, 
                      0.184695, 0.188059, 0.192952, 0.197844, 0.202737, 0.207629, 0.212522, 0.217415, 0.222307, 
                      0.227200, 0.232092, 0.236985, 0.244003, 0.251021, 0.258038, 0.265056, 0.272074, 0.279092, 
                      0.286110, 0.293127, 0.300145, 0.307163, 0.313822, 0.320480, 0.327139, 0.333797, 0.340456, 
                      0.347114, 0.353773, 0.360431, 0.367090, 0.373748, 0.381480, 0.389212, 0.396944, 0.404676, 
                      0.412408, 0.420140, 0.427872, 0.435605
                      
// Values of lfo delay in sec from 0-127 "LFO DLY"
// approximate formula used:  exp([LDO DLY]/14.2-3)/10
// NB : I  extrapolated those values from my 30 years old Juno-2, results weren't stable between measures...
gilfodels[] fillarray 0.069000, 0.064100, 0.059200, 0.054300, 0.049400, 0.044500, 0.039600, 0.034700, 0.029800, 
                      0.024900, 0.020000, 0.018300, 0.016600, 0.014900, 0.013200, 0.011500, 0.009800, 0.008100, 
                      0.006400, 0.004700, 0.003000, 0.007500, 0.012000, 0.016500, 0.021000, 0.025500, 0.030000, 
                      0.034500, 0.039000, 0.043500, 0.048000, 0.053200, 0.058400, 0.063600, 0.068800, 0.074000, 
                      0.079200, 0.084400, 0.089600, 0.094800, 0.100000, 0.104600, 0.109200, 0.113800, 0.118400, 
                      0.123000, 0.127600, 0.132200, 0.136800, 0.141400, 0.146000, 0.161000, 0.176000, 0.191000, 
                      0.206000, 0.221000, 0.236000, 0.251000, 0.266000, 0.281000, 0.296000, 0.368500, 0.441000, 
                      0.513500, 0.586000, 0.658500, 0.731000, 0.803500, 0.876000, 0.948500, 1.021000, 1.036400, 
                      1.051800, 1.067200, 1.082600, 1.098000, 1.113400, 1.128800, 1.144200, 1.159600, 1.175000, 
                      1.289800, 1.404600, 1.519400, 1.634200, 1.749000, 1.863800, 1.978600, 2.093400, 2.208200, 
                      2.323000, 2.538500, 2.754000, 2.969500, 3.185000, 3.400500, 3.616000, 3.831500, 4.047000, 
                      4.262500, 4.478000, 5.092500, 5.707000, 6.321500, 6.936000, 7.550500, 8.165000, 8.779500, 
                      9.394000, 10.008500, 10.623000, 11.799300, 12.975600, 14.151900, 15.328200, 16.504500, 
                      17.680800, 18.857100, 20.033400, 21.209700, 22.386000, 23.986286, 25.586571, 27.186857, 
                      28.787143, 30.387429, 31.987714, 33.588000

gilforate[] fillarray 0.000411, 0.003560, 0.006709, 0.009858, 0.013007, 0.016156, 0.019305, 0.022454, 0.025603, 
                      0.028752, 0.031901, 0.035050, 0.038199, 0.041348, 0.044497, 0.047646, 0.050795, 0.053944, 
                      0.057093, 0.060242, 0.063391, 0.069015, 0.074639, 0.080263, 0.085887, 0.091511, 0.097135, 
                      0.102760, 0.108384, 0.114008, 0.119632, 0.131495, 0.143358, 0.155222, 0.167085, 0.178948, 
                      0.190812, 0.202675, 0.214539, 0.226402, 0.238265, 0.258837, 0.279409, 0.299981, 0.320553, 
                      0.341125, 0.361697, 0.382268, 0.402840, 0.423412, 0.443984, 0.488356, 0.532728, 0.577100, 
                      0.621473, 0.665845, 0.710217, 0.754589, 0.798961, 0.843333, 0.887705, 0.964156, 1.040606, 
                      1.117057, 1.193507, 1.269958, 1.346408, 1.422858, 1.499309, 1.575759, 1.652210, 1.808662, 
                      1.965113, 2.121565, 2.278017, 2.434468, 2.590920, 2.747372, 2.903824, 0.000000, 3.216727, 
                      3.504346, 3.791965, 4.079584, 4.367203, 0.000000, 4.942441, 5.230060, 5.517679, 5.805298, 
                      6.092917, 6.706867, 7.320817, 7.934767, 8.548717, 9.162666, 9.776616, 10.390566, 11.004516, 
                      11.618466, 12.232416, 13.054164, 13.875912, 14.697660, 15.519409, 16.341157, 17.162905, 
                      17.984653, 18.806401, 19.628150, 20.449898, 23.069631, 25.689364, 28.309098, 30.928831, 
                      33.548564, 36.168297, 38.788031, 41.407764, 44.027497, 46.647230, 49.266964, 51.886697, 
                      54.506430, 57.126163, 59.745897, 62.365630, 64.985363
                      

gipwmrate[] fillarray 0.000000, 0.002994, 0.005988, 0.008982, 0.011976, 0.014970, 0.017964, 0.020958, 
                      0.023952, 0.026946, 0.029940, 0.032223, 0.034506, 0.036789, 0.039072, 0.041355, 
                      0.043638, 0.045921, 0.048204, 0.050487, 0.052770, 0.056668, 0.060565, 0.064462, 
                      0.068360, 0.072257, 0.076154, 0.080051, 0.083949, 0.087846, 0.091743, 0.098255, 
                      0.104767, 0.111279, 0.117791, 0.124303, 0.130815, 0.137327, 0.143839, 0.150351, 
                      0.156863, 0.168424, 0.179986, 0.191548, 0.203109, 0.214671, 0.226233, 0.237795, 
                      0.249356, 0.260918, 0.272480, 0.298329, 0.324178, 0.350028, 0.375877, 0.401727, 
                      0.427576, 0.453425, 0.479275, 0.505124, 0.530973, 0.561608, 0.592243, 0.622878, 
                      0.653512, 0.684147, 0.714782, 0.745416, 0.776051, 0.806686, 0.837321, 0.906650, 
                      0.975979, 1.045308, 1.114637, 1.183966, 1.253296, 1.322625, 1.391954, 1.461283, 
                      1.530612, 1.645408, 1.760204, 1.875000, 1.989796, 2.104592, 2.219388, 2.334184, 
                      2.448980, 2.563776, 2.678571, 2.828571, 2.978571, 3.128571, 3.278571, 3.428571, 
                      3.686810, 3.945048, 4.203287, 4.461525, 4.719764, 5.009744, 5.299725, 5.589705, 
                      5.879685, 6.169666, 6.497294, 6.824923, 7.152551, 7.480179, 7.807808, 8.272163, 
                      8.736519, 9.200874, 9.665229, 10.129585, 10.593940, 11.058296, 11.522651, 11.987006, 
                      12.451362, 13.591026, 14.730690, 15.870354, 17.010017, 18.149681, 19.289345, 20.429009



// vcffreq values 0-127
givcffreq[] fillarray 11.528952, 11.747088, 11.965224, 12.183360, 12.401496, 12.619632, 12.837768, 13.055904, 
                      13.274040, 13.492176, 13.710312, 14.393507, 15.076701, 15.759896, 16.443090, 17.126285, 
                      17.809480, 18.492674, 19.175869, 19.859063, 20.542258, 22.365894, 24.189530, 26.013166, 
                      27.836802, 29.660439, 31.484075, 33.307711, 35.131347, 36.954983, 38.778619, 41.810322, 
                      44.842024, 47.873726, 50.905429, 53.937131, 56.968834, 60.000537, 63.032239, 66.063941, 
                      69.095644, 76.826937, 84.558229, 92.289522, 100.020814, 107.752107, 115.483400, 123.214692, 
                      130.945985, 138.677277, 146.408570, 162.790608, 179.172646, 195.554685, 211.936723, 228.318761, 
                      244.700799, 261.082837, 277.464876, 293.846914, 310.228952, 331.380140, 352.531327, 373.682515, 
                      394.833702, 415.984890, 437.136078, 458.287265, 479.438453, 500.589640, 521.740828, 573.914911, 
                      626.088994, 678.263076, 730.437159, 782.611242, 834.785325, 886.959408, 939.133490, 991.307573, 
                      1043.481656, 1160.239551, 1276.997446, 1393.755342, 1510.513237, 1627.271132, 1744.029027, 1860.786922, 
                      1977.544818, 2094.302713, 2211.060608, 2363.702490, 2516.344372, 2668.986254, 2821.628135, 2974.270017, 
                      3126.911899, 3432.488362, 3738.064826, 4043.641289, 4349.217752, 4654.794215, 4960.370679, 5265.947142, 
                      5571.523605, 6189.787658, 6808.051711, 7426.315764, 8044.579818, 8662.843871, 9281.107924, 9899.371977, 
                      10517.636030, 11062.204470, 11606.772900, 12151.341340, 12695.909770, 13240.478210, 13785.046640, 14329.615080, 
                      14874.183510, 15276.226560, 15678.269610, 16080.312660, 16482.355710, 16884.398760, 17286.441810, 17688.484860
                      


// Env T1 values 0-127, formula used:  power(2,envt/10-8)
gienvt1[] fillarray     0.004187, 0.004487, 0.004809, 0.005154, 0.005524, 0.005921, 0.006346, 0.006801, 0.007289, 0.007812, 
                        0.008373, 0.008974, 0.009618, 0.010309, 0.011049, 0.011842, 0.012691, 0.013602, 0.014579, 0.015625, 
                        0.016746, 0.017948, 0.019237, 0.020617, 0.022097, 0.023683, 0.025383, 0.027205, 0.029157, 0.031250, 
                        0.033493, 0.035897, 0.038473, 0.041235, 0.044194, 0.047366, 0.050766, 0.054409, 0.058315, 0.062500, 
                        0.066986, 0.071794, 0.076947, 0.082469, 0.088388, 0.094732, 0.101532, 0.108819, 0.116629, 0.125000, 
                        0.133972, 0.143587, 0.153893, 0.164938, 0.176777, 0.189465, 0.203063, 0.217638, 0.233258, 0.250000, 
                        0.267943, 0.287175, 0.307786, 0.329877, 0.353553, 0.378929, 0.406126, 0.435275, 0.466516, 0.500000, 
                        0.535887, 0.574349, 0.615572, 0.659754, 0.707107, 0.757858, 0.812252, 0.870551, 0.933033, 1.000000, 
                        1.071773, 1.148698, 1.231144, 1.319508, 1.414214, 1.515717, 1.624505, 1.741101, 1.866066, 2.000000, 
                        2.143547, 2.297397, 2.462289, 2.639016, 2.828427, 3.031433, 3.249010, 3.482202, 3.732132, 4.000000, 
                        4.287094, 4.594793, 4.924578, 5.278032, 5.656854, 6.062866, 6.498019, 6.964405, 7.464264, 8.000000, 
                        8.574188, 9.189587, 9.849155, 10.556063, 11.313709, 12.125733, 12.996038, 13.928809, 14.928528, 
                        16.000000, 17.148375, 18.379174, 19.698311, 21.112127, 22.627417, 24.251465, 25.992077

// env T3
gienvt3[] fillarray     0.090000, 0.097000, 0.104000, 0.111000, 0.118000, 0.125000, 0.132000, 0.139000, 
                        0.146000, 0.153000, 0.160000, 0.164000, 0.168000, 0.172000, 0.176000, 0.180000, 
                        0.184000, 0.188000, 0.192000, 0.196000, 0.200000, 0.205000, 0.210000, 0.215000, 
                        0.220000, 0.225000, 0.230000, 0.235000, 0.240000, 0.245000, 0.250000, 0.258000, 
                        0.266000, 0.274000, 0.282000, 0.290000, 0.298000, 0.306000, 0.314000, 0.322000, 
                        0.330000, 0.348000, 0.366000, 0.384000, 0.402000, 0.420000, 0.438000, 0.456000, 
                        0.474000, 0.492000, 0.510000, 0.539000, 0.568000, 0.597000, 0.626000, 0.655000, 
                        0.684000, 0.713000, 0.742000, 0.771000, 0.800000, 0.858000, 0.916000, 0.974000, 
                        1.032000, 1.090000, 1.148000, 1.206000, 1.264000, 1.322000, 1.380000, 1.545000, 
                        1.710000, 1.875000, 2.040000, 2.205000, 2.370000, 2.535000, 2.700000, 2.865000, 
                        3.030000, 3.595000, 4.160000, 4.725000, 5.290000, 5.855000, 6.420000, 6.985000, 
                        7.550000, 8.115000, 8.680000, 9.224000, 9.768000, 10.312000, 10.856000, 11.400000, 
                        11.864000, 12.328000, 12.792000, 13.256000, 13.720000, 14.447500, 15.175000, 15.902500, 
                        16.630000, 17.357500, 18.085000, 18.812500, 19.540000, 20.267500, 20.995000, 22.048500, 
                        23.102000, 24.155500, 25.209000, 26.262500, 27.316000, 28.369500, 29.423000, 30.476500, 
                        31.530000, 32.394286, 33.258571, 34.122857, 34.987143, 35.851429, 36.715714, 37.580000



// ent T3 values 0-127 
gienvt4[] fillarray     0.007000, 0.009300, 0.011600, 0.013900, 0.016200, 0.018500, 0.020800, 0.023100, 
                        0.025400, 0.027700, 0.030000, 0.034400, 0.038800, 0.043200, 0.047600, 0.052000, 
                        0.056400, 0.060800, 0.065200, 0.069600, 0.074000, 0.083100, 0.092200, 0.101300, 
                        0.110400, 0.119500, 0.128600, 0.137700, 0.146800, 0.155900, 0.165000, 0.184100, 
                        0.203200, 0.222300, 0.241400, 0.260500, 0.279600, 0.298700, 0.317800, 0.336900, 
                        0.356000, 0.394400, 0.432800, 0.471200, 0.509600, 0.548000, 0.586400, 0.624800, 
                        0.663200, 0.701600, 0.740000, 0.808000, 0.876000, 0.944000, 1.012000, 1.080000, 
                        1.148000, 1.216000, 1.284000, 1.352000, 1.420000, 1.541000, 1.662000, 1.783000, 
                        1.904000, 2.025000, 2.146000, 2.267000, 2.388000, 2.509000, 2.630000, 2.887000, 
                        3.144000, 3.401000, 3.658000, 3.915000, 4.172000, 4.429000, 4.686000, 4.943000, 
                        5.200000, 5.520000, 5.840000, 6.160000, 6.480000, 6.800000, 7.120000, 7.440000, 
                        7.760000, 8.080000, 8.400000, 8.909000, 9.418000, 9.927000, 10.436000, 10.945000, 
                        11.454000, 11.963000, 12.472000, 12.981000, 13.490000, 14.243000, 14.996000, 15.749000, 
                        16.502000, 17.255000, 18.008000, 18.761000, 19.514000, 20.267000, 21.020000, 22.101000, 
                        23.182000, 24.263000, 25.344000, 26.425000, 27.506000, 28.587000, 29.668000, 30.749000, 
                        31.830000, 32.902857, 33.975714, 35.048571, 36.121429, 37.194286, 38.267143, 39.340000





// amplitude for oscillation
giAmp = 0.4 

// Amplitude of pwm oscilation as a ratio
gipwmAmp = 0.375


// ----------------------------------------------------------------------------------------------------------------
// Begin of instrument
// ----------------------------------------------------------------------------------------------------------------
  instr 1
  

// ----------------------------------------------------------------------------------------------------------------
; Gets
// ----------------------------------------------------------------------------------------------------------------
iLfoRate        chnget "lforate"  
iLfoDely        chnget "lfodely"  
iPulse          chnget "pulse"
iPulse          = iPulse - 1
iSawtooth       chnget "sawtooth"
iSawtooth       = iSawtooth - 1
iSub            chnget "sub"
iSub            = iSub - 1
iSubLvl         chnget "sublvl" 
iSubLvl         = iSubLvl - 1
kpwpwm          chnget "pwpwm"
iNoisLvl        chnget "noislvl"
iNoisLvl         = iNoisLvl - 1
iPwmRate        chnget "pwmrate"
iDcoRng         chnget "dcorng"
iDcoLfo         chnget "dcolfo"
iDcoEnvD        chnget "dcoenvd"
SDcoEnvM        chnget "dcoenvm"    
iHpfFreq        chnget "hpffreq" 
iHpfFreq        = iHpfFreq - 1
iVcfFreq        chnget "vcffreq" 
iVcfReso        chnget "vcfreso" 
iVcfEnvd        chnget "vcfenvd" 
iEnvT1          chnget "envt1"
iEnvT2          chnget "envt2"
iEnvT3          chnget "envt3"
iEnvT4          chnget "envt4"
iEnvL1          chnget "envl1"
iEnvL2          chnget "envl2"
iEnvL3          chnget "envl3"
giAmp           chnget "volume"





;printf_i "isublevl : %f\n", 1,iSubLvl 






// ----------------------------------------------------------------------------------------------------------------
; LFO Block
// ----------------------------------------------------------------------------------------------------------------

if (iLfoDely > 10) then 
    itmp = 1 
else 
    itmp = 0 
endif 
kLfo            linseg 0,gilfodels[iLfoDely] , 0,itmp ,1 // Delay for LFO1 
aLFO            lfo kLfo, gilforate[iLfoRate], 1                                // Rate for LFO 



if (iPwmRate != 0) then
    kLfoPw          lfo kpwpwm/2, gipwmrate[iPwmRate], 1                        // Rate for LFO PWM
    kLfoPw          = kLfoPw - kpwpwm/2
else 
    kLfoPw = kpwpwm                                                     // Basicely No LFO PWM
endif 

printf_i "iPwmRate : %d, hz: %f \n",1,iPwmRate,gipwmrate[iPwmRate]

// ----------------------------------------------------------------------------------------------------------------
; DCO Block
// ----------------------------------------------------------------------------------------------------------------

kNote           = p4 * (8  / (2^(iDcoRng + 1)))                        // Base note calculation : note * dcoRng correction 
kNote           = kNote  +  aLFO * (kNote * gilfovals[iDcoLfo] / 2)    // note + lfo oscilation

//printf_i  ": kLfoPw %f,k kLFOPw : %f p5 %f kpwpwm : %d \n",1, kLfoPw  ,(kLfoPw)*1.99/127 ,p5,kpwpwm



; -- Square part
if (iPulse == 0) then 
    aOsc1 = 0
else
    aOscTri vco2 p5, kNote,0,0,0,0.2
    if (iPulse == 1) then
        aOsc1  vco2  p5, kNote,10,0,0,0.45  // Square 
    elseif (iPulse == 2) then 
        aOsc1   vco2  p5, kNote,2,0.75
    elseif (iPulse == 3) then
        aOsc1   vco2  p5, kNote ,2,  0.5 - (kLfoPw)*0.49/127  
        aOsc1 = aOsc1  // + kLfoPw
    endif 
    aOsc1 = - aOsc1 *(aOscTri + 6)/7     // the pulse wave is not really a square...
endif 




; -- Sawtooth part
if (iSawtooth == 0) then 
    aOsc2  = 0
else
    aSaw1 vco2  p5, kNote ,0
    
    if (iSawtooth == 1) then
        aOsc2           = - aSaw1  
    elseif (iSawtooth  == 2) then
        aSquare1x2      vco2  p5, p4*2,10     // note / 2  
        aSquare1x201    =   (-aSquare1x2  + 1) / 2    // Gate for Sawtooth waves 
        aOsc2           = (-aSaw1+1) * aSquare1x201    -1   

    elseif (iSawtooth == 3) then
        asquarepwm      vco2  p5, kNote * 2, 2 ,  0.5 - (kLfoPw)*0.49/127  
        aSquare1x201    =   (-asquarepwm + 1) / 2
        aSaw1           vco2  p5, p4 ,0
        aOsc2           = (-aSaw1 + 1) * (aSquare1x201)        -1    // saw03
    
    elseif (iSawtooth == 4) then
        aSaw4           vco2  p5, kNote ,0
        asquare         vco2  p5, kNote * 8, 10, 0.5, 0.5
        aSquare201      =   (asquare  + 1) / 2    // Gate for Sawtooth waves 
        aOsc2           = (-aSaw4 + 1) * (aSquare201)        -1    // saw04

    elseif (iSawtooth == 5) then
        aSaw4           vco2  p5, kNote ,0
        aSquared2       vco2  p5, kNote*2,10     // note / 2  
        asquared8       vco2  p5, kNote* 8, 10, 0.5, 0.5  // note / 8
        aSquare1x201    =   (- aSquared2     + 1) / 2    // Gate for Sawtooth waves 
        aSquare201      =   (asquared8 + 1) / 2    // Gate for Sawtooth waves 
        aOsc2           = (-aSaw4 + 1) * (aSquare201) * aSquare1x201        -1    // saw04
    endif 
endif

; -- Sub part

if (iSubLvl == 0) then 
    kSubLevel = 0
else
    kSubLevel = (2^(iSubLvl)) / 8
endif


if (iSub == 0) then 
    aOsc3   vco2,  p5 * kSubLevel, kNote/2,10

elseif (iSub == 1) then
    aOsc3   vco2  p5 * kSubLevel, kNote/2 ,2,0.75

elseif (iSub == 2) then
   aSub1 vco2  p5* kSubLevel, kNote*2 ,10
   aSub2 vco2  p5* kSubLevel, kNote/2 ,10
   aOsc3   =  (- aSub1 + 1) * (-aSub2 + 1) / 2 - 1

elseif (iSub == 3) then
   aSub1 vco2  p5* kSubLevel, kNote*4 ,10
   aSub2 vco2  p5* kSubLevel, kNote/2 ,10
   aOsc3   =  (- aSub1 + 1) * (-aSub2 + 1) / 2 - 1

elseif (iSub == 4) then
    aOsc3   vco2,  p5 * kSubLevel, kNote/4,10

elseif (iSub == 5) then
    aOsc3   vco2  p5 * kSubLevel, kNote/4 ,2,0.75

endif 


; -- Noise part
if (iNoisLvl == 0) then 
    kNoisLvl  = 0
else
    kNoisLvl  = (2^(kNoisLvl)) / 8
endif
aOsc4   noise p5 * iNoisLvl / 3, -0.9

; Output VCO Block
aOutVcoblock    =  aOsc1 * giAmp + aOsc2* giAmp + aOsc3 * giAmp + aOsc4 * giAmp


// -----------
// post filter 
// -----------
//aPoutPostFilter mvclpf1 aOutVcoblock    ,8000,0
aPoutPostFilter  = aOutVcoblock    

// ----------------------------------------------------------------------------------------------------------------
; HPF Block
// ----------------------------------------------------------------------------------------------------------------
if (iHpfFreq == 0) then
    aOutHPFBlock        mvclpf1 aPoutPostFilter ,8000,0
elseif (iHpfFreq == 1) then
    aOutHPFBlock        = aPoutPostFilter    
elseif (iHpfFreq == 2) then
    aOutHPFBlock        mvchpf aPoutPostFilter ,312
elseif (iHpfFreq == 3) then
    aOutHPFBlock        mvchpf aPoutPostFilter ,1000
endif


// ----------------------------------------------------------------------------------------------------------------
; VCF Block
// ----------------------------------------------------------------------------------------------------------------
;ares reson asaw, kcf, kbw
;asig balance ares, asaw
;     outs asig, asig

// ares tbvcf asig, xfco, xres, kdist, kasym [, iskip]
;aOutVCFBlock reson aOutHPFBlock, givcffreq[iVcfFreq], 20 






// ----------------------------------------------------------------------------------------------------------------
; VCA  VCF Block
// ----------------------------------------------------------------------------------------------------------------

;printf_i "courbe : %f %f %f %f %f %f %f \n",1, gienvt1[iEnvT1], iEnvL1/127, gienvt1[iEnvT2]*(iEnvL1-iEnvL2)/127, iEnvL2/127, gienvt1[iEnvT3], iEnvL3/127, gienvt1[iEnvT4]
if (iEnvL1 > iEnvL2) then 
    kEnvL linsegr 0, gienvt1[iEnvT1], iEnvL1/127, gienvt1[iEnvT2*(iEnvL1-iEnvL2)/127], iEnvL2/127, gienvt3[iEnvT3], iEnvL3/127, gienvt4[iEnvT4],0
    //kEnvE expsegr 0.001, gienvt1[iEnvT1], iEnvL1/127, gienvt1[iEnvT2*(iEnvL1-iEnvL2)/127], iEnvL2/127, gienvt3[iEnvT3], iEnvL3/127, gienvt4[iEnvT4],0.001
    
    
else
    kEnvL linsegr 0, gienvt1[iEnvT1*iEnvL1/127], iEnvL1/127, gienvt1[iEnvT2], iEnvL2/127, gienvt3[iEnvT3], iEnvL3/127, gienvt4[iEnvT4],0
    //kEnvE expsegr 0.001, gienvt1[iEnvT1*iEnvL1/127], iEnvL1/127, gienvt1[iEnvT2], iEnvL2/127, gienvt3[iEnvT3], iEnvL3/127, gienvt4[iEnvT4],0.001
endif 



//kEnvE	expsegr	1, .05, 0.5, 1, .01

kEnv = kEnvL*2
printf_i "iVcfFreq:%d     iVcfEnvd:%d   kEnv : %f\n",1,iVcfFreq,iVcfEnvd,kEnv

aOutVCFBlock moogvcf aOutHPFBlock, givcffreq[min(iVcfFreq + iVcfEnvd * kEnv/8, 127)]*1.1 , iVcfReso/145




// ----------------------------------------------------------------------------------------------------------------
; Output
// ----------------------------------------------------------------------------------------------------------------
outs        aOutVCFBlock * kEnv, aOutVCFBlock * kEnv 
  
  endin
  
  
</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...

f0 z

</CsScore>
</CsoundSynthesizer>
