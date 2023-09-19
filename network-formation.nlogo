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
  let current-utility objective-function
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
  let utility-removing map [ agent-to-remove -> utility-when-removing agent-to-remove ] current-advisors
  let utility-adding map [ agent-to-add -> utility-when-adding agent-to-add ] potential-advisors
  report sentence utility-removing utility-adding
end

to-report utility-when-removing [ agent-to-remove ]
  ask out-request-to agent-to-remove [ die ]
  let val objective-function
  create-request-to agent-to-remove
  report val
end

to-report utility-when-adding [ agent-to-add ] 
  create-request-to agent-to-add
  let val objective-function
  ask out-request-to agent-to-add [ die ]
  report val
end

to-report objective-function
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
  report count out-request-neighbors with [ member? self incoming-requests ]
end

to-report transitivity
   let my-neighbors out-request-neighbors
   report sum [ count out-request-neighbors with [ member? self my-neighbors ] ] of my-neighbors
 end

to-report homophily
  report count out-request-neighbors with [ gender = [ gender ] of myself ] 
end

to-report seniority-advisors
  report sum [ seniority ] of out-request-neighbors
end

to-report norm-btw-centrality
  report map [ val -> val / ((count turtles - 1) * (count turtles - 2)) ] [ nw:betweenness-centrality ] of turtles
end
