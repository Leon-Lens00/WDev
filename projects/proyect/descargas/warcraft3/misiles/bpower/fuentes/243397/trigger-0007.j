//TESH.scrollpos=0
//TESH.alwaysfold=0
                                        
                                        
                                        /* This is a detailed instruction how to import Frozen Orb*/
                                        ------------------------------------------------------------

                1. Import the "Frozen Orb" script and "library Missile" into your map.
                
                2. Missile uses a unit called "particle" and a imported modelfile called war3mapImported\dummy.mdx. Copy the unit and the modelfile into your map 
                   Inside the Missile library you have to set "public constant DUMMY_UNIT_ID" to the correct raw of particle in your map.
                
                3. Follow the instructions inside the Frozen Orb scope for proper and optimal configuration and spell usage.
                
                4. Hint: Read Missile API carefully to make perfect use of projectile behaviour in your map. ( i.e. destructable collision, ...  )
                
                                                        /*End of Instruction*/
                
                A. How do I get raw codes ?
                B. I want to apply something else than slow effect on hit, is that possible?
                
                A: Go to the object editor, Press CTRL + D. The raw code is written before the unit,abilty, buff, name. e.g. for Particle it is 'h000'.
                B: Ofc e.g. you want to apply purge. Find purge in the object editor, set cooldown to 0, mana costs to 0 , range to 99999. Look up the OrderId of purge: 852111
                   Find all order ids in this demo map in scope OrderIds. They were published by Nestharus and can also be found in his github account.
                   Set everything correctly in the Frozen Orb scope
                   private constant integer BUFF_ABILITY  = 'enter purge raw code here' 
                   private constant integer BUFF_ORDER_ID =  enter purge OrderId here

                
                