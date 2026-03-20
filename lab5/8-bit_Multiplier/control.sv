//Two-always example for state machine

module control (input  logic Clk,
					 input logic Reset,
					 input logic  Run,
                output logic Shift_En, 
					 output logic adding, 
					 output logic substract, 
					 output logic clear_remainder);

    // Declare signals curr_state, next_state of type enum
    // with enum values of a, b, ..., s as the state values
	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
    enum logic [5:0] {a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s }   curr_state, next_state; 

	//flip-flop to store the current state
    always_ff @ (posedge Clk) begin
        if (Reset)
            curr_state <= a;	//reset state to 'a'
        else 
            curr_state <= next_state;	//update current state to next state
    end

    // next state logic
	always_comb begin
		  next_state  = curr_state;
        unique case (curr_state) 

            a :    if (Run)
                       next_state = s;
				s : 	 next_state = b;
            b :    next_state = c;
				c :    next_state = d;
            d :    next_state = e;
				e :    next_state = f;
            f :    next_state = g;
				g :    next_state = h;
				h :    next_state = i;
            i :    next_state = j;
				j :    next_state = k;
				k :    next_state = l;
				l :    next_state = m;
				m :    next_state = n;
            n :    next_state = o;
				o :    next_state = p;
            p :    next_state = q;
				q :    next_state = r;
            r :    if (~Run) 
                       next_state = a;
							  
        endcase
   
		  // Assign outputs based on ‘state’
        case (curr_state) 
	   	   a: 
	         begin
					 clear_remainder = 1'b0;
					 Shift_En 		  = 1'b0;
					 adding          = 1'b0;
					 substract 		  = 1'b0;
		      end
				
				s: 
	         begin
					 clear_remainder = 1'b1;
					 Shift_En 		  = 1'b0;
					 adding          = 1'b0;
					 substract 	     = 1'b0;
		      end
				
	   	   b: 
	         begin
					 clear_remainder = 1'b0;
					 Shift_En        = 1'b0;
					 adding          = 1'b1;
					 substract 	     = 1'b0;
		      end
				
				c: 
	         begin
					 clear_remainder = 1'b0;
					 Shift_En 		  = 1'b1;
					 adding 			  = 1'b0;
					 substract 		  = 1'b0;
		      end
				
				d: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En 		  = 1'b0;
					 adding 			  = 1'b1;
					 substract 		  = 1'b0;
		      end
				
				e: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En 		  = 1'b1;
					 adding 			  = 1'b0;
					 substract 		  = 1'b0;
		      end
				
				f: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En 		  = 1'b0;
					 adding 			  = 1'b1;
					 substract 		  = 1'b0;
		      end
				
				g: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En		  = 1'b1;
					 adding 			  = 1'b0;
					 substract 		  = 1'b0;
		      end
				
				h: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En 		  = 1'b0;
					 adding 			  = 1'b1;
					 substract 		  = 1'b0;
		      end
				
				i: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En 		  = 1'b1;
					 adding			  = 1'b0;
					 substract 		  = 1'b0;
		      end
				
				j: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En 		  = 1'b0;
					 adding 			  = 1'b1;
					 substract 		  = 1'b0;
		      end
				
				k: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En 		  = 1'b1;
					 adding 			  = 1'b0;
					 substract 		  = 1'b0;
		      end
				
				l: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En 		  = 1'b0;
					 adding 			  = 1'b1;
					 substract 		  = 1'b0;
		      end
				
				m: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En        = 1'b1;
					 adding          = 1'b0;
					 substract       = 1'b0;
		      end
				
				n: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En        = 1'b0;
					 adding          = 1'b1;
					 substract       = 1'b0;
		      end
				
				o: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En        = 1'b1;
					 adding          = 1'b0;
					 substract       = 1'b0;
		      end
				
				p: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En        = 1'b0;
					 adding          = 1'b1;
					 substract       = 1'b1;
		      end
				
				q: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En        = 1'b1;
					 adding          = 1'b0;
					 substract       = 1'b0;
		      end
				r: 
	         begin
				    clear_remainder = 1'b0;
					 Shift_En        = 1'b0;
					 adding          = 1'b0;
					 substract       = 1'b0;
				end
				
	   	   default:  //output remain the same
		      begin 
					 clear_remainder = 1'b0;
					 Shift_En        = 1'b0;
					 adding          = 1'b0;
					 substract       = 1'b0;
		      end
				
        endcase
    end

endmodule