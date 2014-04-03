/*
 * Copyright XMOS Limited - 2009
 * 
 * An example testbench which instantiates one simulator and connects pairs of pins.
 *
 */

#include <string>
#include <vector>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "xsidevice.h"
using namespace std;
#include "crc.h"
#include "test.h"


/* TODO List*/
/*
 * - Ideally RXA done properly - requires two more states using RxAStartDelay and RxAEndDelay
 * - RxV bubbles in packets
 * - USB clock not right - currently /17
 */

#define PID_OUT   1
#define PID_ACK   2
#define PID_DATA0 3
#define PID_IN    9
#define PID_DATA1 0xb
#define PID_SETUP 0xd

#define PIDn_ACK     0xd2
#define PIDn_DATA0   0xC3
#define PIDn_DATA1   0x4B


#define MAX_INSTANCES 256


#define RX_END_DELAY 3 /* Number of clocks between end of data packet an RXActive going low. See UTMI spec page 59 */


/* All port names relative to Xcore */
#define CLK_PORT        "XS1_PORT_1J"

#define RX_DATA_PORT    "XS1_PORT_8C"

#define RX_RXA_PORT     "XS1_PORT_1O" // FLAG 1

#define RX_RXV_PORT     "XS1_PORT_1M"

#define V_TOK_PORT      "XS1_PORT_1N" 

#define TX_DATA_PORT    "XS1_PORT_8A"
#define TX_RDY_OUT_PORT "XS1_PORT_1K"
#define TX_RDY_IN_PORT "XS1_PORT_1H"

int g_rxEndDelay = RX_END_DELAY;

using namespace std;

typedef enum USBEventType { tx, rx, delay, tok, };

typedef struct testnode                                                
{                                                               
      int data;               // will store information
      testnode *next;             // the reference to the next node
}; 

class USBEvent
{
    protected:
        USBEventType eventType;

    public:
        USBEvent();
        USBEvent (USBEventType e) {eventType = e;}  // Contructor
        USBEventType GetEventType() {return eventType;}
        virtual int GetDelayTime(){return 9999999;}
};


class USBDelay: public USBEvent 
{
    protected:
        int delayTime;

    public:
        USBDelay();
        USBDelay(int d):USBEvent(delay) {delayTime = d;}// Contstructor
        int GetDelayTime() {return delayTime;}
};

class USBRxPacket: public USBEvent 
{
    protected:
        int dataLength;
        unsigned char *data;

    public:
        USBRxPacket();
        USBRxPacket(int l, unsigned char *d):USBEvent(rx) {dataLength = l;data=d;}// Contstructor
        int GetDataLength() {return dataLength;}
        int GetData(int i) {return data[i];}
};

class USBRxToken: public USBEvent 
{
    protected:
        unsigned char pid;
        unsigned char ep;
        bool valid;

    public:
        USBRxToken();
        USBRxToken(unsigned char p, unsigned char e, bool v):USBEvent(tok) {pid = p; ep=e; valid=v;}// Contstructor
        int GetPid() {return pid;}
        int GetEp() {return ep;}
        bool GetValid() {return valid;}
};

class USBTxPacket: public USBEvent 
{
    protected:
        int dataLength; // Expected
        unsigned char *data;  // Expected
        int timeout;          


    public:
        USBTxPacket();
        USBTxPacket(int l, unsigned char *d, int t):USBEvent(tx) {dataLength = l;data=d;timeout=t;}// Contstructor
        int GetDataLength() {return dataLength;}
        int GetData(int i) {return data[i];}
        int GetTimeout() {return timeout;}
};





typedef struct node                                                
{                                                               
      USBEvent *e;               // will store information
      node *next;             // the reference to the next node
};  

void *g_device = 0;
string g_sim_exe_name;

void print_usage()
{
  fprintf(stderr, "Usage:\n");
  fprintf(stderr, "  %s <options> SIM_ARGS\n", g_sim_exe_name.c_str());
  fprintf(stderr, "options:\n");
  fprintf(stderr, "  --help - print this message\n");
  fprintf(stderr, "  --connect <from pkg> <from pin> <to pkg> <to pin> - connect a pair of pads together\n");
  fprintf(stderr, "  SIM_ARGS - the remaining arguments will be passed to the xsim created\n");
  exit(1);
}

#define FAIL_TX_TIMEOUT 0
#define FAIL_TX_TOOSHORT 1
#define FAIL_TX_MISMATCH 2

void fail(int failReason)
{
    switch (failReason)
    {
        case FAIL_TX_TIMEOUT:
            fprintf(stderr, "ERROR: Tx Timeout (Expected packet from XCore but did not receive within timeout\n");
            break;
        
        case FAIL_TX_TOOSHORT:
            fprintf(stderr, "ERROR: Tx Packed ended before expected\n");
            break;
        
        case FAIL_TX_MISMATCH:
            fprintf(stderr, "ERROR: Tx data mismatch\n");
            break;

    }
    fprintf(stderr, "Terminating due to Error\n");
    exit(1);
}


unsigned str_to_uint(const char *val_str, const char *description)
{
  char *end_ptr = 0;
  unsigned value = strtoul(val_str, &end_ptr, 0);

  if (strcmp(end_ptr, "") != 0) {
    fprintf(stderr, "ERROR: could not parse %s\n", description);
    print_usage();
  }
  
  return (unsigned)value;
}

int parse_connect(int argc, char **argv, int index)
{
  if ((index + 4) >= argc) {
    fprintf(stderr, "ERROR: missing arguments for --connect\n");
    print_usage();
  }

  //g_connections[g_num_connections].from_package = argv[index + 1];
  //g_connections[g_num_connections].from_pin     = argv[index + 2];
  //g_connections[g_num_connections].to_package   = argv[index + 3];
  //g_connections[g_num_connections].to_pin       = argv[index + 4];
  //g_num_connections++;
  return index + 5;
}

void parse_args(int argc, char **argv)
{
  g_sim_exe_name = argv[0];
  unsigned int char_index = g_sim_exe_name.find_last_of("\\/");
  if (char_index > 0)
    g_sim_exe_name.erase(0, char_index + 1);

  bool done = false;
  int index = 1;
  while (!done && (index < argc)) {
    if (strcmp(argv[index], "--help") == 0) {
      print_usage();

    //} else if (strcmp(argv[index], "--connect") == 0) {
    //  index = parse_connect(argc, argv, index);

    } 
    else {
      done = true;
    }
  }

  string args;
  while (index < argc) {
    args += " ";
    args += argv[index];
    index++;
  }

  XsiStatus status = xsi_create(&g_device, args.c_str());
  if (status != XSI_STATUS_OK) {
    fprintf(stderr, "ERROR: failed to create device with args '%s'\n", args.c_str());
    print_usage();
  }
}

bool is_pin_driving(const char *package, const char *pin)
{
  unsigned int is_driving = 0;
  XsiStatus status = xsi_is_pin_driving(g_device, package, pin, &is_driving);
  if (status != XSI_STATUS_OK) {
    fprintf(stderr, "ERROR: failed to check for driving pin %s on package %s\n", pin, package);
    exit(1);
  }
  return is_driving ? true : false;
}

unsigned sample_pin(const char *package, const char *pin)
{
  unsigned value = 0;
  XsiStatus status = xsi_sample_pin(g_device, package, pin, &value);
  if (status != XSI_STATUS_OK) {
    fprintf(stderr, "ERROR: failed to sample pin %s on package %s\n", pin, package);
    exit(1);
  }
  return value;
}

void drive_pin(const char *package, const char *pin, unsigned value)
{
  XsiStatus status = xsi_drive_pin(g_device, package, pin, value);
  if (status != XSI_STATUS_OK) {
    fprintf(stderr, "ERROR: failed to drive pin %s on package %s\n", pin, package);
    exit(1);
  }
}

void drive_port(const char *core, const char *port, XsiPortData mask, XsiPortData value)
{
    char *portString;

    if(strcmp(port, CLK_PORT) == 0)
    {
       portString = "CLK_PORT"; 
       //fprintf(stdin, "TB: Driving %s : %x\n", portString, value);
       //fprintf(stdout, "TB: Driving %s : %x\n", portString, value);
    }
    else
    {
        //fprintf(stdout, "TB: Driving %s : %x\n", port, value);
    }


  XsiStatus status = xsi_drive_port_pins(g_device, core, port, mask,value);
  if (status != XSI_STATUS_OK) 
  {
    fprintf(stderr, "\nERROR: failed to drive port %s on core %s\n", port, core);
    exit(1);
  }
}


unsigned sample_port(const char *core, const char *port, XsiPortData mask)
{
    unsigned svalue = 0;

    XsiStatus status = xsi_sample_port_pins(g_device, core, port, mask, &svalue);

    //fprintf(stdout, "TB: Sampled %s : %x\n", port, svalue);

    if (status != XSI_STATUS_OK) 
    {
        fprintf(stderr, "ERROR: failed to sample port %s on core %s\n", port, core);
        exit(1);
    }
    return svalue;
}




int g_usbClock = 0;

/* USB State machine states */
typedef enum USBState {
                            START,
                            IN_DELAY, 
                            RX_DATA,
                            RX_TOKEN_DELAY1,
                            RX_TOKEN_DELAY2,
                            RX_TOKEN_DELAY3,
                            RX_TOKEN_EP1,
                            RX_TOKEN_EP2,
                            RX_DATA_END,
                            TX_DATA,
                            TX_DATA_WAIT,
                        };

USBState g_currentState;
int g_delayCount = 0;
int g_rxDataCount = 0;
int g_rxDataIndex = 0;

int g_txDataCount = 0;
int g_txDataIndex = 0;
int g_txTimeout = 0;

USBDelay *myUsbDelay;
USBRxPacket *myUsbRxPacket;
USBTxPacket *myUsbTxPacket;
USBRxToken *myUsbRxToken;

int stop = 0;

USBState usb_rising(USBState curState, node *head)
{
    node *temp1 = head; 
      
    USBState nextState = g_currentState;
    unsigned expectTxData = 0;

    /* Sample data from device on rising edge */
    unsigned txdRdyOut = sample_port("stdcore[0]", TX_RDY_OUT_PORT, 0xFF);
    unsigned txData = sample_port("stdcore[0]", TX_DATA_PORT, 0xFF);

    switch(curState)
    {
        case START:

            fprintf(stdout, "TB: in START: \n");
            
            /* Pop a usb event from the list */
            //if(head != NULL)
            if(!stop)
            {
                USBEvent *e1 = temp1->e;   

                /* Look for DELAY */
                myUsbDelay = dynamic_cast<USBDelay*>(e1); 
                myUsbRxPacket = dynamic_cast<USBRxPacket*>(e1);
                myUsbRxToken = dynamic_cast<USBRxToken*>(e1);
                myUsbTxPacket = dynamic_cast<USBTxPacket*>(e1);

                if(myUsbDelay)
                {
                    fprintf(stdout, "Read Delay (%d)\n", myUsbDelay->GetDelayTime());
            
                    nextState = IN_DELAY;
                    g_delayCount = myUsbDelay->GetDelayTime();
                }

                /* LOOK FOR RX PACKET */
                else if(myUsbRxPacket)
                {
                    fprintf(stdout, "Read RxPacket (length: %d): ", myUsbRxPacket->GetDataLength());
                    for(int i = 0; i < myUsbRxPacket->GetDataLength(); i++)
                    {
                        fprintf(stdout, "%x ", myUsbRxPacket->GetData(i));
                    } 
                    fprintf(stdout, "\n");
                
                    nextState = RX_DATA;
                    g_rxDataCount = myUsbRxPacket->GetDataLength();
                    g_rxDataIndex = 0;
                }
                else if(myUsbRxToken)
                {
                    fprintf(stdout, "Read RxToken (PID: %d, EP: %d)\n", myUsbRxToken->GetPid(), myUsbRxToken->GetEp());

                    nextState = RX_TOKEN_DELAY1;
                }
                else if(myUsbTxPacket)
                {
                    fprintf(stdout, "Read TxPacket (Length: %d, Timeout: %d): ", 
                            myUsbTxPacket->GetDataLength(), myUsbTxPacket->GetTimeout());

                    expectTxData = 1;

                    for(int i = 0; i < myUsbTxPacket->GetDataLength(); i++)
                    {
                        fprintf(stdout, "%x ", myUsbTxPacket->GetData(i));
                    } 
                    fprintf(stdout, "\n");

                    nextState = TX_DATA_WAIT;
                    g_txDataCount = myUsbTxPacket->GetDataLength();
                    g_txTimeout = myUsbTxPacket->GetTimeout();
                    g_txDataIndex = 0;                  
                    drive_port("stdcore[0]", V_TOK_PORT, 0x1, 0);
                    drive_port("stdcore[0]", RX_RXA_PORT, 0xFF, 0);
                    drive_port("stdcore[0]", RX_RXV_PORT, 0xFF, 0);
                    drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, 0);


                }
                else
                {
                    printf("TB: UNKNOWN EVENT TYPE IN LIST!!\n");
                    while(1);

                }

                if(head->next == NULL)
                {
                        stop = 1;
                }
                else    
                {
                    *head = *head->next;   // tranfer the address of 'temp->next' to 'temp'
                }
            }
            else
            {
                fprintf(stdout, "END OF EVENT LIST\n");
                fprintf(stdout, "PASS PASS PASS PASS PASS PASS PASS PASS PASS PASS PASS\n");
                while(1);
            }           

            break;

        case IN_DELAY:

            //fprintf(stdout, "TB: IN_DELAY (%d)\n", g_delayCount);

            drive_port("stdcore[0]", RX_RXA_PORT, 0x1, 0);
            drive_port("stdcore[0]", RX_RXV_PORT, 0x1, 0);
            //drive_port("stdcore[0]", V_TOK_PORT, 0x1, 0);
            drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, 0x0);

            /* Reduce delay once per period (so every other usb_tick)*/
            if(g_usbClock == 1)
            {
                g_delayCount--;
                if(g_delayCount == 0)
                {
                    /* End of Delay.. go back to start and read new event*/
                    nextState = START;
                    fprintf(stdout, "TB: End of Delay\n\n");
                }
                else
                {
                    nextState = IN_DELAY;
                }
            }
            else
            {
                nextState = IN_DELAY;
            }
            break; 

        case RX_DATA:

            fprintf(stdout, "TB: RX_DATA %d : %d\n", g_rxDataIndex, myUsbRxPacket->GetData(g_rxDataIndex));
            nextState = RX_DATA;

            //drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, myUsbRxPacket->GetData(g_rxDataIndex));

            // Change data on falling edge
            if(g_usbClock)
            {
                g_rxDataIndex++;
            }

            
            break; 

        case RX_TOKEN_DELAY1:
            break;  
        
         case RX_TOKEN_DELAY2:
            break; 
        
         case RX_TOKEN_DELAY3:
            break; 

        case RX_TOKEN_EP1:
            break;

        case RX_TOKEN_EP2:
            break;

        case TX_DATA_WAIT:
            {
            /* Waiting for TX DATA */
            fprintf(stdout, "TB: TX_DATA_WAIT Expecting: %x (Timeout: %d)\n", myUsbTxPacket->GetData(g_txDataIndex), g_txTimeout);
            nextState = TX_DATA_WAIT;

            expectTxData = 1;

            unsigned txVld = sample_port("stdcore[0]", TX_RDY_OUT_PORT, 0xFF);

            if(txVld)
            {

                unsigned char sample = sample_port("stdcore[0]", TX_DATA_PORT, 0xFF);
                fprintf(stdout, "TB: RECEIVED BYTE: %x : ", sample);

                if(sample == (unsigned)myUsbTxPacket->GetData(g_txDataIndex))
                {
                    fprintf(stdout, "MATCH\n");
                }
                else
                {
                    //fprintf(stdout, "ERROR!!\n");
                    //while(1);
                    fail(FAIL_TX_MISMATCH);
                }
                g_txDataIndex++;

                if(g_txDataIndex == g_txDataCount)
                {
                    nextState = START;
                }
                else
                {
                    nextState = TX_DATA;
                }
            }
            else
            {
                g_txTimeout--;
                if(g_txTimeout == 0)
                {
                    fail(FAIL_TX_TIMEOUT);
                }
            }
            }
            break;
        
        case TX_DATA:
        {
            /* TODO CHECK FOR PACKET ENDING EARLY */
            fprintf(stdout, "TB: TX_DATA\n");
           
            unsigned txVld = sample_port("stdcore[0]", TX_RDY_OUT_PORT, 0xFF);

            expectTxData = 1;

            if(txVld)
            {
                unsigned char sample = sample_port("stdcore[0]", TX_DATA_PORT, 0xFF);
                fprintf(stdout, "TB: RECEIVED BYTE: %x : ", sample);

                if(sample == (unsigned)myUsbTxPacket->GetData(g_txDataIndex))
                {
                    fprintf(stdout, "MATCH\n");
                }
                else
                {
                    fail(FAIL_TX_MISMATCH);
                }
                g_txDataIndex++;

                if(g_txDataIndex == g_txDataCount)
                {
                    nextState = START;
                }
                else
                {
                    nextState = TX_DATA;
                }
            }
            else
            {
                fail(FAIL_TX_TOOSHORT);
            }
           
            
            break; 
        }
        default:
            
            fprintf(stdout, "TB: UNKNOWN STATE: %d\n", g_currentState);
            break;
        
    }

    if(!expectTxData)
    {
        if(txdRdyOut!=0) /* TxData may be non-zero but we dont care do long as ReadyOut == 0 */
        { 
            fprintf(stdout, "TB: !!! ERROR: UNEXPECTED DATA FROM XCORE!!!\n");

            fprintf(stdout, "TB: TxReady High\n");

            if(txData != 0)
                fprintf(stdout, "TB: TxData != 0\n");
            
            while(1);
        }
    }

    return nextState;


}

USBState usb_falling(USBState curState)
{
    USBState nextState = curState;

    switch (curState)
    {
        case RX_TOKEN_DELAY1:

            /* Drive out start of token (PID) */
            drive_port("stdcore[0]", V_TOK_PORT, 0x1, 0);
            drive_port("stdcore[0]", RX_RXA_PORT, 0xFF, 1);
            drive_port("stdcore[0]", RX_RXV_PORT, 0xFF, 1);
            drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, myUsbRxToken->GetPid());

            fprintf(stdout, "TB: RX_TOKEN_DELAY1\n");
            nextState = RX_TOKEN_DELAY2;
            break;  

        case RX_TOKEN_DELAY2:

            /* End of PID cycle */
            drive_port("stdcore[0]", RX_RXV_PORT, 0xFF, 0);
            drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, 0);

            fprintf(stdout, "TB: RX_TOKEN_DELAY2\n");
            nextState = RX_TOKEN_DELAY3;
            break; 
        
        case RX_TOKEN_DELAY3:

            /* Cycle gap */

            fprintf(stdout, "TB: RX_TOKEN_DELAY3\n");
            nextState = RX_TOKEN_EP1;
            break; 

        case RX_TOKEN_EP1:

            /* Drive out EP number */
            /* Valid token high also */
            drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, myUsbRxToken->GetEp());
            drive_port("stdcore[0]", RX_RXV_PORT, 0xFF, 1);
            if(myUsbRxToken->GetValid()==true)
            {
                drive_port("stdcore[0]", V_TOK_PORT, 0xFF, 1);
            }
            else
            {
                drive_port("stdcore[0]", V_TOK_PORT, 0xFF, 0);
            }
            nextState = RX_TOKEN_EP2;
            break;

         case RX_TOKEN_EP2:
            
            /* End of EP */
            drive_port("stdcore[0]", RX_RXV_PORT, 0xFF, 0);
            drive_port("stdcore[0]", RX_RXA_PORT, 0xFF, 0);
            drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, 0);
            nextState = START;

            break;

        case RX_DATA:

            /* Drive out RX DATA on falling edge */
            drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, myUsbRxPacket->GetData(g_rxDataIndex));

            drive_port("stdcore[0]", V_TOK_PORT, 0x1, 0);
            drive_port("stdcore[0]", RX_RXA_PORT, 0xFF, 1);
            drive_port("stdcore[0]", RX_RXV_PORT, 0xFF, 1);
            drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, myUsbRxPacket->GetData(g_rxDataIndex));


            /* End of RX data */
            if(g_rxDataIndex == g_rxDataCount)
            {
                    /* Return to start state */
                    //drive_port("stdcore[0]", RX_RXA_PORT, 0xFF, 0);
                    drive_port("stdcore[0]", RX_RXV_PORT, 0xFF, 0);
                    drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, 0);
                    nextState = RX_DATA_END;
                    g_rxEndDelay = RX_END_DELAY;

                    fprintf(stdout, "TB: EN OF RX DATA\n");
            }
            break;

        case RX_DATA_END:
                
            g_rxEndDelay--;

            if(g_rxEndDelay < 0)
            {
                drive_port("stdcore[0]", RX_RXA_PORT, 0xFF, 0);
                nextState = START;
            }
                
            break;

        default:

            break;

    }


    return nextState;

}





  

void usb_tick(node *head)
{

    node *temp1 = head; 
      
    USBState nextState = g_currentState;

    /* Toggle USB clock port */
    g_usbClock = !g_usbClock;

    drive_port("stdcore[0]", CLK_PORT, 0x1, g_usbClock);

    if(g_usbClock)
    {
        nextState = usb_rising(g_currentState, head);
    }
    else
    {
        nextState = usb_falling(g_currentState);
    }

    g_currentState = nextState;

}


XsiStatus sim_clock()
{
  XsiStatus status = xsi_clock(g_device);
  if ((status != XSI_STATUS_OK) && (status != XSI_STATUS_DONE)) {
    fprintf(stderr, "ERROR: failed to clock device (status %d)\n", status);
    exit(1);
  }
  return status;
}

void PrintUSBEventList(node *head)
{
    fprintf(stdout, "\nUSB Event List:\n");

    node *temp1 = head; 
      
    int x = 0;
 
    while(temp1 != NULL)
    {
        printf("EVENT %d: ", x);

        x++;
        
        USBEvent *e1 = temp1->e;   

        USBDelay * myUsbDelay = dynamic_cast<USBDelay*>(e1);
        
        if(myUsbDelay)
        {
            fprintf(stdout, "Delay (%d)\n", myUsbDelay->GetDelayTime());
        }

        USBRxPacket * myUsbRxPacket = dynamic_cast<USBRxPacket*>(e1);

        if(myUsbRxPacket)
        {
            fprintf(stdout, "RxPacket (length: %d): ", myUsbRxPacket->GetDataLength());
            for(int i = 0; i < myUsbRxPacket->GetDataLength(); i++)
            {
                fprintf(stdout, "%x ", myUsbRxPacket->GetData(i));
            } 
            fprintf(stdout, "\n");
        }

        USBRxToken * myUsbRxToken = dynamic_cast<USBRxToken*>(e1);
        
        if(myUsbRxToken)
        {
            fprintf(stdout, "RxToken (PID: %d, EP: %d)\n", myUsbRxToken->GetPid(), myUsbRxToken->GetEp());
        }

        temp1 = temp1->next;   // transfer the address of 'temp->next' to 'temp'
    }

    printf("Done\n");
}

void AddUSBEventToList(node **head, USBEvent *e)
{
    node *temp;             //create a temporary node 
    temp = (node*)malloc(sizeof(node)); //allocate space for  

    temp->e = e;             // store data(first field)
    temp->next=*head;  // store the address of the pointer head(second field)
    *head = temp;
}


void AddList(testnode **testhead, int i)
{
 testnode *temp;             //create a temporary node 
        temp = (testnode*)malloc(sizeof(testnode)); //allocate space for node 

        temp->data = i;             // store data(first field)
        temp->next=*testhead;  // store the address of the pointer head(second field)
        *testhead = temp;                  // transfer the address of 'temp' to 'head' 


}

 
#define RX_DATALENGTH 10
#define RX_PKTLENGTH (RX_DATALENGTH+3)

int counter = 0;
unsigned char g_rxDataVal[5] = {1,1,1,1,1};
unsigned char g_txDataVal[5] = {1,1,1,1,1};

unsigned char g_pidTableIn[16];
unsigned char g_pidTableOut[16];

//eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, 10);
/* NOTES:
 * We need badCrc AND handshake flags to deal with Iso endpoints
 *
 * TODO:
 * - timeout value
 * - Could take a hex value for handshake not 1 or 0 (0 would mean none)
 * 
 * Restrictions: 
 * - Can't send a handshake of 0x00 - passing 0 in for handshake will cause no handshake to be sent 
 */
int AddInTransaction(USBEvent **UsbEventList, int eventIndex, int epNum, int length, int badCrc, unsigned char handshake)
{
    unsigned char *data = new unsigned char[length];
    unsigned char *packet = new unsigned char[length+3]; /* +3 for PID and CRC */
    unsigned char *dataAck = new unsigned char[1];
    dataAck[0] = handshake;

    /* Populate expected data */
    for (int i = 0; i< length; i++)
    {
        data[i] = g_txDataVal[epNum]++;
    }

    /* Create good CRC */
    unsigned crc = GenCrc16(data, length);

    /* PID */
    packet[0] = g_pidTableIn[epNum];
   
    for(int i = 0; i < length; i++)
    {
        packet[i+1] = data[i];
    }
    
    packet[length+1] = crc & 0xff;
    packet[length+2] = (crc>>8);

    /* Token: TB -> XCore */ 
    UsbEventList[eventIndex++] = new USBRxToken(PID_IN, epNum, true);

    /* Data: XCore -> TB */
    UsbEventList[eventIndex++] = new USBTxPacket(length+3, packet, 200);
 
    UsbEventList[eventIndex++] = new USBDelay(15);

    if(!badCrc)
    {
        if(handshake)
        {
            UsbEventList[eventIndex++] = new USBRxPacket(1, dataAck);

            if(handshake != PID_ACK)
            {
                /* We expect a re-send */
                g_txDataVal[epNum]-=length;
            }
            else
            {
                /* toggle PID */
                g_pidTableIn[epNum] ^= 0x88;
            }
        }
        else
        {
            /* If no handshake then ISO.. dont don anything... */
        }
    }
    else
    {
        /* Emulate bad crc by not sending ack - we expect a resend*/
        g_txDataVal[epNum]-=length;
    }
    return eventIndex;
}

int AddSetupTransaction(USBEvent **UsbEventList, int eventIndex, int epNum, unsigned char dataPid, uint length, int badCrc, int handshake, bool valid)
{
    unsigned char *data = new unsigned char[length];
    unsigned char *packet = new unsigned char[length+3]; /* +3 for PID and CRC */
    unsigned char *dataAck = new unsigned char[1];
    dataAck[0] = PIDn_ACK;

    /* Populate expected data */
    for (int i = 0; i< length; i++)
    {
        data[i] = g_rxDataVal[epNum]++;
    }

    /* Create good CRC */
    unsigned crc = GenCrc16(data, length);

    /* PID and toggle */
    if(dataPid != 0)
    {
        g_pidTableOut[epNum] = dataPid;
    }    
    
    packet[0] = g_pidTableOut[epNum];

    /* Dont toggle pid if we know we are sending a bad crc.. */
    if(!badCrc)
        g_pidTableOut[epNum] ^= 0x8;

    for(int i = 0; i < length; i++)
    {
        packet[i+1] = data[i];
    }
 
    if(!badCrc)
    {   
        packet[length+1] = crc & 0xff;
        packet[length+2] = (crc>>8);
    }
    else
    {
        /* Set the CRC to something weird.. */
        packet[length+1] = 0xff;
        packet[length+2] = 0xff;
    }

    UsbEventList[eventIndex++] = new USBRxToken(PID_SETUP,epNum, valid);
    UsbEventList[eventIndex++] = new USBDelay(40);
    UsbEventList[eventIndex++] = new USBRxPacket(length+3, packet); /* +3 for PID and CRC */

    if(valid)
    {
        if(handshake && !badCrc)
        {
            UsbEventList[eventIndex++] = new USBTxPacket(1, dataAck, 30);
        }

        if(badCrc)
        {
            /* If CRC is bad then dont expect handshake.  We need to resend */
            g_rxDataVal[epNum] -= length;
        }
    }
    else
    {
        g_rxDataVal[epNum] -= length;
    }

    return eventIndex;
}


int g_numTests = 0;



int AddOutTransaction(USBEvent **UsbEventList, int eventIndex, int epNum, unsigned char dataPid, uint length, int badCrc, int handshake, bool valid)
{
    unsigned char *data = new unsigned char[length];
    unsigned char *packet = new unsigned char[length+3]; /* +3 for PID and CRC */
    unsigned char *dataAck = new unsigned char[1];
    dataAck[0] = PIDn_ACK;

    /* Populate expected data */
    for (int i = 0; i< length; i++)
    {
        data[i] = g_rxDataVal[epNum]++;
    }

    /* Create good CRC */
    unsigned crc = GenCrc16(data, length);

    /* PID and toggle */
    if(dataPid != 0)
    {
        g_pidTableOut[epNum] = dataPid;
    }    
    
    packet[0] = g_pidTableOut[epNum];

    /* Dont toggle pid if we know we are sending a bad crc.. */
    if(!badCrc)
        g_pidTableOut[epNum] ^= 0x8;

    for(int i = 0; i < length; i++)
    {
        packet[i+1] = data[i];
    }
 
    if(!badCrc)
    {   
        packet[length+1] = crc & 0xff;
        packet[length+2] = (crc>>8);
    }
    else
    {
        /* Set the CRC to something weird.. */
        packet[length+1] = 0xff;
        packet[length+2] = 0xff;
    }

    UsbEventList[eventIndex++] = new USBRxToken(PID_OUT,epNum, valid);
    UsbEventList[eventIndex++] = new USBDelay(40);
    UsbEventList[eventIndex++] = new USBRxPacket(length+3, packet); /* +3 for PID and CRC */

    if(valid)
    {
        if(handshake && !badCrc)
        {
            UsbEventList[eventIndex++] = new USBTxPacket(1, dataAck, 30);
        }

        if(badCrc)
        {
            /* If CRC is bad then dont expect handshake.  We need to resend */
            g_rxDataVal[epNum] -= length;
        }
    }
    else
    {
        g_rxDataVal[epNum] -= length;
    }

    return eventIndex;
}
int main(int argc, char **argv)
{
    parse_args(argc, argv);

    // Empty linked list
    node *head = NULL;

    
    
    /* Init port state */
    drive_port("stdcore[0]", RX_RXA_PORT, 0x1, 0);
    drive_port("stdcore[0]", RX_RXV_PORT, 0x1, 0);
    drive_port("stdcore[0]", V_TOK_PORT, 0x1, 0);
    drive_port("stdcore[0]", RX_DATA_PORT, 0xFF, 0x0);
    drive_port("stdcore[0]", TX_RDY_IN_PORT, 0xFF, 0x1);

    /* Create test datapacket */
    unsigned char *data;
    unsigned char *dataPacket;
    data = new unsigned char[RX_DATALENGTH];
    dataPacket = new unsigned char[RX_PKTLENGTH];

    unsigned char *dataNak = new unsigned char[1];
    unsigned char *dataAck = new unsigned char[1];
    dataNak[0] = 0x5a;
    dataAck[0] = 0xd2;
    int len = 0;
    int ep  = 0;
    int handshake = 1;
    int badcrc = 0;
    bool valid = true;
    unsigned char dataPid = 0;
    int newlen = 0;

    for (int i = 0; i < 16; i++)
    {
        g_pidTableIn[i] = PIDn_DATA0;
        g_pidTableOut[i] = PID_DATA0;
    }
    
    int eventIndex = 0;   

    /* Bad CRC*/
    for (int i = 0; i < RX_DATALENGTH; i++)
    {
        data[i] = i+1; 
    }

    /* GOOD CRC TEST */
    unsigned crc = GenCrc16(data, RX_DATALENGTH);

    dataPacket[0] = PIDn_DATA0;
    for(int i = 0; i < RX_DATALENGTH; i++)
    {
        dataPacket[i+1] = data[i];
    }

#if (TEST_ACK) || (TEST_NAK)
    dataPacket[RX_PKTLENGTH-2] = crc & 0xff;
    dataPacket[RX_PKTLENGTH-1] = (crc>>8);
#endif

#define NUM_EVENTS 100
    USBEvent *UsbEventList[NUM_EVENTS];

    /* Create test packet list */
    UsbEventList[eventIndex++] = new USBDelay(1500);

#if 0
    /**** Simple control transfer test 
     * Note Payload should *always* be 8 bytes
     * Note Device should *never* NAK a SETUP 
     * Data PID *always* DATA0
     */
     
    valid = true;
    ep = 0;
    badcrc = 0;
    handshake = 1;
    dataPid = PID_DATA0;

    /* Simulate a SET request */
    /* SETUP Stage */
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddSetupTransaction(UsbEventList, eventIndex, 0, dataPid, 8, badcrc, handshake, valid);

    /* Data Stage*/
    dataPid = 0;
    badcrc = 0;
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 0, dataPid, RX_DATALENGTH, badcrc, 1, true); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 0, dataPid, RX_DATALENGTH+1, badcrc, 1, true); /* EP, Length */
    
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 0, dataPid, RX_DATALENGTH+2, badcrc, 1, true); /* EP, Length */

    /* Status stage - zero length IN */
    UsbEventList[eventIndex++] = new USBDelay(100);
    g_pidTableIn[0] = PIDn_DATA1;

    eventIndex = AddInTransaction(UsbEventList, eventIndex, 0, 0, badcrc,  PID_ACK); /* EP, Length, handshake */

#if 1
    /* Simulate a GET request */
     /* SETUP Stage */
    dataPid = PID_DATA0;
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddSetupTransaction(UsbEventList, eventIndex, 0, dataPid, 8, badcrc, handshake, valid);

    /* Data stage IN */
    UsbEventList[eventIndex++] = new USBDelay(100);
    /* Need to reset PID toggling on a setup */
    g_pidTableIn[0] = PIDn_DATA1;
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 0, RX_DATALENGTH+2, badcrc,  PID_ACK); /* EP, Length, handshake */

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 0, RX_DATALENGTH+2, badcrc,  PID_ACK); /* EP, Length, handshake */

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 0, RX_DATALENGTH+2, badcrc,  PID_ACK); /* EP, Length, handshake */

    /* Status stage - zero length OUT (DATA1 PID) */
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 0, PID_DATA1, 0, 0, 1, true); /* EP, Length */
    
    /****/
#endif

#if 1
/**** Test bad CRC in OUT data */
    badcrc = 1;
    dataPid = 0;
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH+1, badcrc, 1, true); /* EP, Length */
    
    /* We should not receive ACK from XCore (due to bad CRC) - re-send same packet */
    badcrc = 0;
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH+1, badcrc, 1, true); /* EP, Length */

    /* Send another to check things are okay.. */
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH, badcrc, 1, true); /* EP, Length */
    /* End test */
#endif


#if 1
#if 1
    /***** Test out of sequence OUT data PIDS - i.e. situation where XCore ack didn't make it to host 
     * i.e. PID sequence DATA0 DATA1 DATA1 DATA0
     * Expected behaviour is that the second DATA1 packet is ACKed but the data is junked.
     * USB Spec page 159
     */
    valid = true;
    badcrc = 0;
    handshake = 1;
    dataPid = PID_DATA1;

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, 0, RX_DATALENGTH, badcrc, handshake, valid); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, 0, RX_DATALENGTH, badcrc, handshake, valid); /* EP, Length */
     
    UsbEventList[eventIndex++] = new USBDelay(100);
    g_rxDataVal[1] -= RX_DATALENGTH; /* Manual reset of length counter */
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH, badcrc, handshake, valid); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, 0, RX_DATALENGTH, badcrc, handshake, valid); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(500);
    /*****/
#endif

#if 1
    /***** Basic OUT Testing with different tail lengths */
    dataPid = 0;
    badcrc = 0;
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH, 0, 1, true); /* EP, Length */
    

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH+1, 0, 1, true); /* EP, Length */
    
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH+2, 0, 1, true); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH+3, 0, 1, true); /* EP, Length */
    /*End test */
#endif

#if 1
    /**** Test bad CRC in OUT data */
    badcrc = 1;
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH+1, badcrc, 1, true); /* EP, Length */
    
    /* We should not receive ACK from XCore (due to bad CRC) - re-send same packet */
    badcrc = 0;
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH+1, badcrc, 1, true); /* EP, Length */

    /* Send another to check things are okay.. */
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH, badcrc, 1, true); /* EP, Length */
    /* End test */
#endif

#if 1
    /**** Test OUT zero length */
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, 0, badcrc, 1, true); /* EP, Length */

    /* Send another to make sure all okay - have to allow bigger delays for checks for longer packets */
    UsbEventList[eventIndex++] = new USBDelay(200);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, 40, badcrc, 1, true); /* EP, Length */
    
    UsbEventList[eventIndex++] = new USBDelay(300);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, 41, badcrc, 1, true); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(200);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, 42, badcrc, 1, true); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(200);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, 43, badcrc, 1, true); /* EP, Length */

    /* End test */
#endif

#if 1 
    /**** ISO OUT tests - no handshaking */
    ep = 2;
    handshake = 0;
    badcrc = 0;
    len = RX_DATALENGTH;
    dataPid = PID_DATA0;
    
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, dataPid, len, badcrc, handshake, true); /* EP, Length */
    
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, dataPid, len+1, badcrc, handshake, true); /* EP, Length */
    
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, dataPid, len+2, badcrc, handshake, true); /* EP, Length */
  
    /* Zero length ISO test */
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, dataPid, 0, badcrc, handshake, true); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, dataPid, len+3, badcrc, handshake, true); /* EP, Length */


#endif
#endif
#if 1
#if 1 
    /**** Basic bulk IN test */
    dataPid = 0;
    badcrc = 0;
    ep = 1;
    handshake = PID_ACK;
    newlen = 0;
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, dataPid, newlen, 0, 1, true); 

    UsbEventList[eventIndex++] = new USBDelay(500);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, ep, RX_DATALENGTH+1, badcrc, handshake); 
    
    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, dataPid, newlen, 0, 1, true); 

    /* Test some more lengths... */
    for(int i = 0; i< 30; i++)
    {
        UsbEventList[eventIndex++] = new USBDelay(100);
        eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, dataPid, newlen+1+i, 0, 1, true); 


        UsbEventList[eventIndex++] = new USBDelay(100);
        eventIndex = AddInTransaction(UsbEventList, eventIndex, ep, newlen+i, badcrc, handshake); 
    }
    /****/
#endif
#endif

#if 1
    /* IN ISO */
    ep = 2;
    handshake = 0;
    newlen = 0;

    UsbEventList[eventIndex++] = new USBDelay(100);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, PID_DATA0, newlen, 0, handshake, true); 

    UsbEventList[eventIndex++] = new USBDelay(500);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, ep, RX_DATALENGTH, badcrc, handshake); 

    UsbEventList[eventIndex++] = new USBDelay(500);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, ep, newlen, badcrc, 0); 
 
    for(int i = 0; i < 40; i++)
    { 
        UsbEventList[eventIndex++] = new USBDelay(100);
        eventIndex = AddOutTransaction(UsbEventList, eventIndex, ep, PID_DATA0, newlen+1+i, 0, handshake, true); 
   
        UsbEventList[eventIndex++] = new USBDelay(100);
        eventIndex = AddInTransaction(UsbEventList, eventIndex, ep, newlen+i, badcrc, 0); 
    }

#endif
#endif

#if 0
    /**** Test emulation of BAD crc for IN - no ACK from host. We expect a resend of same data */
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, dataPid, RX_DATALENGTH, 0, 1, true); /* EP, Length */
    UsbEventList[eventIndex++] = new USBDelay(500);
    
    UsbEventList[eventIndex++] = new USBDelay(500);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, 30, badcrc, PID_ACK); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(500);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, RX_DATALENGTH, badcrc, PID_ACK); /* EP, Length */


    //badcrc = 1;
    //eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, RX_DATALENGTH, badcrc, 0); /* EP, Length */
    
    badcrc = 1;
    UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, RX_DATALENGTH, badcrc, PID_ACK); /* EP, Length */

    badcrc = 0;
    UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, RX_DATALENGTH, badcrc, PID_ACK); /* EP, Length */
    
    UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, RX_DATALENGTH, badcrc, PID_ACK); /* EP, Length */
    /*****/
#endif

#if 0
    /***** Test IN with BAD handshake */
    len = RX_DATALENGTH;
    badcrc = 0;
    UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, RX_DATALENGTH, badcrc,  0xFF); 

    /* Expect resend of same data here... */
    UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, RX_DATALENGTH, badcrc, PID_ACK); 

    /*****/
#endif


    /*** Test the shared thread EP model (EP's 3+4) */
    UsbEventList[eventIndex++] = new USBDelay(700);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 3, dataPid, RX_DATALENGTH, 0, 1, true); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 3, dataPid, RX_DATALENGTH, 0, 1, true); /* EP, Length */

     UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 4, dataPid, RX_DATALENGTH, 0, 1, true); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 4, dataPid, RX_DATALENGTH, 0, 1, true); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 3, RX_DATALENGTH, badcrc, PID_ACK); 

    UsbEventList[eventIndex++] = new USBDelay(50);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 3, RX_DATALENGTH, badcrc, PID_ACK); 
#if 0
    /***** Test some invalid IN tokens */
    UsbEventList[eventIndex++] = new USBDelay(50);
 
    UsbEventList[eventIndex++] = new USBRxToken(PID_IN, 1, false);
    UsbEventList[eventIndex++] = new USBDelay(50);
    
    UsbEventList[eventIndex++] = new USBRxToken(PID_IN, 9, false); /* odd ep */
    UsbEventList[eventIndex++] = new USBDelay(50);
    
    UsbEventList[eventIndex++] = new USBRxToken(0x56, 1, false); /* Weird pid */
    UsbEventList[eventIndex++] = new USBDelay(50);
    
    /* Invalid out transfer */
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 5, RX_DATALENGTH, 0, 1, false); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(50);
    
    /* Send good out transfer to check everything okay */
    eventIndex = AddOutTransaction(UsbEventList, eventIndex, 1, RX_DATALENGTH, 0, 1, true); /* EP, Length */

    UsbEventList[eventIndex++] = new USBDelay(300);
    eventIndex = AddInTransaction(UsbEventList, eventIndex, 1, RX_DATALENGTH, badcrc, PID_ACK); /* EP, Length */
#endif

    /* Must give enough delay for exit() on xcore to run .. this is a TODO item */
    UsbEventList[eventIndex++] = new USBDelay(500);

    for(int i = eventIndex-1; i >= 0; i--)
    {
        AddUSBEventToList(&head, UsbEventList[i]);
    }    

    PrintUSBEventList(head);

    printf("\nRunning Sim...\n");
        

    int time = 0;

    bool done = false;
    while (!done) 
    {
        XsiStatus status = sim_clock();
        if (status == XSI_STATUS_DONE)
        {
            done = true;
        }
    
        time++;

        // USB tick every 8 sim ticks
        if(time == 8)
        {
            time = 0;
            usb_tick(head);
        }

   
    }

  XsiStatus status = xsi_terminate(g_device);
  if (status != XSI_STATUS_OK) {
    fprintf(stderr, "ERROR: failed to terminate device\n");
    exit(1);
  }
  return 0;
}
