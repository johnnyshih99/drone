# Drone
This is a basic drone design. The original problem statement at the bottom.  
The suggested time spent is 1 hour.  
This is really a conceptual design. More than anything else, it showcases OOD and basic programming.  
The code can't really be executed at the current state.  
I'll need to gather more specifications and come up with mocks.  

# Design
For the design I defined x-y plane parallel to the ground and z-axis perpendicular.  
Engine, Gyroscope, Orientation_sensor objects stay simple and follow the requirements.  

## Drone object   
* uses a hash for the engines so that we can use key to store the x-y positions of the engines.  
* gyroscope and orientation_sensor feeds their data into the system.  
* not too sure exactly how pitch and roll affect he aerodynamic of the drone, so I just imagined to make it upright at all time.  
* `move_(direction)` functions incrementally adds force in the specified direction by adjusting the engines' power.  
* For the handtap requirement, without extra sensors I imagined it would be detected by an unexpected/unnatural change in gyro/orientation readings  
* There are a few constant variable defined. Arbitrary numbers were given to them but we can also make them customizable.  

# Original Problem Statement
build an application that flies a drone with the following Requirements:  

* drone has n engines
* drone has one gyroscope
* drone has one orientation sensor
* orientation sensor provides the pitch and the roll 
* gyroscope has 3 vectors (x, y ,z) and provides you the velocity on each of these vectors
* an engine has a power indicator from 0 to 100
* an engine has a status (off, on)
* the drone has a status (off, hovering, moving)

for simplicity sake:  
* the drone has 4 engines
* the pitch is aligned to the x axis
* the roll is aligned to the y axis

methods to implement:  
* take_off(take the drone in the air)
* move_[forward, left, right, back, up, down]
* stabilize(makes the drone hover)
* status(gives the current status of the drone)
* land(stabilizes and goes down at reduce speed)
 

if an engine breaks ( goes off ), the drone will send a distress signal and start landing (use STDOUT for distress signal)  

if the drones fails to take off it sends a distress signal (use STDOUT for distress signal)  

If I tap the drone with my hand it should correct itself and hover instead of crashing  
