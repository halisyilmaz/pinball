module pinball(clk, clk_vga, vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B, start, breaker);

input clk, start, breaker; //left_button,right_button;
output reg [7:0] vga_R;
output reg [7:0] vga_G;
output reg [7:0] vga_B;

output vga_h_sync, vga_v_sync;

//VGA
output reg clk_vga;
reg [9:0] count_x;
reg [9:0] count_y;
reg vga_v;
reg vga_h;

//Ball Movement
reg [32:0] ball_x;
reg [32:0] ball_y;
parameter ball_r=10;
reg x_direction; //0: Left 1:Right
reg y_direction;	//0: Up 1:Down
reg [32:0] x_speed;	//Ball x speed Higher is Slower
reg [32:0] y_speed;	//Ball y speed Higher is Slower
reg [32:0] speed_counter_x;
reg [32:0] speed_counter_y;
reg temp_direction;
reg [32:0] temp_speed;

//Flipper
reg [32:0] left_deg;
reg [32:0] right_deg;
reg [32:0] left_x;
reg [32:0] left_y;
reg [32:0] right_x;
reg [32:0] right_y;

//TARGETS
parameter target_r=19;

//Red Target (10 Pts)
reg [32:0] red1_x;
reg [32:0] red1_y;

reg [32:0] red2_x;
reg [32:0] red2_y;

//Green Target (-15 Pts)
reg [32:0] green1_x;
reg [32:0] green1_y;

reg [32:0] green2_x;
reg [32:0] green2_y;

//Blue Target (Hexagon)
reg [32:0] blue1_x;
reg [32:0] blue1_y;

reg [32:0] blue2_x;
reg [32:0] blue2_y;


//Game & Score
reg gameover;
reg [9:0] score;

//Timer
reg [26:0] count_25;
reg [8:0] count_second;

reg [8:0] a0,a1,a2;
reg b1,b2,b3,b4,b5,b6,b7;
reg b11,b22,b33,b44,b55,b66,b77;
reg b111,b222,b333,b444,b555,b666,b777;
wire [9:0] a00,a11,a22;

//Scoreboard
reg [8:0] s0,s1,s2;
reg c1,c2,c3,c4,c5,c6,c7;
reg cc1,cc2,cc3,cc4,cc5,cc6,cc7;
reg ccc1,ccc2,ccc3,ccc4,ccc5,ccc6,ccc7;
wire[9:0] s00,s11,s22;

//Random
reg [7:0] random_num_1;
reg [7:0] random_num_2;
reg [7:0] random_num_3;
reg [7:0] random_num_4;
reg [7:0] random_num_5;
reg [7:0] random_num_6;
reg [7:0] random_num_7;
reg [7:0] random_num_8;
reg [7:0] random_num_9;
reg [7:0] random_num_10;
reg [7:0] random_num_11;
reg [7:0] random_num_12;
reg [7:0] random_num_13; //Rand Position
reg [7:0] random_num_14; //Rand X Direction
reg [7:0] random_num_15; //Rand Y Direction

//All Initializations
initial begin

//VGA Initializations
count_x=0;
count_y=0;
clk_vga=0;

//Ball
ball_x=395+144;
ball_y=395+35;
x_direction=0;
y_direction=0;
x_speed=300000;
y_speed=100000;
temp_speed=100000;
speed_counter_x=0;
speed_counter_y=0;
//temp_direction=0;
//temp_speed=0;

//Flipper
left_deg=0;
right_deg=0;
left_x=300+144;
left_y=480+35;
right_x=340+144;
right_y=480+35;

//Red Target (10 Pts)
red1_x=87+144+160;
red1_y=95+35;

red2_x=232+144+160;
red2_y=251+35;

//Green Target (-15 Pts)
green1_x=123+144+160;
green1_y=300+35;

green2_x=221+144+160;
green2_y=130+35;

//Blue Target (Hexagon)
blue1_x=150+144+160;
blue1_y=125+35;

blue2_x=57+144+160;
blue2_y=184+35;

//Score & Timer
score=10'b0000000000;

gameover=1;

count_25=0;
count_second=0;

//Random
random_num_1=8'b0;
random_num_2=8'b0;
random_num_3=8'b0;
random_num_4=8'b0;
random_num_5=8'b0;
random_num_6=8'b0;
random_num_7=8'b0;
random_num_8=8'b0;
random_num_9=8'b0;
random_num_10=8'b0;
random_num_11=8'b0;
random_num_12=8'b0;
random_num_13=8'b0;
random_num_14=8'b0;
random_num_15=8'b0;

end


//25MHz Clock
always@(posedge clk) begin //25Mhz Clk
clk_vga<=!clk_vga;
end


//VGA Syncronization
always @(posedge clk_vga)
begin
	if (count_x<799)
		count_x = count_x + 10'b0000000001;
	else 
		begin
			count_x = 0;
			if(count_y < 524)
				count_y = count_y + 10'b0000000001;
			else
				count_y = 0;
		end	
	if (count_x < 96) 
		vga_h = 0;
	else
		vga_h = 1;
	if(count_y < 2) //burayi kontrol et
		vga_v = 0;
	else
		vga_v = 1;
end

assign vga_h_sync = vga_h;
assign vga_v_sync = vga_v;

//Game Interactions
always @ (posedge clk) begin
	if(gameover==0) begin
	
		//Border Interactions
		
		if ((ball_x==170+144)) //left border
			begin
			x_direction<=1;
			end
		else if (ball_x ==470+144)		// right border
			begin
			x_direction<=0;
			end
		else if (ball_y==11+35)		// top border
			begin
			y_direction<=1;
			end

/************************************************
		else if ((ball_y==11+35+340)&(y_direction==1))		// top border
			begin
			y_direction<=0;
			end			
************************************************/			
			
	
		else if ((ball_y>340+35)&(ball_y<440+35)&(ball_y==340+35-(160+144)-10+ball_x))	//Left Bottom Border
			begin
			x_direction<=1;
			y_direction<=1;
			x_speed<=125000;
			y_speed<=125000;
			end
		else if((ball_y>340+35)&(ball_y<440+35)&(ball_y==480+340+144+35-10-ball_x))	//Right Bottom Border
			begin
			x_direction<=0;
			y_direction<=1;
			x_speed<=125000;
			y_speed<=125000;
			end
		
		//TARGET INTERACTIONS
		
			//RED TARGET 1
				else if((ball_y==red1_y-(target_r+ball_r))&&(ball_x>red1_x-6)&&(ball_x<red1_x+6)) begin // Top
					ball_y<=ball_y-1;
					y_direction<=0;
					score<=score+10'b0000001010;
				end else if((ball_y==red1_y+(target_r+ball_r))&&(ball_x>red1_x-6)&&(ball_x<red1_x+6)) begin //Bottom
					ball_y<=ball_y+1;
					y_direction<=1;
					score<=score+10'b0000001010;
				end else if((ball_x==red1_x-(target_r+ball_r))&&(ball_y>red1_y-6)&&(ball_y<red1_y+6)) begin  // Left 
					ball_x<=ball_x-1;
					x_direction<=0;
					score<=score+10'b0000001010;
				end else if((ball_x==red1_x+(target_r+ball_r))&&(ball_y>red1_y-6)&&(ball_y<red1_y+6)) begin  // Right
					ball_x<=ball_x+1;
					x_direction<=1;
					score<=score+10'b0000001010;
				end else if((ball_y==(red1_y+red1_x+24+10-ball_x)) && (ball_x>=red1_x+6) && (ball_y>=red1_y+6)) begin	//Right_bottom border
					if((x_direction==0) && (y_direction==0)) begin		//left-up direction
					ball_x<=ball_x+1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=1;
					y_direction<=1;
					score<=score+10'b0000001010;
					end
					else begin		
					ball_x<=ball_x+1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					score<=score+10'b0000001010;
					end
				end
				else if((ball_y==(red1_y-red1_x+24+10+ball_x)) && (ball_x<=red1_x+6) && (ball_y>=red1_y+6))begin	//Left bottom border
					if((x_direction==1) && (y_direction==0))begin		//right-up direction
					ball_x<=ball_x-1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=0;
					y_direction<=1;
					score<=score+10'b0000001010;
					end
					else begin
					ball_x<=ball_x-1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					score<=score+10'b0000001010;
					end
				end
				else if((ball_y==(red1_y+red1_x-24-10-ball_x))&& (ball_x<=red1_x-6) && (ball_y<=red1_y-6))begin	//Left top border
					if((x_direction==1) && (y_direction==1))begin		//right-down direction
					ball_x<=ball_x-1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=0;
					y_direction<=0;
					score<=score+10'b0000001010;
					end
					else begin		//right-up direction
					ball_x<=ball_x-1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					score<=score+10'b0000001010;
					end
				end
				else if((ball_y==(red1_y-red1_x-24-10+ball_x)) && (ball_x>=red1_x+6) && (ball_y<=red1_y-6))begin	//Right Top  border
					if((x_direction==0) && (y_direction==1))begin		//left-down direction
					ball_x<=ball_x+1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=1;
					y_direction<=0;
					score<=score+10'b0000001010;
					end
					else begin
					ball_x<=ball_x+1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					score<=score+10'b0000001010;
					end
				end

			
			//RED TARGET 2
				else if((ball_y==red2_y-(target_r+ball_r))&&(ball_x>red2_x-6)&&(ball_x<red2_x+6)) begin // Top
					ball_y<=ball_y-1;
					y_direction<=0;
					score<=score+10'b0000001010;
				end else if((ball_y==red2_y+(target_r+ball_r))&&(ball_x>red2_x-6)&&(ball_x<red2_x+6)) begin //Bottom
					ball_y<=ball_y+1;
					y_direction<=1;
					score<=score+10'b0000001010;
				end else if((ball_x==red2_x-(target_r+ball_r))&&(ball_y>red2_y-6)&&(ball_y<red2_y+6)) begin  // Left 
					ball_x<=ball_x-1;
					x_direction<=0;
					score<=score+10'b0000001010;
				end else if((ball_x==red2_x+(target_r+ball_r))&&(ball_y>red2_y-6)&&(ball_y<red2_y+6)) begin  // Right
					ball_x<=ball_x+1;
					x_direction<=1;
					score<=score+10'b0000001010;
				end else if((ball_y==(red2_y+red2_x+24+10-ball_x)) && (ball_x>=red2_x+6) && (ball_y>=red2_y+6)) begin	//Right_bottom border
					if((x_direction==0) && (y_direction==0)) begin		//left-up direction
					ball_x<=ball_x+1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=1;
					y_direction<=1;
					score<=score+10'b0000001010;
					end
					else begin		
					ball_x<=ball_x+1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					score<=score+10'b0000001010;
					end
				end
				else if((ball_y==(red2_y-red2_x+24+10+ball_x)) && (ball_x<=red2_x+6) && (ball_y>=red2_y+6))begin	//Left bottom border
					if((x_direction==1) && (y_direction==0))begin		//right-up direction
					ball_x<=ball_x-1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=0;
					y_direction<=1;
					score<=score+10'b0000001010;
					end
					else begin	
					ball_x<=ball_x-1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					score<=score+10'b0000001010;
					end
				end
				else if((ball_y==(red2_y+red2_x-24-10-ball_x))&& (ball_x<=red2_x-6) && (ball_y<=red2_y-6))begin	//Left top border
					if((x_direction==1) && (y_direction==1))begin		//right-down direction
					ball_x<=ball_x-1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=0;
					y_direction<=0;
					score<=score+10'b0000001010;
					end
					else begin		//right-up direction
					ball_x<=ball_x-1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					score<=score+10'b0000001010;
					end
				end
				else if((ball_y==(red2_y-red2_x-24-10+ball_x)) && (ball_x>=red2_x+6) && (ball_y<=red2_y-6))begin	//Right Top  border
					if((x_direction==0) && (y_direction==1))begin		//left-down direction
					ball_x<=ball_x+1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=1;
					y_direction<=0;
					score<=score+10'b0000001010;
					end
					else begin
					ball_x<=ball_x+1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					score<=score+10'b0000001010;
					end
				end	
				
			//GREEN TARGET 1		
				else if((ball_y==green1_y-(target_r+ball_r))&&(ball_x>green1_x-6)&&(ball_x<green1_x+6)) begin // Top
					y_direction<=0;
					ball_y<=ball_y-1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
				end else if((ball_y==green1_y+(target_r+ball_r))&&(ball_x>green1_x-6)&&(ball_x<green1_x+6)) begin //Bottom
					y_direction<=1;
					ball_y<=ball_y+1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
				end else if((ball_x==green1_x-(target_r+ball_r))&&(ball_y>green1_y-6)&&(ball_y<green1_y+6)) begin  // Left 
					x_direction<=0;
					ball_x<=ball_x-1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
				end else if((ball_x==green1_x+(target_r+ball_r))&&(ball_y>green1_y-6)&&(ball_y<green1_y+6)) begin  // Right
					x_direction<=1;
					ball_x<=ball_x+1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
				end else if((ball_y==(green1_y+green1_x+24+10-ball_x)) && (ball_x>=green1_x+6) && (ball_y>=green1_y+6)) begin	//Right_bottom border
					if((x_direction==0) && (y_direction==0)) begin		//left-up direction
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=1;
					y_direction<=1;
					ball_x<=ball_x+1;
					ball_y<=ball_y+1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
					else begin		
					x_speed<=y_speed;
					y_speed<=x_speed;
					ball_x<=ball_x+1;
					ball_y<=ball_y+1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
				end
				else if((ball_y==(green1_y-green1_x+24+10+ball_x)) && (ball_x<=green1_x+6) && (ball_y>=green1_y+6))begin	//Left bottom border
					if((x_direction==1) && (y_direction==0))begin		//right-up direction
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=0;
					y_direction<=1;
					ball_x<=ball_x-1;
					ball_y<=ball_y+1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
					else begin	
					x_speed<=y_speed;
					y_speed<=x_speed;
					ball_x<=ball_x-1;
					ball_y<=ball_y+1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
				end
				else if((ball_y==(green1_y+green1_x-24-10-ball_x))&& (ball_x<=green1_x-6) && (ball_y<=green1_y-6))begin	//Left top border
					if((x_direction==1) && (y_direction==1))begin		//right-down direction
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=0;
					y_direction<=0;
					ball_x<=ball_x-1;
					ball_y<=ball_y-1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
					else begin		//right-up direction
					x_speed<=y_speed;
					y_speed<=x_speed;
					ball_x<=ball_x-1;
					ball_y<=ball_y-1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
				end
				else if((ball_y==(green1_y-green1_x-24-10+ball_x)) && (ball_x>=green1_x+6) && (ball_y<=green1_y-6))begin	//Right Top  border
					if((x_direction==0) && (y_direction==1))begin		//left-down direction
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=1;
					y_direction<=0;
					ball_x<=ball_x+1;
					ball_y<=ball_y-1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
					else begin
					x_speed<=y_speed;
					y_speed<=x_speed;
					ball_x<=ball_x+1;
					ball_y<=ball_y-1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
				end	
		
		
		//GREEN TARGET 2
				else if((ball_y==green2_y-(target_r+ball_r))&&(ball_x>green2_x-6)&&(ball_x<green2_x+6)) begin // Top
					ball_y<=ball_y-1;
					y_direction<=0;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
				end else if((ball_y==green2_y+(target_r+ball_r))&&(ball_x>green2_x-6)&&(ball_x<green2_x+6)) begin //Bottom
					ball_y<=ball_y+1;
					y_direction<=1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
				end else if((ball_x==green2_x-(target_r+ball_r))&&(ball_y>green2_y-6)&&(ball_y<green2_y+6)) begin  // Left 
					ball_x<=ball_x-1;
					x_direction<=0;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
				end else if((ball_x==green2_x+(target_r+ball_r))&&(ball_y>green2_y-6)&&(ball_y<green2_y+6)) begin  // Right
					ball_x<=ball_x+1;
					x_direction<=1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
				end else if((ball_y==(green2_y+green2_x+24+10-ball_x)) && (ball_x>=green2_x+6) && (ball_y>=green2_y+6)) begin	//Right_bottom border
					if((x_direction==0) && (y_direction==0)) begin		//left-up direction
					ball_x<=ball_x+1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=1;
					y_direction<=1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
					else begin		
					ball_x<=ball_x+1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
				end
				else if((ball_y==(green2_y-green2_x+24+10+ball_x)) && (ball_x<=green2_x+6) && (ball_y>=green2_y+6))begin	//Left bottom border
					if((x_direction==1) && (y_direction==0))begin		//right-up direction
					ball_x<=ball_x-1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=0;
					y_direction<=1;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
					else begin	
					ball_x<=ball_x-1;
					ball_y<=ball_y+1;
					x_speed<=y_speed;
					y_speed<=temp_speed;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
				end
				else if((ball_y==(green2_y+green2_x-24-10-ball_x))&& (ball_x<=green2_x-6) && (ball_y<=green2_y-6))begin	//Left top border
					if((x_direction==1) && (y_direction==1))begin		//right-down direction
					ball_x<=ball_x-1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=0;
					y_direction<=0;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
					else begin		//right-up direction
					ball_x<=ball_x-1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
				end
				else if((ball_y==(green2_y-green2_x-24-10+ball_x)) && (ball_x>=green2_x+6) && (ball_y<=green2_y-6))begin	//Right Top  border
					if((x_direction==0) && (y_direction==1))begin		//left-down direction
					ball_x<=ball_x+1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					x_direction<=1;
					y_direction<=0;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
					else begin
					ball_x<=ball_x+1;
					ball_y<=ball_y-1;
					x_speed<=y_speed;
					y_speed<=x_speed;
					if(score>=15)begin score<=score-10'b0000001111; end
					else if (score<15) begin score<=10'b0; end
					end
				end
				
				//BLUE TARGET 1
				else if( ((ball_y==blue1_y+20+ball_r)&&(ball_x>blue1_x-5)&&(ball_x<blue1_x+5))||(((ball_y==blue1_y-20-ball_r)&&(ball_x>blue1_x-5)&&(ball_x<blue1_x+5)))
				|| (((ball_x>=blue1_x+5)&&(ball_x<=blue1_x+25+ball_r))&&( (ball_y==-ball_x+(blue1_y+blue1_x+35)) || (ball_y==ball_x+(blue1_y-blue1_x-35)))) 
				|| (((ball_x<=blue1_x-5)&&(ball_x>=blue1_x-25-ball_r))&&( (ball_y==ball_x+(blue1_y-blue1_x+35)) || (ball_y==-ball_x+(blue1_y+blue1_x-35)))) ) begin
					case(random_num_13)
						0:begin
						ball_x<=blue1_x+(15+ball_r);
						ball_y<=blue1_y+(10+ball_r);
						score<=score+20;
						end
						1:begin
						ball_x<=blue1_x;
						ball_y<=blue1_y+(22+ball_r);
						score<=score+20;
						end
						2:begin
						ball_x<=blue1_x-(15+ball_r);
						ball_y<=blue1_y+(10+ball_r);
						score<=score+20;
						end
						3:begin
						ball_x<=blue1_x-(15+ball_r);
						ball_y<=blue1_y-(10+ball_r);
						score<=score+20;
						end
						4:begin
						ball_x<=blue1_x;
						ball_y<=blue1_y-(22+ball_r);
						score<=score+20;
						end
						5:begin
						ball_x<=blue1_x+(15+ball_r);
						ball_y<=blue1_y-(10+ball_r);
						score<=score+20;
						end
					endcase
					x_direction<=random_num_14;
					y_direction<=random_num_15;				
				end
				
			//BLUE TARGET 2
				else if( ((ball_y==blue2_y+20+ball_r)&&(ball_x>blue2_x-5)&&(ball_x<blue2_x+5))||(((ball_y==blue2_y-20-ball_r)&&(ball_x>blue2_x-5)&&(ball_x<blue2_x+5)))
				|| (((ball_x>=blue2_x+5)&&(ball_x<=blue2_x+25+ball_r))&&( (ball_y==-ball_x+(blue2_y+blue2_x+35)) || (ball_y==ball_x+(blue2_y-blue2_x-35)))) 
				|| (((ball_x<=blue2_x-5)&&(ball_x>=blue2_x-25-ball_r))&&( (ball_y==ball_x+(blue2_y-blue2_x+35)) || (ball_y==-ball_x+(blue2_y+blue2_x-35)))) ) begin
					case(random_num_13)
						0:begin
						ball_x<=blue2_x+(15+ball_r);
						ball_y<=blue2_y+(10+ball_r);
						score<=score+20;
						end
						1:begin
						ball_x<=blue2_x;
						ball_y<=blue2_y+(22+ball_r);
						score<=score+20;
						end
						2:begin
						ball_x<=blue2_x-(15+ball_r);
						ball_y<=blue2_y+(10+ball_r);
						score<=score+20;
						end
						3:begin
						ball_x<=blue2_x-(15+ball_r);
						ball_y<=blue2_y-(10+ball_r);
						score<=score+20;
						end
						4:begin
						ball_x<=blue2_x;
						ball_y<=blue2_y-(22+ball_r);
						score<=score+20;
						end
						5:begin
						ball_x<=blue2_x+(15+ball_r);
						ball_y<=blue2_y-(10+ball_r);
						score<=score+20;
						end
					endcase
					x_direction<=random_num_14;
					y_direction<=random_num_15;				
				end
				
			//LOOP BREAKER
			else if(breaker==0) begin
				x_direction<=random_num_14;
				y_direction<=random_num_15;
			
			end
				
			//Y SLOW DOWN
			else begin
				if(ball_y<80) begin
					y_speed<=500000;
				end else if(ball_y<110) begin
					y_speed<=475000;
				end else if(ball_y<150) begin
					y_speed<=450000;
				end else if(ball_y<180) begin
					y_speed<=400000;
				end else if(ball_y<210) begin
					y_speed<=350000;
				end else if(ball_y<250) begin
					y_speed<=300000;
				end else if(ball_y<280) begin
					y_speed<=250000;
				end else if(ball_y<310) begin
					y_speed<=200000;
				end else if(ball_y<340) begin
					y_speed<=150000;
				end else begin
					y_speed<=125000;
				end
			end //gameover close
			
		//BALL MOVEMENT	
		
		if(speed_counter_x<x_speed) begin	//X movement
		speed_counter_x<=speed_counter_x+1;
		end else begin
			if(x_direction==0) begin
			ball_x<=ball_x-1;
			end else begin
			ball_x<=ball_x+1;
			end		
		speed_counter_x<=0;
		end
		
		if(speed_counter_y<y_speed) begin	//Y movement
		speed_counter_y<=speed_counter_y+1;
		end else begin
			if(y_direction==0) begin
			ball_y<=ball_y-1;
			end else begin
			ball_y<=ball_y+1;
			end	
		speed_counter_y<=0;
		end
			
	end else begin
	score<=0;
	x_direction<=0;
	y_direction<=0;
	ball_x=395+144;
	ball_y=395+35;
	end
end

//GAME START & END
always @ (posedge clk) begin
	if(start==0) begin
	gameover<=0;
	end
	
	if(ball_y==480+35) begin
	gameover<=1;
	end
end

always @(posedge clk) //second counter
begin
	if(gameover==1)begin
		random_num_1=random_num_1+1'b1;
		random_num_2=random_num_2+3'b111;
		random_num_3=random_num_3+4'b1000;
		random_num_4=random_num_4+3'b011;
		random_num_5=random_num_5+3'b101;
		random_num_6=random_num_6+2'b10;
		random_num_7=random_num_7+3'b100;
		random_num_8=random_num_8+4'b1001;
		random_num_9=random_num_9+4'b1011;
		random_num_10=random_num_10+4'b0110;
		random_num_11=random_num_11+4'b0111;
		random_num_12=random_num_12+4'b0011;
	end
	else begin
		if((((blue1_x-blue2_x)*(blue1_x-blue2_x)+(blue1_y-blue2_y)*(blue1_y-blue2_y) <= 50*50) || ((blue1_x-red1_x)*(blue1_x-red1_x)+(blue1_y-red1_y)*(blue1_y-red1_y) <= 50*50) || ((blue1_x-red2_x)*(blue1_x-red2_x)+(blue1_y-red2_y)*(blue1_y-red2_y) <= 50*50)
|| ((blue1_x-green1_x)*(blue1_x-green1_x)+(blue1_y-green1_y)*(blue1_y-green1_y) <= 50*50) || ((blue1_x-green2_x)*(blue1_x-green2_x)+(blue1_y-green2_y)*(blue1_y-green2_y) <= 50*50) ||((blue2_x-red1_x)*(blue2_x-red1_x)+(blue2_y-red1_y)*(blue2_y-red1_y) <= 50*50) 
||((blue2_x-red2_x)*(blue2_x-red2_x)+(blue2_y-red2_y)*(blue2_y-red2_y) <= 50*50) || ((blue2_x-green1_x)*(blue2_x-green1_x)+(blue2_y-green1_y)*(blue2_y-green1_y)<= 50*50) ||((blue2_x-green2_x)*(blue2_x-green2_x)+(blue2_y-green2_y)*(blue2_y-green2_y)<= 50*50)  
||((red1_x-red2_x)*(red1_x-red2_x)+(red1_y-red2_y)*(red1_y-red2_y) <= 50*50) || ((red1_x-green1_x)*(red1_x-green1_x)+(red1_y-green1_y)*(red1_y-green1_y)<= 50*40)  || ((red1_x-green2_x)*(red1_x-green2_x)+(red1_y-green2_y)*(red1_y-green2_y) <= 50*50)
||((red2_x-green1_x)*(red2_x-green1_x)+(red2_y-green1_y)*(red2_y-green1_y)<= 50*50)  ||((red2_x-green2_x)*(red2_x-green2_x)+(red2_y-green2_y)*(red2_y-green2_y) <= 50*50) || ((green1_x-green2_x)*(green1_x-green2_x)+(green1_y-green2_y)*(green1_y-green2_y) <= 50*50))==0)
		red1_x=random_num_1+144+160+32;
		red1_y=random_num_2+35+42;
		red2_x=random_num_3+144+160+32;
		red2_y=random_num_4+35+42;
		green1_x=random_num_5+144+160+32;
		green1_y=random_num_6+35+42;
		green2_x=random_num_7+144+160+32;
		green2_y=random_num_8+35+42;
		blue1_x=random_num_9+144+160+32;
		blue1_y=random_num_10+35+42;
		blue2_x=random_num_11+144+160+32;
		blue2_y=random_num_12+35+42;
		random_num_13=(count_second%10); //Rand Position
		random_num_14=((count_second+score)%2); //X Rand Direction
		random_num_15=(count_second%2); //Y Rand Direction 
	end
end


//TIMER

always @(posedge clk) //second counter
begin
	if(count_25 < 50000000-1)
	count_25=count_25+1'b1;
	else
		begin
			count_25=0; 
			if(gameover==0)begin
			count_second=count_second+1'b1;
			end
			else begin
			count_second=0;
			end
		end
end

assign	a00 =  count_second%10; 
assign   a11 = (count_second/10)%10;
assign   a22 = (count_second/100)%10;

always @(posedge clk)
begin
a0=a00;
a1=a11;
a2=a22;
end
	
// TIMER 7-SEGMENT 
always@(posedge clk) //count-up a2a1a0
	begin
	case(a2)
	0: begin
	b1 = ((count_x>=0+144+500  && count_x <=4+144+500  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b2 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b3 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b4 = 0;
	b5 = ((count_x>=0+144+500 && count_x <=4+144+500  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b6 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b7 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	1: begin
	b1 = 0;
	b2 = 0;
	b3 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b4 = 0;
	b5 = 0;
	b6 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b7 = 0;
		end
	2: begin
	b1 = 0;
	b2 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b3 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b4 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b5 = ((count_x>=0+144+500  && count_x <=4+144+500  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b6 = 0;
	b7 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	3: begin
	b1 = 0;
	b2 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b3 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b4 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b5 = 0;
	b6 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b7 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	4: begin
	b1 = ((count_x>=0+144+500  && count_x <=4+144+500  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b2 = 0;
	b3 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b4 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b5 = 0;
	b6 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b7 = 0;
		end
	5: begin
	b1 = ((count_x>=0+144+500  && count_x <=4+144+500  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b2 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b3 = 0;
	b4 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b5 = 0;
	b6 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b7 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	6: begin
	b1 = ((count_x>=0+144+500 && count_x <=4+144+500  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b2 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b3 = 0;
	b4 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b5 = ((count_x>=0+144+500  && count_x <=4+144+500  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b6 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b7 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	7: begin
	b1 = 0;
	b2 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b3 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b4 = 0;
	b5 = 0;
	b6 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b7 = 0;
		end
	8: begin
	b1 = ((count_x>=0+144+500 && count_x <=4+144+500  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b2 = ((count_x>=5+144+500 && count_x <=24+144+500 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b3 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b4 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b5 = ((count_x>=0+144+500  && count_x <=4+144+500  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b6 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b7 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
	end
	9: begin
	b1 = ((count_x>=0+144+500 && count_x <=4+144+500   ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b2 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b3 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b4 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b5 = 0;
	b6 = ((count_x>=25+144+500 && count_x <=29+144+500 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b7 = ((count_x>=5+144+500  && count_x <=24+144+500 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	endcase
end

always@(posedge clk) //count-up a2a1a0
	begin
	case(a1)
	0: begin
	b11 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b22 = ((count_x>=5+144+500+31 && count_x <=24+144+500+31  ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b33 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b44 = 0;
	b55 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b66 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b77 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	1: begin
	b11 = 0;
	b22 = 0;
	b33 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b44 = 0;
	b55 = 0;
	b66 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b77 = 0;
		end
	2: begin
	b11 = 0;
	b22 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b33 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b44 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b55 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b66 = 0;
	b77 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	3: begin
	b11 = 0;
	b22 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b33 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b44 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b55 = 0;
	b66 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b77 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	4: begin
	b11 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b22 = 0;
	b33 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b44 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b55 = 0;
	b66 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b77 = 0;
		end
	5: begin
	b11 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b22 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b33 = 0;
	b44 = ((count_x>=5+144+500+31 && count_x <=24+144+500+31  ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b55 = 0;
	b66 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b77 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	6: begin
	b11 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b22 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b33 = 0;
	b44 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b55 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b66 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b77 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	7: begin
	b11 = 0;
	b22 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b33 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b44 = 0;
	b55 = 0;
	b66 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b77 = 0;
		end
	8: begin
	b11 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b22 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b33 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b44 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b55 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b66 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b77 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
	end
	9: begin
	b11 = ((count_x>=0+144+500+31  && count_x <=4+144+500+31  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b22 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b33 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b44 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b55 = 0;
	b66 = ((count_x>=25+144+500+31 && count_x <=29+144+500+31 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b77 = ((count_x>=5+144+500+31  && count_x <=24+144+500+31 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	endcase
end
	
always@(posedge clk) //count-up a2a1a0
	begin
	case(a0)
	0: begin
	b111 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b222 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b333 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b444 = 0;
	b555 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b666 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b777 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	1: begin
	b111 = 0;
	b222 = 0;
	b333 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b444 = 0;
	b555 = 0;
	b666 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b777 = 0;
		end
	2: begin
	b111 = 0;
	b222 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b333 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b444 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b555 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b666 = 0;
	b777 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	3: begin
	b111 = 0;
	b222 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b333 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b444 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b555 = 0;
	b666 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b777 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	4: begin
	b111 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b222 = 0;
	b333 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b444 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b555 = 0;
	b666 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b777 = 0;
		end
	5: begin
	b111 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b222 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b333 = 0;
	b444 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b555 = 0;
	b666 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b777 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	6: begin
	b111 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b222 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b333 = 0;
	b444 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b555 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b666 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b777 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	7: begin
	b111 = 0;
	b222 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b333 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b444 = 0;
	b555 = 0;
	b666 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b777 = 0;
		end
	8: begin
	b111 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b222 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b333 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b444 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b555 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b666 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b777 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
	end
	9: begin
	b111 = ((count_x>=0+144+500+62  && count_x <=4+144+500+62  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b222 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	b333 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	b444 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	b555 = 0;
	b666 = ((count_x>=25+144+500+62 && count_x <=29+144+500+62 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	b777 = ((count_x>=5+144+500+62  && count_x <=24+144+500+62 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	endcase
end
 
assign	s00 =  score%10; 
assign   s11 = (score/10)%10;
assign  	s22 = (score/100)%10;

always @(posedge clk)
begin

s0=s00;
s1=s11;
s2=s22;
end


always@(posedge clk) //scoreboard s2s1s0
	begin
	case(s2)
	0: begin
	c1 = ((count_x>=0+144+110-50  && count_x <=4+144+110-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c2 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	c3 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c4 = 0;
	c5 = ((count_x>=0+144+110-50 && count_x <=4+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c6 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c7 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	1: begin
	c1 = 0;
	c2 = 0;
	c3 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c4 = 0;
	c5 = 0;
	c6 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c7 = 0;
		end
	2: begin
	c1 = 0;
	c2 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	c3 = ((count_x>=25+144+110 -50&& count_x <=29+144+110 -50) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c4 = ((count_x>=5+144+110-50 && count_x <=24+144+110-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	c5 = ((count_x>=0+144+110-50  && count_x <=4+144+110-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c6 = 0;
	c7 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	3: begin
	c1 = 0;
	c2 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	c3 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c4 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	c5 = 0;
	c6 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c7 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	4: begin
	c1 = ((count_x>=0+144+110-50  && count_x <=4+144+110-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c2 = 0;
	c3 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c4 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	c5 = 0;
	c6 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c7 = 0;
		end
	5: begin
	c1 = ((count_x>=0+144+110-50  && count_x <=4+144+110-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c2 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	c3 = 0;
	c4 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	c5 = 0;
	c6 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c7 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	6: begin
	c1 = ((count_x>=0+144+110-50 && count_x <=4+144+110-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c2 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	c3 = 0;
	c4 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	c5 = ((count_x>=0+144+110-50  && count_x <=4+144+110-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c6 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c7 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	7: begin
	c1 = 0;
	c2 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	c3 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c4 = 0;
	c5 = 0;
	c6 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c7 = 0;
		end
	8: begin
	c1 = ((count_x>=0+144+110-50 && count_x <=4+144+110-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c2 = ((count_x>=5+144+110-50 && count_x <=24+144+110-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	c3 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c4 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	c5 = ((count_x>=0+144+110-50  && count_x <=4+144+110-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c6 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c7 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
	end
	9: begin
	c1 = ((count_x>=0+144+110-50 && count_x <=4+144+110-50   ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c2 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	c3 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	c4 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	c5 = 0;
	c6 = ((count_x>=25+144+110-50 && count_x <=29+144+110-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	c7 = ((count_x>=5+144+110-50  && count_x <=24+144+110-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
		endcase
	end
	
	always@(posedge clk) //scoreboard s2s1s0
	begin
	case(s1)
	0: begin
	cc1 = ((count_x>=0+144+110+31-50  && count_x <=4+144+110+31-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc2 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	cc3 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc4 = 0;
	cc5 = ((count_x>=0+144+110+31-50 && count_x <=4+144+110+31-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc6 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc7 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	1: begin
	cc1 = 0;
	cc2 = 0;
	cc3 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc4 = 0;
	cc5 = 0;
	cc6 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc7 = 0;
		end
	2: begin
	cc1 = 0;
	cc2 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	cc3 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc4 = ((count_x>=5+144+110+31-50 && count_x <=24+144+110+31-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	cc5 = ((count_x>=0+144+110 +31-50 && count_x <=4+144+110+31-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc6 = 0;
	cc7 = ((count_x>=5+144+110+31-50 && count_x <=24+144+110+31-50) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	3: begin
	cc1 = 0;
	cc2 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	cc3 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc4 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	cc5 = 0;
	cc6 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc7 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	4: begin
	cc1 = ((count_x>=0+144+110+31-50  && count_x <=4+144+110+31-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc2 = 0;
	cc3 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc4 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	cc5 = 0;
	cc6 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc7 = 0;
		end
	5: begin
	cc1 = ((count_x>=0+144+110+31-50  && count_x <=4+144+110+31-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc2 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	cc3 = 0;
	cc4 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	cc5 = 0;
	cc6 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc7 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	6: begin
	cc1 = ((count_x>=0+144+110+31-50 && count_x <=4+144+110+31-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc2 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	cc3 = 0;
	cc4 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	cc5 = ((count_x>=0+144+110+31-50  && count_x <=4+144+110+31-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc6 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc7 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	7: begin
	cc1 = 0;
	cc2 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	cc3 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc4 = 0;
	cc5 = 0;
	cc6 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc7 = 0;
		end
	8: begin
	cc1 = ((count_x>=0+144+110+31-50 && count_x <=4+144+110+31-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc2 = ((count_x>=5+144+110+31-50 && count_x <=24+144+110+31-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	cc3 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc4 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	cc5 = ((count_x>=0+144+110+31-50  && count_x <=4+144+110+31-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc6 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc7 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
	end
	9: begin
	cc1 = ((count_x>=0+144+110+31-50 && count_x <=4+144+110+31-50   ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc2 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	cc3 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	cc4 = ((count_x>=5+144+110+31-50 && count_x <=24+144+110+31-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	cc5 = 0;
	cc6 = ((count_x>=25+144+110+31-50 && count_x <=29+144+110+31-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	cc7 = ((count_x>=5+144+110+31-50  && count_x <=24+144+110+31-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
		endcase
	end
	
	always@(posedge clk) //scoreboard s2s1s0
	begin
	case(s0)
	0: begin
	ccc1 = ((count_x>=0+144+110+62-50  && count_x <=4+144+110+62-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc2 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	ccc3 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc4 = 0;
	ccc5 = ((count_x>=0+144+110+62-50 && count_x <=4+144+110+62-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc6 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc7 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	1: begin
	ccc1 = 0;
	ccc2 = 0;
	ccc3 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc4 = 0;
	ccc5 = 0;
	ccc6 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc7 = 0;
		end
	2: begin
	ccc1 = 0;
	ccc2 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	ccc3 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc4 = ((count_x>=5+144+110+62-50 && count_x <=24+144+110+62-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	ccc5 = ((count_x>=0+144+110 +62-50 && count_x <=4+144+110+62-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc6 = 0;
	ccc7 = ((count_x>=5+144+110 +62-50 && count_x <=24+144+110+62-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	3: begin
	ccc1 = 0;
	ccc2 = ((count_x>=5+144+110+62 -50 && count_x <=24+144+110+62-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	ccc3 = ((count_x>=25+144+110+62 -50&& count_x <=29+144+110+62-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc4 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	ccc5 = 0;
	ccc6 = ((count_x>=25+144+110 +62-50&& count_x <=29+144+110+62-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc7 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	4: begin
	ccc1 = ((count_x>=0+144+110+62-50  && count_x <=4+144+110+62-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc2 = 0;
	ccc3 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc4 = ((count_x>=5+144+110+62 -50 && count_x <=24+144+110+62-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	ccc5 = 0;
	ccc6 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc7 = 0;
		end
	5: begin
	ccc1 = ((count_x>=0+144+110+62 -50&& count_x <=4+144+110+62-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc2 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	ccc3 = 0;
	ccc4 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	ccc5 = 0;
	ccc6 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc7 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	6: begin
	ccc1 = ((count_x>=0+144+110+62-50 && count_x <=4+144+110+62 -50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc2 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	ccc3 = 0;
	ccc4 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	ccc5 = ((count_x>=0+144+110+62-50  && count_x <=4+144+110+62-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc6 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc7 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
	7: begin
	ccc1 = 0;
	ccc2 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	ccc3 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc4 = 0;
	ccc5 = 0;
	ccc6 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc7 = 0;
		end
	8: begin
	ccc1 = ((count_x>=0+144+110+62-50 && count_x <=4+144+110+62-50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc2 = ((count_x>=5+144+110+62-50 && count_x <=24+144+110+62-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	ccc3 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc4 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	ccc5 = ((count_x>=0+144+110+62 -50 && count_x <=4+144+110+62-50  ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc6 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc7 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
	end
	9: begin
	ccc1 = ((count_x>=0+144+110+62-50 && count_x <=4+144+110+62 -50  ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc2 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=0+35+20  && count_y<=4+35+20  ));
	ccc3 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=5+35+20  && count_y<=24+35+20 ));
	ccc4 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=25+35+20 && count_y<=29+35+20 ));
	ccc5 = 0;
	ccc6 = ((count_x>=25+144+110+62-50 && count_x <=29+144+110+62-50 ) && (count_y>=30+35+20 && count_y<=49+35+20 ));
	ccc7 = ((count_x>=5+144+110+62-50  && count_x <=24+144+110+62-50 ) && (count_y>=50+35+20 && count_y<=54+35+20 ));
		end
		endcase
	end	
	
	
	//COLOR ASSIGNMENTS
always @ (posedge clk) begin
	if(count_x>144 && count_x<784 && count_y>34 && count_y<515) begin
		//BORDER & BALL & PLUNGERS
		if(((count_x==160+144)&&(count_y<340+35))||((count_x==480+144)&&(count_y<340+35))||((count_x>160+144)&&(count_x<480+144)&&(count_y==0+35))//sol - sağ - üst - sol alt - sağ alt
		||((count_y>340+35)&&(count_y<440+35)&&((count_y==340+35-(160+144)+count_x)||(count_y==480+340+144+35-count_x)))) begin						//White
			vga_R <= 8'b11111111;
			vga_G <= 8'b11111111;
			vga_B <= 8'b11111111;
		end
		else if ((((count_x-ball_x)**2)+((count_y-ball_y)**2))< (ball_r**2)) begin		//Ball
			vga_R <= 8'b11111111;
			vga_G <= 8'b11111111;
			vga_B <= 8'b00000000;	
		end
			
	/*	else if (0) begin		//Plunger
			vga_R <= 8'b11111111;
			vga_G <= 8'b11111111;
			vga_B <= 8'b11111111;	
		end*/
		
		//TARGETS
		else if (((count_x-red1_x)*(count_x-red1_x)+(count_y-red1_y)*(count_y-red1_y))<(target_r**2)) begin //RED Target 1
			vga_R <= 8'b11111111;
			vga_G <= 8'b00000000;
			vga_B <= 8'b00000000;
		end
		else if (((count_x-red2_x)*(count_x-red2_x)+(count_y-red2_y)*(count_y-red2_y))<(target_r**2)) begin //RED Target 2
			vga_R <= 8'b11111111;
			vga_G <= 8'b00000000;
			vga_B <= 8'b00000000;
		end
		else if (((count_x-green1_x)*(count_x-green1_x)+(count_y-green1_y)*(count_y-green1_y))<(target_r**2)) begin //GREEN Target 1
			vga_R <= 8'b00000000;
			vga_G <= 8'b11111111;
			vga_B <= 8'b00000000;
		end
		else if (((count_x-green2_x)*(count_x-green2_x)+(count_y-green2_y)*(count_y-green2_y))<(target_r**2)) begin //GREEN Target 2
			vga_R <= 8'b00000000;
			vga_G <= 8'b11111111;
			vga_B <= 8'b00000000;
		end
		else if ( ((count_y==blue1_y+20+ball_r)&&(count_x>blue1_x-5)&&(count_x<blue1_x+5))||(((count_y==blue1_y-20-ball_r)&&(count_x>blue1_x-5)&&(count_x<blue1_x+5))) //BLUE Target 2
				|| (((count_x>=blue1_x+5)&&(count_x<=blue1_x+25+ball_r))&&( (count_y==-count_x+(blue1_y+blue1_x+35)) || (count_y==count_x+(blue1_y-blue1_x-35)))) 
				|| (((count_x<=blue1_x-5)&&(count_x>=blue1_x-25-ball_r))&&( (count_y==count_x+(blue1_y-blue1_x+35)) || (count_y==-count_x+(blue1_y+blue1_x-35)))) ) 
		begin  
			vga_R <= 8'b00000000;	
			vga_G <= 8'b00000000;
			vga_B <= 8'b11111111;
		end
		
		else if ( ((count_y==blue2_y+20+ball_r)&&(count_x>blue2_x-5)&&(count_x<blue2_x+5))||(((count_y==blue2_y-20-ball_r)&&(count_x>blue2_x-5)&&(count_x<blue2_x+5))) //BLUE Target 2
				|| (((count_x>=blue2_x+5)&&(count_x<=blue2_x+25+ball_r))&&( (count_y==-count_x+(blue2_y+blue2_x+35)) || (count_y==count_x+(blue2_y-blue2_x-35)))) 
				|| (((count_x<=blue2_x-5)&&(count_x>=blue2_x-25-ball_r))&&( (count_y==count_x+(blue2_y-blue2_x+35)) || (count_y==-count_x+(blue2_y+blue2_x-35)))) ) 
		begin 
			vga_R <= 8'b00000000;
			vga_G <= 8'b00000000;
			vga_B <= 8'b11111111;
		end
		
		//FLIPPERS
		//Left Joint
		else if (((count_x-(100+160+144))**2+(count_y-(340+100+35))**2)<(3**2)) begin
			vga_R <= 8'b11111111;
			vga_G <= 8'b00000000;
			vga_B <= 8'b11111111;
		end	
		//Right Joint
		else if (((count_x-(220+160+144))**2+(count_y-(340+100+35))**2)<(3**2)) begin
			vga_R <= 8'b11111111;
			vga_G <= 8'b00000000;
			vga_B <= 8'b11111111;
		end	
		
		//Left Flipper
		
		//Right Flipper
		
		//TIMER 7-SEGMENT
		else if(b1||b2||b3||b4||b5||b6||b7) begin
		vga_R <= 8'b11111111;
		vga_G <= 8'b11111111;
		vga_B <= 8'b11111111;
		end
		
		else if(b11||b22||b33||b44||b55||b66||b77) begin
		vga_R <= 8'b11111111;
		vga_G <= 8'b11111111;
		vga_B <= 8'b11111111;
		end
		
		else if(b111||b222||b333||b444||b555||b666||b777) begin
		vga_R <= 8'b11111111;
		vga_G <= 8'b11111111;
		vga_B <= 8'b11111111;
		end
	
		//SCOREBOARD 7-SEGMENT
		else if(c1||c2||c3||c4||c5||c6||c7) begin
		vga_R <= 8'b11111111;
		vga_G <= 8'b11111111;
		vga_B <= 8'b11111111;
		end
		
		else if(cc1||cc2||cc3||cc4||cc5||cc6||cc7) begin
		vga_R <= 8'b11111111;
		vga_G <= 8'b11111111;
		vga_B <= 8'b11111111;
		end
		
		else if(ccc1||ccc2||ccc3||ccc4||ccc5||ccc6||ccc7) begin
		vga_R <= 8'b11111111;
		vga_G <= 8'b11111111;
		vga_B <= 8'b11111111;
		end

		else begin
		vga_R <= 8'b00000000;
		vga_G <= 8'b00000000;
		vga_B <= 8'b00000000;
		end		
	end
	else begin		//OUT OF SCREEN VALUE 0
		vga_R <= 8'b00000000;
		vga_G <= 8'b00000000;
		vga_B <= 8'b00000000;
	end
end

endmodule
