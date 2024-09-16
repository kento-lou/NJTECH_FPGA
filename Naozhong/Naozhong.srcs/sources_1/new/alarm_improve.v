`timescale 1ns / 1ps

// Create Date: 2019/03/22 21:09:12
// Design Name: 阿汪先生         尘（修改）
// Module Name: alarm_improve
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 

module alarm_improve(clk,rst_n,key_h,key_l,wx,dx,fm,q0,q1,q2,q3);
//alarmq更改闹铃时间键
//tmq更改现实时间键
input  clk;
input  rst_n;//复位键
input  key_l;//列输入
output key_h;//行输出
output wx;//位选（片选）高电平有效
output dx;//段选，共阴极，高电平有效
output fm;//蜂鸣器
reg[6:0]shu3;//数码管数据
reg[6:0]shu2;
reg[6:0]shu1;
reg[6:0]shu0;

//存储人为设置时间,放映在数码管上
reg [3:0]tmrst0;
reg [3:0]tmrst1;
reg [3:0]tmrst2;
reg [3:0]tmrst3;


reg flag1;//标志按键按下后无按键按下五秒了
reg [3:0]count1;//用来计时，在停止输入时间5s后，还没有按下确定键，则恢复原来计数
//结束

 //设计闹铃功能处
 reg [3:0]cuna3;//存储闹铃时间
 reg [3:0]cuna2;
 reg [3:0]cuna1;
 reg [3:0]cuna0;
//结束


//消抖加扫描键盘

reg [8:0]stata;//状态
wire [3:0]key_l;//列输入
reg [3:0]key_h;//行输出,改变其，以此来进行扫描列
reg [3:0]c_key_l;//存下列输出，可以知道哪列按下的
reg [3:0]c_key_h;//存下行输出，可以知道哪列按下的
reg [7:0]c_key_hl;//存行列值
reg flagkey;//标志有按键按下，为了后续当数码管左移使能信号
reg en_xd;//消抖计时的使能信号，进入消抖状态开始计时
reg [23:0]countxd;//20ms计时
reg count_20;//为1时代表达到了20ms
parameter kongbai=9'b0_0000_0001,
           xiaodou=9'b0_0000_0010,
           saomiao0=9'b0_0000_0100,
           saomiao1=9'b0_0000_1000,
           saomiao2=9'b0_0001_0000,
           saomiao3=9'b0_0010_0000,
           zhi=9'b0_0100_0000,//确定行列
           sfd=9'b0_1000_0000,//释放等待
           sfxd=9'b1_0000_0000,//释放消抖
           huanchong0=9'b11,//缓冲状态
           huanchong1=9'b111,
           huanchong2=9'b1111,
           huanchong3=9'b11111,
           huanchong4=9'b111111;

reg [9:0]count_sm0;//用于中途缓冲
reg [9:0]count_sm1;
reg [9:0]count_sm2;
reg [9:0]count_sm3;
reg [9:0]count_sf;//释放缓冲
reg a0;//用于测试第一行是否被检测到
reg a1;
reg a2;
reg a3;
output reg q0;
output reg q1;
output reg q2;
output reg q3;
always @* begin
q0<=a0;
q1<=a1;
q2<=a2;
q3<=a3;
end


always@(posedge clk,negedge rst_n)begin
     if(!rst_n)begin
            stata<=kongbai;
            key_h<=4'b0000;
            c_key_h<=4'b0000;
            c_key_hl<=8'b0000_1111;
            en_xd<=1'b0;
            flagkey<=1'b0;
            count_sm0<=0;
            count_sm1<=0;
            count_sm2<=0;
            count_sm3<=0;
            a0<=0;
            a1<=0;
            a2<=0;
            a3<=0;
      end
      else begin
      case(stata)
       kongbai:begin
           key_h<=4'b0000;//空白状态下一直送0000，为了可以检测按键按下
           if(key_l!=4'b1111)begin//说明有按键按下
            c_key_l<=key_l;//存储列值
            stata<=xiaodou;
            en_xd<=1'b1;//进入消抖状态，计时开始，5ms
           end
           else begin
            stata<=kongbai;
            en_xd<=1'b0;
            end
         end
        xiaodou:begin
        if(count_20==1)begin
           stata<=huanchong0;
           key_h<=4'b1110;//由于是并行的，所以要提前給值再操作
           en_xd<=1'b0;
           end
        else if(key_l==4'b1111)begin
           stata<=kongbai;
           en_xd<=0;
           end
       else begin//既没有到5毫秒，也没有检测到抖动，维持原状态
          stata<=xiaodou;
         end
        end
        huanchong0:begin
           if(count_sm0<=100)begin
               count_sm0=count_sm0+1;
               key_h<=4'b1110;
            end
           else begin
               count_sm0<=0;
               stata<=saomiao0;
               key_h<=4'b1110;
           end
        end    
        saomiao0:begin
               if(key_l!=4'b1111)begin
                 c_key_h<=4'b1110;//代表在第一行 
                 stata<=huanchong1;
                 a0<=~a0;
               end
          else begin
            stata<=huanchong1;
            c_key_h<=c_key_h;             
          end
       end
        huanchong1:begin
          if(count_sm1<=100)begin
              count_sm1=count_sm1+1;
              key_h<=4'b1101;
           end
          else begin
              count_sm1<=0;
              stata<=saomiao1;
              key_h<=4'b1101;
          end
       end              
       saomiao1:begin      
           if(key_l!=4'b1111)begin
              c_key_h<=4'b1101;
              stata<=huanchong2;              
              a1<=~a1;                 
              end 
          else begin
           stata<=huanchong2;
           c_key_h<=c_key_h;                   
          end          
       end 
        huanchong2:begin
          if(count_sm2<=100)begin
              count_sm2=count_sm2+1;
              key_h<=4'b1011;
           end
          else begin
              count_sm2<=0;
              stata<=saomiao2;
              key_h<=4'b1011;
          end
       end        
       saomiao2:begin        
             if(key_l!=4'b1111)begin
                c_key_h<=4'b1011;
                stata<=huanchong3;            
                a2<=~a2;                 
                end
         else begin
          stata<=huanchong3;
          c_key_h<=c_key_h;                  
         end                                    
       end 
       
        huanchong3:begin
          if(count_sm3<=100)begin
              count_sm3=count_sm3+1;
              key_h<=4'b0111;
           end
          else begin
              count_sm3<=0;
              stata<=saomiao3;
              key_h<=4'b0111;
          end
       end              
       saomiao3:begin       
               if(key_l!=4'b1111)begin
                  c_key_h<=4'b0111;
                  stata<=zhi;       
                  a3<=~a3;                   
                  end
         else begin
            stata<=zhi;
            c_key_h<=c_key_h;                  
           end                              
         end    
        zhi:begin//确定行列值
            stata<=huanchong4;            
            c_key_hl<={c_key_h,c_key_l};
            flagkey<=1'b1;//表明有按键按下,为了后续数码管左移；让其保存一个时钟周期。
          end
        huanchong4:begin
           flagkey<=1'b0;//一个时钟到了
           if(count_sf<100) begin
              count_sf<=count_sf+1;
              key_h<=4'b0000;
            end
           else begin
              stata<=sfd;
              key_h<=4'b0000;
           end       
        end
        sfd:begin//等待释放
            if(key_l==4'b1111)begin
                stata<=sfxd;//进入释放消抖状态
                en_xd<=1'b1;//开始5ms计时
                end
            else begin
               stata<=sfd; //继续等待
             end   //阿汪先生的博客
         end    
        sfxd:begin
            if(count_20==1)begin
               stata<=kongbai;//释放结束，进入空白状态
               en_xd<=1'b0;//清零
               end
            else if(key_l!=4'b1111)begin
               stata<=sfd;
               en_xd<=0;
               end
            else begin
               stata<=sfxd;
             end
            end 
       default:begin
            stata<=kongbai;
         end           
     endcase   
   end  
end

//行列值译码
reg [3:0]key_board;
always@(*)begin
    case(c_key_hl)
         8'b1110_1110:
               key_board=4'hd;//扫描结果得出：第一行第一列，表示按下的为1；
         8'b1110_1101:
               key_board=4'hf;//当alarmq
         8'b1110_1011:
               key_board=4'h0;
         8'b1110_0111:
               key_board=4'he;//当tmq
         8'b1101_1110:
               key_board=4'hc;
         8'b1101_1101:
               key_board=4'h9;
         8'b1101_1011:
               key_board=4'h8;
         8'b1101_0111:
               key_board=4'h7;
         8'b1011_1110:
               key_board=4'hb;
         8'b1011_1101:
               key_board=4'h6;
         8'b1011_1011:
               key_board=4'h5;
         8'b1011_0111:
               key_board=4'h4;
         8'b0111_1110:
               key_board=4'ha;
         8'b0111_1101:
               key_board=4'h3;
         8'b0111_1011:
               key_board=4'h2;
         8'b0111_0111:
               key_board=4'h1;
        default:
               key_board=key_board;
    endcase 
end

//消抖计时，5ms
parameter N_xd=24'd5_000_00;//fz.10
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        countxd<=24'b0;
        count_20<=1'b0;
    end
    else if(en_xd)begin
         if(countxd<N_xd-1)begin
            countxd<=countxd+1;
            count_20<=1'b0;
         end
         else begin
            count_20<=1'b1;//标志20ms达到
            countxd<=24'b0;
            end
        end
    else begin
        countxd<=24'b0;
        count_20<=1'b0;
        end
end


//数码管扫描模块
reg [6:0]dx;//段选信号
reg [3:0]wx;//位选信号
parameter N=5'd19;//fz.4
reg[N-1:0]regN;//用来确定数码管扫描频率；
always@(*)begin
    case(regN[N-1:N-2])//先定义后使用
       2'b00: begin
         wx=4'b0001;//位选高电平有效,组合逻辑电路，顺序执行，若为阻塞赋值则不对了，要提前片选
         dx=shu0;
         end
       2'b01: begin
           wx=4'b0010;//共阴极的
           dx=shu1;
           end       
       2'b10: begin
           wx=4'b0100;//共阴极的
           dx=shu2;
         end       
       default: begin
           wx=4'b1000;//共阴极的
           dx=shu3;
         end       
      endcase

end

//用来确定扫描频率
always @(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        regN<=0;
        end
    else
        regN<=regN+1'b1;
 end

//分频1s
reg [28:0]countf1;//[7:0]fz
reg en_fj1;//标志一秒了
parameter N_fp=28'h5f5e100;//fz.100//分频1秒钟计数的数
//分频1秒
always @(posedge clk,negedge rst_n)begin
     if (!rst_n)begin
         en_fj1<=0;
         countf1<=0;
     end
     else begin
          if(countf1==N_fp-2)begin
               en_fj1<=1'b1;//进位变为1;
               countf1<=countf1+1'b1;
          end
          else if(countf1==N_fp-1)begin
              countf1<=0;
              en_fj1<=0;//进位为0；
          end
          else begin
               countf1<=countf1+1; 
               en_fj1<=0;//进位为0；
          end
     end
end
//分频1s结束

//分频1分钟
reg en_fj;//分钟使能信号
reg [7:0]countf;
always @(posedge clk,negedge rst_n)begin
     if (!rst_n)begin
         en_fj<=0;
         countf<=0;
     end
     else if(en_fj1==1'b1)begin
          /*if(countf==8'd58)begin
               en_fj<=1'b1;//进位变为1;
               countf<=countf+1'b1;
          end
          else*/ if(countf==8'd59)begin
              countf<=1;
              en_fj<=1;//进位为0；
          end
          else begin
               countf<=countf+1'b1; 
               en_fj<=0;//进位为0；
          end
     end
     else begin
         countf<=countf;
         en_fj<=0;
     end
end
//分频结束


//简单秒表设计
reg [3:0]jishi3;//存储时间寄存器10小时
reg [3:0]jishi2;//1小时
reg [3:0]jishi1;//10分
reg [3:0]jishi0; //分
reg en_j0;
reg en_j1;//数电中的进位，接在下一级的使能端，如此可以使用一个主clk
reg en_j2;
//分 低位计时器设计
always @(posedge clk,negedge rst_n)begin
       if (!rst_n)begin
           jishi0<=4'b0000;
           //进位清零
           en_j0<=1'b0;
         end
    //当五秒内按下alarmq或tmq时，计时器要改变原本样子，不能在其他always块中同时赋值同一个数.优先级问题
       else if(flag1==1'b1 && c_key_hl==8'b1110_0111)begin//5s内，tmq来了
          if(tmrst0<=4'd9)
            jishi0<=tmrst0;
         end
       else if(jishi0<9 && en_fj==1'b1)begin  //不进位
            jishi0<=jishi0+1'b1;
            en_j0<=1'b0;//进位此时为0；
       end
       else if(jishi0==9 && en_fj==1'b1)begin  //满9进位
            jishi0<=4'b0;
             en_j0<=1'b1;
       end
      else begin
           jishi0<=jishi0;
           en_j0<=0;
       end
end
 //分 高位计时器设计      
always @(posedge clk,negedge rst_n)begin
              if (!rst_n)begin
                  jishi1<=4'b0;
                  en_j1<=1'b0;
                end
              //当五秒内按下alarmq或tmq时，计时器要改变原本样子，不能在其他always块中同时赋值同一个数.优先级问题
              else if(flag1==1'b1 && c_key_hl==8'b1110_0111)begin//还要alrmq或者tmq来，我们需要对该信号检测
                if(tmrst1<=4'h5)
                  jishi1<=tmrst1;
                  
                end

              else if(jishi1==5 && en_j0==1'b1)begin
                   jishi1<=0;
                   en_j1<=1;
                   end
              else if(jishi1<5 && en_j0==1'b1)begin   //满5进位
                    jishi1<=jishi1+1'b1;
                    en_j1<=0;
                   end
             else begin
                   jishi1<=jishi1;
                   en_j1<=0;
               end
end
                   
//时 低位计时器设计
always @(posedge clk,negedge rst_n)begin
              if (!rst_n)begin
                  jishi2<=4'b0;
                  en_j2<=1'b0;
                end
              //当五秒内按下alarmq或tmq时，计时器要改变原本样子，不能在其他always块中同时赋值同一个数.优先级问题
              else if(flag1==1'b1 && c_key_hl==8'b1110_0111)begin//还要alrmq或者tmq来，我们需要对该信号检测
                if(tmrst2<=4'd9)
                  jishi2<=tmrst2;
                end

              else if(jishi2<9 &&jishi3<2 && en_j1==1'b1)begin
                   jishi2<=jishi2+1'b1;
                   en_j2<=1'b0;//进位为0
                end

              else if(jishi2==9 &&jishi3<2 && en_j1==1'b1)begin
                   jishi2<=0;
                   en_j2<=1'b1;
              end
              else if(jishi2<3 && jishi3==2 && en_j1==1'b1)begin
                   jishi2<=jishi2+1'b1;
                   en_j2<=1'b0;//进位恢复为0
                   end
              /*else if(jishi2==2 && jishi3==2 && en_j1==1'b1)begin
                   jishi2<=jishi2+1'b1;
                   en_j2<=1'b1;//进位为1
                   end*/
              else if(jishi2==3 && jishi3==2 && en_j1==1'b1)begin
                   jishi2<=0;
                   en_j2<=1;
                   end
             else begin
                   jishi2<=jishi2;
                   en_j2<=0;
               end
end          

//时 高位计时器设计
always @(posedge clk,negedge rst_n)begin
              if (!rst_n)begin
              jishi3<=4'b0;//计时器清零
              end
              //当五秒内按下alarmq或tmq时，计时器要改变原本样子，不能在其他always块中同时赋值同一个数.优先级问题
              else if(flag1==1'b1 && c_key_hl==8'b1110_0111)begin//还要alrmq或者tmq来，我们需要对该信号检测
                if(tmrst2<=3'd4 && tmrst3 == 2'd2)
                  jishi3<=tmrst3;
                else if(tmrst2<=4'd9 && tmrst3 <= 2'd1)
                  jishi3<=tmrst3;
              end
              //修改结束
              else if(jishi3<2 && en_j2==1'b1)
                   jishi3<=jishi3+1'b1;
              else if(jishi3==2 && en_j2==1'b1) begin //当10小时的计时器进位时，即等于2时，且进位为1
                   jishi3<=4'b0;							//阿汪先生的博客
              end
              else begin
                   jishi3<=jishi3;
               end
end

//更正，四个tmrst，分别对应要显示的数码管(在不同情况下的值）
reg [3:0]counta;//显示时间计时
reg flag_a;//用来标志是否显示闹铃的
always@(posedge clk,negedge rst_n)begin
     if(!rst_n)begin
          tmrst0<=4'b0000;
          tmrst1<=4'b0000;
          tmrst2<=4'b0000;
          tmrst3<=4'b0000;
      end
     else if(flagkey)begin//表明有按键按下,数码管优先显示,不是alarmq或者tmq按下
          if(c_key_hl!=8'b1110_0111 && c_key_hl!=8'b1110_1101)begin
              tmrst0<=key_board;
              tmrst1<=tmrst0;
              tmrst2<=tmrst1;
              tmrst3<=tmrst2;
              //还要将count1变成0，打破初始的五秒状态，从而开始计时五秒；
             end
          else//alarmq或者tmq按下的,要将count1置为五秒状态，flag1也是   
             if(flag1==1'b1 && c_key_hl==8'b1110_0111)begin//五秒计时计时没到,按下了tmq,先不变，将tmrst值送给计时器，5s计时达到五秒状态，恢复正常计时器
                  tmrst0<=tmrst0;
                  tmrst1<=tmrst1;
                  tmrst2<=tmrst2;
                  tmrst3<=tmrst3;
              end
             else if(flag1==1'b1 && c_key_hl==8'b1110_1101)begin//五秒计时计时没到,按下了alarmq,存储闹铃，count1置位五秒状态，然后恢复正常计时器
                  tmrst0<=jishi0;
                  tmrst1<=jishi1;
                  tmrst2<=jishi2;
                  tmrst3<=jishi3;  
              end 
             else if(flag1==1'b0 && c_key_hl==8'b1110_1101)begin//五秒到了，按下了alarmq键，则显示闹铃，开始计时,让其显示五秒显示五秒 
                 tmrst0<=cuna0;
                 tmrst1<=cuna1;
                 tmrst2<=cuna2;
                 tmrst3<=cuna3;                                  
               end
             else begin//五秒到了，按下了tmq键，没用,仍然是计时器
                  tmrst0<=jishi0;//tmrst0;
                  tmrst1<=jishi1;//tmrst1;
                  tmrst2<=jishi2;//tmrst2;//其实赋值jishi2也可以，但是为了照顾闹铃时间显示；
                  tmrst3<=jishi3;//tmrst3;             
              end        
     end
     else if(flag1==1'b0)begin//无按键按下，五秒了（初始化时五秒计时就当成到达五秒）;(alarmq和tmq按下后也是)
       if(flag_a==1'b0)begin//闹铃不显示
         tmrst0<=jishi0;
         tmrst1<=jishi1;
         tmrst2<=jishi2;
         tmrst3<=jishi3; 
         end
        else begin//闹铃显示
          tmrst0<=cuna0;
          tmrst1<=cuna1;
          tmrst2<=cuna2;
          tmrst3<=cuna3;                  
         end           
      end
     else begin//既没有按键按下，又没有达到五秒，保持不变
        tmrst0<=tmrst0;
        tmrst1<=tmrst1;         
        tmrst2<=tmrst2;      
        tmrst3<=tmrst3;      
      end
end

//设定时间，计时5s功能,显示闹钟时间
always @(posedge clk,negedge rst_n)begin
if(!rst_n)
    begin
      counta<=4'b0100;//复位时使其变成达到五秒状态
      flag_a<=1'b0;//复位时使其在五秒状态
    end
else if(flagkey)begin//有按键按下
  if(flag1==1'b0 && c_key_hl==8'b1110_1101)begin//五秒外按下了alarmq键，开始计时显示时间
     counta<=4'b0000;//可以进行计时了；
     flag_a<=1'b1;
   end 
  else if(c_key_hl==8'b1110_0111)begin//tmq按下，不影响
    counta<=counta;
    flag_a<=flag_a;
    end
  else begin//键值按下,打断闹铃的显示
    counta<=4'b0100;
    flag_a<=1'b0;
   end
 end
else if(counta<4 && en_fj1==1)begin
       counta<=counta+1'b1;
     end
else if(counta==4'b0100 && en_fj1==1)
    begin
    flag_a<=1'b0;//不再显示闹铃
    counta<=4'b0100;//表明已经达到了五秒。
    end
else begin
    flag_a<=flag_a;
    counta<=counta;		//阿汪先生的博客
 end
end

//编码，将要显示的值编码为数码管能显示的
always@(*)begin
    case(tmrst0)
        4'h0:
          shu0=7'b1111110;
        4'h1:
         shu0=7'b0110000;
        4'h2:
          shu0=7'b1101101;
        4'h3:
          shu0=7'b1111001;         
        4'h4:
          shu0=7'b0110011;
        4'h5:
          shu0=7'b1011011;
        4'h6:
          shu0=7'b1011111;
        4'h7:             
          shu0=7'b1110000;
        4'h8:
          shu0=7'b1111111;
        4'h9:
          shu0=7'b1111011;
        4'ha:
          shu0=7'b1110111;
        4'hb:  
          shu0=7'b0011111;           
        4'hc:
          shu0=7'b1001110;
        4'hd:
          shu0=7'b0111101;
        4'he:
          shu0=7'b1001111;
        4'hf:
          shu0=7'b1000111; 
        default:
          shu0=7'b1111110; 
        
    endcase
    case(tmrst1)
        4'h0:
          shu1=7'b1111110;
        4'h1:
         shu1=7'b0110000;
        4'h2:
          shu1=7'b1101101;
        4'h3:
          shu1=7'b1111001;         
        4'h4:
          shu1=7'b0110011;
        4'h5:
          shu1=7'b1011011;
        4'h6:
          shu1=7'b1011111;
        4'h7:             
          shu1=7'b1110000;
        4'h8:
          shu1=7'b1111111;
        4'h9:
          shu1=7'b1111011;
        4'ha:
          shu1=7'b1110111;
        4'hb:  
          shu1=7'b0011111;           
        4'hc:
          shu1=7'b1001110;
        4'hd:
          shu1=7'b0111101;
        4'he:
          shu1=7'b1001111;
        4'hf:
          shu1=7'b1000111; 
        
        default:
          shu1=7'b1111110;       
    endcase

    case(tmrst2)
        4'h0:
          shu2=7'b1111110;
        4'h1:
         shu2=7'b0110000;
        4'h2:
          shu2=7'b1101101;
        4'h3:
          shu2=7'b1111001;         
        4'h4:
          shu2=7'b0110011;
        4'h5:
          shu2=7'b1011011;
        4'h6:
          shu2=7'b1011111;
        4'h7:             
          shu2=7'b1110000;
        4'h8:
          shu2=7'b1111111;
        4'h9:
          shu2=7'b1111011;
        4'ha:
          shu2=7'b1110111;
        4'hb:  
          shu2=7'b0011111;           
        4'hc:
          shu2=7'b1001110;
        4'hd:
          shu2=7'b0111101;
        4'he:
          shu2=7'b1001111;
        4'hf:
          shu2=7'b1000111; 



        default:
          shu2=7'b1111110;   
    
    endcase
    case(tmrst3)
        4'h0:
          shu3=7'b1111110;
        4'h1:
         shu3=7'b0110000;
        4'h2:
          shu3=7'b1101101;
        4'h3:
          shu3=7'b1111001;         
        4'h4:
          shu3=7'b0110011;
        4'h5:
          shu3=7'b1011011;
        4'h6:
          shu3=7'b1011111;
        4'h7:             
          shu3=7'b1110000;
        4'h8:
          shu3=7'b1111111;
        4'h9:
          shu3=7'b1111011;
        4'ha:
          shu3=7'b1110111;
        4'hb:  
          shu3=7'b0011111;           
        4'hc:
          shu3=7'b1001110;
        4'hd:
          shu3=7'b0111101;
        4'he:
          shu3=7'b1001111;
        4'hf:
          shu3=7'b1000111; 

        default:
          shu3=7'b1111110;         
    endcase
end


//设定时间，计时5s功能，当有按键按下时开始计时
always @(posedge clk,negedge rst_n)begin
if(!rst_n)
    begin
    count1<=4'b0100;//复位时使其变成达到五秒状态，接收计时器数值
    flag1<=1'b0;
    end     
else if(flagkey)begin//表明有按键按下                      
      if(c_key_hl!=8'b1110_0111 && c_key_hl!=8'b1110_1101)begin //键值按下  
          count1<=4'b0000;//开始计时
          flag1<=1'b1;        
       end
      else begin//alarmq或者tmq按下
        if(flag1==1'b1 && c_key_hl==8'b1110_0111)begin//5秒内按下tmq
           count1<=4'b0100;
           flag1<=1'b0;
        end
        else if(flag1==1'b1 && c_key_hl==8'b1110_1101)begin//5s内按下了alarmq
           count1<=4'b0100;   
           flag1<=1'b0;          
        end
        else  begin//五秒后按下alarmq或者tmq
           count1<=4'b0100;
           flag1<=1'b0;
         end
    end
  end                         
else if(count1<4 && en_fj1==1)begin
     count1<=count1+1'b1;
     flag1<=1'b1;
 end
else if(count1==4'b0100 && en_fj1==1)
    begin
    flag1<=1'b0;
    count1<=4'b0100;//表明已经达到了五秒。
    end
/*else begin
   flag1<=flag1;
   count1<=count1;
 end*/
end 
          
 //设计闹铃功能
 //对于显示闹铃时间，
always @(posedge clk,negedge rst_n)begin
      if(!rst_n)
      begin
          cuna3<=4'b0000;
          cuna2<=4'b0000;
          cuna1<=4'b0000;
          cuna0<=4'b0000;
      end
      else if(flag1==1'b1 && c_key_hl==8'b1110_1101) begin //则存储闹铃,闹铃需要四个存储器设为cuna3....
          cuna3<=tmrst3;//千万注意，中文情况下，zifu没问题，但是一旦标点或者括号，就有大问题，什么括号都算
          cuna2<=tmrst2;
          cuna1<=tmrst1;
          cuna0<=tmrst0;
      end
      else begin
          cuna3<=cuna3;
          cuna2<=cuna2;
          cuna1<=cuna1;
          cuna0<=cuna0;      
      end
end
//蜂鸣器
reg fm;
always @*
begin
if(jishi3==cuna3 && jishi2==cuna2  && jishi1==cuna1  && jishi0==cuna0)
 fm=1'b1;//蜂鸣器响了
else//组合逻辑一定要加else，否则会出现锁存器，锁存器不属于组合逻辑
 fm=1'b0;//1'b0;
end
endmodule
