extensions [ pathdir netprologo]

turtles-own [  ] 

patches-own [ pellet-grid?  territorio]  ;; true/false: is a pellet here initially?

breed [ pellets pellet ]
pellets-own [ powerup? ]


breed [ pacmans pacman  ]
pacmans-own  [ new-heading scared home-x home-y name]



globals [
  score         ;; your score


 


  left-team-file
  right-team-file

  pastilhas-esquerda
  pastilhas-direita
  
  left-color
  right-color

  clock-fino
  
  winner
]




to initialize-prolog
  ; We initialize Prolog by sending a query to load a .PL file
  ; (see info tab for the prolog code)
  ; (see extension doc for the meaning of netprologo:run-query)
  if not netprologo:run-query  (trans (word "consult('" pathdir:get-current pathdir:get-separator left-team-file "')")  ) ;;;; unix e windows path problems
 

  [
    user-message word "Error loading prolog file " left-team-file
  ]
    if not netprologo:run-query (trans (word "consult('" pathdir:get-current pathdir:get-separator right-team-file "')")  ) ;;;; unix e windows path problems
 
  [
    user-message word "Error loading prolog file " right-team-file
  ]
end

to-report trans [str]
  ifelse empty? str
    [report ""]
    [report word (tt first str) (trans (butfirst str))]
end

to-report tt [Elem]
  ifelse Elem = "\\"
    [report "\\\\"]
    [report Elem]
end

;;;
;;; the asked agent info
;;;
to-report agent
  report (word "(" name "," xcor "," ycor "," heading "," scared ")")
end

;;;
;;; the free cells
;;;
to-report free-cells
  report (word "[" (butlast reduce word map xx ([list pxcor pycor] of patches with [pcolor = 0 and pxcor > -10 and pxcor < 9])) "]")
end

;;
;; info about my colleague
;;
to-report my-colleague
  let him who-is-my-colleague
  report (word "(" [name] of him "," [xcor] of him "," [ycor] of him "," [heading] of him "," [scared] of him ")")
end


;;
;; who is my colleague
;;
to-report who-is-my-colleague
  report one-of other (pacmans with [color = [color] of myself])
end

;;
;; where are my pellets
;;
to-report my-pastilhas
  let my-pasti (word "[" "]")
  if any? pellets with [not hidden? and not powerup? and color = [color] of myself]
       [set my-pasti (word "[" (butlast reduce word map xx ([list xcor ycor] of pellets with [not hidden? and not powerup? and color = [color] of myself])) "]")]
   report my-pasti
end


;;
;; where are my super-pellets
;;
to-report my-super-pastilhas
  let my-super-pasti (word "[" "]")
      if any? pellets with [not hidden? and powerup? and color = [color] of myself]
       [set my-super-pasti (word "[" (butlast reduce word map xx ([list xcor ycor] of pellets with [not hidden? and powerup? and color = [color] of myself])) "]")]
  report my-super-pasti
end


;;
;; where are his pellets
;;
to-report his-pastilhas
  let my-pasti (word "[" "]")
  if any? pellets with [not hidden? and not powerup? and color != [color] of myself]
       [set my-pasti (word "[" (butlast reduce word map xx ([list xcor ycor] of pellets with [not hidden? and not powerup? and color != [color] of myself])) "]")]
   report my-pasti
end

;;
;; where are his super-pellets
;;
to-report his-super-pastilhas
  let my-super-pasti (word "[" "]")
      if any? pellets with [not hidden? and powerup? and color != [color] of myself]
       [set my-super-pasti (word "[" (butlast reduce word map xx ([list xcor ycor] of pellets with [not hidden? and powerup? and color != [color] of myself])) "]")]
  report my-super-pasti
end

;;
;; who is the other team
;;
to-report other-team
  let ag0 one-of pacmans with [(color != [color] of myself)]
 ; show ag0
  let ag1 one-of pacmans with [(color != [color] of myself) and name != [name] of ag0]
 ; show ag1
  report (word "[" 
                 "(" [name] of ag0 "," [xcor] of ag0 "," [ycor] of ag0 "," [heading] of ag0 "," [scared] of ag0 ")"
               ","
                 "(" [name] of ag1  "," [xcor] of ag1 "," [ycor] of ag1 "," [heading] of ag1 "," [scared] of ag1 ")"
               "]")
end

to-report my-team
  ifelse color = left-color
    [report left-team]
    [report right-team]
end

to-report my-base
   report (word "(" home-x "," home-y ")") 
end

to-report his-base
  let ag0 one-of pacmans with [(color != [color] of myself)]
  report (word "(" [home-x] of ag0 "," [home-y] of ag0 ")") 

end

;;;
;;;  So' passa a posicao do pacman e dos fantasmas + as casas do labirinto navegaveis
;;;
to zigzag-me
  
      let prolog-query (build-function-call (list (word "pacman" my-team) ticks level-limit Score agent my-colleague other-team my-base his-base free-cells my-pastilhas my-super-pastilhas  his-pastilhas his-super-pastilhas "Decisao"))
      
       if show-prolog?
        [ ;show "agent"
          ;show agent
          ;show "fantasmas"
          ;show my-colleague
          ;show "labirinto"
          ;show free-cells
          ;show "pastilhas"
          ;show my-pastilhas
          ;show "super-pastilhas"
          ;show my-super-pastilhas
          show prolog-query

        ]   

;let prolog-query (netprologo:build-prolog-call "knights(?1, X)" board-size)
  ifelse not netprologo:run-query prolog-query  
   [if show-prolog? [show "query failed"]] 
  ; Second: take the first solution from the previous query
   [let rn netprologo:run-next
    let out netprologo:dereference-var "Decisao"
    ;show out
    set new-heading out] 
    
  
 ; ]

end



; Report to build the function call as a string of the form:
;  [F x1 x2 ... xn] -> "F(x1,x2,...,xn)"
to-report build-function-call [l]
  ; Get the "name" of the function
  let func first l

  ; Build the list of arguments separated by commas
  let arg reduce [(word ?1 "," ?2)] (bf l)
  
  ; report the resulting string
  report (word func "("arg ")")
end



to-report xx [l]
  
  report (word "(" first l "," first butfirst l ")" ",")
 
end

to-report xxx [l]
  let l1 list (item 0 l) (item 1 l)
  let v3 item 2 l
  report (word "(" (xx l1) v3 "),")
end

to-report xxxx [l]
  let l1 list (item 0 l) (item 1 l)
  let v3 item 2 l
  let v4 item 3 l
  report (word "(" (xx l1) v3 "," v4 "),")
end


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; begin game
;;;
to new  ;; Observer Button

  clear-all


  load-map
 


 end

to new-game
    ;;NOSSO CODIGO
  

; set id-left-team read-from-string remove ".pl" remove "teampac" left-team
  
;  set id-right-team read-from-string remove ".pl" remove "teampac" right-team 
  
  set left-team-file (word "teampac" left-team ".pl")

  set right-team-file (word "teampac" right-team ".pl")
  
  initialize-prolog  ;;; initialize Prolog in the beginning only...
  
  ask pacmans [setxy home-x home-y set scared 0 set shape "ghost"]

  ask pellets [show-turtle]
  
  set score 0
  set clock-fino 0
  reset-ticks
  
   random-seed new-seed
 
  set left-color red
  set right-color 95  
  
  set pastilhas-esquerda count pellets with [color = left-color]
  set pastilhas-direita count pellets with [color = right-color]
  set winner ""
end

to desloca
  foreach [0 1 2 3 4 5 6 7 8 9] 
    [ask patches with [pxcor = ?] [set pcolor [pcolor] of patch (? + 1) pycor]]
  ask pellets with [color = right-color] 
     [set xcor xcor - 1]
     
end

to desloca-direita-1casa [x y ]
  
  ask patch x y   [set pcolor  [pcolor] of patch (x + 1) y]
end



;;;
;;; load the map correspondant to the level
;;;
to load-map  ;; Observer Procedure
  
  ;; Filenames of Level Files
  let maps [;"pacmap1.csv"  
            "captureDiFlag.csv"]


 
;  let current-difficulty difficulty
   import-world item 0 maps
   set score 0
  


end



;;;;
;;;; my territory
;;
to-report my-territory?
  report (color = left-color and xcor < 0) or
         (color = right-color and xcor >= 0)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Runtime Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;;
;; fim do jogo se uma das equipas tiver menos do que 3 pellets
;;
;;
to-report the-end?
  report pastilhas-direita < 3 or pastilhas-esquerda < 3 or ticks = 300
end


;;; Faz  or report da vitoria
;;
to report-vitoria
  ifelse score = 0 
    [set winner"DRAW"]
    [set winner vencedor]
end


;; Ok o vencedor eh
;;
to-report vencedor
  if pastilhas-esquerda < pastilhas-direita
    [report right-team]
  if pastilhas-esquerda > pastilhas-direita
    [report left-team]
end


;;  
;;  one playing step
;;
to play  ;; Observer Forever Button
  ;; Only true at this point if you died and are trying to continue
  if the-end? [report-vitoria stop]
  tick
 
  move-pacman

  display
end


;;;
;;; O pacman move-se
;;;
to move-pacman  ;; Observer Procedure

  ask pacmans
  [ ;; move forward unless blocked by wall
    set clock-fino clock-fino + 1          ;; the asyncronous clock
    if scared > 0 [set scared scared - 1]  ;;;; decrement scared in each tick
    display
    let old-heading heading
    ;set new-heading one-of [0 90 180 270]
    
    zigzag-me  ; pacman choose heading (Prolog)
    set heading new-heading
    if [pcolor] of patch-ahead 1 != black
       [ set heading old-heading ]
    if [pcolor] of patch-ahead 1 = black
      [ fd 1 ]
    action-effects
  ]
end


;;
;; the effects of actions after activaton of shapes
;; that depend on the role: his territory or on the adversary's
;; as a ghost is he scared or not scared, etc etc
;;
to action-effects
  ifelse my-territory?
    [ifelse scared > 0
      [set shape "scared"
       behave-scared-ghost]
      [set shape "ghost"
       behave-non-scared-ghost]]
    [ifelse shape = "pacman"   
 ;; Animation -opening and closing the mouth
      [ set shape "pacman open" ]
      [ set shape "pacman" ]
     behave-pacman]
end


;;
;; behave as a pacman
;; if pacman in the same cell with a scared and a non-scared ghost
;; the sacred one will go into the base and pacman also into his base
;;
to behave-pacman
   if any? pacmans-here with [scared = 0 and color != [color] of myself ];; the scared are already in the base
            [go-to-base]
      if any? pellets-here with [not hidden?]
      [ if [powerup?] of one-of pellets-here with [not hidden?]
         [ his-ghosts-are-scared]
         ask pellets-here [ hide-turtle ]
         update-score]
        ask pacmans-here with [color != [color] of myself and scared > 0] 
             [go-to-base]
       
end


;;
;; the scared ghost behave
;;
to behave-scared-ghost
  if any? (pacmans-here with [color != [color] of myself])
      [go-to-base]
end


;;
;; The non scared ghost do their behavior
;;
to behave-non-scared-ghost
  if any? (pacmans-here with [color != [color] of myself])
      [ask pacmans-here with [color != [color] of myself]
         [go-to-base]]
end


;;
;; the other pacmans will be scared for 40 ticks
;;
to his-ghosts-are-scared
  ask pacmans with [color != [color] of myself]
    [set scared 40]
end


;;
;; update score and update pastilhas
;;
to update-score
  ifelse color = left-color
    [set score score + 1
     set pastilhas-direita pastilhas-direita - 1]
    [set score score - 1
     set pastilhas-esquerda pastilhas-esquerda - 1]
end



;;
;; pacman return to the base
;;
to go-to-base
  setxy home-x home-y
  set shape "ghost"
  set scared 0
end













; Copyright 2001 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
244
10
695
482
10
10
21.0
1
10
1
1
1
0
0
0
1
-10
10
-10
10
1
1
1
ticks
30.0

MONITOR
30
322
140
367
Score
score
0
1
11

BUTTON
14
14
124
47
Load-Maze
new
NIL
1
T
OBSERVER
NIL
N
NIL
NIL
1

BUTTON
120
93
230
126
Play
play
T
1
T
OBSERVER
NIL
P
NIL
NIL
1

BUTTON
18
93
116
126
NIL
play\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
28
53
201
86
level-limit
level-limit
0
300
300
1
1
NIL
HORIZONTAL

SWITCH
42
134
190
167
show-prolog?
show-prolog?
1
1
-1000

MONITOR
128
258
220
303
right-pastilhas
pastilhas-direita
0
1
11

MONITOR
27
257
113
302
left-pastilhas
pastilhas-esquerda
0
1
11

MONITOR
144
323
209
368
NIL
clock-fino
0
1
11

INPUTBOX
18
192
112
252
left-team
0
1
0
Number

INPUTBOX
117
192
214
252
right-team
1000
1
0
Number

BUTTON
128
13
217
46
NIL
new-game
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
75
377
161
422
The winner is
Winner
0
1
11

@#$#@#$#@
## WHAT IS IT?

This is the classic arcade game, Pac-Man.  The game involves navigating Pac-Man through a maze.  Your objective is that Pac-Man eat all of the pellets (white circles), while avoiding the ghosts that pursue him.

If a ghost ever catches Pac-Man then Pac-Man is defeated.  If this occurs, the level will reset, but this will happen only if Pac-Man still has some lives remaining. (The pellets already collected on the level remain collected.)

However, when Pac-Man eats a Power-Pellet (large white circle) he can turn the tide, and the ghosts will turn scared and flee from him, for with the power of the Power-Pellet, Pac-Man can eat the ghosts!  Once a ghost is eaten it will return to its base, where it is born again, immune to the Power-Pellet until Pac-Man can find a new one to consume.  Pac-Man had better do just that, because unfortunately, the power of the Power-Pellet does not last forever, and will begin to wear off over time. (You will see the ghosts start to flash back to their normal appearance during the last few seconds of the Power-Pellet's effectiveness.)

Finally, occasionally a bonus (rotating star) will appear in the maze.  This bonus gives Pac-Man extra points if he eats it, but it will disappear if Pac-Man doesn't get it within a limited amount of time.

There are 5 levels in this Pacman, a different maze for each one and 2 levels of difficulty, one where the ghosts are slower than Pac-Man and another where they have the same speed.

There os also a limit number of moves in each level so that the game does not last forever and in each time step Pac-Man looses 10 score units. 

## HOW TO USE IT

Monitors
-- SCORE shows your current score.  You get points for collecting pellets, eating ghosts, and collecting bonuses.  You will get an extra life after every 35,000 points.
-- LEVEL shows your current level.  Each level has a different map, if you complete all the maps, it will loop back to the first map and continue.
-- LIVES shows how many extra lives you have remaining.  If you are defeated by a ghost when this is at 0, the game is over.

Sliders
-- LIM-DIFFICULTY controls the maximum speed of the ghosts.  In each tick pacman moves.Lower numbers make the ghosts move slowly. There is a variable that DIFFICULTY that can have at most the LIM-DIFFICULTY, starting at 1. If DIFFICULTY is 1 it means ghosts move every 2 ticks and DIFFICULTY 2 means ghosts move at the same speed of pacman (at every tick).

Buttons
-- NEW sets up a new game on level 1, with 3 lives, and a score of 0.
-- PLAY begins the game.  The game will pause 1 second after each level, so you will need to hit PLAY again after each level to continue.


## THINGS TO NOTICE

If you go off the edge of the maze you will wrap around to the other side.

Identifying Things in the Maze:
-- Yellow Circle with a mouth:  This is Pac-Man - you.
-- White Circles:
               These are Pellets - Collect all of these (including the Power-Pellets) to move on to the next level.

-- Large White Circles:
         These are Power-Pellets - They allow you to eat the Ghosts for a limited ammount of time.

-- Blue Squares:
                These are the walls of the maze - Neither Pac-Man nor the Ghosts can move through the walls.

-- Gray Squares:
                These are the Ghost Gates - Only Ghosts can move through them, and if they do so after having been eaten they will be healed.

-- Rotating Colored Stars:
      These are Bonus Stars - They give you extra points when you eat them.

-- Colorful Ghost with Eyes:
    These are the active Ghosts - Watch out for them!

-- Blue Ghost Shape:
            These are the scared Ghosts - Eat them for Extra Points! A Ghost is scared during 50 ticks.

-- Two Small Eyes:
              These are the Ghosts after they've been eaten - They will not affect you, and you can't eat them again, so just ignore them, but try not to be near its base when it gets back there.

-- There is a time limit for each level:
Each level must not exceed 500 ticks otherwise pacman looses a life

Scoring System
-- Eat a Pellet:
       100 Points

-- Eat a Power-Pellet: 500 Points
-- Eat a Scared Ghost: 500 Points
-- Eat a Bonus Star:   100-1000 Points (varies)
-- Each pacman move makes it loose score: 5 units. 

## THINGS TO DO

Write an automated program for Pac-Man that will get him safely through the maze and collect all the pellets, in every level and in each level covering both difficulty levels: 1 and 2.
The program should be written in Prolog with predicate called pacman/13.
pacman(Time, LevelLim, Score, Level, Difficulty, Lives, PacManPos, PacManHead,  PowerPellets, Maze, Ghosts, Scared, Pellets, Bonus, NewHeading).

1. Time: an integer, the number of ticks
2. LevelLim: the limited ticks level
3. Score: an integer
4. Level: the level of the game (different maze for each level)
5. Difficulty: the difficulty level (1 or 2). 1 means moving ghosts move every 2 ticks and 2 means ghosts move in every tick (as fast as pacman)
6. Lives: the number of lives to use.
7. PacManPos: a list with xcor and ycor of pacman (xcor,ycor)
8. PacManHead: the heading of pacman (0, 90, 180 or 270)
9. Maze: a list with all the valid maze cells; a list of (x,y) 
10. Ghosts: a list with all not eaten ghosts; a list of ghosts info given by ((x,y),eaten?)
11. Scared: how much more time left where ghosts are scared, 0 means they are not scared
12. Pellets: a list with all the pellets not eaten, each pellet is given by a list with the coordinates xcor and ycor: (xcor,ycor)
13. PowerPellets: a list with all the PowerPellets, where each PowerPellet is given by (x,y)
14. Bonus: a list of three element lists. Each Bonus is defined by a 3-tuple where the first is its position, and then its value and life time. Position is a pair (x,y). Something like ((x,y),value,countdown)
15. OutParameter - NewHeading: should be one of {0, 90, 180, 270} 


## EXTENDING THE MODEL


## NETLOGO FEATURES

This model makes use of breeds, create-<breed>, and user-message.

The "import-world" command is used to read in the different maze configurations (levels).


## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

* Wilensky, U. (2001).  NetLogo Pac-Man model.  http://ccl.northwestern.edu/netlogo/models/Pac-Man.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

This work was adpated by PauloU from Uri Wilensky's original PacMan model. It uses Netprologo and pathdir extensions in order to program in Prolog an autonomous pacman agent.

Copyright 2014 PauloU.

The original model:

Copyright 2001 Uri Wilensky.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227.
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
Circle -7500403 true true 45 45 210

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

eyes
false
0
Circle -1 true false 62 75 57
Circle -1 true false 182 75 57
Circle -16777216 true false 79 93 20
Circle -16777216 true false 196 93 21

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

ghost
false
0
Circle -7500403 true true 61 30 179
Rectangle -7500403 true true 60 120 240 232
Polygon -7500403 true true 60 229 60 284 105 239 149 284 195 240 239 285 239 228 60 229
Circle -1 true false 81 78 56
Circle -16777216 true false 99 98 19
Circle -1 true false 155 80 56
Circle -16777216 true false 171 98 17

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

pacman
true
0
Circle -7500403 true true 0 0 300
Polygon -16777216 true false 105 -15 150 150 195 -15

pacman open
true
0
Circle -7500403 true true 0 0 300
Polygon -16777216 true false 270 -15 149 152 30 -15

pellet
true
0
Circle -7500403 true true 105 105 92

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

scared
false
0
Circle -7500403 true true 61 30 179
Rectangle -7500403 true true 60 120 240 232
Polygon -7500403 true true 60 229 60 284 105 239 149 284 195 240 239 285 239 228 60 229
Circle -16777216 true false 81 78 56
Circle -16777216 true false 155 80 56
Line -16777216 false 137 193 102 166
Line -16777216 false 103 166 75 194
Line -16777216 false 138 193 171 165
Line -16777216 false 172 166 198 192

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
new
@#$#@#$#@
@#$#@#$#@
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
