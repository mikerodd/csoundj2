/*
  juno2extract.c - Convert sysex bulk copy from Juno-1/Juno-2 to 
  snaps file compatible with cabbage.


  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.

 */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

int help() {
  printf(
	 "Usage :  juno2extract sysexfile \n"
	 "Convert a sysex bulk data file from a Juno-1/Juno-2,\n"
	 "output an XML file compatible with cabbage \n"
	 );
}


int error(int err, char* msg) {
  printf("ERR %d - %s\n", err, msg);
  exit(err);
}

int verif_test(int test,int err, char* msg) {
  if (!test)  error(err,msg);
}


#define TEST_HEADER(a,s)   verif_test(((buf[count] & a )== a),2,s); count++; 


#define BUILD_BYTE (buf[count++]) | (buf[count++])<<4

int main(int argc, char** argv) {
  char buf[10000];
  char tablechars[64] = "ABCDEFGHIJKLMNOPKRSTUVWXYZabcdefghijklmnopkrstuvwxyz0123456789 -";
  char pname[11]="          "; 

  if (argc != 2) {
    help();
    error(100,"Invalid number of arguments");
  }
  /* Pointer to the file */
  FILE *fp1;
  void* pcur;
  /* Character variable to read the content of file */

  int err = 0 ;
  int lg, count, i, j ;
  unsigned int value, b[22], c[7];
  
  
  /* Opening a file in r mode*/

  if ((fp1 = fopen(argv[1], "r")) == NULL) error(1,"Invalid file...");

  printf("<?xml version=""1.0"" encoding=""UTF-8""?>\n");
  printf("<CABBAGE_PRESETS>\n");

  lg = fread(buf,1,9000,fp1);
  fclose(fp1);
  
  /*  printf("size : %d\n",lg);*/
  count = 0;

  for (j=0; j < 16; j++) {
  
    TEST_HEADER(0xF0,"Expected F0 (Exclusive Status) in 0");
    TEST_HEADER(0x41,"Expected 41 (Roland ID) in 1");
    TEST_HEADER(0x37,"Expected 37 (Bulk mode) in 2");
    TEST_HEADER(0x00,"Expected 00 (Midi channel 0) in 3");
    TEST_HEADER(0x23,"Expected 23 (Format JU-1, JU-2) in 4");
    TEST_HEADER(0x20,"Expected 20 (Level #1) in 5");
    TEST_HEADER(0x01,"Expected 01 (Group #) in 6");
    TEST_HEADER(0x00,"Expected something (Extension of program #) in 7");
    TEST_HEADER(j*4,"Expected program count (Extension of program #) in 7");
    
    
    for (i =0; i < 4; i++) {
      
      strcpy(pname,"          ");
      printf("  <PRESET%d\n",i + j * 4);
      
      /* byte 0 */
      /* printf("before : %02x (%d)\n",buf[count], count); */
      value = BUILD_BYTE ;
      /*printf("byte 0 : %02x\n",value );*/
      printf("    dcoaftr=\"%d\"\n",(value&0xF0)>>4);
      printf("    vcfkybd=\"%d\"\n",value&0xF);
      
      /* byte 1 */
      value = BUILD_BYTE ;
      printf("    vcfaftr=\"%d\"\n",(value&0xF0)>>4);
      printf("    vcaaftr=\"%d\"\n",value&0xF);
      
      /* byte 2 */
      value = BUILD_BYTE ;
      printf("    envkbd=\"%d\"\n",(value&0xF0)>>4);
      printf("    dcobnd=\"%d\"\n",value&0xF);
      
      /* byte 3 */
      value = BUILD_BYTE ;
      printf("    dcolfo=\"%d\"\n",value&0b01111111);
      
      /* byte 4 */
      value = BUILD_BYTE ;
      b[0] = (value&0b10000000)>>7;
      
      printf("    chorus=\"%d\"\n",b[0]);
      printf("    dcoenvd=\"%d\"\n",value&0b01111111);
      
      /* byte 5 */
      value = BUILD_BYTE ;
      b[1] = (value&0b10000000)>>6;
      printf("    pwpwm=\"%d\"\n",value&0b01111111);
      
      /* byte 6 */
      value = BUILD_BYTE ;
      b[2] = (value&0b10000000)>>7;
      printf("    pwmrate=\"%d\"\n",value&0b01111111);
      printf("    dcoenv=\"%d\"\n",(b[1]|b[2]) + 1);
      
      /* byte 7 */
      value = BUILD_BYTE ;
      b[3] = (value&0b10000000)>>6 ;
      printf("    vcffreq=\"%d\"\n",value&0b01111111);
      
      /* byte 8 */
      value = BUILD_BYTE ;
      b[4] = (value&0b10000000)>>7 ;
      printf("    vcfreso=\"%d\"\n",value&0b01111111);
      printf("    vcfenv=\"%d\"\n",(b[3]|b[4]) + 1);

      /* byte 9 */
      value = BUILD_BYTE ;
      b[5] = (value&0b10000000)>>6 ;
      printf("    vcfenvd=\"%d\"\n",value&0b01111111);
      
      /* byte 10 */
      value = BUILD_BYTE ;
      b[6] = (value&0b10000000)>>7 ;
      printf("    vcflfo=\"%d\"\n",value&0b01111111);
      printf("    vcaenv=\"%d\"\n",(b[5]|b[6]) + 1);
      
      /* byte 11 */
      value = BUILD_BYTE ;
      b[7] = (value&0b10000000)>>5 ;
      printf("    vcalevl=\"%d\"\n",value&0b01111111);
      
      /* byte 12 */
      value = BUILD_BYTE ;
      b[8] = (value&0b10000000)>>6 ;
      printf("    lforate=\"%d\"\n",value&0b01111111);
      
      /* byte 13 */
      value = BUILD_BYTE ;
      b[9] = (value&0b10000000)>>7 ;
      printf("    lfodely=\"%d\"\n",value&0b01111111);
      printf("    sub=\"%d\"\n",(b[7]|b[8]|b[9]) + 1);
      
      /* byte 14 */
      value = BUILD_BYTE ;
      b[10] = (value&0b10000000)>>5 ;
      printf("    envt1=\"%d\"\n",value&0b01111111);
      
      /* byte 15 */
      value = BUILD_BYTE ;
      b[11] = (value&0b10000000)>>6 ;
      printf("    envl1=\"%d\"\n",value&0b01111111);
      
      /* byte 16 */
      value = BUILD_BYTE ;
      b[12] = (value&0b10000000)>>7 ;
      printf("    envt2=\"%d\"\n",value&0b01111111);
      printf("    sawtooth=\"%d\"\n",(b[10]|b[11]|b[12]) + 1);
      
      /* byte 17 */
      value = BUILD_BYTE ;
      b[13] = (value&0b10000000)>>6 ;
      printf("    envl2=\"%d\"\n",value&0b01111111);
      
      /* byte 18 */
      value = BUILD_BYTE ;
      b[14] = (value&0b10000000)>>7 ;
      printf("    envt3=\"%d\"\n",value&0b01111111);
      printf("    pulse=\"%d\"\n",(b[13]|b[14]) + 1);
      
      /* byte 19 */
      value = BUILD_BYTE ;
      b[15] = (value&0b10000000)>>6 ;
      printf("    envl3=\"%d\"\n",value&0b01111111);
      
      /* byte 20 */
      value = BUILD_BYTE ;
      b[16] = (value&0b10000000)>>7 ;
      printf("    envt4=\"%d\"\n",value&0b01111111);
      printf("    hpffreq=\"%d\"\n",(b[15]|b[16]) + 1);
      
      /* byte 21 */
      value = BUILD_BYTE ;
      pname[0] = tablechars[value&0b00111111];
      b[17] = (value&0b10000000)>>6 ;
      
      /* byte 22 */
      value = BUILD_BYTE ;
      pname[1] = tablechars[value&0b00111111];
      b[18] = (value&0b10000000)>>7 ;
      printf("    dcorng=\"%d\"\n",(b[17]|b[18]) + 1);
      
      /* byte 23 */
      value = BUILD_BYTE ;
      pname[2] = tablechars[value&0b00111111];
      b[19] = (value&0b10000000)>>6 ;
      
      /* byte 24 */
      value = BUILD_BYTE ;
      pname[3] = tablechars[value&0b00111111];
      b[20] = (value&0b10000000)>>7 ;
      printf("    sublevl=\"%d\"\n",(b[19]|b[20]) + 1);
      
      /* byte 25 */
      value = BUILD_BYTE ;
      pname[4] = tablechars[value&0b00111111];
      b[21] = (value&0b10000000)>>6 ;
      
      /* byte 26 */
      value = BUILD_BYTE ;
      pname[5] = tablechars[value&0b00111111];
      b[22] = (value&0b10000000)>>7 ;
      printf("    noislvl=\"%d\"\n",(b[21]|b[22]) + 1);
      
      /* byte 27 */
      value = BUILD_BYTE ;
      pname[6] = tablechars[value&0b00111111];
      c[0] = (value&0b10000000)>>6 ;
      c[1] = (value&0b01000000)>>6 ;
      
      /* byte 28 */
      value = BUILD_BYTE ;
      pname[7] = tablechars[value&0b00111111];
      c[3] = (value&0b10000000)>>4 ;
      c[2] = (value&0b01000000)>>4 ;
      
      /* byte 29 */
      value = BUILD_BYTE ;
      pname[8] = tablechars[value&0b00111111];
      c[5] = (value&0b10000000)>>2 ;
      c[4] = (value&0b01000000)>>2 ;
      
      /* byte 30 */
      value = BUILD_BYTE ;
      pname[9] = tablechars[value&0b00111111];
      c[7] = (value&0b10000000) ;
      c[6] = (value&0b01000000) ;
      
      printf("    crsrate=\"%d\"\n",(c[0]|c[1]|c[2]|c[3]|c[4]|c[5]|c[6]|c[7]));
      printf("    PresetName=\"P%d%d-  %s\"\n",j/2 +1,i + 1+(j % 2) *4,pname);
      

      
      /* byte 31 */
      TEST_HEADER(0x0,"Expected 0 (Dummy) ");
      TEST_HEADER(0x0,"Expected 0 (Dummy) ");
      
      /* end PRESET */
      printf ("  />\n");
    }
    TEST_HEADER(0xF7,"Expected F7 (End of System Exlusive) ");
    /* printf(" end : %02x (%02x)\n",buf[count], count);*/
  }  
  
  
  


  printf("</CABBAGE_PRESETS>\n");

  

  return 0;
}
