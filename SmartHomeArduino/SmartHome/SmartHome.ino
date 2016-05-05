#include <enc28j60.h>
#include <EtherCard.h>
#include <net.h>

 
#include <EtherCard.h>

#define REQUEST_RATE 1000 // milliseconds
/*网络请求相关*/
// ethernet interface mac address
static byte mymac[] = { 0x74,0x69,0x69,0x2D,0x30,0x31 };
// remote website name
const char website[] PROGMEM = "api.yeelink.net";

byte Ethernet::buffer[700];
static long timer;
char response[50] = "{";

/* 开关网络请求完成后的回调函数*/
static void my_result (byte status, word off, word len) {
  Serial.print("<<< reply ");
  Serial.print(millis() - timer);
  Serial.println(" ms");
  bool parseStatus = false;
  int indexOfResponse = 0;
//  Serial.println((const char*) Ethernet::buffer + off);
  for (int index = 0;index < 400; index++) {
    char reply = Ethernet::buffer[off++];
    if (parseStatus == false)
    {
      if (reply !='{') {
        continue;
      }else {
        parseStatus = true;
      }  
    }else {
      indexOfResponse++;
      response[indexOfResponse] = reply;
      if (reply == '}') break;
    }
  } 
  Serial.println(response);
}


/*步进电机相关*/
int motorPin1 = 6;    // Blue   - 28BYJ48 pin 1
int motorPin2 = 7;    // Pink   - 28BYJ48 pin 2
int motorPin3 = 8;    // Yellow - 28BYJ48 pin 3
int motorPin4 = 9;    // Orange - 28BYJ48 pin 4
                        // Red    - 28BYJ48 pin 5 (VCC)

int motorSpeed = 1200;  //variable to set stepper speed
int count = 0;          // count of steps made
int countsperrev = 512; // number of steps per full revolution
int lookup[8] = {B01000, B01100, B00100, B00110, B00010, B00011, B00001, B01001};

//网络请求类型，requestType=1，请求开关；requestType=0，请求电机
bool requestType = 1;
//开关状态,
bool switchStatus = 1;
//步进电机状态
int  stepperStatus = 0;
void setup () {
  pinMode(2,OUTPUT);

  //declare the motor pins as outputs
  pinMode(motorPin1, OUTPUT);
  pinMode(motorPin2, OUTPUT);
  pinMode(motorPin3, OUTPUT);
  pinMode(motorPin4, OUTPUT);
  
  Serial.begin(57600);
  Serial.println("\n[getDHCPandDNS]");
  
  if (!ether.begin(sizeof Ethernet::buffer, mymac, 10))
    Serial.println( "Failed to access Ethernet controller");
 else
   Serial.println("Ethernet controller initialized");
 
  if (!ether.dhcpSetup())
    Serial.println("Failed to get configuration from DHCP");
  else
    Serial.println("DHCP configuration done");
 
  ether.printIp("IP Address:\t", ether.myip);
  ether.printIp("Netmask:\t", ether.netmask);
  ether.printIp("Gateway:\t", ether.gwip);
  ether.printIp("DNS Address:\t", ether.dnsip);

  if (!ether.dnsLookup(website))
    Serial.println("DNS failed");
  ether.printIp("Server: ", ether.hisip);
  
  timer = - REQUEST_RATE; // start timing out right away
}

void loop () {
    
  ether.packetLoop(ether.packetReceive());
 
  if (millis() > timer + REQUEST_RATE) {
    timer = millis();
     if (requestType == 1) {
        Serial.println("\n>>> REQ");
        ether.browseUrl(PSTR("/v1.0/device/345323/sensor/384355/datapoints"), "", website, my_result);
        requestType = 0;
     }else {
        ether.browseUrl(PSTR("/v1.0/device/345323/sensor/387775/datapoints"), "", website, my_result);
        requestType = 1;
     }
  }
//  Serial.print("LED is ");
//  Serial.println(getData());
  if (requestType == 0) {
    if (getData() == 0) {
      switchStatus = 0;
    }else {
      switchStatus = 1;
    }
  }else {
    if (getData() == 0) {
      stepperStatus = 0;
    }else if (getData() == 1) {
      stepperStatus = 1;
    }else {
      stepperStatus = -1;
    }
  }
  
  //开关赋值
  if (switchStatus == 0) {
    digitalWrite(2,HIGH);
  }else {
    digitalWrite(2,LOW);
  }
  
  //电机状态赋值
  if (stepperStatus == 0) {
    stepperStop();
  }else if (stepperStatus == 1) {
    clockwise();
  }else {
    anticlockwise();
  }
}

int getData() {
  int index = 0;
  int status = 0;
  for (index;index < 50;index++) {
    if (response[index] == 'v' &&
        response[index + 1] == 'a' &&
        response[index + 2] == 'l')
    {
      if (response[index + 7] == '1')
      {
        status = 1;
      }else if (response[index + 7] == '0') {
        status = 0;
      }else {
        status = -1;
      }
      break;
    }
  }
  return status;
}

//逆时针旋转函数
void anticlockwise()
{
  for(int i = 0; i < 8; i++)
  {
    setOutput(i);
    delayMicroseconds(motorSpeed);
  }
}

//顺时针旋转函数
void clockwise()
{
  for(int i = 7; i >= 0; i--)
  {
    setOutput(i);
    delayMicroseconds(motorSpeed);
  }
}

void setOutput(int out)
{
  digitalWrite(motorPin1, bitRead(lookup[out], 0));
  digitalWrite(motorPin2, bitRead(lookup[out], 1));
  digitalWrite(motorPin3, bitRead(lookup[out], 2));
  digitalWrite(motorPin4, bitRead(lookup[out], 3));
}

//步进电机停止函数
void stepperStop()
{
  digitalWrite(motorPin1,0);
  digitalWrite(motorPin2,0);
  digitalWrite(motorPin3,0);
  digitalWrite(motorPin4,0);
}
