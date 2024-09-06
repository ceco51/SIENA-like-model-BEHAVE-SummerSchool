extensions [ nw ]

directed-link-breed [ requests request ] ;advice requests

breed [ networkers networker ]
breed [ satisficers satisficer ]

turtles-own [
  gender
  seniority
  current-advisors
  potential-advisors
]


to setup
  clear-all
  ifelse import?
  [ nw:load-graphml "nodes.graphml" ] ;same directory as .nlogo model
  [
    create-agents
    set-attributes
  ]
  reset-ticks
end

to create-agents
  create-networkers round n-agents * prop-networkers
  create-satisficers n-agents - count networkers
end


to set-attributes
  ask turtles [
    set gender one-of [ 0 1 ]
    set seniority random-poisson ifelse-value is-networker? self [ 12 ] [ 11 ]
    set color ifelse-value is-networker? self [ green ] [ yellow ]
    set shape ifelse-value gender = 0 [ "circle" ] [ "square" ]
    set size sqrt ( seniority / 20 )
    setxy random-xcor random-ycor
  ]
end

to go
  ask one-of turtles [
    set current-advisors [ self ] of out-request-neighbors
    set potential-advisors [ self ] of other turtles with [ not member? self [ current-advisors ] of myself ]
    evaluate-scenarios-and-choose
  ]
  layout-spring turtles requests 0.2 5 1
  if count requests >= max-links [ stop ]
  tick
end

to evaluate-scenarios-and-choose
  let potential-utilities evaluation
  let best-utility max potential-utilities
  let best-utility-index position best-utility potential-utilities
  let current-utility utility-function
  if best-utility > current-utility [
    let targets sentence current-advisors potential-advisors
    ifelse best-utility-index < length current-advisors ;we are in the "removing" part of the list
    [
      ask out-request-to item best-utility-index targets [ die ]
    ]
    [
      create-request-to item best-utility-index targets
    ]
  ]
end

to-report evaluation
  let utility-removing map [agent-to-remove -> utility-when-removing agent-to-remove] current-advisors
  let utility-adding map [agent-to-add -> utility-when-adding agent-to-add] potential-advisors
  report sentence utility-removing utility-adding
end

to-report utility-when-removing [agent-to-remove]
  ask out-request-to agent-to-remove [die]
  let val utility-function
  create-request-to agent-to-remove
  report val
end

to-report utility-when-adding [agent-to-add]
  create-request-to agent-to-add
  let val utility-function
  ask out-request-to agent-to-add [die]
  report val
end

to-report utility-function
  let preferences ifelse-value is-networker? self
   [beta-outdeg-net * outdegree + beta-rec-net * reciprocity + beta-trans-net * transitivity]
   [beta-outdeg-sat * outdegree + beta-hom-sat * homophily + beta-attract-seniority * seniority-advisors]
  report preferences + random-gamma alpha zeta
end

; network effects


to-report outdegree
  report count my-out-requests
end

to-report reciprocity
  let incoming-requests in-request-neighbors
  report count out-request-neighbors with [member? self incoming-requests]
end

to-report transitivity
   let my-neighbors out-request-neighbors
   report sum [ count out-request-neighbors with [ member? self my-neighbors ] ] of my-neighbors
 end

to-report homophily
  report count out-request-neighbors with [gender = [gender] of myself]
end

to-report seniority-advisors
  report sum [seniority] of out-request-neighbors
end

to-report norm-btw-centrality
  report map [val -> val / ((count turtles - 1) * (count turtles - 2))] [nw:betweenness-centrality] of turtles
end
@#$#@#$#@
GRAPHICS-WINDOW
551
13
1013
476
-1
-1
13.76
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

INPUTBOX
23
90
83
150
n-agents
40.0
1
0
Number

BUTTON
12
33
75
66
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
87
34
150
67
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
160
35
229
68
iterate
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
114
113
286
146
prop-networkers
prop-networkers
0
1
0.5
0.05
1
NIL
HORIZONTAL

INPUTBOX
9
224
106
284
beta-outdeg-sat
-1.0
1
0
Number

TEXTBOX
11
197
161
215
#satisficers (breed1)
11
0.0
1

TEXTBOX
166
196
316
214
#networkers(breed2)
11
0.0
1

INPUTBOX
165
227
270
287
beta-outdeg-net
-1.0
1
0
Number

INPUTBOX
167
299
253
359
beta-rec-net
0.75
1
0
Number

INPUTBOX
166
372
258
432
beta-trans-net
0.75
1
0
Number

INPUTBOX
9
297
101
357
beta-hom-sat
0.5
1
0
Number

INPUTBOX
310
96
404
156
max-links
297.0
1
0
Number

MONITOR
378
500
509
545
possible-number-links
count turtles * (count turtles - 1)
17
1
11

TEXTBOX
304
260
454
288
#parameters for Gamma distr. of shocks
11
0.0
1

SWITCH
457
38
547
71
import?
import?
1
1
-1000

INPUTBOX
299
292
349
352
alpha
0.2
1
0
Number

INPUTBOX
300
362
350
422
zeta
2.0
1
0
Number

BUTTON
355
37
449
70
export-graphml
nw:save-graphml(word random 10000 \"output.graphml\")
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
8
365
131
425
beta-attract-seniority
0.005
1
0
Number

PLOT
562
495
762
645
seniority (networkers)
NIL
NIL
0.0
15.0
0.0
15.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [seniority] of networkers"

PLOT
790
498
990
648
seniority (satisficers)
NIL
NIL
0.0
50.0
0.0
15.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [seniority] of satisficers"

MONITOR
35
499
133
544
# of females
count turtles with [gender = 0]
17
1
11

MONITOR
261
500
355
545
# of males
count turtles with [gender = 1]
17
1
11

BUTTON
238
36
348
69
iterate x 100
repeat 100 [ go ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1229
302
1435
347
local clustering coefficient (median)
ifelse-value any? turtles with [is-number? nw:clustering-coefficient] [median [nw:clustering-coefficient] of turtles] [\"undefined\"]
3
1
11

PLOT
1493
255
1778
405
Local clustering coefficient (distribution)
NIL
NIL
0.0
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 1 -16777216 true "" "histogram [nw:clustering-coefficient] of turtles"

PLOT
1494
72
1778
222
Degree distribution
NIL
NIL
0.0
39.0
0.0
20.0
false
true
"" ""
PENS
"in-degree" 1.0 1 -16777216 true "" "histogram [count my-in-requests] of turtles"
"out-degree" 1.0 1 -5298144 true "" "histogram [count my-out-requests] of turtles"

MONITOR
1234
100
1407
145
in-degree (scaled variance)
variance [count my-in-requests] of turtles / mean [count my-in-requests] of turtles
3
1
11

MONITOR
1236
157
1406
202
out-degree (scaled variance)
variance [count my-out-requests] of turtles / mean [count my-out-requests] of turtles
3
1
11

MONITOR
1229
442
1339
487
# of components
length nw:weak-component-clusters
0
1
11

MONITOR
1359
445
1515
490
Size of largest component
max map count nw:weak-component-clusters
0
1
11

MONITOR
1357
500
1461
545
# communities
length nw:louvain-communities
0
1
11

MONITOR
1473
498
1573
543
Modularity
nw:modularity nw:louvain-communities
3
1
11

PLOT
1488
558
1749
708
Betweenness centrality (distribution)
NIL
NIL
0.0
0.5
0.0
10.0
true
false
"" ""
PENS
"default" 0.01 1 -16777216 true "" "histogram norm-btw-centrality"

MONITOR
1223
609
1433
654
Betweenness centrality (median)
median norm-btw-centrality
3
1
11

TEXTBOX
1292
20
1442
38
Summary statistics
14
0.0
1

TEXTBOX
1077
143
1227
161
Degree distribution
11
0.0
1

TEXTBOX
1082
316
1232
334
Clustering
11
0.0
1

TEXTBOX
1085
488
1235
506
Connectivity
11
0.0
1

TEXTBOX
1087
623
1237
641
Centralisation
11
0.0
1

PLOT
1490
721
1816
871
# homophilous ties (distribution)
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"satisficers" 1.0 1 -1184463 true "" "histogram [homophily] of satisficers"
"networkers" 1.0 1 -10899396 true "" "histogram [homophily] of networkers"

MONITOR
1235
736
1444
781
% homophilous ties
(sum [homophily] of turtles / count requests) * 100
3
1
11

MONITOR
164
501
226
546
density
count requests / (count turtles * (count turtles - 1))
3
1
11

MONITOR
1228
361
1405
406
local clustering coefficient (mean)
ifelse-value any? turtles with [is-number? nw:clustering-coefficient] [mean [nw:clustering-coefficient] of turtles] [\"undefined\"]
3
1
11

TEXTBOX
11
173
258
211
#Preferences of breeds of agents
15
0.0
1

TEXTBOX
15
11
165
36
#Model commands
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="5" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3000"/>
    <metric>count turtles</metric>
    <metric>count requests / (n-agents * (n-agents - 1))</metric>
    <metric>variance [count my-in-requests] of turtles / mean [count my-in-requests] of turtles</metric>
    <metric>variance [count my-out-requests] of turtles / mean [count my-out-requests] of turtles</metric>
    <metric>ifelse-value any? turtles with [is-number? nw:clustering-coefficient] [median [nw:clustering-coefficient] of turtles] ["undefined"]</metric>
    <metric>max map count nw:weak-component-clusters</metric>
    <enumeratedValueSet variable="zeta">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-links">
      <value value="297"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta-outdeg-sat">
      <value value="-1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta-rec-net">
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-agents">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta-trans-net">
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta-outdeg-net">
      <value value="-1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta-hom-sat">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="beta-attract-seniority">
      <value value="0.005"/>
    </enumeratedValueSet>
    <steppedValueSet variable="prop-networkers" first="0.05" step="0.05" last="0.95"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
