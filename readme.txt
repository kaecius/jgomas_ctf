#############################################
############ HOMEWORK 3: JGOMAS #############
#############################################

AUTHORS:
    - Daniel Cañadillas
    - Erlantz Calvo
    - Unai Carbajo

Spent time: 15h


Note: all the new files are variations of an original .asl file:
    jasonAgent_ALLIED.asl   or   jasonAgent_AXIS.asl

TASK 1) Implement an ALLIED agent that shows his position and distance to the flag and his distance to the base.

#########################################################
Created file: "jasonAgent_ALLIED_Pos.asl"
#########################################################

For this first task, we edited the "get_agent_to_aim" plan in the new "jasonAgent_ALLIED_Pos" file, which is executed
every time the agent looks for objects in his Field Of View (FOV). Making use of the beliefs "?mi_position",
"?objective", "?distance?", "?base_position", etc. we managed to print agent's postition, the distance to the flag and 
his distance to the base.

Source code:
    ?my_position(X,Y,Z);
    .println("[TASK - 1] My position: ", math.round(X),", ", math.round(Z));


    ?objective(FlagX,FlagY, FlagZ);
    !distance(pos(FlagX,FlagY,FlagZ)); // Calculate de distance from agent's position to the flag
    ?distance(D);
    .println("[TASK - 1] Distance to the flag: ", math.round(D), " units");


    ?base_position(BaseX,BaseY,BaseZ);
    !distance(pos(BaseX,BaseY,BaseZ)); // Calculate de distance from agent's position to the base
    ?distance(Db);
    .println("[TASK - 1] Distance from the base: ", math.round(Db) , " units" );

#########################################################
#########################################################


TASK 2) Implement a "crazy" AXIS agent that moves randomly.

#########################################################
Created file: "jasonAgent_AXIS_CRAZY_SOLDIER.asl"
#########################################################

First of all we initialized the next beliefs (in the "init" plan): "is_crazy(1)", "rand_mov(1)".

As we made in the first task, we edited the "get_agent_to_aim", in order to make the new soldier move randomly.
This random move is made every 10 ticks, thanks to a belief "rand_mov(N)", where N is the tick count. When the tick
count reaches 10, a random number between 0 and 1 is generated, and based on the value of that number, the soldier
moves "up", "down", "left" or "right", thanks to the next believes: "order(up)", "order(down)", "order(left)" and
"order(right)".

In case that those 10 ticks haven't passed yet, the tick count N is increased, removing and adding a new "rand_mov(N+1)"
belief, and all "order" beliefs are removed.

+!init
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.")};
      -+is_crazy(1);
      -+rand_mov(1).

Source code:

        +!get_agent_to_aim
        <-
        ...
        ?current_task(T);
        ?is_crazy(C);
        ?rand_mov(N);

        if(is_crazy(1) & (N mod 10) == 0){
            -rand_mov(N);
            +rand_mov(1);
            .random(X);
            .println("[TASK - 2] Moving randomly");
            if(X < 1/4){
              -+order(up);  
            }else{
                if(X < 2/4){
                    -+order(right);
                }else{
                    if(X < 3/4){
                        -+order(down); 
                    }else {
                        -+order(left);
                    }
                }
            }
        }else{
            -rand_mov(N);
            +rand_mov(N+1);

            ... .

        +!init
        <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.")};
            -+is_crazy(1);
            -+rand_mov(1).


#########################################################
#########################################################


TASK 3)  Implement an AXIS agent that locates his "crazy" partner and follows him.

#########################################################
Edited file: "jasonAgent_AXIS_CRAZY_SOLDIER.asl"
Created file: "jasonAgent_AXIS_FOLLOW_CRAZY_SOLDIER.asl"
#########################################################

We have created the "jasonAgent_AXIS_FOLLOW_CRAZY_SOLDIER.asl", whose behavour is similar to a regular soldier's one,
but, in this case, he follows his crazy partner who moves randomly.

First of all we made some changes in the crazy soldier's asl. Those changes consist in a new plan
"wanna_follow_crazy_one [source(A)]", which is activated once another soldiers sends him a mesage with that
"wanna_follow_crazy_one" plan. When this plan is executed the crazy agent creates the new belief "wanna_follow_me(A)",
which includes A, the agent that wants to follow the crazy soldier.

In addition to this, the plan "get_agent_to_aim", has been edited. Everytime the tick counter is increased,
the crazy soldier sends to the follower soldier an order to move to his actual position.


Source code ("jasonAgent_AXIS_CRAZY_SOLDIER.asl"):

    ....

    +wanna_follow_crazy_one [source(A)]
    <-
        .println("[TASK - 3] I am the crazy one o.O, follow me!");
        -+wanna_follow_me(A);
        -wanna_follow_crazy_one.

    ....

    +!get_agent_to_aim
    <-
        ....

        if(wanna_follow_me(A)){
                ?wanna_follow_me(A);
                ?my_position(X,Y,Z);
                .concat("order(move,",X,",",Z,")",Content);
                .send_msg_with_conversation_id(A,tell,Content,"INT");
                .println("[Task - 3] Come and protect me!");
                -+wanna_follow_me(A);
            }
        ....   .

#########################################################

In the case of the follower soldier implementation, we started setting some instructions in the "init" plan, which
consist in sending a message to every axis soldier. Then the crazy soldier, which his "wanna_follow_crazy_one" plan will be 
trigger, will register the follower soldier, thus, every tick the crazy soldier will send a message to the
follower soldier with an order to move to his actual position. There is no more implementation in this soldier.



Source code ("jasonAgent_AXIS_FOLLOW_CRAZY_SOLDIER.asl"):

    +!init
    <-  ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.")};
        .my_team("AXIS", E1);
        .println("[TASK - 3] Who is the crazy one??");
        .concat("wanna_follow_crazy_one", Content);
        .send_msg_with_conversation_id(E1,tell,Content,"INT").

Note: whenever the crazy soldier gets stuck in a wall, this follower will stop following him and will continue a
path just like a regular soldier.

#########################################################
#########################################################

TASK 4) Implement an ALLIED agent that locates the “crazy” agent and kills him. The “crazy” agent can defend himself.

#########################################################
Edited file: "jasonAgent_AXIS_CRAZY_SOLDIER.asl"
Created file: "jasonAgent_ALLIES_CRAZY_KILLER.asl"
#########################################################

This task is quite similar to the 3rd task, in fact, the implementation resembles a lot to the crazy solider follower's
one. In this case, instead a new "wanna_kill_crazy_one [source(A)]" plan is created, which will behave as the
task "wanna_follow_crazy_one" plan. This new plan is activated once another soldiers sends him a mesage with that
"wanna_kill_crazy_one" plan. When this plan is executed the crazy agent creates the new belief "wanna_kill_me(A)",
which includes A, the agent that wants to kill the crazy soldier.

In addition to this, the plan "get_agent_to_aim", has been edited. Everytime the tick counter is increased,
the crazy soldier sends to the killer soldier an order to move to his actual position.

Source code ("jasonAgent_AXIS_CRAZY_SOLDIER.asl"):

    ....

    +wanna_kill_crazy_one [source(A)]
    <-
        .println("[TASK - 4] I am the crazy one o.O, try to kill me!");
        -+wanna_kill_me(A);
        -wanna_kill_crazy_one.

    ...

    +!get_agent_to_aim
    <-
        ....

         if(wanna_kill_me(B)){
                ?wanna_kill_me(B);
                ?my_position(X,Y,Z);
                .concat("order(move,",X,",",Z,")",Content1);
                .send_msg_with_conversation_id(B,tell,Content1,"INT");
                .println("[Task - 4] Come and kill me!");
                -+wanna_kill_me(B);
            }
        ....   .

#########################################################

In the case of the killer soldier implementation, we started setting some instructions in the "init" plan, which
consist in sending a message to every axis soldier. Then the crazy soldier, which his "wanna_kill_crazy_one" plan will be
trigger, and will register the killer soldier, thus, every tick the crazy soldier will send a message to the
killer soldier with an order to move to his actual position.

In the original implementation of the crazy soldier he could defends himself, so, there's no extra implementation in the crazy soldier
(neither in the killer soldier).

Source code ("jasonAgent_ALLIED_CRAZY_KILLER.asl"):

    +!init
    <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.")};
            .my_team("AXIS", E1);
            +speak(1);
            .concat("wanna_kill_crazy_one", Content);
            .send_msg_with_conversation_id(E1,tell,Content,"INT").

#########################################################
#########################################################

TASK 5) Include a new task at your choice.

#########################################################
Created file: "jasonAgent_ALLIED_SUPER_SOLDIER.asl"
#########################################################

In this task 5 we created a super soldier (allied):
    - Has no ammo.
    - Has 1000 HP (health points).
    - Has as main objetive take the flag and return to his base.
    - Can't shoot.
    - Can't ask for ammunition.
    - When is under fire the whole teams moves to his position to cover him.

The main changes in the implementation has been made in the initial beliefs and in the plans that dealed with
the soldier's sight and soldier's ammo.

The "ini" plan has been changed in a way that the HP (1000) are set, along with the ammo (0). In addition to this,
a belief "help_ticks(10)" has been defined, that will be used to measure the shots that the soldier has received,
in the case of getting hit 10 times, the whole team will move to his position to help him.

This behave is defined in the "perform_injury_action" plan. Everytime the soldier gets hit, the plan will check if
the counter "H" that is defined in the "help_ticks(H)" belief is 10, in this case, the super soldier will put the
"order(help)" belief, along with the "help_ticks(0)" belief (restarting the counter); so, when the plan "order(help)" 
is triggered, the whole time will go help the super soldier. In the case that the "H" value isn't 10, the belief will 
be removed, and the belief "help_ticks(H+1)" will bet set.

Appart from this, the following plans has been cleared:
    - get_agent_to_aim
    - perform_aim_action

Source code:

    ...

    +!perform_injury_action 
    <- if(help_ticks(10)){
        +order(help);
        -help_ticks(10);
        +help_ticks(0);
    }
    ?help_ticks(H);
    -+help_ticks(H+1).

    ...

    +!init
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR init GOES HERE.")};
   +my_health(1000);
   +my_ammo(0);
   +help_ticks(10).
