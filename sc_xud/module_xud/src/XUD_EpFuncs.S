/** XUD_EpFuncs.S
  * @brief     Functions for data transfer to/from XUD
  * @author    Ross Owen, XMOS Limited
  */
#include <usb.h>

.section        .cp.const4,"aMc",@progbits,4
.align  4
minus2:
.long  0xfffffffe
.text

    
#define SR_EEBLE_BIT 0x1
//int XUD_GetSetupData(XUD_ep e_out, XUD_ep in, unsigned buffer[]); 
//                 r0                  r1              r2     
// TODO just use GetData
.globl   XUD_GetSetupData
.globl   XUD_GetSetupData.nstackwords
.linkset XUD_GetSetupData.nstackwords, 4
.text

.cc_top XUD_GetSetupData.func, XUD_GetSetupData

ResetSuspendSetup:
    mkmsk      r0, 32                           // Return -1 as length
    ldw         r10, sp[2]                        
    ldw         r4, sp[1]    
    retsp      4

XUD_GetSetupData:
    
    entsp       4
    stw         r4, sp[1]                       
    stw         r10, sp[2]                       

XUD_GetSetupData_:
    ldw        r4, r0[0]                        // Load mem address of EP structure
    stw        r2, r0[3]    
    stw        r0, r4[0]
    ldw        r10, r0[2]    


XUD_GetSetupData_Retry: 
    testct     r11, res[r10]                      // Test whether there is a RESET/SUSPEND exception
    bt         r11, ResetSuspendSetup
        
XUD_GetSetupData_NoReq:                         // Entry for _NoReq 
    in         r3, res[r10]                     // Input packet "word" length 
    testct     r11, res[r10]                    // CT means we got a SETUP (not OUT).
    bf         r11, XUD_GetSetupData_GotOut
    inct        r11, res[r10]                   // Always get 0 (expect 8 bytes data)

//XUD_GetSetupData_CheckPid: 
                                                // We expect data0 else something gone wrong...
                                                // TODO..

XUD_GetSetupData_ResetPid:                      // We must reset PID toggling on SETUP (both IN AND OUT)
    ldc         r11, PID_DATA1
    stw         r11, r0[4]                      // Reset OUT toggle

//#ifdef ARCH_S
    ldc         r11, PIDn_DATA1
//#else
    //ldc         r11, PID_DATA1
//#endif  
											
    stw         r11, r1[4]                      // Reset IN toggle


    ldc         r0, 8                           // Return 8 byte length (TODO really could return actual length here)
    ldw         r10, sp[2]                        
    ldw         r4, sp[1]                        
    retsp       4

XUD_GetSetupData_GotOut:                        // Got an OUT intead not a SETUP
    int         r11, res[r10]

//CalcdataLength:
    shl         r3, r3, 2                       // Num received words to bytes
    add         r3, r11, r3                     // r11: Total bytes received (Note this includes 2 byte crc)

XUD_GetSetupData_CheckPid: 
    ldw         r11, r0[6]                      // Load received PID from EP structure
    shr         r11, r11, 24                    // Shift down due to inpw
    ldw         r10, r0[4]                      // Load expected PID 

    xor         r11, r10, r11                   // Do the comparison
    bt          r11, XUD_GetSetupData_               // Ignore packet...

//XUD_GetData_PidOkay: 
    stw         r11, r4[0]                      // Zero ready entry (NOTE R11 0 from branch above)  
                                                // TODO is there a race here? Should this happen in XUD thread? 
    
    ldw         r11, r0[5]                      // Load EP type
    bf          r11, XUD_GetSetupData_ReturnOk       // Jump over PID toggle for ISO  

//XUD_GetData_PidToggle:
    ldc         r11, 8
    xor         r10, r10, r11
    stw         r10, r0[4]
 
XUD_GetSetupData_ReturnOk:
    sub         r0, r3, 2                       // Length correction for CRC correction (return val in r0) 

    ldw         r10, sp[2]                        
    ldw         r4, sp[1]                        
    retsp       4

.cc_bottom XUD_GetSetupData.func


.cc_top XUD_SetData_Select.func, XUD_SetData_Select


//void XUD_SetData_Select(chan c, XUD_ep ep, unsigned &x);
//                         r0,      r1           r2
.globl   XUD_SetData_Select
.globl   XUD_SetData_Select.nstackwords
.linkset XUD_SetData_Select.nstackwords, 4

XUD_SetData_Select:
    entsp 4
    stw   r4, sp[1]

    in          r3, res[r0]                   // Data sent okay 

XUD_SetData_LoadEpType_:
    ldw         r11, r1[5]                      // Don't do any toggling for ISO
    bf          r11, XUD_SetData_DonePid_

XUD_SetData_PidToggle_:                          // 
    ldw         r11, r1[4]                      // Load EP PID from structure 
    ldc         r4, 0x88                        
    xor         r11, r11, r4                
    stw         r11, r1[4]                      // Store back PID

XUD_SetData_DonePid_:                        
    //ldw         r0, sp[1]                  
    //ldw         r1, sp[2]
    //ldw         r2, sp[3]
    //ldw         r3, sp[4]  
Return2_:                                       // Reg restore
    ldw         r4, sp[1]        
    retsp       4
    
.cc_bottom XUD_SetData_Select.func





//void XUD_GetData_Select(chan c, XUD_ep ep, unsigned &x);
//                         r0,      r1           r2
.globl   XUD_GetData_Select
.globl   XUD_GetData_Select.nstackwords
.linkset XUD_GetData_Select.nstackwords, 0

.cc_top XUD_GetData_Select.func, XUD_GetData_Select
    
XUD_GetData_Select:                             // Entry for _NoReq 
    testct     r3, res[r0]
    bt         r3, XUD_GetData_Select_Return_ResetSuspend
    in         r3, res[r0]                      // Input packet "word" length  
    int        r11, res[r0]                     // r11 is tail length (bytes)
	shr		   r11, r11, 3

CalcdataLength_:
    shl        r3, r3, 2                        // Num received words to bytes
    add        r3, r11, r3                      // r11: Total bytes received (Note this includes 2 byte crc)

XUD_GetData_CheckPid_: 
    ldw        r11, r1[6]                       // Load received PID from EP structure
    shr        r11, r11, 24                     // Shift down due to inpw
    ldw        r0, r1[4]                        // Load expected PID 

    xor        r11, r0, r11                     // Do the comparison
    ecallt     r11                              //  TODO TODO TODO TODO
    bt          r11, XUD_GetData_Select_Return_BadPid
    //bt         r11, XUD_GetData_Select        // We can't just jump back to XUD_GetData_Select since 

XUD_GetData_PidOkay_: 
    ldw         r11, r1[5]                       // Load EP type
    bf          r11, XUD_GetData_ReturnOk_       // Jump over PID toggle for ISO  

XUD_GetData_PidToggle_:
    ldc         r11, 8
    xor         r0, r0, r11
    stw         r0, r1[4]
 
XUD_GetData_ReturnOk_:
    sub         r0, r3, 2                        // Length correction for CRC correction (return val in r0) 
    stw         r0, r2[0]
    retsp       0
    
XUD_GetData_Select_Return_ResetSuspend:
    mkmsk       r0, 32                           // Return -1 as length
    stw         r0, r2[0]
    retsp       0

XUD_GetData_Select_Return_BadPid:
    ldw         r0, cp[minus2]
    stw         r0, r2[0]
    retsp       0



.cc_bottom XUD_GetData_Select.func






//int XUD_GetData(XUD_ep c, unsigned char buffer[]);
.globl   XUD_GetData
.globl   XUD_GetData.nstackwords
.linkset XUD_GetData.nstackwords, 16
.text

.cc_top XUD_GetData.func, XUD_GetData
XUD_GetData:
    entsp       16
    stw         r10, sp[1]
    mov        r11, r1
    //mov        r1, r0
 
 // ldw        r4, r0[0]                        // Load mem address of EP structure
  //  stw        r2, r0[3]    
  //  stw        r0, r4[0]
  //  ldw        r10, r0[2] 
    
XUD_GetData_:
    ldw        r2, r0[0]                        // Load mem address of EP structure
    stw        r1, r0[3]    
    stw        r0, r2[0]

XUD_GetData_Retry:					  
    ldw        r10, r0[2]                        // Load our chanend ID to use
                                                // Wait for XUD response       
    testct     r11, res[r10]                     // Test whether there is a RESET/SUSPEND exception
    bt         r11, ResetSuspend
    
//XUD_GetData_Select:                             // Entry for _NoReq 
DataEnd:
    in         r3, res[r10]                      // Input packet "word" length  
    int        r11, res[r10]                     // r11 is tail length (bytes)
	shr		   r11, r11, 3
CalcdataLength:
    shl        r3, r3, 2                        // Num received words to bytes
    add        r3, r11, r3                      // r11: Total bytes received (Note this includes 2 byte crc)

XUD_GetData_CheckPid: 
    ldw        r11, r0[6]                       // Load received PID from EP structure
    shr        r11, r11, 24                     // Shift down due to inpw
    ldw        r10, r0[4]                        // Load expected PID 

    xor        r11, r10, r11                     // Do the comparison
    bt         r11, XUD_GetData_                // Ignore packet...

XUD_GetData_PidOkay: 
    stw        r11, r2[0]                       // Zero ready entry (NOTE R11 0 from branch above)  
                                                // TODO is there a race here? Should this happen in XUD thread? 
    
    ldw        r11, r0[5]                       // Load EP type
    bf         r11, XUD_GetData_ReturnOk        // Jump over PID toggle for ISO  

XUD_GetData_PidToggle:
    ldc        r11, 8
    xor        r10, r10, r11
    stw        r10, r0[4]
 
XUD_GetData_ReturnOk:
    sub        r0, r3, 2                        // Length correction for CRC correction (return val in r0) 
    ldw         r10, sp[1]
    retsp      16
    
ResetSuspend:
    mkmsk      r0, 32                           // Return -1 as length

Return:
    ldw         r10, sp[1]
    retsp      16

.cc_bottom XUD_GetData.func









// Note: Assumes startIndex is word aligned
//int XUD_SetData_indexed(chanend c, unsigned buffer[], unsigned datasize, unsigned startIndex unsigned pid); 
//                           r0             r1                  r2                r3

.globl   XUD_SetData_NoReq
.globl   XUD_SetData_NoReq.nstackwords
.linkset XUD_SetData_NoReq.nstackwords, 0

.globl   XUD_SetData
.globl   XUD_SetData.nstackwords
.linkset XUD_SetData.nstackwords, 7
.text

.cc_top XUD_SetData.func, XUD_SetData
XUD_SetData:
    entsp       7    
    stw         r0, sp[1]                        // Reg save (for retry) 
    stw         r1, sp[2]
    stw         r2, sp[3]
    stw         r3, sp[4]
    stw         r5, sp[5]
    stw         r10, sp[6]

XUD_SetDataRetry:       
    stw         r4, sp[0]                        
        
XUD_SetData_NoReq:	
    add         r1, r1, r3                      // Add start index to buffer address

CalcTailLength:
    shl         r3, r2, 5                       // Taillength: bytes to bits * 2
    zext        r3, 7

SetupLoopTerm:
    shr         r2, r2, 2                       // r2: datalength (bytes) ---> r2: datalength (words)

AdjustBufferPointer:
    shl         r5, r2, 2                       // Get end off buffer address
    add         r1, r1, r5

NegativeIndex:                                  // Produce negtive offset from end of buffer
    neg         r2, r2                               
    stw         r2, r0[6]                       // Store index

XUD_SetData_DataRdy:
    ldw         r2, r0[0]                       // Load mem address of EP structure
    stw         r1, r0[3]                       // Store buffer address    
StoreTailLength:
    stw         r3, r0[7]                       // Store tail length (bytes)

    stw         r0, r2[0]                       // Mark ready with address of ep structure 

                                                // Wait for XUD Response    
    ldw         r10, r0[2]                      // Load our chanend ID to use
    testct      r11, res[r10]                   // Test for RESET/SUSPEND exception
    bt          r11, ResetSuspend2

    in          r11, res[r10]                   // Data sent okay 

XUD_SetData_LoadEpType:
    ldw         r11, r0[5]                      // Don't do any toggling for ISO
    bf          r11, XUD_SetData_DonePid

XUD_SetData_PidToggle:                          // 
    ldw         r11, r0[4]                      // Load EP PID from structure 
    ldc         r4, 0x88                        
    xor         r11, r11, r4                
    stw         r11, r0[4]                      // Store back PID

XUD_SetData_DonePid:
    ldw         r0, sp[1]
    ldw         r1, sp[2]
    ldw         r2, sp[3]
    ldw         r3, sp[4]  
Return2:
    ldw         r4, sp[0]        
    ldw         r5, sp[5] 
    ldw         r10, sp[6]     
    retsp       7
    
ResetSuspend2:
        
    mkmsk      r0, 32
    bu         Return2

    .cc_bottom XUD_SetData.func


.globl XUD_ResetEndpoint
.globl   XUD_ResetEndpoint.nstackwords
.linkset XUD_ResetEndpoint.nstackwords, 1
        
.cc_top XUD_ResetEndpoint.func, XUD_ResetEndpoint
XUD_ResetEndpoint:
        entsp 1
        ldw r0, r0[2]
        bf  r1, .L0
        ldw r1, r1[0]
        ldw r1, r1[2]
.L0:        
        bl XUD_ResetEndpoint0
        retsp 1
.cc_bottom XUD_ResetEndpoint.func

.globl   XUD_SetReady
.globl   XUD_SetReady.nstackwords
.linkset XUD_SetReady.nstackwords, 0

.cc_top XUD_SetReady.func, XUD_SetReady
XUD_SetReady:
    ldw        r0,  r0[2]               
    out        res[r0], r1                      
    ldw        r11, r0[0]
    ldw        r2,  r0[1]
    stw        r2, r11[0]
    retsp 0
.cc_bottom XUD_SetReady.func     


.globl   XUD_SetStall_Out
.globl   XUD_SetStall_Out.nstackwords
.linkset XUD_SetStall_Out.nstackwords, 0
        
/* R0: ep number */
.cc_top XUD_SetStall_Out.func, XUD_SetStall_Out
XUD_SetStall_Out:
    ldaw       r1,  dp[handshakeTable_OUT]
    ldc        r2, PIDn_STALL
    stw        r2, r1[r0]               
    retsp 0
.cc_bottom XUD_SetStall_Out.func   


 .globl   XUD_SetStall_In
.globl   XUD_SetStall_In.nstackwords
.linkset XUD_SetStall_In.nstackwords, 0
        
/* R0: ep number */
.cc_top XUD_SetStall_In.func, XUD_SetStall_In
XUD_SetStall_In:
    ldaw       r1,  dp[handshakeTable_IN]
    ldc        r2, PIDn_STALL
    stw        r2, r1[r0]               
    retsp 0
.cc_bottom XUD_SetStall_In.func       

.globl   XUD_UnStall_Out
.globl   XUD_UnStall_Out.nstackwords
.linkset XUD_UnStall_Out.nstackwords, 0
        
/* R0: ep number */
.cc_top XUD_UnStall_Out.func, XUD_UnStall_Out
XUD_UnStall_Out:
    ldaw       r1,  dp[handshakeTable_OUT]
    ldc        r2, PIDn_NAK
    stw        r2, r1[r0]               
    retsp 0
.cc_bottom XUD_UnStall_Out.func   


.globl   XUD_UnStall_In
.globl   XUD_UnStall_In.nstackwords
.linkset XUD_UnStall_In.nstackwords, 0
        
/* R0: ep number */
.cc_top XUD_UnStall_In.func, XUD_UnStall_In
XUD_UnStall_In:
    ldaw       r1,  dp[handshakeTable_IN]
    ldc        r2, PIDn_NAK
    stw        r2, r1[r0]               
    retsp 0
.cc_bottom XUD_UnStall_In.func  
