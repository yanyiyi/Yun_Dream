import processing.serial.*;
import processing.pdf.*;

Serial port; 
boolean record ;
String nowStat ;
int lf = 10 ;
int iLight_Counts = 18 ;
int[][] Aver_Stat = new int[10][iLight_Counts] ;
int[] iLight_Vals = new int[iLight_Counts], iPre_Light_Vals = new int[iLight_Counts] ;
int cAmount = 15; // amount of cloud
int w,h;
float[] fMagic = {   1, 1, 1, 1, 
                     1, 1, 1, 1, 
                     1, 1, 1, 0, 
                     1, 1, 1, 1 ,
                                   1,1} ; 
                                   // 0-15 is the Cds, 16 is FarNear
float[][] fCircle_Size = new float[cAmount][iLight_Counts] ; // , fPre_Circle_Size = new float[iLight_Counts] ;
float[][] fCloud_Alpha = new float[cAmount][iLight_Counts] ; // , fPre_Cloud_Alpha = new float[iLight_Counts] ;
int cANum;
int[][] rPoint = new int[cAmount][iLight_Counts];
int[][] gPoint = new int[cAmount][iLight_Counts];
int[][] bPoint = new int[cAmount][iLight_Counts];

int[] iAlpha_Limit = { 180, 0 } ;

float border = 7 ;
float[] fWidth = new float[cAmount]; // 
float[] fHeight = new float[cAmount]; // Width and Height of the Clould center
float[] fWidthMove = new float[cAmount];
float[] fHeightMove = new float[cAmount]; // Width Height of Clould center
int[] fWidthDir = new int[cAmount]; // direction
int[] fHeightDir = new int[cAmount]; // Width Height of Clould center
int cw,ch;
boolean sketchFullScreen() {
  return true;
} //OPEN fullscreen

int flyingSig = 0; 
//

int[] iInit_Values = new int[iLight_Counts] ;

float[][] R = new float[cAmount][iLight_Counts], G = new float[cAmount][iLight_Counts], B = new float[cAmount][iLight_Counts] ;

void setup(){ /// Processing Setup

        beginRecord( PDF, "frame-####.pdf" );
        sketchFullScreen() ;
        background(120, 210, 250) ;
        port = new Serial( this, Serial.list()[5], 9600 ) ;
        //size( 640, 480) ;
        size( displayWidth, displayHeight ) ;
        noStroke() ; // initail Eniroment
        cw= width;
        ch= height;
        initailPosition(0, cw, ch);  
        
        for ( int i = 0 ; i < iLight_Counts ; i ++ ) {
            iLight_Vals[i] = 0 ;
            iPre_Light_Vals[i] = 200 ;
        } // for()
  
        // Initial: Delay 3 seconds and read 10 pair numbers.
        delay( 1000 ) ;
        nowStat = port.readStringUntil( lf ) ;
        delay( 1000 ) ;
        nowStat = port.readStringUntil( lf ) ;
        
        for ( int i = 0 ; i < 10 ; i ++ ) {
            delay( 100 ) ;
            nowStat = port.readStringUntil( lf ) ;
            Aver_Stat[i] = int( splitTokens( nowStat, "," ) ) ;
            //println( nowStat ) ;
        } // for
  
        // Get average to 'iInit_Values'.
        for ( int i = 0 ; i < 10 ; i ++ )
          for ( int j = 0 ; j < iLight_Counts ; j ++ )
            iInit_Values[j] += Aver_Stat[i][j] / 10 ;
        
} // setup()


void draw() {

  if (record) {
    // Note that #### will be replaced with the frame number. Fancy!
    beginRecord(PDF, "frame-####.pdf"); 
      noStroke();
  }


  if ( 0 < port.available() ) { // for arduino 
          
          nowStat = port.readStringUntil( lf ) ;
          if ( nowStat != null ) {
            print( "\n Receiving:" + nowStat ) ;        
            iLight_Vals = int( splitTokens( nowStat, "," ) ) ;

                if ( iLight_Vals.length >= iLight_Counts ) {
                        print(iLight_Vals[16]);
                        if (iLight_Vals[16] > 1 && iLight_Vals[16] < 50){
                            flyingSig++; 
                            print("GO");
                              if (flyingSig == 10){
                                flyingSig = 0;
                                cFly();
                            }
                        }
                        background( 120, 210, 250 ) ;
                        // Clean window.
                        int cNum = cANum;
                        sensorLight(cNum); 
                        for(int i = 0; i <= cANum; i++ ){
                          creatCloud(i);  
                      }
                      for(int i = 0; i <= cANum; i++ ){
                        if (i != 0) moveCloud(i-1);  
                      }
                      
                } // if iLight_Vals.length >= iLight_Counts
              
          } // if  nowStat != null
          /*  
          if (record) {
            endRecord();
            record = false;
      } // if record
          */
  } // if0 < port.available() 
    
} // draw()
  // Use a keypress so thousands of files aren't created
  


void keyPressed() {
    if (key == CODED) {
          if (keyCode == SHIFT) {
              cANum++;
              initailPosition(cANum,cw,ch);
              if (cANum == cAmount-1) {cANum = 0;
                initailPosition(cANum,cw,ch);
              }

          } else {
          
    }
    record = true;
  }// keyPressed()
}

float fCircleOffset(int cNum, int fCircleNumber, int fCircleDevide) {
  float cF;
  cF = (fCircle_Size[cNum][fCircleNumber]) / fCircleDevide;
  return cF;
}
 
void moveCloud(int cNum) {
      
        fHeightMove[cNum] = random(2,12); // this is amount the cloud raise
        fHeight[cNum] += fHeightMove[cNum] * fHeightDir[cNum];  
        fWidthMove[cNum] = random(-5,5);  // this is amount the cloud shake
        fWidth[cNum] += fWidthMove[cNum] * fWidthDir[cNum];  
}     

       
void creatCloud(int cNum) {
        
        // Base 16 clouds.
        for ( int i = 0 ; i < iLight_Counts ; i ++ ) {
          
          // Cloud Colors.
          rPoint[cNum][i] *= ( R[cNum][i] >= 255 || R[cNum][i] <= 150 ) ? -1 : 1 ;
          gPoint[cNum][i] *= ( G[cNum][i] >= 255 || G[cNum][i] <= 150 ) ? -1 : 1 ;
          bPoint[cNum][i] *= ( B[cNum][i] >= 255 || B[cNum][i] <= 150 ) ? -1 : 1 ;
          R[cNum][i] += random( 0, 3 ) * rPoint[cNum][i] ;
          G[cNum][i] += random( 0, 3 ) * gPoint[cNum][i] ;
          B[cNum][i] += random( 0, 3 ) * bPoint[cNum][i] ;
          
          //fill( 255, fCloud_Alpha[cNum][i] ) ;
          
          fill( B[cNum][i], fCloud_Alpha[cNum][i] ) ;
          // Cloud draw size.
          
          int x_temp = i % 4, y_temp = i / 4 ;
          float x_real = 0, y_real= 0 ;
          
          x_real = ( fWidth[cNum] ) + ( ( ( x_temp == 0 || x_temp == 1 ) ? -1 : 1 ) * fCircleOffset(cNum,i,2) ) + ( ( x_temp == 0 ) ? - fCircleOffset(cNum,i+1, 2) : 0 ) + ( ( x_temp == 3 ) ? fCircleOffset(cNum,i-1,2) : 0 ) ;
          y_real = ( fHeight[cNum] ) + ( ( ( y_temp == 0 || y_temp == 1 ) ? -1 : 1 ) * fCircleOffset(cNum,i,3) ) + ( ( y_temp == 0 ) ? -fCircleOffset(cNum,i+4, 3) : 0 ) + ( ( y_temp == 3 ) ? fCircleOffset(cNum,i-4,3) : 0 ) ;
        
          ellipse( x_real, y_real, fCircle_Size[cNum][i], fCircle_Size[cNum][i] ) ;
          //println( "X:"+ x_real +",Y:"+ y_real +",Size:"+ fCircle_Size[cNum][i] +",Color:"+ B[cNum][i] +",Alpha:"+fCloud_Alpha[cNum][i]) ;
          } // for

        
        // Bonus clouds.
        fill( 255, ( fCloud_Alpha[cNum][1] + fCloud_Alpha[cNum][2] ) * 2 / 3  ) ;
        ellipse( ( fWidth[cNum] ), ( fHeight[cNum] ) - ( fCircleOffset(cNum,1,3) + fCircleOffset(cNum,2,3) + ( fCircleOffset(cNum,5,3) ) + fCircleOffset(cNum,6,3) ) / 2, ( fCircleOffset(cNum,1,3) + fCircleOffset(cNum,2,3) )* 2, ( fCircleOffset(cNum,1,3) + fCircleOffset(cNum,2,3) )* 2 ) ; 
        fill( 255, ( fCloud_Alpha[cNum][5] + fCloud_Alpha[cNum][6] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ), ( fHeight[cNum] ) - ( fCircleOffset(cNum,5,3) + fCircleOffset(cNum,6,3) ) / 2, ( fCircleOffset(cNum,5,3) + fCircleOffset(cNum,6,3) ) * 2, ( fCircleOffset(cNum,5,3)+ fCircleOffset(cNum,6,3) ) * 2) ;
        fill( 255, ( fCloud_Alpha[cNum][9] + fCloud_Alpha[cNum][10] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ), ( fHeight[cNum] ) + ( fCircleOffset(cNum,9,3) + fCircleOffset(cNum,10,3) ) / 2, ( fCircleOffset(cNum,9,3) + fCircleOffset(cNum,10,3) ) * 2, ( fCircleOffset(cNum,9,3) + fCircleOffset(cNum,10,3) ) * 2) ;
        fill( 255, ( fCloud_Alpha[cNum][13] + fCloud_Alpha[cNum][14] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ), ( fHeight[cNum] ) + ( fCircleOffset(cNum,13,3) + fCircleOffset(cNum,14,3) + fCircleOffset(cNum,9,3) + fCircleOffset(cNum,10,3)) / 2, ( fCircleOffset(cNum,13,3) + fCircleOffset(cNum,14,3) ) * 2, ( fCircle_Size[cNum][13] + fCircle_Size[cNum][14] ) * 2 / 3 ) ; 
        
        fill( 255, ( fCloud_Alpha[cNum][4] + fCloud_Alpha[cNum][8] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ) - ( ( fCircle_Size[cNum][4] / 3 ) + ( fCircle_Size[cNum][8] / 3 ) ) / 2, ( fHeight[cNum] ), ( fCircle_Size[cNum][4] + fCircle_Size[cNum][8] ) * 2 / 3, ( fCircle_Size[cNum][4] + fCircle_Size[cNum][8] ) * 2 / 3 ) ;
        fill( 255, ( fCloud_Alpha[cNum][7] + fCloud_Alpha[cNum][11] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ) + ( ( fCircle_Size[cNum][7] / 3 ) + ( fCircle_Size[cNum][11] / 3 ) ) / 2, ( fHeight[cNum] ), ( fCircle_Size[cNum][7] + fCircle_Size[cNum][11] ) * 2 / 3, ( fCircle_Size[cNum][7] + fCircle_Size[cNum][11] ) * 2 / 3 ) ;     

        fill( 255, ( fCloud_Alpha[cNum][4] + fCloud_Alpha[cNum][8] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ) - ( ( fCircle_Size[cNum][4] / 3 ) + ( fCircle_Size[cNum][8] / 3 ) ) , ( fHeight[cNum] ), ( fCircle_Size[cNum][4] + fCircle_Size[cNum][8] ) * 2 / 3, ( fCircle_Size[cNum][4] + fCircle_Size[cNum][8] ) * 2 / 3 ) ;
        fill( 255, ( fCloud_Alpha[cNum][7] + fCloud_Alpha[cNum][11] ) * 2 / 3 ) ;
        ellipse( ( fWidth[cNum] ) + ( ( fCircle_Size[cNum][7] / 3 ) + ( fCircle_Size[cNum][11] / 3 ) ), ( fHeight[cNum] ), ( fCircle_Size[cNum][7] + fCircle_Size[cNum][11] ) * 2 / 3, ( fCircle_Size[cNum][7] + fCircle_Size[cNum][11] ) * 2 / 3 ) ;     

   fill( 255, ( fCloud_Alpha[cNum][4] + fCloud_Alpha[cNum][8] ) * 2 / 4 ) ;
        ellipse( ( fWidth[cNum] ) - ( ( fCircle_Size[cNum][4] / 3 ) + ( fCircle_Size[cNum][8] / 3 ) ) , ( fHeight[cNum] ), ( fCircle_Size[cNum][4] + fCircle_Size[cNum][8] ) * 2 / 3, ( fCircle_Size[cNum][4] + fCircle_Size[cNum][8] ) * 2 / 3 ) ;
        fill( 255, ( fCloud_Alpha[cNum][7] + fCloud_Alpha[cNum][11] ) * 2 / 4 ) ;
        ellipse( ( fWidth[cNum] ) + ( ( fCircle_Size[cNum][7] / 3 ) + ( fCircle_Size[cNum][11] / 3 ) ), ( fHeight[cNum] ), ( fCircle_Size[cNum][7] + fCircle_Size[cNum][11] ) * 2 / 3, ( fCircle_Size[cNum][7] + fCircle_Size[cNum][11] ) * 2 / 3 ) ;     

        
    } // function Cloud


void initailPosition(int cNum, int w, int h) {
        fHeightDir[cNum] = -1;
        fWidthDir[cNum] = -1;
        fWidth[cNum] = w/2;
        fHeight[cNum] = h/2 + h/4; /// Center of CLOUD
        print(fWidth[cNum],fHeight[cNum]);
        for ( int i = 0 ; i < iLight_Counts ; i ++ ) {
                R[cNum][i] = random( 210, 255 ) ;
                G[cNum][i] = random( 210, 255 ) ;
                B[cNum][i] = random( 210, 255 ) ;
                } // for
} //initailPosition

void sensorLight(int cNum){
        for ( int i = 0 ; i < iLight_Counts ; i ++ )
                        if ( abs( iLight_Vals[i] - iPre_Light_Vals[i] ) <= 50 )
                          iLight_Vals[i] = iPre_Light_Vals[i] ;
                      
                      for ( int i = 0 ; i < iLight_Counts ; i ++ )
                        if ( iLight_Vals[i] >= iInit_Values[i] )
                          iLight_Vals[i] = iInit_Values[i] ;
                     
                      for ( int i = 0 ; i < iLight_Counts ; i ++ )
                        if ( iInit_Values[i] >= iLight_Vals[i] )
                          fCircle_Size[cNum][i] = map( iLight_Vals[i], 0, iInit_Values[i], width * fMagic[i] / border, 0 ) ;
                      
                      for ( int i = 0 ; i < iLight_Counts ; i ++ )
                        if ( iInit_Values[i] >= iLight_Vals[i] )
                          fCloud_Alpha[cNum][i] = map( iLight_Vals[i], iAlpha_Limit[1], iInit_Values[i], iAlpha_Limit[0], iAlpha_Limit[1] ) ;         
}
void cFly(){
              cANum++;
              initailPosition(cANum,cw,ch);
              if (cANum == cAmount-1) {cANum = 0;
                initailPosition(cANum,cw,ch);
              }             
}
